# 微信小程序中等功能改造经验总结

## 项目背景

408Master 微信小程序（`source/wx/xzs-student/`）是基于原生微信小程序 + iView Weapp 组件库的学生端。本次改造目标：在已有 4 Tab（首页、刷题、错题、我的）基础上，新增 AI 学习助手、知识目录、学习画像三项中等功能，同时优化首页/刷题页/错题页 UI。

改造完成后小程序覆盖：刷题、错题复习、拍照识题、AI 解析、知识目录浏览、学习统计。

---

## 一、架构判断

### 1.1 小程序和 Web 学生端的关系

```
小程序页面 → app.formPost() → /api/wx/student/*  → WX Controller → Service 层
Web 学生端 → axios/postStream → /api/student/*    → Student Controller → Service 层
```

两端 Controller 独立，Service 层共用。这意味着：

- **Service 改动两边都生效**，不需要重复写业务逻辑。
- **新增小程序功能只需要两层工作**：新增 WX Controller（薄转发层）+ 新增小程序页面。
- **不要复用 Web Controller**，因为认证机制不同（Web 用 Cookie/Session，小程序用 Token）。

### 1.2 WX Controller 的固定写法

每个 WX Controller 都遵循这个模板：

```java
@Controller("WXStudent<Name>Controller")   // bean 名必须加 WXStudent 前缀避免冲突
@RequestMapping(value = "/api/wx/student/<path>")
@ResponseBody
public class <Name>Controller extends BaseWXApiController {

    private final SomeService someService;

    @Autowired
    public <Name>Controller(SomeService someService) {
        this.someService = someService;
    }

    @RequestMapping(value = "/endpoint", method = RequestMethod.POST)
    public RestResponse<SomeType> methodName(@RequestParam ... params) {
        return RestResponse.ok(someService.someMethod(params));
    }
}
```

关键点：
- 继承 `BaseWXApiController`，通过 `getCurrentUser()` 获取当前用户。
- 所有端点用 `RequestMethod.POST`（不是 GET），因为 `app.formPost()` 只支持 POST。
- Controller 只做转发，不加业务逻辑。

---

## 二、踩过的坑

### 2.1 GET vs POST：前端请求封装决定后端设计

小程序 `app.js` 只封装了 `formPost()`，没有 GET 方法。如果后端设计为 `GET /api/wx/student/...`，前端无法直接调用。

**结论**：所有 WX 小程序接口统一用 POST，即使语义上是查询操作。这和 Web 端不同（Web 端知识图谱用 GET）。

如果将来需要 GET（比如下载），在 `app.js` 中补一个最小 `formGet()` 即可，但不要为此破坏现有 `formPost`。

### 2.2 AI 返回值类型不稳定

`/api/wx/student/question/analyze-question` 的 `res.response` 可能是：
- 纯字符串（Markdown 文本）
- 带结构对象（`{ content: "..." }`）
- `null`

前端必须做兼容处理：

```js
var raw = ''
if (typeof res.response === 'string') {
  raw = res.response
} else if (res.response && res.response.content) {
  raw = res.response.content
} else {
  raw = String(res.response || '')
}
```

### 2.3 不要用 finally

小程序运行环境和代码风格偏保守，Promise 的 `finally` 在低版本基础库可能不稳。用 `then` + `catch` 都显式恢复状态：

```js
app.formPost(url, data)
  .then(function (res) {
    _this.setData({ loading: false })
    // handle success
  })
  .catch(function (e) {
    _this.setData({ loading: false })
    // handle error
  })
```

### 2.4 知识图谱数据结构需要前端二次加工

后端 `KnowledgeGraphService.getKnowledgeGraph()` 返回的是图谱格式（nodes + links + categories），不是列表。小程序不需要图形化展示，需要在前端把 nodes 按 category 分组转成列表。

分组时 `node.category` 可能不存在，需要兜底：

```js
var groupName = node.subjectName || node.categoryName || '未分类'
```

### 2.5 loadMoreTip 不能用"暂无数据"一个文案覆盖三种状态

小程序列表页的底部提示应区分：
- 空列表：不显示 load-more，显示独立的空状态卡片
- 加载中：`"正在加载..."`
- 已到底：`"没有更多了"`

```js
// 到底时
loadMoreTip: re.list.length > 0 ? '没有更多了' : ''
```

### 2.6 首页统计接口不能阻塞主流程

首页同时加载 dashboard 数据（试卷/任务）和用户统计。统计接口可能慢或失败，必须独立调用：

```js
indexLoad: function() {
  this.loadUserStats()  // 不 await，独立执行
  app.formPost('/api/wx/student/dashboard/index', null).then(...)
  app.formPost('/api/wx/student/dashboard/task', null).then(...)
}
```

统计失败只设 `statsLoadFailed: true`，不影响首页主功能。

---

## 三、页面设计经验

