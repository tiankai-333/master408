# 问题排查与解决记录

这份文档用于汇总项目开发中遇到过的典型问题。详细过程保留在各专题文档中，这里做“可汇报、可复盘”的索引。

## 1. MySQL 中文乱码

- 现象：题干、解析、学科名称等中文显示异常。
- 根因：SQL 导入、数据库字符集、连接参数和终端管道编码不一致。
- 处理：
  - 数据库使用 `utf8mb4`。
  - 导入 SQL 时避免 Windows PowerShell 的 `Get-Content | mysql` 管道。
  - 提供 `import_db.py` 统一以 UTF-8 读取 SQL。
- 资料：
  - `MySQL中文乱码问题排查与解决.md`
  - `数据库字符编码修复指导.md`

## 2. 数据库结构和旧 SQL 混杂

- 现象：数据库文件过多，早期实验脚本和当前主线 SQL 混在一起，容易误导入旧表。
- 根因：项目经过多轮 AI/RAG、知识库和题库改造，历史方案没有归档。
- 处理：
  - 当前部署 SQL 收敛到 `database/current/`。
  - 历史知识库实验脚本归档到 `database/archive/legacy-knowledge/`。
  - 测试数据放入 `database/tests/`。
- 资料：
  - `../../database/README.md`

## 3. 试卷中心显示异常

- 现象：试卷中心只显示部分试卷、侧边栏点击需要两次、学科数量不对。
- 根因：前端筛选、分页参数和后端返回数据之间存在不一致。
- 处理：
  - 调整试卷中心学科、侧边栏和列表展示逻辑。
  - 展示更多 408 综合试卷，避免只显示 10 条或学科缺失。
- 资料：
  - `../02-work-records/2026-05-ai-rag-development-log.md`

## 4. 答题和批改交互问题

- 现象：试卷界面选项重合，批改界面无法取消。
- 根因：选项布局和批改状态切换逻辑没有覆盖真实试卷数据场景。
- 处理：
  - 修复选项重叠。
  - 修复批改取消交互。
- 资料：
  - `../02-work-records/2026-05-ai-rag-development-log.md`

## 5. AI/RAG 检索可用性

- 现象：AI 如果没有高质量知识库和 embedding，容易空检索或产生幻觉。
- 根因：知识点数据、向量字段、检索 fallback 和 Prompt 注入需要协同设计。
- 处理：
  - 使用 `t_ai_knowledge_base` 作为 RAG 文档库。
  - 保留 `t_text_content.embedding` 兼容路径。
  - 增加关键词 fallback。
  - 爬取 408 知识点并导入知识库。
- 资料：
  - `../01-requirements-plan/AI智能学习辅助功能-整体规划.md`
  - `AI_AGENT_TEST_GUIDE.md`

## 6. AI 工作台卡死（429 限流）

- **现象**：AI 学习工作台发消息后一直显示"正在检索…"，永远不出结果。
- **根因**：每次对话都调智谱 embedding API 做向量检索，触发 429 限流；同一 API Key 的 chat 流式调用也被连带限流，SSE 连接挂住。
- **处理**：
  - RagService 增加候选向量和已解析 `float[]` 的 5 分钟 TTL 缓存，避免每次全表扫描和重复 JSON 反序列化。
  - Orchestrator 在闲聊（`free_chat`）且无知识点/题目上下文时直接跳过 RAG 检索。
- **资料**：
  - `2026-05-29-ai-workbench-stall-fix.md`

## 7. Admin 后台登录失败（跨域 Cookie 丢失）

- **现象**：用 `http://127.0.0.1:8002` 访问管理后台，登录成功但页面仍显示"用户未登录"；改用 `http://localhost:8002` 则正常。
- **根因**：`.env` 中 `VITE_APP_URL=http://localhost:8000` 让 axios 直连后端，绕过 Vite 代理。`127.0.0.1` 和 `localhost` 被浏览器视为不同域，session cookie 域名为 `localhost`，在 `127.0.0.1` 页面发请求时 cookie 不会携带。
- **处理**：清空 `VITE_APP_URL`，让请求走 Vite dev server 代理，避免跨域。
- **资料**：
  - `2026-05-29-ai-workbench-stall-fix.md`（附 2）

