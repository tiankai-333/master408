#!/usr/bin/env python3
"""
CSGraduates爬虫工具 - 快速启动脚本
用于快速爬取计算机考研真题和知识点
"""

import sys
import os

# 确保 crawler 模块可以导入
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from crawler import CSGraduatesCrawler


def main():
    """主函数 - 演示基本用法"""
    print("=" * 60)
    print("CSGraduates考研真题和知识点爬虫")
    print("=" * 60)
    print()
    
    # 初始化爬虫
    crawler = CSGraduatesCrawler()
    
    # 示例1: 列出所有可爬取的内容
    print("1. 列出所有可爬取的内容...")
    print("   运行: python main.py --list-chapters")
    print()
    
    # 示例2: 只爬取知识点
    print("2. 只爬取知识点...")
    print("   运行: python main.py --knowledge-only")
    print()
    
    # 示例3: 只爬取真题
    print("3. 只爬取历年真题...")
    print("   运行: python main.py --exam-only")
    print()
    
    # 示例4: 爬取特定年份的真题
    print("4. 爬取2020-2024年的真题...")
    print("   运行: python main.py --exam-only --start-year 2020 --end-year 2024")
    print()
    
    # 示例5: 爬取特定科目
    print("5. 只爬取数据结构知识点...")
    print("   运行: python main.py --knowledge-only --subject data_structure")
    print()
    
    # 示例6: 爬取所有内容并指定输出文件
    print("6. 爬取所有内容并保存到自定义文件...")
    print("   运行: python main.py --output my_data.json")
    print()
    
    # 示例7: 自定义请求延迟
    print("7. 设置请求延迟为2秒...")
    print("   运行: python main.py --delay 2")
    print()
    
    print("=" * 60)
    print("直接开始爬取? (y/n): ", end="")
    
    choice = input().strip().lower()
    if choice == 'y':
        print("\n开始爬取所有内容...\n")
        all_data = {
            "crawl_time": crawler.session.headers.get("Date", ""),
            "knowledge": crawler.crawl_all(),
            "exam_papers": crawler.crawl_exam_papers()
        }
        crawler.save_results(all_data)
        print("\n爬取完成!")
    else:
        print("\n取消爬取。请使用上述命令进行操作。")


if __name__ == "__main__":
    main()
