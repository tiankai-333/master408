#  Codex 疑难问题速查手册

> 目标读者：AI Agent（Codex / Claude Code），用于减少重复排查时间。
> 约定：所有路径相对于仓库根 `c:\Dev\Workspaces\master408\`。

***

## 1. Docker 容器网络问题

### 1.1 pip install 超时（容器内无法访问 PyPI）

**现象**：

```
docker run --rm --network xzs-net python:3.11-slim pip install pymysql requests
# → Retrying ... ReadTimeoutError
```

**涉及文件**：

- `deploy/docker-compose.yml` — xzs-net 网络定义
- `ai/embed_questions.py` — 需要 pymysql + requests 的脚本

**根因**：云服务器 `118.31.34.132` 容器内 DNS/网络 无法稳定访问 `pypi.org`。

**已知可用的 workaround**：

- 在**宿主机**上 pip install，然后通过暴露 MySQL 端口来连接。但 MySQL 容器默认未暴露 3306 到宿主机。
- 修改 `deploy/docker-compose.yml` 中 mysql 服务，临时加 `ports: - "3306:3306"`，然后宿主机脚本连 `127.0.0.1`。

### 1.2 MySQL 容器主机名无法解析

**现象**：

```
docker run --rm --network xzs-net python:3.11-slim python3 -c "import socket; socket.gethostbyname('mysql')"
# → socket.gaierror
```

**涉及文件**：

- `deploy/docker-compose.yml` L4-L18（mysql 服务定义，container\_name: `xzs-mysql`）
- `ai/embed_questions.py` L18-L25（DB\_CONFIG 的 host 字段）

**根因**：docker-compose 中 mysql 服务的 `container_name` 是 `xzs-mysql`，不是 `mysql`。在 `--network xzs-net` 下应使用 `xzs-mysql` 作为主机名。

**快速修复**：`DB_CONFIG["host"] = "xzs-mysql"` 或 `"127.0.0.1"`（如果端口已暴露）。

***

## 2. MySQL Schema 问题

### 2.1 Row size too large (8126B)

**现象**：

```
ERROR 1118 (42000): Row size too large. The maximum row size for the used table type is 8126.
```

**触发场景**：对已有大量 TEXT 列的表（如 `t_question`）再执行 `ALTER TABLE ADD COLUMN ... TEXT`。

**涉及文件**：

- `database/05_rag_embeddings.sql` — embedding 列添加
- 表：`t_question`, `t_text_content`

**解决方案**：使用 `MEDIUMTEXT` 或 `LONGTEXT`（存储在行外），并指定 `ROW_FORMAT=DYNAMIC`：

```sql
ALTER TABLE t_text_content ADD COLUMN embedding LONGTEXT NULL 
  COMMENT '向量嵌入(JSON float[])' ;
-- InnoDB 默认 ROW_FORMAT=DYNAMIC 时 LONGTEXT 不占行内空间
```

### 2.2 列名不存在/误用

**现象**：

```
pymysql.err.OperationalError: (1054, "Unknown column 'q.question_title' in 'field list'")
```

**涉及文件**：

- `ai/embed_questions.py` L42 — 曾用 `q.question_title`，正确列名是 `q.title`

**快速定位**：先用 `SHOW COLUMNS FROM t_question` 或用 `DESC t_question` 确认列名。

***

## 3. PowerShell 内联 Python 转义问题

**现象**：在 PowerShell 中用 `python -c "..."` 运行包含 SQL 字符串的 Python 代码时，多重引号转义极易失败。

**错误示例**：

```powershell
python -c "import pymysql; conn = pymysql.connect(host='127.0.0.1', ...)"
# → 单引号在 PowerShell 中不会被正确处理
```

**正确做法**：始终将 Python 代码写入 `.py` 文件再执行，避免内联：

```powershell
# ❌ 不要这样做
python -c "很长的代码..."

# ✅ 这样做
New-Item -Path tmp_script.py -Value @'
很长的代码...
'@
python tmp_script.py
```

**涉及文件**：所有 `tmp_*.py` 临时脚本（当前仓库中约 17 个待清理）。

***

## 4. Git 合并冲突 — README.md 重叠编辑

**现象**：`feature/ai` 和 `dev` 分支都对 `README.md` 的分支表格和更新日志段落做了修改，`git merge` 时产生冲突。

**涉及文件**：

- `README.md` L37-L46（分支表格）
- `README.md` L52-L97（更新日志）

**冲突模式**：

```
<<<<<<< HEAD (dev 的版本)
| `feature/crawler-and-exam-data` | ... |
=======
| `feature/ai` | ... |
>>>>>>> feature/ai (AI 分支的版本)
```

**解决策略**：保留两者的内容，合并到同一个表格/段落中，而不是二选一。

**预防**：在多个分支上避免对同一文件的同一段落做结构性修改；如果不可避免，先合并一个分支到另一个再继续。

***

## 5. Docker Compose 端口映射缺失 → 502 Bad Gateway

**现象**：Nginx 返回 502，后端容器运行中但端口不可达。

```
curl http://127.0.0.1:8000/api/...
# → Connection refused
```

**涉及文件**：

- `deploy/docker-compose.yml` L20-L34（xzs-backend 服务定义）— 曾缺少 `ports: "8000:8000"`

**根因**：Docker Compose 中服务默认不暴露端口到宿主机，即使容器内部监听 8000，也需要 `ports` 映射。

**检查方法**：

```bash
docker ps --format "table {{.Names}}\t{{.Ports}}"
# xzs-backend 必须显示 0.0.0.0:8000->8000/tcp
```

**修复**：在 docker-compose.yml 的 backend 服务中添加：

```yaml
ports:
  - "8000:8000"
