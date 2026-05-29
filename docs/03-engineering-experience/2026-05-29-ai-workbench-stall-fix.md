# AI 工作台卡死问题排查与修复

**日期**：2026-05-29
**现象**：AI 学习工作台发消息后一直显示"正在检索知识库资料…""AI 正在生成回答…"，始终不出结果。
**影响**：学生端 AI 工作台完全不可用。

---

## 1. 现象复现

前端 SSE 连接到 `/api/student/ai/workbench/stream`，后端按序返回以下状态事件后挂住：

1. `status: 正在检索知识库资料…`
2. `status: AI 正在解析题目…`（或 `AI 正在生成回答…`）

之后不再有任何 `chunk` 事件，前端一直显示加载动画。

## 2. 排查过程

### 2.1 检查后端日志

`backend-8000.log` 最后若干行显示：

```text
01:56:03 ERROR RagService - GLM Embedding API call failed: 429 Too Many Requests
01:58:02 ERROR RagService - GLM Embedding API call failed: 429 Too Many Requests
02:11:14 ERROR RagService - GLM Embedding API call failed: 429 Too Many Requests
02:18:46 ERROR RagService - GLM Embedding API call failed: 429 Too Many Requests
```

每次对话请求都触发 embedding API 调用，全部被智谱限流返回 429。日志到此结束，说明后续 AI 流式调用也被卡住（同一 API Key 共享限流配额）。

### 2.2 追踪请求链路

```text
前端 postStream()
  → AiWorkbenchController.stream()          ← 创建 SseEmitter, CompletableFuture.runAsync()
    → AiOrchestratorServiceImpl.handleStream()
      → ragService.retrieve(query, 5)       ← 每次请求都执行
        → ragService.loadCandidates()       ← 每次全表扫描 t_text_content
        → ragService.embed(query)           ← 调智谱 embedding API（卡点 1）
        → cosine similarity 遍历所有候选    ← 每次重新 JSON 反序列化 embedding 字段
      → analysisService.analyzeWithAIStream() ← 智谱 chat API 也被 429（卡点 2）
```

### 2.3 定位两个根因

- **卡点 1**：每次请求都调 embedding API。`retrieve()` 内的 `embed(query)` 对每次用户输入做向量化，触发智谱 429 限流，后续 chat API 也被连带限流。
- **卡点 2**：每次都全表扫描 + 重复反序列化。`loadCandidates()` 没有 TTL 缓存；`retrieve()` 每次重新 `parseEmbedding()`，造成数据库压力大、CPU 浪费。

此外，即使是纯闲聊（无知识点、无题目上下文），也会走完整的 RAG 检索流程，完全没有必要。

## 3. 修复方案

### 3.1 RagService 候选向量缓存

文件：`source/xzs/src/main/java/com/mindskip/xzs/ai/RagService.java`

- 新增 `cachedCandidates`、`cachedEmbeddings`、`lastCacheTime` 三个 volatile 字段。
- `loadCandidates()` 增加 5 分钟 TTL：缓存未过期直接返回，过期后重新查表并缓存候选和已解析的 `float[]`。
- `retrieve()` 使用缓存的 `cachedEmbeddings`，跳过重复的 `parseEmbedding()` 调用。

```java
// 新增缓存字段
private volatile List<RagCandidate> cachedCandidates = null;
private volatile List<float[]> cachedEmbeddings = null;
private volatile long lastCacheTime = 0;
private static final long CACHE_TTL_MS = 5 * 60 * 1000;
```

**效果**：5 分钟内多次请求只查一次数据库，不做重复 JSON 反序列化。

### 3.2 Orchestrator 按需跳过 RAG

文件：`source/xzs/src/main/java/com/mindskip/xzs/service/impl/AiOrchestratorServiceImpl.java`

在 `handleStream()` 中，对 `free_chat` 意图且无知识点/题目上下文时跳过 RAG 检索：

```java
boolean hasContextKnowledge = request.getContext() != null
        && (request.getContext().getKnowledgePoint() != null
            || request.getContext().getQuestion() != null);
boolean needsRag = !AiIntentRouter.FREE_CHAT.equals(intent) || hasContextKnowledge;
if (needsRag) {
    // 只在有上下文时才做 RAG
}
```

**效果**：闲聊类请求直接走 AI 流式调用，不消耗 embedding API 配额，响应延迟从"等待限流超时"降到秒级。

## 4. 验证

1. 编译通过：`mvn compile -q` 无错误。
2. 重启后端，`Undertow started on port(s) 8000` 正常。
3. 前端刷新后，闲聊消息秒回（不触发 RAG）；有题目上下文时 RAG 走缓存。

## 5. 后续建议

