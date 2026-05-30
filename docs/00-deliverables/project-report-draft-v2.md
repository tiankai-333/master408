# 408Master 智能学习平台项目报告

## 1. 项目概述

### 1.1 项目背景

本项目基于开源考试系统 xzs（学之思）进行二次开发。原系统主要面向常规在线考试场景，提供题目管理、试卷管理、答题记录和用户管理等基础功能。

为适配 408 计算机考研学习场景，我在原系统基础上完成了以下主要工作：

1. **数据库结构扩展**：为 `t_question` 表增加 15 个扩展字段（`title`、`options`、`correct_answer`、`analysis`、`images` 等），新增知识点关联表、AI 配置表、学习档案表等共计约 10 张新表。
   - 代码位置：`database/current/02_extend_fields.sql`、`database/current/01_init_structure.sql`

2. **题库数据采集与导入**：通过 Python 爬虫从公开考研网站抓取 408 真题数据（约 616 道选择题、98 道综合题、658 条知识标签），并编写 SQL 生成脚本导入数据库。
   - 代码位置：`crawler/main.py`、`crawler/generate_sql.py`、`database/current/04_exam_data.sql`

3. **AI 解析能力接入**：实现四种 AI 解析风格（标准解析、费曼学习法、第一性原理、柏拉图式对话），支持 SSE 流式输出，后端统一管理 API 密钥。
   - 代码位置：`source/xzs/src/main/java/com/mindskip/xzs/ai/AnalysisService.java`、`source/xzs/src/main/resources/ai/prompts/analysis/`

4. **RAG 检索增强**：集成 Qdrant 向量数据库，使用 GLM Embedding-2（1024 维）生成文本向量，支持题目解析的语义检索。
   - 代码位置：`source/xzs/src/main/java/com/mindskip/xzs/ai/RagService.java`、`scripts-embedding/embed_rag_chunks_to_qdrant.py`

5. **前端完整迁移至 Vue 3**：管理端（xzs-admin）和学生端（xzs-student）均已从 Vue 2 完整迁移到 Vue 3 + Vite + Element Plus + Pinia。
   - 代码位置：`source/vue/xzs-admin/`（Vue 3.4）、`source/vue/xzs-student/`（Vue 3.5）

6. **微信小程序端开发**：基于微信小程序原生开发，包含 16 个页面，支持做题、错题本、AI 图片识题等功能。
   - 代码位置：`source/wx/xzs-student/`

7. **Docker 部署适配**：编写 Dockerfile、docker-compose.yml 和 Nginx 配置，支持一键容器化部署。
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

原系统没有独立的"错题本表"。错题功能通过查询 `t_exam_paper_question_customer_answer` 表中 `do_right = 0` 的记录实现。

### 2.2 原系统存在的问题

1. **题目数据结构单一**：原 `t_question` 表仅通过 `info_text_content_id` 关联 `t_text_content` 存储题目 JSON，缺少 `title`（题干 HTML）、`options`（选项）、`correct_answer`（正确答案）、`analysis`（解析）等独立字段，无法直接支持复杂题干和图片题。

2. **缺少知识点关联**：原系统没有知识点表和题目-知识点关联表，无法按知识点维度组织题库。

3. **缺少 AI 功能支持**：原系统没有 AI 配置表、Prompt 模板表、使用日志表等，无法支持 AI 解析和 RAG 功能。

4. **图片资源无统一管理**：原系统没有图片路径字段和静态资源服务配置。

### 2.3 数据库修改方案

#### 2.3.1 为支持 408 题库的修改

通过 `02_extend_fields.sql` 为 `t_question` 增加以下字段：

| 字段名 | 类型 | 用途 |
|--------|------|------|
| `title` | TEXT | 题目内容（HTML 格式） |
| `options` | TEXT | 选项 JSON |
| `correct_answer` | TEXT | 正确答案 |
| `analysis` | TEXT | 解析（HTML 格式） |
| `difficulty` | INT | 难度等级（1/2/3） |
| `knowledge_point` | VARCHAR(200) | 知识点 |
| `source` | VARCHAR(100) | 来源（如"2024年408真题"） |
| `source_year` | INT | 来源年份 |
| `source_question_no` | INT | 原始题号 |
| `tags` | TEXT | 知识标签（逗号分隔） |
| `images` | TEXT | 图片路径 |
| `title_text` | TEXT | 题目纯文本 |
| `analysis_text` | TEXT | 解析纯文本 |
| `content_format` | VARCHAR(20) | 内容格式（html/markdown/plain） |
| `has_image` | BIT(1) | 是否包含图片 |
| `has_code` | BIT(1) | 是否包含代码 |

