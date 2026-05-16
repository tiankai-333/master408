"""分析真题页面HTML结构"""

import requests
from bs4 import BeautifulSoup

def analyze_page():
    url = "https://www.csgraduates.com/study_methods/408quiz/2011/"
    
    print("Fetching page...")
    response = requests.get(url)
    response.encoding = "utf-8"
    
    soup = BeautifulSoup(response.text, "lxml")
    
    print("\n=== HTML结构分析 ===\n")
    
    # 查找所有标题
    for level in ['h1', 'h2', 'h3', 'h4', 'h5', 'h6']:
        headers = soup.find_all(level)
        if headers:
            print(f"\n{level.upper()} 标签 ({len(headers)}个):")
            for i, h in enumerate(headers[:5]):  # 只显示前5个
                text = h.get_text(strip=True)[:100]
                print(f"  {i+1}. {text}")
    
    # 查找主要内容区域
    print("\n\n=== 查找主要内容区域 ===")
    
    # 尝试各种可能的内容容器
    selectors = ['article', 'main', 'div.content', 'div.post', 'div.entry', 'div.article']
    
    for selector in selectors:
        elem = soup.select_one(selector)
        if elem:
            text = elem.get_text(strip=True)[:200]
            print(f"\n{selector}: 找到 ({len(elem.get_text())} 字符)")
            print(f"  内容预览: {text}...")
            break
    else:
        print("未找到标准内容区域")
    
    # 查找包含题目的区域
    print("\n\n=== 查找包含题目关键词的内容 ===")
    
    # 搜索包含题号的模式
    content = soup.get_text()
    
    # 统计不同科目的出现
    subjects = ["数据结构", "组成原理", "操作系统", "计算机网络"]
    for subject in subjects:
        count = content.count(subject)
        print(f"  {subject}: 出现 {count} 次")
    
    # 查找选择题题号模式
    import re
    question_pattern = re.compile(r'\d+\.\s+[A-Z].*?\n', re.MULTILINE)
    matches = question_pattern.findall(content[:5000])
    print(f"\n找到选择题模式 (数字. 选项): {len(matches)} 处")
    if matches:
        print("示例:")
        for m in matches[:3]:
            print(f"  {m.strip()[:100]}")
    
    # 检查答案速对表
    answer_table = re.findall(r'(\d+)\s+([A-D])', content[:10000])
    if answer_table:
        print(f"\n找到答案表: {len(answer_table)} 个答案")
        print(f"前10个: {answer_table[:10]}")
    
    # 查找包含完整题目的div
    print("\n\n=== 查找具体题目内容 ===")
    
    # 尝试查找所有包含题号的div
    all_divs = soup.find_all('div')
    print(f"页面共有 {len(all_divs)} 个div")
    
    # 查找含有题目编号的div
    for div in all_divs[:20]:
        text = div.get_text(strip=True)[:100]
        if re.match(r'^\d+\s', text):
            print(f"\n找到题目div:")
            print(f"  内容: {text}")
            break

if __name__ == "__main__":
    analyze_page()
