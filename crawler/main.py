"""
CSGraduates网站爬虫 - 主程序
支持命令行参数控制爬取行为
"""

import argparse
import sys
import time
from pathlib import Path
from crawler import CSGraduatesCrawler


def main():
    """主函数"""
    parser = argparse.ArgumentParser(
        description="CSGraduates考研真题和知识点爬虫",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
示例:
  python main.py                          # 爬取所有内容
  python main.py --subject data_structure # 只爬取数据结构
  python main.py --list-chapters          # 列出所有章节
  python main.py --output custom.json      # 指定输出文件
  python main.py --exam-only              # 只爬取真题
  python main.py --start-year 2020 --end-year 2024  # 指定年份范围爬取真题
        """
    )
    
    parser.add_argument(
        "--subject",
        type=str,
        help="指定要爬取的科目 (data_structure)"
    )
    
    parser.add_argument(
        "--output",
        type=str,
        default=None,
        help="指定输出文件路径"
    )
    
    parser.add_argument(
        "--config",
        type=str,
        default="config.json",
        help="指定配置文件路径"
    )
    
    parser.add_argument(
        "--list-chapters",
        action="store_true",
        help="列出所有可爬取的章节"
    )
    
    parser.add_argument(
        "--delay",
        type=float,
        default=None,
        help="设置请求间隔(秒)"
    )
    
    parser.add_argument(
        "--exam-only",
        action="store_true",
        help="只爬取真题，不爬取知识点"
    )
    
    parser.add_argument(
        "--knowledge-only",
        action="store_true",
        help="只爬取知识点，不爬取真题"
    )
    
    parser.add_argument(
        "--start-year",
        type=str,
        default=None,
        help="真题起始年份 (例如: 2020)"
    )
    
    parser.add_argument(
        "--end-year",
        type=str,
        default=None,
        help="真题结束年份 (例如: 2024)"
    )
    
    args = parser.parse_args()
    
    # 检查配置文件
    config_path = Path(args.config)
    if not config_path.exists():
        print(f"错误: 配置文件 {args.config} 不存在")
        sys.exit(1)
    
    # 初始化爬虫
    try:
        crawler = CSGraduatesCrawler(args.config)
    except Exception as e:
        print(f"初始化爬虫失败: {e}")
        sys.exit(1)
    
    # 列出章节
    if args.list_chapters:
        print("\n=== 可爬取的科目和章节 ===\n")
        for subject_key, subject_info in crawler.config["subjects"].items():
            print(f"\n【{subject_info['name']}】")
            print(f"  路径: {subject_info['path']}")
            for i, chapter in enumerate(subject_info["chapters"], 1):
                print(f"  {i}. {chapter['name']} ({chapter['path']})")
        
        print("\n\n=== 可爬取的历年真题 ===\n")
        if "exam_years" in crawler.config:
            for exam in crawler.config["exam_years"]:
                print(f"  {exam['year']}年 408真题")
        else:
            print("  (配置文件中未定义真题年份)")
        print()
        return
    
    # 设置延迟
    if args.delay is not None:
        crawler.config["crawl_settings"]["delay_seconds"] = args.delay
    
    # 爬取数据
    print("\n" + "=" * 50)
    print("CSGraduates考研真题和知识点爬虫")
    print("=" * 50 + "\n")
    
    # 只爬取真题
    if args.exam_only:
        print("开始爬取历年真题...\n")
        data = crawler.crawl_exam_papers(args.start_year, args.end_year)
        output_path = args.output or crawler.config["output"]["exam_papers"]
        crawler.save_results(data, output_path)
        print(f"\n爬取完成!")
        print(f"数据已保存到: {output_path}")
        return
    
    # 只爬取知识点
    if args.knowledge_only:
        if args.subject:
            if args.subject not in crawler.config["subjects"]:
                print(f"错误: 未找到科目 '{args.subject}'")
                print("使用 --list-chapters 查看所有可用科目")
                sys.exit(1)
            
            print(f"开始爬取: {args.subject}\n")
            data = crawler.crawl_subject(args.subject)
        else:
            print("开始爬取所有知识点...\n")
            data = crawler.crawl_all()
        
        output_path = args.output or crawler.config["output"]["knowledge_base"]
        crawler.save_results(data, output_path)
        print(f"\n爬取完成!")
        print(f"数据已保存到: {output_path}")
        return
    
    # 爬取所有内容（知识点 + 真题）
    all_data = {
        "crawl_time": time.strftime("%Y-%m-%d %H:%M:%S"),
        "knowledge": {},
        "exam_papers": {}
    }
    
    # 爬取知识点
    if args.subject:
        if args.subject not in crawler.config["subjects"]:
            print(f"错误: 未找到科目 '{args.subject}'")
            print("使用 --list-chapters 查看所有可用科目")
            sys.exit(1)
        
        print(f"开始爬取知识点: {args.subject}\n")
        all_data["knowledge"] = crawler.crawl_subject(args.subject)
    else:
        print("开始爬取所有知识点...\n")
        all_data["knowledge"] = crawler.crawl_all()
    
    # 爬取真题
    print("\n开始爬取历年真题...\n")
    all_data["exam_papers"] = crawler.crawl_exam_papers(args.start_year, args.end_year)
    
    # 保存结果
    output_path = args.output or crawler.config["output"]["knowledge_base"]
    crawler.save_results(all_data, output_path)
    
    print("\n爬取完成!")
    print(f"数据已保存到: {output_path}")


if __name__ == "__main__":
    main()