为 `t_exam_paper` 增加 `source_year` 和 `description` 字段。

新增 `t_essay_question` 表用于存储综合应用题（爬虫数据），代码位置：`02_extend_fields.sql:39-52`。

#### 2.3.2 为支持知识点系统的修改

| 新增表 | 用途 | 代码位置 |
|--------|------|---------|
| `knowledge_point` | 知识点表（支持父子层级） | `01_init_structure.sql:286` |
| `question_knowledge_point` | 题目-知识点多对多关联 | `01_init_structure.sql:307` |

#### 2.3.3 为支持 AI/RAG 的修改

| 新增表 | 用途 | 代码位置 |
|--------|------|---------|
| `t_ai_usage_log` | AI 调用使用日志 | `01_init_structure.sql:321` |
| `t_ai_prompt_template` | Prompt 模板 | `01_init_structure.sql:382` |
| `t_ai_knowledge_base` | AI 知识库（含 RAG 向量字段） | `01_init_structure.sql:351` |
| `t_ai_adjustment_log` | 模板调整日志 | `01_init_structure.sql:414` |
| `ai_provider_config` | AI 服务商密钥配置 | `14_ai_provider_config.sql` |
| `ai_user_key` | 用户私钥（BYOK） | `AiUserKey.java` domain |
| `t_text_content.embedding` | 题目解析向量（LONGTEXT） | `05_rag_embeddings.sql` |
| `t_ai_knowledge_base` RAG 字段 | embedding, embedding_model, embedding_dimension, chunk_index, content_hash | `06_ai_knowledge_rag.sql` |

#### 2.3.4 为支持学习档案的修改

| 新增表 | 用途 | 代码位置 |
|--------|------|---------|
| `t_user_learning_profile` | 学生学习画像 | `06_ai_knowledge_rag.sql:92` |
| `t_user_learning_event` | 学习事件流水 | `06_ai_knowledge_rag.sql:107` |
| `t_user_skill_feedback` | 用户对解析风格的反馈 | `06_ai_knowledge_rag.sql:123` |

#### 2.3.5 为支持小程序端的修改

小程序端不需要修改数据库结构。小程序通过 `/api/wx/` 前缀的专用 Controller 访问与 Web 端相同的数据库。后端新增了 `controller/wx/student/` 包下的 7 个 WX 专用 Controller，复用相同的 Service 和 Mapper 层。

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

| 数据类型 | 数量 | 数据来源文件 |
|---------|------|------------|
| 选择题数据 | 约 616 道 | `crawler/data/exam_questions.json`（505KB） |
| 综合题数据 | 约 98 道 | `crawler/data/essay_questions.csv`（217KB） |
| 知识标签 | 658 条 | `crawler/data/knowledge_tags.json`（88KB） |
| HTML 真题源文件 | 228 个 | `crawler/data/html-sources/csgraduates/` |
| 知识点 HTML | 4 科目录 | `crawler/data/knowledge-html-sources/csgraduates/` |
| 题目图片 | 约 16 个 | `crawler/data/images/`（SVG/JPG 格式） |
| 原始真题 PDF | 32 个 | `crawler/真题pdf/`（2009-2024年） |

