import pymysql

conn = pymysql.connect(host='localhost', user='root', password='123456', database='xzs', charset='utf8mb4')
cur = conn.cursor()

cur.execute("SHOW COLUMNS FROM t_exam_paper_answer")
print("=== t_exam_paper_answer columns ===")
for row in cur.fetchall():
    print(f"  {row[0]:30s} {row[1]:15s} {row[2]:5s} {row[3] or ''}")

cur.execute("SELECT COUNT(*) FROM t_exam_paper_answer")
print(f"\nrow count: {cur.fetchone()[0]}")

conn.close()
