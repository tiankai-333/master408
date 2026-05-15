import json
import csv
import re
import uuid
from pathlib import Path

BASE = Path(__file__).parent / "data"

SUBJECT_MAP = {
    "数据结构": 1,
    "计算机组成原理": 2,
    "操作系统": 3,
    "计算机网络": 4,
}

with open(BASE / "exam_questions.json", "r", encoding="utf-8") as f:
    questions = json.load(f)

with open(BASE / "knowledge_tags.json", "r", encoding="utf-8") as f:
    tags_list = json.load(f)

tags_map = {}
for t in tags_list:
    key = (t["source"], t["question_no"])
    tags_map[key] = t["tags"]

essays = []
with open(BASE / "essay_questions.csv", "r", encoding="utf-8") as f:
    reader = csv.DictReader(f)
    for row in reader:
        essays.append(row)


def esc(s):
    if not s:
        return ""
    return str(s).replace("\\", "\\\\").replace("'", "''").replace("\n", "\\n").replace("\r", "")


def parse_options_from_analysis(analysis_text):
    if not analysis_text:
        return [], analysis_text
    pattern = r'([A-D])[.、．:：]\s*'
    matches = list(re.finditer(pattern, analysis_text))
    if len(matches) < 2:
        return [], analysis_text

    options = []
    for i, m in enumerate(matches):
        prefix = m.group(1)
        start = m.end()
        end = matches[i + 1].start() if i + 1 < len(matches) else len(analysis_text)
        content = analysis_text[start:end].strip()
        stop_words = ['查看答案', '正确答案', '参考答案', '答案解析', '解析']
        for sw in stop_words:
            idx = content.find(sw)
            if idx > 0:
                content = content[:idx].strip()
                break
        if content:
            options.append({
                "prefix": prefix,
                "content": content,
                "itemUuid": str(uuid.uuid4())[:8]
            })

    if len(options) >= 2:
        clean_analysis = analysis_text
        for opt in reversed(options):
            full_match = opt['prefix'] + re.escape(opt['content'][:20])
            clean_analysis = re.sub(re.escape(opt['prefix']) + r'[.、．:：]\s*' + re.escape(opt['content']), '', clean_analysis, count=1)
        return options, clean_analysis.strip()
    return [], analysis_text


def parse_options(options_text):
    if not options_text:
        return []
    items = []
    for m in re.finditer(r'([A-D])[.、．:：]\s*(.*?)(?=[A-D][.、．:：]|查看答案|正确答案|$)', options_text, re.DOTALL):
        prefix = m.group(1)
        content = m.group(2).strip()
        if content:
            items.append({
                "prefix": prefix,
                "content": content,
                "itemUuid": str(uuid.uuid4())[:8]
            })
    return items


def extract_title_and_options(question_text):
    title = question_text
    options = []
    m = re.search(r'^(.*?[）)。)])(.*)', question_text, re.DOTALL)
    if m:
        title = m.group(1).strip()
        rest = m.group(2).strip()
        if rest:
            options = parse_options(rest)
    return title, options


def process_image_tags(text):
    if not text:
        return text
    text = re.sub(r'\[图片[：:]\s*([^\]]+)\]', r'<img src="\1" style="max-width:600px"/>', text)
    text = re.sub(r'!\[([^\]]*)\]\(([^)]+)\)', r'<img src="\2" alt="\1" style="max-width:600px"/>', text)
    return text


text_content_values = []
question_values = []
tc_id = 1

