# UML 标准判断学习档案

这份档案的目标不是教你写代码，也不是让你背工具语法，而是让你能判断一张图“是不是标准 UML”“哪里不标准”“应该怎么改得更标准”。

## 1. 先记住一句话

UML 的核心不是画得漂亮，而是：

> 用规定好的图形符号，准确表达系统中的角色、功能、结构、交互和部署。

所以判断 UML 标准不标准，先看三件事：

1. 图类型是否明确。
2. 图中的元素符号是否符合该图类型。
3. 关系线是否有明确语义。

如果一张图只是把方框和箭头堆在一起，即使很好看，也只能叫“架构示意图”，不能直接叫标准 UML。

## 2. 类图中英文怎么用

### 推荐原则

类图里建议：

| 内容 | 推荐语言 | 原因 |
|---|---|---|
| 类名 | 英文 | 类名通常对应代码、数据库、领域模型，英文更稳定 |
| 属性名 | 英文 | 属性常对应字段或对象属性，英文更接近实现 |
| 方法名 | 英文 | 方法是行为抽象，英文更接近代码和标准写法 |
| 关系说明 | 中文或英文都可 | 面向答辩可以中文，面向工程协作可以英文 |
| 图标题 | 中文 | 给评审/学生看更直观 |
| 注释说明 | 中文 | 帮助讲解业务含义 |

### 本项目建议

本项目的类图建议这样：

```text
类名：Question、Student、ExamPaper、KnowledgePoint
属性：id、title、sourceYear、questionType、mastery
方法：answer()、isActive()、calculateMastery()
关系说明：包含、关联、生成、引用
```

也就是：

```text
英文表达模型，中文解释业务。
```

### 为什么类名不要全中文

不推荐：

```text
题目
学生
试卷
知识点
错题本
```

原因：

1. 标准 UML 当然允许中文，但工程类图通常和代码、数据库、接口关联。
2. 中文类名不利于和实际类、表、接口对照。
3. 后续如果导入 PlantUML、IDE、文档系统，英文更稳。

### 什么时候可以用中文类名

可以用于：

1. 需求阶段的概念草图。
2. 非技术评审场景。
3. 用户故事、业务流程讲解。

但如果你说这是“领域类图”或“设计类图”，建议类名仍用英文。

## 3. UML 常见图类型速查

| 图类型 | 看什么 | 标准元素 | 常见错误 |
|---|---|---|---|
| 用例图 | 谁使用系统，系统提供什么目标 | Actor、Use Case、System Boundary、include、extend | 把数据库、Controller、页面画成用例 |
| 类图 | 业务对象/类的结构和关系 | Class、attribute、method、association、composition、多重性 | 只有方框没有属性方法；多对多没有中间对象 |
| 时序图 | 一次流程中对象如何交互 | participant、lifeline、message、return、alt、loop | 画成流程图；没有返回消息；多个场景塞一张图 |
| 组件图 | 模块边界和依赖 | component、interface、dependency、package | 把类、表、服务器混在同层 |
| 部署图 | 软件部署在哪里 | node、artifact、database、communication path | 把业务类画进部署图 |
| 活动图 | 业务流程/算法流程 | action、decision、merge、fork、join、start/end | 用普通流程图代替但不标分支/并发语义 |
| 状态机图 | 一个对象状态如何变化 | state、transition、event、guard | 把整个业务流程误画成状态图 |

## 4. 判断一张 UML 是否标准的总流程

看图时按这个顺序问：

### 第一步：它是什么图？

一张图必须能回答：

```text
这是用例图？类图？时序图？组件图？部署图？
```

如果回答不出来，它多半不是标准 UML，而是普通架构图。

### 第二步：元素符号对吗？

例如：

- 用例图里用户应是 Actor，用例应是椭圆。
- 类图里类应分成类名、属性、方法三层。
- 时序图里应有垂直生命线和水平消息。
- 部署图里应有节点、容器、制品。

### 第三步：关系线语义对吗？

UML 里线不是装饰，它有语义。

| 线/箭头 | 常见含义 |
|---|---|
| 实线关联 | A 与 B 有结构关系 |
| 虚线依赖 | A 使用 B，但不是强拥有 |
| 空心三角 | 继承/泛化 |
| 空心菱形 | 聚合，弱整体-部分 |
| 实心菱形 | 组合，强整体-部分 |
| `<<include>>` | 用例必然包含另一个用例 |
| `<<extend>>` | 用例在条件下扩展另一个用例 |

如果一张图所有线都是箭头，那通常不够标准。

## 5. 类图标准判断

类图是你这个项目最容易画错、也最值得学的一类。

### 标准类图至少应该有

1. 类名。
2. 属性。
3. 方法。
4. 类之间关系。
5. 多重性。

例如：

```text
Question
---------
+id: Integer
+title: Text
+sourceYear: Integer
---------
+isActive(): Boolean
```

### 类图中关系怎么判断

#### 关联 Association

表示两个类之间有普通关系。

```text
Student "1" -- "0..*" AnswerRecord
```

意思是：

一个学生可以有多条答题记录。

#### 组合 Composition

实心菱形，强生命周期绑定。

```text
Question "1" *-- "1..*" QuestionContent
```

意思是：

题目拥有题目内容版本，题目不存在时内容版本也失去意义。

#### 聚合 Aggregation

空心菱形，弱整体-部分。

聚合在实际建模中容易滥用。你不确定时，宁可用普通关联。

#### 多对多

多对多最好用中间类。

不够标准：

```text
Question "*" -- "*" KnowledgePoint
```

更标准：

