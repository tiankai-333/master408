# database/current

当前分支部署必需 SQL，只保留可进入正常初始化流程的脚本。

## 导入顺序

```bash
mysql -u root -p xzs < database/current/01_init_structure.sql
mysql -u root -p xzs < database/current/02_extend_fields.sql
mysql -u root -p xzs < database/current/04_exam_data.sql
mysql -u root -p xzs < database/current/05_rag_embeddings.sql
mysql -u root -p xzs < database/current/06_ai_knowledge_rag.sql
mysql -u root -p xzs < database/current/10_knowledge_points_data.sql
mysql -u root -p xzs < database/current/07_demo_student_learning_data.sql
mysql -u root -p xzs < database/current/08_clean_knowledge_display_noise.sql
mysql -u root -p xzs < database/current/09_rename_legacy_brand_logs.sql
mysql -u root -p xzs < database/current/11_default_user_level.sql
mysql -u root -p xzs < database/current/12_canonical_ai_architecture.sql
mysql -u root -p xzs < database/current/13_backfill_canonical_ai_data.sql
mysql -u root -p xzs < database/current/14_ai_provider_config.sql
```

## 文件说明

| 文件 | 说明 |
|---|---|
| `01_init_structure.sql` | 核心表结构。 |
| `02_extend_fields.sql` | 408 真题扩展字段、综合题表。 |
| `04_exam_data.sql` | 题目、试卷、用户、科目等数据。 |
| `05_rag_embeddings.sql` | 题目内容 embedding 字段。 |
| `06_ai_knowledge_rag.sql` | AI 知识库、RAG 字段、学生画像、学习事件、Skill 反馈。 |
| `10_knowledge_points_data.sql` | 408 知识点目录与 AI 知识库内容，包含爬虫导入后本地已验证的数据。 |
| `07_demo_student_learning_data.sql` | `231310423` 测试账号默认做题记录，用于学习状态、做题记录和错题本演示。 |
| `08_clean_knowledge_display_noise.sql` | 清理知识目录根节点中的爬虫图例残留，避免页面展示 A/B/C/D/E 等噪声。 |
| `09_rename_legacy_brand_logs.sql` | 替换用户动态中的旧系统品牌名。 |
| `11_default_user_level.sql` | 学生注册默认年级兜底，兼容取消年级后的旧字段约束。 |
| `12_canonical_ai_architecture.sql` | 新增规范题目内容、RAG 元数据、学生图谱、Agent/Skill/Tool 表。 |
| `13_backfill_canonical_ai_data.sql` | 从旧题库和 AI 知识库幂等回填规范层。 |
| `14_ai_provider_config.sql` | 管理端 AI 供应商密钥配置表和默认供应商种子。 |

`10_knowledge_points_data.sql` 让云端部署不依赖额外运行爬虫。需要重新抓取或刷新数据时，再使用 `crawler/knowledge_crawler.py --skip-crawl --import-db --clear-existing` 从 `crawler/data/knowledge_pages.json` 导入本地库，并重新导出该 SQL。

新增 AI 架构采用渐进兼容方式：旧 `t_question`、`t_text_content`、`t_ai_knowledge_base` 继续保留；新代码应优先读 `question_content`、`rag_document`、`rag_chunk`、`student_*`、`ai_agent/ai_skill` 等规范表。
