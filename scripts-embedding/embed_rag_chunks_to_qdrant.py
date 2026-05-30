import base64
import hashlib
import json
import os
import re
import subprocess
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path

from cryptography.hazmat.primitives.ciphers.aead import AESGCM


ROOT = Path(__file__).resolve().parents[1]
MYSQL_CONTAINER = os.environ.get("MYSQL_CONTAINER", "xzs-mysql")
MYSQL_DATABASE = os.environ.get("MYSQL_DATABASE", "xzs")
MYSQL_PASSWORD = os.environ.get("MYSQL_ROOT_PASSWORD", "doushijiaxiang0.")
QDRANT_URL = os.environ.get("QDRANT_URL", "http://127.0.0.1:6333").rstrip("/")
COLLECTION = os.environ.get("QDRANT_COLLECTION", "xzs_408_chunks")
PROVIDER = os.environ.get("AI_PROVIDER_CODE", "zhipu")


def run_mysql(sql, raw=False):
    cmd = [
        "docker",
        "exec",
        "-e",
        f"MYSQL_PWD={MYSQL_PASSWORD}",
        MYSQL_CONTAINER,
        "mysql",
        "-uroot",
        MYSQL_DATABASE,
        "--default-character-set=utf8mb4",
        "-N",
        "-B",
    ]
    if raw:
        cmd.append("--raw")
    cmd.extend(["-e", sql])
    result = subprocess.run(cmd, cwd=ROOT, text=True, capture_output=True, check=True)
    return result.stdout


def read_provider():
    rows = run_mysql(
        "SELECT api_key_cipher, api_base_url, embedding_model "
        f"FROM ai_provider_config WHERE provider_code='{PROVIDER}' LIMIT 1;"
    ).splitlines()
    if not rows:
        raise RuntimeError(f"Provider not found: {PROVIDER}")
    parts = rows[0].split("\t")
    if len(parts) < 3 or not parts[0]:
        raise RuntimeError(f"Provider {PROVIDER} has no encrypted API key")
    return {
        "cipher": parts[0],
        "base_url": (parts[1] or "https://open.bigmodel.cn/api/paas/v4").rstrip("/"),
        "model": parts[2] or "embedding-2",
    }


def candidate_master_keys():
    keys = []
    env_key = os.environ.get("AI_SECRET_MASTER_KEY")
    if env_key:
        keys.append(env_key)
    keys.append("408MasterLocalSecret")
    app_yml = ROOT / "source" / "xzs" / "src" / "main" / "resources" / "application.yml"
    if app_yml.exists():
        text = app_yml.read_text(encoding="utf-8", errors="ignore")
        match = re.search(r"privateKey:\s*([A-Za-z0-9+/=]+)", text)
        if match:
            keys.append(match.group(1))
    deduped = []
    for key in keys:
        if key and key not in deduped:
            deduped.append(key)
    return deduped


def decrypt_api_key(cipher_text):
    blob = base64.b64decode(cipher_text)
    nonce, payload = blob[:12], blob[12:]
    errors = []
    for master_key in candidate_master_keys():
        key = hashlib.sha256(master_key.encode("utf-8")).digest()
        try:
            return AESGCM(key).decrypt(nonce, payload, None).decode("utf-8")
        except Exception as exc:
            errors.append(type(exc).__name__)
    raise RuntimeError(f"Cannot decrypt API key with known master keys: {', '.join(errors)}")


def fetch_chunks():
    sql = """
    SELECT JSON_OBJECT(
      'id', rc.id,
      'document_id', rc.document_id,
      'title', rd.title,
      'chunk_index', rc.chunk_index,
      'chunk_text', COALESCE(rc.content_text, rc.content),
      'content_hash', rc.content_hash,
      'knowledge_point_id', rc.knowledge_point_id
    )
    FROM rag_chunk rc
    JOIN rag_document rd ON rd.id = rc.document_id
    LEFT JOIN rag_embedding re
      ON re.chunk_id = rc.id
     AND re.embedding_model = 'embedding-2'
     AND re.collection_name = 'xzs_408_chunks'
    WHERE rc.enabled = b'1'
      AND (re.id IS NULL OR re.status <> 'indexed')
    ORDER BY rc.id;
    """
    rows = run_mysql(sql, raw=True).splitlines()
    return [json.loads(row) for row in rows if row.strip()]


def http_json(method, url, body=None, headers=None, timeout=120):
    payload = None if body is None else json.dumps(body, ensure_ascii=False).encode("utf-8")
    req_headers = {"Content-Type": "application/json"}
    if headers:
        req_headers.update(headers)
    req = urllib.request.Request(url, data=payload, headers=req_headers, method=method)
    try:
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            text = resp.read().decode("utf-8")
            return json.loads(text) if text else {}
    except urllib.error.HTTPError as exc:
        text = exc.read().decode("utf-8", errors="ignore")
        raise RuntimeError(f"HTTP {exc.code}: {text}")