```text
Question "1" -- "0..*" QuestionKnowledgePoint
KnowledgePoint "1" -- "0..*" QuestionKnowledgePoint
```

因为中间关系通常还有来源、权重、置信度等属性。

## 6. 用例图标准判断

### 用例图看目标，不看实现

标准用例图里应该出现：

```text
学生
管理员
刷题
提交答案
查看错题本
配置 AI Provider
```

不应该出现：

```text
Vue
Controller
MySQL
Qdrant
RagService
```

这些是实现，不是用户目标。

### include 和 extend 怎么判断

`include` 是必然发生：

```text
提交答案 include 保存答题记录
```

但注意，“保存答题记录”如果不是用户目标，不一定要画进用例图。

`extend` 是可选发生：

```text
查看 AI 解析 extend 做题
```

意思是做题后可以选择看 AI 解析，但不是必然。

## 7. 时序图标准判断

标准时序图必须有时间顺序。

你应该看到：

1. 上方横向排列参与者。
2. 每个参与者下面有生命线。
3. 消息从上到下发生。
4. 有调用和返回。
5. 有条件分支时使用 `alt`。
6. 有循环时使用 `loop`。

例如 AI/RAG：

```text
学生 -> 前端 -> 后端 -> RagService -> Qdrant -> MySQL -> AI Provider
```

如果一张图只是：

```text
前端 -> 后端 -> 数据库
```

但没有时间顺序、返回、分支，它更像组件交互图，不是完整时序图。

## 8. 组件图标准判断

组件图讲“模块边界”，不是讲类，也不是讲服务器。

适合出现：

```text
Student Web Client
Admin Web Client
Student API Controllers
Question Application Service
RAG Application Service
MySQL Repository Adapter
AI Provider Client
```

不建议同一层同时出现：

```text
Question 类
t_question 表
Nginx 容器
某个按钮
某个 Controller 方法
```

这叫抽象层级混乱。

### 判断抽象层级一致

问一句：

> 这些节点是不是同一种粒度？

如果一张组件图里同时有“Vue 管理端”“QuestionService”“t_question.title 字段”，那就不标准。

## 9. 部署图标准判断

部署图只讲运行环境和部署关系。

适合出现：

```text
User Browser
Nginx Container
Backend Container
MySQL Container
Qdrant Container
AI Provider API
xzs-3.9.0.jar
static files
```

不适合出现：

```text
Question
StudentKnowledgeState
MistakeBook
```

这些是领域对象，应在类图里。

## 10. “像 UML 但不标准”的常见情况

### 1. Flowchart 冒充用例图

如果用 `flowchart LR` 画：

```text
学生 --> 刷题
管理员 --> 管理题库
```

它可以叫“用例视图”，但不是严格 UML 用例图。

### 2. ClassDiagram 冒充组件图

如果用类图语法加 `<<component>>`：

```text
class StudentClient {
  <<component>>
}
```

这只能算模拟组件图。严格组件图应该用 component 符号。

### 3. 类图只有关系没有属性

例如：

```text
Question --> KnowledgePoint
Student --> MistakeBook
```

这叫领域关系图，不是完整类图。

### 4. 部署内容混进领域类图

如果类图里出现：

```text
Nginx
Docker
Qdrant
MySQL
```

通常不标准。它们应该放部署图或组件图。

## 11. 本项目 UML 学习路线

建议按这个顺序学：

### 第一阶段：会分图

目标：

```text
看到一张图，能说出它应该属于哪类 UML。
```

练习：

- 用户目标：用例图。
- 模块边界：组件图。
- 一次 AI 请求过程：时序图。
- 题目/学生/知识点关系：类图。
- Docker/Nginx/MySQL/Qdrant：部署图。

### 第二阶段：会看符号

目标：

```text
能判断符号有没有用错。
```

练习：

- Actor 是不是用户角色？
- Use Case 是不是椭圆目标？
- Class 有没有属性方法？
- Component 是否是模块？
- Node 是否是运行环境？

### 第三阶段：会看关系

目标：

```text
能判断关系线有没有语义。
```

练习：

- 多对多是否需要中间类？
- 组合是否真的有生命周期绑定？
- 依赖是否只是调用？
- include/extend 是否被滥用？

### 第四阶段：会看真实性

目标：

```text
能判断图是否和真实项目一致。
```

练习：

- Qdrant 当前代码是否真实接入？
- AiAgent/AiSkill 是已落地、部分落地，还是规划？
- RAG 文档和 chunk 是否存在对应表？
- 试卷和题目是否真有中间关系？

## 12. 你的项目里怎么讲 UML

答辩时可以这样说：

> 我把 UML 分成五类来讲。用例图说明系统对学生、管理员、开发者分别提供什么能力；组件图说明当前是模块化单体，而不是微服务；时序图说明一次 AI/RAG 请求如何流转；类图说明题目、知识点、学生学习状态和 RAG 元数据的领域关系；部署图说明 Nginx、后端、MySQL、Qdrant 和外部模型 API 的运行拓扑。

这段话很稳，因为它体现了你知道：

1. UML 图不是随便画。
2. 不同图解决不同问题。
3. 业务、模块、流程、部署不能混在一起。

## 13. 最终判断口诀

看到一张 UML 图，问八个问题：

1. 这是什么图？
2. 它解决什么问题？
3. 图中元素符号对吗？
4. 关系线语义对吗？
5. 抽象层级一致吗？
6. 类图有没有属性、方法、多重性？
7. 部署内容有没有单独放部署图？
8. 图中内容是否真实对应当前系统？

能经得住这八问，这张 UML 图基本就标准。