## 6. 微信小程序本地跑通

- 现象：小程序正式微信登录依赖 AppID/AppSecret，本地开发阶段难以完整跑通。
- 根因：微信接口、合法域名和后端绑定流程都依赖正式环境。
- 处理：
  - 本地开发阶段使用 127.0.0.1 后端地址。
  - 后端在未配置正式 AppSecret 时支持开发模式绑定。
  - 试卷列表取消不合适的年级过滤，保证 408 试卷可见。
- 资料：
  - `../02-work-records/2026-05-ai-rag-development-log.md`

## 7. 云端 SSH 受限

- 现象：当前网络无法 SSH 到云服务器，但朋友网络可以连接。
- 根因：可能是安全组白名单、异地网络限制或运营商网络策略。
- 处理：
  - 编写远程部署交接文档。
  - 将构建、上传、导入数据库、验证命令整理成可执行步骤。
- 资料：
  - `../04-deployment/朋友远程部署操作手册.md`
  - `../04-deployment/deployment-experience.md`

## 8. 图片识别 400/1210 排查与修复

- **现象**：重构图片识别链路后，调用智谱 GLM-4V API 报 `400 BAD_REQUEST code=1210`（参数格式错误）。
- **根因**：三个叠加问题：
  1. GLM-4V 系列不支持 `system` role，只接受 `user`/`assistant`
  2. 模型名从旧的 `glm-4.6v` 改成了 `glm-4v-flash`，但实际可用的是 `glm-4.6v-flash`
  3. 智谱 API 的 Base64 图片要传裸 base64，不带 `data:image/png;base64,` 前缀
- **处理**：
  - 去掉 system message，prompt 拼入 user content
  - 默认视觉模型改为 `glm-4.6v-flash`
  - 按 provider 类型剥离 base64 前缀
  - 增加脱敏日志、图片格式校验、URL 防重复追加、用量日志区分 vision/runtime
- **资料**：
  - `2026-05-30-vision-api-1210-fix.md`

## 9. 部署脚本改进：从全量发布到可诊断、可分层部署

### 问题背景

项目使用 `deploy/cloud-update.sh` 进行云端 Docker 部署。脚本已经能完成构建、上传、远端部署、数据库备份和 SQL 快照导入，但随着项目复杂度上升，暴露出多个实际工程问题：前端页面、后端接口、数据库数据经常一起变化，小功能改动也会触发完整部署流程（构建 JAR + 构建前端 dist + 上传静态资源 + 备份数据库 + 导入 SQL + 重启 Docker + 健康检查），导致部署成本高、排错困难。

### 具体问题

**密码硬编码**：数据库密码 `doushijiaxiang0.` 和服务器 IP `118.31.34.132` 直接写在脚本里，存在提交到 Git 的风险。

**构建跳过导致旧包部署**：脚本发现 JAR 或 dist 已存在时跳过构建。用 `-y` 自动确认时，`confirm` 函数返回 true，相当于每次都回答"是，重新构建"，但构建环境（WSL 下 JAVA_HOME 未配置）可能失败，脚本继续使用旧产物，部署的仍然是旧代码。

**首次部署失败**：远端服务器第一次部署时没有 `xzs-mysql` 容器，脚本的备份步骤 `docker exec xzs-mysql mysqldump ...` 直接报错退出。

**WSL / Windows SSH key 不一致**：PowerShell 中 `ssh root@118.31.34.132` 免密成功，但 PowerShell 里 `bash` 调用的是 WSL，WSL 的 `$HOME/.ssh/` 路径与 Windows 不同，找不到 `id_ed25519`，导致脚本的 `ssh -o BatchMode=yes` 连接失败。排查这个问题的过程很费时间，因为错误信息只显示"Permission denied"，没有指出 key 路径差异。

**Maven 构建失败误判**：WSL 环境下 `JAVA_HOME` 未配置，`mvn` 执行失败，但旧 JAR 仍然存在，脚本继续执行并输出"JAR: 39M OK"，实际上传了旧包。

**缺少诊断手段**：部署失败时不知道是本地环境问题、SSH 问题、远端 Docker 问题还是数据库问题，只能手动逐个排查。

