# 学之思 (xzs) 408Master — feature/ai 重新部署操作指南

## 部署日期

2026-05-16

---

## 一、云服务器当前状态诊断

### 1.1 服务器信息

| 项目 | 值 |
|------|-----|
| 公网 IP | `118.31.34.132` |
| SSH 用户 | `root` |
| SSH 密码 | `D0ushiji@xi@ng` |
| 系统 | Ubuntu 22.04.4 LTS (x86_64) |
| 磁盘 | 20GB (42% 使用, 11GB 可用) |
| Docker | 29.5.0 (阿里云镜像加速) |
| 部署目录 | `/opt/xzs-deploy/` |

### 1.2 当前服务状态

| 服务 | 运行方式 | 状态 | 说明 |
|------|---------|------|------|
| Nginx | 宿主机 systemd | ✅ 运行中 (port 80) | `/etc/nginx/sites-enabled/default` |
| xzs-backend | Docker 容器 | ⚠️ 运行中但报错 | `127.0.0.1:8000` |
| xzs-mysql | Docker 容器 | ⚠️ 运行中但数据为空 | 内部 3306 |

### 1.3 ⚠️ 发现的关键问题

| # | 问题 | 影响 | 修复方式 |
|---|------|------|---------|
| 1 | **数据库完全为空** | 0 条题目、0 条试卷，所有页面无数据 | 导入完整 SQL（含数据） |
| 2 | **缺少 exam 数据** | `t_text_content`、`t_question`、`t_exam_paper` 表结构有但无数据 | 执行 `04_exam_data.sql` |
| 3 | **缺少 embedding 列** | RAG 检索功能不可用 | 执行 `05_rag_embeddings.sql` |
| 4 | **旧版 JAR 包** | May 15 的旧代码，无 AI RAG 功能 | 重新打包 feature/ai 并构建 Docker 镜像 |
| 5 | **旧版前端静态文件** | 无 4 种 Skill 风格切换界面 | 重新构建前端 dist |
| 6 | **后端报错 knowledge_point 表不存在** | 旧版 SQL schema 不完整 | 使用新版完整初始化脚本 |

### 1.4 数据库对比

| 指标 | 本地（feature/ai） | 云端（118.31.34.132） | 差距 |
|------|-------------------|----------------------|------|
| t_text_content | 735 | 0 | ❌ 缺 735 条 |
| t_question | 714 | 0 | ❌ 缺 714 条 |
| t_exam_paper | 14 | 0 | ❌ 缺 14 条 |
| t_user | 4 | 8 | - |
| t_subject | 14 | 7 | ❌ 缺"408综合"等 |
| embedding 列 | ✅ 有 | ❌ 无 | ❌ RAG 不可用 |
| 悬空引用 | 0 ✅ | 0（因无数据） | N/A |

---

## 二、架构图

```
浏览器 (公网) → http://118.31.34.132
    │
    ▼
┌──────────────────────────────────────────┐
│  Nginx (宿主机 systemd, :80)              │
│  root: /opt/xzs-deploy/static            │
│                                           │
│  /student/*  → static/student/ SPA       │
│  /admin/*    → static/admin/ SPA         │
│  /api/*      → proxy_pass :8000          │
└──────────────────────────────────────────┘
         │ /api/*
         ▼
┌──────────────────────┐    ┌──────────────────┐
│  xzs-backend (:8000) │    │  xzs-mysql (:3306)│
│  Docker 容器          │───▶│  Docker 容器       │
│  Memory: 512m        │    │  Memory: 512m     │
│  SPRING_PROFILES=prod│    │  RootPass 注入了   │
└──────────────────────┘    └──────────────────┘
```

### 网络

所有容器共享 `xzs-net` Docker bridge 网络。Backend 通过容器名 `mysql` 访问数据库。

---

## 三、重新部署步骤（逐步执行）

### ⚠️ 重要：在执行以下操作前，先确保本地已切换到 `feature/ai` 分支

```bash
git checkout feature/ai
git pull origin feature/ai
```

---

### 第 1 步：本地构建前端

在本地 Windows 执行：

```powershell
# 学生端
cd source\vue\xzs-student
npm install --registry=https://registry.npmmirror.com
npm run build
# 产出：source\vue\xzs-student\dist\  → 需要上传

# 管理端
cd ..\..\vue\xzs-admin
npm install --registry=https://registry.npmmirror.com
npm run build
# 产出：source\vue\xzs-admin\dist\  → 需要上传
```

