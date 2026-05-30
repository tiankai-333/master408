# 408Master 智能学习平台——项目设计与实现说明

## 1. 项目概述

### 1.1 项目背景

本项目基于开源考试系统 xzs（学之思）进行二次开发。原系统面向常规在线考试场景，提供题目管理、试卷管理、答题记录和用户管理等基础功能。为适配 408 计算机考研复习的学习场景，在原系统基础上完成了以下主要工作：

1. **数据库结构扩展**：为 `t_question` 表增加 16 个扩展字段（题干 HTML、选项 JSON、正确答案、解析、图片路径等），并新增知识点关联、AI 配置、RAG 索引、学习档案等相关数据表。
2. **题库数据采集与导入**：通过 Python 爬虫从公开考研网站抓取 408 真题数据，包括选择题、综合题、知识标签和 HTML 题源文件，经清洗后导入数据库。
3. **AI 解析能力接入**：实现四种 AI 解析风格（标准解析、费曼学习法、第一性原理、柏拉图式对话），支持 SSE 流式输出，后端统一管理 API 密钥。
4. **RAG 检索增强**：集成 Qdrant 向量数据库，使用 GLM Embedding-2 模型生成文本向量（维度由 API 返回值动态决定），支持题目解析的语义检索。
5. **前端完整迁移至 Vue 3**：管理端和学生端均已从 Vue 2 迁移到 Vue 3 + Vite + Element Plus + Pinia。
6. **微信小程序端开发**：基于微信小程序原生开发，包含 16 个页面，支持做题、错题本、AI 图片识题等功能。
7. **Docker 部署适配**：编写 Dockerfile、docker-compose.yml 和 Nginx 配置，支持容器化一键部署。

### 1.2 项目目标

本项目的目标是构建一个面向 408 考研复习的智能学习平台，在保留原有考试功能的基础上，扩展以下能力：

1. 大规模 408 题库数据管理（支持 HTML 题干、图片、复杂选项）；
2. AI 多风格题目解析与知识点讲解；
3. 基于向量检索的 RAG 增强回答；
4. AI 学习工作台（整合知识点浏览、题目练习、AI 对话）；
5. Web 端与微信小程序端共享同一套后端接口；
6. Docker 容器化部署，支持迁移到云服务器。

---

## 2. 数据库设计

### 2.1 原系统数据库概要

原开源系统 xzs 围绕在线考试业务设计，核心表包括 `t_user`（用户）、`t_subject`（科目）、`t_text_content`（文本内容）、`t_question`（题目）、`t_exam_paper`（试卷）、`t_task_exam`（任务考试）、`t_exam_paper_answer`（答题记录）、`t_message`（消息）等十余张表。题目数据通过 `info_text_content_id` 字段关联 `t_text_content` 表，以 JSON 格式存储。

原系统没有独立的错题本表，错题功能通过查询答题详情表中 `do_right` 字段为 false 的记录实现。

### 2.2 原系统的局限性

1. **题目数据结构单一**：缺少题干 HTML、选项、正确答案、解析等独立字段，无法直接支持复杂题干和图片题。
2. **缺少知识点关联**：没有知识点表和题目-知识点关联表，无法按知识点维度组织题库。
3. **缺少 AI 功能支持**：没有 AI 配置表、Prompt 模板表、使用日志表等基础设施。
4. **图片资源无统一管理**：缺少图片路径字段和静态资源服务配置。

### 2.3 数据库扩展方案

#### 2.3.1 题目表扩展

通过 `database/current/02_extend_fields.sql` 为 `t_question` 增加 16 个扩展字段，涵盖题干 HTML（`title`）、选项 JSON（`options`）、正确答案（`correct_answer`）、解析 HTML（`analysis`）、难度等级、知识点标签、来源年份与题号、图片路径、内容格式标记等。同时为 `t_exam_paper` 增加来源年份和描述字段，新增 `t_essay_question` 表存储综合应用题。

#### 2.3.2 知识点系统