### 改进措施

**密钥外置到 `.env`**：新建 `deploy/.env.example`（模板，提交 Git）和 `deploy/.env`（真实密码，gitignore 排除）。脚本加载顺序调整为"默认值 < .env < 命令行参数"，密码不再出现在代码中。

**`full` 默认强制构建**：`full` 命令设置 `FORCE_BUILD=true`，构建前先删除旧 JAR，Maven/npm 失败时直接 `fail` 退出，不再使用旧产物伪装成功。新增 `--skip-build` 选项允许跳过构建（用于只改了 SQL 或配置的场景）。

**新增 `doctor` 命令**：检查本地环境（WSL/Git Bash/Linux）、命令是否存在（ssh/scp/rsync/java/mvn/npm）、SSH key 路径和文件存在性、SSH 连接测试（打印实际命令）、远端 Docker 版本和磁盘空间。`full` 流程前自动调用 `doctor`。

**首次部署检测**：部署前检查远端是否存在 `xzs-mysql` 容器，不存在则标记为首次部署，跳过数据库备份，先 `docker compose up -d mysql`，然后用 `wait_mysql_ready()` 轮询 `mysqladmin ping` 最多 90 秒，再导入 SQL。

**`setup-key` 环境提示**：显示当前运行环境（WSL/Git Bash）、HOME 路径、选择的 SSH key 路径，明确提示 PowerShell 和 WSL 使用不同 `~/.ssh` 目录。

**备份清理**：备份成功后保留最近 3 个，删除更早的，避免磁盘被历史备份占满。

**SQL 归档整合**：将 21 个增量补丁 SQL 文件归档到 `database/archive/`，用 `mysqldump` 导出一个干净的 `00_full_snapshot.sql`（6.6MB），新部署只需一步导入。

### 经验总结

1. **部署失败不一定是 Docker 的问题**：实际遇到的问题中，本地环境（JAVA_HOME）、SSH key 路径（WSL vs Windows）、远端容器状态（MySQL 是否存在）都可能导致部署失败，需要有诊断命令快速定位。

2. **Windows + WSL 环境下要明确脚本运行在哪个 shell 中**：PowerShell 里 `bash` 调用的是 WSL，不是 Git Bash。WSL 的 `$HOME` 是 `/home/<user>/`，不是 `/c/Users/<user>/`。SSH key、Java、Maven 的路径都不同。

3. **小改动不应该总是触发全量部署**：只改前端时不应该重新构建 JAR，只改后端时不应该重新上传 295MB 的前端 dist。后续应支持 `frontend`、`backend`、`db` 等分层部署命令。

4. **演示环境可以使用 SQL 快照覆盖，但必须在文档中说明边界**：当前 `deploy/README.md` 已明确标注为"开发/演示环境 SQL 快照覆盖策略"，不适合有真实用户数据的生产环境。如果进入生产，应改为增量迁移（Flyway/Liquibase）。

5. **部署脚本也需要工程化维护**：配置外置（.env）、诊断能力（doctor）、构建失败中止（fail 而非继续）、首次部署处理（检测容器是否存在）和备份清理（保留最近 N 个）都是必要的。

### 后续计划

- 将题目 HTML 和图片等大体积静态资源从前端 dist 中拆出，独立上传
- 增加 `database/migrations`（结构迁移）和 `database/data-patches`（数据补丁），支持增量升级
- 后端和前端打成 Docker 镜像，使用镜像 tag 管理版本
- 增加域名和 HTTPS（Let's Encrypt）
- 增加定时数据库备份和日志轮转
- 暂不引入 Kubernetes 和 CI/CD

- 资料：
  - `../../deploy/cloud-update.sh`
  - `../../deploy/README.md`
  - `../../deploy/.env.example`
  - `../02-work-records/2026-05-29-cloud-deploy-and-sql-consolidation.md`

---

## 汇报表达

可以把这些问题统一总结为：

> 项目不是只完成业务功能，还经历了数据编码、SQL 结构治理、前端交互修复、AI 检索可靠性、小程序联调和云端部署受限等真实工程问题。每类问题都形成了定位、修复和验证记录，提高了项目的可维护性和可交接性。