```

***

## 6. 数据库数据完整性

### 6.1 导入冲突（Duplicate entry）

**现象**：

```
ERROR 1062 (23000): Duplicate entry '1' for key 'PRIMARY'
```

**涉及文件**：

- `database/04_exam_data.sql` — 包含 INSERT 语句

**根因**：目标数据库已有旧用户/旧数据，与 SQL 中的 INSERT 冲突。

**解决方案**：在导入数据 SQL 前先 TRUNCATE 所有表（注意外键顺序，先删子表再删主表）：

```sql
-- 按外键依赖反向 TRUNCATE
TRUNCATE TABLE t_exam_paper_question_customer_answer;
TRUNCATE TABLE t_exam_paper_answer;
TRUNCATE TABLE t_user_event_log;
TRUNCATE TABLE t_exam_paper_question;
TRUNCATE TABLE t_exam_paper;
TRUNCATE TABLE t_question_knowledge;
TRUNCATE TABLE t_question;
TRUNCATE TABLE t_subject;
TRUNCATE TABLE t_user;
```

### 6.2 外键悬空（Dangling reference）

**快速检查 SQL**：

```sql
-- 试卷引用的 TextContent 是否存在
SELECT ep.id, ep.frame_text_content_id
FROM t_exam_paper ep
LEFT JOIN t_text_content tc ON ep.frame_text_content_id = tc.id
WHERE ep.frame_text_content_id IS NOT NULL AND tc.id IS NULL;

-- 题目引用的学科是否存在
SELECT q.id, q.subject_id
FROM t_question q
LEFT JOIN t_subject s ON q.subject_id = s.id
WHERE s.id IS NULL;
```

***

## 7. 环境变量 / API Key 配置

**现象**：AI 分析接口返回空或报错。

**涉及文件**：

- `source/xzs/src/main/resources/application-prod.yml` — `ai.api.key` 配置

**检查步骤**：

```bash
# 在服务器上检查
docker exec xzs-backend cat /app/application-prod.yml | grep -A2 "ai:"
```

**安全建议**：API Key 不应硬编码在 yml 中，应通过 Docker 环境变量注入：

```yaml
# docker-compose.yml
services:
  xzs-backend:
    environment:
      - AI_API_KEY=${AI_API_KEY}
```

***

## 快速诊断速查表

| 症状              | 最可能原因                         | 涉文件                                                   |
| --------------- | ----------------------------- | ----------------------------------------------------- |
| 前端页 502         | backend 端口未暴露                 | `deploy/docker-compose.yml`                           |
| 后端 500          | 数据库字段 NULL 触发 Java NPE        | 各 Controller + `ExamUtil.java`                        |
| AI 返回空          | API Key 未配 / embedding 全 NULL | `application-prod.yml` / `t_text_content.embedding`   |
| pip install 超时  | 云服务器容器网络限制                    | `deploy/docker-compose.yml` + `ai/embed_questions.py` |
| MySQL 连接拒绝      | 容器名不匹配或端口未暴露                  | `deploy/docker-compose.yml`                           |
| Data too long   | TEXT 列不够，需 MEDIUMTEXT         | 各 `database/*.sql`                                    |
| Duplicate entry | 未 TRUNCATE 就 INSERT           | `database/04_exam_data.sql`                           |
| git merge 冲突    | 多分支改同一段落                      | `README.md`                                           |

***

## 当前待解决的阻塞项

| # | 阻塞项                                | 影响范围          | 建议方案                                                             |
| - | ---------------------------------- | ------------- | ---------------------------------------------------------------- |
| 1 | 云端无法运行 embed\_questions.py（pip 超时） | RAG 向量全部 NULL | ① 宿主机暴露 MySQL 端口 → 宿主机运行脚本；② 或将 pymysql 预装到 Dockerfile           |
| 2 | dev 分支合并未提交（冲突已解）                  | 代码未同步         | `git add README.md && git commit -m "Merge feature/ai into dev"` |
| 3 | 17 个 tmp\_\*.py 临时文件残留             | 仓库污染          | `git rm tmp_*.py` 后提交清理                                          |