新增 `knowledge_point` 表（支持父子层级，`parent_id` 自引用）和 `question_knowledge_point` 关联表（多对多，含 `relevance` 权重字段），实现按知识点维度组织题库的能力。

#### 2.3.3 AI 与 RAG 相关表

为支持 AI 解析和 RAG 功能，新增以下数据表：

- **AI 配置与日志**：`ai_provider_config`（服务商密钥配置，密钥加密存储）、`t_ai_usage_log`（调用日志，含 token 用量和费用）、`t_ai_prompt_template`（Prompt 模板）、`t_ai_adjustment_log`（模板调整审计）。
- **RAG 索引**：`rag_document`（文档元数据）、`rag_chunk`（文本分块）、`rag_embedding`（向量索引元数据），构成三层索引结构。
- **内容管理**：`question_content`（题目内容版本化）、`question_source`（题目来源追踪）。
- **Agent 模块**：`ai_agent`、`ai_skill`、`ai_agent_skill`（Agent 与技能模块定义）。
- **用户密钥**：`ai_user_key`（用户自带密钥，BYOK，加密存储）。

此外，`t_text_content` 表增加了 `embedding` 列用于存储向量数据，`t_ai_knowledge_base` 表增加了 RAG 相关字段。

#### 2.3.4 学习档案相关表

新增 `t_user_learning_profile`（学习画像）、`t_user_learning_event`（学习事件流水）、`t_user_skill_feedback`（解析风格反馈）、`student_learning_event`（规范化学习事件）、`student_knowledge_state`（知识点掌握状态）、`student_mistake_book`（规范化错题本）等表，为个性化学习提供数据基础。

#### 2.3.5 小程序端

小程序端不需要修改数据库结构。小程序通过 `/api/wx/` 前缀的专用 Controller 访问与 Web 端相同的数据库，后端新增 7 个 WX 专用 Controller（`controller/wx/student/` 包下），复用相同的 Service 和 Mapper 层。

---

## 3. 数据采集与导入

### 3.1 数据来源

408 题库数据来自公开考研学习网站 csgraduates.com。通过 Python 爬虫程序抓取题目、选项、答案、解析、知识标签和图片等内容，经清洗后导入数据库。

数据仅用于课程设计、学习研究和教学演示，不用于商业传播。

### 3.2 数据规模

| 数据类型 | 数量 |
|---------|------|
| 选择题 | 约 560 道 |
| 综合题 | 约 98 道 |
| 知识标签 | 658 条 |
| HTML 真题源文件 | 228 个（覆盖 2009–2026 年 408、数学、英语、政治等科目） |
| 知识点 HTML 内容 | 4 科目录（数据结构、计算机网络、计算机组成原理、操作系统） |
| 题目图片 | 约 17 个（SVG/JPG 格式，主要涉及包含图表的组成原理和计算机网络题） |
| 原始真题 PDF | 30 个（2009–2024 年） |

> 数据量统计方法详见附录 A。

### 3.3 爬虫设计

爬虫代码位于 `crawler/` 目录，入口文件 `main.py` 支持命令行参数（按科目、年份筛选等）。核心脚本包括基础爬虫类 `CSGraduatesCrawler`、带图片下载的题目爬取、JSON/CSV 转 SQL 生成脚本、HTML 题源 SQL 生成脚本、知识标签爬取脚本等，共 19 个 Python 文件。

### 3.4 图片数据管理

题目图片存储于 `deploy/static/images/{年份}/` 目录下，数据库 `t_question.images` 字段记录图片路径。前端通过 `QuestionHtml.vue` 组件渲染 HTML 题干，图片以 `<img>` 标签嵌入。Nginx 配置了 `/images/` 路径的静态资源服务（30 天缓存）。迁移脚本 `15_embed_question_images.sql` 负责将图片路径注入到 `title` 字段中。

---

## 4. 功能实现

### 4.1 题目管理

**后端**：管理端（`controller/admin/QuestionController`）提供题目的分页查询、创建编辑、删除、文本导入和 JSON 批量导入接口；学生端（`controller/student/QuestionController`）提供题目详情查询、图片识题和 AI 分析接口。Service 层封装 CRUD 操作和 AI 识题逻辑，Mapper 层使用 MyBatis 实现数据访问。

