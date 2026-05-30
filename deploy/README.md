# deploy/ - 408Master 部署与运行方式

## 先说结论

`deploy/cloud-update.ps1` 是 **云端 Docker 部署脚本**。

它会构建/上传产物、操作远程服务器 `/opt/xzs-deploy`、重启 Docker 服务，必要时还会导入 SQL。它不是本地日常开发启动脚本。开发 Java 接口时，优先用本地 Spring Boot 启动后端，否则很容易出现“源码已经改了，但 Docker 容器还在跑旧 JAR”的问题。

本项目现在有三种运行方式：

| 场景 | 用法 | 适合做什么 |
|------|------|------------|
| 云端 Docker | `deploy/cloud-update.ps1 full/deploy/...` | 发布到服务器、SSL、远程 MySQL/Qdrant/Nginx |
| 本地 Docker | `docker compose -f deploy/docker-compose.yml up -d` | 本地模拟生产容器环境 |
| 本地 Spring Boot | `mvn spring-boot:run` | 日常后端开发、调接口、看日志 |

## 1. 云端 Docker 部署

PowerShell 脚本：

```powershell
.\deploy\cloud-update.ps1 doctor
.\deploy\cloud-update.ps1 full
.\deploy\cloud-update.ps1 deploy
.\deploy\cloud-update.ps1 status
```

这个脚本面向云服务器：

```text
root@118.31.34.132
/opt/xzs-deploy
```

它会使用 Docker Compose 管理云端服务：

- `mysql`
- `backend`
- `qdrant`
- `nginx`

注意：

- 默认部署不应该上传 `qdrant-data`。
- Qdrant 数据迁移只在显式执行时运行：

```powershell
.\deploy\cloud-update.ps1 upload-qdrant
```

- SSL 相关命令：

```powershell
.\deploy\cloud-update.ps1 setup-ssl
.\deploy\cloud-update.ps1 renew-ssl
```

## 2. 本地 Docker 运行

本地 Docker 是用来模拟云端环境的，不是最高效的开发方式。

启动：

```powershell
docker compose -f deploy\docker-compose.yml up -d
```

查看：

```powershell
docker compose -f deploy\docker-compose.yml ps
docker compose -f deploy\docker-compose.yml logs --tail=120 backend
```

如果改了 Java 代码，本地 Docker 不会自动使用新源码。必须重新构建 JAR、复制到 `deploy/xzs-3.9.0.jar`，再重建 backend 镜像：

```powershell
cd source\xzs
mvn -DskipTests package
Copy-Item .\target\xzs-3.9.0.jar ..\..\deploy\xzs-3.9.0.jar -Force
cd ..\..
docker compose -f deploy\docker-compose.yml build backend
docker compose -f deploy\docker-compose.yml up -d backend
```

如果只是开发接口，这条链路太重，优先用下一节。

## 3. 本地 Spring Boot 开发

这是日常后端开发推荐方式。

先保证本地 MySQL/Qdrant 可用。可以只用 Docker 跑基础服务，然后后端用 Maven 跑。当前推荐链路是：

```text
学生端 Vite 8001  ┐
管理端 Vite 8002  ├── /api -> Maven Spring Boot 8003
                  │
Maven Spring 8003 ├── Docker MySQL localhost:3307 -> 容器 3306
                  └── Docker Qdrant localhost:6333
```

注意：`8000` 是 Docker 后端/JAR 部署口，可能跑旧包；日常开发不要用 `8000` 判断当前源码是否生效。

`application-dev.yml` 当前连接 `localhost:3307`，所以本地开发要叠加 `docker-compose.local.yml` 暴露 MySQL 到宿主机 `3307`：

```powershell
docker compose -f deploy\docker-compose.yml -f deploy\docker-compose.local.yml up -d mysql qdrant
```

启动后端：

```powershell
cd source\xzs
mvn spring-boot:run -Dspring-boot.run.profiles=dev
```

本地 Maven 后端使用 `8003`，避免和 Docker 后端的 `8000`、学生端 Vite 的 `8001`、管理端 Vite 的 `8002` 撞端口。

学生端前端：

```powershell
cd source\vue\xzs-student
npm run dev
```

管理端前端：

```powershell
cd source\vue\xzs-admin
npm run dev
```

这种方式的优点：

- Java 源码改完后，重启 Maven 后端即可生效。
- 日志直接显示在当前终端。
- 不需要反复 `package -> copy jar -> docker build -> docker up`。

如果出现接口 500，优先看 Maven 日志和数据库连接目标。常见问题是 Spring 连到了本机自己的 `3306`，而不是 Docker 里的项目库。当前项目约定本地开发使用 `3307` 访问 Docker MySQL。

## 4. 常见误区

### 改了源码但接口还是 500

先确认当前跑的是哪种后端：

- Maven 启动：看 `source/xzs` 终端日志。
- Docker 启动：看 `docker compose logs backend`。

如果 Docker 里的 JAR 是旧的，源码中新写的 Controller/Mapper 不会生效。

检查 JAR 是否包含某个类：

```powershell
jar tf deploy\xzs-3.9.0.jar | Select-String "StudentAiConfigController"
```

### 不要把 cloud-update 当成本地开发命令

`cloud-update.ps1 full/deploy/reset-db` 会影响云端环境和数据库。除非目标是部署服务器，否则不要为了本地调试随手执行。

## 5. 云端文件结构

```text
/opt/xzs-deploy/
├── docker-compose.yml
├── Dockerfile
├── nginx.conf
├── xzs-3.9.0.jar
├── sql/
├── static/
│   ├── student/
│   └── admin/
├── mysql-data/
├── qdrant-data/
├── ssl/
└── logs/
```

## 6. 访问地址

云端：

```text
https://wx.hhhuu.com/student/
https://wx.hhhuu.com/admin/
http://118.31.34.132/student/
```

本地常见端口：

```text
http://127.0.0.1:8000    Docker 后端/JAR 部署口，开发时通常不用
http://127.0.0.1:8001    学生端 dev server
http://127.0.0.1:8002    管理端 dev server
http://127.0.0.1:8003    Maven dev 后端
http://127.0.0.1:3307    Docker MySQL 暴露到宿主机的端口
http://127.0.0.1:6333    Qdrant
```