for q in questions:
    q["_db_id"] = tc_id
    year = int(q["year"])
    qno = int(q["question_number"])
    subject_id = SUBJECT_MAP.get(q["subject"], 1)
    source = f"{year}年408真题"
    tags = tags_map.get((source, qno), "")

    raw_title = q.get("question", "")
    raw_options = q.get("options", "")
    answer = q.get("answer", "")
    analysis = q.get("analysis", "")
    images = q.get("images", "")

    option_items = []
    if raw_options and raw_options.strip():
        option_items = parse_options(raw_options)

    if not option_items:
        option_items, analysis = parse_options_from_analysis(analysis)

    if not option_items:
        title, option_items = extract_title_and_options(raw_title)

    title = process_image_tags(raw_title)
    analysis = process_image_tags(analysis)

    content_obj = {
        "titleContent": title,
        "analyze": analysis,
        "questionItemObjects": option_items
    }

    content_json = json.dumps(content_obj, ensure_ascii=False)
    content_json_esc = esc(content_json)
    text_content_values.append(f"({tc_id}, '{content_json_esc}', NOW())")

    has_image = "b'1'" if images or "<img" in title or "<img" in analysis else "b'0'"
    has_code = "b'1'" if "```" in analysis else "b'0'"

    question_values.append(
        f"(1, {subject_id}, 20, NULL, NULL, '{esc(answer)}', {tc_id}, 1, 1, b'0', "
        f"'{esc(title)}', NULL, '{esc(answer)}', '{esc(analysis)}', 2, '{esc(q['subject'])}', "
        f"'{source}', {year}, {qno}, '{esc(tags)}', '{esc(images)}', "
        f"NULL, NULL, 'html', {has_image}, {has_code})"
    )
    tc_id += 1

for e in essays:
    e["_db_id"] = tc_id
    year = int(e["year"])
    qno = int(e["question_no"])
    subject_id = SUBJECT_MAP.get(e["subject"], 1)
    source = f"{year}年408真题"
    tags = tags_map.get((source, qno), "")

    title = e.get("title", "") or ""
    answer = e.get("answer", "") or ""
    analysis = e.get("analysis", "") or ""
    images = e.get("images", "") or ""

    title = process_image_tags(title)
    analysis = process_image_tags(analysis)

    content_obj = {
        "titleContent": title,
        "analyze": analysis,
        "questionItemObjects": [],
        "correct": answer
    }

    content_json = json.dumps(content_obj, ensure_ascii=False)
    content_json_esc = esc(content_json)
    text_content_values.append(f"({tc_id}, '{content_json_esc}', NOW())")

    has_image = "b'1'" if images or "<img" in title else "b'0'"
    has_code = "b'1'" if "```" in analysis else "b'0'"

    question_values.append(
        f"(5, {subject_id}, 100, NULL, NULL, NULL, {tc_id}, 1, 1, b'0', "
        f"'{esc(title)}', NULL, '{esc(answer)}', '{esc(analysis)}', 2, '{esc(e['subject'])}', "
        f"'{source}', {year}, {qno}, '{esc(tags)}', '{esc(images)}', "
        f"NULL, NULL, 'html', {has_image}, {has_code})"
    )
    tc_id += 1

paper_values = []

