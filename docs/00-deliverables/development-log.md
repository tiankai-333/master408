# 408Master 开发记录

## 2026-04-22 项目启动

- Fork xzs（学之思）开源考试系统
- 确定项目方向：基于原系统二次开发，构建 408 考研智能学习平台
- 开始 UI 品牌化改造（408Master）

## 2026-04-28 学生端 UI 改造

- 学生端界面现代化改造
- 调整布局和交互流程

## 2026-05-14 Vue 2 → Vue 3 完整迁移与数据库扩展

- 管理端（xzs-admin）和学生端（xzs-student）从 Vue 2 迁移到 Vue 3 + Vite + Element Plus + Pinia
- 路由从 Vue Router 2.x 升级到 4.x（createRouter + createWebHistory）
- 状态管理从 Vuex 迁移到 Pinia
- 构建工具从 Webpack 迁移到 Vite
- 为 `t_question` 增加 16 个扩展字段（题干 HTML、选项 JSON、正确答案、解析、图片路径等）
- 增加 `knowledge_point`、`question_knowledge_point` 知识点关联表
- 增加 `t_ai_usage_log`、`t_ai_prompt_template`、`t_ai_knowledge_base` 等 AI 基础表
- 增加 `t_user_learning_profile`、`t_user_learning_event`、`t_user_skill_feedback` 等学习档案表

## 2026-05-15 至 2026-05-16 题库爬虫与数据导入

- 编写 Python 爬虫抓取 csgraduates.com 公开考研数据
- 抓取选择题约 560 道、综合题约 98 道、知识标签 658 条、HTML 题源 228 个
- 编写 SQL 生成脚本将 JSON/CSV 数据导入数据库
- 生成 HTML 格式题目的 SQL 导入脚本
- 生成知识点 HTML 内容的 SQL 导入脚本
- 下载题目图片（SVG/JPG 格式）到静态资源目录

## 2026-05-16 AI 功能

- 实现 4 种 AI 解析风格（标准解析、费曼学习法、第一性原理、柏拉图式对话），每种对应独立 JSON Prompt 模板文件
- 后端 `AnalysisService` 启动时动态加载模板，加载失败回退硬编码默认
- 接入 SSE 流式输出，AI 回复边生成边推送给前端
- 后端统一管理 AI 密钥，API Key 采用 AES/GCM 加密存储，前端只显示掩码
- AI 解析和 Embedding 调用写入 `t_ai_usage_log`（含 token 用量、费用、耗时）
- 修复 AI 流式输出中 JSON null 被误当成正文 token 的问题
- 修复流式失败态：失败时只显示明确错误信息，不追加本地假回答

## 2026-05-16 Docker 部署

- 编写 Dockerfile（Java 8 基础镜像）
- 编写 docker-compose.yml（MySQL + Qdrant + Backend + Nginx 四服务）
- 配置 Nginx 反向代理，支持 SSE 长连接和静态资源服务
- 根地址默认跳转 /student/index，管理端 base 修正为 /admin/
- 本地部署验证完成：学生端构建通过，知识图谱和 AI 工作台页面可访问

## 2026-05-17 知识图谱

- 增加 `KnowledgeGraphController`，提供图谱数据、知识点详情、题目关联知识点等接口
- 学生端增加知识图谱页面（按科目展示知识点目录树）
- 支持按科目筛选知识点，选择知识点后查看详情和关联真题
- 知识点列表展示使用摘要，避免页面过挤

## 2026-05-17 至 2026-05-19 AI 工作台与 RAG

- 增加规范化 RAG 索引架构：`rag_document` → `rag_chunk` → `rag_embedding` 三层索引结构
- 从旧题库和知识库回填 `question_content`、`question_knowledge_point`、`rag_document`、`rag_chunk`
- 部署 Qdrant 向量数据库，后端增加 `RagIndexService` 抽象
- 使用智谱 embedding-2 生成向量，119 个 chunk 全部写入 Qdrant
- 增加 AI Provider 密钥管理、测试连接和用量分析页面
- AI 解析增加 SSE 流式输出（知识图谱和错题本解析边生成边展示）
- 增加 AI Provider 优先级调度：公共密钥 → 用户私钥 → 配置文件兜底
- 增加意图路由（`AiIntentRouter`），支持 6 种意图自动识别
- 增加草案确认型 Agent：`/agent/plan` 生成组卷草案，`/agent/confirm` 经学生确认后创建限时卷
- 增加显式工具调用：`/compose paper` 生成限时练习卷
- 增加组卷服务 `AiPaperComposeService`，只能从题库已有题目挑选，不能编造新题
- 学生端 Dashboard AI 学习工作台重设计：hero 区、知识节点动画、快捷入口和技能模式面板
- AI 工作台 prompt 解耦和稳定性修复，讲法切换和任务类型独立
- AI 工作台改为"先选上下文，再生成画像/练习"：提供随机知识点、随机真题、随机错题、粘贴四个上下文入口
- 随机范围支持三层筛选：全库 → 科目 → 知识点关联真题/错题

