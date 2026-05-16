"""
改进版大题爬虫 - 专门处理综合应用题
"""

import requests
from bs4 import BeautifulSoup
import csv
import json
import re
from pathlib import Path
import time


class ImprovedEssayCrawler:
    """改进版大题爬虫"""
    
    def __init__(self):
        self.base_url = "https://www.csgraduates.com"
        self.session = requests.Session()
        self.session.headers.update({
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
        })
        self.images_dir = Path("crawler/data/essay_images")
        self.images_dir.mkdir(parents=True, exist_ok=True)
        
    def fetch_page(self, url):
        """获取页面内容"""
        try:
            response = self.session.get(url, timeout=30)
            response.encoding = 'utf-8'
            return response.text
        except Exception as e:
            print(f"  获取页面失败: {e}")
            return None
    
    def download_image(self, img_url, filename):
        """下载图片"""
        try:
            response = self.session.get(img_url, timeout=30)
            if response.status_code == 200:
                filepath = self.images_dir / filename
                with open(filepath, 'wb') as f:
                    f.write(response.content)
                print(f"    下载图片: {filename}")
                return str(filepath)
        except Exception as e:
            print(f"    下载失败 {img_url}: {e}")
        return None
    
    def parse_essay_questions(self, html, year):
        """解析大题"""
        soup = BeautifulSoup(html, "lxml")
        essay_questions = []
        
        main_content = soup.find("main")
        if not main_content:
            return essay_questions
        
        # 查找所有h5标签（题目标题）
        h5_tags = main_content.find_all('h5')
        
        current_subject = "数据结构"
        is_in_essay = False
        
        for i, h5 in enumerate(h5_tags):
            text = h5.get_text(strip=True)
            
            # 检测科目
            prev_h4 = h5.find_previous('h4')
            if prev_h4:
                prev_text = prev_h4.get_text(strip=True)
                if "数据结构" in prev_text:
                    current_subject = "数据结构"
                elif "组成原理" in prev_text or "组成" in prev_text:
                    current_subject = "计算机组成原理"
                elif "操作系统" in prev_text:
                    current_subject = "操作系统"
                elif "计算机网络" in prev_text:
                    current_subject = "计算机网络"
            
            # 检测大题题号 (41-47)
            q_match = re.match(r'^(4[1-7]|[1-9][0-9])$', text)
            if q_match:
                q_no = int(text)
                
                # 判断是否是大题（41及以上）
                if q_no >= 41:
                    is_in_essay = True
                    essay = {
                        'year': year,
                        'question_no': q_no,
                        'subject': current_subject,
                        'title': "",
                        'sub_questions': [],
                        'total_score': 10,  # 默认10分
                        'answer': "",
                        'analysis': "",
                        'images': []
                    }
                    
                    # 提取后续内容
                    next_elements = h5.find_all_next(['h5', 'h4', 'p', 'div', 'pre'])
                    content_text = ""
                    
                    for elem in next_elements[:30]:  # 限制范围
                        elem_text = elem.get_text(strip=True)
                        
                        # 遇到下一个题目就停止
                        next_h5 = elem.find_next('h5')
                        if next_h5 and next_h5.get_text(strip=True) != text:
                            next_text = next_h5.get_text(strip=True)
                            if re.match(r'^\d+$', next_text) and int(next_text) != q_no:
                                break
                        
                        # 下载图片
                        for img in elem.find_all('img'):
                            img_url = img.get('src', '')
                            if img_url and not img_url.startswith('data:'):
                                full_url = requests.compat.urljoin(self.base_url, img_url)
                                ext = '.jpg' if '.jpg' in img_url else '.png' if '.png' in img_url else '.svg'
                                filename = f"{year}_{current_subject}_{q_no}_{len(essay['images'])+1}{ext}"
                                local_path = self.download_image(full_url, filename)
                                if local_path:
                                    essay['images'].append(local_path)
                        
                        content_text += elem_text + "\n"
                        
                        # 提取答案和解析
                        if "正确答案" in elem_text or "答案" in elem_text:
                            essay['answer'] += elem_text + "\n"
                        if "解析" in elem_text or "分析" in elem_text:
                            essay['analysis'] += elem_text + "\n"
                    
                    essay['title'] = content_text
                    essay_questions.append(essay)
        
        return essay_questions
    
    def crawl_all_years(self):
        """爬取所有年份的大题"""
        years = [str(y) for y in range(2011, 2025)]
        all_essays = []
        
        for year in years:
            print(f"\n爬取 {year} 年大题...")
            url = f"{self.base_url}/study_methods/408quiz/{year}/"
            html = self.fetch_page(url)
            
            if html:
                essays = self.parse_essay_questions(html, year)
                print(f"  找到 {len(essays)} 道大题")
                
                for essay in essays:
                    print(f"    第{essay['question_no']}题 - {essay['subject']}")
                
                all_essays.extend(essays)
            
            time.sleep(1)  # 防反爬
        
        return all_essays
    
    def save_to_csv(self, essays, filepath="crawler/data/essay_questions.csv"):
        """保存到CSV"""
        Path(filepath).parent.mkdir(parents=True, exist_ok=True)
        
        with open(filepath, 'w', encoding='utf-8', newline='') as f:
            writer = csv.writer(f)
            writer.writerow(['year', 'subject', 'question_no', 'title', 'total_score', 'answer', 'analysis', 'images'])
            
            for essay in essays:
                writer.writerow([
                    essay['year'],
                    essay['subject'],
                    essay['question_no'],
                    essay['title'][:100] + '...' if len(essay['title']) > 100 else essay['title'],
                    essay['total_score'],
                    essay['answer'][:100] + '...' if len(essay['answer']) > 100 else essay['answer'],
                    essay['analysis'][:100] + '...' if len(essay['analysis']) > 100 else essay['analysis'],
                    ','.join(essay['images'])
                ])
        
        print(f"\n✓ 已保存到CSV: {filepath}")
    
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
            '组成原理': 2,
            '操作系统': 3,
            '计算机网络': 4
        }
        
        for essay in essays:
            subject_id = subject_mapping.get(essay['subject'], 1)
            
            # 转义特殊字符
            title = essay['title'].replace("'", "''").replace('\\', '\\\\')[:5000]  # 限制长度
            answer = essay['answer'].replace("'", "''").replace('\\', '\\\\')[:5000]
            analysis = essay['analysis'].replace("'", "''").replace('\\', '\\\\')[:5000]
            images = ','.join(essay['images'])
            
            sql = f"""INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
({subject_id}, {essay['year']}, {essay['question_no']}, '{title}', '[]', {essay['total_score']}, '{answer}', '{analysis}', '{images}');"""
            
            sql_lines.append(sql)
        
        sql_lines.extend([
            "",
            "COMMIT;",
            f"-- 共插入 {len(essays)} 道大题",
            "-- 大题导入完成"
        ])
        
        Path(filepath).parent.mkdir(parents=True, exist_ok=True)
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write('\n'.join(sql_lines))
        
        print(f"✓ 已生成SQL文件: {filepath}")


if __name__ == "__main__":
    crawler = ImprovedEssayCrawler()
    essays = crawler.crawl_all_years()
    
    print(f"\n总计找到 {len(essays)} 道大题")
    
    if essays:
        crawler.save_to_csv(essays)
        crawler.save_to_sql(essays)
        print("\n大题爬取完成！")
    else:
        print("\n未找到大题，请检查HTML结构")
