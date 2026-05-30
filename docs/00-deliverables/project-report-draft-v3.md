# 408Master 智能学习平台项目报告

## 1. 项目概述

### 1.1 项目背景

本项目基于开源考试系统 xzs（学之思）进行二次开发。原系统主要面向常规在线考试场景，提供题目管理、试卷管理、答题记录和用户管理等基础功能。

为适配 408 计算机考研学习场景，我在原系统基础上完成了以下主要工作：

1. **数据库结构扩展**：为 `t_question` 表增加 16 个扩展字段（`title`、`options`、`correct_answer`、`analysis`、`images` 等），新增知识点关联表、AI 配置表、RAG 索引表、学习档案表等共计约 20 张新表。
   - 代码位置：`database/current/02_extend_fields.sql`、`database/current/01_init_structure.sql`、`database/current/12_canonical_ai_architecture.sql`

2. **题库数据采集与导入**：通过 Python 爬虫从公开考研网站抓取 408 真题数据（约 560 道选择题、98 道综合题、658 条知识标签、228 个 HTML 真题源文件），并编写 SQL 生成脚本导入数据库。
   - 代码位置：`crawler/main.py`、`crawler/generate_sql.py`、`database/current/04_exam_data.sql`

3. **AI 解析能力接入**：实现四种 AI 解析风格（标准解析、费曼学习法、第一性原理、柏拉图式对话），支持 SSE 流式输出，后端统一管理 API 密钥。
   - 代码位置：`source/xzs/src/main/java/com/mindskip/xzs/ai/AnalysisService.java`、`source/xzs/src/main/resources/ai/prompts/analysis/`

4. **RAG 检索增强**：集成 Qdrant 向量数据库，使用 GLM Embedding-2 模型生成文本向量（维度由 API 返回值动态决定），支持题目解析的语义检索。
   - 代码位置：`source/xzs/src/main/java/com/mindskip/xzs/ai/RagService.java`、`scripts-embedding/embed_rag_chunks_to_qdrant.py`

5. **前端完整迁移至 Vue 3**：管理端（xzs-admin）和学生端（xzs-student）均已从 Vue 2 完整迁移到 Vue 3 + Vite + Element Plus + Pinia。
   - 代码位置：`source/vue/xzs-admin/`（Vue 3.4.31）、`source/vue/xzs-student/`（Vue 3.5.13）

6. **微信小程序端开发**：基于微信小程序原生开发，包含 16 个页面，支持做题、错题本、AI 图片识题等功能。
   - 代码位置：`source/wx/xzs-student/`

7. **Docker 部署适配**：编写 Dockerfile、docker-compose.yml 和 Nginx 配置，支持容器化部署。
   - 代码位置：`deploy/Dockerfile`、`deploy/docker-compose.yml`、`deploy/nginx.conf`

### 1.2 项目目标

本项目的目标是构建一个面向 408 考研复习的智能学习平台，在保留原有考试功能的基础上，扩展以下能力：

1. 大规模 408 题库数据管理（支持 HTML 题干、图片、复杂选项）；
2. AI 多风格题目解析与知识点讲解；
3. 基于向量检索的 RAG 增强回答；
4. AI 学习工作台（整合知识点浏览、题目练习、AI 对话）；
5. Web 端与微信小程序端共享同一套后端接口；
6. Docker 容器化部署，支持迁移到云服务器。

---

## 2. 原开源系统与数据库改造说明

### 2.1 原系统数据库设计

原开源系统 xzs 围绕传统在线考试业务设计，核心表结构如下：

| 表名 | 用途 | 代码位置 |
|-----|------|---------|
| `t_user` | 用户信息 | `01_init_structure.sql:34` |
| `t_subject` | 科目管理 | `01_init_structure.sql:63` |
| `t_text_content` | 文本内容（JSON） | `01_init_structure.sql:78` |
| `t_question` | 题目 | `01_init_structure.sql:89` |
| `t_exam_paper` | 试卷 | `01_init_structure.sql:112` |
| `t_task_exam` | 任务考试 | `01_init_structure.sql:138` |
| `t_exam_paper_answer` | 试卷答题记录 | `01_init_structure.sql:154` |
| `t_exam_paper_question_customer_answer` | 答题详情 | `01_init_structure.sql:180` |
| `t_task_exam_customer_answer` | 任务考试答题 | `01_init_structure.sql:205` |
| `t_message` / `t_message_user` | 消息系统 | `01_init_structure.sql:218-247` |
| `t_user_event_log` | 用户事件日志 | `01_init_structure.sql:253` |
| `t_user_token` | 用户Token | `01_init_structure.sql:268` |

原系统没有独立的"错题本表"。错题功能通过查询 `t_exam_paper_question_customer_answer` 表中 `do_right` 字段（`bit(1)` 类型）为 false 的记录实现。

### 2.2 原系统存在的问题

1. **题目数据结构单一**：原 `t_question` 表仅通过 `info_text_content_id` 关联 `t_text_content` 存储题目 JSON，缺少 `title`（题干 HTML）、`options`（选项）、`correct_answer`（正确答案）、`analysis`（解析）等独立字段，无法直接支持复杂题干和图片题。

2. **缺少知识点关联**：原系统没有知识点表和题目-知识点关联表，无法按知识点维度组织题库。

3. **缺少 AI 功能支持**：原系统没有 AI 配置表、Prompt 模板表、使用日志表等，无法支持 AI 解析和 RAG 功能。

4. **图片资源无统一管理**：原系统没有图片路径字段和静态资源服务配置。

### 2.3 数据库修改方案

#### 2.3.1 为支持 408 题库的修改

通过 `02_extend_fields.sql` 为 `t_question` 增加以下 16 个字段：

| 字段名 | 类型 | 用途 | 代码位置 |
|--------|------|------|---------|
| `title` | TEXT | 题目内容（HTML 格式） | `02_extend_fields.sql:11` |
| `options` | TEXT | 选项 JSON | `02_extend_fields.sql:12` |
| `correct_answer` | TEXT | 正确答案 | `02_extend_fields.sql:13` |
| `analysis` | TEXT | 解析（HTML 格式） | `02_extend_fields.sql:14` |
| `difficulty` | INT | 难度等级（1=简单/2=中等/3=困难） | `02_extend_fields.sql:15` |
| `knowledge_point` | VARCHAR(200) | 知识点 | `02_extend_fields.sql:16` |
| `source` | VARCHAR(100) | 来源（如"2024年408真题"） | `02_extend_fields.sql:17` |
| `source_year` | INT | 来源年份 | `02_extend_fields.sql:18` |
| `source_question_no` | INT | 原始题号（1-47） | `02_extend_fields.sql:19` |
| `tags` | TEXT | 知识标签（逗号分隔） | `02_extend_fields.sql:20` |
| `images` | TEXT | 图片路径 | `02_extend_fields.sql:21` |
| `title_text` | TEXT | 题目纯文本 | `02_extend_fields.sql:22` |
| `analysis_text` | TEXT | 解析纯文本 | `02_extend_fields.sql:23` |
| `content_format` | VARCHAR(20) | 内容格式（html/markdown/plain） | `02_extend_fields.sql:24` |
| `has_image` | BIT(1) | 是否包含图片 | `02_extend_fields.sql:25` |
| `has_code` | BIT(1) | 是否包含代码 | `02_extend_fields.sql:26` |

