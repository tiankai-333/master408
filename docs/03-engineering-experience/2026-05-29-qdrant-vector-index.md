# Qdrant 向量索引接入

> 日期: 2026-05-29

## 背景

原 RAG 检索用内存余弦相似度（`RagService.cosineSimilarity`），embedding 调智谱 API。问题：

- `t_text_content` 6883 条记录只有 1 条有 embedding，内存方案几乎不可用
- 全量 embed 后内存加载所有向量，扩展性差
- Qdrant 基础设施已建好（`QdrantRagIndexServiceImpl`、`rag_chunk` 表）但未接通

## 方案

用 Qdrant 替代内存方案，题目 + 知识库文档统一走向量索引。

### 数据流

```
t_question + t_text_content
        │ (backfill SQL)
        ▼
rag_document (document_type='question')
rag_chunk   (每题一条 chunk)
        │ (embed → Qdrant upsert)
        ▼
Qdrant collection: xzs_408_chunks
        │ (retrieve 时 search)
        ▼
RagService.retrieve() → RagDocument 列表
```

### 改动文件

| 文件 | 改动 |
|------|------|
| `deploy/docker-compose.yml` | 加 `qdrant` 服务，端口 6333，持久化 volume |
| `application-dev.yml` | `ai.rag.vector.enabled: true`，Qdrant URL |
| `RagService.java` | 注入 `RagIndexService`，Qdrant 启用时走 `retrieveFromQdrant()` |
| `RagDocumentMapper.xml` | `backfillDocumentsFromQuestions` + `backfillChunksFromQuestions` SQL |
| `RagDocumentMapper.java` | 新增两个 mapper 方法 |
| `RagDocumentService.java` | 新增 `backfillFromQuestions()` 接口 |
| `RagDocumentServiceImpl.java` | 实现题目灌入 |
| `AiConfigController.java` | `POST /api/admin/ai-config/rag/index` 触发全量索引 |

### 踩坑记录

- `t_question` 没有 `knowledge_point_id` 列，实际是 `knowledge_point`（varchar），SQL 已修正
- `ai_user_key` 表缺失导致 analysis 接口 500，已手动建表
- Qdrant 旧版本存储格式不兼容（`on_disk` vs `mmap`），需清空 `deploy/qdrant-data/` 重建
- 后台索引任务与前端请求共用 embed API，限频 429 会互相影响

### 关键设计决策

- **Qdrant 不可用时 fallback 到内存方案**：`ragIndexService.isEnabled()` 为 false 走原逻辑
- **索引幂等**：SQL 用 `NOT EXISTS` 防重复灌入，`rag_embedding` 表记录已索引状态
- **批量处理**：每次取 20 条 indexable chunk，embed 后 upsert，避免 API 限频

## 使用方法

### 1. 启动 Qdrant

```bash
# Docker Compose（本地开发）
cd deploy
docker compose up -d qdrant

# 或直接 docker run（适用于 Linux 无 Desktop 的场景）
docker run -d --name qdrant \
  -p 6333:6333 -p 6334:6334 \
  -v qdrant_storage:/qdrant/storage \
  qdrant/qdrant:latest
```

### 2. 启动后端

确认日志输出 `Qdrant RAG index is enabled`。

### 3. 触发全量索引

```bash
curl -X POST http://localhost:8000/api/admin/ai-config/rag/index \
  -H "Content-Type: application/json" \
  -H "token: <admin-token>" \
  -d '{"source": "all"}'
```

`source` 参数：`questions`（仅题目）、`knowledge`（仅知识库）、`all`（两者都灌）。

### 4. 验证

```bash
# Qdrant collection 状态
curl http://127.0.0.1:6333/collections/xzs_408_chunks
```

## 当前进度

### 已完成

- 代码全部完成，编译通过，功能可用
- Docker Qdrant 运行正常，collection `xzs_408_chunks` 状态 green
- **3369 条向量已入库**（6613 题中部分 + 119 知识库）
- 408 科目覆盖：数据结构、计组、OS、网络、408综合 共 699/1223 已索引
- 端到端验证通过：学生端 analysis 接口正常返回 AI 分析结果

### 未完成 — 本地 embedding 模型替换

**问题**：构建阶段用智谱 Embedding-2 API 批量索引，消耗 ~30000 次 API 调用、~980 万 token。成本高且慢（限频 429）。

**教训：构建走本地，查询走云端。**

**下一步**：

1. 下载 `BAAI/bge-large-zh-v1.5`（1.3GB，1024 维，中文效果好）
2. 写 Python 脚本本地批量 embed，直接写入 Qdrant
3. **注意**：本地模型与智谱 Embedding-2 向量空间不同，必须全量重新索引，不能混用
4. 重新索引后，查询时的 embed 也要改走本地模型（或本地 embedding 服务）
5. 智谱 API 仅作为 fallback 或查询时的选项

**相关选择**：
- `bge-large-zh-v1.5`（推荐）：1024 维，中文最佳，1.3GB
- `bge-small-zh-v1.5`：512 维，90MB，精度较差
- 智谱 Embedding-2：不开源，无法本地部署

## 数据量参考

| 数据 | 数量 |
|------|------|
| `t_question` 总量 | 6613 |
| 408 科目题目（subject_id 1-5） | 1223 |
| 知识库文档 | 119 |
| Qdrant 已索引 | 3369 |
| embedding 维度 | 1024（embedding-2 模型） |

## 相关文件

- 排错参考: `AI_AGENT_TEST_GUIDE.md`
- 上一轮 RAG 开发: `2026-05-ai-rag-development-log.md`
