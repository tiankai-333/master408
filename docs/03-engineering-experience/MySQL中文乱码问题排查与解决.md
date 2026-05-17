# MySQL中文乱码问题排查与解决

## 问题现象

在管理端页面中，题目列表显示如下乱码：

| 学科 | 题干 |
|------|------|
| ????? (??) | ARP??????IP?????MAC??? |
| ????? (??) | ???192.168.5.0/24???5?????????18??????????? |

## 问题排查流程

### 步骤1：检查数据库字符集配置

```bash
mysql -u root -p -D xzs -e "SHOW VARIABLES LIKE 'character%';"
```

**结果**：
```
+--------------------------+---------------------------------------------------------+
| Variable_name            | Value                                               |
+--------------------------+---------------------------------------------------------+
| character_set_client     | utf8mb4                                            |
| character_set_connection | utf8mb4                                            |
| character_set_database   | utf8mb4                                            |
| ...                      | ...                                                  |
+--------------------------+---------------------------------------------------------+
```

**结论**：数据库本身的字符集配置是正确的（utf8mb4）。

---

### 步骤2：检查表的字符集

```bash
mysql -u root -p -D xzs -e "SHOW CREATE TABLE t_question;"
```

**结果**：
```sql
CREATE TABLE `t_question` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '??ID',
  `question_type` int DEFAULT NULL COMMENT '???1=??, 2=??, 3=??, 4=??, 5=??',
  ...
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='???'
```

**结论**：表的字符集也是 utf8mb4，正确。

---

### 步骤3：检查后端连接配置

检查 `application-dev.yml`：

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/xzs?useSSL=false&useUnicode=true&serverTimezone=Asia/Shanghai&characterEncoding=UTF-8&...&connectionCollation=utf8mb4_unicode_ci
```

**结论**：后端连接配置也正确指定了 UTF-8 编码。

---

### 步骤4：检查实际存储的数据

```bash
mysql -u root -p -D xzs -e "SELECT * FROM t_subject LIMIT 5;"
```

**结果**：
```
+-----+---------+-------+------------+------------+------------------+
| id  | name    | level | level_name | item_order | deleted          |
+-----+---------+-------+------------+------------+------------------+
| 100 | ????    |     1 | ???        |          1 | 0x00             |
| 101 | ????    |     2 | ??         |          2 | 0x00             |
+-----+---------+-------+------------+------------+------------------+
```

**关键发现**：数据存储时就已经是乱码了！问题出在**数据导入环节**，而不是数据库配置。

---

## 根本原因

### 问题出在哪里？

之前使用命令行导入 SQL 数据时：

```bash
# ❌ 错误的导入方式（可能导致乱码）
mysql -u root -p -D xzs < data.sql

# 或者
mysql -u root -p -D xzs -e "INSERT INTO ... VALUES ('中文内容');"
```

**问题原因**：
1. **PowerShell 编码问题**：Windows PowerShell 的默认编码不是 UTF-8
2. **MySQL 客户端默认编码**：命令行执行时 MySQL 客户端可能使用系统默认编码（GBK）而不是 UTF-8
3. **`$` 符号特殊含义**：PowerShell 中 `$` 开头的字符会被当作变量解析，导致 BCrypt 密码（`$2a$10$...`）被截断

---

### 验证：BCrypt 密码被截断的例子

**生成的正确密码**：
```
$2b$10$YmEni5TRXVO5yjpXJiXbcu2auSC07D4LQ9U.Unaq1V.wE7Emr18EG
```

**PowerShell 执行后实际存储的密码**：
```
.Unaq1V.wE7Emr18EG
```

**原因**：`$2b$10$YmEni5TRXVO5yjpXJiXbcu` 被 PowerShell 当作变量解析了，因为 `$` 是变量前缀。

---

## 解决方案

### 方案1：使用 `--default-character-set=utf8mb4` 参数

```bash
# ✅ 正确的导入方式
mysql -u root -p123456 --default-character-set=utf8mb4 -D xzs < data.sql
```

### 方案2：使用 `source` 命令

```bash
mysql -u root -p123456 --default-character-set=utf8mb4 -D xzs -e "source c:/path/to/data.sql"
```

### 方案3：使用 Python 脚本（推荐）

对于包含复杂字符（如 `$`）的内容，使用 Python 脚本更安全：

```python
import subprocess

with open('data.sql', 'r', encoding='utf-8') as f:
    sql_content = f.read()

result = subprocess.run(
    ['mysql', '-u', 'root', '-p123456', '--default-character-set=utf8mb4', '-D', 'xzs'],
    input=sql_content,
    capture_output=True, text=True
)
print(result.stdout)
```

---

## 本次修复的具体操作

### 1. 重新导入题目数据

```bash
mysql -u root -p123456 --default-character-set=utf8mb4 -D xzs -e "source c:/Dev/Workspaces/master408/sql/add_2024_exam.sql"
```

### 2. 清理旧乱码数据

```sql
DELETE FROM t_question WHERE id < 2000;
```

### 3. 修复学科表数据

使用 Python 脚本更新学科表：

```python
import subprocess

sql = """
UPDATE t_subject SET name = '数据结构', level_name = '一级' WHERE id = 100;
UPDATE t_subject SET name = '数据结构', level_name = '二级' WHERE id = 101;
UPDATE t_subject SET name = '数据结构', level_name = '三级' WHERE id = 102;
UPDATE t_subject SET name = '计算机组成原理', level_name = '一级' WHERE id = 103;
UPDATE t_subject SET name = '计算机组成原理', level_name = '二级' WHERE id = 104;
UPDATE t_subject SET name = '计算机组成原理', level_name = '三级' WHERE id = 105;
UPDATE t_subject SET name = '操作系统', level_name = '一级' WHERE id = 106;
UPDATE t_subject SET name = '操作系统', level_name = '二级' WHERE id = 107;
UPDATE t_subject SET name = '操作系统', level_name = '三级' WHERE id = 108;
UPDATE t_subject SET name = '计算机网络', level_name = '一级' WHERE id = 109;
UPDATE t_subject SET name = '计算机网络', level_name = '二级' WHERE id = 110;
UPDATE t_subject SET name = '计算机网络', level_name = '三级' WHERE id = 111;
"""

with open('fix_subject.sql', 'w', encoding='utf-8') as f:
    f.write(sql)

result = subprocess.run(
    ['mysql', '-u', 'root', '-p123456', '--default-character-set=utf8mb4', '-D', 'xzs'],
    stdin=open('fix_subject.sql', 'r', encoding='utf-8'),
    capture_output=True, text=True
)
```

---

## 总结：排查乱码问题的通用步骤

### 排查顺序

| 步骤 | 检查内容 | 命令/方法 |
|------|----------|-----------|
| 1 | 数据库字符集 | `SHOW VARIABLES LIKE 'character%';` |
| 2 | 表字符集 | `SHOW CREATE TABLE 表名;` |
| 3 | 后端连接配置 | 检查 `characterEncoding=UTF-8` |
| 4 | **实际存储的数据** | `SELECT 中文列 FROM 表名 LIMIT 1;` |

### 关键经验

**乱码问题大多出在数据传输环节，而不是数据库配置本身。**

在 Windows PowerShell 环境下执行 MySQL 命令时，务必：
1. 添加 `--default-character-set=utf8mb4` 参数
2. 避免直接在命令行中包含 `$` 等特殊字符
3. 优先使用 `source` 命令或 Python 脚本导入数据

---

## 参考资料

- [MySQL 8.0 字符集配置](https://dev.mysql.com/doc/refman/8.0/en/charset-unicode.html)
- [PowerShell 编码问题](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_character_encoding)