HTML 源文件覆盖范围：408 计算机真题（2009-2026）、数学一/二/三、英语一/二、政治等。

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
deploy/static/images/{年份}/{题目号}.{svg|jpg|png}
```

数据库 `t_question.images` 字段存储图片路径（如 `/images/2012/2012_4.svg`），不存储图片二进制内容。

**前端渲染**：前端通过 `QuestionHtml.vue` 组件渲染 HTML 题干，图片以 `<img>` 标签形式嵌入 HTML。Nginx 配置了 `/images/` 路径的静态资源服务（30 天缓存），代码位置：`deploy/nginx.conf:36-40`。

当前题目图片数量有限（约 16 个 SVG/JPG 文件），主要涉及包含图表的计算机组成原理和计算机网络题目。

**支持的图片格式**：SVG、JPG、PNG（根据实际文件确认）。

---

## 4. 功能实现

### 4.1 题目功能

**后端实现**：

| 层级 | 代码位置 | 说明 |
|------|---------|------|
| Controller | `controller/admin/QuestionController.java` | 管理端：分页查询、创建编辑、删除 |
| Controller | `controller/student/QuestionController.java` | 学生端：查看详情、AI 分析、图片识题 |
| Service | `service/QuestionService.java` | 题目 CRUD + `analyzeImageQuestion()` |
| Mapper | `repository/QuestionMapper.java` + `QuestionMapper.xml` | MyBatis 数据访问 |
| Domain | `domain/Question.java` | 实体类 |

**前端实现**：

管理端支持 5 种题型的独立编辑器：单选题、多选题、判断题、填空题、简答题。
- 代码位置：`source/vue/xzs-admin/src/views/exam/question/edit/` 下 5 个 `.vue` 文件

学生端在试卷答题页面 (`/do`) 和错题本页面 (`/question/index`) 中查看题目。

### 4.2 试卷功能

**后端实现**：

| 接口路径 | Controller | 说明 |
|---------|-----------|------|
| `POST /api/admin/exam/paper/page` | `ExamPaperController` | 管理端试卷列表 |
| `POST /api/student/exam/paper/pageList` | `ExamPaperController` | 学生端试卷列表 |
| `POST /api/student/exampaper/answer/answerSubmit` | `ExamPaperAnswerController` | 提交答卷 |
| `POST /api/student/ai/compose-paper` | `AIAnalysisController` | AI 辅助组卷 |

除传统试卷管理外，系统还实现了 AI 辅助组卷功能：后端根据学生请求，从题库中筛选题目并生成练习试卷。
- 代码位置：`service/AiPaperComposeService.java`、`service/impl/AiPaperComposeServiceImpl.java`

### 4.3 错题本功能

错题本没有独立的数据库表，而是通过查询答题详情表筛选 `do_right = false` 的记录实现。

**调用链**：
```
前端 views/question-error/index.vue
  → API questionAnswer.pageList()
    → POST /api/student/question/answer/page
      → QuestionAnswerController.pageList()
        → ExamPaperQuestionCustomerAnswerService.studentPage()
```

**AI 分析**：错题本页面集成了 AI 分析功能，支持四种解析风格，通过 SSE 流式输出分析结果。
- 代码位置：`source/vue/xzs-student/src/views/question-error/index.vue`

### 4.4 图片识题功能

用户上传题目图片后，系统调用大模型的多模态能力识别图片中的题目内容。

**后端实现**：
- Controller：`QuestionController.analyzeImageQuestion()`，接口路径 `POST /api/student/question/analyze-image`
- Service：`QuestionService.analyzeImageQuestion(MultipartFile file)`
- 代码位置：`controller/student/QuestionController.java:45-57`

**前端实现**：
- Web 端：`source/vue/xzs-student/src/views/question/ai-analyze.vue`（拖拽上传，支持 JPG/PNG/GIF，最大 10MB）
- 小程序端：`source/wx/xzs-student/pages/ai-analyze/index/index.js`（调用 `wx.chooseMedia` + `wx.uploadFile`）

**调用流程**：
```
用户选择图片 → 上传至后端 → 后端调用大模型多模态API → 返回识别结果（题目类型、内容、选项、答案、解析）
```

**注意**：该功能依赖外部 AI 服务商的多模态能力，不是传统的 OCR 文字识别技术。

### 4.5 四种 AI 解析风格

系统提供四种 AI 解析风格，区别在于 Prompt 模板设计不同。

**Prompt 模板文件**（位于 `source/xzs/src/main/resources/ai/prompts/analysis/`）：

| 风格 | 文件名 | System Prompt 要点 |
|------|--------|-------------------|
| 标准解析 | `default.json` | 专业 408 辅导老师，全面、条理清晰、紧扣考点 |
| 费曼学习法 | `feynman.json` | 把复杂概念翻译成大白话，用生活场景类比 |
| 第一性原理 | `first-principles.json` | 从基本定义出发，质疑假设，逻辑推导 |
| 柏拉图式对话 | `plato.json` | 通过层层追问引导学生自己发现答案 |

**加载机制**：`AnalysisService` 在启动时从 classpath 加载这四个 JSON 文件，解析为 `PromptTemplate` 对象。
- 代码位置：`ai/AnalysisService.java:68-89`

**风格切换流程**：
```
前端选择风格(style参数)
  → 后端 AIAnalysisController
    → AnalysisService.getTemplate(style) 获取对应模板
      → 构建 systemPrompt + userPrompt
        → 调用大模型API
