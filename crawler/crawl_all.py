import requests
from bs4 import BeautifulSoup, Tag, NavigableString
import re
import json
import csv
import time
from pathlib import Path

BASE_URL = "https://www.csgraduates.com"
DATA_DIR = Path(__file__).parent / "data"
IMAGES_DIR = Path(__file__).parent / "images"
YEARS = list(range(2011, 2025))

SUBJECT_KEYWORDS = {
    "数据结构": "数据结构",
    "组成原理": "计算机组成原理",
    "计算机组成原理": "计算机组成原理",
    "操作系统": "操作系统",
    "计算机网络": "计算机网络",
}

session = requests.Session()
session.headers.update({
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
})


def fetch_page(url):
    for attempt in range(3):
        try:
            resp = session.get(url, timeout=30)
            resp.encoding = "utf-8"
            if resp.status_code == 200:
                return resp.text
        except Exception as e:
            print(f"  重试 {attempt + 1}: {e}")
            time.sleep(2)
    return None


def download_image(img_src, year, question_no):
    if not img_src:
        return None
    full_url = img_src if img_src.startswith("http") else BASE_URL + img_src
    try:
        resp = session.get(full_url, timeout=15)
        if resp.status_code == 200:
            ext = Path(img_src).suffix or ".png"
            filename = f"{year}_{question_no}{ext}"
            filepath = IMAGES_DIR / str(year) / filename
            filepath.parent.mkdir(parents=True, exist_ok=True)
            with open(filepath, "wb") as f:
                f.write(resp.content)
            return str(filepath.relative_to(Path(__file__).parent))
    except Exception:
        pass
    return None


def parse_answer_div(div_text, is_essay=False):
    """
    Parse the answer div that contains:
    [tag_label]A.xxxB.xxx...查看答案与解析收藏正确答案：Xanalysis
    OR for essays: [tag_label]查看答案与解析收藏 (no answer letter, analysis in following divs)

    Returns: (knowledge_tag, options_list, correct_answer, analysis_from_this_div)
    """
    text = div_text.strip()
    knowledge_tag = ""
    correct_answer = ""
    analysis = ""
    options = []

    # Step 1: Extract "正确答案：X"
    ans_match = re.search(r'正确答案[：:]\s*([A-D])', text)
    if ans_match:
        correct_answer = ans_match.group(1)
        before_answer = text[:ans_match.start()]
        analysis = text[ans_match.end():].strip()
    else:
        before_answer = text

    # Step 2: Clean markers from before_answer
    before_answer = re.sub(r'查看答案与解析收藏\s*', '', before_answer)
    before_answer = re.sub(r'查看答案与解析\s*', '', before_answer)
    before_answer = re.sub(r'收藏\s*', '', before_answer)
    before_answer = before_answer.strip()

    # Step 3: Extract knowledge tag (text before the first A. pattern)
    opt_start = re.search(r'[A-D][.、．:：]', before_answer)
    if opt_start:
        knowledge_tag = before_answer[:opt_start.start()].strip()
        options_text = before_answer[opt_start.start():]
    else:
        # No options found - entire before_answer is the tag
        knowledge_tag = before_answer
        options_text = ""

    # Step 4: Parse individual options
    if options_text:
        for m in re.finditer(r'([A-D])[.、．:：]\s*(.*?)(?=[A-D][.、．:：]|$)', options_text, re.DOTALL):
            prefix = m.group(1)
            content = m.group(2).strip()
            if content:
                options.append({"prefix": prefix, "content": content})

    # Step 5: Clean analysis - remove QuizDB script residue
    analysis = re.sub(r'class\s+QuizDB.*?}', '', analysis, flags=re.DOTALL)
    analysis = re.sub(r'if\s*\(\s*typeof\s+window\.quizDB.*?}\s*}\s*\)', '', analysis, flags=re.DOTALL)
    analysis = re.sub(r'window\.quizDB.*?}', '', analysis, flags=re.DOTALL)
    analysis = analysis.strip()

    return knowledge_tag, options, correct_answer, analysis


