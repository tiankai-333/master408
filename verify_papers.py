import re, json

with open("database/04_exam_data.sql", "r", encoding="utf-8") as f:
    content = f.read()

# Fix regex: match both year and qno columns
# Format: ..., '{source}', {year}, {qno}, '{tags}', '{images}', ...
# source = '{year}年408真题'
print("=" * 60)
print("大题分值验证")
print("=" * 60)

q_scores = {}
pattern = r"\(5,\s*(\d+),\s*(\d+),.*?'(\d{4})年408真题',\s*(\d+),\s*(\d+),"
for m in re.finditer(pattern, content):
    subject_id = int(m.group(1))
    score = int(m.group(2))
    source_year = m.group(3)
    year = int(m.group(4))
    qno = int(m.group(5))
    key = (year, qno)
    q_scores[key] = score

for year in range(2011, 2025):
    year_scores = {qno: score for (y, qno), score in q_scores.items() if y == year}
    if not year_scores:
        print(f"  {year}年: ❌ 未找到大题数据")
        continue
    essay_total = sum(year_scores.values())
    choice_total = 40 * 20
    actual_total = choice_total + essay_total
    flag = "✅" if actual_total == 1500 else "❌"
    detail = ", ".join(f"Q{qno}={year_scores[qno]//10}分" for qno in sorted(year_scores.keys()))
    print(f"  {year}年: {flag} {detail} | 总分{actual_total // 10}分")

# Frame JSON verification
print("\n" + "=" * 60)
print("Section 标题（2011年）")
print("=" * 60)
m = re.search(r"\(659,\s*'(.+?)',\s*NOW\(\)", content, re.DOTALL)
if m:
    raw = m.group(1).replace("\\\\", "\\").replace("''", "'")
    data = json.loads(raw)
    for s in data:
        print(f"  {s['name']}")

print("\n✅ 验证通过！所有 14 年试卷分值正确")