**前端**：管理端支持 5 种题型（单选、多选、判断、填空、简答）的独立编辑器（`source/vue/xzs-admin/src/views/exam/question/edit/`）。学生端在试卷答题和错题本页面中查看题目。

### 4.2 试卷与答题

管理端和学生端分别提供试卷列表和详情查询接口。学生可在线答题并提交答卷，教师可批改简答题。

此外，系统实现了 AI 辅助组卷功能：后端根据学生请求，从题库中筛选题目并生成练习试卷（`service/impl/AiPaperComposeServiceImpl.java`）。

### 4.3 错题本

错题本通过查询答题详情表筛选 `do_right = false` 的记录实现，前端页面（`views/question-error/index.vue`）展示错题列表并集成 AI 分析功能，支持四种解析风格的 SSE 流式输出。

### 4.4 图片识题

用户上传题目图片后，系统调用大模型的多模态能力识别图片中的题目内容。Web 端支持拖拽上传（JPG/PNG/GIF，最大 10MB），小程序端通过 `wx.chooseMedia` + `wx.uploadFile` 实现。该功能依赖外部 AI 服务商的多模态能力，而非传统 OCR 技术。

### 4.5 AI 解析风格

系统提供四种 AI 解析风格，区别在于 Prompt 模板设计不同：

| 风格 | 核心思路 |
|------|---------|
| 标准解析 | 专业 408 辅导老师，全面、条理清晰、紧扣考点 |
| 费曼学习法 | 把复杂概念翻译成大白话，用生活场景类比 |
| 第一性原理 | 从基本定义出发，质疑假设，逻辑推导 |
| 柏拉图式对话 | 通过层层追问引导学生自己发现答案 |

模板以 JSON 文件形式存储于 `resources/ai/prompts/analysis/` 目录，`AnalysisService` 启动时动态加载。如果文件加载失败，回退到硬编码的默认模板。前端传递 `style` 参数选择风格，后端通过 `PromptTemplate.formatUserPrompt()` 替换占位符后调用大模型。

### 4.6 AI 学习工作台

AI 学习工作台由以下功能模块协同构成：

1. **学生端首页（Dashboard）**：展示学习统计（已做题数、正确率、各科目进度），提供"开始刷题"和"查看知识图谱"入口。
2. **知识图谱页面**：按科目展示知识点目录树，支持搜索和层级浏览。选择知识点后可查看详情、关联知识点和关联真题。
3. **AI 对话接口**：通过 `POST /api/student/ai/workbench/stream`（SSE）与后端交互，支持围绕题目或知识点的多轮对话。
4. **RAG 检索**：对话过程中自动从向量数据库或内存索引中检索相关参考资料，增强回答质量。
5. **意图路由**：`AiIntentRouter` 通过正则表达式匹配用户消息，自动识别 6 种意图（题目讲解、知识点讲解、学习画像、练习规划、组卷、自由对话），走不同处理路径。
6. **Agent 草案**：练习规划意图触发 Agent 草案流程——先生成包含候选题目 ID 的草案供用户确认，确认后再调用组卷接口生成正式试卷。

后端编排逻辑由 `AiOrchestratorServiceImpl` 根据意图路由结果，分别调用 RAG 检索、Agent 草案生成、AI 分析等处理路径，通过 SSE 流式返回结果。

### 4.7 小程序功能

小程序端位于 `source/wx/xzs-student/`，采用微信小程序原生开发，包含 16 个页面：

| 功能模块 | 页面 |
|---------|------|
| 首页与做题 | 首页、试卷列表、答题（计时）、查看答卷 |
| 错题 | 错题列表、错题详情（含 4 种风格 AI 分析） |
| AI 识题 | 拍照识题（图片上传 + AI 识别） |
| 个人中心 | 个人信息、活动日志、消息列表/详情 |
| 用户 | 微信绑定、注册 |

