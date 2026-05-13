## 分支管理规则

### 1. 长期分支（始终保留）

| 分支 | 用途 | 保护策略 |
|------|------|---------|
| `main` | 稳定生产分支，用于部署上线 | 🔒 禁止直接提交，必须通过 PR 合并 |
| `dev` | 开发整合分支，用于日常集成 | ⚠️ 建议通过 PR 合并 |

### 2. 短期分支（完成即删）

| 分支前缀 | 用途 | 示例 |
|----------|------|------|
| `feature/*` | 新功能开发 | `feature/vue3-migration`、`feature/ai-analyze` |
| `hotfix/*` | 紧急线上 bug 修复 | `hotfix/login-error` |
| `refactor/*` | 代码重构 | `refactor/api-layer` |

### 3. 工作流程（5人团队协作）

```
1. 从 dev 分支创建 feature 分支
   git checkout dev
   git checkout -b feature/my-feature

2. 在 feature 分支开发，定期提交

3. 开发完成后，提交 PR 合并回 dev

4. 测试通过后，dev 合并到 main 发布
```

### 4. 当前活跃分支

| 分支 | 状态 | 说明 |
|------|------|------|
| `main` | ✅ 稳定 | 最新稳定版 |
| `dev` | ⚠️ 开发中 | 开发整合分支 |
| `feature/vue3-migration` | 🚀 进行中 | Vue2 到 Vue3 的完整迁移 |

---

## 更新日志

### 最近更新（2026-05-14）

**Vue3 迁移完成**
- 🚀 前端框架升级：Vue2 → Vue3，vue-router3 → 4，Vuex → Pinia
- 🔧 构建工具升级：vue-cli → Vite
- 📝 完整迁移文档：`docs/Vue2ToVue3Migration.md`
- 🗄️ 数据库增强：知识图谱、RAG 检索、AI 解析相关表设计
- 🐛 问题修复：登录密码卡顿、侧边栏空白、页面溢出等问题

**分支管理优化**
- 📦 清理旧分支，采用规范的 Git Flow 分支策略

---

### 最近更新（2026-05-06 15:27）

本次合并了 `dev` 分支的最新改动到 `main` 分支，主要更新内容：

**管理员前端（xzs-admin）更新**
- 🎨 页面样式：更新登录页、仪表板页面样式
- 🖼️ 资源文件：更新 favicon.ico、logo.png
- 📦 依赖更新：更新 package-lock.json 和 package.json
- 🎯 组件优化：调整导航栏、侧边栏 Logo、标签页组件
- 🎭 样式统一：新增 element-ui.scss，更新全局样式变量和 SCSS 文件
- 🔌 API 请求：优化 request.js 配置

**学生端前端（xzs-student）更新**
- 📦 依赖更新：更新 package-lock.json 和 package.json
- 🖼️ 资源文件：更新 logo2.png
- 🌐 页面配置：更新 index.html
- 🔌 API 调整：修改 question.js

**冲突解决**
- ✅ 解决了 `package-lock.json` 冲突
- ✅ 解决了 `src/layout/index.vue` 冲突

---

## 项目运行

### 1.0 下载
```
mkdir C:\Dev\Workspaces
cd C:\Dev\Workspaces
git clone https://github.com/tiankai-333/master408.git
```

### 1.1 数据库配置

#### 1.1.1 前提条件
- 确保已安装 MySQL 5.7+ 或 MySQL 8.0+
- 创建数据库用户并授予权限

#### 1.1.2 快速初始化（推荐）

项目提供了完整的数据库初始化脚本，一键完成建表和数据插入：

```bash
# 进入项目目录
cd C:\Dev\Workspaces\master408

# 进入 MySQL 命令行（输入密码后进入）
mysql -u root -p

# 执行初始化脚本
source C:/Dev/Workspaces/master408/sql/init_database.sql
```

#### 1.1.3 脚本说明

`sql/init_database.sql` 脚本包含：

| 操作 | 说明 |
|------|------|
| 创建数据库 | 自动创建 `xzs` 数据库 |
| 创建表结构 | 6张核心表（学科、题目、用户、试卷等） |
| 插入基础数据 | 12条学科记录、13条题目内容、12条题目记录 |
| 创建测试用户 | admin（管理员）、student（学生） |

#### 1.1.4 测试账号

| 用户名 | 密码 | 角色 |
|--------|------|------|
| admin | 123456 | 管理员 |
| student | 123456 | 学生 |

#### 1.1.5 手动配置（可选）

如果需要手动配置数据库连接，请修改后端配置文件：

```
source/xzs/src/main/resources/application-dev.yml
```

配置项：
```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/xzs?useUnicode=true&characterEncoding=UTF-8&serverTimezone=Asia/Shanghai
    username: root
    password: your_password
```

#### 1.1.6 题目数据格式规范

题目数据分为两部分存储：

1. **t_text_content**（JSON格式）：存储题目详细内容
```json
{
  "titleContent": "题目描述",
  "analyze": "答案解析",
  "questionItemObjects": [
    {"prefix": "A", "content": "选项内容", "itemUuid": "唯一ID"}
  ],
  "correct": "正确答案"
}
```

2. **t_question**（元信息）：存储题目基本信息
| 字段 | 说明 |
|------|------|
| question_type | 题型：1=单选, 2=多选, 3=判断, 4=填空, 5=简答 |
| subject_id | 学科ID |
| grade_level | 年级等级：1=期末考, 2=考研, 3=复试 |
| difficult | 难度：1-5 |

### 1.2 前端运行

1.1.1 解决版本冲突
```
cd C:\Dev\Workspaces\master408\source\vue\xzs-student
```
卸载 node-sass 并安装 sass
```
npm uninstall node-sass

npm install sass --save-dev
```
1.1.2 清理并重新安装所有依赖（只做一次，现在已经做完了）
```
