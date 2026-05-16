"""
Audit and optionally sync crawled 408 image paths into MySQL.

Default mode is read-only. Add --apply to update t_question/t_essay_question
from crawler/data/images and crawler/data/essay_images.
"""

import argparse
import re
from pathlib import Path

import pymysql


SUBJECT_BY_CODE = {
    "DS": 1,
    "CO": 2,
    "OS": 3,
    "CN": 4,
}

SUBJECT_BY_NAME = {
    "数据结构": 1,
    "计算机组成原理": 2,
    "操作系统": 3,
    "计算机网络": 4,
}


def normalize_question_image(path: Path) -> str:
    match = re.match(r"(?P<year>\d{4})_[A-Z]{2}_(?P<qno>\d{2})_\d+\.(svg|jpg|jpeg|png)$", path.name)
    if not match:
        return str(path).replace("\\", "/")
    year = match.group("year")
    qno = str(int(match.group("qno")))
    ext = path.suffix.lower()
    return f"images/{year}/{year}_{qno}{ext}"


def parse_choice_image(path: Path):
    match = re.match(r"(?P<year>\d{4})_(?P<code>[A-Z]{2})_(?P<qno>\d{2})_\d+\.(svg|jpg|jpeg|png)$", path.name)
    if not match:
        return None
    return {
        "year": int(match.group("year")),
        "subject_id": SUBJECT_BY_CODE.get(match.group("code")),
        "question_no": int(match.group("qno")),
        "db_path": normalize_question_image(path),
        "file": str(path),
    }


def parse_essay_image(path: Path):
    match = re.match(r"(?P<year>\d{4})_(?P<subject>.+)_(?P<qno>\d+)_\d+\.(svg|jpg|jpeg|png)$", path.name)
    if not match:
        return None
    subject_id = SUBJECT_BY_NAME.get(match.group("subject"))
    year = int(match.group("year"))
    qno = int(match.group("qno"))
    return {
        "year": year,
        "subject_id": subject_id,
        "question_no": qno,
        "db_path": f"images/{year}/{year}_{qno}{path.suffix.lower()}",
        "file": str(path),
    }


def connect(args):
    return pymysql.connect(
        host=args.db_host,
        port=args.db_port,
        user=args.db_user,
        password=args.db_password,
        database=args.db_name,
        charset="utf8mb4",
        autocommit=False,
    )


def sync_choice(conn, item, apply):
    with conn.cursor() as cursor:
        cursor.execute(
            """
            SELECT id, images
            FROM t_question
            WHERE source_year = %s
              AND source_question_no = %s
              AND subject_id = %s
              AND deleted = b'0'
            """,
            (item["year"], item["question_no"], item["subject_id"]),
        )
        row = cursor.fetchone()
        if not row:
            return "missing-question"
        qid, images = row
        if images and item["db_path"] in images.replace("\\", "/"):
            return "ok"
        if apply:
            cursor.execute(
                "UPDATE t_question SET images = %s, has_image = b'1' WHERE id = %s",
                (item["db_path"], qid),
            )
        return "would-update" if not apply else "updated"


def sync_essay(conn, item, apply):
    with conn.cursor() as cursor:
        cursor.execute(
            """
            SELECT id, images
            FROM t_essay_question
            WHERE year = %s
              AND question_no = %s
              AND subject_id = %s
            """,
            (item["year"], item["question_no"], item["subject_id"]),
        )
        row = cursor.fetchone()
        if not row:
            return "missing-essay"
        eid, images = row
        if images and item["db_path"] in images.replace("\\", "/"):
            return "ok"
        if apply:
            cursor.execute(
                "UPDATE t_essay_question SET images = %s WHERE id = %s",
                (item["db_path"], eid),
            )
        return "would-update" if not apply else "updated"


def main():
    parser = argparse.ArgumentParser(description="Audit or sync 408 image paths.")
    parser.add_argument("--apply", action="store_true", help="Apply database updates.")
    parser.add_argument("--db-host", default="127.0.0.1")
    parser.add_argument("--db-port", type=int, default=3306)
    parser.add_argument("--db-user", default="root")
    parser.add_argument("--db-password", default="123456")
    parser.add_argument("--db-name", default="xzs")
    args = parser.parse_args()

    choice_items = []
    for path in sorted(Path("crawler/data/images").glob("*")):
        item = parse_choice_image(path)
        if item and item["subject_id"]:
            choice_items.append(item)

    essay_items = []
    for path in sorted(Path("crawler/data/essay_images").glob("*")):
        item = parse_essay_image(path)
        if item and item["subject_id"]:
            essay_items.append(item)

    conn = connect(args)
    stats = {}
    try:
        for item in choice_items:
            status = sync_choice(conn, item, args.apply)
            stats[status] = stats.get(status, 0) + 1
            print(f"choice {status}: {item['year']} #{item['question_no']} {item['db_path']}")
        for item in essay_items:
            status = sync_essay(conn, item, args.apply)
            stats[status] = stats.get(status, 0) + 1
            print(f"essay {status}: {item['year']} #{item['question_no']} {item['db_path']}")
        if args.apply:
            conn.commit()
        else:
            conn.rollback()
    finally:
        conn.close()

    print("summary:", stats)
    print("mode:", "applied" if args.apply else "dry-run")


if __name__ == "__main__":
    main()
