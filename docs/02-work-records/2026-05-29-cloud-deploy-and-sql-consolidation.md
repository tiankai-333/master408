# 云端 Docker 部署 + SQL 归档整合

日期：2026-05-29

## 背景

本地 Docker 4 服务部署（mysql + backend + qdrant + nginx）已稳定运行，但云端服务器 `118.31.34.132` 仍运行旧版（缺少 qdrant、Docker nginx，数据库缺少 12 个迁移）。需要将云端更新到与本地一致的最新版本。

同时 `database/current/` 下积累了 21 个增量补丁式 SQL 文件（01-23 编号，部分有错误已修复），需要归档整合。

---

## 完成的工作

### 1. 本地构建产物

- 后端 JAR：`mvn clean package -DskipTests` → `xzs-3.9.0.jar`（39MB）
- 学生端前端：`npm run build` → `dist/`（约 295MB，含 CSGraduates HTML 题库）
- 管理端前端：`npm run build`（`VITE_APP_URL=` 空，同源请求）

### 2. SQL 归档整合

**问题**：`database/current/` 有 21 个编号 SQL 文件，包含建表、数据导入、补丁修复等，关系复杂，部分早期文件有 bug 已被后续补丁覆盖。

**方案**：从本地 Docker MySQL 直接 `mysqldump` 导出全量快照，替换所有增量文件。

- 旧文件（01-23）移至 `database/archive/`
- 新文件：`database/current/00_full_snapshot.sql`（6.6MB，包含全部表结构和数据）
- 新部署只需一步：`mysql -u root -p xzs < 00_full_snapshot.sql`

**数据概览**：

| 表 | 行数 |
|---|---|
| t_question | 650 |
| t_text_content | 669 |
| t_exam_paper | 18 |
| knowledge_point | 116 |
| question_content | 640 |
| rag_document / rag_chunk | 119 / 81 |
| t_user | 4（含 test/123456） |

### 3. 部署脚本 v2.0

重写 `deploy/cloud-update.sh` 为可复用的完整部署工具。

**命令列表**：

| 命令 | 功能 |
|---|---|
| `full` | 构建 + 上传 + 远端部署（默认） |
| `build` | 仅本地构建 |
| `upload` | 仅上传产物 |
| `deploy` | 仅远端部署 |
| `status` | 查看云端服务状态 |
| `logs` | 查看后端日志（实时追踪） |
| `reset-db` | 用本地快照重置云端数据库 |
| `migrate` | 仅执行 SQL 迁移 |
| `rollback` | 回滚到上次备份 |
| `setup-key` | 引导配置 SSH 免密 |
| `ssh` | 直接 SSH 进服务器 |

**关键改进**：
- SSH 统一加 `BatchMode=yes`，连接失败直接报错不卡住
- SQL 策略改为快照覆盖（drop + import），不再做增量补丁
- 支持 `--skip-frontend`、`--skip-migration`、`-y` 等选项

### 4. SSH 免密登录配置

**问题**：Windows PowerShell 没有 `ssh-copy-id` 命令。

**解决**：手动将公钥追加到服务器 `~/.ssh/authorized_keys`：
```bash
# 本地查看公钥
cat ~/.ssh/id_ed25519.pub

# 服务器上执行
mkdir -p ~/.ssh && chmod 700 ~/.ssh
echo "公钥内容" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

### 5. 云端服务器状态

| 项目 | 值 |
|---|---|
| IP | 118.31.34.132 |
| 磁盘 | 20G 总 / 9.4G 已用 / 9.0G 可用（45%） |
| 部署目录 | /opt/xzs-deploy |
| 当前服务 | 旧版 mysql + backend（缺少 qdrant、Docker nginx） |
| 宿主机 nginx | 运行中（需停用，改用 Docker nginx） |

---

## 经验总结

### SSH 免密登录（Windows 环境）

- Windows PowerShell 没有 `ssh-copy-id`，需手动复制公钥
- 公钥路径：`C:\Users\wutia\.ssh\id_ed25519.pub`
- 三步：1) 看公钥 2) SSH 登上去追加 3) 验证

### SQL 管理策略

- **增量补丁适合开发期**，但积累到 20+ 个文件后维护成本高、容易出错
- **快照导出适合发布期**，`mysqldump` 一个文件搞定，部署和回滚都简单
- 旧文件不要删，归档到 `database/archive/` 保留历史

### 部署脚本设计

- `BatchMode=yes` 是关键——没有免密登录时直接报错，不会卡在密码提示
- rsync 比 scp 更适合大文件上传（增量传输、断点续传）
- 健康检查要有超时机制（15 次 × 5 秒 = 75 秒），不能无限等

### 云端资源

- 20G 小服务器，9G 可用，上传前端 dist（295MB）+ SQL 快照（6.6MB）无压力
- 4 个 Docker 容器总 mem_limit 1.6GB，需监控内存

---

## 待完成

- [ ] 执行 `bash deploy/cloud-update.sh full -y` 完成云端部署
- [ ] 浏览器验证学生端和管理端
- [ ] 云端安全组关闭 Qdrant 端口（6333/6334）
