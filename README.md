## 分支管理规则

### 1. 长期分支（始终保留）

| 分支 | 用途 | 保护策略 |
|------|------|---------|
| `main` | 稳定生产分支，用于部署上线 | 🔒 禁止直接提交，必须通过 PR 合并 |
| `dev` | 开发整合分支，用于日常集成 | ⚠️ 建议通过 PR 合并 |

### 2. 短期分支（完成即删）

| 分支前缀 | 用途 | 示例 |
|----------|------|------|
| `feature/*` | 新功能开发 | `feature/vue3-migration`、`feature/ai-analyze` |
| `hotfix/*` | 紧急线上 bug 修复 | `hotfix/login-error` |
| `refactor/*` | 代码重构 | `refactor/api-layer` |

### 3. 工作流程（5人团队协作）

```
1. 从 dev 分支创建 feature 分支
   git checkout dev
   git checkout -b feature/my-feature

2. 在 feature 分支开发，定期提交

3. 开发完成后，提交 PR 合并回 dev

4. 测试通过后，dev 合并到 main 发布
```

### 4. 当前活跃分支

| 分支 | 状态 | 说明 |
|------|------|------|
| `main` | ✅ 稳定 | 最新稳定版 |
| `dev` | 🚀 进行中 | AI RAG + NPE修复 + 爬虫数据 + Docker部署 (已合并feature/ai + feature/crawler-and-exam-data) |
| `feature/crawler-and-exam-data` | ✅ 已完成 | 408真题爬虫 + 数据库完整 + NPE全面防护 |
| `feature/ai` | ✅ 已完成 | AI RAG 检索增强 + 4种Skill风格优化 + 已部署云端 |
| `deploy/docker-infra` | 🛠️ 部署 | Docker 部署基础设施（三容器编排） |

---

## 更新日志

### 最近更新（2026-05-16）— AI RAG 检索增强 + NPE 全面防护

**RAG 检索增强生成**
- 🧠 核心服务：新增 `RagService.java`，集成 GLM Embedding API 实现向量检索
- 🔍 检索管线：用户提问 → embedding → cosine similarity Top-K → 注入 prompt → 更准确的 AI 回答
- 🗄️ 向量存储：`t_text_content` 新增 `embedding` 列，存储 1024 维向量（GLM Embedding-2）
- 🐍 批量脚本：`ai/embed_questions.py` 可批量生成 672 道题目的向量嵌入（需云服务器网络可达）

**4 种 Skill 风格全面优化**
- 📚 `default` 标准解析：考点识别→推导过程→易错提醒→记忆技巧→举一反三
- 🎓 `feynman` 费曼风格：大白话版→生活类比→手把手教学→帮你记住→你学到了啥
- ❓ `plato` 柏拉图式：唤起认知→建立连接→深入思考→揭示答案→学习总结
- ⚡ `first-principles` 第一性原理：基本公理→推导链构建→抵达答案→验证反思→本质洞察
- 🔗 所有模板增加 `{reference_docs}` 变量，支持 RAG 检索结果注入

**NPE 全面防护 (5个Java文件, 10处修复)**
- 🛡️ `QuestionAnswerController`：subject/textContent null保护 + JSON解析try-catch + select空值校验
- 🛡️ `ExamPaperAnswerController`(student/admin)：subject/user null保护
- 🛡️ `ExamUtil`：scoreToVM(null)→"-" secondToVM(null)→"-"
- 🛡️ `QuestionServiceImpl`：getQuestionEditRequestVM null check
- ✅ 考试记录和错题本页面不再报"系统内部错误"

**408真题爬虫重构**
- 🕷️ `crawler/crawl_all.py`：统一爬虫，正确解析题目/选项/答案/解析
- 📊 `database/04_exam_data.sql`：672条text_content + 658道题 + 14套试卷

**数据库整洁**
- 🗑️ 清理7个旧版数据库文件
- 🔍 4项悬空引用检查全部通过（0 悬空）

**Docker 云端部署**
- 🐳 三容器编排（Nginx + Spring Boot + MySQL）
- 📋 完整重新部署指南 `deploy/REDEPLOY_GUIDE.md`
- 🌐 运行于 `118.31.34.132:80`

---

### 最近更新（2026-05-14）

