import argparse
import hashlib
import json
import re
import time
from collections import defaultdict, deque
from copy import copy
from dataclasses import dataclass
from pathlib import Path
from urllib.parse import urljoin, urlparse

import requests
from bs4 import BeautifulSoup, Tag


BASE_URL = "https://www.csgraduates.com"
SOURCE_NAME = "csgraduates"

SUBJECT_SPECS = [
    {
        "subject_id": 1,
        "subject_name": "数据结构",
        "slug": "data-structure",
        "prefix": "/data_structure/",
    },
    {
        "subject_id": 2,
        "subject_name": "计算机组成原理",
        "slug": "constitution-principle",
        "prefix": "/constitution_principle/",
    },
    {
        "subject_id": 3,
        "subject_name": "操作系统",
        "slug": "operating-system",
        "prefix": "/operating_system/",
    },
    {
        "subject_id": 4,
        "subject_name": "计算机网络",
        "slug": "computer-network",
        "prefix": "/computer_network/",
    },
]


@dataclass
class KnowledgePage:
    subject_id: int
    subject_name: str
    subject_slug: str
    title: str
    url: str
    source_path: str
    html_ref: str
    asset_dir: str
    summary: str
    html: str
    existing_id: int | None = None
    level: int = 1
    sort_order: int = 0


def safe_slug(value: str) -> str:
    slug = re.sub(r"[^A-Za-z0-9_.-]+", "-", value.strip())
    return slug.strip("-").lower() or "item"


def sql_string(value) -> str:
    if value is None:
        return "NULL"
    value = str(value)
    return "'" + value.replace("\\", "\\\\").replace("'", "''") + "'"


def fetch_text(session: requests.Session, url: str, timeout: int = 30) -> str:
    response = session.get(url, timeout=timeout)
    response.raise_for_status()
    response.encoding = "utf-8"
    return response.text


def safe_write_text(path: Path, content: str):
    path.parent.mkdir(parents=True, exist_ok=True)
    try:
        path.write_text(content, encoding="utf-8")
    except OSError as exc:
        # Windows search/AV indexing can briefly lock large generated HTML files.
        # Keeping the previous generated copy is better than failing the whole crawl.
        if path.exists():
            print(f"  warning: skipped locked file {path}: {exc}")
            return
        path.write_text(content, encoding="utf-8")


def discover_urls(session: requests.Session) -> list[dict]:
    sitemap = fetch_text(session, f"{BASE_URL}/sitemap.xml")
    urls = [u.replace("http://", "https://") for u in re.findall(r"<loc>(.*?)</loc>", sitemap)]
    pages = []
    for url in urls:
        path = urlparse(url).path
        if "/study_methods/" in path:
            continue
        for spec in SUBJECT_SPECS:
            if path.startswith(spec["prefix"]):
                pages.append({**spec, "url": url})
                break
    return sorted(
        {page["url"]: page for page in pages}.values(),
        key=lambda page: (page["subject_id"], urlparse(page["url"]).path.count("/"), page["url"]),
    )


def clean_node(node: Tag) -> Tag:
    node = copy(node)
    for tag in node.find_all(["script", "style", "button", "nav"]):
        tag.decompose()
    for tag in node.select(".td-breadcrumbs, .td-page-meta, .td-sidebar-nav, .pageinfo, .alert"):
        tag.decompose()
    for tag in node.find_all(True):
        for attr in list(tag.attrs):
            name = attr.lower()
            if name.startswith("on"):
                del tag.attrs[attr]
        classes = tag.get("class")
        if classes:
            tag["class"] = [cls for cls in classes if not str(cls).startswith("td-")]
    return node


def inner_html(tag: Tag) -> str:
    cleaned = clean_node(tag)
    return "".join(str(child) for child in cleaned.contents).strip()


def text_of_html(html: str) -> str:
    soup = BeautifulSoup(html, "html.parser")
    return re.sub(r"\s+", " ", soup.get_text(" ", strip=True)).strip()