### 3.1 首页用 2 列功能卡片，不要堆 i-cell 列表

小程序首页是用户进入的第一个页面，需要一眼看清所有入口。i-cell 列表视觉上太密，不够突出。

改为 2 列 grid 卡片，每个卡片有彩色圆形图标 + 标题 + 一行描述：

```
[ AI 学习助手 ] [ 知识目录   ]
[ 专项练习    ] [ 错题本     ]
[ 拍照识题    ] [ 做题记录   ]
```

6 个入口刚好 3 行，不会太长也不会太稀疏。

### 3.2 刷题页和错题页用单列卡片

i-cell 的左右挤压布局（标题 + value + is-link）在小屏幕上信息密度高但阅读体验差。改为单列卡片：

- 左侧：标题（2 行截断）+ 科目/时间
- 右侧：箭头或标签
- 点击整张卡片跳转

### 3.3 不要新增第 5 个 Tab

微信小程序 Tab 超过 4 个会变挤。AI 和知识点更适合做成"贯穿式能力"（从首页入口进入），而不是独立 Tab。

### 3.4 不在小程序端暴露 API Key 管理

密钥属于敏感配置，小程序端输入和保存体验差，容易泄露。Web 管理端统一配置 Provider，小程序只调用后端封装好的接口。

---

## 四、可复用的代码模式

### 4.1 AI 分析页面模板

任何需要 AI 解析的新页面，都可以复用这个模式：

```js
// data
{ aiAnalyzing: false, aiResult: '', aiResultHtml: '', aiStyleIndex: 0 }

// AI 调用
app.formPost('/api/wx/student/question/analyze-question', {
  questionType: '未知',
  questionContent: content,
  options: '', correctAnswer: '',
  style: style
}).then(function (res) {
  // 兼容返回值
  var raw = typeof res.response === 'string' ? res.response : ...
  var html = markdownUtil.renderMarkdown(raw)
  _this.setData({ aiResult: raw, aiResultHtml: html })
})
```

依赖：
- `utils/markdown.js` → `renderMarkdown()`
- iView 组件：`i-button`, `i-message`, `i-spin`
- `<rich-text nodes="{{aiResultHtml}}" />` 渲染结果

### 4.2 分页列表模板

```js
// data
{ queryParam: { pageIndex: 1, pageSize: 20 }, tableData: [], total: 1 }

// 加载
app.formPost(url, queryParam).then(res => {
  setData({
    tableData: override ? re.list : tableData.concat(re.list),
    total: re.pages
  })
})

// 触底
onReachBottom: function () {
  if (!this.loading && pageIndex < total) {
    pageIndex++; search(false)
  }
}
```

### 4.3 页面跳转传参

```js
// 发送
wx.navigateTo({ url: '/pages/detail/index?id=' + id })
wx.navigateTo({ url: '/pages/page/index?content=' + encodeURIComponent(text) })

// 接收
onLoad: function (options) {
  var id = options.id
  var content = decodeURIComponent(options.content || '')
}
```

---

## 五、文件清单

### 本次新增文件

| 文件 | 用途 |
|------|------|
| `controller/wx/student/KnowledgeGraphController.java` | WX 知识图谱 3 端点 |
| `pages/ai-workbench/index.{js,wxml,wxss,json}` | AI 学习助手页面 |
| `pages/knowledge/index/index.{js,wxml,wxss,json}` | 知识目录页面 |
| `pages/knowledge/detail/index.{js,wxml,wxss,json}` | 知识点详情页面 |

### 本次修改文件

| 文件 | 改动 |
|------|------|
| `controller/wx/student/UserController.java` | 新增 stats 端点 |
| `app.json` | 注册 3 个新页面 |
| `pages/index/index.{js,wxml,wxss}` | 首页卡片化 + 统计 |
| `pages/exam/index/index.{js,wxml,wxss}` | 刷题页卡片布局 |
| `pages/error-book/index/index.{js,wxml,wxss}` | 错题页卡片 + 状态修复 |

### 未改动

`app.js`、tabBar、`exam/do`、`exam/read`、`error-book/detail`、`ai-analyze`、iView 组件库。

---

## 六、后续建议

1. **SSE 流式响应**：当前小程序 AI 解析是一次性返回，体验上比 Web 端慢。可以考虑用 `wx.request` 的 `enableChunked` 或轮询方案实现逐字输出。
2. **知识目录缓存**：知识图谱数据不常变，可以用 `wx.setStorageSync` 缓存，避免每次进入都请求。
3. **错题按知识点筛选**：当前 `QuestionAnswerController` 只支持按 `subjectId` 过滤。如果需要按知识点筛选错题，需要在后端新增 join 查询。
4. **小程序端学习画像完善**：当前只展示总数和正确率。后续可以加"每个科目的薄弱知识点"列表，需要 `student_knowledge_state` 表的数据。
