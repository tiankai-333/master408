"""
CSGraduates knowledge crawler and importer.

This script crawls the public 408 knowledge pages, saves a JSON snapshot, and
optionally imports the page hierarchy into knowledge_point plus the full page
content into t_ai_knowledge_base.
"""

import argparse
import hashlib
import json
import re
import time
from dataclasses import dataclass, asdict
from pathlib import Path
from typing import Dict, List, Optional
from urllib.parse import urljoin, urlparse

import pymysql
import requests
from bs4 import BeautifulSoup


BASE_URL = "https://www.csgraduates.com"
DATA_DIR = Path(__file__).parent / "data"
OUTPUT_FILE = DATA_DIR / "knowledge_pages.json"

SUBJECTS = [
    {"id": 1, "name": "数据结构", "domain": "data_structure", "path": "/data_structure/"},
    {"id": 2, "name": "计算机组成原理", "domain": "constitution_principle", "path": "/constitution_principle/"},
    {"id": 3, "name": "操作系统", "domain": "operating_system", "path": "/operating_system/"},
    {"id": 4, "name": "计算机网络", "domain": "computer_network", "path": "/computer_network/"},
]


@dataclass
class KnowledgePage:
    subject_id: int
    subject_name: str
    domain: str
    title: str
    url: str
    path: str
    parent_path: Optional[str]
    level: int
    sort_order: int
    content: str


class KnowledgeCrawler:
    def __init__(self, delay: float = 0.5, timeout: int = 12):
        self.delay = delay
        self.timeout = timeout
        self.session = requests.Session()
        self.session.headers.update({
            "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
                          "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120 Safari/537.36"
        })
        self.failures = []

    def fetch(self, url: str) -> str:
        last_error = None
        for _ in range(3):
            try:
                response = self.session.get(url, timeout=(6, self.timeout))
                response.raise_for_status()
                response.encoding = "utf-8"
                return response.text
            except requests.RequestException as exc:
                last_error = exc
                time.sleep(self.delay)
        raise RuntimeError(f"Failed to fetch {url}: {last_error}")

    def discover_subject_links(self, subject: Dict) -> List[Dict[str, str]]:
        root_url = urljoin(BASE_URL, subject["path"])
        soup = BeautifulSoup(self.fetch(root_url), "html.parser")
        seen = set()
        links = []

        for link in soup.find_all("a"):
            href = link.get("href") or ""
            full_url = urljoin(root_url, href)
            parsed = urlparse(full_url)
            path = parsed.path
            title = link.get_text(" ", strip=True)

            if parsed.netloc != "www.csgraduates.com":
                continue
            if not path.startswith(subject["path"]):
                continue
            if path in seen:
                continue
            if not title or title in {"章节视图", "Image"}:
                continue

            seen.add(path)
            links.append({"title": title, "url": full_url, "path": path})

        if subject["path"] not in seen:
            links.insert(0, {"title": subject["name"], "url": root_url, "path": subject["path"]})

        return links

    def parse_page(self, subject: Dict, link: Dict, parent_path: Optional[str], index: int) -> KnowledgePage:
        soup = BeautifulSoup(self.fetch(link["url"]), "html.parser")
        title_node = soup.find("h1")
        title = title_node.get_text(" ", strip=True) if title_node else link["title"]
        content_node = soup.find("main") or soup.find("article") or soup.body

        for tag in content_node.find_all(["script", "style", "nav", "aside"]):
            tag.decompose()

        content = content_node.get_text("\n", strip=True)
        content = self.clean_text(content)
        level = max(1, len([part for part in link["path"].strip("/").split("/") if part]))

        return KnowledgePage(
            subject_id=subject["id"],
            subject_name=subject["name"],
            domain=subject["domain"],
            title=title,
            url=link["url"],
            path=link["path"],
            parent_path=parent_path,
            level=level,
            sort_order=index,
            content=content,
        )

    def crawl(self) -> List[KnowledgePage]:
        pages = []

        for subject in SUBJECTS:
            links = self.discover_subject_links(subject)
            paths = [item["path"] for item in links]

            for index, link in enumerate(links, start=1):
                parent_path = self.find_parent_path(link["path"], paths)
                print(f"[{subject['name']}] {index:02d}/{len(links)} {link['path']}", flush=True)
                try:
                    pages.append(self.parse_page(subject, link, parent_path, index))
                except Exception as exc:
                    print(f"  SKIP {link['url']}: {exc}", flush=True)
                    self.failures.append({"url": link["url"], "error": str(exc)})
                time.sleep(self.delay)

        return pages

    @staticmethod
    def find_parent_path(path: str, all_paths: List[str]) -> Optional[str]:
        candidates = [candidate for candidate in all_paths if candidate != path and path.startswith(candidate)]
        if not candidates:
            return None
        return max(candidates, key=len)

    @staticmethod
    def clean_text(text: str) -> str:
        text = text.replace("\xa0", " ")
        text = re.sub(r"\n{3,}", "\n\n", text)
        text = re.sub(r"[ \t]{2,}", " ", text)
        noise = {
            "隐藏章节栏",
            "隐藏工具栏",
            "章节视图",
            "明亮模式",
            "夜间模式",
            "护眼模式",
        }
        lines = [line.strip() for line in text.splitlines()]
        lines = [line for line in lines if line and line not in noise]
        return "\n".join(lines)


