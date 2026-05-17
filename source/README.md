# source

主源码目录，包含后端、两个 Web 前端和微信小程序端。

## 目录结构

| 目录 | 说明 |
|---|---|
| `xzs/` | Spring Boot 后端，提供 Web、管理端、小程序和 AI/RAG API。 |
| `vue/xzs-student/` | Vue3 + Vite 学生端 Web。 |
| `vue/xzs-admin/` | Vue3 + Vite 管理端 Web。 |
| `wx/xzs-student/` | 原生微信小程序学生端。 |

## 后端

```bash
cd source/xzs
mvn package -DskipTests
java -jar target/xzs-3.9.0.jar
```

默认端口：

```text
http://127.0.0.1:8000
```

关键配置：

| 文件 | 说明 |
|---|---|
| `src/main/resources/application.yml` | 公共配置，包含端口、微信配置、AI API 配置。 |
| `src/main/resources/application-dev.yml` | 本地数据库配置。 |
| `src/main/resources/application-prod.yml` | 生产环境数据库配置。 |
| `ai/prompts/analysis/*.json` | AI 解析 Prompt 模板。 |

## 学生端 Web

```bash
cd source/vue/xzs-student
npm install --registry=https://registry.npmmirror.com
npm run dev -- --host 127.0.0.1 --port 8001
```

访问：

```text
http://127.0.0.1:8001/student/
```

构建：

```bash
npm run build
```

## 管理端 Web

```bash
cd source/vue/xzs-admin
npm install --registry=https://registry.npmmirror.com
npm run dev
```

线上构建前，如果通过同域 Nginx 转发 `/api/`，建议设置：

```bash
printf 'VITE_APP_URL=\n' > .env.production
npm run build
```

## 微信小程序

用微信开发者工具导入：

```text
source/wx/xzs-student
```

本地开发时：

1. 确保后端已启动在 `http://127.0.0.1:8000`。
2. 微信开发者工具勾选“不校验合法域名、TLS 版本及 HTTPS 证书”。
3. 使用 `student / 123456` 登录绑定。

线上发布时需要修改：

| 文件/配置 | 要做什么 |
|---|---|
| `wx/xzs-student/app.js` | 把 `globalData.baseAPI` 改成 `https://你的域名`。 |
| `wx/xzs-student/project.config.json` | 替换为自己的小程序 `appid`。 |
| 后端 `system.wx.appid` / `system.wx.secret` | 配置真实微信小程序 AppID 和 AppSecret。 |
| 微信公众平台后台 | 配置 `request 合法域名`。 |

## 常用验证

```bash
curl -s http://127.0.0.1:8000/api/student/ai/styles

curl -s -X POST http://127.0.0.1:8000/api/wx/student/auth/bind \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  --data 'userName=student&password=123456&code=test-code'
```
