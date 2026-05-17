# source/vue

Web 前端目录，包含学生端和管理端两个 Vue3 + Vite 应用。

## 子项目

| 目录 | 说明 |
|---|---|
| `xzs-student/` | 学生端：登录、首页、试卷中心、答题、记录、知识图谱、AI 解析。 |
| `xzs-admin/` | 管理端：题目、试卷、用户、知识库和 AI Agent 调试。 |

## 学生端运行

```bash
cd source/vue/xzs-student
npm install --registry=https://registry.npmmirror.com
npm run dev -- --host 127.0.0.1 --port 8001
```

访问：

```text
http://127.0.0.1:8001/student/
```

## 管理端运行

```bash
cd source/vue/xzs-admin
npm install --registry=https://registry.npmmirror.com
npm run dev
```

## 构建

```bash
cd source/vue/xzs-student
npm run build

cd ../xzs-admin
printf 'VITE_APP_URL=\n' > .env.production
npm run build
```

## 线上接口注意

学生端请求使用相对 `/api/`，通常由 Vite/Nginx 代理到后端。

管理端 `src/utils/request.js` 使用 `VITE_APP_URL` 作为 `baseURL`。线上如果通过同域 Nginx 代理 `/api/`，应让 `VITE_APP_URL` 为空，避免浏览器请求自己的 `localhost`。