def parse_year_page(html, year):
    soup = BeautifulSoup(html, "lxml")
    current_subject = ""
    questions = []

    all_headers = list(soup.find_all(["h4", "h5"]))

    for elem in all_headers:
        if elem.name == "h4":
            text = elem.get_text(strip=True)
            for kw, subject in SUBJECT_KEYWORDS.items():
                if kw in text:
                    current_subject = subject
                    break
            continue

        if elem.name != "h5":
            continue

        h5_text = elem.get_text(strip=True)
        m = re.match(r'^(\d+)', h5_text)
        if not m:
            continue

        question_no = int(m.group(1))
        if question_no > 47:
            continue

        question_type = "choice" if question_no <= 40 else "essay"

        # Collect all elements until next h5/h4
        elements = []
        next_sib = elem.next_sibling
        while next_sib:
            if isinstance(next_sib, Tag):
                if next_sib.name in ("h5", "h4"):
                    break
                elements.append(next_sib)
            next_sib = next_sib.next_sibling

        # --- Phase 1: Categorize elements ---
        title_parts = []
        all_divs = []  # (is_code_like, text)
        images = []

        for el in elements:
            if isinstance(el, NavigableString):
                continue

            el_text = el.get_text(strip=True)
            if not el_text:
                continue

            if el.name == "script":
                continue  # always skip scripts

            # Collect images from this element
            for img in el.find_all("img"):
                src = img.get("src", "")
                if src:
                    local_path = download_image(src, year, question_no)
                    if local_path:
                        images.append(local_path)

            if el.name == "p":
                title_parts.append(el_text)
                continue

            if el.name == "div":
                all_divs.append(el_text)
                continue

        # --- Phase 2: Find the answer div ---
        answer_div_idx = None
        for i, d in enumerate(all_divs):
            if "正确答案" in d or "查看答案" in d:
                answer_div_idx = i
                break

        # --- Phase 3: Parse answer div ---
        tag = ""
        options = []
        correct_answer = ""
        analysis = ""

        if answer_div_idx is not None:
            answer_div_text = all_divs[answer_div_idx]
            tag, options, correct_answer, analysis_from_div = parse_answer_div(
                answer_div_text, is_essay=(question_type == "essay")
            )
            analysis = analysis_from_div

            # For essays: collect additional divs after the answer div as extended analysis
            if question_type == "essay":
                for d in all_divs[answer_div_idx + 1:]:
                    clean = re.sub(r'class\s+QuizDB.*$', '', d, flags=re.DOTALL)
                    clean = re.sub(r'if\s*\(\s*typeof\s+window\.quizDB.*$', '', clean, flags=re.DOTALL)
                    clean = clean.strip()
                    if clean:
                        if analysis:
                            analysis += "\n" + clean
                        else:
                            analysis = clean

        # --- Phase 4: Extract inline code blocks (divs before answer div) ---
        code_blocks = []
        if answer_div_idx is not None:
            for i in range(answer_div_idx):
                d = all_divs[i]
                # Check if this is actual code (starts with code-like patterns) vs data
                if re.match(r'^\s*[a-zA-Z_]\w*\s*=', d) or re.match(r'^\s*\d+\s*[∞\d\s]*$', d[:50]):
                    code_blocks.append(d)

        # --- Phase 5: Assemble title ---
        title = "\n".join(title_parts)

        # Append code blocks to title (they're part of the question description)
        if code_blocks:
            if title:
                title += "\n" + "\n".join(code_blocks)
            else:
                title = "\n".join(code_blocks)

        # Build options string for JSON compatibility
        options_str = ""
        if options:
            options_str = "".join(f"{o['prefix']}.{o['content']}" for o in options)

        questions.append({
            "year": year,
            "question_number": question_no,
            "subject": current_subject,
            "question_type": question_type,
            "question": title,
            "options": options_str,
            "answer": correct_answer,
            "analysis": analysis,
            "images": ",".join(images) if images else "",
            "knowledge_tag": tag,
        })

    return questions