**Vue3 迁移完成**
- 🚀 前端框架升级：Vue2 → Vue3，vue-router3 → 4，Vuex → Pinia
- 🔧 构建工具升级：vue-cli → Vite
- 📝 完整迁移文档：`docs/Vue2ToVue3Migration.md`
- 🗄️ 数据库增强：知识图谱、RAG 检索、AI 解析相关表设计
- 🐛 问题修复：登录密码卡顿、侧边栏空白、页面溢出等问题

**分支管理优化**
- 📦 清理旧分支，采用规范的 Git Flow 分支策略

---

### 最近更新（2026-05-06 15:27）

本次合并了 `dev` 分支的最新改动到 `main` 分支，主要更新内容：

**管理员前端（xzs-admin）更新**
- 🎨 页面样式：更新登录页、仪表板页面样式
- 🖼️ 资源文件：更新 favicon.ico、logo.png
- 📦 依赖更新：更新 package-lock.json 和 package.json
- 🎯 组件优化：调整导航栏、侧边栏 Logo、标签页组件
- 🎭 样式统一：新增 element-ui.scss，更新全局样式变量和 SCSS 文件
- 🔌 API 请求：优化 request.js 配置

**学生端前端（xzs-student）更新**
- 📦 依赖更新：更新 package-lock.json 和 package.json
- 🖼️ 资源文件：更新 logo2.png
- 🌐 页面配置：更新 index.html
- 🔌 API 调整：修改 question.js

**冲突解决**
- ✅ 解决了 `package-lock.json` 冲突
- ✅ 解决了 `src/layout/index.vue` 冲突

---

## 项目运行

### 1.0 下载
```
mkdir C:\Dev\Workspaces
cd C:\Dev\Workspaces
git clone https://github.com/tiankai-333/master408.git
```

### 1.1 数据库配置

#### 1.1.1 前提条件
- 确保已安装 MySQL 5.7+ 或 MySQL 8.0+
- 创建数据库用户并授予权限

#### 1.1.2 快速初始化（推荐）

项目提供了完整的数据库初始化脚本，一键完成建表和数据插入：

```bash
# 进入项目目录
cd C:\Dev\Workspaces\master408

# 进入 MySQL 命令行（输入密码后进入）
mysql -u root -p

# 执行初始化脚本
source C:/Dev/Workspaces/master408/sql/init_database.sql
```

#### 1.1.3 脚本说明

`sql/init_database.sql` 脚本包含：

| 操作 | 说明 |
|------|------|
| 创建数据库 | 自动创建 `xzs` 数据库 |
| 创建表结构 | 6张核心表（学科、题目、用户、试卷等） |
| 插入基础数据 | 12条学科记录、13条题目内容、12条题目记录 |
| 创建测试用户 | admin（管理员）、student（学生） |

#### 1.1.4 测试账号

| 用户名 | 密码 | 角色 |
|--------|------|------|
| admin | 123456 | 管理员 |
| student | 123456 | 学生 |

#### 1.1.5 手动配置（可选）

如果需要手动配置数据库连接，请修改后端配置文件：

```
source/xzs/src/main/resources/application-dev.yml
```

配置项：
```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/xzs?useUnicode=true&characterEncoding=UTF-8&serverTimezone=Asia/Shanghai
    username: root
    password: your_password
```

#### 1.1.6 题目数据格式规范

题目数据分为两部分存储：

1. **t_text_content**（JSON格式）：存储题目详细内容
```json
{
  "titleContent": "题目描述",
  "analyze": "答案解析",
  "questionItemObjects": [
    {"prefix": "A", "content": "选项内容", "itemUuid": "唯一ID"}
  ],
  "correct": "正确答案"
}
```

2. **t_question**（元信息）：存储题目基本信息
| 字段 | 说明 |
|------|------|
| question_type | 题型：1=单选, 2=多选, 3=判断, 4=填空, 5=简答 |
| subject_id | 学科ID |
| grade_level | 年级等级：1=期末考, 2=考研, 3=复试 |
| difficult | 难度：1-5 |

### 1.2 前端运行