### 第 2 步：本地构建后端

```powershell
cd source\xzs
mvn clean package -DskipTests
# 产出：source\xzs\target\xzs-3.9.0.jar
```

### 第 3 步：打包 SQL 数据为单文件导入用

```powershell
cd database
# 创建用于云端的合并 SQL（去掉 DROP/CREATE DATABASE 语句，保留 CREATE TABLE IF NOT EXISTS）
# 注意：直接使用 04_exam_data.sql 文件，它包含完整的 INSERT 数据
```

### 第 4 步：上传文件到云服务器

```powershell
# 安装 paramiko 用于 SCP（或使用 WinSCP/FileZilla）
pip install paramiko

# 上传 JAR 包
scp source\xzs\target\xzs-3.9.0.jar root@118.31.34.132:/opt/xzs-deploy/

# 上传前端文件
scp -r source\vue\xzs-student\dist\* root@118.31.34.132:/opt/xzs-deploy/static/student/
scp -r source\vue\xzs-admin\dist\* root@118.31.34.132:/opt/xzs-deploy/static/admin/

# 上传 SQL 数据文件
scp database\04_exam_data.sql root@118.31.34.132:/opt/xzs-deploy/sql/
scp database\05_rag_embeddings.sql root@118.31.34.132:/opt/xzs-deploy/sql/
```

> **上传工具选择**：你可以使用任意 SCP 工具，如：
> - Windows 自带 `scp` 命令（PowerShell）
> - WinSCP 图形界面
> - FileZilla (SFTP 模式)
> - `rsync -avz` (如果服务器有 rsync)

### 第 5 步：SSH 连接云服务器

```bash
ssh root@118.31.34.132
# 密码：D0ushiji@xi@ng
```

### 第 6 步：停止旧服务

```bash
cd /opt/xzs-deploy

# 停止后端
docker stop xzs-backend || true
docker rm xzs-backend || true

# MySQL 保留不删（数据持久化）
# docker stop xzs-mysql || true

# 删除旧镜像
docker rmi xzs-backend:latest || true
```

### 第 7 步：清理数据库旧数据并重新初始化

```bash
# 清理现有题目数据（保留表结构）
docker exec xzs-mysql mysql -u root -p'doushijiaxiang0.' xzs -e "
  SET FOREIGN_KEY_CHECKS=0;
  TRUNCATE TABLE t_exam_paper_question_customer_answer;
  TRUNCATE TABLE t_task_exam_customer_answer;
  TRUNCATE TABLE t_exam_paper_answer;
  TRUNCATE TABLE t_task_exam;
  DELETE FROM t_exam_paper WHERE id < 100;
  DELETE FROM t_question WHERE id < 1000;
  DELETE FROM t_text_content WHERE id < 1000;
  SET FOREIGN_KEY_CHECKS=1;
"

# 导入考试数据（735 条题目 + 14 套试卷）
docker exec -i xzs-mysql mysql -u root -p'doushijiaxiang0.' xzs < /opt/xzs-deploy/sql/04_exam_data.sql

# 添加 embedding 列（RAG 向量存储）
docker exec -i xzs-mysql mysql -u root -p'doushijiaxiang0.' xzs < /opt/xzs-deploy/sql/05_rag_embeddings.sql
```

### 第 8 步：验证数据库恢复

```bash
docker exec xzs-mysql mysql -u root -p'doushijiaxiang0.' xzs -e "
  SELECT 'text_content' AS tbl, COUNT(*) AS cnt FROM t_text_content
  UNION ALL SELECT 'question', COUNT(*) FROM t_question
  UNION ALL SELECT 'exam_paper', COUNT(*) FROM t_exam_paper
  UNION ALL SELECT 'subject', COUNT(*) FROM t_subject
  UNION ALL SELECT 'user', COUNT(*) FROM t_user;
"

# 预期输出：
# text_content    735
# question        714
# exam_paper      14
# subject         14
# user            4
```

### 第 9 步：验证悬空引用

