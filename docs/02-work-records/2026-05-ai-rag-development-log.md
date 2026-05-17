# 2026-05 AI/RAG 开发记录

## 分支

- 当前主线开发分支：`codex/ai-knowledge-rag`
- GitHub 远端分支：`origin/codex/ai-knowledge-rag`
- 参考基础分支：`feature/ai`
- 预期合并目标：`main`
- PR 创建入口：`https://github.com/tiankai-333/master408/pull/new/codex/ai-knowledge-rag`

`codex/ai-knowledge-rag` 是英文、语义明确、和 GitHub 远端一致的分支名，适合保留。旧的临时分支如果没有形成可演示功能，不建议写入项目亮点。

## 阶段目标

在原学之思考试系统基础上，把 408Master 从“刷题系统”推进到“智能学习系统”：

- 用 RAG 知识库减少 AI 解析幻觉。
- 用四种 Skill 视角提供题目解析和知识讲解：常规、费曼学习法、第一性原理、柏拉图式对话。
- 用 Agent 记录学生学习过程，建立学生画像。
- 用学生反馈反向调整后续 Skill 输出。
- 用爬虫补充高质量 408 知识库，支撑后续问答、解析和学习路径推荐。

## 主要完成内容

### 1. 408 知识点爬虫与知识库

- 新增/完善 `crawler/knowledge_crawler.py`。
- 已形成 `crawler/data/knowledge_pages.json` 快照。
- 爬取知识点页面约 116 条：
  - 数据结构：30 条
  - 计算机组成原理：30 条
  - 操作系统：22 条
  - 计算机网络：34 条
- 数据导入目标包括 `knowledge_point` 和 `t_ai_knowledge_base`。
- 后续可继续扩充方法论资料，例如费曼学习法、第一性原理、柏拉图式对话材料、沉思录片段、马斯克公开讲话等，但应标注来源和用途，避免混入题库事实数据。

### 2. 数据库主线整理

当前生产初始化 SQL 已收敛到 `database/current/`：

- `01_init_structure.sql`：基础表结构、账号、学科。
- `02_extend_fields.sql`：真题兼容字段。
- `04_exam_data.sql`：2011-2024 年 408 综合试卷与题目数据。
- `05_rag_embeddings.sql`：RAG 向量字段。
- `06_ai_knowledge_rag.sql`：AI 知识库、学生画像、学习事件、Skill 反馈闭环表。

历史脚本已归档到 `database/archive/`：

- 旧知识库实验脚本放入 `database/archive/legacy-knowledge/`。
- 历史备份放入 `database/archive/backups/`。
- 测试数据放入 `database/tests/`。

当前部署、导入和 README 不再把旧知识库实验脚本作为主线依赖。

### 3. RAG 与 Skill/Agent 能力

- RAG 检索优先使用 `t_ai_knowledge_base` 中的结构化知识库与 embedding。
- 保留旧 `t_text_content.embedding` 兼容路径。
- 增加关键词 fallback，避免没有 embedding 时完全不可用。
- 学生端 AI 解析支持四种风格：
  - `default`
  - `feynman`
  - `first-principles`
  - `plato`
- AI 分析接口记录 `usageLogId`，便于后续反馈闭环。
- 反馈接口把用户对解析的评价写回，用于后续 Agent 调整。
- 学生画像和学习事件为后续“根据真实学习过程生成个性化建议”打基础。

### 4. 前后端与数据修复

- 修复试卷中心学科、侧边栏点击、列表条数和页面可见性问题。
- 修复试卷答题选项重合问题。
- 修复批改界面无法取消的问题。
- 408Master 最右侧面板改为基于真实接口数据，避免展示静态假数据。
- 补充正常做题记录，便于演示学生学习轨迹和正确率统计。
- 修复部分真题图片路径，静态图片可通过后端 `/images/...` 访问。
- 已检查的图片状态包括 15 个唯一图片文件、题目图片引用和综合题图片引用。

### 5. 微信小程序跑通

- 小程序目录：`source/wx/xzs-student`。
- 开发阶段 `globalData.baseAPI` 调整为本地后端地址。
- 后端微信绑定在未配置正式 AppSecret 时支持开发模式，便于本地跑通。
- 小程序试卷列表取消学生年级过滤后，可以看到 408 综合试卷。
- 已验证小程序绑定、试卷列表、试卷详情的基础链路。

### 6. 部署准备

- 推荐部署分支：`codex/ai-knowledge-rag`。
- 推荐部署目录：`/opt/xzs-deploy`。
- 当前部署资料：
  - `deploy/README.md`
  - `deploy/REDEPLOY_GUIDE.md`
  - `docs/04-deployment/朋友远程部署操作手册.md`
- 因当前网络环境 SSH 受限，部署需要能连上服务器的同学按文档执行。
- 朋友部署时应只导入 `database/current/` 中的 SQL 主线文件。

## 已验证结果

- 后端构建：`mvn package -DskipTests` 通过。
- 学生端构建：`npm run build` 曾通过。
- 学生/管理登录接口曾返回成功。
- `/api/student/ai/styles` 返回四种 Skill 风格。
- `/api/student/knowledge-graph/graph` 曾返回 120 个节点、228 条关系、4 个分类。
- `/api/student/ai/feedback` 曾返回成功。
- `/api/admin/ai-agent/knowledge-base/statistics` 曾返回成功。
- RAG debug 查询“虚拟存储器”曾返回 3 条知识文档。
- 静态图片 `/images/2012/2012_44.svg` 曾返回 HTTP 200。
- 小程序 bind、paper list、paper detail 基础链路曾跑通。

## 后续风险和建议

- Embedding 生成还需要自动化，避免知识库只有文本、没有稳定向量。
- 小程序正式上线需要真实 AppID/AppSecret、HTTPS 域名和微信公众平台 request 合法域名配置。
- 云端部署受 SSH 白名单或异地网络限制影响，需由可连接服务器的人执行。
- 旧 SQL 已归档，生产初始化不要导入 `database/archive/legacy-knowledge/`。
- 方法论资料可以增强 Skill 表达，但应和 408 学科事实知识分层存储，避免检索时污染题目事实解释。
- 后续写项目汇报时，可以把亮点概括为“408 题库 + RAG 知识库 + 四视角 Skill + 学生画像 Agent + 反馈闭环”。