class KnowledgeImporter:
    def __init__(self, host: str, port: int, user: str, password: str, database: str):
        self.conn = pymysql.connect(
            host=host,
            port=port,
            user=user,
            password=password,
            database=database,
            charset="utf8mb4",
            autocommit=False,
        )

    def close(self):
        self.conn.close()

    def clear_existing(self):
        with self.conn.cursor() as cursor:
            cursor.execute("DELETE FROM question_knowledge_point")
            cursor.execute("DELETE FROM knowledge_point")
            cursor.execute("DELETE FROM t_ai_knowledge_base WHERE source_type = 'csgraduates'")
        self.conn.commit()

    def import_pages(self, pages: List[KnowledgePage]):
        path_to_id: Dict[str, int] = {}
        kb_columns = self.table_columns("t_ai_knowledge_base")
        has_rag_columns = {"chunk_index", "content_hash"}.issubset(kb_columns)

        with self.conn.cursor() as cursor:
            for page in pages:
                parent_id = path_to_id.get(page.parent_path)
                description = page.content[:500] if page.content else page.title
                cursor.execute(
                    """
                    INSERT INTO knowledge_point
                      (name, subject_id, parent_id, description, level, sort_order, create_time, deleted)
                    VALUES (%s, %s, %s, %s, %s, %s, NOW(), b'0')
                    """,
                    (page.title, page.subject_id, parent_id, description, page.level, page.sort_order),
                )
                knowledge_id = cursor.lastrowid
                path_to_id[page.path] = knowledge_id

                if has_rag_columns:
                    cursor.execute(
                        """
                        INSERT INTO t_ai_knowledge_base
                          (category, domain, sub_domain, title, keywords, content, chunk_index,
                           content_hash, source_type, source_name, source_author, core_concepts,
                           application_scenarios, examples, enabled, priority, usage_count,
                           create_user, create_time, update_time, deleted)
                        VALUES
                          (%s, %s, %s, %s, %s, %s, 0,
                           %s, 'csgraduates', %s, %s, %s,
                           %s, %s, 1, %s, 0,
                           1, NOW(), NOW(), b'0')
                        """,
                        (
                            "408知识点",
                            page.domain,
                            page.subject_name,
                            page.title,
                            ",".join([page.subject_name, page.title]),
                            page.content,
                            hashlib.sha256((page.url + page.content).encode("utf-8")).hexdigest(),
                            page.url,
                            "计算机考研杂货铺",
                            page.title,
                            page.subject_name,
                            "",
                            max(1, 100 - page.level * 5),
                        ),
                    )
                else:
                    cursor.execute(
                        """
                        INSERT INTO t_ai_knowledge_base
                          (category, domain, sub_domain, title, keywords, content, source_type,
                           source_name, source_author, core_concepts, application_scenarios, examples,
                           enabled, priority, usage_count, create_user, create_time, update_time, deleted)
                        VALUES
                          (%s, %s, %s, %s, %s, %s, 'csgraduates',
                           %s, %s, %s, %s, %s,
                           1, %s, 0, 1, NOW(), NOW(), b'0')
                        """,
                        (
                            "408知识点",
                            page.domain,
                            page.subject_name,
                            page.title,
                            ",".join([page.subject_name, page.title]),
                            page.content,
                            page.url,
                            "计算机考研杂货铺",
                            page.title,
                            page.subject_name,
                            "",
                            max(1, 100 - page.level * 5),
                        ),
                    )

        self.conn.commit()

    def table_columns(self, table_name: str):
        with self.conn.cursor() as cursor:
            cursor.execute(
                """
                SELECT COLUMN_NAME
                FROM information_schema.COLUMNS
                WHERE TABLE_SCHEMA = DATABASE()
                  AND TABLE_NAME = %s
                """,
                (table_name,),
            )
            return {row[0] for row in cursor.fetchall()}


def save_pages(pages: List[KnowledgePage], output: Path):
    output.parent.mkdir(parents=True, exist_ok=True)
    with output.open("w", encoding="utf-8") as file:
        json.dump([asdict(page) for page in pages], file, ensure_ascii=False, indent=2)


def load_pages(path: Path) -> List[KnowledgePage]:
    with path.open("r", encoding="utf-8") as file:
        return [KnowledgePage(**item) for item in json.load(file)]


def main():
    parser = argparse.ArgumentParser(description="Crawl CSGraduates 408 knowledge pages.")
    parser.add_argument("--skip-crawl", action="store_true", help="Import the existing JSON snapshot instead of crawling.")
    parser.add_argument("--import-db", action="store_true", help="Import pages into local MySQL.")
    parser.add_argument("--clear-existing", action="store_true", help="Clear existing knowledge crawler rows before import.")
    parser.add_argument("--output", default=str(OUTPUT_FILE), help="JSON snapshot output path.")
    parser.add_argument("--delay", type=float, default=0.5)
    parser.add_argument("--timeout", type=int, default=12)
    parser.add_argument("--db-host", default="127.0.0.1")
    parser.add_argument("--db-port", type=int, default=3306)
    parser.add_argument("--db-user", default="root")
    parser.add_argument("--db-password", default="123456")
    parser.add_argument("--db-name", default="xzs")
    args = parser.parse_args()

    output = Path(args.output)
    if args.skip_crawl:
        pages = load_pages(output)
    else:
        pages = KnowledgeCrawler(delay=args.delay, timeout=args.timeout).crawl()
        save_pages(pages, output)

    print(f"Collected {len(pages)} knowledge pages.")

    if args.import_db:
        importer = KnowledgeImporter(args.db_host, args.db_port, args.db_user, args.db_password, args.db_name)
        try:
            if args.clear_existing:
                importer.clear_existing()
            importer.import_pages(pages)
        finally:
            importer.close()
        print("Imported knowledge pages into MySQL.")


if __name__ == "__main__":
    main()
