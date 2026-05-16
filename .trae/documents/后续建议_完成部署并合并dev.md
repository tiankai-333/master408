# 后续建议：完成 RAG Embedding 生成 + 前端验证 + 合并 dev

## 背景

`feature/ai` 分支已成功部署到云端 `118.31.34.132`。数据库完整（658 题、14 卷、0 悬空），后端 API 正常响应。但 RAG 检索功能尚未完全生效——`t_text_content.embedding` 列存在但全部为 NULL，需要运行 `embed_questions.py` 批量生成向量嵌入。

---

## 任务 1：云端生成 RAG Embedding

### 1.1 前置条件检查

| 检查项 | 当前状态 | 说明 |
|--------|---------|------|
| embedding 列 | ✅ 已存在 | `05_rag_embeddings.sql` 已执行 |
| Python 依赖 | ❓ 待确认 | 服务器可能缺少 `pymysql` `requests` |
| GLM API Key | ❓ 待确认 | 检查 `application-prod.yml` 中的 `ai.api.key` |
| MySQL 网络可达 | ⚠️ 需处理 | MySQL 容器未暴露 3306 到宿主机，脚本需从容器内运行或通过 Docker 网络访问 |

### 1.2 执行步骤

```
1. SSH root@118.31.34.132 (密码 D0ushiji@xi@ng)
2. pip3 install pymysql requests
3. 修改 embed_questions.py 的 DB_CONFIG：
   - host: "mysql" (docker 容器名) 或 "xzs-mysql" 
   - 或者 docker run --rm --network xzs-net python:3.11-slim ...
4. 运行 python3 embed_questions.py
5. 验证：docker exec xzs-mysql mysql -u root -p'doushijiaxiang0.' xzs \
        -e "SELECT COUNT(*) AS embedded, COUNT(*)-COUNT(embedding) AS pending FROM t_text_content;"
```

### 1.3 风险点

- **API 限流**：GLM Embedding API 可能有 QPS 限制，`embed_questions.py` 中已设置 `time.sleep(0.2)` 间隔
- **MySQL 连接问题**：MySQL 容器未暴露端口。最佳方案是修改脚本连接 `xzs-mysql:3306`（Docker 内网），然后在 backend 容器中运行：
  ```bash
  docker cp embed_questions.py xzs-backend:/app/
  docker exec xzs-backend python3 /app/embed_questions.py
  ```
- **658 条 × 0.2s 间隔 ≈ 2-3 分钟**，需确保 SSH 连接稳定

---

## 任务 2：浏览器前端功能验证

### 2.1 验证清单

| 页面 | 地址 | 预期结果 | 优先级 |
|------|------|---------|--------|
| 学生端登录 | `http://118.31.34.132/student/` | 显示登录页，正常登录（231310423/123456） | 🔴 高 |
| 考试记录 | `http://118.31.34.132/student/#/record/index` | 显示试卷列表，不报"系统内部错误" | 🔴 高 |
| 错题本 | `http://118.31.34.132/student/#/question-error/index` | 显示错题列表（可能为空，但不应报错） | 🔴 高 |
| AI 知识图谱 | `http://118.31.34.132/student/#/knowledge-graph/index` | 显示 4 种 Skill 风格按钮（📚/🎓/❓/⚡） | 🟡 中 |
| AI 分析 | 点击风格按钮发送题目 | AI 返回五步法分析结果 | 🟡 中 |
| 管理端登录 | `http://118.31.34.132/admin/` | 显示登录页（admin/123456） | 🟢 低 |

### 2.2 常见问题排查

| 现象 | 可能原因 | 修复 |
|------|---------|------|
| 页面白屏 | 前端 dist 未正确上传 | 检查 `/opt/xzs-deploy/static/student/index.html` |
| 接口 404 | Nginx 配置不对 | 检查 proxy_pass 是否正确指向 `http://127.0.0.1:8000` |
| 接口 500 | 数据库数据问题 | 检查后端日志 `docker logs xzs-backend --tail 50` |
| AI 分析返回空 | API Key 未配置/已过期 | 检查服务器 `application-prod.yml` |

---

## 任务 3：合并 feature/ai → dev，覆盖稳定版

### 3.1 步骤

```
git checkout dev
git merge feature/ai --no-ff -m "Merge: AI RAG system + 4 skill styles + Docker deploy fixes"
git push origin dev
```

### 3.2 变更摘要（feature/ai → dev）

| 类别 | 文件 | 说明 |
|------|------|------|
| AI RAG | `RagService.java` `PromptTemplate.java` `AnalysisService.java` `AIAnalysisController.java` | 向量检索 + 模板优化 |
| AI 模板 | `ai/prompts/analysis/*.json` | 4 种风格五步法格式 |
| AI 脚本 | `ai/embed_questions.py` | 批量 embedding 生成 |
| 数据库 | `database/05_rag_embeddings.sql` | embedding 列 DDL |
| 领域 | `TextContent.java` `TextContentMapper.java/xml` | embedding 字段支持 |
| 前端 | `knowledge-graph/index.vue` | 调用 RAG API + 展示参考来源 |
| 部署 | `deploy/Dockerfile` `deploy/docker-compose.yml` `deploy/nginx.conf` `deploy/REDEPLOY_GUIDE.md` | Docker 部署基础设施 |
| 文档 | `README.md` | AI 系统架构文档 + 更新日志 |

---

## 风险点与建议

1. **AI API Key 安全**：当前 `ai.api.key` 硬编码在 `application-prod.yml`，建议改为环境变量注入或 Docker secrets
2. **DevTools 生产环境**：当前 Docker 镜像包含 `spring-boot-devtools`，生产环境应排除以减小镜像体积
3. **前端 HTTPS**：当前使用 HTTP，生产环境建议配置 SSL 证书
4. **数据库备份**：建议在合并 dev 前执行 `mysqldump` 备份云端数据库
5. **embed_questions.py 网络依赖**：脚本需要修改 DB 连接方式以适应 Docker 网络环境，建议在 `feature/ai` 分支中提前修复此问题
