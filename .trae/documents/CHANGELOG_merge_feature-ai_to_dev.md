# Changelog: Merge `feature/ai` → `dev`

> **合并提交**: `a70225a5` — 2026-05-16  
> **基准**: `a08e7b33` (origin/dev) → `a70225a5` (HEAD → dev)  
> **分支**: `feature/ai` (23fd19db) 并入 `dev`

---

## 📊 变更统计

| 指标 | 数值 |
|------|------|
| 涉及文件 | **21** |
| 新增行数 | +1,681 |
| 删除行数 | -35 |
| 新建文件 | 10 |
| 修改文件 | 11 |

---

## 🆕 新建文件（10 个）

### AI 核心服务

| 文件 | 行数 | 说明 |
|------|------|------|
| `source/xzs/src/main/java/com/mindskip/xzs/ai/RagService.java` | 262 | RAG 向量检索服务：GLM Embedding API 调用 → cosine similarity Top-K 检索 |
| `ai/embed_questions.py` | 167 | 批量生成题目向量嵌入脚本（pymysql → 每题调用 GLM Embedding → 写回 DB） |

### 数据库

| 文件 | 行数 | 说明 |
|------|------|------|
| `database/05_rag_embeddings.sql` | 22 | `t_text_content` 增加 `embedding LONGTEXT` 列 DDL |

### 部署基础设施

| 文件 | 行数 | 说明 |
|------|------|------|
| `deploy/Dockerfile` | 8 | Spring Boot 应用容器镜像构建文件 |
| `deploy/docker-compose.yml` | 71 | 三容器编排（Nginx + xzs-backend + xzs-mysql） |
| `deploy/nginx.conf` | 35 | Nginx 反向代理 + 前端静态文件配置 |
| `deploy/REDEPLOY_GUIDE.md` | 453 | 13 步重新部署操作指南（含故障排查） |

### 文档

| 文件 | 行数 | 说明 |
|------|------|------|
| `.trae/documents/后续建议_完成部署并合并dev.md` | 100 | 后续任务 Plan：RAG Embedding 生成 + 前端验证 + 合并 dev |
| `.trae/documents/后续建议_Codex疑难问题速查.md` | 276 | AI Agent 专用：7 类反复疑难问题速查手册 |

---

## ✏️ 修改文件（11 个）

### README.md（+146/-17）— 合并冲突解决 + 新增 AI 架构文档

- 分支表格：`feature/ai` 状态从 `🚀 进行中` → `✅ 已完成`，`dev` 更新为含 AI RAG
- 更新日志：合并两分支变更到一个统一条目 "AI RAG 检索增强 + NPE 全面防护"
- 新增完整 **AI 智能导师系统** 章节（~120 行）：
  - 架构概览流程图
  - RAG 检索增强技术说明
  - 启用 RAG 步骤
  - 四种 AI 解析风格速查表
  - API 接口文档（含请求/响应示例）
  - AI 配置说明
  - 关键文件索引

### AI Prompt 模板（4 个文件，各 +6/-6）

| 文件 | 修改内容 |
|------|---------|
| `ai/prompts/analysis/default.json` | 增加 `{reference_docs}` 占位符 + 五步法结构（考点识别→推导→易错→记忆→举一反三） |
| `ai/prompts/analysis/feynman.json` | 增加 `{reference_docs}` + 强化生活类比 + 五步输出 |
| `ai/prompts/analysis/plato.json` | 增加 `{reference_docs}` + 强化启发式提问 + 五步输出 |
| `ai/prompts/analysis/first-principles.json` | 增加 `{reference_docs}` + 强化推导链 + 五步输出 |

### Java 后端（6 个文件）

| 文件 | 变更 | 说明 |
|------|------|------|
| `AnalysisService.java` | +19 | `analyzeWithAI` 方法增加 `List<String> referenceDocs` 参数 |
| `PromptTemplate.java` | +10 | 新增 `formatUserPrompt` 重载方法，支持注入 `{reference_docs}` |
| `AIAnalysisController.java` | +41 | 集成 RagService：调用 `retrieve()` → 传入 AnalysisService → 返回 `references` 列表 |
| `TextContent.java` | +13 | 领域模型新增 `embedding` 字段（String/JSON float[]） |
| `TextContentMapper.java` | +3 | 新增 `selectAllWithEmbedding()` 方法签名 |
| `TextContentMapper.xml` | +24 | 完整 Mapper SQL，含 `embedding` 列映射 |

### 前端（1 个文件）

| 文件 | 变更 | 说明 |
|------|------|------|
| `source/vue/xzs-student/src/views/knowledge-graph/index.vue` | +42 | AI 回复气泡底部显示 "📚 参考来源" + 检索到的题目链接（title + similarity） |

---

## 🏗️ 架构变更

```
                     变更前                          变更后
                 ┌──────────┐                  ┌──────────┐
                 │  前端    │                  │  前端    │
                 │ 提问 →   │                  │ 提问 +    │
                 │ 显示答案 │                  │ 显示参考  │
                 └────┬─────┘                  └────┬─────┘
                      │                            │
                      ▼                            ▼
            ┌─────────────────┐          ┌─────────────────────┐
            │ AnalysisService │          │ AIAnalysisController│
            │ (直接调 GLM)    │          │  ├─ RagService      │ ← NEW
            └────────┬────────┘          │  │   ├─ embed()     │
                     │                   │  │   └─ retrieve()  │
                     ▼                   │  └─ AnalysisService  │
              ┌──────────┐               │      (注入参考文档)  │
              │ GLM Chat │               └──────────┬──────────┘
              └──────────┘                          │
                                          ┌────────┴────────┐
                                          ▼                 ▼
                                    ┌──────────┐    ┌──────────────┐
                                    │ GLM Chat │    │ GLM Embedding│ ← NEW
                                    └──────────┘    └──────┬───────┘
                                                           │
                                                    ┌──────▼──────┐
                                                    │ t_text_     │
                                                    │ content.    │
                                                    │ embedding   │ ← NEW
                                                    └─────────────┘
```

---

## 📦 完整文件清单

```
新建 (10):
  .trae/documents/后续建议_Codex疑难问题速查.md
  .trae/documents/后续建议_完成部署并合并dev.md
  ai/embed_questions.py
  database/05_rag_embeddings.sql
  deploy/Dockerfile
  deploy/REDEPLOY_GUIDE.md
  deploy/docker-compose.yml
  deploy/nginx.conf
  source/xzs/src/main/java/com/mindskip/xzs/ai/RagService.java

修改 (11):
  README.md
  ai/prompts/analysis/default.json
  ai/prompts/analysis/feynman.json
  ai/prompts/analysis/first-principles.json
  ai/prompts/analysis/plato.json
  source/xzs/src/main/java/com/mindskip/xzs/ai/AnalysisService.java
  source/xzs/src/main/java/com/mindskip/xzs/ai/PromptTemplate.java
  source/xzs/src/main/java/com/mindskip/xzs/controller/student/AIAnalysisController.java
  source/xzs/src/main/java/com/mindskip/xzs/domain/TextContent.java
  source/xzs/src/main/java/com/mindskip/xzs/repository/TextContentMapper.java
  source/xzs/src/main/resources/mapper/TextContentMapper.xml
  source/vue/xzs-student/src/views/knowledge-graph/index.vue
```
