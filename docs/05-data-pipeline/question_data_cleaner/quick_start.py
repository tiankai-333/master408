import json
import base64
import uuid
from pathlib import Path

# 页面配置：页码 -> 题目信息
PAGE_CONFIG = {
    4: {'questions': [1, 2, 3, 4], 'type': 1, 'subject': 101},
    5: {'questions': [5, 6, 7, 8], 'type': 1, 'subject': 101},
    6: {'questions': [9, 10, 11, 12], 'type': 1, 'subject': 104},
    7: {'questions': [13, 14, 15, 16], 'type': 1, 'subject': 104},
    8: {'questions': [17, 18, 19, 20], 'type': 1, 'subject': 107},
    9: {'questions': [21, 22, 23, 24], 'type': 1, 'subject': 107},
    10: {'questions': [25, 26, 27, 28], 'type': 1, 'subject': 110},
    11: {'questions': [29, 30, 31, 32], 'type': 1, 'subject': 110},
    12: {'questions': [33, 34, 35, 36], 'type': 1, 'subject': 110},
    13: {'questions': [37, 38, 39, 40], 'type': 1, 'subject': 110},
    15: {'questions': [41], 'type': 5, 'subject': 101},
    16: {'questions': [42], 'type': 5, 'subject': 101},
    17: {'questions': [43], 'type': 5, 'subject': 104},
    18: {'questions': [44], 'type': 5, 'subject': 104},
    19: {'questions': [45], 'type': 5, 'subject': 107},
    20: {'questions': [46], 'type': 5, 'subject': 107},
    21: {'questions': [47], 'type': 5, 'subject': 110},
    22: {'questions': [48], 'type': 5, 'subject': 110},
}

def image_to_base64(image_path):
    with open(image_path, 'rb') as f:
        return base64.b64encode(f.read()).decode('utf-8')

def main():
    img_dir = Path(__file__).parent.parent / '2024_408' / 'images'
    output_dir = Path(__file__).parent
    output_dir.mkdir(parents=True, exist_ok=True)
    
    questions = []
    
    for page_num, config in PAGE_CONFIG.items():
        img_path = img_dir / f'page{page_num}_img1.jpeg'
        
        if not img_path.exists():
            print(f'Warning: Image not found: {img_path}')
            continue
        
        img_b64 = image_to_base64(img_path)
        
        for q_num in config['questions']:
            q_id = 2000 + q_num
            tc_id = 2000 + q_num
            
            # 构建题目内容
            text_content = {
                'titleContent': f'[第{q_num}题] 请查看右侧图片',
                'analyze': '本题解析待补充',
                'questionItemObjects': [],
                'correct': '正确答案待补充',
                'imageBase64': img_b64,
                'imageFilename': img_path.name,
                'pageNum': page_num
            }
            
            # 选择题添加选项
            if config['type'] == 1:
                text_content['questionItemObjects'] = [
                    {'prefix': 'A', 'content': '选项A', 'itemUuid': str(uuid.uuid4())},
                    {'prefix': 'B', 'content': '选项B', 'itemUuid': str(uuid.uuid4())},
                    {'prefix': 'C', 'content': '选项C', 'itemUuid': str(uuid.uuid4())},
                    {'prefix': 'D', 'content': '选项D', 'itemUuid': str(uuid.uuid4())}
                ]
            
            question = {
                'id': q_id,
                'question_type': config['type'],
                'subject_id': config['subject'],
                'score': 2 if config['type'] == 1 else 10,
                'grade_level': 2,
                'difficult': 3,
                'correct': '待补充',
                'info_text_content_id': tc_id,
                'create_user': 1,
                'status': 1,
                'text_content': text_content,
                'text_content_id': tc_id
            }
            
            questions.append(question)
            print(f'Created question {q_num} (page {page_num})')
    
    # 保存题目数据
    output_file = output_dir / 'parsed_questions.json'
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(questions, f, ensure_ascii=False, indent=2)
    
    print(f'\nSuccess! Created {len(questions)} questions')
    print(f'Output: {output_file}')
    print(f'\nNext step: Open question_editor.html to edit the questions!')

if __name__ == '__main__':
    main()
