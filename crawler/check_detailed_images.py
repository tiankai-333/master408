"""详细检查真题中的图片"""

import requests
from bs4 import BeautifulSoup
import re

def check_detailed_images():
    url = "https://www.csgraduates.com/study_methods/408quiz/2011/"
    
    response = requests.get(url)
    response.encoding = "utf-8"
    
    soup = BeautifulSoup(response.text, "lxml")
    
    # 查找所有图片和SVG
    all_media = []
    
    # 图片
    for img in soup.find_all('img'):
        src = img.get('src', '')
        all_media.append({
            'type': 'img',
            'src': src,
            'alt': img.get('alt', ''),
            'full_url': requests.compat.urljoin(url, src)
        })
    
    # SVG
    for svg in soup.find_all('svg'):
        all_media.append({
            'type': 'svg',
            'content': str(svg)[:100],
            'inline': True
        })
    
    # 检查pre和code中的图形
    pre_elements = soup.find_all('pre')
    if pre_elements:
        print(f"\n发现 {len(pre_elements)} 个 <pre> 代码块")
        
        # 检查是否包含ASCII图形
        for i, pre in enumerate(pre_elements[:3]):
            content = pre.get_text()
            if len(content) > 50 and '\n' in content:
                lines = content.split('\n')
                if len(lines) > 5:
                    print(f"\n  第{i+1}个代码块包含ASCII图形:")
                    print(f"  前5行:")
                    for line in lines[:5]:
                        print(f"    {line}")
    
    # 统计图片URL
    print(f"\n" + "=" * 70)
    print("图片URL详细列表:")
    print("=" * 70)
    
    local_images = [m for m in all_media if m['type'] == 'img' and not m['src'].startswith('http')]
    
    for i, img in enumerate(local_images, 1):
        print(f"\n图片 {i}:")
        print(f"  原始路径: {img['src']}")
        print(f"  完整URL: {img['full_url']}")
        if img['alt']:
            print(f"  ALT文本: {img['alt']}")
    
    print(f"\n\n总共: {len(local_images)} 张本地图片")
    
    # 检查图片是否可访问
    print(f"\n检查图片可访问性...")
    for img in local_images[:3]:
        try:
            img_response = requests.head(img['full_url'], timeout=5)
            print(f"  ✓ {img['src'][:50]}... - {img_response.status_code}")
        except Exception as e:
            print(f"  ✗ {img['src'][:50]}... - 错误: {e}")

if __name__ == "__main__":
    check_detailed_images()
