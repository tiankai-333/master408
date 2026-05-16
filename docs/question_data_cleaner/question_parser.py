import json
import uuid
from pathlib import Path

class QuestionParser:
    def __init__(self, ocr_results_file, output_dir):
        self.ocr_results_file = Path(ocr_results_file)
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(parents=True, exist_ok=True)
        
        with open(self.ocr_results_file, 'r', encoding='utf-8') as f:
            self.ocr_results = json.load(f)
        
        self.subject_ids = {
            'data_structure': 101,
            'computer_organization': 104,
            'operating_system': 107,
            'computer_network': 110
        }
    
    def parse_questions(self):
        questions = []
        
        for page_data in self.ocr_results:
            page_num = page_data['page_num']
            page_type = page_data['type']
            
            if page_type == 'choice':
                questions.extend(self.parse_choice_page(page_data))
            elif page_type == 'essay':
                questions.extend(self.parse_essay_page(page_data))
            elif page_type == 'answer':
                pass
        
        return questions
    
    def parse_choice_page(self, page_data):
        questions = []
        question_nums = page_data['questions']
        
        for q_num in question_nums:
            question = self.create_question_template(
                q_num=q_num,
                q_type=1,
                subject=page_data['subject'],
                page_num=page_data['page_num'],
                image_base64=page_data['image_base64'],
                image_filename=page_data['image_filename']
            )
            questions.append(question)
        
        return questions
    
    def parse_essay_page(self, page_data):
        questions = []
        question_nums = page_data['questions']
        
        for q_num in question_nums:
            question = self.create_question_template(
                q_num=q_num,
                q_type=5,
                subject=page_data['subject'],
                page_num=page_data['page_num'],
                image_base64=page_data['image_base64'],
                image_filename=page_data['image_filename']
            )
            questions.append(question)
        
        return questions
    
    def create_question_template(self, q_num, q_type, subject, page_num, image_base64, image_filename):
        q_id = 2000 + q_num
        text_content_id = 2000 + q_num
        
        title_content = f"[第{q_num}题] 请参考右侧图片查看题目内容"
        
        if q_type == 1:
            question_item_objects = [
                {"prefix": "A", "content": "选项A", "itemUuid": str(uuid.uuid4())},
                {"prefix": "B", "content": "选项B", "itemUuid": str(uuid.uuid4())},
                {"prefix": "C", "content": "选项C", "itemUuid": str(uuid.uuid4())},
                {"prefix": "D", "content": "选项D", "itemUuid": str(uuid.uuid4())}
            ]
        else:
            question_item_objects = []
        
        text_content = {
            "titleContent": title_content,
            "analyze": "本题解析待补充",
            "questionItemObjects": question_item_objects,
            "correct": "正确答案待补充",
            "imageBase64": image_base64,
            "imageFilename": image_filename,
            "pageNum": page_num
        }
        
        return {
            "id": q_id,
            "question_type": q_type,
            "subject_id": self.subject_ids[subject],
            "score": 2 if q_type == 1 else 10,
            "grade_level": 2,
            "difficult": 3,
            "correct": "待补充",
            "info_text_content_id": text_content_id,
            "create_user": 1,
            "status": 1,
            "text_content": text_content,
            "text_content_id": text_content_id
        }
    
    def save_questions(self, questions):
        output_file = self.output_dir / 'parsed_questions.json'
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(questions, f, ensure_ascii=False, indent=2)
        
        print(f"题目解析完成！")
        print(f"共解析 {len(questions)} 道题目")
        print(f"结果保存至: {output_file}")
        
        return output_file

def main():
    ocr_results_file = r'c:/Dev/Workspaces/master408/docs/question_data_cleaner/ocr_results.json'
    output_dir = r'c:/Dev/Workspaces/master408/docs/question_data_cleaner'
    
    parser = QuestionParser(ocr_results_file, output_dir)
    questions = parser.parse_questions()
    parser.save_questions(questions)

if __name__ == '__main__':
    main()