```

### 4.6 AI 学习工作台

AI 学习工作台是学生端的核心页面（即学生端首页 Dashboard），采用三栏布局。

**代码位置**：`source/vue/xzs-student/src/views/dashboard/index.vue`（约 2568 行）

**功能组成**：

| 区域 | 功能 |
|------|------|
| 左侧栏 | 学习统计、科目列表、AI 讲法选择器（4 种风格） |
| 中央栏 | AI 对话区域、快捷操作按钮（题目讲解、知识点讲解、学习画像、组卷练习）、Agent 草案卡片、SSE 流式渲染 |
| 右侧栏 | 知识点目录树（按科目分组，支持搜索）、相关题目、图片识题入口 |

**后端接口**：
- `POST /api/student/ai/workbench/stream`（SSE 流式）—— `AiWorkbenchController`
- `POST /api/student/ai/agent/plan` —— Agent 草案生成
- `POST /api/student/ai/agent/confirm` —— 确认 Agent 草案

**意图路由**（`AiIntentRouter.java`）：
- `explain_question`：题目讲解
- `explain_knowledge`：知识点讲解
- `learning_profile`：学习画像
- `practice_plan`：练习规划
- `compose_paper`：组卷
- `free_chat`：自由对话

### 4.7 知识图谱页面

**后端实现**：`KnowledgeGraphController.java`，接口路径 `/api/student/knowledge-graph/`

| 接口 | 方法 | 说明 |
|------|------|------|
| `GET /graph` | `getKnowledgeGraph()` | 获取知识图谱数据（支持按 subjectId 筛选） |
| `GET /knowledge-point/{id}` | `getKnowledgePointDetail()` | 获取知识点详情 |
| `GET /question/{questionId}/knowledge-points` | `getQuestionKnowledgePoints()` | 获取题目关联的知识点 |
| `GET /knowledge-point/{id}/questions` | `getKnowledgePointQuestions()` | 获取知识点下的题目 |

**前端实现**：`source/vue/xzs-student/src/views/knowledge-graph/index.vue`（路由 `/knowledge-graph/index`）

知识图谱功能也集成在 AI 学习工作台的右侧栏中，支持在对话上下文中选择知识点。

### 4.8 小程序功能

小程序端位于 `source/wx/xzs-student/`，采用微信小程序原生开发，AppID 为 `wx217587125a29c7b5`。

**核心页面**（16 个）：

| 页面路径 | 功能 |
|---------|------|
| `pages/index/index` | 首页（试卷和任务列表） |
| `pages/exam/index/index` | 刷题（试卷列表） |
| `pages/exam/do/index` | 答题（计时答题） |
| `pages/exam/read/index` | 查看答卷 |
| `pages/record/index` | 考试记录 |
| `pages/error-book/index/index` | 错题本列表 |
| `pages/error-book/detail/index` | 错题详情 + AI 分析（4 种风格） |
| `pages/ai-analyze/index/index` | 拍照识题（图片上传 + AI 识别） |
| `pages/my/index/index` | 个人中心 |
| `pages/my/info/index` | 编辑个人信息 |
| `pages/user/bind/index` | 微信绑定 |

**TabBar**：首页、刷题、错题、大师（4 个 Tab）

**API 调用**：小程序通过 `/api/wx/` 前缀访问后端，与 Web 端共享同一套 Service 层。

---

## 5. 架构设计

### 5.1 Vue 2 到 Vue 3 的完整迁移

两个前端项目均已从 Vue 2 完整迁移到 Vue 3：

| 项目 | Vue 版本 | 构建工具 | UI 框架 | 状态管理 | 代码位置 |
|------|---------|---------|---------|---------|---------|
| xzs-admin | Vue 3.4 | Vite 5 | Element Plus 2.9 | Pinia 2.3 | `source/vue/xzs-admin/` |
| xzs-student | Vue 3.5 | Vite 6 | Element Plus 2.9 | Pinia 2.3 | `source/vue/xzs-student/` |

迁移要点：
- 路由从 Vue Router 2.x 升级到 4.x（`createRouter` + `createWebHistory`）
- 状态管理从 Vuex 迁移到 Pinia
- 使用 Vue 3 组合式 API（Composition API）
- 构建工具从 Webpack 迁移到 Vite

Git 历史记录确认迁移发生在 2026-05-14（commit: `e7703b65`，提交信息："Vue2 to Vue3 迁移完成"）。

### 5.2 项目整体架构

系统由以下组件构成：

```
┌─────────────┐  ┌──────────────┐
│  Web 管理端  │  │  Web 学生端   │  Vue 3 + Vite + Element Plus
│  (xzs-admin) │  │ (xzs-student)│
└──────┬───────┘  └──────┬───────┘
       │                 │
       └────────┬────────┘
                │ HTTP / SSE
       ┌────────▼────────┐
       │  Spring Boot     │  Java 8, Undertow
       │  后端 API        │  端口 8000
       └──┬────┬────┬────┘
          │    │    │
   ┌──────▼┐  │  ┌─▼────────┐
   │ MySQL │  │  │  Qdrant   │
   │ 8.0   │  │  │ 向量数据库  │
   └───────┘  │  └───────────┘
         ┌────▼─────┐
         │ AI 模型   │  智谱GLM / DeepSeek / OpenAI
         │ 服务      │
         └──────────┘