```bash
docker exec xzs-mysql mysql -u root -p'doushijiaxiang0.' xzs -e "
  SELECT 'exam_paper->text_content' AS ck, COUNT(*) AS dangling
  FROM t_exam_paper ep LEFT JOIN t_text_content tc ON ep.frame_text_content_id=tc.id
  WHERE tc.id IS NULL AND ep.frame_text_content_id IS NOT NULL
  UNION ALL
  SELECT 'question->text_content', COUNT(*)
  FROM t_question q LEFT JOIN t_text_content tc ON q.info_text_content_id=tc.id
  WHERE tc.id IS NULL AND q.info_text_content_id IS NOT NULL
  UNION ALL
  SELECT 'question->subject', COUNT(*)
  FROM t_question q LEFT JOIN t_subject s ON q.subject_id=s.id
  WHERE s.id IS NULL AND q.subject_id IS NOT NULL
  UNION ALL
  SELECT 'answer->text_content', COUNT(*)
  FROM t_exam_paper_question_customer_answer a LEFT JOIN t_text_content tc ON a.question_text_content_id=tc.id
  WHERE tc.id IS NULL AND a.question_text_content_id IS NOT NULL;
"
# 预期：全部为 0
```

### 第 10 步：重新构建并启动后端

```bash
cd /opt/xzs-deploy

# 重新构建 Docker 镜像（使用新的 JAR 包）
docker compose build backend

# 启动后端
docker compose up -d backend

# 观察日志确认启动成功
docker logs -f xzs-backend
# 等待看到 "Started XzsApplication" 表示启动成功，然后 Ctrl+C 退出日志
```

### 第 11 步：确认 Nginx 配置正确

```bash
# 查看当前 Nginx 配置（应已正确配置）
cat /etc/nginx/sites-enabled/default

# 如果配置有变更，重载 Nginx
nginx -t && systemctl reload nginx
```

### 第 12 步：最终验证

```bash
# API 健康检查
curl -s http://localhost/api/student/dashboard/index | python -m json.tool

# 考试记录 API（应返回正常数据或空列表）
curl -s -X POST http://localhost/api/student/question/answer/page \
  -H "Content-Type: application/json" \
  -d '{"pageIndex":1,"pageSize":10}' | python -m json.tool

# AI 风格列表
curl -s http://localhost/api/student/ai/styles | python -m json.tool
```

### 第 13 步：浏览器验证

| 页面 | 地址 | 预期结果 |
|------|------|---------|
| 学生端首页 | `http://118.31.34.132/student/` | 显示登录页 |
| 考试记录 | `http://118.31.34.132/student/#/record/index` | 正常显示（不报"系统内部错误"） |
| 错题本 | `http://118.31.34.132/student/#/question-error/index` | 正常显示 |
| AI 知识图谱 | `http://118.31.34.132/student/#/knowledge-graph/index` | 显示 4 种 Skill 风格按钮 |

---

## 四、生成 RAG Embedding（部署后执行）

部署完成并验证正常后，在服务器上运行 embedding 生成脚本：

```bash
# 在服务器上安装 Python 依赖
pip3 install pymysql requests

# 上传并运行 embedding 脚本
# （将本地的 ai/embed_questions.py 上传到服务器）
scp ai/embed_questions.py root@118.31.34.132:/opt/xzs-deploy/

# SSH 到服务器运行
ssh root@118.31.34.132
cd /opt/xzs-deploy

# 修改脚本中的数据库连接（需要连接到 Docker MySQL）
# 运行脚本
python3 embed_questions.py
```

> ⚠️ **embed_questions.py 需要修改**：因为 MySQL 在 Docker 容器内，host 需要改为容器名或宿主机暴露的端口。或者直接用 Docker exec 方式执行。

由于 MySQL 只在 Docker 内网可访问，更好的方式是：

```bash
# 通过 Docker 网络访问 MySQL
docker exec xzs-backend python3 /app/embed_questions.py
# 或者修改脚本的 DB_CONFIG 连接 127.0.0.1:3306（需先暴露端口）
```

---

## 五、常见问题排查

### Q1: 后端启动后立即退出

```bash
docker logs xzs-backend --tail 50
```
检查是否数据库连接失败或 SQL 错误。

### Q2: 页面显示"系统内部错误"

1. 检查后端日志：`docker logs xzs-backend --tail 50 | grep -i error`
2. 检查数据库是否有悬空引用（见第 9 步）
3. 确认 SQL 数据已正确导入

### Q3: AI 分析返回空

1. 确认 `ai.api.key` 在 `application-prod.yml` 中已正确配置
2. 检查后端日志是否有 API 调用错误
3. RAG 功能需先运行 `embed_questions.py`

### Q4: Nginx 502 Bad Gateway

后端未启动或端口不对：
```bash
docker ps | grep backend  # 确认容器运行中
netstat -tlnp | grep 8000 # 确认端口监听
```

### Q5: 静态文件 404