为 `t_exam_paper` 增加 `source_year`（`02_extend_fields.sql:32`）和 `description`（`02_extend_fields.sql:33`）字段。

新增 `t_essay_question` 表用于存储综合应用题（爬虫数据），代码位置：`02_extend_fields.sql:39-52`。

#### 2.3.2 为支持知识点系统的修改

| 新增表 | 用途 | 代码位置 |
|--------|------|---------|
| `knowledge_point` | 知识点表（支持父子层级，`parent_id` 自引用） | `01_init_structure.sql:286` |
| `question_knowledge_point` | 题目-知识点多对多关联（含 `relevance` 权重字段） | `01_init_structure.sql:307` |

#### 2.3.3 为支持 AI/RAG 的修改

**基础 AI 表**（`01_init_structure.sql`）：

| 新增表 | 用途 | 代码位置 |
|--------|------|---------|
| `t_ai_usage_log` | AI 调用使用日志（含 token 用量、费用、耗时） | `01_init_structure.sql:321` |
| `t_ai_prompt_template` | DB 级 Prompt 模板 | `01_init_structure.sql:382` |
| `t_ai_knowledge_base` | AI 知识库（含 RAG 向量字段） | `01_init_structure.sql:351` |
| `t_ai_adjustment_log` | 模板调整审计日志 | `01_init_structure.sql:414` |

**AI 服务商配置**：

| 新增表 | 用途 | 代码位置 |
|--------|------|---------|
| `ai_provider_config` | AI 服务商密钥配置（密钥加密存储） | `14_ai_provider_config.sql` |
| `ai_user_key` | 用户私钥（BYOK，加密存储） | `deploy/sql/ai_user_key.sql` |

**RAG 向量存储**：

| 修改/新增 | 用途 | 代码位置 |
|-----------|------|---------|
| `t_text_content` 增加 `embedding` 列 | 题目解析向量（LONGTEXT, JSON float[]） | `05_rag_embeddings.sql:16` |
| `t_ai_knowledge_base` 增加 RAG 字段 | embedding, embedding_model, embedding_dimension, chunk_index, content_hash | `06_ai_knowledge_rag.sql:10-74` |

**规范化 RAG 索引表**（`12_canonical_ai_architecture.sql`）：

| 新增表 | 用途 | 代码位置 |
|--------|------|---------|
| `rag_document` | RAG 文档元数据 | `12_canonical_ai_architecture.sql:153` |
| `rag_chunk` | RAG 文本分块 | `12_canonical_ai_architecture.sql:177` |
| `rag_embedding` | 向量索引元数据 | `12_canonical_ai_architecture.sql:197` |
| `question_content` | 题目内容版本化管理 | `12_canonical_ai_architecture.sql:10` |
| `question_source` | 题目来源追踪 | `12_canonical_ai_architecture.sql:51` |
| `ai_agent` / `ai_skill` / `ai_agent_skill` | AI Agent 与技能模块 | `12_canonical_ai_architecture.sql:251-284` |

#### 2.3.4 为支持学习档案的修改

| 新增表 | 用途 | 代码位置 |
|--------|------|---------|
| `t_user_learning_profile` | 学生学习画像 | `06_ai_knowledge_rag.sql:92` |
| `t_user_learning_event` | 学习事件流水 | `06_ai_knowledge_rag.sql:107` |
| `t_user_skill_feedback` | 用户对解析风格的反馈 | `06_ai_knowledge_rag.sql:123` |
| `student_learning_event` | 规范化学习事件 | `12_canonical_ai_architecture.sql:86` |
| `student_knowledge_state` | 学生知识点掌握状态 | `12_canonical_ai_architecture.sql:108` |
| `student_mistake_book` | 学生错题本（规范化） | `12_canonical_ai_architecture.sql:128` |

#### 2.3.5 为支持小程序端的修改

小程序端不需要修改数据库结构。小程序通过 `/api/wx/` 前缀的专用 Controller 访问与 Web 端相同的数据库。后端新增了 `controller/wx/student/` 包下的 7 个 WX 专用 Controller（AuthController、DashboardController、ExamPaperController、ExamPaperAnswerController、UserController、QuestionController、QuestionAnswerController），复用相同的 Service 和 Mapper 层。

代码位置：`source/xzs/src/main/java/com/mindskip/xzs/controller/wx/student/`

---

## 3. 数据部分设计

### 3.1 数据来源

本项目的 408 题库数据来自公开考研学习网站 csgraduates.com。通过 Python 爬虫程序抓取题目、选项、答案、解析、知识标签和图片等内容，经清洗后导入数据库。

在数据使用方面：
- 数据仅用于课程设计、学习研究和教学演示；
- 对原网站内容表示感谢；
- 不用于商业传播。

### 3.2 数据量

基于代码中数据文件的统计：

| 数据类型 | 数量 | 统计方式 | 数据来源文件 |
|---------|------|---------|------------|
| 选择题数据 | 约 560 道 | `exam_questions.json` 中 `"year"` 字段出现 560 次 | `crawler/data/exam_questions.json`（505KB） |
| 选择题 CSV | 930 行数据 | `wc -l` 统计 931 行（含表头） | `crawler/data/exam_questions.csv`（691KB） |
| 综合题数据 | 约 98 道 | `essay_questions.csv` 共 715 行（含表头） | `crawler/data/essay_questions.csv`（217KB） |
| 知识标签 | 658 条 | `knowledge_tags.json` 数组长度 | `crawler/data/knowledge_tags.json`（88KB） |
| HTML 真题源文件 | 228 个 | `find -name "*.html"` 递归统计 | `crawler/data/html-sources/csgraduates/` |
| 知识点 HTML | 4 科目录 | DS/CN/CO/OS 四个子目录 | `crawler/data/knowledge-html-sources/csgraduates/` |
| 题目图片（爬虫目录） | 15 个 | `find -type f` 统计 | `crawler/data/images/`（SVG/JPG 格式） |
| 综合题图片 | 2 个 | `find -type f` 统计 | `crawler/data/essay_images/` |
| 原始真题 PDF | 30 个 | `find -name "*.pdf"` 统计 | `crawler/真题pdf/`（2009-2024年） |

HTML 源文件覆盖范围：408 计算机真题（2009-2026）、数学一/二/三、英语一/二、政治等。

**注意**：选择题数据的精确数量取决于统计方式。JSON 文件中每条记录对应一道题目，`"year"` 字段出现 560 次，表明约 560 道题。CSV 文件 931 行包含表头和可能的空行。报告中选择"约 560 道"这一保守数字。

### 3.3 爬虫代码设计

爬虫代码位于 `crawler/` 目录，共 19 个 Python 脚本。

**入口文件**：`crawler/main.py`，支持命令行参数（`--exam-only`、`--knowledge-only`、`--subject`、`--start-year` 等）。

**核心脚本**：