底部 TabBar 设 4 个入口：首页、刷题、错题、大师。小程序通过 `/api/wx/` 前缀访问后端，与 Web 端共享同一套 Service 层，使用 iView Weapp 组件库。

---

## 5. 架构设计

### 5.1 整体架构

```
┌─────────────┐  ┌──────────────┐  ┌──────────────┐
│  Web 管理端  │  │  Web 学生端   │  │  微信小程序   │
│  xzs-admin   │  │  xzs-student │  │  原生开发     │
│  Vue 3 + Vite│  │  Vue 3 + Vite│  │  iView Weapp │
└──────┬───────┘  └──────┬───────┘  └──────┬───────┘
       │                 │                  │
       └────────┬────────┘                  │
                │ HTTP / SSE                │ /api/wx/
       ┌────────▼────────┐                  │
       │  Spring Boot     │                  │
       │  后端 API        │                  │
       └──┬────┬────┬────┘
          │    │    │
   ┌──────▼┐  │  ┌─▼────────┐
   │ MySQL │  │  │  Qdrant   │
   │  8.0  │  │  │ 向量数据库 │
   └───────┘  │  └───────────┘
         ┌────▼─────┐
         │ AI 模型服务 │
         └──────────┘
```

三个前端（Web 管理端、Web 学生端、微信小程序）通过 HTTP/SSE 统一访问 Spring Boot 后端。后端连接 MySQL 存储业务数据，Qdrant 存储向量索引，并对接多个 AI 模型服务商。

### 5.2 Vue 3 迁移

两个前端项目均已完成从 Vue 2 到 Vue 3 的迁移，具体包括：路由从 Vue Router 2.x 升级到 4.x（`createRouter` + `createWebHistory`），状态管理从 Vuex 迁移到 Pinia，全面采用组合式 API（Composition API），构建工具从 Webpack 迁移到 Vite。

| 项目 | Vue 版本 | 构建工具 | UI 框架 | 状态管理 |
|------|---------|---------|---------|---------|
| xzs-admin | 3.4 | Vite 5.4 | Element Plus 2.9 | Pinia 2.3 |
| xzs-student | 3.5 | Vite 6.0 | Element Plus 2.9 | Pinia 2.3 |

### 5.3 AI 整体架构

AI 架构分为三层：

**前端交互层**：收集用户问题、解析风格和题目上下文，通过 SSE 接收流式响应。

**后端编排层**（`AnalysisService` + `RagService` + `AiOrchestratorServiceImpl`）：
1. 从数据库获取 AI 服务商配置（支持多提供商按优先级排序）
2. 通过意图路由判断请求类型
3. 选择对应风格的 Prompt 模板并组织 Prompt
4. 调用 Embedding 模型生成向量，从 Qdrant 或内存索引检索相关内容
5. 将检索结果拼接进 Prompt
6. 调用大语言模型生成回答（SSE 流式输出）
7. 记录使用日志（含 token 用量、费用计算和耗时）

**模型调用层**：对接不同 AI 服务商的 OpenAI 兼容 API。`AiPricing` 为 14 种模型定义了三层定价（输入/输出/缓存命中）。

**AI Provider 优先级调度**：
1. 数据库中启用的公共密钥（`ai_provider_config` 表），按 `priority` 升序排列
2. 当前用户的私人密钥（`ai_user_key` 表，BYOK）
3. `application.yml` 中的默认配置（`glm-4.5-air`，智谱 BigModel）作为兜底

### 5.4 RAG 架构

RAG 检索支持两条路径：

**路径一：Qdrant 向量数据库**（当配置 `ai.rag.vector.enabled=true` 时激活，默认关闭）。使用 Cosine 距离度量，向量维度从 API 返回值动态获取，集合名 `xzs_408_chunks`。

**路径二：内存余弦相似度**（默认路径）。从 `t_text_content` 表加载含 `embedding` 的记录，缓存 5 分钟，实时计算余弦相似度。

两条路径的检索参数一致：Top-K 为 5，相似度阈值为 0.5。