def main():
    DATA_DIR.mkdir(parents=True, exist_ok=True)

    all_questions = []
    all_tags = []

    for year in YEARS:
        print(f"\n{'=' * 60}")
        print(f"爬取 {year} 年 408 真题...")
        url = f"{BASE_URL}/study_methods/408quiz/{year}/"
        html = fetch_page(url)
        if not html:
            print(f"  ❌ 获取页面失败")
            continue

        questions = parse_year_page(html, year)

        choice_count = sum(1 for q in questions if q["question_type"] == "choice")
        essay_count = sum(1 for q in questions if q["question_type"] == "essay")
        with_ans = sum(1 for q in questions if q["answer"])
        with_analysis = sum(1 for q in questions if q["analysis"])
        with_options = sum(1 for q in questions if q["options"])
        with_tag = sum(1 for q in questions if q["knowledge_tag"])

        print(f"  选择题: {choice_count}, 大题: {essay_count}")
        print(f"  有答案: {with_ans}, 有解析: {with_analysis}, 有选项: {with_options}, 有标签: {with_tag}")

        all_questions.extend(questions)

        source = f"{year}年408真题"
        for q in questions:
            all_tags.append({
                "source": source,
                "question_no": q["question_number"],
                "question_type": q["question_type"],
                "tags": q["knowledge_tag"],
            })

        time.sleep(1)

    # Split
    choices = [q for q in all_questions if q["question_type"] == "choice"]
    essays = [q for q in all_questions if q["question_type"] == "essay"]

    # Save choices JSON
    choice_output = []
    for q in choices:
        choice_output.append({
            "year": q["year"],
            "question_number": q["question_number"],
            "subject": q["subject"],
            "question": q["question"],
            "options": q["options"],
            "answer": q["answer"],
            "analysis": q["analysis"],
            "images": q["images"],
        })

    with open(DATA_DIR / "exam_questions.json", "w", encoding="utf-8") as f:
        json.dump(choice_output, f, ensure_ascii=False, indent=2)

    # Save essays CSV
    with open(DATA_DIR / "essay_questions.csv", "w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=[
            "year", "subject", "question_no", "title", "total_score",
            "answer", "analysis", "images"
        ])
        writer.writeheader()
        for e in essays:
            writer.writerow({
                "year": e["year"],
                "subject": e["subject"],
                "question_no": e["question_number"],
                "title": e["question"],
                "total_score": "10",
                "answer": e["answer"],
                "analysis": e["analysis"],
                "images": e["images"],
            })

    # Save knowledge tags
    with open(DATA_DIR / "knowledge_tags.json", "w", encoding="utf-8") as f:
        json.dump(all_tags, f, ensure_ascii=False, indent=2)

    print(f"\n{'=' * 60}")
    print(f"爬取完成！")
    print(f"  选择题: {len(choices)} 道 (期望 560)")
    print(f"  大题: {len(essays)} 道 (期望 98)")

    no_answer_choices = sum(1 for q in choices if not q["answer"])
    no_answer_essays = sum(1 for e in essays if not e["answer"])
    no_title_essays = sum(1 for e in essays if not e["question"])
    no_analysis_essays = sum(1 for e in essays if not e["analysis"])
    print(f"  选择题无答案: {no_answer_choices} 道")
    print(f"  大题无标题: {no_title_essays} 道")
    print(f"  大题无答案: {no_answer_essays} 道")
    print(f"  大题无解析: {no_analysis_essays} 道")
    print(f"  图片目录: {IMAGES_DIR}")

    # Show subjects summary
    from collections import Counter
    subj_counts = Counter(q["subject"] for q in choices)
    print(f"\n  选择题科目分布: {dict(subj_counts)}")


if __name__ == "__main__":
    main()