| 脚本 | 功能 |
|------|------|
| `crawler.py` | 基础爬虫类 `CSGraduatesCrawler` |
| `crawl_all.py` | 统一爬取选择题和综合题 |
| `exam_crawler_with_images.py` | 带图片下载的题目爬取 |
| `generate_sql.py` | 将 JSON/CSV 转换为 SQL 导入脚本 |
| `generate_html_exam_sql.py` | 从 HTML 源生成 HTML 格式题目的 SQL |
| `generate_knowledge_html_sql.py` | 生成知识点 HTML 内容的 SQL |
| `crawl_tags.py` | 爬取知识标签并更新数据库 |

### 3.4 图片数据的存储与调用

**图片存储路径**：

```
deploy/static/images/{年份}/{题目号}.{svg|jpg}
```

实际文件示例（来自 `deploy/static/images/`）：
- `2012/2012_27.svg`、`2012/2012_29.svg`、`2012/2012_4.svg`、`2012/2012_44.svg`
- `2016/2016_4.svg`
- `2020/2020_41.svg`
- `2023/2023_19.jpg`

数据库 `t_question.images` 字段存储图片路径，不存储图片二进制内容。

**前端渲染**：前端通过 `QuestionHtml.vue` 组件渲染 HTML 题干，图片以 `<img>` 标签形式嵌入 HTML。此外 `15_embed_question_images.sql` 迁移脚本将 `images` 路径注入到 `title` 字段中。

Nginx 配置了 `/images/` 路径的静态资源服务（30 天缓存），代码位置：`deploy/nginx.conf:36-40`。

当前题目图片数量有限（共约 17 个 SVG/JPG 文件），主要涉及包含图表的计算机组成原理和计算机网络题目。

**支持的图片格式**：根据实际文件确认，包括 SVG 和 JPG。PNG 格式在爬虫的文件类型过滤中也被支持，但当前数据集中未出现 PNG 文件。

---

## 4. 功能实现

### 4.1 题目功能

**后端实现**：

| 层级 | 代码位置 | 说明 |
|------|---------|------|
| Controller | `controller/admin/QuestionController.java` | 管理端：`POST /page` 分页查询、`POST /edit` 创建编辑、`POST /delete/{id}` 删除、`POST /upload/txt` 文本导入、`POST /upload` JSON 批量导入 |
| Controller | `controller/student/QuestionController.java` | 学生端：`POST /select/{id}` 查看详情、`POST /analyze-image` 图片识题、`POST /analyze-question` AI 分析、`POST /analyze-question-stream` SSE 流式分析 |
| Service | `service/QuestionService.java` | 题目 CRUD + `analyzeImageQuestion(MultipartFile)` + `analyzeQuestion()` |
| Mapper | `repository/QuestionMapper.java` + `resources/mapper/QuestionMapper.xml` | MyBatis 数据访问，含 `selectForAiPaper`、`selectMistakesForAiPaper` 等专用查询 |
| Domain | `domain/Question.java` | 实体类 |

**前端实现**：

管理端支持 5 种题型的独立编辑器（`questionType` 1-5）：单选题（`single-choice.vue`）、多选题（`multiple-choice.vue`）、判断题（`true-false.vue`）、填空题（`gap-filling.vue`）、简答题（`short-answer.vue`）。
- 代码位置：`source/vue/xzs-admin/src/views/exam/question/edit/` 下 5 个 `.vue` 文件

学生端在试卷答题页面 (`/do`) 和错题本页面 (`/question/index`) 中查看题目。

### 4.2 试卷功能

**后端实现**：

| 接口路径 | Controller | 说明 |
|---------|-----------|------|
| `POST /api/admin/exam/paper/page` | `ExamPaperController`（admin） | 管理端试卷分页列表 |
| `POST /api/student/exam/paper/pageList` | `ExamPaperController`（student） | 学生端试卷列表 |
| `POST /api/student/exam/paper/select/{id}` | `ExamPaperController`（student） | 学生端试卷详情 |
| `POST /api/student/exampaper/answer/answerSubmit` | `ExamPaperAnswerController`（student） | 提交答卷 |
| `POST /api/student/exampaper/answer/edit` | `ExamPaperAnswerController`（student） | 教师批改 |
| `POST /api/student/exampaper/answer/read/{id}` | `ExamPaperAnswerController`（student） | 查看答卷 |
| `POST /api/student/ai/compose-paper` | `AIAnalysisController` | AI 辅助组卷 |

**注意路径差异**：试卷操作使用 `/api/student/exam/paper/`（两个路径段），而答题操作使用 `/api/student/exampaper/answer/`（一个路径段 `exampaper`）。这是因为它们分别由不同的 Controller 处理。

除传统试卷管理外，系统还实现了 AI 辅助组卷功能：后端根据学生请求，从题库中筛选题目并生成练习试卷。
- 代码位置：`service/AiPaperComposeService.java`、`service/impl/AiPaperComposeServiceImpl.java`

### 4.3 错题本功能

错题本没有独立的数据库表，而是通过查询答题详情表筛选 `do_right = false` 的记录实现。`do_right` 字段类型为 `bit(1)`（`01_init_structure.sql:192`）。

**调用链**：
```
前端 views/question-error/index.vue
  → API questionAnswer.pageList()
    → POST /api/student/question/answer/page
      → QuestionAnswerController.pageList()
        → ExamPaperQuestionCustomerAnswerService.studentPage()
```

**AI 分析**：错题本页面集成了 AI 分析功能，支持四种解析风格，通过 SSE 流式输出分析结果。前端 API 调用 `analyzeQuestionStream()` 发送至 `POST /api/student/question/analyze-question-stream`。
- 代码位置：`source/vue/xzs-student/src/views/question-error/index.vue`

### 4.4 图片识题功能

用户上传题目图片后，系统调用大模型的多模态能力识别图片中的题目内容。

**后端实现**：
- Controller：`QuestionController.analyzeImageQuestion()`，接口路径 `POST /api/student/question/analyze-image`（multipart/form-data，参数名 `file`）
- Service：`QuestionService.analyzeImageQuestion(MultipartFile file)`
- 代码位置：`controller/student/QuestionController.java:45-57`

**前端实现**：
- Web 端：`source/vue/xzs-student/src/views/question/ai-analyze.vue`（拖拽上传，支持 JPG/PNG/GIF，最大 10MB）
- 小程序端：`source/wx/xzs-student/pages/ai-analyze/index/index.js`（调用 `wx.chooseMedia` + `wx.uploadFile`，上传至 `/api/wx/student/question/analyze-image`）

**调用流程**：
```
用户选择图片 → 上传至后端 → 后端调用大模型多模态API → 返回识别结果（题目类型、内容、选项、答案、解析）
```

**注意**：该功能依赖外部 AI 服务商的多模态能力，不是传统的 OCR 文字识别技术。`QuestionService.analyzeImageQuestion()` 的具体实现将图片发送给已配置的 AI 服务商进行识别。

### 4.5 四种 AI 解析风格

系统提供四种 AI 解析风格，区别在于 Prompt 模板设计不同。

**Prompt 模板文件**（位于 `source/xzs/src/main/resources/ai/prompts/analysis/`）：

| 风格 | 文件名 | style 值 | System Prompt 要点 |
|------|--------|---------|-------------------|
| 标准解析 | `default.json` | `default` | 专业 408 辅导老师，全面、条理清晰、紧扣考点 |
| 费曼学习法 | `feynman.json` | `feynman` | 把复杂概念翻译成大白话，用生活场景类比 |
| 第一性原理 | `first-principles.json` | `first-principles` | 从基本定义出发，质疑假设，逻辑推导 |
| 柏拉图式对话 | `plato.json` | `plato` | 通过层层追问引导学生自己发现答案 |