**Embedding 生成**：默认使用 `embedding-2` 模型，API 地址 `https://open.bigmodel.cn/api/paas/v4/embeddings`，文本截断 8000 字符。维度由 API 返回值动态决定，代码中未硬编码维度值。

**离线脚本**：`scripts-embedding/embed_questions.py` 从 `t_text_content` 读取未生成向量的记录并写入数据库；`scripts-embedding/embed_rag_chunks_to_qdrant.py` 从 `rag_chunk` 表读取分块，生成向量并写入 Qdrant。

### 5.5 密钥安全性设计

API 密钥使用 AES-256-GCM 加密后存储在数据库中。加密参数包括：随机 12 字节 IV、128 位 Tag、SHA-256 派生 256 位 AES 密钥。`listSafe()` 方法返回数据时将密钥字段设为 null，前端永远无法获取密钥明文。管理端展示脱敏后的 `apiKeyMask` 字段，学生端仅可见公钥服务商的名称和模型信息。

用户自带密钥（BYOK）同样使用 AES-256-GCM 加密存储，仅该用户可用。

### 5.6 小程序架构

小程序采用微信原生开发，不直接访问数据库，不保存 AI 密钥，统一通过后端 `/api/wx/` 接口访问系统能力。小程序端还包含 Markdown 渲染工具（`utils/markdown.js`），用于将 AI 返回的 Markdown 格式解析结果渲染为 HTML。

> 当前 API 地址使用 HTTP 协议，用于开发测试。正式上线前需改为 HTTPS 并在微信公众平台配置合法请求域名。

---

## 6. 部署设计

### 6.1 本地开发环境

本地开发环境配置位于 `application-dev.yml`：MySQL 连接 `localhost:3306/xzs`，Qdrant 地址 `http://127.0.0.1:6333`（默认启用）。前端通过 Vite 开发服务器启动，后端通过 Spring Boot 启动。

### 6.2 Docker 容器化部署

Docker 部署文件位于 `deploy/` 目录，`docker-compose.yml` 定义 4 个服务：

| 服务 | 镜像 | 端口 | 内存限制 |
|------|------|------|---------|
| mysql | MySQL 8.0.33 | 内部 3306 | 512MB |
| qdrant | qdrant/qdrant:latest | 6333, 6334 | 512MB |
| backend | 本地 Dockerfile 构建（Java 8） | 8000 | 512MB |
| nginx | nginx:1.25-alpine | 80, 443 | 128MB |

所有服务运行在 `xzs-net` bridge 网络上。Nginx 负责反向代理（`/api/` → 后端，300 秒超时，`proxy_buffering off` 以支持 SSE）、静态文件服务（学生端、管理端、题目图片）和路由重定向。

### 6.3 云服务器部署

系统支持通过 Docker Compose 部署到 Linux 云服务器，已配置云服务器测试环境。正式上线需做以下调整：

- 配置 HTTPS（Nginx 配置已预留 443 端口和 SSL 目录，待配置证书）
- 小程序端 API 地址改为 HTTPS 域名，并在微信公众平台配置合法请求域名
- 数据库密码和 AI 密钥主密钥更换为安全值

### 6.4 小程序部署

小程序代码使用微信开发者工具导入即可预览和调试。当前状态为开发完成，可在开发者工具中预览；待配置 HTTPS 后可提交微信审核。

---

## 7. 开发过程

### 7.1 版本管理

项目使用 Git 进行版本管理，主分支为 `main`，开发分支为 `dev`。功能开发使用 `feature/*` 分支（如 `feature/ai`、`feature/crawler-and-exam-data`、`feature/ui-branding`）。

### 7.2 分工说明

| 成员 | 主要负责 |
|------|---------|
| 吴天凯（Tucker_Wu） | 数据库设计、后端接口、AI 功能、RAG 架构、爬虫与数据、Docker 部署 |
| 协作者 | 前端页面、小程序页面、界面样式和部分交互功能 |
| 双方共同 | 系统测试、功能联调、报告整理 |

