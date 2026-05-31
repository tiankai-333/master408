# 2026-05-31 小程序功能完善 & Bug 修复（第二轮）

## 背景

小程序前端功能基本完成后，进行实际体验测试，发现多个页面空白、数据不显示、交互不合理等问题。逐一排查修复。

## 问题与修复

### 1. 试卷提交批改失败

**现象**：做完试卷点击"提交试卷"后无法批改，首页学习记录始终为空。

**根因**：`formSubmit` 直接修改 `e.detail.value` 对象追加 `id` 和 `doTime`，在小程序某些版本下赋值不可靠。后端 `requestToExamPaperSubmitVM` 解析不到参数时 NPE，但 controller 没有 try-catch，直接返回 500。

**修复**：
- 前端：用 `Object.keys()` 构建独立 formData 对象，不再直接修改 `e.detail.value`
- 后端：`answerSubmit` 方法包裹 try-catch，日志记录异常详情
- 后端返回的错误信息通过 `wx.showToast` 展示给用户，不再静默失败

**涉及文件**
- `source/wx/xzs-student/pages/exam/do/index.js` — formSubmit 重构
- `source/xzs/.../controller/wx/student/ExamPaperAnswerController.java` — 加 logger 和 try-catch

### 2. AI 分析等待白屏

**现象**：拍照识题、错题解析等待 AI 回复时全屏白屏，只有转圈。

**根因**：页面使用 `<i-spin size="large" fix>` 全屏遮罩，AI 响应慢时用户看到的就是白屏。

**修复**：
- 错题解析页：去掉 `aiAnalyzing` 的全屏 spin，按钮本身已有 loading 状态
- 拍照识题页：去掉全屏 spin，改为内联提示条"AI 识别中，请稍候..."

**涉及文件**
- `source/wx/xzs-student/pages/error-book/detail/index.wxml`
- `source/wx/xzs-student/pages/ai-analyze/index/index.wxml`
- `source/wx/xzs-student/pages/ai-analyze/index/index.wxss`

### 3. 首页日历标签硬编码 & 学习详情空白

**现象**：周日历标题永远显示"本周"，切换前后周不变。学习详情始终"当天暂无学习记录"。

**根因**：
- 标签：WXML 硬编码 `本周`，`weekLabel` 变量已计算但未使用
- 学习详情：API 返回非 code=1 时 `.then()` 的 `if` 分支静默忽略，用户看到空白

**修复**：
- 标签：`本周` → `{{weekLabel}}`
- 错误提示：所有 API 调用的 `.then()` 加 else 分支，非 401 时显示 toast

**涉及文件**
- `source/wx/xzs-student/pages/index/index.wxml`
- `source/wx/xzs-student/pages/index/index.js`

### 4. 真题练习只显示 4 科

**现象**：科目选择只显示数据结构、组成原理、操作系统、计算机网络。

**根因**：科目列表前端硬编码，数据库实际有 8 科（含 408综合、数学1、英语1、政治）。

**修复**：保留硬编码为兜底，`onLoad` 时调用 `/api/wx/student/subject/list` 覆盖。后端新增 `SubjectController`（wx student 版本），调用已有的 `subjectService.allSubject()`。

**涉及文件**
- `source/wx/xzs-student/pages/exam/index/index.js` — loadSubjects()
- `source/xzs/.../controller/wx/student/SubjectController.java` — 新建

### 5. 练习中心"限时训练"改为"拍照识题"

**修复**：入口文案和跳转路径改为已有页面 `/pages/ai-analyze/index/index`。

**涉及文件**
- `source/wx/xzs-student/pages/practice/index.wxml`

### 6. 密钥信息页（替换"消息"）

**需求**："我的"页面"消息"入口改为"密钥信息"，显示公共/私人 AI 密钥和测试按钮。

**实现**：
- 后端：新增 `AiConfigController`（wx student 版），复用 `AiProviderConfigService` 和 `AiUserKeyService`
- 前端：新建 `pages/my/ai-keys/index` 页面，分公共/私人两块显示
- "我的"页面入口改为跳转密钥信息页

