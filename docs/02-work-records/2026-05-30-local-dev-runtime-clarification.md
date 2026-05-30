# 2026-05-30 本地开发运行链路澄清记录

## 背景

本次排查开始于本地访问 `8000` 时看到非常旧的页面，几乎像未二开的开源原版。进一步确认后发现，`8000` 实际是 Docker backend 容器暴露的端口，运行的是镜像里的 JAR，不是当前 Maven 源码。

由于前端、Maven、Docker、MySQL 端口混在一起，之前容易把“旧 Docker 后端”“Maven 后端连错库”“前端代理目标错误”混为同一个问题。

## 已确认事实

- `8000`：Docker 后端，容器名 `xzs-backend`，运行 `/app/xzs-3.9.0.jar`。
- `8003`：本地 Maven Spring Boot 后端，使用 `dev` profile。
- `8001`：学生端 Vite dev server。
- `8002`：管理端 Vite dev server。
- `3306`：本机已有 `mysqld` 占用，不适合作为本项目 Docker MySQL 的宿主机端口。
- `3307`：本项目本地开发约定的 Docker MySQL 宿主机端口，映射到容器内 `3306`。
- `6333`：Qdrant HTTP API。

## 本次调整

### 停用旧 Docker 后端干扰

本地开发时建议停止 Docker backend/nginx：

```powershell
docker compose -f deploy\docker-compose.yml stop backend nginx
```

这样可以避免继续访问 `8000` 并误以为是当前源码。

### 调整本地 MySQL 映射

`deploy/docker-compose.local.yml` 将 MySQL 宿主机端口改为 `3307`：

```yaml
services:
  mysql:
    ports:
      - "3307:3306"
```

原因是本机 `3306` 已被已有 MySQL 占用。

### 调整 dev 数据库连接

`source/xzs/src/main/resources/application-dev.yml` 改为连接：

```text
jdbc:mysql://localhost:3307/xzs
```

密码使用 Docker MySQL 的 root 密码：

```text
doushijiaxiang0.
```

### Maven 后端验证

Maven 后端成功启动在 `8003`：

```text
The following profiles are active: dev
Undertow started on port(s) 8003
```

接口验证：

```text
GET http://127.0.0.1:8003/api/student/ai-config/index
返回 401 用户未登录
```

该结果说明接口进入了当前 Maven 后端，且不是 502 或旧 Docker 后端。

## 文档同步

已补充：

- `deploy/README.md`：明确本地推荐链路、端口约定、`8000` 的旧 Docker/JAR 风险。
- `docs/03-engineering-experience/2026-05-30-local-dev-maven-docker-ports.md`：沉淀为工程经验。
- 本文件：作为工作日志记录本次排查和调整。

## 后续注意

本地开发优先使用：

```text
Vite 前端 8001/8002 -> Maven Spring 8003 -> Docker MySQL 3307 + Qdrant 6333
```

如果再次出现 500：

1. 先看 Maven 日志。
2. 再确认数据库连接的是 `3307`。
3. 再查表和字段是否缺失。
4. 不要优先重跑云端部署脚本。
