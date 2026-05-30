# database/current

当前分支部署必需的 SQL 文件。

## 快速初始化

```bash
# 依次执行：建表 → 种子数据 → 业务数据
mysql -u root -p xzs < database/current/01_schema.sql
mysql -u root -p xzs < database/current/02_seed.sql
mysql -u root -p xzs < database/current/03_questions_and_exams.sql
mysql -u root -p xzs < database/current/04_knowledge_and_rag.sql
mysql -u root -p xzs < database/current/05_student_data.sql
```

或一键全量导入（合并文件）：

```bash
cat database/current/0{1,2,3,4,5}_*.sql | mysql -u root -p xzs
```

## 文件说明

| 文件 | 说明 | 大小 |
|---|---|---|
| `01_schema.sql` | 所有 41 张表的 CREATE TABLE（纯结构，无数据） | ~49 KB |
| `02_seed.sql` | 种子/配置数据：科目、AI配置、用户、Agent、Prompt模板 | ~7 KB |
| `03_questions_and_exams.sql` | 题目与试卷（核心业务数据） | ~2.8 MB |
| `04_knowledge_and_rag.sql` | 知识点、RAG 向量、AI知识库 | ~3.7 MB |
| `05_student_data.sql` | 学生学习状态、事件、错题本（大部分表为空） | ~9 KB |

## 数据概览

| 表 | 行数 | 说明 |
|---|---|---|
| t_question | 650 | 题目 |
| t_text_content | 669 | 题目文本内容 |
| t_exam_paper | 18 | 试卷 |
| t_subject | 5 | 科目 |
| knowledge_point | 116 | 知识点 |
| t_ai_knowledge_base | 98 | AI 知识库 |
| question_content | 640 | 规范化题目内容 |
| rag_document / rag_chunk | 119 / 81 | RAG 向量检索 |
| ai_provider_config | 3 | AI 供应商配置 |
| t_user | 4 | 用户（含 test/123456 测试账号） |

## 历史文件

- `00_full_snapshot.sql` — 拆分前的全量快照，验证后可删除
- `database/archive/` — 旧的增量迁移文件（00-23 编号），仅增量升级时使用
