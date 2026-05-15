# 学之思 (xzs) Docker 部署文档

## 部署日期

2026-05-15

## 服务器信息

- **公网 IP**: `118.31.34.132`
- **系统**: Ubuntu (x86_64)
- **Docker**: 已安装，配置阿里云镜像加速

## 项目架构

```
浏览器 (公网)
    │
    ▼
┌─────────────────────────────────────────────┐
│  Nginx (:80) — 宿主机 systemd 服务           │
│                                              │
│  /student/*   → 静态文件 (Vue 学生端)         │
│  /admin/*     → 静态文件 (Vue 管理端)         │
│  /api/*       → proxy_pass → :8000 (后端)    │
└─────────────────────────────────────────────┘
         │
         ▼
┌──────────────────────┐    ┌──────────────────┐
│  xzs-backend (Docker)│    │  xzs-mysql (Docker)│
│  :8000 (Spring Boot) │───▶│  :3306 (内网)     │
│  Memory: 512m        │    │  Memory: 512m     │
└──────────────────────┘    └──────────────────┘
```

## 目录结构

```
deploy/
├── README.md            # 本文件
├── Dockerfile           # 后端 Spring Boot 镜像
├── docker-compose.yml   # 服务编排（MySQL + Backend + Nginx）
├── nginx.conf           # Nginx 反代 + 静态文件托管配置
├── sql/                 # 数据库初始化脚本
│   └── xzs-mysql.sql
├── static/              # 前端静态文件（构建后拷贝至此）
│   ├── student/         # Vue 学生端 dist
│   └── admin/           # Vue 管理端 dist
└── logs/                # 后端日志
```

## 部署文件说明

### 1. Dockerfile

- 基础镜像: `registry.cn-hangzhou.aliyuncs.com/mindskip/java:1.8.0`（阿里云仓库，无需翻墙）
- 拷贝 `xzs-3.9.0.jar` 到容器 `/app/`
- 使用 `spring.profiles.active=prod` 启动

### 2. docker-compose.yml

三容器编排：

| 服务 | 镜像来源 | 端口 | 内存限制 |
|------|----------|------|----------|
| mysql | `registry.cn-hangzhou.aliyuncs.com/mindskip/mysql:8.0.33` | 3306 (仅内网) | 512m |
| backend | 本地 Dockerfile 构建 | 8000 | 512m |
| nginx | `nginx:1.25-alpine` | 80:80 | 128m |

- 所有容器重启策略：`always`
- 日志限制：`max-size=10m, max-file=3`
- 数据库密码：通过环境变量注入
- MySQL 数据持久化到 `./mysql-data/`
- SQL 初始化脚本挂载到 `/docker-entrypoint-initdb.d/`

### 3. nginx.conf

- **`/student`** → 学生端 Vue SPA（try_files fallback 到 index.html）
- **`/admin`** → 管理端 Vue SPA（try_files fallback 到 index.html）
- **`/api/`** → 反向代理到 `http://backend:8000`
- **`/`** → 302 重定向到 `/student/`

## 构建与部署步骤

### 前置条件

- 本地安装 Node.js、npm、Maven、Java
- 服务器已安装 Docker、Nginx

### 步骤 1: 构建前端

```bash
# 学生端
cd source/vue/xzs-student
npm install --registry=https://registry.npmmirror.com
npm run build
# 产出: source/vue/xzs-student/student/

# 管理端（需先在 .env.prod 添加 VUE_APP_URL=''）
cd source/vue/xzs-admin
npm install --registry=https://registry.npmmirror.com
npm run build
# 产出: source/vue/xzs-admin/admin/
```

### 步骤 2: 构建后端

```bash
cd source/xzs
mvn clean package -DskipTests
# 产出: source/xzs/target/xzs-3.9.0.jar
```

### 步骤 3: 上传到服务器

将 `deploy/` 目录下的所有文件上传到服务器 `/opt/xzs-deploy/`：
- `Dockerfile`
- `docker-compose.yml`
- `nginx.conf`
- `xzs-3.9.0.jar`（JAR 包）
- `sql/xzs-mysql.sql`（数据库初始化脚本）
- `static/student/`（学生端前端 dist）
- `static/admin/`（管理端前端 dist）

### 步骤 4: 启动服务

```bash
# 若使用宿主机 Nginx（推荐，避免嵌套容器网络问题）：
# 1) 先用 docker compose 启动 backend + mysql
cd /opt/xzs-deploy
docker compose up -d mysql backend

# 2) 将 nginx.conf 内容写入 Nginx 配置重启
cp nginx.conf /etc/nginx/sites-enabled/default
systemctl restart nginx
```

或者全部用 docker compose 一把梭：

```bash
cd /opt/xzs-deploy
docker compose up -d --build
```

> **当前部署方式**: MySQL 和 Backend 跑在 Docker 中，Nginx 直接运行在宿主机上（systemd），80 端口绑定宿主机。

## 镜像源

所有 Docker 镜像均使用国内源，无需翻墙：

| 镜像 | 源 |
|------|-----|
| Java 基础镜像 | `registry.cn-hangzhou.aliyuncs.com/mindskip/java:1.8.0` |
| MySQL | `registry.cn-hangzhou.aliyuncs.com/mindskip/mysql:8.0.33` |
| Nginx | 宿主机 apt 安装（或 `nginx:1.25-alpine`） |

Docker 镜像加速配置（`/etc/docker/daemon.json`）：
```json
{
  "registry-mirrors": [
    "https://docker.m.daocloud.io",
    "https://docker.mirrors.ustc.edu.cn",
    "https://hub-mirror.c.163.com"
  ]
}
```

## SQL 导入

```bash
docker exec -i xzs-mysql mysql -u root -p'doushijiaxiang0.' xzs < xzs-mysql.sql
```

## 验证

```bash
# 学生端
curl http://localhost/student/

# 管理端
curl http://localhost/admin/

# API（预期返回 {"code":401}，表示鉴权正常）
curl http://localhost/api/student/user/current
```

## 公网访问

| 入口 | 地址 |
|------|------|
| 学生端 | <http://118.31.34.132/student/> |
| 管理端 | <http://118.31.34.132/admin/> |

## 管理命令

```bash
# 查看容器状态
docker ps

# 查看后端日志
docker logs -f xzs-backend

# 查看 MySQL 日志
docker logs -f xzs-mysql

# 重启后端
docker restart xzs-backend

# 查看 Nginx 日志
tail -f /var/log/nginx/access.log

# 进入 MySQL
docker exec -it xzs-mysql mysql -u root -p'doushijiaxiang0.' xzs

# 停止所有服务
docker compose down
```