def summary_of_html(html: str) -> str:
    soup = BeautifulSoup(html, "html.parser")
    for tag in soup.find_all(["svg", "pre", "code"]):
        tag.decompose()
    text = re.sub(r"\s+", " ", soup.get_text(" ", strip=True)).strip()
    tokens = text.split(" ")
    while tokens and re.fullmatch(r"[A-E]|\d{1,2}", tokens[0]):
        tokens.pop(0)
    return " ".join(tokens)[:480]


def localize_html_assets(
    html: str,
    source_url: str,
    session: requests.Session,
    asset_public_prefix: str,
    asset_disk_dir: Path,
    failures: list[str],
) -> str:
    if not html:
        return html
    soup = BeautifulSoup(f"<div>{html}</div>", "html.parser")
    asset_disk_dir.mkdir(parents=True, exist_ok=True)
    for img in soup.find_all("img"):
        src = img.get("src") or img.get("data-src")
        if not src or src.startswith("data:"):
            continue
        absolute = urljoin(source_url, src)
        parsed = urlparse(absolute)
        suffix = Path(parsed.path).suffix.lower()
        if suffix not in [".svg", ".png", ".jpg", ".jpeg", ".webp", ".gif"]:
            suffix = ".png"
        digest = hashlib.sha256(absolute.encode("utf-8")).hexdigest()[:16]
        filename = f"{safe_slug(Path(parsed.path).stem)}-{digest}{suffix}"
        target = asset_disk_dir / filename
        if not target.exists():
            try:
                response = session.get(absolute, timeout=30)
                response.raise_for_status()
                target.write_bytes(response.content)
            except Exception as exc:
                failures.append(f"{absolute}: {exc}")
                continue
        img["src"] = f"{asset_public_prefix}/{filename}"
        for attr in ["data-src", "srcset", "data-srcset"]:
            if attr in img.attrs:
                del img.attrs[attr]
    return soup.div.decode_contents()


def parse_current_knowledge_points(path: Path) -> dict[tuple[int, str], deque[int]]:
    if not path.exists():
        return {}
    content = path.read_text(encoding="utf-8", errors="ignore")
    pattern = re.compile(
        r"INSERT INTO `knowledge_point` .*? VALUES \((\d+),'((?:[^']|'')*)',(\d+),",
        re.S,
    )
    by_key: dict[tuple[int, str], deque[int]] = defaultdict(deque)
    for match in pattern.finditer(content):
        point_id = int(match.group(1))
        name = match.group(2).replace("''", "'")
        subject_id = int(match.group(3))
        by_key[(subject_id, name)].append(point_id)
    return by_key


def parse_page(page: dict, html: str, session: requests.Session, html_root: Path, asset_root: Path) -> tuple[KnowledgePage, list[str]]:
    soup = BeautifulSoup(html, "html.parser")
    content = soup.select_one("main .td-content") or soup.find("main") or soup.body
    if not content:
        raise RuntimeError(f"No content container found for {page['url']}")
    title_tag = content.find(["h1", "h2"]) or soup.find(["h1", "title"])
    title = title_tag.get_text(" ", strip=True) if title_tag else page["subject_name"]
    point_slug = safe_slug(urlparse(page["url"]).path.strip("/").replace("/", "-"))
    fragment_dir = html_root / page["slug"]
    asset_dir = asset_root / page["slug"] / point_slug
    html_ref = f"knowledge-html/csgraduates/{page['slug']}/{point_slug}.html"
    asset_public_prefix = f"knowledge-assets/csgraduates/{page['slug']}/{point_slug}"
    failures: list[str] = []
    content_html = inner_html(content)
    content_html = localize_html_assets(content_html, page["url"], session, asset_public_prefix, asset_dir, failures)
    summary = summary_of_html(content_html)
    fragment_dir.mkdir(parents=True, exist_ok=True)
    safe_write_text(fragment_dir / f"{point_slug}.html", content_html)
    level = max(1, urlparse(page["url"]).path.rstrip("/").count("/") - 1)
    return KnowledgePage(
        subject_id=page["subject_id"],
        subject_name=page["subject_name"],
        subject_slug=page["slug"],
        title=title,
        url=page["url"],
        source_path=f"knowledge-html-sources/csgraduates/{page['slug']}/{point_slug}.html",
        html_ref=html_ref,
        asset_dir=asset_public_prefix,
        summary=summary,
        html=content_html,
        level=level,
    ), failures