每个 JSON 文件包含 `name`、`style`、`systemPrompt`、`userPromptTemplate`、`variables` 五个字段。

**加载机制**：`AnalysisService` 构造函数调用 `loadTemplates()`（`AnalysisService.java:68-89`），从 classpath 加载这四个 JSON 文件，解析为 `PromptTemplate` 对象存入 `Map<String, PromptTemplate>`。如果文件加载失败，回退到硬编码的默认模板。

**风格切换流程**：
```
前端选择风格(style参数)
  → 后端 AIAnalysisController
    → AnalysisService.getTemplate(style) 获取对应模板
      → PromptTemplate.formatUserPrompt() 替换 {question}、{knowledge_points_block}、{reference_docs} 占位符
        → 调用大模型API
```

### 4.6 AI 学习工作台

AI 学习工作台是学生端的核心页面（即学生端首页 Dashboard），采用三栏布局。

**代码位置**：`source/vue/xzs-student/src/views/dashboard/index.vue`（1154 行，28KB）

**功能组成**：

| 区域 | 功能 |
|------|------|
| 主体区域 | 408Master 品牌展示、学习统计、"开始刷题"和"查看知识图谱"入口 |

AI 学习工作台的交互功能主要通过 AI 对话接口实现，前端页面通过 `POST /api/student/ai/workbench/stream`（SSE）和 `POST /api/student/ai/analyze-stream`（SSE）与后端交互。

**后端接口**：
- `POST /api/student/ai/workbench/stream`（SSE 流式）—— `AiWorkbenchController`（`controller/student/AiWorkbenchController.java`）
- `POST /api/student/ai/agent/plan` —— Agent 草案生成（`AIAnalysisController`）
- `POST /api/student/ai/agent/confirm` —— 确认 Agent 草案（`AIAnalysisController`）
- `POST /api/student/ai/compose-paper` —— AI 辅助组卷（`AIAnalysisController`）

**意图路由**（`service/AiIntentRouter.java`，第 10-15 行定义 6 种意图常量）：

| 意图 | 常量名 | 触发条件 |
|------|--------|---------|
| 题目讲解 | `explain_question` | 有题目或粘贴文本时 |
| 知识点讲解 | `explain_knowledge` | 有知识点上下文时 |
| 学习画像 | `learning_profile` | 消息匹配画像关键词时 |
| 练习规划 | `practice_plan` | 消息匹配"练习/组卷/出题"等模式时 |
| 组卷 | `compose_paper` | 消息匹配"直接建卷"等模式时 |
| 自由对话 | `free_chat` | 兜底意图 |

意图路由使用正则表达式匹配，代码位置：`AiIntentRouter.java:17-45`。

**后端编排**：`AiOrchestratorServiceImpl.java` 根据意图路由结果，分别调用 RAG 检索、Agent 草案生成、AI 分析等不同处理路径，通过 SSE 流式返回结果。

### 4.7 知识图谱页面

**后端实现**：`KnowledgeGraphController.java`（`controller/student/KnowledgeGraphController.java`），类级别映射 `/api/student/knowledge-graph`

| 接口 | HTTP 方法 | 说明 |
|------|----------|------|
| `/graph` | **GET** | 获取知识图谱数据（支持 `?subjectId=` 筛选） |
| `/knowledge-point/{id}` | **GET** | 获取知识点详情 |
| `/question/{questionId}/knowledge-points` | **GET** | 获取题目关联的知识点 |
| `/knowledge-point/{id}/questions` | **GET** | 获取知识点下的题目（支持 `?limit=` 参数） |

**前端实现**：`source/vue/xzs-student/src/views/knowledge-graph/index.vue`（路由 `/knowledge-graph/index`）

知识图谱功能也集成在 AI 学习工作台的知识点目录树中，支持在对话上下文中选择知识点。后端服务层为 `KnowledgeGraphService.java`，数据来自 `knowledge_point` 表和 `question_knowledge_point` 关联表。

### 4.8 小程序功能

小程序端位于 `source/wx/xzs-student/`，采用微信小程序原生开发，AppID 为 `wx217587125a29c7b5`（来自 `project.config.json`）。

**核心页面**（16 个，来自 `app.json` 的 `pages` 数组）：

| 页面路径 | 功能 |
|---------|------|
| `pages/index/index` | 首页（试卷和任务列表） |
| `pages/exam/index/index` | 刷题（试卷列表） |
| `pages/exam/do/index` | 答题（计时答题） |
| `pages/exam/read/index` | 查看答卷 |
| `pages/exam/edit/index` | 答题编辑（存根页面） |
| `pages/record/index` | 考试记录 |
| `pages/error-book/index/index` | 错题本列表 |
| `pages/error-book/detail/index` | 错题详情 + AI 分析（4 种风格） |
| `pages/ai-analyze/index/index` | 拍照识题（图片上传 + AI 识别） |
| `pages/my/index/index` | 个人中心 |
| `pages/my/info/index` | 编辑个人信息 |
| `pages/my/log/index` | 活动日志 |
| `pages/my/message/list/index` | 消息列表 |
| `pages/my/message/info/index` | 消息详情 |
| `pages/user/bind/index` | 微信绑定 |
| `pages/user/register/index` | 注册 |

**TabBar**（来自 `app.json:31-56`）：首页、刷题、错题、大师（4 个 Tab）

**API 调用**：小程序通过 `/api/wx/` 前缀访问后端，与 Web 端共享同一套 Service 层。使用 iView Weapp 组件库提供 50 个 UI 组件。

---

## 5. 架构设计

### 5.1 Vue 2 到 Vue 3 的完整迁移

两个前端项目均已从 Vue 2 完整迁移到 Vue 3（Git 提交 `e7703b65`，2026-05-14，提交信息："Vue2 to Vue3 迁移完成"）：

| 项目 | Vue 版本 | 构建工具 | UI 框架 | 状态管理 | 代码位置 |
|------|---------|---------|---------|---------|---------|
| xzs-admin | `^3.4.31` | Vite `^5.4.14` | Element Plus `^2.9.1` | Pinia `^2.3.0` | `source/vue/xzs-admin/` |
| xzs-student | `^3.5.13` | Vite `^6.0.0` | Element Plus `^2.9.1` | Pinia `^2.3.0` | `source/vue/xzs-student/` |

迁移要点：
- 路由从 Vue Router 2.x 升级到 4.x（`createRouter` + `createWebHistory`）
- 状态管理从 Vuex 迁移到 Pinia
- 使用 Vue 3 组合式 API（Composition API）
- 构建工具从 Webpack 迁移到 Vite

### 5.2 项目整体架构

系统由以下组件构成：

