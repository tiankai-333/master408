"""
CSGraduates网站爬虫
用于爬取计算机考研真题和知识点
"""

import requests
from bs4 import BeautifulSoup
import json
import time
import re
from typing import Dict, List, Optional
from pathlib import Path


class CSGraduatesCrawler:
    """爬取CSGraduates网站的真题和知识点"""
    
    def __init__(self, config_path: str = "config.json"):
        """初始化爬虫"""
        self.config = self._load_config(config_path)
        self.base_url = self.config["base_url"]
        self.session = requests.Session()
        self.session.headers.update({
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
        })
        
    def _load_config(self, config_path: str) -> Dict:
        """加载配置文件"""
        with open(config_path, "r", encoding="utf-8") as f:
            return json.load(f)
    
    def fetch_page(self, url: str, retries: Optional[int] = None) -> Optional[str]:
        """获取页面内容"""
        if retries is None:
            retries = self.config["crawl_settings"]["max_retries"]
            
        for attempt in range(retries):
            try:
                response = self.session.get(
                    url,
                    timeout=self.config["crawl_settings"]["timeout_seconds"]
                )
                response.raise_for_status()
                response.encoding = "utf-8"
                return response.text
            except requests.RequestException as e:
                if attempt < retries - 1:
                    time.sleep(self.config["crawl_settings"]["delay_seconds"])
                else:
                    print(f"Failed to fetch {url}: {e}")
                    return None
        return None
    
    def parse_knowledge_point(self, html: str, url: str) -> Dict:
        """解析知识点页面"""
        soup = BeautifulSoup(html, "lxml")
        
        # 提取标题
        title_elem = soup.find("h1")
        title = title_elem.get_text(strip=True) if title_elem else ""
        
        # 提取面包屑导航
        breadcrumbs = []
        breadcrumb_elem = soup.find("ul", class_="breadcrumb")
        if breadcrumb_elem:
            for item in breadcrumb_elem.find_all("li"):
                link = item.find("a")
                if link:
                    breadcrumbs.append({
                        "text": link.get_text(strip=True),
                        "url": link.get("href", "")
                    })
        
        # 提取主要内容
        content_elem = soup.find("article") or soup.find("main") or soup.find("div", class_="content")
        content = ""
        if content_elem:
            # 移除脚本和样式
            for tag in content_elem.find_all(["script", "style"]):
                tag.decompose()
            content = content_elem.get_text(separator="\n", strip=True)
        
        # 提取章节链接
        chapters = []
        for link in soup.find_all("a"):
            href = link.get("href", "")
            if href.startswith("/data_structure/") or href.startswith("/operating_system/"):
                chapters.append({
                    "title": link.get_text(strip=True),
                    "url": self.base_url + href if href.startswith("/") else href
                })
        
        return {
            "title": title,
            "url": url,
            "breadcrumbs": breadcrumbs,
            "content": content,
            "chapters": chapters
        }
    
    def parse_exam_paper(self, html: str, url: str, year: str) -> Dict:
        """解析真题页面"""
        soup = BeautifulSoup(html, "lxml")
        
        # 提取标题
        title_elem = soup.find("h1")
        title = title_elem.get_text(strip=True) if title_elem else f"{year}年408真题"
        
        # 提取主要内容区域
        content_elem = soup.find("article") or soup.find("main") or soup.find("div", class_="content")
        
        # 提取选择题
        choices = []
        if content_elem:
            # 查找选择题部分
            choice_pattern = re.compile(r'^\s*(\d+)\s+([A-D])\s+(.+)$', re.MULTILINE)
            content_text = content_elem.get_text(separator="\n", strip=True)
            matches = choice_pattern.findall(content_text)
            for num, option, question in matches:
                if int(num) <= 44:  # 选择题通常不超过44题
                    choices.append({
                        "number": int(num),
                        "answer": option,
                        "question": question.strip()
                    })
        
        # 提取答案速对表
        answers = {}
        answer_pattern = re.compile(r'(\d+)\s+([A-D])', re.MULTILINE)
        if content_elem:
            content_text = content_elem.get_text()
            matches = answer_pattern.findall(content_text)
            for num, ans in matches:
                answers[int(num)] = ans
        
        return {
            "year": year,
            "title": title,
            "url": url,
            "choices": choices,
            "answers": answers
        }
    
    def crawl_subject(self, subject_key: str) -> Dict:
        """爬取整个科目"""
        if subject_key not in self.config["subjects"]:
            print(f"Subject {subject_key} not found in config")
            return {}
        
        subject_config = self.config["subjects"][subject_key]
        result = {
            "name": subject_config["name"],
            "chapters": []
        }
        
        # 爬取科目主页
        subject_url = self.base_url + subject_config["path"]
        html = self.fetch_page(subject_url)
        if html:
            result["overview"] = self.parse_knowledge_point(html, subject_url)
        
        # 爬取各章节
        for chapter in subject_config["chapters"]:
            print(f"Crawling: {chapter['name']}")
            chapter_url = self.base_url + chapter["path"]
            chapter_html = self.fetch_page(chapter_url)
            
            if chapter_html:
                chapter_data = self.parse_knowledge_point(chapter_html, chapter_url)
                chapter_data["chapter_name"] = chapter["name"]
                result["chapters"].append(chapter_data)
                
                # 爬取子页面
                self._crawl_subpages(chapter_data, chapter["name"])
            
            time.sleep(self.config["crawl_settings"]["delay_seconds"])
        
        return result
    
    def crawl_exam_papers(self, start_year: Optional[str] = None, end_year: Optional[str] = None) -> Dict:
        """爬取历年真题"""
        result = {
            "crawl_time": time.strftime("%Y-%m-%d %H:%M:%S"),
            "papers": []
        }
        
        exam_years = self.config.get("exam_years", [])
        
        for exam in exam_years:
            year = exam["year"]
            
            # 根据年份范围过滤
            if start_year and year < start_year:
                continue
            if end_year and year > end_year:
                continue
            
            print(f"Crawling exam paper: {year}")
            exam_url = self.base_url + exam["path"]
            html = self.fetch_page(exam_url)
            
            if html:
                paper_data = self.parse_exam_paper(html, exam_url, year)
                result["papers"].append(paper_data)
            
            time.sleep(self.config["crawl_settings"]["delay_seconds"])
        
        return result
    
    def _crawl_subpages(self, chapter_data: Dict, chapter_name: str):
        """爬取子页面"""
        if "chapters" in chapter_data and chapter_data["chapters"]:
            chapter_data["subpages"] = []
            for subpage in chapter_data["chapters"][:5]:  # 限制子页面数量
                print(f"  Crawling subpage: {subpage['title']}")
                html = self.fetch_page(subpage["url"])
                if html:
                    subpage_data = self.parse_knowledge_point(html, subpage["url"])
                    chapter_data["subpages"].append(subpage_data)
                time.sleep(self.config["crawl_settings"]["delay_seconds"])
    
    def crawl_all(self) -> Dict:
        """爬取所有科目"""
        all_data = {
            "crawl_time": time.strftime("%Y-%m-%d %H:%M:%S"),
            "subjects": []
        }
        
        for subject_key in self.config["subjects"]:
            print(f"\n=== Crawling subject: {subject_key} ===")
            subject_data = self.crawl_subject(subject_key)
            if subject_data:
                all_data["subjects"].append(subject_data)
        
        return all_data
    
    def save_results(self, data: Dict, output_path: Optional[str] = None):
        """保存结果"""
        if output_path is None:
            output_path = self.config["output"]["knowledge_base"]
        
        Path(output_path).parent.mkdir(parents=True, exist_ok=True)
        
        with open(output_path, "w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        
        print(f"Results saved to {output_path}")


def main():
    """主函数"""
    crawler = CSGraduatesCrawler()
    data = crawler.crawl_all()
    crawler.save_results(data)


if __name__ == "__main__":
    main()