```

小程序端通过 `/api/wx/` 接口与同一后端通信。

### 5.3 AI 整体架构

AI 架构分为三层：

**1. 前端交互层**：收集用户问题、解析风格、题目上下文，通过 SSE 接收流式响应。
- 代码位置：`views/dashboard/index.vue`、`views/question-error/index.vue`

**2. 后端编排层**（`AnalysisService.java` + `RagService.java` + `AiOrchestratorServiceImpl.java`）：
1. 从数据库获取 AI 服务商配置（支持多个提供商按优先级排序）
2. 判断用户请求类型（意图路由）
3. 组织 Prompt（选择对应风格的模板）
4. 调用 Embedding 模型生成向量
5. 从 Qdrant 检索相关内容
6. 将检索结果拼接进 Prompt
7. 调用大语言模型生成回答
8. 记录使用日志（token 用量、费用、耗时）

**3. 模型调用层**：对接不同 AI 服务商的 OpenAI 兼容 API。

**AI Provider 优先级调度**（`AnalysisService.resolveProvider()`）：
1. 数据库中启用的公共密钥（`ai_provider_config` 表），按 `priority` 升序排列
2. 当前用户的私人密钥（`ai_user_key` 表），按 `priority` 升序排列
3. `application.yml` 中的默认配置作为兜底

### 5.4 Qdrant 与 RAG 架构

RAG 检索支持两条路径：

**路径一：Qdrant 向量数据库**（当 `ai.rag.vector.enabled=true` 时激活）
- 配置位置：`application.yml` 的 `ai.rag.vector.qdrant` 节
- 集合名：`xzs_408_chunks`
- 距离度量：Cosine
- 向量维度：1024（GLM Embedding-2）
- 实现代码：`QdrantRagIndexServiceImpl.java`

**路径二：内存余弦相似度**（默认路径）
- 从 `t_text_content` 表加载所有含 `embedding` 的记录
- 缓存 5 分钟（`CACHE_TTL_MS = 300000`）
- 实时代算余弦相似度
- 实现代码：`RagService.java:301-340`

**检索参数**：
- Top-K：5
- 相似度阈值：0.5（低于此值的候选被过滤）

**Embedding 生成**：
- 模型：GLM Embedding-2（1024 维）
- API：`https://open.bigmodel.cn/api/paas/v4/embeddings`
- 文本截断：8000 字符
- 批量生成脚本：`scripts-embedding/embed_questions.py`（写入 MySQL）、`scripts-embedding/embed_rag_chunks_to_qdrant.py`（写入 Qdrant）

**完整 RAG 调用链**：
```
前端 POST /api/student/ai/analyze-stream
  → AIAnalysisController.analyzeWithAIStream()
    → RagService.retrieve(question, 5)
      → RagService.embed(query)  // 调用 Embedding API
      → QdrantRagIndexServiceImpl.search() 或内存检索
    → RagService.formatReferenceDocs(ragDocs)
    → AnalysisService.analyzeWithAIStream(style, question, ..., referenceDocs, ...)
      → AnalysisService.buildWorkbenchPrompt()  // 组装带参考资料的 Prompt
      → callAiApiStream()  // 调用大模型 API
    → SSE 返回流式响应
```

