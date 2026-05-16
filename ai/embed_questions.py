"""
批量生成题目解析的向量嵌入（RAG Embedding）
模型：GLM Embedding-2 (1536维)
API：https://open.bigmodel.cn/api/paas/v4/embeddings

使用方法：
    1. 先执行 database/05_rag_embeddings.sql 添加 embedding 列
    2. 设置环境变量 GLM_API_KEY
    3. python ai/embed_questions.py

输出：更新 t_text_content.embedding 列为 JSON float[] 格式
"""
import json
import time
import pymysql
import requests
import os
import sys
from concurrent.futures import ThreadPoolExecutor, as_completed
from threading import Lock

GLM_API_KEY = os.environ.get("GLM_API_KEY", "e4a645c3ea464385acdafec1f41b2e9b.vJnGYzcGzAESUSBu")
EMBED_API_URL = "https://open.bigmodel.cn/api/paas/v4/embeddings"
EMBED_MODEL = "embedding-2"
BATCH_SIZE = 20
MAX_WORKERS = 5
MAX_TEXT_LENGTH = 8000

DB_CONFIG = {
    "host": "localhost",
    "port": 3306,
    "user": "root",
    "password": "123456",
    "database": "xzs",
    "charset": "utf8mb4",
}

db_lock = Lock()


def get_connection():
    return pymysql.connect(**DB_CONFIG)


def get_unembedded_rows(conn, limit=None):
    """查询尚未生成 embedding 的题目解析文本"""
    sql = """
        SELECT id, content
        FROM t_text_content
        WHERE embedding IS NULL
          AND content IS NOT NULL
          AND content != ''
        ORDER BY id
    """
    if limit:
        sql += f" LIMIT {limit}"
    with conn.cursor() as cursor:
        cursor.execute(sql)
        return cursor.fetchall()


def get_id_title_mapping(conn):
    """获取 text_content id -> 题目标题 的映射（通过 t_question 关联）"""
    sql = """
        SELECT tc.id, COALESCE(q.question_title, tc.id) AS title
        FROM t_text_content tc
        LEFT JOIN t_question q ON q.info_text_content_id = tc.id
        WHERE tc.embedding IS NULL
    """
    with conn.cursor() as cursor:
        cursor.execute(sql)
        rows = cursor.fetchall()
        return {r[0]: r[1] for r in rows}


def get_embedding(text):
    """调用 GLM Embedding API 获取向量"""
    headers = {
        "Authorization": f"Bearer {GLM_API_KEY}",
        "Content-Type": "application/json",
    }
    payload = {
        "model": EMBED_MODEL,
        "input": text[:MAX_TEXT_LENGTH],
    }
    try:
        resp = requests.post(EMBED_API_URL, headers=headers, json=payload, timeout=60)
        if resp.status_code == 200:
            data = resp.json()
            embedding_list = data["data"][0]["embedding"]
            return embedding_list
        else:
            print(f"  Embedding API error: {resp.status_code} {resp.text[:200]}")
            return None
    except Exception as e:
        print(f"  Embedding API exception: {e}")
        return None


def update_embedding(conn, text_id, embedding_list):
    """更新数据库中的 embedding 列"""
    json_str = json.dumps(embedding_list)
    sql = "UPDATE t_text_content SET embedding = %s WHERE id = %s"
    with db_lock:
        with conn.cursor() as cursor:
            cursor.execute(sql, (json_str, text_id))
        conn.commit()


def embed_batch(rows, id_title_map, conn):
    """批量生成 embedding 并更新数据库"""
    count = 0
    for text_id, content in rows:
        title = id_title_map.get(text_id, f"text_{text_id}")
        title_short = title[:50]
        print(f"Embedding {text_id}: {title_short}...")

        embedding = get_embedding(content)
        if embedding:
            update_embedding(conn, text_id, embedding)
            count += 1
            print(f"  -> OK ({len(embedding)} dims)")
        else:
            print(f"  -> FAILED")

        time.sleep(0.2)  # rate limit

        if count % 20 == 0:
            print(f"\n进度: {count} 条完成\n")

    return count


def main():
    print("=" * 60)
    print("408Master RAG Embedding Generator")
    print(f"Model: {EMBED_MODEL}")
    print(f"API: {EMBED_API_URL}")
    print("=" * 60)

    conn = get_connection()

    rows = get_unembedded_rows(conn, limit=None)
    total = len(rows)
    print(f"\n待 embedding 的记录数: {total}")

    if total == 0:
        print("所有题目已生成 embedding！")
        conn.close()
        return

    id_title_map = get_id_title_mapping(conn)
    print(f"标题映射: {len(id_title_map)} 条")

    start = time.time()
    embedded = embed_batch(rows, id_title_map, conn)
    elapsed = time.time() - start

    print(f"\n{'=' * 60}")
    print(f"完成！{embedded}/{total} 条成功，耗时 {elapsed:.1f} 秒")
    print(f"{'=' * 60}")

    conn.close()


if __name__ == "__main__":
    main()
