import pymysql

DB_CONFIG = {
    "host": "localhost",
    "user": "root",
    "password": "123456",
    "database": "xzs",
    "charset": "utf8mb4",
    "client_flag": pymysql.constants.CLIENT.MULTI_STATEMENTS,
}

sql_files = [
    "database/current/01_init_structure.sql",
    "database/current/02_extend_fields.sql",
    "database/current/04_exam_data.sql",
    "database/current/05_rag_embeddings.sql",
    "database/current/06_ai_knowledge_rag.sql",
    "database/current/07_demo_student_learning_data.sql",
    "database/current/08_clean_knowledge_display_noise.sql",
]

conn = pymysql.connect(**DB_CONFIG)
cursor = conn.cursor()

for sql_file in sql_files:
    print(f"导入 {sql_file} ...")
    with open(sql_file, "r", encoding="utf-8") as f:
        sql_content = f.read()
    try:
        cursor.execute(sql_content)
        conn.commit()
        print(f"  成功")
    except Exception as e:
        print(f"  错误: {e}")
        conn.rollback()

cursor.close()
conn.close()
print("全部导入完成")