### 5.5 小程序原生架构

小程序端采用微信小程序原生开发，使用 iView Weapp 组件库（50 个组件）。

小程序不直接访问数据库，不保存 AI 密钥，统一通过后端 `/api/wx/` 接口访问系统能力。

小程序 API 基地址在 `app.js` 中配置：
```javascript
globalData: {
  baseAPI: "http://118.31.34.132"
}
```

**注意**：当前 API 地址使用 HTTP 协议，用于开发测试。正式上线前需改为 HTTPS 并在微信公众平台配置合法请求域名。

### 5.6 密钥安全性设计

**存储方式**：API 密钥使用 AES-256-GCM 加密后存储在数据库 `ai_provider_config.api_key_cipher` 字段中。
- 加密实现：`AiProviderConfigServiceImpl.java`，使用随机 12 字节 IV + SHA-256(masterKey) 作为 AES 密钥
- Master Key 来源：`${ai.secret.master-key:${system.pwdKey.privateKey:408MasterLocalSecret}}`

**前端安全**：
- `listSafe()` 方法返回数据时将 `apiKeyCipher` 设为 null，前端永远无法获取密钥
- 管理端显示脱敏后的 `apiKeyMask` 字段
- 学生端仅能看到公钥服务商的名称和模型信息

**用户私钥（BYOK）**：学生可以添加自己的 API 密钥（`ai_user_key` 表），同样加密存储，仅该用户可用。

---

## 6. 部署设计

### 6.1 本地开发部署

本地开发环境配置位于 `application-dev.yml`：
- MySQL：`localhost:3306/xzs`，用户 `root`，密码 `123456`
- RAG：启用，Qdrant 地址 `http://127.0.0.1:6333`

前端开发通过 Vite 开发服务器启动，后端通过 Spring Boot 启动。

### 6.2 Docker 容器化部署

Docker 部署文件位于 `deploy/` 目录。

**Dockerfile**（`deploy/Dockerfile`）：
- 基础镜像：`registry.cn-hangzhou.aliyuncs.com/mindskip/java:1.8.0`
- 运行 `xzs-3.9.0.jar`，激活 `prod` profile
- 暴露端口 8000

**docker-compose.yml**（`deploy/docker-compose.yml`）定义 4 个服务：

| 服务 | 镜像 | 端口 | 内存限制 |
|------|------|------|---------|
| `mysql` | MySQL 8.0.33 | 内部 3306 | 512MB |
| `qdrant` | `qdrant/qdrant:latest` | 6333, 6334 | 512MB |
| `backend` | 本地构建 | 8000 | 512MB |
| `nginx` | `nginx:1.25-alpine` | 80, 443 | 128MB |

**nginx.conf**（`deploy/nginx.conf`）配置：
- `/api/` 反向代理到后端（300 秒超时，支持 SSE）
- `/student` 服务学生端静态文件
- `/admin` 服务管理端静态文件
- `/images/` 服务题目图片（30 天缓存）

### 6.3 云服务器部署

系统支持通过 Docker Compose 部署到 Linux 云服务器。当前小程序代码中的 API 地址 `118.31.34.132` 表明已有云服务器测试环境的配置。

**注意**：
- 正式上线需要配置 HTTPS（当前 Nginx 配置预留了 443 端口和 SSL 目录 `./ssl`）
- 小程序端需要将 API 地址改为 HTTPS 域名，并在微信公众平台配置合法请求域名
- 数据库密码需更换为强密码

### 6.4 小程序部署

小程序代码位于 `source/wx/xzs-student/`，使用微信开发者工具导入即可预览和调试。

AppID：`wx217587125a29c7b5`

**上线要求**：
1. 后端接口必须使用 HTTPS
2. 域名需在微信公众平台配置为合法请求域名
3. 通过微信审核后发布

**当前状态**：开发完成，待配置 HTTPS 后可提交审核。

---

## 7. 开发过程

### 7.1 Git 分支与版本管理

项目使用 Git 进行版本管理，主分支为 `main`，开发分支为 `dev`。功能开发使用 `feature/*` 分支。

