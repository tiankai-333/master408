import os
import sys
from pathlib import Path

# 添加当前目录到路径
current_dir = Path(__file__).parent
sys.path.insert(0, str(current_dir))

from ocr_processor import OCRProcessor
from question_parser import QuestionParser
from sql_generator import SQLGenerator

def main():
    print("=" * 60)
    print("2024年408真题 数据清洗工具")
    print("=" * 60)
    
    # 路径配置
    img_dir = r'c:/Dev/Workspaces/master408/docs/05-data-pipeline/2024_408/images'
    output_dir = r'c:/Dev/Workspaces/master408/docs/05-data-pipeline/question_data_cleaner'
    
    print("\n[步骤 1/4] OCR 识别页面内容...")
    processor = OCRProcessor(img_dir, output_dir)
    ocr_results = processor.process_all_pages()
    
    print("\n[步骤 2/4] 解析题目结构...")
    parser = QuestionParser(
        ocr_results_file=output_dir + '/ocr_results.json',
        output_dir=output_dir
    )
    questions = parser.parse_questions()
    parser.save_questions(questions)
    
    print("\n[步骤 3/4] 生成 SQL 导入脚本...")
    generator = SQLGenerator(
        parsed_questions_file=output_dir + '/parsed_questions.json',
        output_dir=output_dir
    )
    generator.generate_full_sql()
    
    print("\n" + "=" * 60)
    print("数据清洗完成！")
    print("=" * 60)
    print("\n生成的文件：")
    print(f"  1. ocr_results.json      - OCR识别结果")
    print(f"  2. parsed_questions.json - 解析后的题目数据")
    print(f"  3. insert_2024_questions.sql - SQL导入脚本")
    print("\n下一步：")
    print("  1. 编辑 parsed_questions.json，补充题目内容、答案和解析")
    print("  2. 运行 sql_generator.py 重新生成 SQL")
    print("  3. 执行 SQL 脚本导入数据库")
    print("=" * 60)

if __name__ == '__main__':
    main()
