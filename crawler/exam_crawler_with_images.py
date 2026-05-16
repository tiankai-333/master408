"""
408考研真题爬虫 - 完整版（含图片下载）
支持下载图片到本地，并保存图片路径
"""

import requests
from bs4 import BeautifulSoup
import json
import time
import csv
import re
from typing import Dict, List, Optional, Tuple
from pathlib import Path
import hashlib


class ExamCrawlerWithImages:
    """408真题爬虫 - 包含图片下载功能"""
    
    def __init__(self, config_path: str = "config.json"):
        """初始化爬虫"""
        self.config = self._load_config(config_path)
        self.base_url = self.config["base_url"]
        self.session = requests.Session()
        self.session.headers.update({
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
        })
        
        # 创建图片下载目录
        self.images_dir = Path("data/images")
        self.images_dir.mkdir(parents=True, exist_ok=True)
        
        # 图片URL缓存，避免重复下载
        self.downloaded_images = {}
        
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
    
    def download_image(self, url: str, filename: str) -> Optional[str]:
        """
        下载图片到本地
        
        参数:
            url: 图片URL
            filename: 保存的文件名（不含扩展名）
        
        返回:
            本地文件路径，如果下载失败返回None
        """
        if not url or url.startswith('data:'):  # 跳过空URL和base64图片
            return None
            
        # 检查是否已下载过
        if url in self.downloaded_images:
            return self.downloaded_images[url]
        
        try:
            # 下载图片
            response = self.session.get(url, timeout=30)
            response.raise_for_status()
            
            # 获取文件扩展名
            content_type = response.headers.get('content-type', '')
            if 'svg' in content_type or url.endswith('.svg'):
                ext = '.svg'
            elif 'png' in content_type or url.endswith('.png'):
                ext = '.png'
            elif 'jpeg' in content_type or url.endswith('.jpeg') or url.endswith('.jpg'):
                ext = '.jpg'
            elif 'gif' in content_type or url.endswith('.gif'):
                ext = '.gif'
            elif 'webp' in content_type or url.endswith('.webp'):
                ext = '.webp'
            else:
                # 从URL推断扩展名
                if '.svg' in url:
                    ext = '.svg'
                elif '.png' in url:
                    ext = '.png'
                elif '.jpg' in url or '.jpeg' in url:
                    ext = '.jpg'
                else:
                    ext = '.png'  # 默认PNG
            
            # 完整文件路径
            filepath = self.images_dir / f"{filename}{ext}"
            
            # 保存图片
            with open(filepath, 'wb') as f:
                f.write(response.content)
            
            # 记录已下载的图片
            local_path = str(filepath)
            self.downloaded_images[url] = local_path
            
            print(f"    ✓ 下载图片: {filename}{ext}")
            return local_path
            
        except Exception as e:
            print(f"    ✗ 下载失败 {url}: {e}")
            return None
    
    def parse_answer_table(self, html: str) -> Dict[int, str]:
        """解析答案速对表"""
        soup = BeautifulSoup(html, "lxml")
        
        answers = {}
        
        # 查找包含答案速对表的表格
        tables = soup.find_all("table")
        for table in tables:
            headers = table.find_all(["th", "td"])
            for header in headers:
                if "No." in header.get_text() or "Ans" in header.get_text():
                    cells = table.get_text()
                    pattern = re.compile(r'(\d+)\s+([A-D])')
                    matches = pattern.findall(cells)
                    for num, ans in matches:
                        if 1 <= int(num) <= 44:
                            answers[int(num)] = ans
                    break
        
        # 如果表格方法失败，尝试文本匹配
        if not answers:
            content = soup.get_text()
            pattern = re.compile(r'(\d+)\s+([A-D])')
            matches = pattern.findall(content[:5000])
            for num, ans in matches:
                if 1 <= int(num) <= 44:
                    answers[int(num)] = ans
        
        return answers
    
    def extract_images_from_question(self, question_element, year: str, 
                                   subject: str, q_num: int) -> List[Dict]:
        """提取题目中的图片"""
        images_info = []
        
        # 查找img标签
        for i, img in enumerate(question_element.find_all('img'), 1):
            src = img.get('src', '')
            alt = img.get('alt', '')
            
            # 转换为完整URL
            if src:
                full_url = requests.compat.urljoin(self.base_url, src)
                
                # 生成文件名：{年份}_{科目}_{题号}_{图片序号}
                subject_code = self._get_subject_code(subject)
                filename = f"{year}_{subject_code}_{q_num:02d}_{i}"
                
                # 下载图片
                local_path = self.download_image(full_url, filename)
                
                images_info.append({
                    'index': i,
                    'original_url': full_url,
                    'local_path': local_path,
                    'alt': alt
                })
        
        return images_info
    
    def _get_subject_code(self, subject: str) -> str:
        """获取科目代码"""
        codes = {
            '数据结构': 'DS',
            '计算机组成原理': 'CO',
            '组成原理': 'CO',
            '操作系统': 'OS',
            '计算机网络': 'CN'
        }
        return codes.get(subject, 'XX')
    
    def parse_exam_questions(self, html: str, year: str) -> List[Dict]:
        """解析真题页面，提取所有题目"""
        soup = BeautifulSoup(html, "lxml")
        
        questions = []
        current_subject = "数据结构"
        question_number = 0
        
        # 查找main内容区域
        main_content = soup.find("main")
        if not main_content:
            return questions
        
        # 遍历所有元素
        elements = main_content.find_all(['h1', 'h2', 'h3', 'h4', 'h5', 'div', 'p'])
        
        for i, elem in enumerate(elements):
            text = elem.get_text(strip=True)
            
            # 检测科目标题
            if elem.name == 'h4':
                if "数据结构" in text:
                    current_subject = "数据结构"
                elif "组成原理" in text:
                    current_subject = "计算机组成原理"
                elif "操作系统" in text:
                    current_subject = "操作系统"
                elif "计算机网络" in text:
                    current_subject = "计算机网络"
                continue
            
            # 检测题号
            if elem.name == 'h5' and re.match(r'^\d+$', text):
                question_number = int(text)
                
                # 提取后续内容
                question_text = ""
                options = []
                answer = ""
                analysis = ""
                images = []
                
                # 查看后续元素
                for j in range(i + 1, min(i + 50, len(elements))):
                    next_elem = elements[j]
                    next_text = next_elem.get_text(strip=True)
                    
                    # 遇到下一个h5或h4就停止
                    if next_elem.name in ['h4', 'h5']:
                        break
                    
                    # 提取图片
                    img_tags = next_elem.find_all('img')
                    for idx, img in enumerate(img_tags, 1):
                        src = img.get('src', '')
                        if src:
                            full_url = requests.compat.urljoin(self.base_url, src)
                            subject_code = self._get_subject_code(current_subject)
                            filename = f"{year}_{subject_code}_{question_number:02d}_{idx}"
                            
                            local_path = self.download_image(full_url, filename)
                            images.append(local_path or full_url)
                    
                    # 提取选项
                    if re.match(r'^A[.、\s]', next_text) or re.match(r'^A\.$', next_text[:3]):
                        if next_text not in options:
                            options.append(next_text)
                    elif re.match(r'^B[.、\s]', next_text) or re.match(r'^B\.$', next_text[:3]):
                        if next_text not in options:
                            options.append(next_text)
                    elif re.match(r'^C[.、\s]', next_text) or re.match(r'^C\.$', next_text[:3]):
                        if next_text not in options:
                            options.append(next_text)
                    elif re.match(r'^D[.、\s]', next_text) or re.match(r'^D\.$', next_text[:3]):
                        if next_text not in options:
                            options.append(next_text)
                    
                    # 提取正确答案
                    if "正确答案" in next_text:
                        match = re.search(r'正确答案[：:]\s*([A-D])', next_text)
                        if match:
                            answer = match.group(1)
                        elif re.match(r'^[A-D]$', next_text[-1]):
                            answer = next_text[-1]
                    
                    # 提取解析
                    if "正确答案" in next_text and len(next_text) > 5:
                        if not analysis:
                            analysis = next_text
                    
                    # 收集题目文本
                    if (next_text and 
                        not re.match(r'^[A-D][.、\s]', next_text) and
                        not re.match(r'^[A-D]$', next_text) and
                        "正确答案" not in next_text and
                        "查看答案" not in next_text and
                        "查看答案与解析" not in next_text and
                        len(next_text) > 3):
                        question_text += " " + next_text
                
                # 清理题目文本
                question_text = re.sub(r'\s+', ' ', question_text).strip()
                
                # 构建选项文本
                options_text = " | ".join(options) if options else ""
                
                # 构建图片路径文本
                images_text = "; ".join(images) if images else ""
                
                # 只添加选择题（题号1-44）
                if 1 <= question_number <= 44:
                    questions.append({
                        "year": year,
                        "subject": current_subject,
                        "question_type": "真题",
                        "question_number": question_number,
                        "question": question_text,
                        "options": options_text,
                        "answer": answer,
                        "analysis": analysis,
                        "images": images_text
                    })
        
        return questions
    
    def crawl_all_exams(self, start_year: Optional[str] = None, 
                       end_year: Optional[str] = None) -> List[Dict]:
        """爬取所有年份的真题"""
        all_questions = []
        
        exam_years = self.config.get("exam_years", [])
        
        for exam in exam_years:
            year = exam["year"]
            
            # 根据年份范围过滤
            if start_year and year < start_year:
                continue
            if end_year and year > end_year:
                continue
            
            print(f"\n正在爬取: {year}年真题")
            exam_url = self.base_url + exam["path"]
            html = self.fetch_page(exam_url)
            
            if html:
                # 解析答案速对表
                answers = self.parse_answer_table(html)
                
                # 解析题目
                questions = self.parse_exam_questions(html, year)
                
                # 补充答案
                for q in questions:
                    if not q["answer"] and q["question_number"] in answers:
                        q["answer"] = answers[q["question_number"]]
                
                print(f"  - 找到 {len(questions)} 道选择题")
                print(f"  - 下载了 {len(self.downloaded_images)} 张图片")
                all_questions.extend(questions)
            
            time.sleep(self.config["crawl_settings"]["delay_seconds"])
        
        return all_questions
    
    def save_to_csv(self, questions: List[Dict], output_path: str):
        """保存为CSV格式"""
        if not questions:
            print("没有题目可保存")
            return
        
        Path(output_path).parent.mkdir(parents=True, exist_ok=True)
        
        # CSV字段（包含图片路径）
        fieldnames = ["year", "subject", "question_type", "question_number", 
                     "question", "options", "answer", "analysis", "images"]
        
        with open(output_path, 'w', newline='', encoding='utf-8-sig') as f:
            writer = csv.DictWriter(f, fieldnames=fieldnames)
            writer.writeheader()
            writer.writerows(questions)
        
        print(f"\n✓ CSV已保存: {output_path}")
    
    def save_to_json(self, questions: List[Dict], output_path: str):
        """保存为JSON格式"""
        Path(output_path).parent.mkdir(parents=True, exist_ok=True)
        
        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(questions, f, ensure_ascii=False, indent=2)
        
        print(f"✓ JSON已保存: {output_path}")
    
    def save_image_manifest(self, output_path: str):
        """保存图片清单"""
        manifest = {
            "total_images": len(self.downloaded_images),
            "images": [
                {"original_url": url, "local_path": path}
                for url, path in self.downloaded_images.items()
            ]
        }
        
        Path(output_path).parent.mkdir(parents=True, exist_ok=True)
        
        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(manifest, f, ensure_ascii=False, indent=2)
        
        print(f"✓ 图片清单已保存: {output_path}")