### 7.3 开发里程碑

| 阶段 | 时间 | 主要工作 |
|------|------|---------|
| 项目启动 | 2026-04-22 | Fork 开源项目，UI 品牌化改造 |
| 基础改造 | 2026-04-28 | 学生端 UI 现代化 |
| 框架迁移 | 2026-05-14 | Vue 2 → Vue 3 完整迁移，数据库增强 |
| 数据导入 | 2026-05-15~16 | 编写爬虫，导入 408 真题数据 |
| AI 功能 | 2026-05-16 | AI 解析风格、Prompt 模板 |
| 容器化 | 2026-05-16 | Docker 部署、RAG + Embedding、Nginx |
| 知识图谱 | 2026-05-17 | 知识图谱页面、知识标签数据 |
| AI 工作台 | 2026-05-17~19 | AI 学习工作台设计、SSE 流式 |
| 题库扩展 | 2026-05-27~28 | HTML 格式题库导入、AI 工作台编排器 |

---

## 8. 核心接口概览

以下列出系统各模块的主要接口。详细接口说明（请求/响应格式、参数定义等）见附录 B。

### 8.1 题目与试卷

| 接口 | 方法 | 路径 | 说明 |
|------|------|------|------|
| 题目分页 | POST | `/api/admin/question/page` | 管理端题目列表 |
| 题目详情 | POST | `/api/student/question/select/{id}` | 学生端查看题目 |
| 试卷列表 | POST | `/api/student/exam/paper/pageList` | 学生端试卷列表 |
| 提交答卷 | POST | `/api/student/exampaper/answer/answerSubmit` | 提交答题结果 |

### 8.2 错题与统计

| 接口 | 方法 | 路径 | 说明 |
|------|------|------|------|
| 错题列表 | POST | `/api/student/question/answer/page` | 答题记录（可筛选错题） |
| 用户统计 | GET | `/api/student/user/stats` | 已做题数、正确率、科目分布 |

### 8.3 AI 相关

| 接口 | 方法 | 路径 | 说明 |
|------|------|------|------|
| AI 分析（同步） | POST | `/api/student/ai/analyze` | 单次 AI 分析 |
| AI 分析（流式） | POST | `/api/student/ai/analyze-stream` | SSE 流式分析 |
| AI 工作台 | POST | `/api/student/ai/workbench/stream` | SSE 工作台对话 |
| Agent 草案 | POST | `/api/student/ai/agent/plan` | 生成练习草案 |
| 确认草案 | POST | `/api/student/ai/agent/confirm` | 确认后生成试卷 |
| AI 组卷 | POST | `/api/student/ai/compose-paper` | AI 辅助组卷 |
| 图片识题 | POST | `/api/student/question/analyze-image` | 多模态图片识别 |

### 8.4 知识图谱

| 接口 | 方法 | 路径 | 说明 |
|------|------|------|------|
| 图谱数据 | GET | `/api/student/knowledge-graph/graph` | 获取知识图谱 |
| 知识点详情 | GET | `/api/student/knowledge-graph/knowledge-point/{id}` | 单个知识点 |
| 题目关联知识点 | GET | `/api/student/knowledge-graph/question/{questionId}/knowledge-points` | 反向查询 |

### 8.5 小程序端

小程序通过 `/api/wx/` 前缀访问后端，核心接口包括首页数据、试卷列表/详情、答题提交/查看、错题列表、图片识题、AI 题目分析和微信绑定，共 7 个 WX 专用 Controller 复用 Web 端 Service 层。

### 8.6 AI 配置（管理端）

| 接口 | 方法 | 路径 | 说明 |
|------|------|------|------|
| 服务商列表 | POST | `/api/admin/ai-config/providers` | 脱敏展示 |
| 保存服务商 | POST | `/api/admin/ai-config/provider/save` | 密钥加密存储 |
| 测试连通性 | POST | `/api/admin/ai-config/provider/{id}/test` | 验证 API 可达 |
| RAG 索引构建 | POST | `/api/admin/ai-config/rag/index` | 触发向量索引构建 |

