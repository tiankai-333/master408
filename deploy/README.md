# deploy

当前推荐的云端部署目录。相比根目录 `docker/`，这里的配置更贴近 408Master 当前分支，包含后端 jar、学生端/管理端静态资源、MySQL 和 Nginx。

## 文件说明

| 文件 | 作用 |
|---|---|
| `Dockerfile` | 把 `xzs-3.9.0.jar` 打成后端镜像。 |
| `docker-compose.yml` | 编排 `mysql`、`backend`、`nginx` 三个服务。 |
| `nginx.conf` | 静态前端和 `/api/` 反向代理配置。 |
| `REDEPLOY_GUIDE.md` | 服务器重新部署操作指南。 |

## 推荐服务器目录

```text
/opt/xzs-deploy
```

推荐结构：

```text
/opt/xzs-deploy/
├── Dockerfile
├── docker-compose.yml
├── nginx.conf
├── xzs-3.9.0.jar
├── sql/
├── static/
│   ├── student/
│   └── admin/
├── mysql-data/
└── logs/
```

## 本地构建产物

后端：

```bash
cd source/xzs
mvn clean package -DskipTests
```

学生端：

```bash
cd source/vue/xzs-student
npm install --registry=https://registry.npmmirror.com
npm run build
```

管理端：

```bash
cd source/vue/xzs-admin
printf 'VITE_APP_URL=\n' > .env.production
npm install --registry=https://registry.npmmirror.com
npm run build
```

## 启动服务

服务器上执行：

```bash
cd /opt/xzs-deploy
docker compose up -d mysql
docker compose build backend
docker compose up -d backend nginx
docker ps
```

## 数据库导入

按 `database/README.md` 中的顺序导入 SQL。当前 AI/RAG 分支至少需要：

```text
database/current/01_init_structure.sql
database/current/02_extend_fields.sql
database/current/04_exam_data.sql
database/current/05_rag_embeddings.sql
database/current/06_ai_knowledge_rag.sql
```

`database/archive/` 中的 SQL 只用于追溯历史方案，不在生产初始化流程中导入。

## 访问地址

```text
http://服务器IP/student/
http://服务器IP/admin/
```

如果已经配置域名和 HTTPS：

```text
https://你的域名/student/
https://你的域名/admin/
```

## 远程协助部署

如果当前机器无法 SSH 到服务器，可把这份文档发给能连服务器的同学：

```text
docs/04-deployment/朋友远程部署操作手册.md
```
