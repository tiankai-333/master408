import json
import re
from copy import copy
from pathlib import Path

from bs4 import BeautifulSoup, Tag


ROOT = Path(__file__).resolve().parents[1]
SOURCE_DIR = ROOT / "crawler" / "data" / "html-sources" / "csgraduates"
HTML_DIR = ROOT / "source" / "vue" / "xzs-student" / "public" / "question-html" / "csgraduates"
SQL_PATH = ROOT / "database" / "current" / "21_fix_english_cloze_options.sql"


def sql_string(value) -> str:
    if value is None:
        return "NULL"
    return "'" + str(value).replace("\\", "\\\\").replace("'", "''") + "'"


def clean_node(node: Tag) -> Tag:
    node = copy(node)
    for tag in node.find_all(["script", "style", "button"]):
        tag.decompose()
    for tag in node.select(".quiz-actions, .feedback-area"):
        tag.decompose()
    for tag in node.find_all(True):
        for attr in list(tag.attrs):
            if attr.lower().startswith("on"):
                del tag.attrs[attr]
    return node


def outer_html(tag: Tag) -> str:
    return str(clean_node(tag)).strip()


def inner_html(tag: Tag) -> str:
    cleaned = clean_node(tag)
    return "".join(str(child) for child in cleaned.contents).strip()


def text_of_html(html: str) -> str:
    soup = BeautifulSoup(html, "html.parser")
    return re.sub(r"\s+", " ", soup.get_text(" ", strip=True)).strip()


def ref_markup(path: str, fallback: str) -> str:
    fallback = (
        fallback.replace("&", "&amp;")
        .replace('"', "&quot;")
        .replace("<", "&lt;")
        .replace(">", "&gt;")
    )
    return f'<div class="question-html-ref" data-src="{path}" data-fallback="{fallback[:180]}"></div>'


def collect_cloze_passage(main: Tag) -> str:
    text_heading = main.find("h4", id="text")
    if not text_heading:
        text_heading = next((h for h in main.find_all("h4") if h.get_text(" ", strip=True).lower() == "text"), None)
    if not text_heading:
        return ""

    nodes = []
    for sib in text_heading.find_next_siblings():
        if isinstance(sib, Tag) and sib.name == "h5" and sib.get_text(" ", strip=True) == "1":
            break
        if isinstance(sib, Tag) and sib.name != "script":
            nodes.append(sib)
    return "\n".join(outer_html(node) for node in nodes).strip()


def find_question_choice(main: Tag, q_no: int) -> Tag | None:
    h5 = main.find("h5", id=str(q_no))
    if not h5:
        h5 = next((h for h in main.find_all("h5") if h.get_text(" ", strip=True) == str(q_no)), None)
    if not h5:
        return None
    for sib in h5.find_next_siblings():
        if isinstance(sib, Tag) and sib.name in {"h4", "h5"}:
            return None
        if isinstance(sib, Tag) and "choice-container" in (sib.get("class") or []):
            return sib
    return None


def extract_items(choice: Tag, exam_key: str, q_no: int) -> list[dict]:
    items = []
    for label in choice.select("label.choice-option, label.choice-option-inline"):
        prefix = label.select_one(".choice-label")
        content = label.select_one(".choice-text")
        prefix_text = prefix.get_text("", strip=True).replace(".", "") if prefix else ""
        item_content = inner_html(content) if content else ""
        if not prefix_text:
            continue
        items.append(
            {
                "prefix": prefix_text,
                "content": item_content,
                "itemUuid": f"cloze-{exam_key}-{q_no}-{prefix_text}",
            }
        )
    return items


def update_exam(source_file: Path) -> list[str]:
    m = re.match(r"english([12])-real-(\d{4})\.html$", source_file.name)
    if not m:
        return []

    english_no = int(m.group(1))
    year = int(m.group(2))
    subject_id = 9 if english_no == 1 else 10
    exam_key = f"english{english_no}-real-{year}"

    soup = BeautifulSoup(source_file.read_text(encoding="utf-8"), "html.parser")
    main = soup.find("main")
    if not main:
        raise RuntimeError(f"{source_file}: cannot find main")

    passage_html = collect_cloze_passage(main)
    if not passage_html:
        return []

    fragment_dir = HTML_DIR / exam_key
    fragment_dir.mkdir(parents=True, exist_ok=True)

    lines = []
    for q_no in range(1, 21):
        choice = find_question_choice(main, q_no)
        if not choice:
            continue
        items = extract_items(choice, exam_key, q_no)
        if not items:
            raise RuntimeError(f"{exam_key} q{q_no}: no cloze options parsed")

        title_html = passage_html if q_no == 1 else f'<p class="cloze-question-prompt">完型填空 第 {q_no} 空</p>'
        title_text = text_of_html(title_html)
        title_ref = ref_markup(f"question-html/csgraduates/{exam_key}/q{q_no}-title.html", title_text)
        options_text = "\n".join(f"{item['prefix']}. {text_of_html(item['content'])}" for item in items)
        items_json = json.dumps(items, ensure_ascii=False)

        (fragment_dir / f"q{q_no}-title.html").write_text(title_html, encoding="utf-8")

        where = f"q.subject_id = {subject_id} AND q.source_year = {year} AND q.source_question_no = {q_no} AND q.deleted = b'0'"
        lines.append(f"-- {exam_key} q{q_no}")
        lines.append(
            "UPDATE t_text_content tc "
            "JOIN t_question q ON q.info_text_content_id = tc.id "
            "SET tc.content = JSON_SET("
            "tc.content, "
            "'$.titleContent', CAST(JSON_QUOTE(" + sql_string(title_ref) + ") AS JSON), "
            "'$.questionItemObjects', CAST(" + sql_string(items_json) + " AS JSON)"
            f") WHERE {where};"
        )
        lines.append(
            "UPDATE t_question q SET "
            f"q.title = {sql_string(title_ref)}, "
            f"q.title_text = {sql_string(title_text)}, "
            f"q.options = {sql_string(items_json)} "
            f"WHERE {where};"
        )
    return lines


def main():
    all_lines = [
        "-- Generated by crawler/fix_english_cloze_import.py",
        "-- Restores cloze option text and prevents repeating the full cloze passage for blanks 2-20.",
        "SET NAMES utf8mb4;",
        "START TRANSACTION;",
        "",
    ]
    changed = 0
    for source_file in sorted(SOURCE_DIR.glob("english*-real-*.html")):
        lines = update_exam(source_file)
        if lines:
            changed += len([line for line in lines if line.startswith("-- english")])
            all_lines.extend(lines)
            all_lines.append("")

    all_lines.extend(["COMMIT;", ""])
    SQL_PATH.write_text("\n".join(all_lines), encoding="utf-8")
    print(f"wrote {SQL_PATH}")
    print(f"updated cloze questions: {changed}")


if __name__ == "__main__":
    main()