```bash
ls -la /opt/xzs-deploy/static/student/   # 确认 index.html 存在
ls -la /opt/xzs-deploy/static/admin/     # 确认 index.html 存在
```

---

## 六、简易一键部署脚本

将以下内容保存为 `deploy_to_server.sh`：

```bash
#!/bin/bash
# Master408 feature/ai 一键部署脚本
# 使用方法：在本地 Git Bash 中执行

SERVER="root@118.31.34.132"
SSH_PASS="D0ushiji@xi@ng"
REMOTE_DIR="/opt/xzs-deploy"

set -e

echo "=== 1. 构建前端 ==="
cd source/vue/xzs-student && npm run build && cd ../../..
cd source/vue/xzs-admin && npm run build && cd ../../..

echo "=== 2. 构建后端 ==="
cd source/xzs && mvn clean package -DskipTests && cd ../..

echo "=== 3. 停止旧服务 ==="
sshpass -p "$SSH_PASS" ssh "$SERVER" "
  docker stop xzs-backend 2>/dev/null || true
  docker rm xzs-backend 2>/dev/null || true
  docker rmi xzs-backend:latest 2>/dev/null || true
"

echo "=== 4. 上传文件 ==="
sshpass -p "$SSH_PASS" scp source/xzs/target/xzs-3.9.0.jar ${SERVER}:${REMOTE_DIR}/
sshpass -p "$SSH_PASS" scp -r source/vue/xzs-student/dist/* ${SERVER}:${REMOTE_DIR}/static/student/
sshpass -p "$SSH_PASS" scp -r source/vue/xzs-admin/dist/* ${SERVER}:${REMOTE_DIR}/static/admin/
sshpass -p "$SSH_PASS" scp database/04_exam_data.sql ${SERVER}:${REMOTE_DIR}/sql/
sshpass -p "$SSH_PASS" scp database/05_rag_embeddings.sql ${SERVER}:${REMOTE_DIR}/sql/

echo "=== 5. 初始化数据库 ==="
sshpass -p "$SSH_PASS" ssh "$SERVER" "
  cd $REMOTE_DIR
  docker exec -i xzs-mysql mysql -u root -p'doushijiaxiang0.' xzs < sql/04_exam_data.sql
  docker exec -i xzs-mysql mysql -u root -p'doushijiaxiang0.' xzs < sql/05_rag_embeddings.sql
"

echo "=== 6. 构建并启动后端 ==="
sshpass -p "$SSH_PASS" ssh "$SERVER" "
  cd $REMOTE_DIR
  docker compose build backend
  docker compose up -d backend
  sleep 10
"

echo "=== 7. 验证 ==="
echo "后端日志:"
sshpass -p "$SSH_PASS" ssh "$SERVER" "docker logs xzs-backend --tail 10"
echo ""
echo "数据库计数:"
sshpass -p "$SSH_PASS" ssh "$SERVER" "
  docker exec xzs-mysql mysql -u root -p'doushijiaxiang0.' xzs -e '
    SELECT \"text_content\" AS tbl, COUNT(*) FROM t_text_content
    UNION ALL SELECT \"question\", COUNT(*) FROM t_question
    UNION ALL SELECT \"exam_paper\", COUNT(*) FROM t_exam_paper;
  '
"
echo ""
echo "=== 部署完成 ==="
echo "学生端: http://118.31.34.132/student/"
echo "管理端: http://118.31.34.132/admin/"

# 注意：需要安装 sshpass
# Windows: 使用 Git Bash 中的 sshpass，或手动执行各步骤
```

> **Windows 用户注意**：由于 `sshpass` 在 Windows 上不可用，建议手动按步骤执行，或使用 Git Bash。

---

## 七、文件清单

| 文件 | 用途 | 来源 |
|------|------|------|
| `xzs-3.9.0.jar` | 后端 Spring Boot 包 | `source/xzs/target/` |
| `static/student/` | 学生端前端 | `source/vue/xzs-student/dist/` |
| `static/admin/` | 管理端前端 | `source/vue/xzs-admin/dist/` |
| `sql/04_exam_data.sql` | 735 条目题目 + 14 套试卷数据 | `database/` |
| `sql/05_rag_embeddings.sql` | RAG 向量列（embedding） | `database/` |
| `Dockerfile` | 后端 Docker 镜像构建 | `deploy/` |
| `docker-compose.yml` | 服务编排 | `deploy/` |
| `nginx.conf` | Nginx 配置（服务器已有，无需更新） | `deploy/` |
