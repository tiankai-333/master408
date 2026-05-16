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
    "database/01_init_structure.sql",
    "database/02_extend_fields.sql",
    "database/04_exam_data.sql",
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