```
┌─────────────┐  ┌──────────────┐  ┌──────────────┐
│  Web 管理端  │  │  Web 学生端   │  │  微信小程序   │
│  (xzs-admin) │  │ (xzs-student)│  │  (xzs-wx)    │
│  Vue 3.4     │  │  Vue 3.5     │  │  原生开发     │
└──────┬───────┘  └──────┬───────┘  └──────┬───────┘
       │                 │                  │
       └────────┬────────┘                  │
                │ HTTP / SSE                │ /api/wx/
       ┌────────▼────────┐                  │
       │  Spring Boot     │  Java 8, Undertow│
       │  后端 API        │  端口 8000       │
       │  274 个 Java 文件│                  │
       └──┬────┬────┬────┘                  
          │    │    │                        
   ┌──────▼┐  │  ┌─▼────────┐              
   │ MySQL │  │  │  Qdrant   │              
   │ 8.0   │  │  │ 向量数据库 │              
   └───────┘  │  └───────────┘              
         ┌────▼─────┐
         │ AI 模型   │  智谱GLM / DeepSeek / OpenAI
         │ 服务      │  OpenAI 兼容 API
         └──────────┘
```

后端共 274 个 Java 文件、26 个 MyBatis Mapper XML 文件。数据库共 20 个 SQL 迁移脚本（`database/current/` 目录）。

### 5.3 AI 整体架构

AI 架构分为三层：

**1. 前端交互层**：收集用户问题、解析风格、题目上下文，通过 SSE 接收流式响应。
- 代码位置：`views/dashboard/index.vue`、`views/question-error/index.vue`

**2. 后端编排层**（`AnalysisService.java` + `RagService.java` + `AiOrchestratorServiceImpl.java`）：
1. 从数据库获取 AI 服务商配置（支持多个提供商按优先级排序）
2. 判断用户请求类型（意图路由，`AiIntentRouter.java`）
3. 组织 Prompt（选择对应风格的模板，`PromptTemplate.formatUserPrompt()`）
4. 调用 Embedding 模型生成向量（`RagService.embed()`）
5. 从 Qdrant 检索相关内容（`QdrantRagIndexServiceImpl.search()`）
6. 将检索结果拼接进 Prompt（`RagService.formatReferenceDocs()`）
7. 调用大语言模型生成回答（`AnalysisService.callAiApiStream()`）
8. 记录使用日志（`AiUsageLog` 表，含 token 用量、费用计算 `AiPricing.java`、耗时）

**3. 模型调用层**：对接不同 AI 服务商的 OpenAI 兼容 API。`AiPricing.java` 为 14 种模型定义了三层定价（输入/输出/缓存命中）。

**AI Provider 优先级调度**（`AnalysisService.resolveProvider()`，`AnalysisService.java:167-213`）：
1. 数据库中启用的公共密钥（`ai_provider_config` 表），按 `priority` 升序排列（数值越小优先级越高）
2. 当前用户的私人密钥（`ai_user_key` 表），按 `priority` 升序排列
3. `application.yml` 中的默认配置（`glm-4.5-air`，智谱 BigModel）作为兜底

### 5.4 Qdrant 与 RAG 架构

RAG 检索支持两条路径（`RagService.java:101-107`）：

**路径一：Qdrant 向量数据库**（当 `ai.rag.vector.enabled=true` 时激活，默认为 `false`）
- 配置位置：`application.yml:75-87` 的 `ai.rag.vector.qdrant` 节
- 集合名：`xzs_408_chunks`（默认值，可配置）
- 距离度量：Cosine（默认值，可配置，`QdrantRagIndexServiceImpl.java:36`）
- 向量维度：动态决定，从 Embedding API 返回值获取（不硬编码）
- 实现代码：`QdrantRagIndexServiceImpl.java`

**路径二：内存余弦相似度**（默认路径，Qdrant 未启用时使用）
- 从 `t_text_content` 表加载所有含 `embedding` 的记录（`TextContentMapper.selectAllWithEmbedding()`）
- 缓存 5 分钟（`CACHE_TTL_MS = 5 * 60 * 1000`，`RagService.java:63`）
- 实时计算余弦相似度（`RagService.cosineSimilarity()`，`RagService.java:283-299`）
- 实现代码：`RagService.java:301-340`

**检索参数**：
- Top-K：5（调用方传入，如 `AiOrchestratorServiceImpl.java:71`）
- 相似度阈值：0.5（`RagService.java:120` 过滤 `score <= 0.5`，`RagService.java:332` 过滤 `similarity <= 0.5`）

**Embedding 生成**：
- 模型：`embedding-2`（默认值，`application.yml` 和 `AiProviderConfigServiceImpl.java:128`）
- API：`https://open.bigmodel.cn/api/paas/v4/embeddings`（默认值）
- 文本截断：8000 字符（`RagService.java:146`）
- 维度：由 API 返回值动态决定。Zhipu 的 `embedding-2` 模型返回 1024 维向量，但代码不硬编码此值

**注意**：报告中说"GLM Embedding-2（1024 维）"——代码确实使用 `embedding-2` 模型，但 1024 维是 Zhipu 文档中的规格，代码中维度是从 API 响应动态读取的，未硬编码。

**批量生成脚本**：
- `scripts-embedding/embed_questions.py`：从 `t_text_content` 读取未生成向量的记录，调用 Embedding API 写入 `embedding` 列
- `scripts-embedding/embed_rag_chunks_to_qdrant.py`：从 `rag_chunk` 表读取未索引的分块，生成向量并写入 Qdrant

**完整 RAG 调用链**：
```
前端 POST /api/student/ai/analyze-stream
  → AIAnalysisController.analyzeWithAIStream()
    → RagService.retrieve(question, 5)
      → RagService.embed(query)           // 调用 Embedding API
      → QdrantRagIndexServiceImpl.search() 或内存检索
    → RagService.formatReferenceDocs(ragDocs)
    → AnalysisService.analyzeWithAIStream(style, question, ..., referenceDocs, ...)
      → buildWorkbenchPrompt()            // 组装带参考资料的 Prompt
      → callAiApiStream()                 // 调用大模型 API
    → SSE 返回流式响应
```

### 5.5 小程序原生架构

小程序端采用微信小程序原生开发，使用 iView Weapp 组件库（`component/iView/` 下约 50 个组件）。

小程序不直接访问数据库，不保存 AI 密钥，统一通过后端 `/api/wx/` 接口访问系统能力。

小程序 API 基地址在 `app.js:8` 中配置：
```javascript
globalData: {
  baseAPI: "http://118.31.34.132"
}
```

**注意**：当前 API 地址使用 HTTP 协议，用于开发测试。正式上线前需改为 HTTPS 并在微信公众平台配置合法请求域名。

小程序端还包含 Markdown 渲染工具（`utils/markdown.js`），用于将 AI 返回的 Markdown 格式解析结果渲染为 HTML。

### 5.6 密钥安全性设计

**存储方式**：API 密钥使用 AES-256-GCM 加密后存储在数据库中。
- 加密算法：`AES/GCM/NoPadding`（`AiProviderConfigServiceImpl.java:278-292`）
- IV：随机 12 字节（`GCM_IV_LENGTH = 12`，第 31 行）
- Tag 长度：128 位（`GCM_TAG_LENGTH = 128`，第 30 行）
- 密钥派生：`SHA-256(masterKey)` 产生 256 位 AES 密钥（第 310-314 行）
- Master Key 来源：`${ai.secret.master-key:${system.pwdKey.privateKey:408MasterLocalSecret}}`