### 7.2 分工说明

| 成员 | 主要负责 |
|------|---------|
| 吴天凯 | 数据库设计、后端接口、AI 功能、RAG 架构、爬虫与数据、Docker 部署 |
| 协作者 | 前端页面、小程序页面、界面样式和部分交互功能 |
| 双方共同 | 系统测试、功能联调、报告整理 |

### 7.3 开发里程碑

基于 Git 提交历史整理：

| 阶段 | 时间 | 主要工作 |
|------|------|---------|
| 项目启动 | 2026-04-22 | Fork 开源项目，UI 品牌化改造（408Master） |
| 基础改造 | 2026-04-28 | 学生端 UI 现代化，前端修改 |
| 数据库扩展 | 2026-05-14 | Vue2→Vue3 完整迁移，数据库增强，学习系统表 |
| 爬虫与题库 | 2026-05-15 ~ 05-16 | 编写爬虫，导入 408 真题数据，数据库结构调整 |
| AI 功能 | 2026-05-16 | AI 解析风格、4 种 Prompt 模板、NPE 修复 |
| Docker 部署 | 2026-05-16 | Docker 部署文件、RAG + Embedding、Nginx 配置 |
| 知识图谱 | 2026-05-17 | 知识图谱页面、知识标签数据、UI 稳定化 |
| AI 工作台 | 2026-05-17 ~ 05-19 | AI 学习工作台设计、Prompt 优化、SSE 流式 |
| RAG 架构 | 2026-05-19 | 规范化 AI/RAG 架构、Qdrant 集成、Provider 配置 |
| 题库扩展 | 2026-05-27  | HTML 格式题库导入、AI 工作台编排器 |

---

## 8. 核心接口文档

### 8.1 用户登录接口

| 项目 | 内容 |
|------|------|
| 模块 | 用户认证 |
| 接口名称 | 登录 |
| 请求路径 | `POST /api/user/login` |
| 请求参数 | `userName`, `password`（RSA 加密） |
| 返回结果 | `{ code: 1, response: { token, user } }` |
| 前端页面 | 登录页（admin: `views/login/index.vue`，student: `views/login/index.vue`） |
| 后端代码 | `controller/admin/UserController.java` |

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
| 后端代码 | `controller/student/QuestionController.java` |

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
| 接口名称 | AI 分析（同步） |
| 请求路径 | `POST /api/student/ai/analyze` |
| 请求参数 | `{ style, question, knowledgePoints, taskType }` |
| 返回结果 | `{ analysis, prompt, systemPrompt, style, references[] }` |
| 后端代码 | `controller/student/AIAnalysisController.java` → `AnalysisService` + `RagService` |

| 项目 | 内容 |
|------|------|
| 接口名称 | AI 分析（SSE 流式） |
| 请求路径 | `POST /api/student/ai/analyze-stream` |
| 返回结果 | SSE 事件流：`status` → `references` → `chunk`(多次) → `done` |
| 后端代码 | `controller/student/AIAnalysisController.java:203` |

| 项目 | 内容 |
|------|------|
| 接口名称 | AI 工作台流式 |
| 请求路径 | `POST /api/student/ai/workbench/stream` |
| 请求参数 | `{ intent, style, context, userMessage }` |
| 后端代码 | `controller/student/AiWorkbenchController.java` → `AiOrchestratorServiceImpl` |

### 8.6 AI 配置接口（管理端）

| 项目 | 内容 |
|------|------|
| 接口名称 | 列出 AI 服务商 |
| 请求路径 | `POST /api/admin/ai-config/providers` |
| 后端代码 | `controller/admin/AiConfigController.java` → `AiProviderConfigService.listSafe()` |

| 项目 | 内容 |
|------|------|
| 接口名称 | 保存 AI 服务商 |
| 请求路径 | `POST /api/admin/ai-config/provider/save` |
| 请求参数 | `{ providerCode, providerName, apiBaseUrl, chatModel, embeddingModel, apiKey, enabled, priority }` |
| 后端代码 | `AiProviderConfigServiceImpl.save()`（加密后存储） |

| 项目 | 内容 |
|------|------|
| 接口名称 | RAG 索引构建 |
| 请求路径 | `POST /api/admin/ai-config/rag/index` |
| 请求参数 | `{ source: "all" | "questions" | "knowledge" }` |
| 后端代码 | `AiConfigController.ragIndex()` → `RagDocumentService` + `RagService` + `RagIndexService` |

