# 本地开发：Maven、Docker 与端口链路经验

日期：2026-05-30

## 背景

项目同时存在云端 Docker 部署、本地 Docker 模拟、本地 Maven 开发三种运行方式。排查过程中曾多次把 `8000` 的旧 Docker 后端误认为当前源码运行结果，导致对登录 500、AI 配置接口错误、前端页面未更新等问题产生误判。

本经验用于说明：本地开发时，前端、Maven 后端、Docker 依赖服务之间的真实关系。

## 推荐本地开发链路

```text
学生端 Vite 8001  ┐
管理端 Vite 8002  ├── /api -> Maven Spring Boot 8003
                  │
Maven Spring 8003 ├── Docker MySQL localhost:3307 -> 容器 3306
                  └── Docker Qdrant localhost:6333
```

核心原则：

- 两个前端共享同一个后端，不是“一个前端一个后端”。
- 本地开发时，Java 后端用 Maven 跑当前源码。
- Docker 只保留 MySQL、Qdrant 等依赖服务。
- `8000` 是 Docker 后端/JAR 部署口，可能跑旧包，开发时不要用它判断源码是否生效。

## 端口约定

| 端口 | 用途 | 说明 |
|---|---|---|
| `8001` | 学生端 Vite dev server | 学生端前端入口 |
| `8002` | 管理端 Vite dev server | 管理端前端入口 |
| `8003` | Maven Spring Boot dev 后端 | 本地开发主后端 |
| `8000` | Docker 后端/JAR 部署口 | 容易是旧包，开发时通常不用 |
| `3307` | 宿主机访问 Docker MySQL | 映射到容器内 `3306` |
| `6333` | Qdrant HTTP API | RAG 向量检索 |

## 为什么 8003 仍然可能 500

把 Spring 后端改到 `8003` 只解决 HTTP 端口冲突，不代表数据库一定正确。

曾出现的问题是：

```text
Spring 8003 -> localhost:3306 -> 本机自己的 MySQL
```

而项目真正需要的是：

```text
Spring 8003 -> localhost:3307 -> Docker xzs-mysql:3306
```

如果 Spring 连到本机自己的 `3306`，可能遇到旧库、空库、缺表或缺字段，于是接口仍然返回 500。排查 500 时应优先看 Maven 日志和数据库连接目标。

## Maven 与 Docker 的区别

`mvn spring-boot:run` 不是运行 `deploy/xzs-3.9.0.jar`。它使用当前源码编译后的 `target/classes` 启动：

```text
source/xzs/src/main/java -> target/classes -> Spring Boot
```

Docker/JAR 运行的是打包产物：

```text
deploy/xzs-3.9.0.jar 或镜像内 /app/xzs-3.9.0.jar
```

所以 Docker 容器重启不等于代码更新。如果没有重新 `package`、复制 JAR、重建镜像，容器里仍可能是旧代码。

## 推荐启动命令

只启动依赖服务：

```powershell
cd C:\Dev\Workspaces\master408
docker compose -f deploy\docker-compose.yml stop backend nginx
docker compose -f deploy\docker-compose.yml -f deploy\docker-compose.local.yml up -d mysql qdrant
```

启动 Maven 后端：

```powershell
cd C:\Dev\Workspaces\master408\source\xzs
mvn spring-boot:run -Dspring-boot.run.profiles=dev
```

启动前端：

```powershell
cd C:\Dev\Workspaces\master408\source\vue\xzs-student
npm run dev

cd C:\Dev\Workspaces\master408\source\vue\xzs-admin
npm run dev
```

## 排查顺序

1. 看前端 Vite proxy 是否指向 `http://localhost:8003`。
2. 看 `8003` 是否有 Java 进程监听。
3. 看 Maven 日志是否显示 `dev` profile 和 `Undertow started on port(s) 8003`。
4. 看 `application-dev.yml` 是否连接 `localhost:3307`。
5. 看 Docker MySQL/Qdrant 是否运行。
6. 如果接口 500，先查表和字段是否缺失，不要先重跑云端部署。

## 经验结论

本地开发的稳定心智模型是：

```text
前端 Vite 只负责页面和代理
Maven Spring 负责当前源码接口
Docker 只负责 MySQL/Qdrant 依赖
云端部署脚本只负责服务器发布
```

不要把 `deploy/cloud-update.ps1` 当成本地开发启动命令。该脚本会操作云端部署环境，和本地快速调试不是同一件事。