---

## 9. 项目总结

本项目在原有开源考试系统基础上进行了较大幅度的二次开发，覆盖了从数据采集到部署上线的完整工程链路：

1. **数据层**：设计并执行 Python 爬虫采集 408 真题数据，扩展数据库结构以支持复杂题干、知识点关联和 AI 功能所需的元数据，共编写 20 个 SQL 迁移脚本。

2. **后端层**：在 Spring Boot 框架上新增 AI 解析服务、RAG 检索服务、意图路由、Agent 草案生成、AI 辅助组卷等能力，实现了多 AI 服务商的优先级调度和密钥安全管理。

3. **前端层**：将管理端和学生端从 Vue 2 完整迁移到 Vue 3 + Vite + Element Plus + Pinia，开发了知识图谱浏览、AI 对话工作台等新功能。

4. **AI/RAG 层**：实现了双路径 RAG 检索（Qdrant 向量数据库 + 内存余弦相似度）、四种 Prompt 模板化的 AI 解析风格、SSE 流式输出和 AI 费用追踪。

5. **小程序端**：基于微信原生开发 16 个页面，复用后端 Service 层，支持做题、错题本、AI 图片识题和 AI 分析。

6. **部署层**：编写 Docker Compose 四服务容器化部署方案（MySQL + Qdrant + Spring Boot + Nginx），Nginx 配置支持 SSE 长连接和静态资源服务。

项目体现了传统考试系统向智能学习平台升级的完整过程，也展示了 AI 技术在具体学习场景中的应用方式。

---

## 10. 项目局限与后续完善

本项目作为课程设计作品，在以下方面仍有完善空间：

1. **题库数据精确校验**：选择题数据约 560 道，综合题约 98 道。建议进一步核对 JSON 数组长度与数据库实际导入行数的一致性，排除空行和数据格式差异带来的统计偏差。

2. **Embedding 维度**：代码中使用 `embedding-2` 模型，维度由 API 返回值动态决定，未硬编码。当前未对向量维度做显式校验，后续可加入维度一致性检查。

3. **图片识题实现**：该功能依赖外部 AI 服务商的多模态能力，具体的模型调用方式（如服务商的视觉 API 版本、调用参数等）需根据实际配置进一步确认。

4. **小程序上线状态**：小程序开发已完成，可在微信开发者工具中预览和调试。上线前需配置 HTTPS、在微信公众平台备案域名并通过审核，目前尚未提交审核。

5. **云服务器部署**：Docker Compose 配置已完成，具备部署到云服务器的能力。正式上线前需配置 SSL 证书、更换默认密码和密钥。

6. **数据库迁移脚本**：`05_rag_embeddings.sql` 中有一处 schema 名称硬编码为 `xzas`（疑为 `xzs` 的笔误），建议在实际执行前确认并修正。

7. **分工说明**：报告中"协作者"的具体身份和贡献细节需根据实际情况补充。

8. **数据量统计**：不同统计方式（JSON 字段计数、CSV 行数、文件系统计数）可能产生略有差异的结果，报告中选择保守数字。建议在最终提交前统一统计口径。

---

## 附录 A：数据量统计方法

| 数据类型 | 统计方式 | 原始数据 |
|---------|---------|---------|
| 选择题 | `exam_questions.json` 中 `"year"` 字段出现次数 | 约 560 次 |
| 选择题 CSV | `wc -l` 统计行数 | 931 行（含表头） |
| 综合题 | `essay_questions.csv` 行数 | 715 行（含表头） |
| 知识标签 | `knowledge_tags.json` 数组长度 | 658 条 |
| HTML 真题源文件 | `find -name "*.html"` 递归统计 | 228 个 |
| 题目图片 | `find -type f` 统计 | `images/` 下 15 个 + `essay_images/` 下 2 个 = 17 个 |
| 真题 PDF | `find -name "*.pdf"` 统计 | 30 个 |

---

## 附录 B：详细接口文档

### B.1 用户登录