1.1.1 解决版本冲突
```
cd C:\Dev\Workspaces\master408\source\vue\xzs-student
```
卸载 node-sass 并安装 sass
```
npm uninstall node-sass

npm install sass --save-dev
```
1.1.2 清理并重新安装所有依赖（只做一次，现在已经做完了）
```

---

## AI 智能导师系统

### 2.1 架构概览

```
前端 (knowledge-graph/index.vue)
  ├─ 4 种 Skill 风格按钮 (标准/费曼/柏拉图/第一性原理)
  └─ POST /api/student/ai/analyze
        │
        ▼
  AIAnalysisController
    ├─ RagService.retrieve(question, topK=5)     ← RAG 检索
    │   ├─ loadCandidates() → DB 含 embedding 的题目
    │   ├─ embed(query) → GLM Embedding-2 API
    │   └─ cosineSimilarity → Top-K 排序
    │
    └─ AnalysisService.analyzeWithAI(style, question, knowledgePoints, referenceDocs)
        ├─ PromptTemplate.formatUserPrompt(...)   ← 注入 {reference_docs}
        └─ GLM Chat API (glm-4.5-air)             ← 生成分析
```

### 2.2 RAG 检索增强

RAG（Retrieval-Augmented Generation）通过向量检索题库中与用户问题最相关的题目，
将其解析内容注入 AI prompt，大幅减少幻觉。

| 组件 | 技术 | 说明 |
|------|------|------|
| Embedding 模型 | GLM Embedding-2 | 1024 维向量 |
| 检索算法 | Cosine Similarity | Top-5，相似度 > 0.5 |
| 向量存储 | MySQL `t_text_content.embedding` | JSON float[] 格式 |
| Prompt 模板 | `{reference_docs}` 变量 | 四种模板均支持 |

### 2.3 启用 RAG

```bash
# 1. 添加 embedding 列（已完成）
mysql -u root -p123456 xzs < database/05_rag_embeddings.sql

# 2. 安装 Python 依赖
pip install pymysql requests

# 3. 批量生成向量嵌入（约 1-3 分钟，需 API Key）
python ai/embed_questions.py
```

### 2.4 四种 AI 解析风格

| 风格 ID | 名称 | 前端 emoji | 解析结构 |
|---------|------|-----------|---------|
| `default` | 标准解析 | 📚 | 考点识别 → 推导过程 → 易错提醒 → 记忆技巧 → 举一反三 |
| `feynman` | 费曼风格 | 🎓 | 大白话版 → 生活类比 → 手把手教学 → 帮你记住 → 你学到了啥 |
| `plato` | 柏拉图式 | ❓ | 唤起认知 → 建立连接 → 深入思考 → 揭示答案 → 学习总结 |
| `first-principles` | 第一性原理 | ⚡ | 基本公理 → 推导链构建 → 抵达答案 → 验证反思 → 本质洞察 |

### 2.5 API 接口

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/student/ai/styles` | 获取可用风格列表 |
| GET | `/api/student/ai/template/{style}` | 获取风格模板详情 |
| POST | `/api/student/ai/analyze` | **AI 分析题目（含 RAG）** |
| POST | `/api/student/ai/generate-prompt` | 生成本地 prompt（不含 AI 调用） |

**analyze 请求体**：
```json
{
  "style": "feynman",
  "question": "在进程调度中，什么是时间片轮转法？",
  "knowledgePoints": ""
}
```

**analyze 响应体**：
```json
{
  "code": 1,
  "response": {
    "analysis": "... AI 生成的完整分析 ...",
    "prompt": "... 生成的完整 prompt ...",
    "style": "feynman",
    "references": [
      {"title": "题#531: 关于进程调度的真题解析", "similarity": "0.87", "id": 531}
    ]
  }
}
```

### 2.6 AI 配置

```yaml
# application.yml
ai:
  api:
    key: your_glm_api_key
    url: https://open.bigmodel.cn/api/paas/v4/chat/completions
    type: glm
  embedding:
    url: https://open.bigmodel.cn/api/paas/v4/embeddings
    model: embedding-2
```

### 2.7 关键文件

| 文件 | 说明 |
|------|------|
| `ai/AnalysisService.java` | AI 分析核心服务，加载模板 + 调用 GLM Chat API |
| `ai/RagService.java` | RAG 检索服务，embedding + cosine similarity |
| `ai/PromptTemplate.java` | Prompt 模板模型，支持 `{reference_docs}` |
| `ai/embed_questions.py` | 批量生成向量嵌入的 Python 脚本 |
| `ai/prompts/analysis/*.json` | 4 种风格的 prompt 模板文件 |
| `database/05_rag_embeddings.sql` | 向量列建表脚本 |
