# 408Master

408Master 是基于学之思考试系统改造的 408 考研刷题与智能学习系统。当前重点分支是 `codex/ai-knowledge-rag`，在传统题库、试卷、做题记录基础上，加入了 RAG 知识库、四种 AI 解析 Skill、学生学习档案 Agent、408 知识点爬虫和小程序学生端跑通能力。

## 当前能力

- 408 真题题库：2011-2024 年综合试卷，选择题与综合应用题数据。
- 学生端 Web：试卷中心、答题、批改、做题记录、知识图谱、AI 解析。
- 管理端 Web：题目、试卷、用户、AI Agent/知识库调试接口。
- 微信小程序学生端：登录绑定、首页、试卷列表、做题、记录、我的。
- AI 解析：常规、费曼学习法、第一性原理、柏拉图式对话四种视角。
- RAG 知识库：116 条 408 知识点页面、方法论摘要、真题解析资料。
- Agent 记录：学习事件、学生画像、Skill 反馈闭环。

## 根目录说明

| 目录/文件 | 作用 |
|---|---|
| `source/` | 主源码目录，包含后端、Web 前端、小程序端。 |
| `source/xzs/` | Spring Boot 后端，端口默认 `8000`。 |
| `source/vue/xzs-student/` | Vue3 + Vite 学生端 Web。 |
| `source/vue/xzs-admin/` | Vue3 + Vite 管理端 Web。 |
| `source/wx/xzs-student/` | 原生微信小程序学生端。 |
| `database/` | 数据库结构、题库数据、RAG/Agent 增量 SQL。 |
| `crawler/` | 408 真题、图片、知识点爬虫和导入工具。 |
| `ai/` | Prompt 模板和 AI/RAG 辅助脚本说明。 |
| `deploy/` | 当前推荐云端 Docker 部署配置和重新部署手册。 |
| `docker/` | 原学之思 Docker 部署参考，保留作对照。 |
| `docs/` | 需求计划、开发记录、工程经验、部署复盘、数据处理和交付材料。 |
| `release/` | 原项目集成部署说明和发布产物目录。 |
| `import_db.py` | 本地导入数据库脚本，避免中文乱码。 |
| `test_api.py` / `verify_*.py` | 本地接口和数据验证脚本。 |

## 快速启动

### 1. 初始化数据库

推荐使用 `database/README.md` 中的顺序导入。最小完整顺序如下：

```bash
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS xzs DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci"

mysql -u root -p xzs < database/current/01_init_structure.sql
mysql -u root -p xzs < database/current/02_extend_fields.sql
mysql -u root -p xzs < database/current/04_exam_data.sql
mysql -u root -p xzs < database/current/05_rag_embeddings.sql
mysql -u root -p xzs < database/current/06_ai_knowledge_rag.sql
```

`database/archive/` 下是历史备份和早期实验脚本，不参与当前主线初始化。

如果在 Windows PowerShell 中导入 SQL，优先使用 `import_db.py`，不要用 `Get-Content | mysql` 管道，避免中文乱码。

### 2. 启动后端

```bash
cd source/xzs
mvn package -DskipTests
java -jar target/xzs-3.9.0.jar
```

默认访问：

```text
http://127.0.0.1:8000
```

### 3. 启动学生端 Web

```bash
cd source/vue/xzs-student
npm install --registry=https://registry.npmmirror.com
npm run dev -- --host 127.0.0.1 --port 8001
```

访问：

```text
http://127.0.0.1:8001/student/
```

### 4. 启动管理端 Web

```bash
cd source/vue/xzs-admin
npm install --registry=https://registry.npmmirror.com
npm run dev
```

### 5. 打开微信小程序

用微信开发者工具导入：

```text
source/wx/xzs-student
```

开发阶段需要勾选“不校验合法域名、TLS 版本及 HTTPS 证书”。本地接口地址在 `source/wx/xzs-student/app.js` 的 `globalData.baseAPI` 中配置。

## 常用账号

| 用户名 | 密码 | 角色 |
|---|---|---|
| `admin` | `123456` | 管理员 |
| `student` | `123456` | 学生 |
| `teacher` | `123456` | 教师 |
| `231310423` | `123456` | 学生测试账号 |

## AI/RAG 相关入口

| 能力 | 文件/接口 |
|---|---|
| Prompt 模板 | `source/xzs/ai/prompts/analysis/*.json` |
| RAG 服务 | `source/xzs/src/main/java/com/mindskip/xzs/ai/RagService.java` |
| AI 解析接口 | `POST /api/student/ai/analyze` |
| AI 反馈接口 | `POST /api/student/ai/feedback` |
| Skill 列表 | `GET /api/student/ai/styles` |
| 知识图谱 | `GET /api/student/knowledge-graph/graph` |
| 管理端知识库统计 | `GET /api/admin/ai-agent/knowledge-base/statistics` |
| RAG 调试 | `GET /api/admin/ai-agent/rag/debug?keyword=...&topK=3` |

## 部署

当前推荐使用 `deploy/` 目录：

- `deploy/docker-compose.yml`：MySQL、后端、Nginx 三服务部署。
- `deploy/Dockerfile`：后端 jar 镜像构建。
- `deploy/nginx.conf`：前端静态资源和 `/api/` 反向代理。
- `deploy/REDEPLOY_GUIDE.md`：完整重新部署步骤。
- `docs/04-deployment/朋友远程部署操作手册.md`：适合发给能 SSH 到服务器的同学照做。

## 关键文档

| 文档 | 说明 |
|---|---|
| `database/README.md` | 数据库导入顺序、表说明、账号、验证 SQL。 |
| `crawler/README.md` | 真题/知识点/图片爬虫使用说明。 |
| `docs/README.md` | 文档总索引，按需求、记录、经验、部署、数据和交付材料整理。 |
| `docs/01-requirements-plan/development-workflow-overview.md` | 需求、开发计划和具体开发流程总览。 |
| `docs/02-work-records/github-collaboration-workflow.md` | GitHub 分支、PR、审核和团队协作记录。 |
| `docs/03-engineering-experience/Vue2ToVue3Migration.md` | Vue2 到 Vue3 迁移经验。 |
| `docs/03-engineering-experience/AI_AGENT_TEST_GUIDE.md` | AI Agent 功能测试指南。 |
| `docs/00-deliverables/408Master_AI_RAG_项目报告.docx` | 项目报告。 |
| `docs/00-deliverables/408Master_AI_RAG_答辩展示.pptx` | 答辩展示 PPT。 |
| `docs/04-deployment/朋友远程部署操作手册.md` | 远程部署交接文档。 |
| `docs/02-work-records/` | 开发记录归档，后续写汇报和答辩材料可复用。 |

## 分支建议

- `main`：稳定部署分支。
- `feature/ai`：AI 功能原始开发分支。
- `codex/ai-knowledge-rag`：当前 RAG、爬虫、Agent、微信小程序跑通改造分支。

复杂改动建议先在 AI 分支验证，再合并到 `main`。