**前端安全**：
- `listSafe()` 方法返回数据时将 `apiKeyCipher` 设为 null，前端永远无法获取密钥
- 管理端显示脱敏后的 `apiKeyMask` 字段
- 学生端仅能看到公钥服务商的名称和模型信息

**用户私钥（BYOK）**：学生可以添加自己的 API 密钥（`ai_user_key` 表，建表脚本 `deploy/sql/ai_user_key.sql`），同样使用 AES-256-GCM 加密存储，仅该用户可用。用户密钥的解析和使用逻辑在 `AiUserKeyServiceImpl.java` 中，与公共密钥共用相同的加密方案。

---

## 6. 部署设计

### 6.1 本地开发部署

本地开发环境配置位于 `application-dev.yml`：
- MySQL：`localhost:3306/xzs`，用户 `root`，密码 `123456`
- RAG：启用（`ai.rag.vector.enabled: true`），Qdrant 地址 `http://127.0.0.1:6333`

前端开发通过 Vite 开发服务器启动（`npm run dev` / `npm run serve`），后端通过 Spring Boot 启动。

### 6.2 Docker 容器化部署

Docker 部署文件位于 `deploy/` 目录。

**Dockerfile**（`deploy/Dockerfile`）：
- 基础镜像：`registry.cn-hangzhou.aliyuncs.com/mindskip/java:1.8.0`（Java 8）
- 运行 `xzs-3.9.0.jar`，激活 `prod` profile
- 暴露端口 8000

**docker-compose.yml**（`deploy/docker-compose.yml`）定义 4 个服务：

| 服务 | 镜像 | 容器名 | 端口 | 内存限制 |
|------|------|--------|------|---------|
| `mysql` | `registry.cn-hangzhou.aliyuncs.com/mindskip/mysql:8.0.33` | xzs-mysql | 内部 3306 | 512MB |
| `qdrant` | `qdrant/qdrant:latest` | xzs-qdrant | 6333, 6334 | 512MB |
| `backend` | 本地 Dockerfile 构建 | xzs-backend | 8000 | 512MB |
| `nginx` | `nginx:1.25-alpine` | xzs-nginx | 80, 443 | 128MB |

所有服务运行在 `xzs-net` bridge 网络上。后端环境变量包括数据库连接、AI 密钥主密钥（`AI_SECRET_MASTER_KEY: "408MasterLocalSecret"`）等。

**override 文件**（`deploy/docker-compose.override-embed.yml`）：临时暴露 MySQL 3306 端口到宿主机，用于运行 Embedding 脚本。

**nginx.conf**（`deploy/nginx.conf`）配置：
- `/api/` 反向代理到 `http://backend:8000`（300 秒超时，`proxy_buffering off`，支持 SSE）
- `/student` 服务学生端静态文件（alias `/usr/share/nginx/html/student`）
- `/admin` 服务管理端静态文件（alias `/usr/share/nginx/html/admin`）
- `/images/` 服务题目图片（alias `/usr/share/nginx/html/images/`，30 天缓存）
- `/` 重定向到 `/student/index`

### 6.3 云服务器部署

系统支持通过 Docker Compose 部署到 Linux 云服务器。小程序 `app.js` 中的 API 地址 `http://118.31.34.132` 表明已有云服务器测试环境的配置。

**注意**：
- 当前 Docker Compose 配置是为本地/测试环境设计的，正式上线需做以下调整
- 正式上线需要配置 HTTPS（当前 Nginx 配置预留了 443 端口和 SSL 目录 `./ssl`，但未配置证书）
- 小程序端需要将 API 地址改为 HTTPS 域名，并在微信公众平台配置合法请求域名
- 数据库密码（当前为 `doushijiaxiang0.`）和 AI 密钥主密钥需更换为安全值

### 6.4 小程序部署

小程序代码位于 `source/wx/xzs-student/`，使用微信开发者工具导入即可预览和调试。

AppID：`wx217587125a29c7b5`（来自 `project.config.json`）

**上线要求**：
1. 后端接口必须使用 HTTPS（当前 `app.js` 中为 HTTP）
2. 域名需在微信公众平台配置为合法请求域名
3. 通过微信审核后发布

**当前状态**：开发完成，可在微信开发者工具中预览和调试。待配置 HTTPS 后可提交审核。

---

## 7. 开发过程

### 7.1 Git 分支与版本管理

项目使用 Git 进行版本管理，主分支为 `main`，开发分支为 `dev`。功能开发使用 `feature/*` 分支（如 `feature/ai`、`feature/crawler-and-exam-data`、`feature/ui-branding`）。

### 7.2 分工说明

| 成员 | 主要负责 |
|------|---------|
| 吴天凯（Tucker_Wu） | 数据库设计、后端接口、AI 功能、RAG 架构、爬虫与数据、Docker 部署 |
| 协作者 | 前端页面、小程序页面、界面样式和部分交互功能 |
| 双方共同 | 系统测试、功能联调、报告整理 |

### 7.3 开发里程碑

基于 Git 提交历史整理：

| 阶段 | 时间 | 主要工作 | 关键提交 |
|------|------|---------|---------|
| 项目启动 | 2026-04-22 | Fork 开源项目，UI 品牌化改造（408Master） | `96546159` |
| 基础改造 | 2026-04-28 | 学生端 UI 现代化，前端修改 | `15d78006` |
| 数据库扩展 | 2026-05-14 | Vue2→Vue3 完整迁移，数据库增强，学习系统表 | `e7703b65` |
| 爬虫与题库 | 2026-05-15~16 | 编写爬虫，导入 408 真题数据，数据库结构调整 | `f5eafa46`, `39db256b` |
| AI 功能 | 2026-05-16 | AI 解析风格、4 种 Prompt 模板、NPE 修复 | `d68f4f5f`, `68b48ed3` |
| Docker 部署 | 2026-05-16 | Docker 部署文件、RAG + Embedding、Nginx 配置 | `c1b07956` |
| 知识图谱 | 2026-05-17 | 知识图谱页面、知识标签数据、UI 稳定化 | `28c31555` |
| AI 工作台 | 2026-05-17~19 | AI 学习工作台设计、Prompt 优化、SSE 流式 | `cb69f895`, `02a98111` |
| 题库扩展 | 2026-05-27~28 | HTML 格式题库导入、英语完形填空修复、AI 工作台编排器 | `eeee837e`, `e26ee103` |

---

## 8. 核心接口文档

所有接口路径均已对照后端 Controller 代码逐条核实。

### 8.1 用户登录接口

| 项目 | 内容 |
|------|------|
| 接口名称 | 登录 |
| 请求路径 | `POST /api/user/login` |
| 请求参数 | `userName`, `password`（RSA 加密） |
| 返回结果 | `{ code: 1, response: { token, user } }` |
| 后端代码 | `configuration/spring/security/RestLoginAuthenticationFilter.java`（Spring Security 过滤器，非 Controller） |
| 前端页面 | 登录页（admin: `views/login/index.vue`，student: `views/login/index.vue`） |

**注意**：登录接口由 Spring Security Filter 处理（`AntPathRequestMatcher("/api/user/login", "POST")`），不是标准 @RequestMapping Controller。

### 8.2 题目查询接口