def embed_text(api_key, base_url, model, text):
    body = {
        "model": model,
        "input": (text or "")[:8000],
    }
    result = http_json(
        "POST",
        f"{base_url}/embeddings",
        body,
        headers={"Authorization": f"Bearer {api_key}"},
        timeout=180,
    )
    data = result.get("data") or []
    if not data:
        raise RuntimeError(f"Embedding response has no data: {json.dumps(result, ensure_ascii=False)[:500]}")
    return data[0]["embedding"], result.get("usage") or {}


def ensure_collection(vector_size):
    existing = http_json("GET", f"{QDRANT_URL}/collections")
    names = [item.get("name") for item in existing.get("result", {}).get("collections", [])]
    if COLLECTION in names:
        return
    http_json(
        "PUT",
        f"{QDRANT_URL}/collections/{COLLECTION}",
        {
            "vectors": {
                "size": vector_size,
                "distance": "Cosine",
            }
        },
    )


def upsert_point(chunk, vector):
    point_id = int(chunk["id"])
    payload = {
        "chunk_id": point_id,
        "document_id": chunk.get("document_id"),
        "title": chunk.get("title"),
        "chunk_index": chunk.get("chunk_index"),
        "content_hash": chunk.get("content_hash"),
        "knowledge_point_id": chunk.get("knowledge_point_id"),
        "text": chunk.get("chunk_text"),
    }
    http_json(
        "PUT",
        f"{QDRANT_URL}/collections/{COLLECTION}/points?wait=true",
        {"points": [{"id": point_id, "vector": vector, "payload": payload}]},
        timeout=180,
    )


def sql_quote(value):
    if value is None:
        return "NULL"
    return "'" + str(value).replace("\\", "\\\\").replace("'", "''") + "'"


def update_embedding(chunk_id, model, dimension, status, error=None):
    vector_id = str(chunk_id)
    sql = f"""
    INSERT INTO rag_embedding
      (chunk_id, embedding_model, embedding_dimension, vector_store, collection_name,
       vector_id, payload_hash, indexed_at, status, error_message)
    VALUES
      ({int(chunk_id)}, {sql_quote(model)}, {int(dimension)}, 'qdrant', {sql_quote(COLLECTION)},
       {sql_quote(vector_id)}, SHA2(CONCAT({int(chunk_id)}, '|', {sql_quote(model)}, '|', {sql_quote(COLLECTION)}), 256),
       {('NOW()' if status == 'indexed' else 'NULL')}, {sql_quote(status)}, {sql_quote(error)})
    ON DUPLICATE KEY UPDATE
      embedding_dimension = VALUES(embedding_dimension),
      vector_store = VALUES(vector_store),
      vector_id = VALUES(vector_id),
      payload_hash = VALUES(payload_hash),
      indexed_at = VALUES(indexed_at),
      status = VALUES(status),
      error_message = VALUES(error_message),
      update_time = NOW();
    """
    run_mysql(sql)


def main():
    provider = read_provider()
    api_key = decrypt_api_key(provider["cipher"])
    chunks = fetch_chunks()
    print(f"Need embedding: {len(chunks)} chunks")
    if not chunks:
        return 0

    success = 0
    failed = 0
    collection_ready = False
    for index, chunk in enumerate(chunks, start=1):
        chunk_id = int(chunk["id"])
        try:
            vector, usage = embed_text(api_key, provider["base_url"], provider["model"], chunk.get("chunk_text") or "")
            if not collection_ready:
                ensure_collection(len(vector))
                collection_ready = True
            upsert_point(chunk, vector)
            update_embedding(chunk_id, provider["model"], len(vector), "indexed")
            success += 1
            print(f"[{index}/{len(chunks)}] chunk {chunk_id} indexed dim={len(vector)} tokens={usage.get('total_tokens', '')}")
            time.sleep(0.15)
        except Exception as exc:
            failed += 1
            message = str(exc)[:950]
            update_embedding(chunk_id, provider["model"], 0, "failed", message)
            print(f"[{index}/{len(chunks)}] chunk {chunk_id} failed: {message}", file=sys.stderr)
            if "余额不足" in message or "资源包" in message or "HTTP 429" in message:
                print("Quota/rate/resource error detected; stop early.", file=sys.stderr)
                break

    print(f"Done. success={success}, failed={failed}")
    return 0 if failed == 0 else 2


if __name__ == "__main__":
    raise SystemExit(main())