def main():
    """主函数"""
    import argparse
    
    parser = argparse.ArgumentParser(description="408考研真题爬虫 - 完整版")
    parser.add_argument("--start-year", type=str, default="2011", help="起始年份")
    parser.add_argument("--end-year", type=str, default="2024", help="结束年份")
    parser.add_argument("--csv", type=str, default="data/exam_questions.csv", help="CSV输出路径")
    parser.add_argument("--json", type=str, default=None, help="JSON输出路径")
    parser.add_argument("--manifest", action="store_true", help="保存图片清单")
    
    args = parser.parse_args()
    
    crawler = ExamCrawlerWithImages()
    
    print("\n" + "=" * 60)
    print("408考研真题爬虫 - 完整版")
    print("=" * 60)
    print(f"\n爬取年份: {args.start_year} - {args.end_year}")
    print(f"图片保存位置: {crawler.images_dir}")
    print(f"输出格式: CSV ✓ JSON {'✓' if args.json else '✗'}\n")
    
    # 爬取所有真题
    questions = crawler.crawl_all_exams(args.start_year, args.end_year)
    
    print(f"\n总计爬取: {len(questions)} 道选择题")
    print(f"总计下载: {len(crawler.downloaded_images)} 张图片")
    
    # 统计各科目题目数量
    subjects = {}
    for q in questions:
        subject = q["subject"]
        subjects[subject] = subjects.get(subject, 0) + 1
    
    print("\n各科目题目数量:")
    for subject, count in sorted(subjects.items()):
        print(f"  - {subject}: {count} 道")
    
    # 统计有图片的题目
    questions_with_images = sum(1 for q in questions if q.get("images"))
    print(f"\n包含图片的题目: {questions_with_images} 道")
    
    # 保存
    crawler.save_to_csv(questions, args.csv)
    
    if args.json or args.manifest:
        json_path = args.json or args.csv.replace('.csv', '.json')
        crawler.save_to_json(questions, json_path)
    
    if args.manifest:
        crawler.save_image_manifest("data/image_manifest.json")
    
    print("\n" + "=" * 60)
    print("爬取完成!")
    print("=" * 60)


if __name__ == "__main__":
    main()