| 项目 | 内容 |
|------|------|
| 接口名称 | 管理端题目分页列表 |
| 请求路径 | `POST /api/admin/question/page` |
| 请求参数 | `pageIndex`, `pageSize`, `id`, `subjectId`, `questionType` |
| 后端代码 | `controller/admin/QuestionController.java` → `QuestionServiceImpl` |

| 项目 | 内容 |
|------|------|
| 接口名称 | 学生端题目详情 |
| 请求路径 | `POST /api/student/question/select/{id}` |
| 后端代码 | `controller/student/QuestionController.java:36` |

### 8.3 试卷接口

| 项目 | 内容 |
|------|------|
| 接口名称 | 学生端试卷列表 |
| 请求路径 | `POST /api/student/exam/paper/pageList` |
| 后端代码 | `controller/student/ExamPaperController.java` |

| 项目 | 内容 |
|------|------|
| 接口名称 | 提交答卷 |
| 请求路径 | `POST /api/student/exampaper/answer/answerSubmit` |
| 后端代码 | `controller/student/ExamPaperAnswerController.java` |

**注意**：路径中 `exampaper` 是一个单词，不是 `exam/paper`。这是两个不同的 Controller：试卷操作用 `ExamPaperController`（路径 `/api/student/exam/paper`），答题操作用 `ExamPaperAnswerController`（路径 `/api/student/exampaper/answer`）。

### 8.4 错题本接口

| 项目 | 内容 |
|------|------|
| 接口名称 | 答题记录分页（错题列表） |
| 请求路径 | `POST /api/student/question/answer/page` |
| 请求参数 | `pageIndex`, `pageSize` |
| 后端代码 | `controller/student/QuestionAnswerController.java` → `ExamPaperQuestionCustomerAnswerService` |
| 前端页面 | `views/question-error/index.vue` |

### 8.5 AI 解析接口

| 项目 | 内容 |
|------|------|
| 接口名称 | 获取可用解析风格 |
| 请求路径 | **GET** `/api/student/ai/styles` |
| 返回结果 | `["default", "feynman", "plato", "first-principles"]` |
| 后端代码 | `controller/student/AIAnalysisController.java:52` |

| 项目 | 内容 |
|------|------|
| 接口名称 | 获取 Prompt 模板 |
| 请求路径 | **GET** `/api/student/ai/template/{style}` |
| 后端代码 | `controller/student/AIAnalysisController.java:58` |

| 项目 | 内容 |
|------|------|
| 接口名称 | AI 分析（同步） |
| 请求路径 | `POST /api/student/ai/analyze` |
| 请求参数 | `{ style, question, knowledgePoints, taskType }` |
| 返回结果 | `{ analysis, prompt, systemPrompt, style, references[] }` |
| 后端代码 | `controller/student/AIAnalysisController.java:82` → `AnalysisService` + `RagService` |

| 项目 | 内容 |
|------|------|
| 接口名称 | AI 分析（SSE 流式） |
| 请求路径 | `POST /api/student/ai/analyze-stream`（`produces = text/event-stream`） |
| 返回结果 | SSE 事件流：`status` → `references` → `chunk`(多次) → `done` |
| 后端代码 | `controller/student/AIAnalysisController.java:203` |

| 项目 | 内容 |
|------|------|
| 接口名称 | AI 工作台流式 |
| 请求路径 | `POST /api/student/ai/workbench/stream`（`produces = text/event-stream`） |
| 请求参数 | `{ intent, style, context, userMessage }` |
| 后端代码 | `controller/student/AiWorkbenchController.java` → `AiOrchestratorServiceImpl` |

### 8.6 AI 配置接口（管理端）

| 项目 | 内容 |
|------|------|
| 接口名称 | 列出 AI 服务商 |
| 请求路径 | `POST /api/admin/ai-config/providers` |
| 后端代码 | `controller/admin/AiConfigController.java:37` → `AiProviderConfigService.listSafe()` |

| 项目 | 内容 |
|------|------|
| 接口名称 | 保存 AI 服务商 |
| 请求路径 | `POST /api/admin/ai-config/provider/save` |
| 请求参数 | `{ providerCode, providerName, apiBaseUrl, chatModel, embeddingModel, apiKey, enabled, priority }` |
| 后端代码 | `controller/admin/AiConfigController.java:42` → `AiProviderConfigServiceImpl.save()`（AES-256-GCM 加密后存储） |

| 项目 | 内容 |
|------|------|
| 接口名称 | 测试 AI 服务商连通性 |
| 请求路径 | `POST /api/admin/ai-config/provider/{id}/test` |
| 后端代码 | `controller/admin/AiConfigController.java:59` |

| 项目 | 内容 |
|------|------|
| 接口名称 | RAG 索引构建 |
| 请求路径 | `POST /api/admin/ai-config/rag/index` |
| 请求参数 | `{ source: "all" | "questions" | "knowledge" }` |
| 后端代码 | `controller/admin/AiConfigController.java:79` → `RagDocumentService` + `RagService` + `RagIndexService` |

### 8.7 图片识题接口

| 项目 | 内容 |
|------|------|
| 接口名称 | 图片识题（Web 端） |
| 请求路径 | `POST /api/student/question/analyze-image` |
| 请求方式 | `multipart/form-data`，参数名 `file` |
| 后端代码 | `controller/student/QuestionController.java:45` → `QuestionService.analyzeImageQuestion()` |

| 项目 | 内容 |
|------|------|
| 接口名称 | 图片识题（小程序端） |
| 请求路径 | `POST /api/wx/student/question/analyze-image` |
| 后端代码 | `controller/wx/student/QuestionController.java:71` |
| 前端代码 | `pages/ai-analyze/index/index.js`（`wx.uploadFile`，第 46 行） |

### 8.8 知识图谱接口

| 项目 | 内容 |
|------|------|
| 接口名称 | 获取知识图谱 |
| 请求路径 | **GET** `/api/student/knowledge-graph/graph`（可选参数 `?subjectId={id}`） |
| 后端代码 | `controller/student/KnowledgeGraphController.java:22` → `KnowledgeGraphService` |

### 8.9 AI 配置接口（学生端 BYOK）

| 项目 | 内容 |
|------|------|
| 接口名称 | 列出公共 AI 服务商 |
| 请求路径 | `POST /api/student/ai-config/providers` |
| 后端代码 | `controller/student/StudentAiConfigController.java` |

| 项目 | 内容 |
|------|------|
| 接口名称 | 用户私钥列表 |
| 请求路径 | `POST /api/student/ai-config/user-keys` |
| 后端代码 | `controller/student/StudentAiConfigController.java:40` |

| 项目 | 内容 |
|------|------|
| 接口名称 | 保存用户私钥 |
| 请求路径 | `POST /api/student/ai-config/user-key/save` |
| 后端代码 | `controller/student/StudentAiConfigController.java` → `AiUserKeyServiceImpl` |

### 8.10 Agent 草案接口

| 项目 | 内容 |
|------|------|
| 接口名称 | 生成练习草案 |
| 请求路径 | `POST /api/student/ai/agent/plan` |
| 请求参数 | `AiAgentPlanRequestVM` |
| 后端代码 | `controller/student/AIAnalysisController.java:183` → `AiAgentPlannerService.plan()` |

