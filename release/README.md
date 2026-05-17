# release

发布产物目录，保留原学之思集成部署方式的结构。

当前云端部署优先使用 `deploy/`，本目录主要用于：

- 临时存放后端 jar。
- 临时存放构建后的 Web 静态文件。
- 兼容原项目“一体化 jar + 静态资源”的部署说明。

## 目录结构

| 路径 | 说明 |
|---|---|
| `java/` | 可放置 `xzs-3.9.0.jar`。 |
| `web/` | 可放置学生端和管理端静态资源。 |

## 当前推荐构建命令

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

## 集成部署参考

如果采用后端 jar 直接托管静态资源的方式，可以把构建后的前端文件放入：

```text
source/xzs/src/main/resources/static/student/
source/xzs/src/main/resources/static/admin/
```

然后重新打包后端：

```bash
cd source/xzs
mvn clean package -DskipTests
java -Duser.timezone=Asia/Shanghai -jar -Dspring.profiles.active=prod target/xzs-3.9.0.jar
```

## 前后端分离部署参考

更推荐把静态资源交给 Nginx：

```nginx
location /api/ {
  proxy_pass http://127.0.0.1:8000;
}
```

当前仓库已在 `deploy/nginx.conf` 中提供 Nginx 容器配置。

## 注意事项

1. 不要把旧 jar 当成当前 AI/RAG 分支产物。
2. 管理端线上构建时不要把接口固定成 `http://localhost:8000`。
3. 数据库必须包含 `database/current/05_rag_embeddings.sql` 和 `database/current/06_ai_knowledge_rag.sql`，否则 AI/RAG/Agent 功能不完整。
