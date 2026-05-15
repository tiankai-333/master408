"""
大题（综合应用题）爬取脚本
从csgraduates.com爬取408真题的综合应用题部分
"""

import requests
from bs4 import BeautifulSoup
import json
import csv
import re
from pathlib import Path
import time


class EssayQuestionCrawler:
    """大题爬虫"""
    
    def __init__(self):
        self.base_url = "https://www.csgraduates.com"
        self.session = requests.Session()
        self.session.headers.update({
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
        })
        
    def fetch_page(self, url):
        """获取页面内容"""
        try:
            response = self.session.get(url, timeout=30)
            response.encoding = 'utf-8'
            return response.text
        except Exception as e:
            print(f"获取页面失败 {url}: {e}")
            return None
    
    def parse_essay_questions(self, html, year):
        """解析大题"""
        soup = BeautifulSoup(html, "lxml")
        essay_questions = []
        
        main_content = soup.find("main")
        if not main_content:
            return essay_questions
        
        # 查找大题标记（通常是"综合应用题"或类似标题）
        elements = main_content.find_all(['h2', 'h3', 'h4', 'div', 'p'])
        
        in_essay_section = False
        current_essay = None
        
        for i, elem in enumerate(elements):
            text = elem.get_text(strip=True)
            
            # 检测大题部分开始
            if "综合应用题" in text or "大题" in text or "应用题" in text:
                in_essay_section = True
                continue
                
            # 检测大题题号（如"41."或"(41)"）
            essay_match = re.match(r'^(\d+)[.、）)]', text)
            if in_essay_section and essay_match:
                if current_essay:
                    essay_questions.append(current_essay)
                
                essay_no = int(essay_match.group(1))
                current_essay = {
                    'year': year,
                    'question_no': essay_no,
                    'title': "",
                    'sub_questions': [],
                    'total_score': 0,
                    'answer': "",
                    'analysis': ""
                }
                
                # 提取分数
                score_match = re.search(r'(\d+)\s*分', text)
                if score_match:
                    current_essay['total_score'] = int(score_match.group(1))
                    
                # 添加标题内容
                current_essay['title'] = text
                
            elif current_essay:
                # 继续收集内容
                if "参考答案" in text or "答案" in text:
                    current_essay['answer'] += text + "\n"
                elif "解析" in text or "分析" in text:
                    current_essay['analysis'] += text + "\n"
                else:
                    current_essay['title'] += "\n" + text
        
        if current_essay:
            essay_questions.append(current_essay)
            
        return essay_questions
    
    def crawl_all_years(self):
        """爬取所有年份的大题"""
        years = ['2011', '2012', '2013', '2014', '2015', '2016', '2017', '2018', '2019', '2020', '2021', '2022', '2023', '2024']
        all_essays = []
        
        for year in years:
            print(f"\n爬取 {year} 年大题...")
            url = f"{self.base_url}/study_methods/408quiz/{year}/"
            html = self.fetch_page(url)
            
            if html:
                essays = self.parse_essay_questions(html, year)
                print(f"  找到 {len(essays)} 道大题")
                all_essays.extend(essays)
            
            time.sleep(1)  # 防反爬
        
        return all_essays
    
    def save_to_csv(self, essays, filepath="data/essay_questions.csv"):
        """保存到CSV"""
        Path(filepath).parent.mkdir(parents=True, exist_ok=True)
        
        with open(filepath, 'w', encoding='utf-8', newline='') as f:
            writer = csv.writer(f)
            writer.writerow(['year', 'question_no', 'title', 'sub_questions', 'total_score', 'answer', 'analysis'])
            
            for essay in essays:
                writer.writerow([
                    essay['year'],
                    essay['question_no'],
                    essay['title'][:50] + '...' if len(essay['title']) > 50 else essay['title'],
                    json.dumps(essay['sub_questions'], ensure_ascii=False),
                    essay['total_score'],
                    essay['answer'][:50] + '...' if len(essay['answer']) > 50 else essay['answer'],
                    essay['analysis'][:50] + '...' if len(essay['analysis']) > 50 else essay['analysis']
                ])
        
        print(f"\n已保存到大题CSV文件: {filepath}")
    
    def save_to_sql(self, essays, filepath="database/06_essay_questions.sql"):
        """生成SQL插入语句"""
        sql_lines = [
            "-- ============================================",
            "-- 大题（综合应用题）导入SQL",
            "-- ============================================",
            "",
            "USE xzs;",
            "",
            "START TRANSACTION;"
        ]
        
        subject_mapping = {
            '数据结构': 1,
            '计算机组成原理': 2,
            '操作系统': 3,
            '计算机网络': 4
        }
        
        for essay in essays:
            # 根据题号判断科目（408大题科目分布有规律）
            q_no = essay['question_no']
            if q_no >= 41 and q_no <= 43:
                subject_id = 1  # 数据结构
            elif q_no >= 44 and q_no <= 46:
                subject_id = 2  # 组成原理
            elif q_no >= 47 and q_no <= 48:
                subject_id = 3  # 操作系统
            elif q_no >= 49 and q_no <= 51:
                subject_id = 4  # 计算机网络
            else:
                subject_id = 1
            
            # 转义特殊字符
            title = essay['title'].replace("'", "''").replace('"', '\\"')
            answer = essay['answer'].replace("'", "''").replace('"', '\\"')
            analysis = essay['analysis'].replace("'", "''").replace('"', '\\"')
            
            sql = f"""INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`) VALUES
({subject_id}, {essay['year']}, {essay['question_no']}, '{title}', '[]', {essay['total_score']}, '{answer}', '{analysis}');"""
            
            sql_lines.append(sql)
        
        sql_lines.extend([
            "",
            "COMMIT;",
            f"-- 共插入 {len(essays)} 道大题"
        ])
        
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write('\n'.join(sql_lines))
        
        print(f"已生成SQL文件: {filepath}")


if __name__ == "__main__":
    crawler = EssayQuestionCrawler()
    essays = crawler.crawl_all_years()
    
    print(f"\n总计找到 {len(essays)} 道大题")
    
    if essays:
        crawler.save_to_csv(essays)
        crawler.save_to_sql(essays)
