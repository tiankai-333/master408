# database/current

当前分支部署必需 SQL，只保留可进入正常初始化流程的脚本。

## 导入顺序

一键本地初始化可以直接执行：

```bash
mysql -u root -p xzs < database/current/00_init_database_with_seed.sql
```

脚本会创建完整表结构、导入种子题库/知识库，并创建测试账号 `test / 123456` 及默认做题记录。

手动分步导入顺序如下：

```bash
mysql -u root -p xzs < database/current/01_init_structure.sql
mysql -u root -p xzs < database/current/02_extend_fields.sql
mysql -u root -p xzs < database/current/04_exam_data.sql
mysql -u root -p xzs < database/current/05_rag_embeddings.sql
mysql -u root -p xzs < database/current/06_ai_knowledge_rag.sql
mysql -u root -p xzs < database/current/10_knowledge_points_data.sql
mysql -u root -p xzs < database/current/08_clean_knowledge_display_noise.sql
mysql -u root -p xzs < database/current/11_default_user_level.sql
mysql -u root -p xzs < database/current/12_canonical_ai_architecture.sql
mysql -u root -p xzs < database/current/13_backfill_canonical_ai_data.sql
mysql -u root -p xzs < database/current/14_ai_provider_config.sql
mysql -u root -p xzs < database/current/15_embed_question_images.sql
mysql -u root -p xzs < database/current/16_import_2026_html_mock_exam.sql
mysql -u root -p xzs < database/current/17_import_csgraduates_html_exams.sql
mysql -u root -p xzs < database/current/18_generate_408_subject_papers.sql
mysql -u root -p xzs < database/current/19_import_408_knowledge_html.sql
mysql -u root -p xzs < database/current/07_demo_student_learning_data.sql
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
| `00_init_database_with_seed.sql` | 一键初始化入口，串联当前目录的结构、种子题库、HTML 真题、知识点和测试账号记录。 |
| `07_demo_student_learning_data.sql` | `test / 123456` 测试账号默认做题记录，用于学习状态、做题记录和错题本演示；同时清理旧 `231310423` 测试账号。 |
| `08_clean_knowledge_display_noise.sql` | 清理知识目录根节点中的爬虫图例残留，避免页面展示 A/B/C/D/E 等噪声。 |
| `11_default_user_level.sql` | 学生注册默认年级兜底，兼容取消年级后的旧字段约束。 |
| `12_canonical_ai_architecture.sql` | 新增规范题目内容、RAG 元数据、学生图谱、Agent/Skill/Tool 表。 |
| `13_backfill_canonical_ai_data.sql` | 从旧题库和 AI 知识库幂等回填规范层。 |
| `14_ai_provider_config.sql` | 管理端 AI 供应商密钥配置表和默认供应商种子。 |
| `15_embed_question_images.sql` | 将题目 images 列路径转为 `<img>` 标签追加到 title，同步 question_content。 |
| `16_import_2026_html_mock_exam.sql` | 导入 2026 HTML 模拟卷。数据库仅保存 HTML 引用、纯文本和内容标签，完整 HTML 片段由学生端静态资源 `question-html/2026/` 提供。 |
| `17_import_csgraduates_html_exams.sql` | 导入 CSGraduates 真题、模拟卷、数学、英语、政治 HTML 题库。 |
| `18_generate_408_subject_papers.sql` | 生成 408 四科近年专项卷。 |
| `19_import_408_knowledge_html.sql` | 导入 408 四科知识点 HTML 轻引用和本地资产索引。 |

`10_knowledge_points_data.sql` 让云端部署不依赖额外运行爬虫。需要重新抓取或刷新数据时，再使用 `crawler/knowledge_crawler.py --skip-crawl --import-db --clear-existing` 从 `crawler/data/knowledge_pages.json` 导入本地库，并重新导出该 SQL。

新增 AI 架构采用渐进兼容方式：旧 `t_question`、`t_text_content`、`t_ai_knowledge_base` 继续保留；新代码应优先读 `question_content`、`rag_document`、`rag_chunk`、`student_*`、`ai_agent/ai_skill` 等规范表。
