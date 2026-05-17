# database

数据库脚本目录。当前已经按用途整理成三类：`current/` 是当前分支部署必需 SQL，`archive/` 是历史/实验脚本，`tests/` 是测试数据脚本。

## 目录结构

| 目录 | 说明 |
|---|---|
| `current/` | 当前 `codex/ai-knowledge-rag` 分支推荐导入脚本。部署只应优先使用这里。 |
| `archive/legacy-knowledge/` | 历史知识体系实验脚本，包含旧表名如 `t_knowledge_point`、`t_question_vector`，当前代码不依赖。 |
| `archive/backups/` | 历史数据库备份，保留作追溯，不建议直接导入当前环境。 |
| `tests/` | 局部测试数据，例如 NPE 复现/验证脚本。 |

## 当前导入顺序

全新环境按以下顺序导入：

| 顺序 | 文件 | 说明 |
|---|---|---|
| 1 | `current/01_init_structure.sql` | 主表结构。 |
| 2 | `current/02_extend_fields.sql` | 408 真题扩展字段和综合题表。 |
| 3 | `current/04_exam_data.sql` | 2011-2024 真题、试卷、用户、科目等基础数据。 |
| 4 | `current/05_rag_embeddings.sql` | `t_text_content.embedding` 字段。 |
| 5 | `current/06_ai_knowledge_rag.sql` | AI 知识库向量字段、学生画像、学习事件、Skill 反馈、方法论摘要。 |

推荐命令：

```bash
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS xzs DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci"

mysql -u root -p xzs < database/current/01_init_structure.sql
mysql -u root -p xzs < database/current/02_extend_fields.sql
mysql -u root -p xzs < database/current/04_exam_data.sql
mysql -u root -p xzs < database/current/05_rag_embeddings.sql
mysql -u root -p xzs < database/current/06_ai_knowledge_rag.sql
```

也可以使用根目录脚本：

```bash
python import_db.py
```

> Windows PowerShell 不要用 `Get-Content | mysql` 导入中文 SQL，容易乱码。优先使用 `import_db.py` 或 MySQL 原生命令。

## 知识点爬虫导入

`current/06_ai_knowledge_rag.sql` 只创建 AI/RAG 结构和方法论摘要。408 四科 116 条知识点页面需要通过爬虫快照导入：

```bash
python3 crawler/knowledge_crawler.py \
  --skip-crawl \
  --import-db \
  --clear-existing \
  --db-host 127.0.0.1 \
  --db-port 3306 \
  --db-user root \
  --db-password '123456' \
  --db-name xzs \
  --output crawler/data/knowledge_pages.json
```

导入后验证：

```sql
SELECT source_type, COUNT(*) FROM t_ai_knowledge_base GROUP BY source_type;
SELECT COUNT(*) AS knowledge_points FROM knowledge_point;
```

预期至少看到：

- `csgraduates` 约 116 条
- `method_summary` 约 3 条

## 当前数据概览

| 数据 | 数量/说明 |
|---|---|
| 真题年份 | 2011-2024 |
| 试卷 | 14 份 |
| 选择题 | 约 560 道入库真题选择题 |
| 综合应用题 | 98 道 |
| 科目 | 数据结构、组成原理、操作系统、计算机网络、408 综合 |
| 常用用户 | `admin`、`student`、`teacher`、`231310423` |
| AI 知识库 | 方法论摘要由 SQL 写入，408 知识点由爬虫导入 |

## 核心表说明

| 表 | 作用 |
|---|---|
| `t_subject` | 科目。 |
| `t_text_content` | 题干、解析、试卷框架 JSON。 |
| `t_question` | 题目元数据，含年份、题号、标签、图片路径。 |
| `t_essay_question` | 综合应用题原始结构化数据。 |
| `t_exam_paper` | 试卷。 |
| `knowledge_point` | 当前代码使用的知识点表，无 `t_` 前缀。 |
| `question_knowledge_point` | 题目-知识点关联表，无 `t_` 前缀。 |
| `t_ai_knowledge_base` | RAG 文档库。 |
| `t_user_learning_profile` | 学生画像。 |
| `t_user_learning_event` | 学习事件。 |
| `t_user_skill_feedback` | Skill 反馈。 |

## 常用账号

| 用户名 | 密码 | 角色 |
|---|---|---|
| `admin` | `123456` | 管理员 |
| `student` | `123456` | 学生 |
| `teacher` | `123456` | 教师 |
| `231310423` | `123456` | 学生测试账号 |

## 验证 SQL

```sql
SELECT question_type, COUNT(*) FROM t_question GROUP BY question_type;
SELECT source, COUNT(*) FROM t_question GROUP BY source ORDER BY source;
SELECT id, name, score, question_count FROM t_exam_paper ORDER BY source_year DESC LIMIT 5;
SELECT source_type, COUNT(*) FROM t_ai_knowledge_base GROUP BY source_type;
```

检查悬空引用：

```sql
SELECT 'exam_paper->text_content' AS ck, COUNT(*) AS dangling
FROM t_exam_paper ep
LEFT JOIN t_text_content tc ON ep.frame_text_content_id = tc.id
WHERE tc.id IS NULL AND ep.frame_text_content_id IS NOT NULL
UNION ALL
SELECT 'question->text_content', COUNT(*)
FROM t_question q
LEFT JOIN t_text_content tc ON q.info_text_content_id = tc.id
WHERE tc.id IS NULL AND q.info_text_content_id IS NOT NULL
UNION ALL
SELECT 'question->subject', COUNT(*)
FROM t_question q
LEFT JOIN t_subject s ON q.subject_id = s.id
WHERE s.id IS NULL AND q.subject_id IS NOT NULL;
```

## 归档脚本说明

`archive/legacy-knowledge/` 中的脚本来自早期知识系统设计，创建的是旧表体系，例如：

- `t_knowledge_point`
- `t_question_knowledge`
- `t_question_vector`
- `t_question_ai_analysis`
- `t_user_learning_behavior`
- `t_user_learning_session`

当前代码主线已经改为使用 `knowledge_point`、`question_knowledge_point` 和 `t_ai_knowledge_base`。因此这些脚本只作历史参考，不应在当前部署流程中默认执行。

`archive/backups/xzs-20260515.sql` 是历史备份，包含旧版数据和部分乱码内容，只作追溯，不建议直接恢复到当前环境。

`tests/test_npe_data.sql` 是异常场景测试数据，不应导入生产环境。
