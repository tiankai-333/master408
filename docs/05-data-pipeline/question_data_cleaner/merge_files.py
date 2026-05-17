import json
import base64
import uuid
from pathlib import Path


class QuestionMerger:
    def __init__(self, images_dir=None):
        self.subject_ids = {
            "data_structure": 101,
            "computer_organization": 104,
            "operating_system": 107,
            "computer_network": 110
        }
        self.type_ids = {
            "choice": 1,
            "multiple_choice": 2,
            "judge": 3,
            "fill": 4,
            "essay": 5
        }
        self.images_dir = Path(images_dir) if images_dir else None

    def load_json(self, filepath):
        with open(filepath, 'r', encoding='utf-8') as f:
            return json.load(f)

    def get_image_base64(self, page_num):
        if not self.images_dir:
            return None
        
        image_path = self.images_dir / f"page{page_num}_img1.jpeg"
        if not image_path.exists():
            image_path = self.images_dir / f"page{page_num}_img1.jpg"
        
        if not image_path.exists():
            return None
        
        with open(image_path, 'rb') as f:
            return base64.b64encode(f.read()).decode('utf-8')

    def merge(self, questions_file, answers_file, output_file=None):
        questions = self.load_json(questions_file)
        answers = self.load_json(answers_file)
        
        answer_map = {a["question_num"]: a for a in answers}
        
        merged_questions = []
        
        for q in questions:
            q_num = q["question_num"]
            answer = answer_map.get(q_num, {})
            
            subject_id = self.subject_ids.get(q["subject"], 101)
            question_type = self.type_ids.get(q["type"], 1)
            
            question_item_objects = []
            if "options" in q and q["options"]:
                for opt in q["options"]:
                    question_item_objects.append({
                        "prefix": opt["prefix"],
                        "content": opt["content"],
                        "itemUuid": str(uuid.uuid4())
                    })
            
            text_content = {
                "titleContent": q.get("titleContent", ""),
                "analyze": answer.get("analyze", "本题解析待补充"),
                "questionItemObjects": question_item_objects,
                "correct": answer.get("correctAnswerText", answer.get("correct", "正确答案待补充"))
            }
            
            if "page_num" in q:
                img_b64 = self.get_image_base64(q["page_num"])
                if img_b64:
                    text_content["imageBase64"] = img_b64
                    text_content["imageFilename"] = f"page{q['page_num']}_img1.jpeg"
                    text_content["pageNum"] = q["page_num"]
            
            merged_question = {
                "id": q.get("id", 2000 + q_num),
                "question_type": question_type,
                "subject_id": subject_id,
                "score": q.get("score", 2 if question_type == 1 else 10),
                "grade_level": q.get("grade_level", 2),
                "difficult": q.get("difficult", 3),
                "correct": answer.get("correct", "待补充"),
                "info_text_content_id": q.get("id", 2000 + q_num),
                "create_user": q.get("create_user", 1),
                "status": q.get("status", 1),
                "text_content": text_content,
                "text_content_id": q.get("id", 2000 + q_num)
            }
            
            merged_questions.append(merged_question)
        
        if output_file:
            with open(output_file, 'w', encoding='utf-8') as f:
                json.dump(merged_questions, f, ensure_ascii=False, indent=2)
            print(f"✅ 合并完成！共 {len(merged_questions)} 道题目")
            print(f"📄 输出文件: {output_file}")
        
        return merged_questions


def main():
    import sys
    
    if len(sys.argv) < 3:
        print("使用方法:")
        print("  python merge_files.py <题目文件> <答案文件> [输出文件] [图片目录]")
        print("\n示例:")
        print("  python merge_files.py examples/questions_only.json examples/answers_only.json output.json ../2024_408/images")
        return
    
    questions_file = sys.argv[1]
    answers_file = sys.argv[2]
    output_file = sys.argv[3] if len(sys.argv) > 3 else "merged_questions.json"
    images_dir = sys.argv[4] if len(sys.argv) > 4 else None
    
    merger = QuestionMerger(images_dir)
    merger.merge(questions_file, answers_file, output_file)


if __name__ == "__main__":
    main()