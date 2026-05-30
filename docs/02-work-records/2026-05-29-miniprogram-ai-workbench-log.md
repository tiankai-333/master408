# 2026-05-29 微信小程序中等功能改造

## 分支

- 开发分支：`dev`
- 基于已有小程序基础功能（4 Tab：首页、刷题、错题、我的）

## 改动概述

在微信小程序端新增 AI 学习助手、知识目录、学习画像三项中等功能，同时优化首页/刷题页/错题页 UI 展示。

## 后端改动

### 新增 WX 知识图谱 Controller

- 文件：`source/xzs/src/main/java/com/mindskip/xzs/controller/wx/student/KnowledgeGraphController.java`
- 3 个 POST 端点，委托 `KnowledgeGraphService`：
  - `POST /api/wx/student/knowledge-graph/graph` — 知识图谱数据
  - `POST /api/wx/student/knowledge-graph/knowledge-point/{id}` — 知识点详情
  - `POST /api/wx/student/knowledge-graph/knowledge-point/{id}/questions` — 关联题目
- 所有端点用 POST（非 GET），匹配小程序 `formPost()` 封装

### 新增用户学习统计端点

- 文件：`source/xzs/src/main/java/com/mindskip/xzs/controller/wx/student/UserController.java`
- 新增 `POST /api/wx/student/user/stats`
- 参考 `ChatController.getUserStats()` 的 JdbcTemplate 查询逻辑
- 返回 totalQuestions、accuracy、weakPoints、按科目统计

### 后端构建验证

- `mvn package -DskipTests` BUILD SUCCESS

## 前端改动

### 新增 AI 学习助手页面

- 目录：`source/wx/xzs-student/pages/ai-workbench/`（4 文件）
- 功能：粘贴题目 → 选择四种讲法 → AI 解析 → Markdown 渲染 → 复制结果
- 复用已有 `/api/wx/student/question/analyze-question` 接口
- 支持从其他页面跳转传入 `content` 参数

### 新增知识目录页面

- 目录：`source/wx/xzs-student/pages/knowledge/index/`（4 文件）
- 功能：加载知识图谱数据 → 按科目折叠分组 → 搜索过滤 → 点击进入详情
- 知识点分组兜底 category/subjectName/"未分类"

### 新增知识点详情页面

- 目录：`source/wx/xzs-student/pages/knowledge/detail/`（4 文件）
- 功能：知识点名称+描述、上下级导航、关联真题列表、AI 讲解按钮
- AI 讲解跳转到 AI 学习助手并自动填入知识点名称

### 首页 UI 优化

- 去掉 i-cell 列表式入口，改为 2 列功能卡片网格（6 个入口）
- 新增学习统计卡片（已做题/正确率/疑似薄弱项）
- 统计接口独立加载，失败不影响首页主功能
- 空的今日任务/限时训练区块不再显示

### 刷题页 UI 优化

- i-cell 列表改为单列卡片布局
- 试卷名称支持 2 行省略
- 修复 loadMoreTip：空列表显示独立空状态，到底显示"没有更多了"

### 错题本 UI 优化

- i-cell 列表改为单列卡片布局，带红色题型标签
- 空状态提示改为"暂无错题，继续保持！"
- 修复 loadMoreTip 不再在已有数据时显示"暂无数据"

### 页面注册

- `app.json` 新增 3 个页面：`ai-workbench/index`、`knowledge/index/index`、`knowledge/detail/index`
- TabBar 不变

## 未改动的文件

- `app.js`（baseAPI 和 formPost 不变）
- tabBar 配置
- `exam/do/`、`exam/read/` 答题流程
- `error-book/detail/` 错题详情 + AI 解析
- `ai-analyze/` 拍照识题
- iView 组件库
- Service 层业务逻辑

## 关键技术决策

1. **WX 接口全用 POST**：小程序 `formPost()` 只支持 POST，即使语义上是查询也用 POST。
2. **AI 返回值兼容字符串/对象**：`res.response` 可能是字符串或 `{ content: "..." }` 对象，前端做类型判断。
3. **不用 finally**：`then`/`catch` 都显式恢复 loading 状态，兼容低版本基础库。
4. **统计接口不阻塞首页**：`loadUserStats()` 独立调用，不 await。
5. **学习画像用"疑似薄弱项"**：不写成"薄弱点诊断"，避免算法能力表述过度。
6. **不新增 Tab**：AI 和知识点做成贯穿式能力，从首页入口进入。

## 文档产出

- `docs/03-engineering-experience/wechat-miniprogram-development-notes.md` — 开发经验总结