| 项目 | 内容 |
|------|------|
| 接口名称 | 确认练习草案 |
| 请求路径 | `POST /api/student/ai/agent/confirm` |
| 后端代码 | `controller/student/AIAnalysisController.java:193` → `AiAgentPlannerService.confirm()` |

### 8.11 小程序端核心接口

小程序通过 `/api/wx/` 前缀访问后端，核心接口包括：

| 接口路径 | HTTP 方法 | 说明 | 后端代码 |
|---------|----------|------|---------|
| `/api/wx/student/dashboard/index` | POST | 首页数据 | `wx/student/DashboardController.java` |
| `/api/wx/student/exampaper/pageList` | POST | 试卷列表 | `wx/student/ExamPaperController.java` |
| `/api/wx/student/exampaper/select/{id}` | POST | 试卷详情 | `wx/student/ExamPaperController.java` |
| `/api/wx/student/exampaper/answer/answerSubmit` | POST | 提交答卷 | `wx/student/ExamPaperAnswerController.java` |
| `/api/wx/student/exampaper/answer/read/{id}` | POST | 查看答卷 | `wx/student/ExamPaperAnswerController.java` |
| `/api/wx/student/question/answer/page` | POST | 错题列表 | `wx/student/QuestionAnswerController.java` |
| `/api/wx/student/question/analyze-image` | POST (multipart) | 拍照识题 | `wx/student/QuestionController.java:71` |
| `/api/wx/student/question/analyze-question` | POST | AI 题目分析 | `wx/student/QuestionController.java:32` |
| `/api/wx/student/auth/bind` | POST | 微信绑定 | `wx/student/AuthController.java` |
| `/api/wx/student/auth/checkBind` | POST | 检查绑定状态 | `wx/student/AuthController.java` |

### 8.12 用户统计接口

| 项目 | 内容 |
|------|------|
| 接口名称 | 获取用户学习统计 |
| 请求路径 | **GET** `/api/student/user/stats` |
| 后端代码 | `controller/student/ChatController.java:173`（注意：此接口位于 ChatController 而非 UserController） |

---

## 9. 项目总结

本项目在原有开源考试系统基础上进行了较大幅度的二次开发。通过数据库结构扩展、题库数据采集、AI 解析能力接入、前端 Vue 3 迁移、RAG 向量检索集成、AI 学习工作台设计、微信小程序开发和 Docker 部署适配等工作，将原有面向普通在线考试的系统升级为面向 408 考研的智能学习平台。

项目的技术亮点包括：

1. **四种 AI 解析风格的 Prompt 模板化管理**
   - 4 个独立 JSON 模板文件，`AnalysisService` 启动时动态加载
   - 工作台场景中根据风格动态注入输出规则
   - 代码位置：`source/xzs/src/main/resources/ai/prompts/analysis/`、`AnalysisService.java:325-338`

2. **双路径 RAG 检索**
   - 同时支持 Qdrant 向量数据库和内存余弦相似度两种检索路径
   - Qdrant 未启用时系统仍能通过内存路径正常运行
   - 代码位置：`RagService.java:101-107`

3. **AI Provider 多层优先级调度**
   - 支持三个 AI 服务商（智谱 GLM / DeepSeek / OpenAI）和用户自带密钥（BYOK）
   - 按 `priority` 升序自动选择最优提供商
   - 代码位置：`AnalysisService.java:167-213`

4. **API 密钥 AES-256-GCM 加密存储**
   - 所有 AI 密钥在数据库中加密存储，`listSafe()` API 永不返回密钥明文
   - 管理端展示脱敏掩码，学生端不可见密钥
   - 代码位置：`AiProviderConfigServiceImpl.java:278-314`

5. **SSE 流式 AI 输出**
   - 支持 Server-Sent Events 实时流式响应，包括 AI 分析和 AI 工作台两个流式接口
   - 代码位置：`AIAnalysisController.java:203`、`AiWorkbenchController.java:30`

6. **意图路由与 Agent 草案**
   - 6 种意图自动识别，支持练习规划草案生成与确认
   - 代码位置：`AiIntentRouter.java`、`AiAgentPlannerServiceImpl.java`

7. **规范化 RAG 索引架构**
   - `rag_document` → `rag_chunk` → `rag_embedding` 三层索引结构
   - Python 离线脚本支持从 MySQL 读取分块、生成向量、写入 Qdrant
   - 代码位置：`12_canonical_ai_architecture.sql`、`embed_rag_chunks_to_qdrant.py`

8. **Docker Compose 一键部署**
   - 4 服务容器化（MySQL + Qdrant + Backend + Nginx）
   - Nginx 反向代理支持 SSE 长连接
   - 代码位置：`deploy/docker-compose.yml`

9. **小程序端复用后端 Service 层**
   - 7 个 WX 专用 Controller 复用同一套 Service/Mapper
   - 支持拍照识题和 4 风格 AI 分析
   - 代码位置：`controller/wx/student/`

10. **AI 费用追踪**
    - `AiPricing.java` 为 14 种模型定义三层定价
    - 每次 AI 调用自动记录 token 用量、费用和耗时
    - 代码位置：`ai/AiPricing.java`

通过本项目，我完成了从数据采集、数据库设计、后端接口开发、前端页面开发、AI 接入、向量检索、小程序开发到容器化部署的完整实践。项目体现了传统考试系统向智能学习平台升级的过程，也展示了 AI 技术在具体学习场景中的应用价值。

---

## 待确认事项清单

以下内容需要人工确认：

1. **选择题数据精确数量**：`exam_questions.json` 中 `"year"` 字段出现 560 次，但原报告中写"约 616 道"。建议运行 `python -c "import json; print(len(json.load(open('crawler/data/exam_questions.json'))))"` 确认 JSON 数组实际长度。

2. **`t_question` 扩展字段数量**：报告标题写"15 个"，实际 `02_extend_fields.sql` 中有 16 个 `ADD COLUMN` 语句。已在报告中修正为 16 个。

3. **`dashboard/index.vue` 行数**：报告原写"约 2568 行"，实际为 1154 行。已在报告中修正。

4. **原始真题 PDF 数量**：原报告写"32 个"，`find -name "*.pdf"` 统计为 30 个。已在报告中修正。

5. **题目图片数量**：原报告写"约 16 个"，实际 `crawler/data/images/` 下 15 个，`crawler/data/essay_images/` 下 2 个，合计 17 个。已在报告中修正。

6. **GLM Embedding-2 维度**：代码中使用 `embedding-2` 模型确认无误，但 1024 维是 Zhipu 文档规格，代码中维度由 API 返回值动态决定，未硬编码。报告中已加注说明。

7. **图片识题的具体实现**：`QuestionService.analyzeImageQuestion()` 的具体实现未直接读取到（可能是调用外部 AI 视觉 API），待确认具体的模型调用方式。

8. **小程序是否已提交微信审核**：代码中 `baseAPI` 使用 HTTP，不满足微信上线要求。报告已写为"开发完成，待配置 HTTPS 后可提交审核"。

9. **分工中"协作者"的具体身份**：报告中的分工描述需要根据实际情况确认和补充。

10. **`05_rag_embeddings.sql` 中的 schema 名称**：第 13 行硬编码 `WHERE TABLE_SCHEMA = 'xzas'`（可能是 `xzs` 的笔误），建议确认是否影响实际执行。