## 2026-05-27 至 2026-05-28 题库扩展与工程完善

- 重建 CSGraduates HTML 真题与模拟卷导入链路：数据库只存 HTML 轻引用和元数据，完整 HTML 放学生端静态目录
- 扩展题库范围：补齐 408 真题/模拟卷、数学一/二/三、英语一/二、思想政治理论 HTML 题库
- 新增 408 四科知识点 HTML 化导入，保留表格、公式、图片、代码块和层级标题
- 新增 `QuestionHtml` 组件，试卷页面和答案查看页面能加载外部 HTML 片段
- 新增 AI 题目图片识别（多模态），学生端 /question/ai-analyze 页面
- 新增 AI 工作台 Orchestrator：统一接收 intent、context、style、userMessage，后端按任务路由
- 新增 `AiWorkbenchContextVM`：真题、错题、知识点和粘贴内容统一进入上下文容器
- 补充 408 四科近年专项卷（数据结构、组成原理、操作系统、计算机网络）
- 整理初始化 SQL：新增一键导入结构、题库、HTML 真题、知识点和演示数据的脚本
- 测试账号更新为 test / 123456，清理旧演示数据

## 2026-05-29 UI 修复与稳定

- 试卷中心修复：左侧只使用真实科目，分页按总页数显示，科目切换一次点击生效
- 错题本和题目详情体验修复：选项、解析、正确答案展示去重，AI 分析 Provider 表缺失时后端安全降级
- 修复知识点富文本过宽：中间列 min-width 归零，宽表格/代码块/大图在上下文卡片内部滚动
- 优化 AI 工作台上下文展示：题目上下文显示科目标签和来源标题，粘贴只进入上下文卡片
- 登录注册修复：取消用户名长度限制，注册年级兜底
- 修复学生端错题本分页切换问题
- 微信小程序补齐错题本与 AI 题目识别入口
- 学生端 UI 刷新：试卷列表、做题记录、错题本、AI 解析页面优化
- 新增 Developer Brief 页面和 80×180 易拉宝展示页
- 更新 UML 说明：用 PlantUML 标准图解释用例、组件、时序、领域类、RAG、AI Runtime 和部署关系

## 主要问题与解决

### 图片题路径不统一

原系统没有图片路径字段。通过增加 `t_question.images` 字段和 `deploy/static/images/` 静态资源目录统一管理。迁移脚本将图片路径注入到 HTML 题干中。HTML 格式题目采用"数据库存引用 + 静态 HTML 片段渲染"的轻量方案，避免超大 HTML 直接塞进旧 TEXT 字段。

### AI 密钥不能放前端

管理端保存 AI 密钥时，后端使用 AES-256-GCM 加密后存入数据库。`listSafe()` API 返回时将密钥字段设为 null，前端永远只看到脱敏掩码。主密钥通过环境变量 `AI_SECRET_MASTER_KEY` 传入，避免写死在配置文件中。

### RAG 需要兜底

实现双路径 RAG 检索：Qdrant 向量数据库（需显式启用）和内存余弦相似度（默认路径）。Qdrant 未启用时系统仍能通过内存路径正常运行，保证功能不被向量数据库绑定。

### 小程序不能直连数据库

小程序通过 `/api/wx/` 前缀的 7 个专用 Controller 访问后端，复用同一套 Service/Mapper 层。小程序端不保存 AI 密钥，不直接访问数据库。

### 关联真题展示与 AI 上下文边界

知识图谱右侧列表使用轻量摘要（截断到 72 字），避免页面拥挤。但 AI 讲题时应加载完整题干、选项、答案和解析，不应依赖展示摘要。这是渐进改造阶段的典型问题：旧表兼容、展示摘要和 AI 输入上下文边界没有完全分开。

### AI 练习/出卷边界

限制 AI 只能从题库已有题目中挑选 1-5 题。没有候选时只输出筛选条件，不能编造新题。写库操作（创建试卷）必须由按钮或指令显式授权。

### 知识点富文本撑爆页面

知识点内容可能包含宽表格、代码块和大图。通过中间列 min-width 归零、右侧栏固定宽度、宽内容在上下文卡片内部滚动解决。装饰性 SVG 图标隐藏，不影响阅读区。
