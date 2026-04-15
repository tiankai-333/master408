1.0 下载
```
mkdir C:\Dev\Workspaces
cd C:\Dev\Workspaces
git clone https://github.com/tiankai-333/master408.git
```
1.1 前端运行

1.1.1 解决版本冲突
```
cd C:\Dev\Workspaces\master408\source\vue\xzs-student
```
卸载 node-sass 并安装 sass
```
npm uninstall node-sass

npm install sass --save-dev
```
1.1.2 清理并重新安装所有依赖
```
rm -rf node_modules package-lock.json

npm install
```
1.1.3 启动项目
```
npm run serve
```

1.2后端运行
```
cd c:/Dev/Workspaces/master408/source/xzs

mvn spring-boot:run
```
1.3数据库
默认数据库名：xzs

数据库密码修改位置：application-dev.yml
source\xzs\src\main\resources\application-dev.yml
---

## 408刷题系统开发流程（基于学之思扩展）

### 一、项目准备与环境搭建（1天）

| 任务 | 负责人 | 产出物 | 备注 |
|------|--------|--------|------|
| 克隆基础项目 `xzs-mysql` 到本地 | 全员 | 本地仓库 | 使用你已推送的 `master408` 仓库 |
| 导入完整数据库脚本 | 后端 | 数据库 `xzs_408` | 包含学之思原有表 + 8张408扩展表 + 初始数据 |
| 修改后端配置文件（数据库连接、端口等） | 后端 | `application.yml` | 确保能正常启动后端服务 |
| 启动前端项目（`student` / `admin`）并验证基础功能 | 前端 | 运行中的前端页面 | 登录、首页等学之思原有功能正常 |
| 安装并配置本地 Ollama (qwen:7b) | 后端/AI | 可调用的 AI 服务 | 用于第二阶段AI辅助功能 |

---

### 二、第一阶段：核心功能开发（1-2周，必须完成）

> **目标**：跑通408刷题最小闭环——题库管理、在线答题、错题本、用户基础功能。

#### 第1周：后端接口开发

| 模块 | 接口 | 优先级 | 依赖表 |
|------|------|--------|--------|
| **题库分类** | 获取科目章节/考点树 `GET /api/student/subject/knowledge-tree` | P0 | `t_subject`, `t_chapter`, `t_knowledge_point` |
| **题目查询** | 分页获取题目列表 `POST /api/student/question/page` | P0 | `t_question`, `t_question_category` |
| **题目详情** | 获取题目详情 `GET /api/student/question/detail/{id}` | P0 | `t_question`, `t_text_content` |
| **刷题会话** | 开始刷题 `POST /api/student/practice/session/start` | P0 | `t_practice_session`, `t_question` |
| **提交答案** | 提交单题并获取下一题 `POST /api/student/practice/session/submit` | P0 | `t_practice_answer`, `t_wrong_book`, `t_practice_session` |
| **错题本** | 加入错题本 `POST /api/student/wrong-book/add` | P0 | `t_wrong_book` |
| | 获取错题本列表 `POST /api/student/wrong-book/page` | P0 | `t_wrong_book`, `t_question` |
| | 更新掌握状态 `POST /api/student/wrong-book/status/update` | P1 | `t_wrong_book` |
| | 删除错题 `DELETE /api/student/wrong-book/delete/{id}` | P1 | `t_wrong_book` |
| **用户统计** | 获取个人学习统计 `GET /api/student/statistics/overview` | P1 | `t_practice_answer`, `t_wrong_book` |

**后端开发规范**：
- 遵循学之思现有代码结构：`controller`、`service`、`mapper`、`domain`、`viewmodel`。
- 复用现有 `BaseApiController`、`RestResponse` 等基础类。
- 使用 MyBatis-Plus 简化单表操作。
- 所有接口均需通过 `@RestController` 和 `@PostMapping`/`@GetMapping` 注解，并配置 Shiro 权限（学生角色可访问）。

#### 第2周：前端页面开发

| 页面 | 功能点 | 负责人 |
|------|--------|--------|
| **题库浏览页** | 左侧408科目树，右侧题目列表（支持筛选科目、章节、题型），点击进入答题 | 前端A |
| **答题页** | 展示题干、选项，提交后立即显示对错与解析，支持“下一题”和“加入错题本” | 前端A |
| **错题本页** | 按科目/考点筛选，展示错题列表，可查看详情、标记掌握状态、删除 | 前端B |
| **个人中心-学习报告** | 展示各科正确率、薄弱考点图表（使用 ECharts） | 前端B |
| **登录/注册页** | 复用学之思现有页面，微调样式 | 前端A |

**前端开发规范**：
- 基于学之思原有 Vue 2.x + Element UI 技术栈，新增页面放在 `src/views/408` 目录下。
- API 请求统一封装在 `src/api/408.js`，复用现有 `request` 拦截器。
- 路由配置在 `src/router/index.js` 中增加408相关路由。

---

### 三、第二阶段：体验优化与AI功能（2-3周）

> **目标**：提升用户体验，接入AI辅助学习。

| 任务 | 后端 | 前端 |
|------|------|------|
| **AI详细解析** | 实现接口 `POST /api/student/ai/analysis`，调用 Ollama API 生成详细解析 | 答题页增加“AI解析”按钮，展示生成的内容 |
| **AI对话** | 实现接口 `POST /api/student/ai/chat`，支持上下文题目提问 | 在解析弹窗或侧边栏增加对话输入框 |
| **题目搜索** | 实现接口 `GET /api/student/question/search?keyword=xxx` | 顶部导航增加搜索入口，结果高亮展示 |
| **做题数据统计强化** | 完善 `statistics/overview` 接口，增加近一周正确率趋势 | 个人中心增加趋势折线图 |
| **界面优化** | - | 答题页增加动画过渡、暗色模式适配 |

---

### 四、第三阶段：拓展功能（可选，按需迭代）

- 高校专区（各大高校真题库）
- 题目收藏功能
- 移动端适配（rem + 响应式）
- AI个性化复习规划

---

### 五、测试与部署（持续进行）

| 阶段 | 内容 |
|------|------|
| **单元测试** | 后端核心 Service 方法编写 JUnit 测试 |
| **接口测试** | 使用 Postman 或 Apifox 对新增接口进行冒烟测试 |
| **联调测试** | 前后端联调，确保数据格式与接口文档一致 |
| **部署** | 后端打包 jar，前端打包 dist 放入 Nginx，配置反向代理 |

---

### 六、团队协作建议

- **分支管理**：`main` 分支保护，开发在 `dev` 分支，每人按功能创建 `feature/xxx` 分支。
- **每日站会**：同步进度、阻塞点。
- **文档维护**：接口变更及时更新接口文档（YApi/Apifox），数据库变更记录在 `sql/migration.sql`。
- **代码规范**：后端遵循阿里巴巴 Java 规范，前端 ESLint + Prettier 统一格式。

---

### 七、里程碑时间线（建议）

```
Week 1-2:  完成P0核心接口 + 题库浏览页、答题页
Week 3:    完成错题本 + 学习报告页面，联调通过
Week 4:    第一阶段测试、修复 Bug、演示
Week 5-6:  第二阶段 AI 功能 + 搜索 + 统计图表
Week 7:    第二阶段测试、优化、准备部署
Week 8+:   拓展功能选做
```