for year in range(2011, 2025):
    year_questions = [q for q in questions if int(q["year"]) == year]
    year_essays = [e for e in essays if int(e["year"]) == year]

    ds_choices = [q for q in year_questions if q["subject"] == "数据结构"]
    co_choices = [q for q in year_questions if q["subject"] == "计算机组成原理"]
    os_choices = [q for q in year_questions if q["subject"] == "操作系统"]
    cn_choices = [q for q in year_questions if q["subject"] == "计算机网络"]
    ds_essays = [e for e in year_essays if e["subject"] == "数据结构"]
    co_essays = [e for e in year_essays if e["subject"] == "计算机组成原理"]
    os_essays = [e for e in year_essays if e["subject"] == "操作系统"]
    cn_essays = [e for e in year_essays if e["subject"] == "计算机网络"]

    sections = []
    sections.append({
        "name": f"一、单项选择题（数据结构，1-{len(ds_choices)}题，每题2分）",
        "questionItems": [{"id": q["_db_id"], "itemOrder": i+1} for i, q in enumerate(ds_choices)]
    })
    off = len(ds_choices)
    sections.append({
        "name": f"二、单项选择题（计算机组成原理，{off+1}-{off+len(co_choices)}题，每题2分）",
        "questionItems": [{"id": q["_db_id"], "itemOrder": off+i+1} for i, q in enumerate(co_choices)]
    })
    off += len(co_choices)
    sections.append({
        "name": f"三、单项选择题（操作系统，{off+1}-{off+len(os_choices)}题，每题2分）",
        "questionItems": [{"id": q["_db_id"], "itemOrder": off+i+1} for i, q in enumerate(os_choices)]
    })
    off += len(os_choices)
    sections.append({
        "name": f"四、单项选择题（计算机网络，{off+1}-{off+len(cn_choices)}题，每题2分）",
        "questionItems": [{"id": q["_db_id"], "itemOrder": off+i+1} for i, q in enumerate(cn_choices)]
    })
    off += len(cn_choices)
    if ds_essays:
        sections.append({
            "name": f"五、综合应用题（数据结构，{off+1}-{off+len(ds_essays)}题，每题10分）",
            "questionItems": [{"id": e["_db_id"], "itemOrder": off+i+1} for i, e in enumerate(ds_essays)]
        })
        off += len(ds_essays)
    if co_essays:
        sections.append({
            "name": f"六、综合应用题（计算机组成原理，{off+1}-{off+len(co_essays)}题，每题10分）",
            "questionItems": [{"id": e["_db_id"], "itemOrder": off+i+1} for i, e in enumerate(co_essays)]
        })
        off += len(co_essays)
    if os_essays:
        sections.append({
            "name": f"七、综合应用题（操作系统，{off+1}-{off+len(os_essays)}题，每题10分）",
            "questionItems": [{"id": e["_db_id"], "itemOrder": off+i+1} for i, e in enumerate(os_essays)]
        })
        off += len(os_essays)
    if cn_essays:
        sections.append({
            "name": f"八、综合应用题（计算机网络，{off+1}题，10分）",
            "questionItems": [{"id": e["_db_id"], "itemOrder": off+1} for e in cn_essays]
        })

    frame_json = json.dumps(sections, ensure_ascii=False)
    frame_json_esc = esc(frame_json)
    text_content_values.append(f"({tc_id}, '{frame_json_esc}', NOW())")

    total_q = len(year_questions) + len(year_essays)

    paper_values.append(
        f"('{year}年全国硕士研究生招生考试计算机学科专业基础综合试题', "
        f"NULL, 1, NULL, 1500, {total_q}, 180, NULL, NULL, {tc_id}, 1, b'0', NULL, {year}, "
        f"'{year}年408计算机学科专业基础综合考试真题')"
    )
    tc_id += 1

essay_values = []
for e in essays:
    year = int(e["year"])
    qno = int(e["question_no"])
    subject_id = SUBJECT_MAP.get(e["subject"], 1)
    title = e.get("title", "") or ""
    answer = e.get("answer", "") or ""
    analysis = e.get("analysis", "") or ""
    images = e.get("images", "") or ""
    essay_values.append(
        f"({subject_id}, {year}, {qno}, '{esc(title)}', 10, '{esc(answer)}', '{esc(analysis)}', '{esc(images)}')"
    )

sql_lines = []
sql_lines.append("-- ============================================")
sql_lines.append("-- 04_exam_data.sql")
sql_lines.append("-- 从爬虫数据生成，匹配 01_init_structure.sql + 02_extend_fields.sql")
sql_lines.append("-- ============================================")
sql_lines.append("")
sql_lines.append("SET NAMES utf8mb4;")
sql_lines.append("")

sql_lines.append("-- ============================================")
sql_lines.append("-- 科目数据")
sql_lines.append("-- ============================================")
sql_lines.append("INSERT INTO `t_subject` (`id`, `name`, `level`, `level_name`, `item_order`, `deleted`) VALUES")
sql_lines.append("(1, '数据结构', 1, '408统考', 1, b'0'),")
sql_lines.append("(2, '计算机组成原理', 1, '408统考', 2, b'0'),")
sql_lines.append("(3, '操作系统', 1, '408统考', 3, b'0'),")
sql_lines.append("(4, '计算机网络', 1, '408统考', 4, b'0');")
sql_lines.append("")

