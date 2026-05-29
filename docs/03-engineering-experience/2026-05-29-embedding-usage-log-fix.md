# Embedding 调用记录在学生端不可见——排查与修复

**日期**：2026-05-29
**范围**：`RagService` / `AIAnalysisController` / `AiWorkbenchController` / 学生端用量分析页

---

## 1. 问题现象

- 管理端 `/ai/config` → 用量分析能看到 embedding-2 的调用记录
- 学生端 `/ai-config/index` → 用量分析里看不到任何 embedding 记录
- 学生端前端类型判断写死 `'Embedding'`（大写 E），后端存的是 `'embedding'`（小写）
- embedding 调用始终硬编码走公共智谱密钥，不支持用户私钥
- 公共密钥挂了整个 RAG 功能就不可用

## 2. 根因分析

### 2.1 embedding 日志缺少 userId（核心问题）

`RagService.saveEmbeddingUsageLog()` 没有调用 `log.setUserId()`，导致 `t_ai_usage_log` 表中 embedding 记录的 `user_id = NULL`。

学生端查询使用 `WHERE user_id = #{userId}` 过滤，NULL 记录被全部排除。管理端查询没有 user_id 过滤，所以能看到。

### 2.2 前端大小写不匹配

学生端 `ai-config/index.vue` 判断类型用的是 `=== 'Embedding'`（大写 E），但后端 `RagService` 存的是 `setStyle("embedding")`（小写）。即使记录能查到，类型标签也会显示为"对话"而非"Embedding"。

### 2.3 embed() 硬编码公共密钥

`RagService.embed()` 写死了 `getEnabled("zhipu")`，只查公共智谱供应商，不支持用户私钥。而 `AnalysisService` 已经实现了 `resolveProvider()` 按 priority 合并公私密钥的逻辑。

### 2.4 历史数据问题

修复前创建的 30408 条 embedding 记录：
- `user_id = NULL`（没写）
- `key_source = NULL`（没写）

## 3. 修复内容

### 3.1 RagService — 加 ThreadLocal userId + keySource

```
新增 ThreadLocal<Integer> currentUser，方法 setCurrentUserId / clearCurrentUserId。
saveEmbeddingUsageLog() 中加 log.setUserId(currentUser.get()) 和 log.setKeySource(keySource)。
```

### 3.2 两个 Controller 补上 RagService.setCurrentUserId()

- `AIAnalysisController`：`/analyze` 和 `/analyze-stream` 两个接口
- `AiWorkbenchController`：`/stream` 接口

在 `AnalysisService.setCurrentUserId()` 旁边加上 `RagService.setCurrentUserId()`，finally 块里加上 `RagService.clearCurrentUserId()`。

### 3.3 embed() 重写为 provider 解析模式

新增 `resolveEmbeddingProvider()`，按 priority 排序查找：

1. 用户私钥（有 embeddingModel 的已启用密钥）
2. 公共供应商（有 embeddingModel 的已启用供应商）
3. fallback：application.yml 默认值

`saveEmbeddingUsageLog` 新增 `keySource` 参数，由解析结果决定是 `"public"` 还是 `"private"`。

### 3.4 学生端前端大小写修复

`ai-config/index.vue`：
```javascript
// 修复前
row.taskType === 'Embedding' ? 'warning' : 'primary'
// 修复后
row.taskType === 'embedding' ? 'warning' : 'primary'
```

### 3.5 学生端 SQL 查询兼容历史 NULL 数据

`AiUsageLogMapper.xml` 三个查询（summary / byProvider / recentLogs）的 WHERE 条件从：
```sql
WHERE user_id = #{userId}
```
改为：
```sql
WHERE (user_id = #{userId} OR (user_id IS NULL AND key_source = 'public'))
```

### 3.6 历史数据迁移

```sql
UPDATE t_ai_usage_log SET key_source = 'public' WHERE key_source IS NULL;
-- 影响 30408 条记录
```

### 3.7 embedding-2 定价更新

`AiPricing.java`：`embedding-2` 从 `{0, 0, 0}` 改为 `{0.5, 0, 0.5}`（¥0.5/百万 token）。

### 3.8 学生端密钥编辑表单自动填充

浏览器把 `type="password"` 的 API Key 字段当成登录密码，自动填充学生账号密码。

修复：给 Embedding 模型输入框加 `autocomplete="off"`，API Key 输入框加 `autocomplete="new-password"`。

### 3.9 管理端/学生端用量表格显示供应商名称

用量分析表格的"供应商"列从显示代码（`zhipu`）改为显示名称（`智谱 GLM`），通过 `providers` 数组映射。

### 3.10 AI 工作台 intent/contextType 逻辑修正

- 粘贴文本统一为 `free_chat` intent + `pasted_question` contextType（不再误判为 `explain_question`）
- contextType 判断改为优先检查数据库 id（有 id → wrong_question/exam_question，无 id → pasted_question）
- `sendMessage()` 里的条件简化：已有稳定上下文时不再覆盖

## 4. 改动文件清单

| 文件 | 改动 |
|---|---|
| `RagService.java` | ThreadLocal userId、resolveEmbeddingProvider、keySource 参数 |
| `AIAnalysisController.java` | 加 RagService.setCurrentUserId / clearCurrentUserId |
| `AiWorkbenchController.java` | 同上 |
| `AiUsageLogMapper.xml` | WHERE 条件兼容 user_id IS NULL |
| `AiPricing.java` | embedding-2 定价 |
| `config.vue`（admin） | 供应商名称显示 |
| `ai-config/index.vue`（student） | 大小写、autocomplete、供应商名称、统一用量表格 |
| `knowledge-graph/index.vue` | intent/contextType/粘贴逻辑 |
| `22_fix_embedding_usage_logs.sql` | 历史数据迁移 |

## 5. 经验教训

1. **日志要关联发起者**：任何需要按用户查询的日志表，写入时必须填 `user_id`。最好在服务入口统一设置（ThreadLocal），日志写入处直接读取，而不是依赖调用方传参。
2. **前后端枚举值大小写要一致**：后端存 `"embedding"`、前端比 `"Embedding"`，这种问题很容易出现且难以发现。建议统一用小写或定义常量共享。
3. **密钥选择应按优先级而非来源类型**：公私密钥本质是同一类数据，应该放在同一个优先队列里排序。硬编码"只用公共智谱"既不灵活也不健壮。
4. **历史数据修复要考虑查询兼容**：修代码只解决未来数据，历史 NULL 记录需要 SQL 迁移 + 查询条件调整双重处理。
