import argparse
import hashlib
import json
import re
import time
from copy import copy
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Iterable
from urllib.parse import urljoin, urlparse

import requests
from bs4 import BeautifulSoup, Tag


BASE_URL = "https://www.csgraduates.com"
SOURCE_NAME = "csgraduates"
SOURCE_AUTHOR = "计算机考研杂货铺"

SUBJECTS = {
    1: "数据结构",
    2: "计算机组成原理",
    3: "操作系统",
    4: "计算机网络",
    5: "计算机408综合",
    6: "数学一",
    7: "数学二",
    8: "数学三",
    9: "英语一",
    10: "英语二",
    11: "思想政治理论",
}

CS_SUBJECT_IDS = {
    "数据结构": 1,
    "组成原理": 2,
    "计算机组成原理": 2,
    "操作系统": 3,
    "计算机网络": 4,
}


@dataclass(frozen=True)
class ExamSpec:
    exam_key: str
    url: str
    family: str
    paper_kind: str
    subject_id: int
    subject_name: str
    paper_name: str
    source_name: str
    source_year: int | None
    suggest_time: int


def safe_slug(value: str) -> str:
    value = re.sub(r"[^A-Za-z0-9_.-]+", "-", value.strip())
    return value.strip("-").lower()


def sql_string(value) -> str:
    if value is None:
        return "NULL"
    value = str(value)
    return "'" + value.replace("\\", "\\\\").replace("'", "''") + "'"


def bit(value: bool) -> str:
    return "b'1'" if value else "b'0'"


def fetch_text(session: requests.Session, url: str, timeout: int = 30) -> str:
    response = session.get(url, timeout=timeout)
    response.raise_for_status()
    response.encoding = "utf-8"
    return response.text


def discover_specs(session: requests.Session) -> list[ExamSpec]:
    sitemap = fetch_text(session, f"{BASE_URL}/sitemap.xml")
    urls = [u.replace("http://", "https://") for u in re.findall(r"<loc>(.*?)</loc>", sitemap)]
    specs: list[ExamSpec] = []

    def add(spec: ExamSpec):
        specs.append(spec)

    for url in urls:
        m = re.search(r"/study_methods/408quiz/(\d{4})/$", url)
        if m:
            year = int(m.group(1))
            add(
                ExamSpec(
                    exam_key=f"408-real-{year}",
                    url=url,
                    family="408",
                    paper_kind="real",
                    subject_id=5,
                    subject_name=SUBJECTS[5],
                    paper_name=f"{year}年全国硕士研究生招生考试计算机学科专业基础综合试题",
                    source_name=f"{year}年408真题",
                    source_year=year,
                    suggest_time=180,
                )
            )
            continue

        m = re.search(r"/study_methods/408simulate/(\d+)/$", url)
        if m:
            no = int(m.group(1))
            add(
                ExamSpec(
                    exam_key=f"408-mock-{no:02d}",
                    url=url,
                    family="408",
                    paper_kind="mock",
                    subject_id=5,
                    subject_name=SUBJECTS[5],
                    paper_name=f"408模拟卷{no}",
                    source_name=f"408模拟卷{no}",
                    source_year=None,
                    suggest_time=180,
                )
            )
            continue

        m = re.search(r"/study_methods/math/math([123])/(\d{4})/$", url)
        if m:
            math_no = int(m.group(1))
            year = int(m.group(2))
            subject_id = {1: 6, 2: 7, 3: 8}[math_no]
            add(
                ExamSpec(
                    exam_key=f"math{math_no}-real-{year}",
                    url=url,
                    family=f"math{math_no}",
                    paper_kind="real",
                    subject_id=subject_id,
                    subject_name=SUBJECTS[subject_id],
                    paper_name=f"{year}年考研{SUBJECTS[subject_id]}真题",
                    source_name=f"{year}年{SUBJECTS[subject_id]}真题",
                    source_year=year,
                    suggest_time=180,
                )
            )
            continue

        m = re.search(r"/study_methods/math_old/(\d{4})/(\d+)/$", url)
        if m:
            year = int(m.group(1))
            paper_no = int(m.group(2))
            subject_id = {1: 6, 2: 7, 3: 8}.get(paper_no, 6)
            add(
                ExamSpec(
                    exam_key=f"math-old-{year}-{paper_no:02d}",
                    url=url,
                    family="math_old",
                    paper_kind="real",
                    subject_id=subject_id,
                    subject_name=SUBJECTS[subject_id],
                    paper_name=f"{year}年考研数学早年真题卷{paper_no}",
                    source_name=f"{year}年考研数学早年真题卷{paper_no}",
                    source_year=year,
                    suggest_time=180,
                )
            )
            continue

        m = re.search(r"/study_methods/english/english([12])/(\d{4})/$", url)
        if m:
            english_no = int(m.group(1))
            year = int(m.group(2))
            subject_id = {1: 9, 2: 10}[english_no]
            add(
                ExamSpec(
                    exam_key=f"english{english_no}-real-{year}",
                    url=url,
                    family=f"english{english_no}",
                    paper_kind="real",
                    subject_id=subject_id,
                    subject_name=SUBJECTS[subject_id],
                    paper_name=f"{year}年考研{SUBJECTS[subject_id]}真题",
                    source_name=f"{year}年{SUBJECTS[subject_id]}真题",
                    source_year=year,
                    suggest_time=180,
                )
            )
            continue

        m = re.search(r"/study_methods/politics/(\d{4})/$", url)
        if m:
            year = int(m.group(1))
            add(
                ExamSpec(
                    exam_key=f"politics-real-{year}",
                    url=url,
                    family="politics",
                    paper_kind="real",
                    subject_id=11,
                    subject_name=SUBJECTS[11],
                    paper_name=f"{year}年考研思想政治理论真题",
                    source_name=f"{year}年思想政治理论真题",
                    source_year=year,
                    suggest_time=180,
                )
            )

    return sorted({s.exam_key: s for s in specs}.values(), key=lambda s: s.exam_key)