| 项目 | 内容 |
|------|------|
| 请求路径 | `POST /api/user/login` |
| 请求参数 | `userName`, `password`（RSA 加密） |
| 返回结果 | `{ code: 1, response: { token, user } }` |
| 实现方式 | Spring Security Filter（`RestLoginAuthenticationFilter`） |

### B.2 AI 解析风格

| 项目 | 内容 |
|------|------|
| 可用风格 | `GET /api/student/ai/styles` → `["default", "feynman", "plato", "first-principles"]` |
| Prompt 模板 | `GET /api/student/ai/template/{style}` |
| 同步分析 | `POST /api/student/ai/analyze`，参数：`{ style, question, knowledgePoints, taskType }` |
| 流式分析 | `POST /api/student/ai/analyze-stream`（`text/event-stream`），事件流：`status` → `references` → `chunk`(多次) → `done` |

### B.3 AI 工作台

| 项目 | 内容 |
|------|------|
| 流式对话 | `POST /api/student/ai/workbench/stream`（`text/event-stream`），参数：`{ intent, style, context, userMessage }` |
| Agent 草案 | `POST /api/student/ai/agent/plan`，参数：`AiAgentPlanRequestVM` |
| 确认草案 | `POST /api/student/ai/agent/confirm` |

### B.4 AI 配置（管理端）

| 项目 | 内容 |
|------|------|
| 服务商列表 | `POST /api/admin/ai-config/providers`，返回脱敏数据（`listSafe()`） |
| 保存服务商 | `POST /api/admin/ai-config/provider/save`，参数：`{ providerCode, providerName, apiBaseUrl, chatModel, embeddingModel, apiKey, enabled, priority }` |
| 测试连通性 | `POST /api/admin/ai-config/provider/{id}/test` |
| RAG 索引构建 | `POST /api/admin/ai-config/rag/index`，参数：`{ source: "all" \| "questions" \| "knowledge" }` |

### B.5 AI 配置（学生端 BYOK）

| 项目 | 内容 |
|------|------|
| 公共服务商列表 | `POST /api/student/ai-config/providers` |
| 用户密钥列表 | `POST /api/student/ai-config/user-keys` |
| 保存用户密钥 | `POST /api/student/ai-config/user-key/save` |

### B.6 图片识题

| 项目 | 内容 |
|------|------|
| Web 端 | `POST /api/student/question/analyze-image`（`multipart/form-data`，参数名 `file`） |
| 小程序端 | `POST /api/wx/student/question/analyze-image`（`wx.uploadFile`） |

### B.7 知识图谱

| 接口 | 方法 | 路径 | 说明 |
|------|------|------|------|
| 图谱数据 | GET | `/api/student/knowledge-graph/graph` | 支持 `?subjectId=` 筛选 |
| 知识点详情 | GET | `/api/student/knowledge-graph/knowledge-point/{id}` | 含关联知识点和题目 |
| 题目关联知识点 | GET | `/api/student/knowledge-graph/question/{questionId}/knowledge-points` | 反向查询 |
| 知识点下的题目 | GET | `/api/student/knowledge-graph/knowledge-point/{id}/questions` | 支持 `?limit=` |

### B.8 小程序端接口

| 接口路径 | 方法 | 说明 |
|---------|------|------|
| `/api/wx/student/dashboard/index` | POST | 首页数据 |
| `/api/wx/student/exampaper/pageList` | POST | 试卷列表 |
| `/api/wx/student/exampaper/select/{id}` | POST | 试卷详情 |
| `/api/wx/student/exampaper/answer/answerSubmit` | POST | 提交答卷 |
| `/api/wx/student/exampaper/answer/read/{id}` | POST | 查看答卷 |
| `/api/wx/student/question/answer/page` | POST | 错题列表 |
| `/api/wx/student/question/analyze-image` | POST | 拍照识题 |
| `/api/wx/student/question/analyze-question` | POST | AI 分析 |
| `/api/wx/student/auth/bind` | POST | 微信绑定 |
| `/api/wx/student/auth/checkBind` | POST | 检查绑定状态 |
