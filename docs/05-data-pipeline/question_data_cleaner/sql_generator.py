import json
from pathlib import Path

class SQLGenerator:
    def __init__(self, parsed_questions_file, output_dir):
        self.parsed_questions_file = Path(parsed_questions_file)
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(parents=True, exist_ok=True)
        
        with open(self.parsed_questions_file, 'r', encoding='utf-8') as f:
            self.questions = json.load(f)
    
    def escape_sql_string(self, s):
        if s is None:
            return 'NULL'
        s = str(s)
        s = s.replace("'", "''")
        s = s.replace("\\", "\\\\")
        return f"'{s}'"
    
    def generate_text_content_sql(self):
        sql_lines = []
        sql_lines.append("-- ============================================")
        sql_lines.append("-- 插入题目内容（t_text_content）")
        sql_lines.append("-- ============================================")
        
        for q in self.questions:
            text_content = q['text_content'].copy()
            # 移除不需要存储在数据库中的字段，只保留必要的
            if 'imageBase64' in text_content:
                del text_content['imageBase64']
            if 'imageFilename' in text_content:
                del text_content['imageFilename']
            if 'pageNum' in text_content:
                del text_content['pageNum']
            
            content_json = json.dumps(text_content, ensure_ascii=False)
            content_json_escaped = self.escape_sql_string(content_json)
            
            sql_line = f"INSERT INTO `t_text_content` (`id`, `content`, `create_time`) VALUES ({q['text_content_id']}, {content_json_escaped}, NOW());"
            sql_lines.append(sql_line)
        
        return '\n'.join(sql_lines)
    
    def generate_question_sql(self):
        sql_lines = []
        sql_lines.append("-- ============================================")
        sql_lines.append("-- 插入题目记录（t_question）")
        sql_lines.append("-- ============================================")
        
        for q in self.questions:
            sql_line = (
                f"INSERT INTO `t_question` ("
                f"`id`, `question_type`, `subject_id`, `score`, `grade_level`, "
                f"`difficult`, `correct`, `info_text_content_id`, `create_user`, `status`, `create_time`, `deleted`"
                f") VALUES ("
                f"{q['id']}, {q['question_type']}, {q['subject_id']}, {q['score']}, {q['grade_level']}, "
                f"{q['difficult']}, {self.escape_sql_string(q['correct'])}, {q['info_text_content_id']}, "
                f"{q['create_user']}, {q['status']}, NOW(), b'0'"
                f");"
            )
            sql_lines.append(sql_line)
        
        return '\n'.join(sql_lines)
    
    def generate_full_sql(self):
        sql_parts = []
        sql_parts.append("-- ============================================")
        sql_parts.append("-- 2024年408真题 数据库导入脚本")
        sql_parts.append("-- ============================================")
        sql_parts.append("")
        sql_parts.append("USE xzs;")
        sql_parts.append("")
        sql_parts.append("SET FOREIGN_KEY_CHECKS = 0;")
        sql_parts.append("")
        sql_parts.append(self.generate_text_content_sql())
        sql_parts.append("")
        sql_parts.append(self.generate_question_sql())
        sql_parts.append("")
        sql_parts.append("SET FOREIGN_KEY_CHECKS = 1;")
        sql_parts.append("")
        sql_parts.append("-- ============================================")
        sql_parts.append("-- 验证导入")
        sql_parts.append("-- ============================================")
        sql_parts.append("SELECT '2024年408真题导入完成！' AS result;")
        sql_parts.append(f"SELECT COUNT(*) AS question_count FROM t_question WHERE id >= 2001;")
        sql_parts.append(f"SELECT COUNT(*) AS text_content_count FROM t_text_content WHERE id >= 2001;")
        
        full_sql = '\n'.join(sql_parts)
        
        output_file = self.output_dir / 'insert_2024_questions.sql'
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(full_sql)
        
        print(f"SQL 脚本生成完成！")
        print(f"共生成 {len(self.questions)} 道题目")
        print(f"SQL 保存至: {output_file}")
        
        return output_file

def main():
    parsed_questions_file = r'c:/Dev/Workspaces/master408/docs/05-data-pipeline/question_data_cleaner/parsed_questions.json'
    output_dir = r'c:/Dev/Workspaces/master408/docs/05-data-pipeline/question_data_cleaner'
    
    generator = SQLGenerator(parsed_questions_file, output_dir)
    generator.generate_full_sql()

if __name__ == '__main__':
    main()
