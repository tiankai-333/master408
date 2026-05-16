"""检查真题页面中的图片"""

import requests
from bs4 import BeautifulSoup

def check_images():
    url = "https://www.csgraduates.com/study_methods/408quiz/2011/"
    
    response = requests.get(url)
    response.encoding = "utf-8"
    
    soup = BeautifulSoup(response.text, "lxml")
    
    # 查找所有图片
    images = soup.find_all('img')
    
    print(f"\n2011年真题页面中的图片统计：")
    print(f"=" * 60)
    print(f"总共发现 {len(images)} 张图片\n")
    
    # 分类统计
    external_images = []  # 外部图片
    ascii_graphics = []  # ASCII图形
    
    for i, img in enumerate(images, 1):
        src = img.get('src', '')
        alt = img.get('alt', '')
        
        if src.startswith('http'):
            external_images.append((i, src, alt))
        else:
            print(f"  本地图片: {src}")
    
    print(f"\n外部图片链接 ({len(external_images)} 张):")
    print("-" * 60)
    for idx, src, alt in external_images[:10]:  # 只显示前10个
        print(f"  {idx}. {src[:80]}...")
        if alt:
            print(f"     ALT: {alt[:50]}...")
    
    if len(external_images) > 10:
        print(f"\n  ... 还有 {len(external_images) - 10} 张图片")
    
    # 检查ASCII图形
    content = soup.get_text()
    
    # 查找可能包含ASCII图形的位置（如树的节点、表格等）
    if '插入结点' in content:
        print(f"\n发现ASCII图形：堆调整过程图")
    
    if '树' in content or '二叉树' in content:
        print(f"发现可能包含树形ASCII图形")
    
    # 统计不同类型的图片
    print(f"\n" + "=" * 60)
    print("图片类型统计:")
    print(f"  - 外部CDN图片: {len(external_images)} 张")
    print(f"  - ASCII图形: 若干 (堆排序图、树形图等)")
    
    # 检查其他年份
    print(f"\n\n检查其他年份的图片情况...")
    years_to_check = [2012, 2015, 2020, 2024]
    
    for year in years_to_check:
        year_url = f"https://www.csgraduates.com/study_methods/408quiz/{year}/"
        try:
            resp = requests.get(year_url, timeout=5)
            resp.encoding = "utf-8"
            year_soup = BeautifulSoup(resp.text, "lxml")
            year_images = year_soup.find_all('img')
            external_count = sum(1 for img in year_images if img.get('src', '').startswith('http'))
            print(f"  {year}年: {len(year_images)} 张图片 (外部链接: {external_count})")
        except:
            print(f"  {year}年: 无法访问")

if __name__ == "__main__":
    check_images()
