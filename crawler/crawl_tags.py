"""
408真题知识标签爬虫
从 csgraduates.com 获取每道题的知识标签，并更新数据库
"""

import requests
from bs4 import BeautifulSoup
import re
import time
import json
import pymysql
from pathlib import Path

BASE_URL = "https://www.csgraduates.com"
YEARS = list(range(2011, 2025))

SUBJECT_MAP = {
    "数据结构": 1,
    "组成原理": 2,
    "计算机组成原理": 2,
    "操作系统": 3,
    "计算机网络": 4,
}

session = requests.Session()
session.headers.update({
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
})


def get_db():
    return pymysql.connect(
        host="localhost", user="root", password="123456",
        database="xzs", charset="utf8mb4", cursorclass=pymysql.cursors.DictCursor
    )


def fetch_page(url):
    for attempt in range(3):
        try:
            resp = session.get(url, timeout=30)
            resp.encoding = "utf-8"
            if resp.status_code == 200:
                return resp.text
        except Exception as e:
            print(f"  重试 {attempt+1}: {e}")
            time.sleep(2)
    return None


def extract_tags_from_html(html_content):
    """从HTML中提取知识标签链接"""
    soup = BeautifulSoup(html_content, "html.parser")
    tags = []
    for a in soup.find_all("a", href=True):
        href = a["href"]
        if "/study_methods/tags/408quiz/" in href:
            tag_text = a.get_text(strip=True)
            if tag_text and tag_text not in tags:
                tags.append(tag_text)
    return tags


def crawl_year_tags(year):
    """爬取某一年所有题目的知识标签"""
    url = f"{BASE_URL}/study_methods/408quiz/{year}/"
    print(f"爬取 {year} 年: {url}")

    html = fetch_page(url)
    if not html:
        print(f"  获取页面失败")
        return []

    soup = BeautifulSoup(html, "html.parser")
    results = []

    current_subject = None
    current_subject_id = None

    for h4 in soup.find_all("h4"):
        text = h4.get_text(strip=True)
        for key, sid in SUBJECT_MAP.items():
            if key in text:
                current_subject = key
                current_subject_id = sid
                break

    if current_subject_id is None:
        current_subject_id = 1

    h5_elements = soup.find_all("h5")
    for h5 in h5_elements:
        num_match = re.match(r'^(\d+)$', h5.get_text(strip=True))
        if not num_match:
            continue

        question_no = int(num_match.group(1))
        if question_no > 47:
            continue

        question_type = "choice" if question_no <= 40 else "essay"

        sibling = h5.next_sibling
        tags = []
        depth = 0
        while sibling and depth < 15:
            if sibling.name == "h5":
                break
            if hasattr(sibling, "find_all"):
                for a in sibling.find_all("a", href=True):
                    href = a["href"]
                    if "/study_methods/tags/408quiz/" in href:
                        tag_text = a.get_text(strip=True)
                        if tag_text and tag_text not in tags:
                            tags.append(tag_text)
            sibling = sibling.next_sibling
            depth += 1

        if not tags:
            parent = h5.parent
            if parent:
                for a in parent.find_all("a", href=True):
                    href = a["href"]
                    if "/study_methods/tags/408quiz/" in href:
                        tag_text = a.get_text(strip=True)
                        if tag_text and tag_text not in tags:
                            tags.append(tag_text)

        results.append({
            "year": year,
            "question_no": question_no,
            "question_type": question_type,
            "tags": ",".join(tags) if tags else "",
        })

    print(f"  获取 {len(results)} 道题的标签")
    return results


def update_database(results):
    """更新数据库中的知识标签"""
    db = get_db()
    updated = 0
    not_found = 0

    try:
        with db.cursor() as cur:
            for item in results:
                cur.execute(
                    """UPDATE t_question 
                       SET tags = %s 
                       WHERE source_year = %s AND source_question_no = %s""",
                    (item["tags"], item["year"], item["question_no"])
                )
                if cur.rowcount > 0:
                    updated += 1
                else:
                    not_found += 1

        db.commit()
    finally:
        db.close()

    print(f"  更新 {updated} 条，未匹配 {not_found} 条")
    return updated, not_found


def main():
    all_results = []
    total_updated = 0
    total_not_found = 0

    for year in YEARS:
        results = crawl_year_tags(year)
        all_results.extend(results)
        updated, not_found = update_database(results)
        total_updated += updated
        total_not_found += not_found
        time.sleep(1.5)

    output_path = Path("data/knowledge_tags.json")
    output_path.parent.mkdir(parents=True, exist_ok=True)
    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(all_results, f, ensure_ascii=False, indent=2)

    print(f"\n=== 完成 ===")
    print(f"总计: {len(all_results)} 道题")
    print(f"更新: {total_updated} 条")
    print(f"未匹配: {total_not_found} 条")
    print(f"标签数据已保存到: {output_path}")

    tagged = sum(1 for r in all_results if r["tags"])
    print(f"有标签的题目: {tagged}/{len(all_results)}")


if __name__ == "__main__":
    main()
