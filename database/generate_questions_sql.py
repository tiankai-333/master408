"""
生成题目SQL文件
从CSV文件读取题目数据，生成INSERT SQL语句
"""

import csv
import json
import re
from pathlib import Path


def clean_text(text):
    """清理文本，转义特殊字符"""
    if not text:
        return ""
    # 移除多余的空白字符
    text = re.sub(r'\s+', ' ', text)
    # 转义单引号
    text = text.replace("'", "''")
    # 转义反斜杠
    text = text.replace("\\", "\\\\")
    return text.strip()


def parse_options(options_text):
    """解析选项文本为JSON格式"""
    if not options_text or options_text.strip() == '':
        return "[]"
    
    options = []
    # 匹配 A. B. C. D. 格式
    pattern = r'([A-D])[.、\s]+(.*?)(?=[A-D][.、\s]|$)'
    matches = re.findall(pattern, options_text, re.DOTALL)
    
    for key, value in matches:
        if value.strip():
            options.append({
                "key": key,
                "value": clean_text(value.strip())
            })
    
    if not options:
        return "[]"
    
    return json.dumps(options, ensure_ascii=False)


def clean_analysis(analysis_text):
    """清理解析文本"""
    if not analysis_text:
        return ""
    # 移除"查看答案与解析收藏"等干扰文字
    text = re.sub(r'查看答案与解析\s*收藏?\s*', '', analysis_text)
    text = re.sub(r'正确答案[：:]\s*[A-D]\s*', '', text)
    return clean_text(text)


def clean_question(question_text):
    """清理题目文本"""
    if not question_text:
        return ""
    # 移除题目来源标记等
    text = re.sub(r'\s*[A-D][.、\s]+', '\n', question_text)
    return clean_text(text)


def get_subject_id(subject_name):
    """获取学科ID"""
    mapping = {
        '数据结构': 1,
        '计算机组成原理': 2,
        '组成原理': 2,
        '操作系统': 3,
        '计算机网络': 4
    }
    return mapping.get(subject_name, 1)


def generate_sql():
    """生成SQL文件"""
    input_file = Path("crawler/data/exam_questions.csv")
    output_file = Path("database/02_exam_questions.sql")
    
    # 读取CSV
    questions = []
    with open(input_file, 'r', encoding='utf-8-sig') as f:  # 使用utf-8-sig自动处理BOM
        reader = csv.DictReader(f)
        for row in reader:
            # 清理列名中的BOM
            cleaned_row = {k.strip('\ufeff').strip(): v for k, v in row.items()}
            questions.append(cleaned_row)
    
    print(f"读取到 {len(questions)} 道题目")
    
    # 生成SQL
    sql_lines = [
        "-- ============================================",
        "-- 真题题目导入SQL (2) - 2011-2024年408真题",
        f"-- 共{len(questions)}道选择题",
        "-- ============================================",
        "",
        "USE xzs;",
        "",
        "-- 开始插入题目",
        "START TRANSACTION;",
        ""
    ]
    
    success_count = 0
    error_count = 0
    
    for i, q in enumerate(questions, 1):
        try:
            # 安全获取字段
            year = q.get('year', q.get('年份', '2011'))
            subject = q.get('subject', q.get('科目', '数据结构'))
            question_num = q.get('question_number', q.get('题号', str(i)))
            
            subject_id = get_subject_id(subject)
            question_type = 'choice'
            title = clean_question(q.get('question', q.get('题目', '')))
            options = parse_options(q.get('options', q.get('选项', '')))
            correct_answer = q.get('answer', q.get('答案', '')).strip()
            analysis = clean_analysis(q.get('analysis', q.get('解析', '')))
            knowledge_point = clean_text(subject)
            source = f"{year}年{subject}真题"
            
            try:
                source_year = int(year) if year else 2011
            except:
                source_year = 2011
                
            try:
                source_question_no = int(question_num) if question_num else i
            except:
                source_question_no = i
                
            images = clean_text(q.get('images', ''))
            
            # 生成INSERT语句
            sql = f"""INSERT INTO `t_question` (`subject_id`, `question_type`, `title`, `options`, `correct_answer`, `analysis`, `difficulty`, `score`, `knowledge_point`, `source`, `source_year`, `source_question_no`, `tags`, `images`) VALUES
({subject_id}, 'choice', '{title}', '{options}', '{correct_answer}', '{analysis}', 2, 2, '{knowledge_point}', '{source}', {source_year}, {source_question_no}, '', '{images}');"""
            
            sql_lines.append(sql)
            success_count += 1
            
            # 每100条输出进度
            if i % 100 == 0:
                print(f"已处理 {i}/{len(questions)} 道题目...")
                
        except Exception as e:
            error_count += 1
            if error_count <= 5:  # 只显示前5个错误
                print(f"处理第{i}题时出错: {e}")
            continue
    
    sql_lines.extend([
        "",
        "COMMIT;",
        "",
        f"-- 共插入 {success_count} 道题目",
        f"-- 失败 {error_count} 道",
        "-- 题目导入完成"
    ])
    
    # 写入文件
    output_file.parent.mkdir(exist_ok=True)
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write('\n'.join(sql_lines))
    
    print(f"\n✓ SQL文件已生成: {output_file}")
    print(f"  成功 {success_count} 道题目")
    print(f"  失败 {error_count} 道题目")


if __name__ == "__main__":
    generate_sql()
