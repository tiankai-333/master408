import pytesseract
from PIL import Image
import os
import json
import base64
from pathlib import Path

class OCRProcessor:
    def __init__(self, img_dir, output_dir):
        self.img_dir = Path(img_dir)
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(parents=True, exist_ok=True)
        
        # 页面到题目的映射（根据页面内容映射.md）
        self.page_mapping = {
            4: {'type': 'choice', 'subject': 'data_structure', 'questions': [1, 2, 3, 4]},
            5: {'type': 'choice', 'subject': 'data_structure', 'questions': [5, 6, 7, 8]},
            6: {'type': 'choice', 'subject': 'computer_organization', 'questions': [9, 10, 11, 12]},
            7: {'type': 'choice', 'subject': 'computer_organization', 'questions': [13, 14, 15, 16]},
            8: {'type': 'choice', 'subject': 'operating_system', 'questions': [17, 18, 19, 20]},
            9: {'type': 'choice', 'subject': 'operating_system', 'questions': [21, 22, 23, 24]},
            10: {'type': 'choice', 'subject': 'computer_network', 'questions': [25, 26, 27, 28]},
            11: {'type': 'choice', 'subject': 'computer_network', 'questions': [29, 30, 31, 32]},
            12: {'type': 'choice', 'subject': 'computer_network', 'questions': [33, 34, 35, 36]},
            13: {'type': 'choice', 'subject': 'computer_network', 'questions': [37, 38, 39, 40]},
            15: {'type': 'essay', 'subject': 'data_structure', 'questions': [41]},
            16: {'type': 'essay', 'subject': 'data_structure', 'questions': [42]},
            17: {'type': 'essay', 'subject': 'computer_organization', 'questions': [43]},
            18: {'type': 'essay', 'subject': 'computer_organization', 'questions': [44]},
            19: {'type': 'essay', 'subject': 'operating_system', 'questions': [45]},
            20: {'type': 'essay', 'subject': 'operating_system', 'questions': [46]},
            21: {'type': 'essay', 'subject': 'computer_network', 'questions': [47]},
            22: {'type': 'essay', 'subject': 'computer_network', 'questions': [48]},
            24: {'type': 'answer', 'subject': 'all', 'questions': []}
        }
        
        self.subject_ids = {
            'data_structure': 101,
            'computer_organization': 104,
            'operating_system': 107,
            'computer_network': 110
        }
    
    def image_to_base64(self, image_path):
        with open(image_path, 'rb') as f:
            return base64.b64encode(f.read()).decode('utf-8')
    
    def process_page(self, page_num):
        img_path = self.img_dir / f'page{page_num}_img1.jpeg'
        if not img_path.exists():
            return None
        
        print(f"正在处理第 {page_num} 页...")
        
        img = Image.open(img_path)
        text = pytesseract.image_to_string(img, lang='chi_sim+eng')
        
        img_base64 = self.image_to_base64(img_path)
        
        page_info = self.page_mapping.get(page_num, {})
        
        return {
            'page_num': page_num,
            'text': text.strip(),
            'image_base64': img_base64,
            'image_filename': img_path.name,
            'type': page_info.get('type', 'unknown'),
            'subject': page_info.get('subject', 'unknown'),
            'questions': page_info.get('questions', [])
        }
    
    def process_all_pages(self):
        results = []
        
        for page_num in self.page_mapping.keys():
            result = self.process_page(page_num)
            if result:
                results.append(result)
        
        output_file = self.output_dir / 'ocr_results.json'
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(results, f, ensure_ascii=False, indent=2)
        
        print(f"\nOCR 处理完成！")
        print(f"共处理 {len(results)} 页")
        print(f"结果保存至: {output_file}")
        
        return results

def main():
    img_dir = r'c:/Dev/Workspaces/master408/docs/2024_408/images'
    output_dir = r'c:/Dev/Workspaces/master408/docs/question_data_cleaner'
    
    processor = OCRProcessor(img_dir, output_dir)
    processor.process_all_pages()

if __name__ == '__main__':
    main()
