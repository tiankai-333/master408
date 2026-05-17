# docker

原学之思项目 Docker 部署参考目录。

当前 408Master AI/RAG 分支的推荐部署配置在根目录 `deploy/`，这里保留旧版 Docker 方案用于对照、回滚和理解原项目部署方式。

## 目录结构

| 路径 | 说明 |
|---|---|
| `docker-compose.yml` | 原项目 `mysql` + `java` 服务编排。 |
| `install/` | 旧版 `docker-compose` 二进制安装文件。 |
| `release/` | 原部署方式下放置 jar 的目录。 |

## 与 `deploy/` 的区别

| 项目 | `docker/` | `deploy/` |
|---|---|---|
| 定位 | 原项目参考方案 | 当前推荐方案 |
| 前端 | 后端静态资源或单独 Nginx | Nginx 容器挂载 `static/student`、`static/admin` |
| 后端 | `java` 容器直接运行 jar | `backend` 镜像由 Dockerfile 构建 |
| MySQL 密码 | 示例值 `123456` | 当前部署值 `doushijiaxiang0.` |
| AI/RAG 数据 | 未覆盖当前增量 | 配合 `database/05`、`database/06` 和知识点爬虫导入 |

## 不建议直接用于当前云端部署

如果要部署当前分支，请优先看：

```text
deploy/README.md
deploy/REDEPLOY_GUIDE.md
docs/04-deployment/朋友远程部署操作手册.md
```

## 仅作参考的启动方式

```bash
cd docker
docker compose up -d
```

如果确实使用旧方案，需要自行确认：

1. SQL 是否包含当前 408 真题和 AI/RAG 增量表。
2. 后端 jar 是否为当前分支重新构建产物。
3. 前端静态文件是否为当前分支重新构建产物。
4. Nginx 或后端静态资源路径是否能正确访问 `/student/`、`/admin/` 和 `/api/`。