def clean_node(node: Tag) -> Tag:
    node = copy(node)
    for tag in node.find_all(["script", "style", "button"]):
        tag.decompose()
    for tag in node.select(".quiz-actions"):
        tag.decompose()
    for tag in node.find_all(True):
        for attr in list(tag.attrs):
            if attr.lower().startswith("on"):
                del tag.attrs[attr]
        if tag.name == "a" and tag.get("href", "").startswith("javascript:"):
            del tag.attrs["href"]
    return node


def inner_html(tag: Tag) -> str:
    cleaned = clean_node(tag)
    return "".join(str(child) for child in cleaned.contents).strip()


def outer_html(tag: Tag) -> str:
    return str(clean_node(tag)).strip()


def text_of_html(html: str) -> str:
    soup = BeautifulSoup(html, "html.parser")
    return re.sub(r"\s+", " ", soup.get_text(" ", strip=True)).strip()


def localize_html_assets(
    html: str,
    source_url: str,
    session: requests.Session,
    asset_public_prefix: str,
    asset_disk_dir: Path,
    failures: list[str],
    warnings: list[str],
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
        if suffix not in {".svg", ".png", ".jpg", ".jpeg", ".gif", ".webp"}:
            suffix = ".png"
        digest = hashlib.sha256(absolute.encode("utf-8")).hexdigest()[:16]
        stem = safe_slug(Path(parsed.path).stem) or "asset"
        filename = f"{stem}-{digest}{suffix}"
        target = asset_disk_dir / filename
        if not target.exists():
            try:
                response = session.get(absolute, timeout=30)
                response.raise_for_status()
                target.write_bytes(response.content)
            except Exception as exc:  # keep crawling but make validation fail later
                filename = f"missing-{digest}.svg"
                target = asset_disk_dir / filename
                placeholder = (
                    "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"900\" height=\"180\" "
                    "viewBox=\"0 0 900 180\">"
                    "<rect width=\"900\" height=\"180\" fill=\"#fff7ed\" stroke=\"#fdba74\"/>"
                    "<text x=\"24\" y=\"70\" font-family=\"Arial, sans-serif\" font-size=\"22\" fill=\"#9a3412\">"
                    "Missing upstream image</text>"
                    f"<text x=\"24\" y=\"112\" font-family=\"Arial, sans-serif\" font-size=\"14\" fill=\"#7c2d12\">{absolute}</text>"
                    "</svg>"
                )
                target.write_text(placeholder, encoding="utf-8")
                warnings.append(f"{absolute}: {exc}; wrote placeholder {filename}")
        img["src"] = f"{asset_public_prefix}/{filename}"
        for attr in ["data-src", "srcset", "data-srcset"]:
            if attr in img.attrs:
                del img.attrs[attr]
    return soup.div.decode_contents()


def parse_questions(spec: ExamSpec, html: str, session: requests.Session, html_root: Path, asset_root: Path):
    soup = BeautifulSoup(html, "html.parser")
    main = soup.find("main")
    if not main:
        raise RuntimeError(f"{spec.exam_key}: cannot find <main>")

    questions = []
    failures: list[str] = []
    warnings: list[str] = []
    current_subject_id = spec.subject_id
    current_subject_name = spec.subject_name
    context_nodes: list[Tag] = []

    for elem in main.find_all(["h4", "h5"], recursive=True):
        text = elem.get_text(" ", strip=True)
        if elem.name == "h4":
            matched_subject = next((name for name in CS_SUBJECT_IDS if name in text), None)
            if matched_subject:
                current_subject_id = CS_SUBJECT_IDS[matched_subject]
                current_subject_name = SUBJECTS[current_subject_id]
                context_nodes = []
            elif spec.family.startswith("english"):
                context_nodes = []
                for sib in elem.find_next_siblings():
                    if isinstance(sib, Tag) and sib.name in ["h4", "h5"]:
                        break
                    if isinstance(sib, Tag) and sib.name != "script":
                        context_nodes.append(sib)
            else:
                context_nodes = []
            continue

        if not text.isdigit():
            continue

        q_no = int(text)
        fragment_dir = html_root / spec.exam_key
        asset_dir = asset_root / spec.exam_key
        asset_public_prefix = f"question-assets/csgraduates/{spec.exam_key}"
        siblings: list[Tag] = []
        for sib in elem.find_next_siblings():
            if isinstance(sib, Tag) and sib.name in ["h4", "h5"]:
                break
            if isinstance(sib, Tag) and sib.name != "script":
                siblings.append(sib)

        choice = next(
            (
                sib
                for sib in siblings
                if sib.name == "div" and "choice-container" in (sib.get("class") or [])
            ),
            None,
        )
        answer_box = next(
            (
                sib
                for sib in siblings
                if sib.name == "div" and "answer-container" in (sib.get("class") or [])
            ),
            None,
        )
        solution = next(
            (
                sib
                for sib in siblings
                if sib.name == "div" and "solution-detail" in (sib.get("class") or [])
            ),
            None,
        )

        if choice:
            title_nodes = siblings[: siblings.index(choice)]
            if spec.family.startswith("english") and context_nodes:
                title_nodes = context_nodes + title_nodes
            title_html = "\n".join(outer_html(n) for n in title_nodes).strip()
            correct = (choice.get("data-answer") or "").strip()
            items = []
            for label in choice.select("label.choice-option"):
                prefix = label.select_one(".choice-label")
                content = label.select_one(".choice-text")
                prefix_text = prefix.get_text("", strip=True).replace(".", "") if prefix else ""
                item_content = inner_html(content) if content else ""
                item_content = localize_html_assets(
                    item_content, spec.url, session, asset_public_prefix, asset_dir, failures, warnings
                )
                items.append(
                    {
                        "prefix": prefix_text,
                        "content": item_content,
                        "itemUuid": hashlib.md5(f"{spec.exam_key}-{q_no}-{prefix_text}".encode()).hexdigest()[:8],
                    }
                )
            explanation = choice.find("div", class_="explanation")
            analysis_html = inner_html(explanation) if explanation else ""
            q_type = 1
            score = default_choice_score(spec, q_no)
        else:
            end_index = len(siblings)
            for marker in [answer_box, solution]:
                if marker in siblings:
                    end_index = min(end_index, siblings.index(marker))
            title_nodes = siblings[:end_index]
            if spec.family.startswith("english") and context_nodes:
                title_nodes = context_nodes + title_nodes
            title_html = "\n".join(outer_html(n) for n in title_nodes).strip()
            analysis_html = inner_html(solution) if solution else ""
            correct = ""
            items = []
            q_type = 5
            score_match = re.search(r"满分\s*(\d+)\s*分", text_of_html(title_html))
            score = int(score_match.group(1)) * 10 if score_match else default_subjective_score(spec, q_no)

        title_html = localize_html_assets(title_html, spec.url, session, asset_public_prefix, asset_dir, failures, warnings)
        analysis_html = localize_html_assets(analysis_html, spec.url, session, asset_public_prefix, asset_dir, failures, warnings)

        title_text = text_of_html(title_html)
        analysis_text = text_of_html(analysis_html)
        questions.append(
            {
                "examKey": spec.exam_key,
                "year": spec.source_year,
                "question_no": q_no,
                "subject": current_subject_name,
                "subject_id": current_subject_id,
                "question_type": q_type,
                "score": score,
                "correct": correct,
                "title_html": title_html,
                "analysis_html": analysis_html,
                "title_text": title_text,
                "analysis_text": analysis_text,
                "items": items,
                "tags": extract_tags(choice),
                "has_code": bool(re.search(r"<(pre|code)\b", title_html + analysis_html, re.I)),
                "has_image": bool(re.search(r"<img\b", title_html + analysis_html, re.I)),
            }
        )

    if not questions:
        raise RuntimeError(f"{spec.exam_key}: parsed zero questions from {spec.url}")

    fragment_dir = html_root / spec.exam_key
    fragment_dir.mkdir(parents=True, exist_ok=True)
    for q in questions:
        no = q["question_no"]
        (fragment_dir / f"q{no}-title.html").write_text(q["title_html"], encoding="utf-8")
        (fragment_dir / f"q{no}-analysis.html").write_text(q["analysis_html"], encoding="utf-8")
    return questions, failures, warnings


def extract_tags(choice: Tag | None) -> str:
    if not choice:
        return ""
    tag_box = choice.select_one(".quiz-tag-container")
    if not tag_box:
        return ""
    tags = [a.get_text(" ", strip=True) for a in tag_box.select("a")]
    if not tags:
        tags = [tag_box.get_text(" ", strip=True)]
    return ",".join(t for t in tags if t)


def default_choice_score(spec: ExamSpec, q_no: int) -> int:
    if spec.family == "408":
        return 20
    if spec.family.startswith("math"):
        return 50 if q_no <= 10 else 60
    if spec.family == "politics":
        return 10 if q_no <= 16 else 20
    if spec.family.startswith("english"):
        return 20
    return 20


def default_subjective_score(spec: ExamSpec, q_no: int) -> int:
    if spec.family == "408":
        return 100
    if spec.family.startswith("math"):
        return 100
    if spec.family.startswith("english"):
        return 100
    if spec.family == "politics":
        return 100
    return 100


def ref_markup(path: str, fallback: str) -> str:
    fallback = fallback.replace("&", "&amp;").replace('"', "&quot;").replace("<", "&lt;").replace(">", "&gt;")
    return f'<div class="question-html-ref" data-src="{path}" data-fallback="{fallback[:180]}"></div>'


def content_tags(q) -> str:
    tags = ["html", "external_html"]
    if q["has_image"]:
        tags.append("image")
    if q["has_code"]:
        tags.append("code")
    if re.search(r"<table\b", q["title_html"] + q["analysis_html"], re.I):
        tags.append("table")
    if "katex" in (q["title_html"] + q["analysis_html"]).lower():
        tags.append("katex")
    if q.get("tags"):
        tags.extend([t for t in q["tags"].split(",") if t])
    return ",".join(dict.fromkeys(tags))


def build_sql(specs: list[ExamSpec], exam_questions: dict[str, list[dict]]) -> str:
    lines = [
        "-- Generated by crawler/generate_html_exam_sql.py",
        "-- Rebuilds CSGraduates HTML-backed exam questions and local asset references.",
        "SET NAMES utf8mb4;",
        "START TRANSACTION;",
        "",
        "CREATE TEMPORARY TABLE tmp_csg_exam_targets (",
        "  exam_key VARCHAR(100) PRIMARY KEY,",
        "  paper_name VARCHAR(255),",
        "  source_name VARCHAR(255),",
        "  source_year INT NULL",
        ");",
    ]
    for spec in specs:
        lines.append(
            "INSERT INTO tmp_csg_exam_targets (exam_key, paper_name, source_name, source_year) VALUES "
            f"({sql_string(spec.exam_key)}, {sql_string(spec.paper_name)}, {sql_string(spec.source_name)}, "
            f"{spec.source_year if spec.source_year is not None else 'NULL'});"
        )
    lines.append(
        "INSERT INTO tmp_csg_exam_targets (exam_key, paper_name, source_name, source_year) VALUES "
        "('408-legacy-2026-mock', '2026年408计算机学科专业基础综合模拟试题', '2026年408模拟题', 2026);"
    )
    lines.extend(
        [
            "",
            "INSERT INTO t_subject (id, name, level, level_name, item_order, deleted) VALUES",
            ",\n".join(
                f"({sid}, {sql_string(name)}, 1, NULL, {sid}, b'0')" for sid, name in SUBJECTS.items()
            ),
            "ON DUPLICATE KEY UPDATE name=VALUES(name), level=VALUES(level), item_order=VALUES(item_order), deleted=b'0';",
            "",
            "CREATE TEMPORARY TABLE tmp_csg_question_ids (id INT PRIMARY KEY, info_text_content_id INT);",
            "INSERT IGNORE INTO tmp_csg_question_ids",
            "SELECT q.id, q.info_text_content_id",
            "FROM t_question q",
            "JOIN question_source qs ON qs.question_id = q.id",
            "JOIN tmp_csg_exam_targets t ON JSON_UNQUOTE(JSON_EXTRACT(qs.metadata, '$.examKey')) = t.exam_key;",
            "INSERT IGNORE INTO tmp_csg_question_ids",
            "SELECT q.id, q.info_text_content_id",
            "FROM t_question q",
            "JOIN tmp_csg_exam_targets t ON q.source = t.source_name AND (q.source_year <=> t.source_year);",
            "INSERT IGNORE INTO tmp_csg_question_ids",
            "SELECT q.id, q.info_text_content_id",
            "FROM t_question q",
            "JOIN question_source qs ON qs.question_id = q.id",
            "JOIN tmp_csg_exam_targets t ON qs.paper_name = t.paper_name;",
            "",
            "CREATE TEMPORARY TABLE tmp_csg_frame_ids (id INT PRIMARY KEY);",
            "INSERT IGNORE INTO tmp_csg_frame_ids",
            "SELECT ep.frame_text_content_id",
            "FROM t_exam_paper ep",
            "JOIN tmp_csg_exam_targets t ON ep.name = t.paper_name AND (ep.source_year <=> t.source_year OR t.source_year IS NULL)",
            "WHERE ep.frame_text_content_id IS NOT NULL;",
            "",
            "DELETE qa FROM question_asset qa JOIN tmp_csg_question_ids t ON qa.question_id = t.id;",
            "DELETE qs FROM question_source qs JOIN tmp_csg_question_ids t ON qs.question_id = t.id;",
            "DELETE qc FROM question_content qc JOIN tmp_csg_question_ids t ON qc.question_id = t.id;",
            "DELETE ep FROM t_exam_paper ep JOIN tmp_csg_exam_targets t ON ep.name = t.paper_name AND (ep.source_year <=> t.source_year OR t.source_year IS NULL);",
            "DELETE q FROM t_question q JOIN tmp_csg_question_ids t ON q.id = t.id;",
            "DELETE tc FROM t_text_content tc JOIN tmp_csg_question_ids t ON tc.id = t.info_text_content_id;",
            "DELETE tc FROM t_text_content tc JOIN tmp_csg_frame_ids t ON tc.id = t.id;",
            "",
        ]
    )

    for spec in specs:
        questions = exam_questions[spec.exam_key]
        q_vars = []
        for q in questions:
            no = q["question_no"]
            q_var = f"@q_{safe_slug(spec.exam_key).replace('-', '_')}_{no}"
            tc_var = f"@tc_{safe_slug(spec.exam_key).replace('-', '_')}_{no}"
            q_vars.append((q, q_var))
            title_ref = ref_markup(
                f"question-html/csgraduates/{spec.exam_key}/q{no}-title.html",
                q["title_text"],
            )
            analysis_ref = ref_markup(
                f"question-html/csgraduates/{spec.exam_key}/q{no}-analysis.html",
                q["analysis_text"],
            )
            info = {"titleContent": title_ref, "analyze": analysis_ref, "questionItemObjects": q["items"]}
            options_json = json.dumps(q["items"], ensure_ascii=False)
            source_hash = hashlib.sha256(
                (q["title_html"] + q["analysis_html"] + options_json).encode("utf-8")
            ).hexdigest()
            metadata = {
                "examKey": spec.exam_key,
                "sourceUrl": spec.url,
                "assetDir": f"question-assets/csgraduates/{spec.exam_key}",
                "htmlDir": f"question-html/csgraduates/{spec.exam_key}",
                "subjectName": q["subject"],
                "paperKind": spec.paper_kind,
                "family": spec.family,
                "html": True,
            }
            lines.extend(
                [
                    f"-- {spec.exam_key} Q{no}",
                    "INSERT INTO t_text_content (content, create_time)",
                    f"VALUES ({sql_string(json.dumps(info, ensure_ascii=False))}, NOW());",
                    f"SET {tc_var} = LAST_INSERT_ID();",
                    "INSERT INTO t_question",
                    "  (question_type, subject_id, score, grade_level, difficult, correct, info_text_content_id, create_user, status, deleted,",
                    "   title, options, correct_answer, analysis, difficulty, knowledge_point, source, source_year, source_question_no, tags, images,",
                    "   title_text, analysis_text, content_format, has_image, has_code)",
                    "VALUES",
                    f"  ({q['question_type']}, {q['subject_id']}, {q['score']}, NULL, 2, {sql_string(q['correct'])}, {tc_var}, 1, 1, b'0',",
                    f"   {sql_string(title_ref)}, {sql_string(options_json)}, {sql_string(q['correct'])}, {sql_string(analysis_ref)},",
                    f"   2, NULL, {sql_string(spec.source_name)}, {spec.source_year if spec.source_year is not None else 'NULL'}, {no}, {sql_string(content_tags(q))}, '',",
                    f"   {sql_string(q['title_text'])}, {sql_string(q['analysis_text'])}, 'html', {bit(q['has_image'])}, {bit(q['has_code'])});",
                    f"SET {q_var} = LAST_INSERT_ID();",
                    "INSERT INTO question_content",
                    "  (question_id, version, title, options, correct_answer, analysis, title_text, analysis_text, content_format, has_image, has_code, legacy_text_content_id, source_hash, is_current)",
                    "VALUES",
                    f"  ({q_var}, 1, {sql_string(title_ref)}, {sql_string(options_json)}, {sql_string(q['correct'])}, {sql_string(analysis_ref)},",
                    f"   {sql_string(q['title_text'])}, {sql_string(q['analysis_text'])}, 'html', {bit(q['has_image'])}, {bit(q['has_code'])}, {tc_var}, {sql_string(source_hash)}, b'1');",
                    "INSERT INTO question_source",
                    "  (question_id, source_type, source_name, source_year, source_question_no, paper_name, raw_ref, metadata)",
                    "VALUES",
                    f"  ({q_var}, 'crawler_html', {sql_string(SOURCE_NAME)}, {spec.source_year if spec.source_year is not None else 'NULL'}, {sql_string(str(no))}, {sql_string(spec.paper_name)},",
                    f"   {sql_string(spec.url)}, {sql_string(json.dumps(metadata, ensure_ascii=False))});",
                    "",
                ]
            )

        total_score = sum(q["score"] for q in questions)
        frame_items = ", ".join(
            f"JSON_OBJECT('id', {q_var}, 'itemOrder', {q['question_no']})" for q, q_var in q_vars
        )
        frame_expr = f"JSON_ARRAY(JSON_OBJECT('name', '一、试题', 'questionItems', JSON_ARRAY({frame_items})))"
        description = f"从 CSGraduates HTML 导入，examKey={spec.exam_key}，题干和解析保留 HTML/图片/公式结构。"
        lines.extend(
            [
                f"-- Paper {spec.exam_key}",
                "INSERT INTO t_text_content (content, create_time)",
                f"VALUES (CAST({frame_expr} AS CHAR), NOW());",
                f"SET @frame_{safe_slug(spec.exam_key).replace('-', '_')} = LAST_INSERT_ID();",
                "INSERT INTO t_exam_paper",
                "  (name, subject_id, paper_type, grade_level, score, question_count, suggest_time, limit_start_time, limit_end_time, frame_text_content_id, create_user, deleted, task_exam_id, source_year, description)",
                "VALUES",
                f"  ({sql_string(spec.paper_name)}, {spec.subject_id}, 1, NULL, {total_score}, {len(questions)}, {spec.suggest_time}, NULL, NULL, @frame_{safe_slug(spec.exam_key).replace('-', '_')}, 1, b'0', NULL, {spec.source_year if spec.source_year is not None else 'NULL'}, {sql_string(description)});",
                "",
            ]
        )

    lines.extend(["COMMIT;", ""])
    return "\n".join(lines)


def selected_specs(specs: list[ExamSpec], args) -> list[ExamSpec]:
    result = specs
    if args.exam_key:
        keys = set(args.exam_key)
        result = [s for s in result if s.exam_key in keys]
    if args.family:
        families = set(args.family)
        result = [s for s in result if s.family in families]
    if args.limit:
        result = result[: args.limit]
    return result


def main():
    parser = argparse.ArgumentParser(description="Generate HTML-backed CSGraduates exam SQL and local assets.")
    parser.add_argument("--output", type=Path, default=Path("database/current/17_import_csgraduates_html_exams.sql"))
    parser.add_argument("--html-root", type=Path, default=Path("source/vue/xzs-student/public/question-html/csgraduates"))
    parser.add_argument("--asset-root", type=Path, default=Path("source/vue/xzs-student/public/question-assets/csgraduates"))
    parser.add_argument("--source-root", type=Path, default=Path("crawler/data/html-sources/csgraduates"))
    parser.add_argument("--manifest", type=Path, default=Path("crawler/data/csgraduates_html_manifest.json"))
    parser.add_argument("--delay", type=float, default=0.15)
    parser.add_argument("--limit", type=int)
    parser.add_argument("--exam-key", action="append")
    parser.add_argument("--family", action="append")
    parser.add_argument("--allow-resource-failures", action="store_true")
    parser.add_argument("--discover-only", action="store_true")
    args = parser.parse_args()

    session = requests.Session()
    session.headers.update({"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"})
    specs = selected_specs(discover_specs(session), args)
    if args.discover_only:
        print(json.dumps([asdict(s) for s in specs], ensure_ascii=False, indent=2))
        return

    args.source_root.mkdir(parents=True, exist_ok=True)
    exam_questions: dict[str, list[dict]] = {}
    manifest = {"source": SOURCE_NAME, "exams": [], "failures": [], "warnings": []}

    for index, spec in enumerate(specs, 1):
        print(f"[{index}/{len(specs)}] {spec.exam_key} {spec.url}")
        html = fetch_text(session, spec.url)
        snapshot = args.source_root / f"{spec.exam_key}.html"
        snapshot.write_text(html, encoding="utf-8")
        questions, failures, warnings = parse_questions(spec, html, session, args.html_root, args.asset_root)
        exam_questions[spec.exam_key] = questions
        html_count = len(list((args.html_root / spec.exam_key).glob("*.html")))
        asset_count = len(list((args.asset_root / spec.exam_key).glob("*"))) if (args.asset_root / spec.exam_key).exists() else 0
        choice_count = sum(1 for q in questions if q["question_type"] == 1)
        subjective_count = sum(1 for q in questions if q["question_type"] != 1)
        print(
            f"  questions={len(questions)} choice={choice_count} subjective={subjective_count} "
            f"assets={asset_count} html={html_count} failures={len(failures)} warnings={len(warnings)}"
        )
        manifest["exams"].append(
            {
                **asdict(spec),
                "questionCount": len(questions),
                "choiceCount": choice_count,
                "subjectiveCount": subjective_count,
                "assetCount": asset_count,
                "htmlFragmentCount": html_count,
                "failures": failures,
                "warnings": warnings,
            }
        )
        manifest["failures"].extend({"examKey": spec.exam_key, "failure": f} for f in failures)
        manifest["warnings"].extend({"examKey": spec.exam_key, "warning": w} for w in warnings)
        if failures and not args.allow_resource_failures:
            raise RuntimeError(f"{spec.exam_key}: {len(failures)} resource failures")
        time.sleep(args.delay)

    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(build_sql(specs, exam_questions), encoding="utf-8")
    args.manifest.parent.mkdir(parents=True, exist_ok=True)
    args.manifest.write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"Generated {args.output}")
    print(f"Generated {args.manifest}")


if __name__ == "__main__":
    main()