sql_lines.append("-- ============================================")
sql_lines.append("-- 用户数据（密码: 123456, BCrypt加密）")
sql_lines.append("-- ============================================")
sql_lines.append("INSERT INTO `t_user` (`id`, `user_uuid`, `user_name`, `password`, `real_name`, `age`, `sex`, `user_level`, `role`, `status`, `deleted`) VALUES")
sql_lines.append("(1, UUID(), 'admin', '$2a$10$BOJWNJAQUNeSL8GI2uD8Fu3iqDit8HDO3ct1Ig5i/Actg0mqwTHQq', '管理员', NULL, NULL, 1, 3, 1, b'0'),")
sql_lines.append("(2, UUID(), 'student', '$2a$10$a0UdBI6U5KbJJFWwEN6jXe4eZTaWZfwYAdu1QK9Pbdv6bAvv3GWFi', '学生用户', NULL, NULL, 1, 1, 1, b'0'),")
sql_lines.append("(3, UUID(), 'teacher', '$2a$10$BOJWNJAQUNeSL8GI2uD8Fu3iqDit8HDO3ct1Ig5i/Actg0mqwTHQq', '教师', NULL, NULL, 1, 2, 1, b'0'),")
sql_lines.append("(4, UUID(), '231310423', '$2a$10$a0UdBI6U5KbJJFWwEN6jXe4eZTaWZfwYAdu1QK9Pbdv6bAvv3GWFi', '学生用户', NULL, NULL, 1, 1, 1, b'0');")
sql_lines.append("")

sql_lines.append("-- ============================================")
sql_lines.append("-- 文本内容（题目内容 + 试卷框架）")
sql_lines.append("-- ============================================")
sql_lines.append("INSERT INTO `t_text_content` (`id`, `content`, `create_time`) VALUES")
sql_lines.append(",\n".join(text_content_values) + ";")
sql_lines.append("")

sql_lines.append("-- ============================================")
sql_lines.append("-- 题目数据（选择题 + 综合应用题）")
sql_lines.append("-- ============================================")
sql_lines.append("INSERT INTO `t_question` (`question_type`, `subject_id`, `score`, `grade_level`, `difficult`, `correct`, `info_text_content_id`, `create_user`, `status`, `deleted`, `title`, `options`, `correct_answer`, `analysis`, `difficulty`, `knowledge_point`, `source`, `source_year`, `source_question_no`, `tags`, `images`, `title_text`, `analysis_text`, `content_format`, `has_image`, `has_code`) VALUES")
sql_lines.append(",\n".join(question_values) + ";")
sql_lines.append("")

sql_lines.append("-- ============================================")
sql_lines.append("-- 试卷数据（2011-2024年408真题）")
sql_lines.append("-- ============================================")
sql_lines.append("INSERT INTO `t_exam_paper` (`name`, `subject_id`, `paper_type`, `grade_level`, `score`, `question_count`, `suggest_time`, `limit_start_time`, `limit_end_time`, `frame_text_content_id`, `create_user`, `deleted`, `task_exam_id`, `source_year`, `description`) VALUES")
sql_lines.append(",\n".join(paper_values) + ";")
sql_lines.append("")

sql_lines.append("-- ============================================")
sql_lines.append("-- 综合应用题原始数据（爬虫备份）")
sql_lines.append("-- ============================================")
sql_lines.append("INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `total_score`, `answer`, `analysis`, `images`) VALUES")
sql_lines.append(",\n".join(essay_values) + ";")

output = Path(__file__).parent.parent / "database" / "04_exam_data.sql"
with open(output, "w", encoding="utf-8") as f:
    f.write("\n".join(sql_lines))

with_options = sum(1 for q in questions if q.get("options") and q["options"].strip())
from_analysis = sum(1 for q in questions if not (q.get("options") and q["options"].strip()) and len(parse_options_from_analysis(q.get("analysis", ""))[0]) >= 2)
from_title = sum(1 for q in questions if not (q.get("options") and q["options"].strip()) and len(parse_options_from_analysis(q.get("analysis", ""))[0]) < 2 and re.search(r'[A-D][.、．:：]', q.get("question", "")))
no_options = len(questions) - with_options - from_analysis - from_title

print(f"生成完成: {output}")
print(f"文本内容: {len(text_content_values)} 条")
print(f"选择题: {len(questions)} 道")
print(f"  - 有独立options字段: {with_options}")
print(f"  - 从analysis解析出选项: {from_analysis}")
print(f"  - 从题目文本解析出选项: {from_title}")
print(f"  - 无选项: {no_options}")
print(f"应用题: {len(essays)} 道")
print(f"试卷: 14 份（总分固定150分）")