**涉及文件**
- `source/xzs/.../controller/wx/student/AiConfigController.java` — 新建
- `source/wx/xzs-student/pages/my/ai-keys/index.*` — 新建
- `source/wx/xzs-student/pages/my/index/index.wxml` — 入口替换

### 7. baseAPI 裸 IP 导致体验版不可用

**现象**：`globalData.baseAPI = "http://118.31.34.132"`，开发工具因 `urlCheck: false` 不报错，但体验版被微信域名白名单拦截。

**根因**：`formPost`/`jsonPost`/`uploadFile` 所有请求都拼接到这个裸 IP。`staticBase` 已经用 `https://wx.hhhuu.com`，说明 Nginx 反代就位。

**修复**：`baseAPI` 改为 `"https://wx.hhhuu.com"`，三个请求函数加 `console.log('[request]', url)` 日志。

**涉及文件**
- `source/wx/xzs-student/app.js`

### 8. 后端 token 表被清空导致全局 401

**现象**：所有页面数据空白，curl 测试返回 `{"code":401,"message":"用户未登录"}`。

**根因**：之前数据库重导时 `t_user_token` 表被清空，小程序本地存的旧 token 在服务端查不到。

**修复**：
- 用户重新绑定登录（根本操作）
- 前端所有 API 调用加可见错误提示，不再静默空白
- 后端部署新 controller（`AiConfigController`、`SubjectController`）通过 `scp jar → docker cp → docker restart` 最小化部署

### 9. 组卷弹窗"清除"按钮 & 科目切换不清知识点

**修复**：
- 去掉科目和知识点选择弹窗的"清除"按钮
- 切换科目时自动清除已选知识点（`selectedPoint: null`）

### 10. 画像按键不传个人数据 & 未选科目时组卷应针对错题

**修复**：
- 画像：点击后先调 `/api/wx/student/user/stats` 获取学习统计，注入 `context.userStats` 传给后端
- 组卷：未选科目时不弹警告，改为发送"根据错题生成练习"请求（`practice_plan` intent, `preferMistakes=true`）

## 经验总结

### 微信小程序认证体系

1. 小程序 `/api/wx/**` 和网页 `/api/student/**` 是**两套独立的认证**。wx 用 token header（`TokenHandlerInterceptor`），web 用 Spring Security session。不能混用
2. `t_user_token` 表是 wx 认证的唯一凭证。数据库重导/清空时必须同步处理这张表，否则所有 wx 用户登录态失效
3. `formPost` 收到 code=401 时会 `wx.reLaunch` 到绑定页。如果用户没被跳转但数据空白，说明 API 返回了非 1 的 code 但不是 401，被 `if (res.code === 1)` 静默丢弃

### 小程序域名配置

1. `app.globalData.baseAPI` 决定所有 API 请求的目标地址。必须用 HTTPS 域名，不能用裸 IP
2. 开发工具 `urlCheck: false` 只在开发期有效，体验版/正式版强制校验
3. 微信后台的"request 合法域名"必须配置，且 AppID 要和开发工具一致
4. 请求失败时加 `console.log('[request]', url)` 打印完整 URL，不要靠猜

### API 错误处理原则

1. **永远不要静默吞错误**。`.then()` 里 `if (res.code === 1)` 必须配 `else` 分支，至少 `console.warn` 或 `wx.showToast`
2. 401（未登录）不要重复弹提示（formPost 已处理跳转），但要区分 401 和其他错误码
3. `e.detail.value` 不要直接赋值，用 `Object.keys()` 构建新对象

### 最小化后端部署

1. `scp jar → docker cp → docker restart` 三步完成，不需要重新构建镜像
2. 但注意：容器重建后（`docker compose up`）会丢失 docker cp 进去的文件。长期方案应该更新 Dockerfile 或用 volume 挂载
