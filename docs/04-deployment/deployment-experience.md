# 部署经验记录

## 部署目标

将 408Master 部署到云服务器，对外提供：

- 学生端 Web：`/student/`
- 管理端 Web：`/admin/`
- 后端接口：`/api/`
- MySQL 数据库
- RAG/Agent 所需 SQL 数据结构

## 推荐部署分支

当前推荐使用：

```text
codex/ai-knowledge-rag
```

该分支包含 AI/RAG、知识库、数据库整理、文档整理和小程序跑通相关改动。部署前应确认远端分支存在并拉取最新代码。

## 推荐部署方式

采用本地或朋友电脑构建、服务器运行 Docker 的方式：

1. 本地构建学生端和管理端。
2. 本地构建后端 jar。
3. 上传 jar、前端 dist、deploy 配置和 SQL。
4. 服务器使用 Docker Compose 启动 MySQL、后端和 Nginx。
5. 手动按顺序导入 `database/current/` 下的 SQL。
6. 导入知识点爬虫数据。
7. 用 curl 和浏览器做最终验证。

## 关键经验

### 1. 不要依赖 Docker 自动导入多个 SQL

当前 SQL 有明确顺序：

1. `01_init_structure.sql`
2. `02_extend_fields.sql`
3. `04_exam_data.sql`
4. `05_rag_embeddings.sql`
5. `06_ai_knowledge_rag.sql`

自动导入无法表达项目语义，手动导入更稳。

### 2. 生产初始化只导入 current

`database/archive/` 是历史和实验脚本，不应导入生产环境。特别是 `legacy-knowledge/` 中包含旧表体系，容易和当前 `knowledge_point`、`question_knowledge_point`、`t_ai_knowledge_base` 主线混淆。

### 3. 管理端线上不要请求 localhost

管理端构建时如果保留 `http://localhost:8000`，线上浏览器会请求访问者自己的电脑。部署构建时应设置同源请求或正确 API 地址。

### 4. 先验证数据库，再启动业务

后端很多错误来自数据库缺表、缺字段或缺数据。导入后应先验证：

- `t_question`
- `t_exam_paper`
- `t_text_content`
- `t_subject`
- `t_ai_knowledge_base`
- `knowledge_point`

### 5. SSH 受限时交给能连接的人执行

当前项目遇到过“本机网络无法 SSH，朋友可以”的场景。此时要把部署步骤写成可复制执行的手册，而不是口头描述。

## 相关文档

- `朋友远程部署操作手册.md`
- `../../deploy/README.md`
- `../../deploy/REDEPLOY_GUIDE.md`

## 汇报表达

可以这样写：

> 项目部署采用 Docker Compose 管理 MySQL、后端和 Nginx，前端静态资源由 Nginx 提供，后端接口通过 `/api/` 反向代理。部署过程中遇到过 SSH 网络限制、数据库初始化顺序、线上 localhost 配置等问题，因此整理了远程部署手册和验证清单，保证项目可以由其他成员复现部署。
