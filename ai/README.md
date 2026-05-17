# ai

这个目录保留 AI/RAG 相关辅助资料和脚本说明。当前后端运行时真正加载的 Prompt 模板主要位于：

```text
source/xzs/ai/prompts/analysis/
```

根目录 `ai/` 更适合作为离线脚本、实验方案、embedding 生成说明的存放位置。

## 当前 AI 能力

| 能力 | 说明 |
|---|---|
| RAG | 从题库、408 知识点和方法论摘要中检索参考资料，注入 Prompt。 |
| 四种 Skill | `default`、`feynman`、`first-principles`、`plato`。 |
| 学生 Agent | 记录学习事件、学生画像、Skill 反馈，用于后续个性化讲解。 |
| 管理端调试 | 提供知识库统计和 RAG debug 接口。 |

## Prompt 模板

分析类模板在：

```text
source/xzs/ai/prompts/analysis/
```

每个模板是 JSON 文件，核心字段包括：

| 字段 | 作用 |
|---|---|
| `name` | 风格名称。 |
| `description` | 前端展示和维护说明。 |
| `system_prompt` | 模型角色和输出约束。 |
| `user_prompt_template` | 用户题目、参考资料、学生画像等变量注入位置。 |
| `variables` | 模板支持的变量列表。 |

当前模板应支持这些变量：

- `{question}`
- `{reference_docs}`
- `{student_profile}`
- `{feedback_notes}`

## 后端入口

| 文件 | 作用 |
|---|---|
| `source/xzs/src/main/java/com/mindskip/xzs/ai/AnalysisService.java` | AI 调用和模板加载。 |
| `source/xzs/src/main/java/com/mindskip/xzs/ai/RagService.java` | RAG 检索。 |
| `source/xzs/src/main/java/com/mindskip/xzs/controller/student/AIAnalysisController.java` | 学生端 AI 解析和反馈接口。 |
| `source/xzs/src/main/java/com/mindskip/xzs/service/impl/AiLearningProfileServiceImpl.java` | 学习事件、学生画像和反馈写入。 |

## 数据库

AI/RAG 相关数据库脚本：

```text
database/current/05_rag_embeddings.sql
database/current/06_ai_knowledge_rag.sql
```

核心表：

| 表 | 作用 |
|---|---|
| `t_ai_knowledge_base` | RAG 文档库，包含 408 知识点、方法论摘要等。 |
| `t_text_content.embedding` | 旧题目解析向量字段，RAG 兼容读取。 |
| `t_user_learning_profile` | 学生画像。 |
| `t_user_learning_event` | 学习事件。 |
| `t_user_skill_feedback` | Skill 反馈。 |

## 常用接口

```text
GET  /api/student/ai/styles
POST /api/student/ai/analyze
POST /api/student/ai/feedback
GET  /api/admin/ai-agent/knowledge-base/statistics
GET  /api/admin/ai-agent/rag/debug?keyword=虚拟存储器&topK=3
```

## 维护建议

1. 修改 Prompt 前，先确认模板变量没有漏写。
2. 新增知识库数据后，先用管理端统计和 RAG debug 接口确认能被检索到。
3. 大段外部资料不要直接入库，优先摘要化、片段化，并保留来源。
4. 正式上线前，应把 embedding 生成和增量更新脚本做成可重复任务。