### 8.7 图片识题接口

| 项目 | 内容 |
|------|------|
| 接口名称 | 图片识题（Web端） |
| 请求路径 | `POST /api/student/question/analyze-image` |
| 请求方式 | `multipart/form-data`，参数 `file` |
| 后端代码 | `controller/student/QuestionController.java:45` → `QuestionService.analyzeImageQuestion()` |

| 项目 | 内容 |
|------|------|
| 接口名称 | 图片识题（小程序端） |
| 请求路径 | `POST /api/wx/student/question/analyze-image` |
| 后端代码 | `controller/wx/student/QuestionController.java` |
| 前端代码 | `pages/ai-analyze/index/index.js`（`wx.uploadFile`） |

### 8.8 知识图谱接口

| 项目 | 内容 |
|------|------|
| 接口名称 | 获取知识图谱 |
| 请求路径 | `GET /api/student/knowledge-graph/graph?subjectId={id}` |
| 后端代码 | `controller/student/KnowledgeGraphController.java` → `KnowledgeGraphService` |

### 8.9 AI 配置接口（学生端 BYOK）

| 项目 | 内容 |
|------|------|
| 接口名称 | 用户私钥列表 |
| 请求路径 | `POST /api/student/ai-config/user-keys` |
| 后端代码 | `controller/student/StudentAiConfigController.java` |

### 8.10 小程序端核心接口

小程序通过 `/api/wx/` 前缀访问后端，核心接口包括：

| 接口路径 | 说明 |
|---------|------|
| `POST /api/wx/student/dashboard/index` | 首页数据 |
| `POST /api/wx/student/exampaper/pageList` | 试卷列表 |
| `POST /api/wx/student/exampaper/select/{id}` | 试卷详情 |
| `POST /api/wx/student/exampaper/answer/answerSubmit` | 提交答卷 |
| `POST /api/wx/student/question/answer/page` | 错题列表 |
| `POST /api/wx/student/question/analyze-image` | 拍照识题 |
| `POST /api/wx/student/question/analyze-question` | AI 题目分析 |

---

## 9. 项目总结

本项目在原有开源考试系统基础上进行了较大幅度的二次开发。通过数据库结构扩展、题库数据采集、AI 解析能力接入、前端 Vue 3 迁移、RAG 向量检索集成、AI 学习工作台设计、微信小程序开发和 Docker 部署适配等工作，将原有面向普通在线考试的系统升级为面向 408 考研的智能学习平台。

项目的技术亮点包括：

1. **四种 AI 解析风格**：通过 JSON 模板实现 Prompt 工程化管理，支持费曼学习法、第一性原理、柏拉图式对话等教学理念。
   - 代码位置：`source/xzs/src/main/resources/ai/prompts/analysis/`

2. **双路径 RAG 检索**：同时支持 Qdrant 向量数据库和内存余弦相似度两种检索路径，确保在向量库不可用时系统仍能正常运行。
   - 代码位置：`source/xzs/src/main/java/com/mindskip/xzs/ai/RagService.java:101-107`

3. **AI Provider 优先级调度**：支持多个 AI 服务商（智谱 GLM、DeepSeek、OpenAI）和用户自带密钥（BYOK），按优先级自动选择。
   - 代码位置：`AnalysisService.java:167-213`

4. **API 密钥 AES-GCM 加密**：所有 AI 密钥在数据库中加密存储，前端永远无法获取明文。
   - 代码位置：`AiProviderConfigServiceImpl.java`

5. **SSE 流式 AI 输出**：支持 Server-Sent Events 实时流式响应，提升用户体验。
   - 代码位置：`AIAnalysisController.java:203-280`

6. **AI 学习工作台**：整合知识点浏览、题目练习、AI 对话、Agent 草案等功能到统一学习场景。
   - 代码位置：`views/dashboard/index.vue`、`AiOrchestratorServiceImpl.java`

通过本项目，我完成了从数据采集、数据库设计、后端接口开发、前端页面开发、AI 接入、向量检索、小程序开发到容器化部署的完整实践。项目体现了传统考试系统向智能学习平台升级的过程，也展示了 AI 技术在具体学习场景中的应用价值。
