# database/current

当前分支部署必需 SQL，只保留可进入正常初始化流程的脚本。

## 导入顺序

```bash
mysql -u root -p xzs < database/current/01_init_structure.sql
mysql -u root -p xzs < database/current/02_extend_fields.sql
mysql -u root -p xzs < database/current/04_exam_data.sql
mysql -u root -p xzs < database/current/05_rag_embeddings.sql
mysql -u root -p xzs < database/current/06_ai_knowledge_rag.sql
mysql -u root -p xzs < database/current/07_demo_student_learning_data.sql
mysql -u root -p xzs < database/current/08_clean_knowledge_display_noise.sql
mysql -u root -p xzs < database/current/09_rename_legacy_brand_logs.sql
```

## 文件说明

| 文件 | 说明 |
|---|---|
| `01_init_structure.sql` | 核心表结构。 |
| `02_extend_fields.sql` | 408 真题扩展字段、综合题表。 |
| `04_exam_data.sql` | 题目、试卷、用户、科目等数据。 |
| `05_rag_embeddings.sql` | 题目内容 embedding 字段。 |
| `06_ai_knowledge_rag.sql` | AI 知识库、RAG 字段、学生画像、学习事件、Skill 反馈。 |
| `07_demo_student_learning_data.sql` | `231310423` 测试账号默认做题记录，用于学习状态、做题记录和错题本演示。 |
| `08_clean_knowledge_display_noise.sql` | 清理知识目录根节点中的爬虫图例残留，避免页面展示 A/B/C/D/E 等噪声。 |
| `09_rename_legacy_brand_logs.sql` | 替换用户动态中的旧系统品牌名。 |

408 知识点页面数据不在 SQL 中直接全量展开，使用 `crawler/knowledge_crawler.py --skip-crawl --import-db --clear-existing` 从 `crawler/data/knowledge_pages.json` 导入。
