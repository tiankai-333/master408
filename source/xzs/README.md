# source/xzs

Spring Boot 后端服务，提供学生端、管理端、微信小程序和 AI/RAG 相关接口。

## 技术栈

- Java / Spring Boot 2.1.6
- MyBatis
- MySQL
- Undertow
- PageHelper
- GLM/OpenAI 兼容大模型调用

## 启动

```bash
mvn package -DskipTests
java -jar target/xzs-3.9.0.jar
```

默认端口：

```text
8000
```

## 重要目录

| 路径 | 说明 |
|---|---|
| `src/main/java/com/mindskip/xzs/controller/student/` | 学生端 Web API。 |
| `src/main/java/com/mindskip/xzs/controller/admin/` | 管理端 API。 |
| `src/main/java/com/mindskip/xzs/controller/wx/` | 微信小程序 API。 |
| `src/main/java/com/mindskip/xzs/ai/` | AI 调用、RAG 检索、Prompt 加载。 |
| `src/main/resources/mapper/` | MyBatis XML。 |
| `src/main/resources/application*.yml` | 环境配置。 |
| `ai/prompts/analysis/` | 四种 AI 解析风格 Prompt。 |
| `src/main/resources/static/images/` | 真题图片静态资源。 |

## 本地配置

数据库配置通常在：

```text
src/main/resources/application-dev.yml
```

AI 和微信配置在：

```text
src/main/resources/application.yml
```

当前开发模式下，如果 `system.wx.secret` 为空，小程序绑定会使用开发 openId 兜底；正式上线必须配置真实 AppSecret。

## 常用接口

学生端：

```text
POST /api/user/login
POST /api/student/exam/paper/pageList
POST /api/student/exam/paper/select/{id}
GET  /api/student/knowledge-graph/graph
GET  /api/student/ai/styles
POST /api/student/ai/analyze
POST /api/student/ai/feedback
```

微信小程序：

```text
POST /api/wx/student/auth/checkBind
POST /api/wx/student/auth/bind
POST /api/wx/student/dashboard/index
POST /api/wx/student/exampaper/pageList
POST /api/wx/student/exampaper/select/{id}
```

管理端 AI：

```text
GET /api/admin/ai-agent/knowledge-base/statistics
GET /api/admin/ai-agent/rag/debug?keyword=虚拟存储器&topK=3
```

## 验证命令

```bash
curl -s http://127.0.0.1:8000/api/student/ai/styles

curl -s -X POST http://127.0.0.1:8000/api/wx/student/auth/bind \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  --data 'userName=student&password=123456&code=test-code'
```

## 打包给 Docker

```bash
mvn clean package -DskipTests
cp target/xzs-3.9.0.jar ../../deploy/
```

然后在服务器或本地部署目录执行：

```bash
docker compose build backend
docker compose up -d backend
```
