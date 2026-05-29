# AI 密钥配置页完善与安全加固

**日期**：2026-05-29
**范围**：管理后台 `/ai/config` 页面功能完善 + API 密钥安全治理

---

## 1. 背景

管理后台"密钥与用量"页面存在多个问题：

- 密钥实际存在（`application.yml` 里配置了智谱 API Key）但页面显示"未设置"，因为前端读的是数据库，而数据库 `ai_provider_config` 表的密钥字段为空
- 没有删除供应商功能
- 测试连接只显示成功/失败标签，错误详情看不到
- 用量分析只有数字和表格，没有趋势图
- 费用一直显示 0（后端 `log.setCost(0D)` 硬编码）
- 编辑已有供应商时供应商代码还能改（改了会导致查询失败）
- `application.yml` 中明文 API Key 已被提交到 GitHub，存在泄露风险

---

## 2. 修复内容

### 2.1 密钥同步：application.yml → 数据库

**问题**：API Key 存在 `application.yml` 里，AI 功能正常（有 fallback 逻辑），但管理后台读数据库所以显示空。

**方案**：在 `AiProviderConfigServiceImpl` 加 `@EventListener(ApplicationReadyEvent.class)` 方法，启动时自动检测：

- 如果 `application.yml` 里有 `ai.api.key` 且数据库对应 provider 还没有密钥 → 自动加密写入并启用
- 如果数据库已有密钥 → 不覆盖

**改动文件**：`AiProviderConfigServiceImpl.java`

### 2.2 安全加固：清除明文密钥

**问题**：`application.yml` 中 `ai.api.key: e4a645c3...` 明文写在源码里，已被推送到 GitHub。

**方案**：

- 将 `ai.api.key` 改为 `${AI_API_KEY:}` 环境变量占位符
- 密钥已通过 2.1 的同步机制存入数据库，后续通过管理后台管理
- 提醒用户：如仓库为 public，需到智谱平台重置 Key

**改动文件**：`application.yml`

### 2.3 新增删除供应商功能（全栈）

**方案**：按项目已有的 delete 模式（POST `/delete/{id}`，无确认弹窗）实现。

| 层 | 文件 | 改动 |
|---|---|---|
| Mapper XML | `AiProviderConfigMapper.xml` | 加 `<delete id="deleteById">` |
| Mapper 接口 | `AiProviderConfigMapper.java` | 加 `int deleteById(Integer id)` |
| Service 接口 | `AiProviderConfigService.java` | 加 `void deleteById(Integer id)` |
| Service 实现 | `AiProviderConfigServiceImpl.java` | 加实现 |
| Controller | `AiConfigController.java` | 加 `POST /provider/delete/{id}` |
| 前端 API | `aiConfig.js` | 加 `deleteProvider` 方法 |
| 前端页面 | `config.vue` | 操作列加删除按钮 |

### 2.4 测试结果详情展示

**方案**：测试状态列用 `el-tooltip` 包裹，hover 时显示 `lastTestMessage`（后端已返回，前端之前没展示）。

**改动文件**：`config.vue`

### 2.5 费用计算

**问题**：`AnalysisService` 和 `RagService` 的 `saveUsageLog` 中 `log.setCost(0D)` 硬编码。

**方案**：新建 `AiPricing.java` 工具类，内置各模型的每百万 token 单价：

| 模型 | 单价（/百万 token） |
|---|---|
| glm-4.5-air | ¥0.5 |
| glm-4-air | ¥0.5 |
| glm-4-flash | ¥0.1 |
| deepseek-chat | ¥2.0 |
| deepseek-reasoner | ¥4.0 |
| gpt-4.1-mini | $1.6 |
| gpt-4o-mini | $0.6 |
| gpt-4o | $17.5 |
| embedding-2 | ¥0.5 |
| text-embedding-3-small | $0.02 |

`AnalysisService` 和 `RagService` 的 `setCost(0D)` 改为 `AiPricing.calculateCost(model, tokensUsed)`。

**新增文件**：`AiPricing.java`
**改动文件**：`AnalysisService.java`、`RagService.java`

### 2.6 用量趋势折线图

**方案**：后端已返回 `byDay` 数据（day、requestCount、tokensUsed），前端用 ECharts 5.6.0（项目已安装）渲染双 Y 轴折线图。

- 左轴：请求数（蓝线）
- 右轴：Token 用量（绿线）
- 放在用量分析卡片内，汇总指标和按供应商表格之间

**改动文件**：`config.vue`

### 2.7 供应商代码编辑只读

**方案**：编辑已有供应商时（`form.id != null`），providerCode 输入框 disabled。新建时正常可输入。

**改动文件**：`config.vue`

---

## 3. 附加修复

### AnalysisService 编译错误

`AnalysisService.java` 第 214-220 行使用了 Unicode 智能引号（`"` `"` U+201C/U+201D）作为 Java 字符串定界符，`mvn clean compile` 时报错。原因是之前的修改工具自动转换了引号类型。

修复：将字符串定界符替换为标准 ASCII `"`，字符串内部的中文引号改用 `\"` 转义。

---

## 4. 侧边栏精简

隐藏了管理后台侧边栏中不常用的菜单入口（URL 仍可访问）：

- 教育管理 `/education`
- 成绩管理 `/answer`
- 消息中心 `/message`
- 日志中心 `/log`
- 任务管理 `/task`

"AI 管理" 父级菜单去掉，改为"密钥与用量"直接作为侧边栏一级入口。

**改动文件**：`router/index.js`