- **embedding API 超时保护**：`RagService.embed()` 使用默认 `RestTemplate`（无超时），应设置 `connectTimeout` 和 `readTimeout`，避免 API 无响应时线程永远阻塞。
- **RAG 结果缓存**：对相同/相近 query 的 embedding 结果做短时缓存（如 Guava Cache 5 min），避免重复向量化。
- **限流降级**：embedding 返回 429 时应有退避策略（指数退避或直接跳过 RAG），而不是每次都重试。
- **监控**：在 `AiUsageLog` 中记录 embedding 和 chat API 的 HTTP 状态码，便于及时发现限流。

---

## 附：对话历史持久化（localStorage）

### 问题

Vue 组件的 `ref([])` 是内存状态，浏览器刷新或关闭后丢失。AI 工作台的对话历史如果一刷新就没了，用户体验很差。

### 方案：localStorage 快照

核心思路很简单——**每次对话内容变化时，把 Vue reactive state 序列化写进 localStorage；页面加载时读回来恢复。**

文件：`source/vue/xzs-student/src/views/knowledge-graph/index.vue`

```javascript
const STORAGE_KEY = 'master408-ai-messages'

// 写：每次消息变化时调用
const saveMessages = () => {
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(messages.value))
  } catch (e) { /* localStorage 满了或隐私模式，静默忽略 */ }
}

// 读：页面加载时调用
const restoreMessages = () => {
  try {
    const saved = localStorage.getItem(STORAGE_KEY)
    if (saved) {
      const parsed = JSON.parse(saved)
      if (Array.isArray(parsed) && parsed.length) return parsed
    }
  } catch (e) { /* JSON 损坏，静默降级 */ }
  return null
}
```

**写入时机**：`saveMessages()` 在以下位置被调用：

- `updateAssistantMessage()` — AI 每输出一段内容
- `sendWorkbenchMessage()` 的 `finally` — 一次对话结束
- `confirmAgentDraft()` — 确认练习草案后
- `clearMessages()` — 手动清空

**恢复时机**：`onMounted` 中调用 `restoreMessages()`，有缓存则恢复，没有则展示默认欢迎语。

**清空**：在聊天标题栏加了清空按钮（垃圾桶图标），点击后将 messages 重置为初始欢迎语并写入 localStorage 覆盖旧数据。

### 适用场景

| 场景                             | 是否适用                                                       |
|----------------------------------|----------------------------------------------------------------|
| SPA 页面内状态跨刷新保留         | 适用                                                           |
| 多标签页共享状态                 | 不适用（localStorage 是同源共享的，但 Vue 不会自动同步）       |
| 大量数据持久化                   | 不适用（localStorage 通常 5-10 MB 上限）                       |
| 敏感数据                         | 不适用（localStorage 明文存储）                                |

如果将来对话量太大（超过 localStorage 上限），可以改为：

- IndexedDB（容量更大）
- 后端接口持久化到数据库（跨设备可用）

---

## 附 2：Admin 前端登录失败（跨域 Cookie 丢失）

### 现象

浏览器访问 `http://127.0.0.1:8002` 打开管理后台，输入账号密码点登录，接口返回成功，但页面仍然显示"用户未登录"，无法进入后台。改为 `http://localhost:8002` 访问则正常。

### 根因

`xzs-admin/.env` 配置了 `VITE_APP_URL=http://localhost:8000`，导致 axios 的 `baseURL` 直接指向后端 `localhost:8000`，绕过了 Vite dev server 的代理。

浏览器中 `127.0.0.1` 和 `localhost` 是**不同的域**。登录成功后，后端通过 `Set-Cookie` 写入 `JSESSIONID`，cookie 域名为 `localhost`。当浏览器在 `127.0.0.1` 页面发后续请求到 `localhost:8000` 时，浏览器不会携带这个 cookie（跨域 + SameSite 策略），导致每次请求都被视为未登录。

### 修复

将 `.env` 中的 `VITE_APP_URL` 清空，让请求走 Vite 代理：

```text
# 修改前：axios 直连后端，产生跨域
VITE_APP_URL=http://localhost:8000

# 修改后：走 Vite proxy（vite.config.js 中已配置 /api → localhost:8000）
VITE_APP_URL=
```

这样无论用 `localhost` 还是 `127.0.0.1` 访问前端页面，API 请求都由 Vite dev server 代理转发，浏览器只与同源通信，不存在跨域问题。

### 关键知识点

- `127.0.0.1` ≠ `localhost`：浏览器将它们视为不同源，cookie 不会共享。
- Vite / webpack dev server 的 proxy 配置只在**无 baseURL** 时生效（请求发给 dev server 自身才会命中代理规则）。
- `baseURL` 一旦设了绝对地址，请求直接发到目标服务器，完全绕过 dev server 代理。
- 开发环境应尽量让 API 请求走 dev server 代理，避免跨域和 cookie 域名问题。