def build_sql(pages: list[KnowledgePage]) -> str:
    lines = [
        "-- Generated by crawler/generate_knowledge_html_sql.py",
        "-- Rich HTML-backed 408 knowledge point content. Existing knowledge_point IDs are preserved when matched.",
        "SET NAMES utf8mb4;",
        "START TRANSACTION;",
        "",
        "CREATE TABLE IF NOT EXISTS `knowledge_content` (",
        "  `id` INT NOT NULL AUTO_INCREMENT,",
        "  `knowledge_point_id` INT NOT NULL,",
        "  `html_ref` VARCHAR(500) NOT NULL,",
        "  `summary_text` TEXT NULL,",
        "  `source_url` VARCHAR(500) DEFAULT NULL,",
        "  `asset_dir` VARCHAR(500) DEFAULT NULL,",
        "  `metadata` LONGTEXT NULL COMMENT 'JSON',",
        "  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,",
        "  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,",
        "  PRIMARY KEY (`id`),",
        "  UNIQUE KEY `uk_knowledge_content_point` (`knowledge_point_id`),",
        "  KEY `idx_knowledge_content_source` (`source_url`)",
        ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='知识点富文本与本地资产引用';",
        "",
    ]

    for index, page in enumerate(pages, 1):
        kp_ref = str(page.existing_id) if page.existing_id else "@kp_id"
        metadata = {
            "sourceName": SOURCE_NAME,
            "subjectName": page.subject_name,
            "sourceUrl": page.url,
            "htmlRef": page.html_ref,
            "assetDir": page.asset_dir,
            "sourcePath": page.source_path,
            "html": True,
        }
        lines.append(f"-- {page.subject_name} / {page.title}")
        if page.existing_id:
            lines.append(f"SET @kp_id := {page.existing_id};")
        else:
            lines.append(
                "SET @kp_id := (SELECT id FROM knowledge_point "
                f"WHERE subject_id = {page.subject_id} AND name = {sql_string(page.title)} AND deleted = FALSE "
                "ORDER BY id LIMIT 1);"
            )
        lines.extend(
            [
                "UPDATE knowledge_point",
                f"SET description = {sql_string(page.summary)}, sort_order = COALESCE(sort_order, {index})",
                f"WHERE id = {kp_ref};",
                "INSERT INTO knowledge_content",
                "  (knowledge_point_id, html_ref, summary_text, source_url, asset_dir, metadata)",
                "VALUES",
                f"  ({kp_ref}, {sql_string(page.html_ref)}, {sql_string(page.summary)}, {sql_string(page.url)},",
                f"   {sql_string(page.asset_dir)}, {sql_string(json.dumps(metadata, ensure_ascii=False))})",
                "ON DUPLICATE KEY UPDATE",
                "  html_ref = VALUES(html_ref),",
                "  summary_text = VALUES(summary_text),",
                "  source_url = VALUES(source_url),",
                "  asset_dir = VALUES(asset_dir),",
                "  metadata = VALUES(metadata),",
                "  update_time = CURRENT_TIMESTAMP;",
                "",
            ]
        )
    lines.extend(["COMMIT;", ""])
    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(description="Generate HTML-backed CSGraduates 408 knowledge point SQL and assets.")
    parser.add_argument("--output", type=Path, default=Path("database/current/19_import_408_knowledge_html.sql"))
    parser.add_argument("--html-root", type=Path, default=Path("source/vue/xzs-student/public/knowledge-html/csgraduates"))
    parser.add_argument("--asset-root", type=Path, default=Path("source/vue/xzs-student/public/knowledge-assets/csgraduates"))
    parser.add_argument("--source-root", type=Path, default=Path("crawler/data/knowledge-html-sources/csgraduates"))
    parser.add_argument("--manifest", type=Path, default=Path("crawler/data/knowledge_html_manifest.json"))
    parser.add_argument("--current-sql", type=Path, default=Path("database/current/10_knowledge_points_data.sql"))
    parser.add_argument("--delay", type=float, default=0.15)
    parser.add_argument("--limit", type=int)
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    session = requests.Session()
    session.headers.update({"User-Agent": "Mozilla/5.0 master408 knowledge html crawler"})
    discovered = discover_urls(session)
    if args.limit:
        discovered = discovered[: args.limit]

    current_ids = parse_current_knowledge_points(args.current_sql)
    pages: list[KnowledgePage] = []
    manifest = {"source": SOURCE_NAME, "pages": []}
    subject_counts = defaultdict(int)
    failure_count = 0

    for index, page in enumerate(discovered, 1):
        print(f"[{index}/{len(discovered)}] {page['subject_name']} {page['url']}")
        html = fetch_text(session, page["url"])
        parsed, failures = parse_page(page, html, session, args.html_root, args.asset_root)
        ids = current_ids.get((parsed.subject_id, parsed.title))
        if ids:
            parsed.existing_id = ids.popleft()
        parsed.sort_order = index
        pages.append(parsed)
        subject_counts[parsed.subject_name] += 1
        failure_count += len(failures)
        source_dir = args.source_root / parsed.subject_slug
        source_dir.mkdir(parents=True, exist_ok=True)
        safe_write_text(source_dir / f"{safe_slug(urlparse(parsed.url).path.strip('/').replace('/', '-'))}.html", html)
        asset_count = len(list((args.asset_root / parsed.subject_slug).rglob("*"))) if (args.asset_root / parsed.subject_slug).exists() else 0
        html_count = len(list((args.html_root / parsed.subject_slug).glob("*.html"))) if (args.html_root / parsed.subject_slug).exists() else 0
        print(
            f"  title={parsed.title} kpId={parsed.existing_id or 'unmatched'} "
            f"html={html_count} assets={asset_count} failures={len(failures)}"
        )
        manifest["pages"].append(
            {
                "title": parsed.title,
                "subjectId": parsed.subject_id,
                "subjectName": parsed.subject_name,
                "knowledgePointId": parsed.existing_id,
                "sourceUrl": parsed.url,
                "htmlRef": parsed.html_ref,
                "assetDir": parsed.asset_dir,
                "failures": failures,
            }
        )
        time.sleep(args.delay)

    if any(subject_counts[spec["subject_name"]] == 0 for spec in SUBJECT_SPECS):
        raise RuntimeError(f"At least one 408 subject parsed zero pages: {dict(subject_counts)}")
    if failure_count:
        raise RuntimeError(f"Asset download failures: {failure_count}")
    if not pages:
        raise RuntimeError("Parsed zero knowledge pages")

    args.manifest.parent.mkdir(parents=True, exist_ok=True)
    safe_write_text(args.manifest, json.dumps(manifest, ensure_ascii=False, indent=2))
    args.output.parent.mkdir(parents=True, exist_ok=True)
    safe_write_text(args.output, build_sql(pages))

    print("Summary:")
    for name in [spec["subject_name"] for spec in SUBJECT_SPECS]:
        print(f"  {name}: {subject_counts[name]} pages")
    print(f"  total: {len(pages)} pages")
    print(f"  sql: {args.output}")
    print(f"  manifest: {args.manifest}")
    if args.dry_run:
        print("Dry-run completed. Files were generated for inspection; import SQL manually after review.")


if __name__ == "__main__":
    main()
