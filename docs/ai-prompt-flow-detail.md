# 408Master AI 修饰流程详解

本文档记录了系统中所有 AI 交互的完整流程，包括具体 prompt、JSON 结构、从发起到回答的每一步细节。

---

## 目录

1. [系统概览](#1-系统概览)
2. [Prompt 模板详解（4 种风格）](#2-prompt-模板详解4-种风格)
3. [场景一：工作台流式对话（核心路径）](#3-场景一工作台流式对话核心路径)
4. [场景二：题目分析页（同步/流式）](#4-场景二题目分析页同步流式)
5. [场景三：图片识别题目](#5-场景三图片识别题目)
6. [场景四：快速文本分析](#6-场景四快速文本分析)
7. [场景五：TXT 文件题目导入](#7-场景五txt-文件题目导入)
8. [场景六：RAG 知识库检索](#8-场景六rag-知识库检索)
9. [场景七：Agent 草案 / 组卷](#9-场景七agent-草案--组卷)
10. [场景八：Admin 模板测试](#10-场景八admin-模板测试)
11. [后处理：cleanAiAnswer 清洗规则](#11-后处理cleanaianswer-清洗规则)
12. [模型参数总览](#12-模型参数总览)
13. [API 请求 JSON 结构参考](#13-api-请求-json-结构参考)

---

## 1. 系统概览

### 1.1 调用链路图

```
前端 Vue 组件
  │
  ├─ /api/student/ai/workbench/stream  ──→  AiWorkbenchController
  │                                          │
  │                                          └─→ AiOrchestratorServiceImpl
  │                                                ├─ AiIntentRouter（意图识别）
  │                                                ├─ RagService.retrieve()（RAG 检索）
  │                                                └─ AnalysisService.analyzeWithAIStream()
  │                                                     └─ callAiApiStream() → LLM API
  │
  ├─ /api/student/ai/analyze           ──→  AIAnalysisController.analyzeWithAI()
  │                                          └─ RagService.retrieve() → AnalysisService.analyzeWithAI()
  │
  ├─ /api/student/ai/analyze-stream    ──→  AIAnalysisController.analyzeWithAIStream()
  │                                          └─ 同上，流式 SSE
  │
  ├─ /api/student/question/analyze-image ──→ QuestionController
  │                                          └─ QuestionServiceImpl.analyzeImageQuestion()
  │
  ├─ /api/student/question/analyze-question ──→ QuestionController
  │                                          └─ QuestionServiceImpl.analyzeQuestion()
  │
  └─ /api/admin/ai-agent/template/{id}/test ──→ AiAgentController
                                               └─ AiAgentServiceImpl.analyzeWithTemplate()
```

### 1.2 Provider 解析优先级

系统按以下顺序查找可用的 AI 密钥（优先级数值越小越优先）：

1. **用户私有密钥** (`ai_user_key` 表，`enabled=true`)  — `source: "private"`
2. **公共 Provider 配置** (`ai_provider_config` 表，`enabled=true`) — `source: "public"`
3. **application.yml 兜底** (`ai.api.key` + `ai.api.url`) — 最后兜底

所有候选按 `priority` 字段升序排列，取第一个。

---

## 2. Prompt 模板详解（4 种风格）

模板文件位于 `source/xzs/ai/prompts/analysis/` 下，启动时加载到内存。

### 2.1 default（标准解析）

**文件**: `default.json`

**System Prompt**:
```
你是一位严谨的计算机考研408辅导老师。你的讲解风格是：专业、全面、条理清晰、紧扣考点。你要像课堂上的老师一样，把题目涉及的每个知识点都讲透，帮助学生建立完整的知识体系。
```

**User Prompt 模板**:
```
请作为考研辅导老师，详细解析以下408题目：

{question}

{knowledge_points_block}

【重要要求】：
1. 必须给出明确的答案和选项分析
2. 每个知识点都要清晰定义
3. 紧扣考研408的考点要求

请严格按照以下格式输出：

## 📚 题型与考点
- **题型**：[单选题/多选题/判断题/填空题/简答题]
- **所属科目**：[数据结构/组成原理/操作系统/计算机网络]
- **核心考点**：[列出3-5个具体考点]

## 🎯 题目分析
用一句话概括这道题在考察什么。

## 📝 解题过程
**步骤1**：[分析已知条件]
**步骤2**：[推导过程]
**步骤3**：[得出结论]

## ✅ 最终答案
**答案：** [明确写出答案]

## 🔍 选项分析
**A选项**：[分析为什么对/错]
**B选项**：[分析为什么对/错]
**C选项**：[分析为什么对/错]
**D选项**：[分析为什么对/错]

## 💡 知识点回顾
### [知识点1名称]
- **定义**：[清晰定义]
- **关键性质**：[列出]
- **常见考法**：[考研中常怎么考]

### [知识点2名称]
- **定义**：[清晰定义]
- **关键性质**：[列出]
- **常见考法**：[考研中常怎么考]

## ⚠️ 易错提醒
- **陷阱1**：[具体说明]
- **陷阱2**：[具体说明]

## 🎓 总结
这道题的核心是掌握______，下次遇到类似题目要注意______。
```

---

### 2.2 feynman（费曼风格）

**文件**: `feynman.json`

**System Prompt**:
```
你是费曼学习法的践行者。你擅长把复杂的计算机概念翻译成大白话。你的秘诀是：用生活中的例子类比，讲成一个有趣的故事。就像理查德·费曼说的："如果你不能简单地解释它，说明你还没有真正理解它。" 你的语气应该亲切、热情，像在给好朋友讲故事一样。
```

**User Prompt 模板**（核心结构）:
```
用费曼学习法的方式，把这道考研题讲得通俗易懂！

{question}

{knowledge_points_block}

【费曼风格要求】：
1. 必须用生活中的例子类比（比如：餐厅、快递、图书馆、交通等）
2. 避免专业术语，如果必须用，要先翻译成大白话
3. 语气亲切，像聊天一样
4. 用具体的数字或场景，让抽象变具体
5. 结尾要有一个"费曼总结"，一句话概括核心

输出格式：
## 👋 嗨，让我用大白话给你讲明白！
## 🏠 生活类比（如：进程调度→餐厅排队点菜、内存管理→仓库货架、TCP协议→快递签收）
## 🤔 一步一步来（侦探破案模式）
## 🎬 具体例子（手动算一遍）
## 🔍 为什么其他选项不对？
## 💡 费曼总结
```

---

### 2.3 first-principles（第一性原理）

**文件**: `first-principles.json`

**System Prompt**:
```
你是一位第一性原理的思考者。像埃隆·马斯克一样，你不满足于表面的知识和经验法则。你要做的是：1) 识别当前问题中的所有假设 2) 把问题分解到最基本的定义 3) 从定义出发，逻辑严密地重新构建答案。你的目标是让读者不仅知道"答案是什么"，更理解"为什么是这样"，以及"如果条件变了会怎样"。
```

**User Prompt 模板**（核心结构）:
```
用第一性原理的思维方式，从本质出发解析这道考研408题目：

{question}

{knowledge_points_block}

【第一性原理要求】：
1. 不要直接用"套路"或"经验法则"，要从最基本的定义出发
2. 明确指出哪些是"假设"，哪些是"事实/定义"
3. 展示完整的逻辑链：定义 → 推导 → 结论
4. 要做"假设检验"：如果某个条件变了，会怎样？
5. 区分"必要条件"和"充分条件"

输出分四阶段：
## 🔍 第一阶段：去壳 —— 识别假设
## 🧱 第二阶段：分解 —— 回到本质（不可再分的核心概念）
## 🔗 第三阶段：重构 —— 从定义出发推导
## 🤔 第四阶段：延伸 —— 假设检验 + 套路vs第一性原理对比
## 🎓 第一性原理总结
```

---

### 2.4 plato（启发式/苏格拉底式）

**文件**: `plato.json`

**System Prompt**:
```
你是一位循循善诱的导师。你不直接灌输知识，而是通过巧妙的提问引导学生自己发现答案。就像苏格拉底的"产婆术"一样，你要展示一个完整的思考过程：提出问题→引导思考→得出结论。你的语气应该是引导性的、启发性的，让读者感觉是自己在思考，而不是被动接受。
```

**User Prompt 模板**（核心结构）:
```
请用启发式的方式，引导我理解这道考研408题目。展示一个完整的思考过程：

{question}

{knowledge_points_block}

【启发式要求】：
1. 采用自问自答的形式，展示思考过程
2. 提出的问题要层层递进，从浅到深
3. 每个问题后要有引导性的思考提示
4. 不要直接给答案，要展示"如何想到答案"
5. 语气要像在与学生对话

输出格式：
## 🤔 让我们一起思考（分四步：搞清题目→回忆知识→分析选项→综合判断）
## 🎯 我的思考历程（完整展示推导链）
## ✅ 最终结论
## 💡 启发式总结（给出3个自查问题）
```

---

### 2.5 变量替换规则

模板中的占位符在运行时替换（`PromptTemplate.formatUserPrompt()`）：

| 占位符 | 替换内容 | 替换逻辑 |
|--------|----------|----------|
| `{question}` | 用户问题/题干 | 直接替换，null→空字符串 |
| `{knowledge_points_block}` | 知识点块 | 非空时包装为 `**相关知识点**：\n{knowledge_points}`，空则为空字符串 |
| `{knowledge_points}` | 知识点原文 | 直接替换 |
| `{reference_docs}` | RAG 参考资料 | 非空时包装为 `**以下内容来自题库中的相关题目，请参考这些内容确保你的答案准确无误，不要编造与参考答案矛盾的信息**：\n{referenceDocs}`，空则为空字符串 |

---

## 3. 场景一：工作台流式对话（核心路径）

**入口**: `POST /api/student/ai/workbench/stream`
**控制器**: `AiWorkbenchController` → `AiOrchestratorServiceImpl.handleStream()`

### 3.1 请求 JSON

```json
{
  "intent": "explain_question | explain_knowledge | learning_profile | practice_plan | compose_paper | free_chat",
  "style": "default | feynman | first-principles | plato",
  "userMessage": "这道题选什么？",
  "context": {
    "contextType": "question | knowledge_point | pasted_question | free",
    "subjectId": 1,
    "subjectName": "数据结构",
    "question": {
      "id": 123,
      "source": "2019年408真题",
      "title": "...",
      "body": "题干内容",
      "options": [{"key":"A","text":"选项A"},{"key":"B","text":"选项B"},...],
      "correctAnswer": "C",
      "analysis": "数据库中的解析",
      "questionType": 1,
      "sourceYear": "2019"
    },
    "knowledgePoint": {
      "id": 10,
      "name": "二叉树遍历",
      "summary": "...",
      "description": "...",
      "htmlRef": "...",
      "sourceUrl": "...",
      "relatedQuestionIds": [1,2,3]
    },
    "answerRecord": {
      "answerId": 456,
      "userAnswer": "B",
      "correct": false,
      "doTime": 120
    },
    "pastedText": null,
    "userStats": {
      "totalQuestions": 50,
      "correctRate": 0.72,
      "subjectBreakdown": {...}
    }
  }
}
```

### 3.2 意图识别（AiIntentRouter）

按以下优先级依次判断：

| 优先级 | 条件 | 意图 |
|--------|------|------|
| 1 | 请求显式指定了 `intent` 且值合法 | 使用该 intent |
| 2 | 用户消息匹配 `(练习\|组卷\|出题\|挑选\|生成.*卷\|针对.*题\|同类题)` | `practice_plan` |
| 3 | 用户消息匹配 `(学习画像\|薄弱点\|学习状态\|掌握情况\|复习建议\|正确率)` | `learning_profile` |
| 4 | 用户消息匹配 `(直接建卷\|确认生成试卷)` 或包含 `/compose paper` | `compose_paper` |
| 5 | 上下文有 question 或 pastedText | `explain_question` |
| 6 | 上下文有 knowledgePoint | `explain_knowledge` |
| 7 | 以上都不满足 | `free_chat` |

### 3.3 分支处理

#### 分支 A：`practice_plan`
不调用 LLM。查询题库生成 Agent 草案，返回 `agentDraft` SSE 事件。

#### 分支 B：`compose_paper`
不调用 LLM。从题库选题生成试卷，返回 `paper` SSE 事件。

#### 分支 C：其他意图（explain_question / explain_knowledge / learning_profile / free_chat）

**步骤 1 — 构建上下文文本** (`buildContextText()`)：

```
上下文类型：question
科目：数据结构

## 当前知识点
名称：二叉树遍历
摘要：二叉树的先序、中序、后序遍历方式
HTML 引用：https://...

## 当前题目
来源：2019年408真题
题干：某二叉树的...
选项：
- A. xxx
- B. xxx
数据库正确答案：C
数据库解析：根据...

## 我的作答记录
我的答案：B
是否正确：错误
做题时间：120

## 学习统计（仅 learning_profile 意图时附加）
- totalQuestions：50
- correctRate：0.72
```

**步骤 2 — 构建用户请求** (`buildStudentRequest()`)：

根据意图在用户消息前加不同前缀：

| 意图 | 前缀 |
|------|------|
| `learning_profile` | `请根据我的学习状态、当前上下文和做题记录，生成 408 学习画像。` |
| `explain_knowledge` | `请围绕当前知识点进行讲解。` |
| `explain_question` | `请围绕当前题目进行讲解。` |
| 其他 | `请围绕当前上下文回答学生问题。` |

然后追加：
```

## 用户请求
{userMessage}
```

如果上下文有 `pastedText` 但没有 `question`：
```

## 粘贴题目
{pastedText}
```

**步骤 3 — RAG 检索**（仅 `pasted_question` 类型上下文触发）：

- 调用 `RagService.retrieve(query, 5)` 检索 top-5 相似文档
- 相似度阈值：0.5（低于此值丢弃）
- 发送 SSE `references` 事件给前端
- 格式化为参考资料追加到 prompt

**步骤 4 — 传入 AnalysisService**：

```
analysisService.analyzeWithAIStream(style, userRequest, contextText, referenceDocs, intent, tokenConsumer)
```

### 3.4 AnalysisService 内部处理

#### 确定系统 Prompt

```java
// 工作台任务 + default 风格 → 使用简短系统提示
String systemPrompt = isWorkbenchTask(taskType) && "default".equals(style)
    ? "你是一个有帮助的AI助手。"
    : template.getSystemPrompt();  // 使用模板的完整系统提示
```

#### 构建用户 Prompt

- **如果是工作台任务（explain/exam/practice/explain_question/explain_knowledge/learning_profile/free_chat）**：
  - 如果风格是 feynman/first-principles/plato → `buildWorkbenchPrompt()`
  - 如果风格是 default → `buildDirectPrompt()`

**`buildWorkbenchPrompt()` 输出结构**：

```
你正在 408Master 的 AI 学习工作台中回答学生。请遵守：
1. 面向学生表达，不要暴露 RAG、向量检索、prompt、上下文注入等技术实现词。
2. 如果参考资料不足，要明确说明「不确定」，不要编造真题年份、题号或答案。
3. 数据库正确答案优先于数据库解析；数据库解析优先于知识点和参考资料；参考资料优先于模型常识。
4. 讲解要围绕 408 的四科：数据结构、组成原理、操作系统、计算机网络。
5. 只输出最终教学答案，不输出自我规划、草稿、元说明或「我需要/我将/现在我」的过程描述。
6. 当前讲法：{风格名}。

## 当前知识点
{knowledgePoints}

## 可参考资料
{referenceDocs}

## 学生请求
{question}

{风格输出规则}

## 输出要求
{任务特定输出要求}
```

**风格输出规则** (`buildStyleOutputRules()`)：

| 风格 | 追加规则 |
|------|----------|
| feynman | `用白话和简单类比讲清楚，先一句话概括，再用生活场景类比，最后回到题目本身。` |
| first-principles | `从最基本的定义和约束出发，一步步推导，少背结论，多说明为什么。` |
| plato | `用 2-3 个关键追问引导学生自己推出结论，每个追问后直接给出判断。` |

**任务特定输出要求**：

| 任务类型 | 追加规则 |
|----------|----------|
| `learning_profile` | 不要输出"题型与考点""选项分析""最终答案"。推荐格式：## 学习画像 / ## 当前优势 / ## 薄弱风险 / ## 下一步练习建议。结论必须来自学习统计。 |
| `practice` | 只能从题库已存在的题目中挑选 1-5 道，不能编造新题。推荐格式：## 选题目标 / ## 筛选条件 / ## 推荐题目 / ## 覆盖知识点。 |
| `explain_question` | 优先说明考点、关键推理、正确答案依据和易错原因。 |
| `explain_knowledge` | 优先说明定义、核心机制、常见考法和与当前题目的联系。 |
| 默认 | 根据学生问题选择最合适的结构，不要机械套固定模板。普通刷题优先短答案。 |

**风格名称映射**：

| style 值 | 显示名称 |
|-----------|----------|
| feynman | `费曼学习法，用白话、类比和反问帮助理解` |
| first-principles | `第一性原理，从定义和基本约束推导` |
| plato | `柏拉图式对话，用层层追问启发思考` |
| default | `常规解析，结构清楚、考点明确` |

**`buildDirectPrompt()` 输出结构**（default 风格工作台任务）：

```
知识点：{knowledgePoints}

参考资料：
{referenceDocs}

{userQuestion}
```

### 3.5 发送到 LLM 的最终 JSON

```json
{
  "model": "glm-4.5-air",
  "messages": [
    {
      "role": "system",
      "content": "你是一个有帮助的AI助手。"
    },
    {
      "role": "user",
      "content": "你正在 408Master 的 AI 学习工作台中回答学生。请遵守：\n1. 面向学生表达...\n...\n## 学生请求\n请围绕当前题目进行讲解。\n\n## 用户请求\n这道题选什么？\n\n用白话和简单类比讲清楚...\n\n## 输出要求\n- 优先说明考点、关键推理..."
    }
  ],
  "temperature": 0.7,
  "max_tokens": 4096,
  "stream": true
}
```

### 3.6 SSE 事件流

| 事件名 | 数据 | 时机 |
|--------|------|------|
| `status` | `"正在检索知识库资料..."` / `"AI 正在解析题目..."` 等 | 开始时 |
| `references` | `[{"title":"题#123: ...","similarity":"0.87","id":123}]` | RAG 检索完成 |
| `chunk` | 单个 token 字符串（逐字推送） | 流式回复中 |
| `done` | `"ok"` | 完成 |
| `error` | 错误消息 | 异常 |
| `agentDraft` | JSON（仅 practice_plan） | Agent 草案 |
| `paper` | JSON（仅 compose_paper） | 组卷结果 |

---

## 4. 场景二：题目分析页（同步/流式）

**入口**: `POST /api/student/ai/analyze` 或 `POST /api/student/ai/analyze-stream`
**控制器**: `AIAnalysisController`

### 4.1 请求 JSON

```json
{
  "style": "feynman",
  "taskType": "chat",
  "question": "某二叉树有5个度为2的节点，3个度为1的节点，则该二叉树的叶子节点数为？\nA. 5\nB. 6\nC. 7\nD. 8",
  "knowledgePoints": "二叉树的性质：n0 = n2 + 1",
  "aiType": "",
  "apiKey": "",
  "apiUrl": "",
  "model": ""
}
```

### 4.2 处理流程

1. **RAG 检索**：以 `question` 为查询，检索 top-5 相似文档
2. **如果用户提供了 apiKey**：使用 `analyzeWithCustomAI()` / `analyzeWithCustomAIStream()`
3. **否则**：使用后端配置的 provider
4. **Prompt 构建**：使用模板的 `formatUserPrompt()`，替换 `{question}` / `{knowledge_points_block}` / `{reference_docs}`
5. **System Prompt**：使用模板自身的 `systemPrompt`（非工作台，不覆盖）

### 4.3 生成的 Prompt 示例（feynman 风格）

**System**:
```
你是费曼学习法的践行者。你擅长把复杂的计算机概念翻译成大白话。...
```

**User**:
```
用费曼学习法的方式，把这道考研题讲得通俗易懂！

某二叉树有5个度为2的节点，3个度为1的节点，则该二叉树的叶子节点数为？
A. 5
B. 6
C. 7
D. 8

**相关知识点**：
二叉树的性质：n0 = n2 + 1

【费曼风格要求】：
1. 必须用生活中的例子类比...
...

**以下内容来自题库中的相关题目，请参考这些内容确保你的答案准确无误**：

## 参考资料（来自题库，供辅助参考）

【参考1】题#45: 二叉树性质...
...
```

---

## 5. 场景三：图片识别题目

**入口**: `POST /api/student/question/analyze-image`
**服务**: `QuestionServiceImpl.analyzeImageQuestion()`

### 5.1 请求

`multipart/form-data`，包含一个图片文件。

### 5.2 发送到 LLM 的 JSON

```json
{
  "model": "glm-4.6v",
  "messages": [
    {
      "role": "system",
      "content": "你是一个题目分析助手，需要识别图片中的所有题目内容。图片中可能包含多道题目，请逐一分析。对于每道题目，提取以下信息：题目类型（单选题、多选题、判断题、填空题、简答题）、题目内容（题干）、选项（如果有）、正确答案、解析（如果有）。请以JSON数组格式返回结果，数组中每个元素代表一道题目，不要包含任何多余的文字描述。"
    },
    {
      "role": "user",
      "content": [
        {
          "type": "text",
          "text": "请分析这张图片中的所有题目，以JSON数组格式返回"
        },
        {
          "type": "image_url",
          "image_url": {
            "url": "data:image/png;base64,iVBOR..."
          }
        }
      ]
    }
  ],
  "temperature": 0.7,
  "max_tokens": 8192
}
```

### 5.3 预期返回

```json
[
  {
    "questionType": "单选题",
    "content": "题干内容",
    "options": {"A": "选项A", "B": "选项B", "C": "选项C", "D": "选项D"},
    "correctAnswer": "C",
    "analysis": "解析内容"
  }
]
```

### 5.4 参数

| 参数 | GLM | OpenAI |
|------|-----|--------|
| model | `glm-4.6v` | `gpt-4o` |
| temperature | 0.7 | 0.7 |
| max_tokens | 8192 | 无限制 |

---

## 6. 场景四：快速文本分析

**入口**: `POST /api/student/question/analyze-question` 或 `analyze-question-stream`
**服务**: `QuestionServiceImpl.analyzeQuestion()`

### 6.1 请求参数

```
questionType: "单选题"
questionContent: "题干内容"
options: "A.xxx B.xxx C.xxx D.xxx"
correctAnswer: "C"
```

### 6.2 构建 User Prompt

```java
"直接给出答案，不要思考过程。分析以下题目，输出JSON格式，包含解题思路、知识点、易错点、答案解析四个字段，每个字段不超过50字。\n\n"
+ "题目：" + questionContent + "\n"
+ "选项：" + options + "\n"
+ "答案：" + correctAnswer + "\n"
+ "\nJSON输出："
```

### 6.3 发送到 LLM 的 JSON

```json
{
  "model": "glm-4.6v",
  "messages": [
    {
      "role": "system",
      "content": "快速分析题目，简短回答。"
    },
    {
      "role": "user",
      "content": "直接给出答案，不要思考过程。分析以下题目，输出JSON格式，包含解题思路、知识点、易错点、答案解析四个字段，每个字段不超过50字。\n\n题目：某二叉树...\n选项：A.5 B.6 C.7 D.8\n答案：B\n\nJSON输出："
    }
  ],
  "temperature": 0.9,
  "max_tokens": 1024
}
```

### 6.4 参数

| 参数 | 值 | 说明 |
|------|-----|------|
| model | `glm-4.6v` / `gpt-4o` | 比标准分析用更高参数的模型 |
| temperature | **0.9** | 高于其他场景，鼓励多样性 |
| max_tokens | **1024** | 限制输出长度，要求简洁 |

---

## 7. 场景五：TXT 文件题目导入

**服务**: `QuestionServiceImpl.callAiApiForTxtContent()`

### 7.1 System Prompt

```
你是一个题目分析助手，需要将txt文件中的题目分解为符合数据库格式的结构。每个题目需要包含：题目类型、学科ID、分数、年级、难度、正确答案、题目内容（包括题干、选项、解析等）。请以JSON格式返回分析结果，每个题目为一个JSON对象，包含所有必要字段。
```

### 7.2 发送到 LLM 的 JSON

```json
{
  "model": "glm-4.5-air",
  "messages": [
    {
      "role": "system",
      "content": "你是一个题目分析助手，需要将txt文件中的题目分解为符合数据库格式的结构..."
    },
    {
      "role": "user",
      "content": "{txt文件内容}"
    }
  ],
  "temperature": 0.7
}
```

### 7.3 参数

| 参数 | GLM | OpenAI |
|------|-----|--------|
| model | `glm-4.5-air` | `gpt-3.5-turbo` |
| temperature | 0.7 | 0.7 |
| max_tokens | 未设置 | 未设置 |

---

## 8. 场景六：RAG 知识库检索

**服务**: `RagService`

### 8.1 Embedding API 请求

当需要将查询文本转为向量时：

```json
{
  "model": "embedding-2",
  "input": "二叉树遍历的性质（截取前8000字符）"
}
```

**端点**: `POST {base_url}/embeddings`
**默认**: `https://open.bigmodel.cn/api/paas/v4/embeddings`

### 8.2 检索流程

1. 将查询文本调用 Embedding API 生成向量
2. 与数据库中所有带 embedding 的 `TextContent` 记算余弦相似度
3. 如果启用了 Qdrant (`ai.rag.vector.enabled=true`)，则通过 Qdrant 向量数据库检索
4. 取相似度 > 0.5 的 top-K 结果（默认 K=5）

### 8.3 参考资料格式化

```
## 参考资料（来自题库，供辅助参考）

【参考1】题#45: 二叉树性质题目内容...
{完整 content}

【参考2】题#78: 另一道相关题目...
{完整 content}
```

### 8.4 Provider 优先级（Embedding）

1. 用户私有密钥中有 `embeddingModel` 配置的
2. 公共 Provider 中有 `embeddingModel` 配置的
3. application.yml 默认（`ai.embedding.model: embedding-2`）

---

## 9. 场景七：Agent 草案 / 组卷

### 9.1 Agent 草案（`practice_plan` 意图）

**不调用 LLM**。直接查询题库：
- 根据科目、知识点、错题历史筛选候选题目
- 生成包含候选题目 ID、知识点、推荐理由的草案
- 通过 SSE `agentDraft` 事件返回

**返回 JSON 结构**：
```json
{
  "intent": "practice_plan",
  "status": "draft",
  "title": "AI限时练习-二叉树遍历",
  "candidateQuestionIds": [23, 45, 67],
  "fallbackKnowledgePoints": ["二叉树", "树与森林"],
  "reason": "根据你的错题记录和薄弱知识点...",
  "confirmText": "确认生成试卷",
  "runLogId": 123
}
```

### 9.2 确认组卷（`compose_paper` 意图）

**不调用 LLM**。根据草案中的题目 ID 或条件：
- 从题库选题，创建 `ExamPaper` + `TaskExam`
- 通过 SSE `paper` 事件返回

**返回 JSON 结构**：
```json
{
  "paperId": 456,
  "paperName": "AI限时练习-二叉树遍历",
  "url": "/exam/paper/456",
  "questionCount": 3,
  "minutes": 10,
  "questionIds": [23, 45, 67],
  "strategy": "错题优先+知识点覆盖"
}
```

---

## 10. 场景八：Admin 模板测试

**入口**: `POST /api/admin/ai-agent/template/{id}/test`
**服务**: `AiAgentServiceImpl.analyzeWithTemplate()`

### 10.1 流程

1. 从数据库加载 `AiPromptTemplate`（按 ID）
2. 加载模板关联的 `AiKnowledgeBase` 记录
3. 调用 `buildPromptWithKnowledgeBase()` 构建 prompt
4. 如果模板有关联知识库，追加参考知识：

```
{userPrompt}

【参考知识】
## 知识库条目标题1
{content}
来源：{sourceName} - {sourceAuthor}

## 知识库条目标题2
{content}
```

5. 调用 LLM API（使用模板自身配置的 `temperature` / `maxTokens`）

### 10.2 数据库模板 vs 文件模板

| 属性 | 文件模板（JSON） | 数据库模板（admin 管理） |
|------|------------------|--------------------------|
| 存储 | `resources/ai/prompts/analysis/*.json` | `t_ai_prompt_template` 表 |
| 加载 | 启动时加载到内存 | 按需从 DB 查询 |
| 使用场景 | 前台学生分析 | Admin 模板测试、Agent 调用 |
| 可编辑 | 需改代码重新部署 | 通过 Admin 界面实时修改 |
| 知识库 | 不关联 | 可关联 `AiKnowledgeBase` |

---

## 11. 后处理：cleanAiAnswer 清洗规则

所有 LLM 回答在返回前都会经过 `AnalysisService.cleanAiAnswer()` 清洗：

```java
// 1. 去除开头 "null" 前缀
cleaned.replaceFirst("^(?i)(?:null\\s*)+", "");

// 2. 去除自述式开头（如"好的，让我来分析..."）
cleaned.replaceFirst("(?s)^(好的，?)?\\s*(我需要|让我|现在我将|我将|我来)\\s*[^#\\n]*(?:\\n|。|：|:)+\\s*", "");

// 3. 去除自述式结尾（如"以上就是我完成的分析"）
cleaned.replaceFirst("(?s)\\s*(现在我已经完成|我已经完成|以上就是我|这样我就完成了)[^#]*$", "");

// 4. 去除空标题行
cleaned.replaceAll("(?m)^#\\s*$", "");
```

---

## 12. 模型参数总览

| 场景 | System Prompt | Temperature | Max Tokens | 模型 (GLM) | 模型 (OpenAI) |
|------|--------------|-------------|------------|------------|---------------|
| 工作台 (default 风格) | `你是一个有帮助的AI助手。` | 0.7 | 4096 | glm-4.5-air | gpt-4o |
| 工作台 (其他风格) | 模板 systemPrompt | 0.7 | 4096 | glm-4.5-air | gpt-4o |
| 题目分析页 | 模板 systemPrompt | 0.7 | 4096 | glm-4.5-air | gpt-4o |
| 图片识别 | `你是一个题目分析助手...` | 0.7 | 8192 | **glm-4.6v** | gpt-4o |
| 快速文本分析 | `快速分析题目，简短回答。` | **0.9** | **1024** | **glm-4.6v** | gpt-4o |
| TXT 导入 | `你是一个题目分析助手...` | 0.7 | 无限制 | glm-4.5-air | **gpt-3.5-turbo** |
| Admin 模板测试 | 模板 systemPrompt | 模板配置 | 模板配置 | glm-4.5-air | gpt-4o |
| 兜底 | `你是一个专业的计算机考研408辅导老师。` | 0.7 | 4096 | glm-4.5-air | gpt-4o |

---

## 13. API 请求 JSON 结构参考

### 13.1 标准 Chat Completions 请求

```json
POST {base_url}/chat/completions
Authorization: Bearer {api_key}
Content-Type: application/json

{
  "model": "glm-4.5-air",
  "messages": [
    {"role": "system", "content": "{system_prompt}"},
    {"role": "user", "content": "{user_prompt}"}
  ],
  "temperature": 0.7,
  "max_tokens": 4096,
  "stream": false
}
```

### 13.2 流式 Chat Completions 请求

```json
{
  "model": "glm-4.5-air",
  "messages": [
    {"role": "system", "content": "{system_prompt}"},
    {"role": "user", "content": "{user_prompt}"}
  ],
  "temperature": 0.7,
  "max_tokens": 4096,
  "stream": true
}
```

### 13.3 Vision 请求（图片识别）

```json
{
  "model": "glm-4.6v",
  "messages": [
    {"role": "system", "content": "你是一个题目分析助手..."},
    {
      "role": "user",
      "content": [
        {"type": "text", "text": "请分析这张图片中的所有题目..."},
        {"type": "image_url", "image_url": {"url": "data:image/png;base64,..."}}
      ]
    }
  ],
  "temperature": 0.7,
  "max_tokens": 8192
}
```

### 13.4 Embedding 请求

```json
POST {base_url}/embeddings
Authorization: Bearer {api_key}
Content-Type: application/json

{
  "model": "embedding-2",
  "input": "二叉树遍历的性质"
}
```

### 13.5 SSE 响应格式（流式）

```
data: {"choices":[{"delta":{"content":"这"},"index":0}]}

data: {"choices":[{"delta":{"content":"道"},"index":0}]}

data: {"choices":[{"delta":{"content":"题"},"index":0}]}

data: [DONE]
```

---

## 附录：SSE 事件时序图（工作台）

```
前端                           后端                            LLM
 │                              │                              │
 │──POST /workbench/stream─────→│                              │
 │                              │──resolve intent──→           │
 │                              │──build context text──→       │
 │                              │──RAG retrieve (if needed)──→ │
 │←──SSE: status───────────────│                              │
 │←──SSE: references───────────│                              │
 │                              │──POST /chat/completions─────→│
 │←──SSE: status───────────────│                              │
 │                              │←──SSE: data: {"delta":...}──│
 │←──SSE: chunk ("这")─────────│                              │
 │←──SSE: chunk ("道")─────────│                              │
 │←──SSE: chunk ("题")─────────│                              │
 │      ... (逐字流式)          │                              │
 │                              │←──SSE: data: [DONE]─────────│
 │←──SSE: done ("ok")──────────│                              │
 │                              │──save usage log──→           │
```
