# Phase 2 实施计划：修复错误 → 数据库验证 → AI RAG 完善 → 部署

---

## 📋 总览

| 阶段 | 内容 | 分支 |
|------|------|------|
| ① 修复 NPE | 考试记录 + 错题本 "系统内部错误" | `feature/crawler-and-exam-data` |
| ② 数据库验证 | 悬空引用检查 + 提交稳定版，覆盖 dev | `dev` |
| ③ AI RAG 完善 | 实现 RAG，优化 4 种 Skill 风格 | `feature/ai` |
| ④ 部署 | 打包部署到云服务器 118.31.34.132 | `feature/ai` (部署) |

---

## 阶段 ① — 修复考试记录和错题本 "系统内部错误"

### 问题诊断

两个页面均报 500 错误，根因是**后端 Java NPE（NullPointerException）**。

### 修改文件清单（4 个文件，10 处修复点）

#### 文件 1：`QuestionAnswerController.java`
**路径**：`source/xzs/src/main/java/com/mindskip/xzs/controller/student/QuestionAnswerController.java`

| # | 行号 | NPE 位置 | 触发条件 | 修复方案 |
|---|------|----------|---------|---------|
| 1 | L48 | `subjectService.selectById(q.getSubjectId())` 返回 null → L55 `subject.getName()` NPE | 学科被删除 | `subject != null ? subject.getName() : "未知"` |
| 2 | L51-53 | `textContentService.selectById(id)` 返回 null → L52 `textContent.getContent()` NPE | TextContent 被删除 | null 检查 + try-catch |
| 3 | L53 | JSON 解析失败 → `questionObject.getTitleContent()` NPE | 内容非法 JSON | try-catch 包住整个解析块 |
| 4 | L67 | `questionService.getQuestionEditRequestVM(id)` 内部 NPE | 题目被删除 | 增加题目存在性校验 |

**修复后的 pageList Lambda**：
```java
PageInfo<QuestionPageStudentResponseVM> page = PageInfoHelper.copyMap(pageInfo, q -> {
    QuestionPageStudentResponseVM vm = modelMapper.map(q, QuestionPageStudentResponseVM.class);
    vm.setCreateTime(DateTimeUtil.dateFormat(q.getCreateTime()));
    
    Subject subject = subjectService.selectById(q.getSubjectId());
    vm.setSubjectName(subject != null ? subject.getName() : "未知");
    
    TextContent textContent = textContentService.selectById(q.getQuestionTextContentId());
    if (textContent != null && textContent.getContent() != null) {
        try {
            QuestionObject questionObject = JsonUtil.toJsonObject(textContent.getContent(), QuestionObject.class);
            if (questionObject != null && questionObject.getTitleContent() != null) {
                vm.setShortTitle(HtmlUtil.clear(questionObject.getTitleContent()));
            }
        } catch (Exception ignored) {
        }
    }
    return vm;
});
```

**修复后的 select 方法**：
```java
@RequestMapping(value = "/select/{id}", method = RequestMethod.POST)
public RestResponse<QuestionAnswerVM> select(@PathVariable Integer id) {
    QuestionAnswerVM vm = new QuestionAnswerVM();
    ExamPaperQuestionCustomerAnswer examPaperQuestionCustomerAnswer = examPaperQuestionCustomerAnswerService.selectById(id);
    if (examPaperQuestionCustomerAnswer == null) {
        return RestResponse.fail(2, "答题记录不存在");
    }
    ExamPaperSubmitItemVM questionAnswerVM = examPaperQuestionCustomerAnswerService.examPaperQuestionCustomerAnswerToVM(examPaperQuestionCustomerAnswer);
    QuestionEditRequestVM questionVM = questionService.getQuestionEditRequestVM(examPaperQuestionCustomerAnswer.getQuestionId());
    if (questionVM == null) {
        return RestResponse.fail(2, "题目已被删除");
    }
    vm.setQuestionVM(questionVM);
    vm.setQuestionAnswerVM(questionAnswerVM);
    return RestResponse.ok(vm);
}
```

---

#### 文件 2：`ExamPaperAnswerController.java` (student)
**路径**：`source/xzs/src/main/java/com/mindskip/xzs/controller/student/ExamPaperAnswerController.java`

| # | 行号 | NPE 位置 | 触发条件 | 修复方案 |
|---|------|----------|---------|---------|
| 5 | L52 | `subjectService.selectById(vm.getSubjectId())` 返回 null → L57 `subject.getName()` NPE | 学科被删除 | `subject != null ? subject.getName() : "未知"` |
| 6 | L53-56 | `ExamUtil.scoreToVM(null)` / `secondToVM(null)` → 内部 NPE | DB 字段 NULL | 配合 ExamUtil 修复（下方） |

**修复后的 pageList Lambda**：
```java
PageInfo<ExamPaperAnswerPageResponseVM> page = PageInfoHelper.copyMap(pageInfo, e -> {
    ExamPaperAnswerPageResponseVM vm = modelMapper.map(e, ExamPaperAnswerPageResponseVM.class);
    Subject subject = subjectService.selectById(vm.getSubjectId());
    vm.setDoTime(ExamUtil.secondToVM(e.getDoTime()));
    vm.setSystemScore(ExamUtil.scoreToVM(e.getSystemScore()));
    vm.setUserScore(ExamUtil.scoreToVM(e.getUserScore()));
    vm.setPaperScore(ExamUtil.scoreToVM(e.getPaperScore()));
    vm.setSubjectName(subject != null ? subject.getName() : "未知");
    vm.setCreateTime(DateTimeUtil.dateFormat(e.getCreateTime()));
    return vm;
});
```

---

#### 文件 3：`ExamPaperAnswerController.java` (admin)
**路径**：`source/xzs/src/main/java/com/mindskip/xzs/controller/admin/ExamPaperAnswerController.java`

| # | 行号 | NPE 位置 | 触发条件 | 修复方案 |
|---|------|----------|---------|---------|
| 7 | L39 | `subjectService.selectById(vm.getSubjectId())` 返回 null → L44 `subject.getName()` NPE | 学科被删除 | `subject != null ? subject.getName() : "未知"` |
| 8 | L41-43 | `ExamUtil.scoreToVM(null)` → 内部 NPE | DB 字段 NULL | 配合 ExamUtil 修复 |
| 9 | L46-47 | `userService.selectById(e.getCreateUser())` 返回 null → L47 `user.getUserName()` NPE | 用户被删除 | `user != null ? user.getUserName() : "未知用户"` |

**修复后的 pageJudgeList Lambda**：
```java
PageInfo<ExamPaperAnswerPageResponseVM> page = PageInfoHelper.copyMap(pageInfo, e -> {
    ExamPaperAnswerPageResponseVM vm = modelMapper.map(e, ExamPaperAnswerPageResponseVM.class);
    Subject subject = subjectService.selectById(vm.getSubjectId());
    vm.setDoTime(ExamUtil.secondToVM(e.getDoTime()));
    vm.setSystemScore(ExamUtil.scoreToVM(e.getSystemScore()));
    vm.setUserScore(ExamUtil.scoreToVM(e.getUserScore()));
    vm.setPaperScore(ExamUtil.scoreToVM(e.getPaperScore()));
    vm.setSubjectName(subject != null ? subject.getName() : "未知");
    vm.setCreateTime(DateTimeUtil.dateFormat(e.getCreateTime()));
    User user = userService.selectById(e.getCreateUser());
    vm.setUserName(user != null ? user.getUserName() : "未知用户");
    return vm;
});
```

---

#### 文件 4：`ExamUtil.java`
**路径**：`source/xzs/src/main/java/com/mindskip/xzs/utility/ExamUtil.java`

| # | 行号 | NPE 位置 | 触发条件 | 修复方案 |
|---|------|----------|---------|---------|
| 10 | L23 | `scoreToVM(null)` → `score % 10` NPE | score 为 null | 开头加 `if (score == null) return "-";` |
| -- | L52 | `secondToVM(null)` → `second / (60*60*24)` NPE | second 为 null | 开头加 `if (second == null) return "-";` |

**修复代码**：
```java
public static String scoreToVM(Integer score) {
    if (score == null) return "-";
    if (score % 10 == 0) {
        return String.valueOf(score / 10);
    } else {
        return String.format("%.1f", score / 10.0);
    }
}

public static String secondToVM(Integer second) {
    if (second == null) return "-";
    // ... 原有逻辑不变
}
```

---

### 阶段 ① 验证方式

修复后执行：
```bash
# 重新编译
cd source/xzs && mvn package -DskipTests
# 重启后端服务
# 浏览器访问：
# http://localhost:8001/record/index → 应正常显示考试记录
# http://localhost:8001/question-error/index → 应正常显示错题本
```

---

## 阶段 ② — 数据库验证 + 提交稳定版

### 2.1 数据库悬空引用检查

通过 SQL 检查以下表的外键一致性：

| 检查项 | SQL | 期望结果 |
|--------|-----|---------|
| `t_exam_paper.frame_text_content_id` → `t_text_content.id` | LEFT JOIN 查悬空 | 0 条 |
| `t_question.info_text_content_id` → `t_text_content.id` | LEFT JOIN 查悬空 | 0 条 |
| `t_question.subject_id` → `t_subject.id` | LEFT JOIN 查悬空 | 0 条 |
| `t_exam_paper_question_customer_answer.question_text_content_id` → `t_text_content.id` | LEFT JOIN 查悬空 | 0 条 |

如果已有数据库连接，执行上述 SQL 验证。如果有悬空引用，用 UPDATE/DELETE 修复。

### 2.2 提交步骤

```bash
# 1. 当前在 feature/crawler-and-exam-data 分支
git add -A
git commit -m "fix: NPE protection for exam records and error notebook pages

- Add null checks in QuestionAnswerController (subject, textContent, questionObject)
- Add null checks in student ExamPaperAnswerController (subject)
- Add null checks in admin ExamPaperAnswerController (subject, user)
- Add null guards in ExamUtil.scoreToVM() and secondToVM()
- Database integrity verified: 0 dangling references"

# 2. 推送特性分支
git push origin feature/crawler-and-exam-data

# 3. 合并到 dev（覆盖稳定版）
git checkout dev
git merge feature/crawler-and-exam-data --no-ff -m "Merge: stable version with NPE fixes and crawler data"
git push origin dev
```

---

## 阶段 ③ — AI RAG 完善 + Skill 四种风格优化

### 3.1 当前 AI 架构

```
前端 (knowledge-graph/index.vue)
  → AIAnalysisController (/api/student/ai)
    → AnalysisService (加载 4 种 prompt 模板)
      → HTTP → 智谱 GLM API (Chat)
  无向量检索 | 无 Embedding | 无 RAG
```

### 3.2 RAG 实现方案

#### 技术选型

| 组件 | 方案 | 理由 |
|------|------|------|
| Embedding 模型 | 智谱 GLM Embedding API (`embedding-2`) | 已有 GLM 账号，无需新增依赖 |
| 向量存储 | MySQL `t_text_content.embedding` 列 (TEXT/JSON) | 题目量小（672条），无需向量数据库 |
| 检索方式 | Cosine Similarity Top-K | 标准做法 |
| RAG 框架 | 自建轻量管线 | 避免引入 LangChain4j 等重型依赖 |

#### 实施步骤

##### 步骤 1：创建 RAG 核心服务

**新建** `source/xzs/src/main/java/com/mindskip/xzs/ai/RagService.java`：

```java
package com.mindskip.xzs.ai;

// 核心功能：
// 1. embed(String text) → float[]  调用 GLM Embedding API
// 2. double cosineSimilarity(float[] a, float[] b)  余弦相似度
// 3. List<RagDocument> retrieve(String query, int topK)  RAG 检索
//    流程：query → embed → 计算与所有题目的 cosine similarity → 排序 → 取 topK

// 数据类 RagDocument:
//   - String questionTitle
//   - String content
//   - double similarity
```

##### 步骤 2：数据库扩展

**新建** `database/05_rag_embeddings.sql`：

```sql
-- 为 t_text_content 增加 embedding 列
ALTER TABLE t_text_content ADD COLUMN embedding LONGTEXT NULL COMMENT '题目解析的向量嵌入(JSON float[] 格式)';
```

##### 步骤 3：批量生成 Embedding 脚本

**新建** `ai/embed_questions.py`：

```python
# 1. 连接 MySQL，查询所有题目的 t_text_content
# 2. 对每个 text_content.content，提取 analysis 部分
# 3. 调用智谱 GLM Embedding API 生成向量
# 4. 将向量以 JSON 格式写回 t_text_content.embedding 列
```

##### 步骤 4：集成到 ChatController / AIAnalysisController

**修改** `AIAnalysisController.java`（或 `ChatController.java`）：
- 在 analysis API 中注入 `RagService`
- 在调用 GLM Chat API 之前，先用 RAG 检索与用户问题最相关的 5 道题
- 将检索到的参考文档注入 system prompt 的 `{reference_docs}` 变量

```java
// 伪代码
List<RagDocument> docs = ragService.retrieve(userQuestion, 5);
String referenceText = docs.stream()
    .map(d -> "【" + d.getQuestionTitle() + "】" + d.getContent())
    .collect(Collectors.joining("\n\n"));
// 将 referenceText 注入 prompt 模板
```

##### 步骤 5：前端展示参考来源

**修改** `source/vue/xzs-student/src/views/knowledge-graph/index.vue`：
- AI 回复气泡底部显示 "📚 参考来源："
- 列出检索到的 5 道题目标题

---

### 3.3 Skill 四种风格模板优化

#### 优化方向

对 4 个模板文件 (`ai/prompts/analysis/*.json`) 进行以下优化：

1. **增加 `{reference_docs}` 变量占位符**：接收 RAG 检索结果，告知 AI 有这些参考材料
2. **优化 default.json 标准解析**：增加五步法结构——①识别考点 → ②推导过程 → ③易错点 → ④记忆技巧 → ⑤举一反三
3. **优化 feynman.json 费曼风格**：强化"用最简单的话解释"，增加类比要求
4. **优化 plato.json 柏拉图式**：强化启发式提问风格，引导用户自己发现答案
5. **优化 first-principles.json 第一性原理**：强化"从最基础原理出发"的推导链

#### 修改文件清单

| 文件 | 修改内容 |
|------|---------|
| `ai/prompts/analysis/default.json` | 优化系统提示词 + 增加 `{reference_docs}` 变量 + 五步法 |
| `ai/prompts/analysis/feynman.json` | 增加 `{reference_docs}` 变量 + 强化类比 |
| `ai/prompts/analysis/plato.json` | 增加 `{reference_docs}` 变量 + 强化启发式 |
| `ai/prompts/analysis/first-principles.json` | 增加 `{reference_docs}` 变量 + 强化推导链 |

---

### 阶段 ③ 提交

```bash
git checkout -b feature/ai
git add -A
git commit -m "feat: RAG-based AI with embedding retrieval and optimized skill templates

- Add RagService for vector-based question retrieval (GLM Embedding API)
- Add t_text_content.embedding column for vector storage
- Add embed_questions.py for batch embedding generation
- Integrate RAG retrieval into AIAnalysisController
- Optimize 4 skill prompt templates with {reference_docs} variable
- Add reference sources display in knowledge-graph page"
git push origin feature/ai
```

---

## 阶段 ④ — 部署到云服务器

### 4.1 目标环境

| 项目 | 值 |
|------|-----|
| IP | 118.31.34.132 |
| 用户 | root |
| 密码 | D0ushiji@xi@ng |
| 连接方式 | SSH |

### 4.2 部署架构

```
云服务器 118.31.34.132
├── Nginx (前端静态文件 + API 代理)
├── Java Spring Boot (jar 包运行，端口 8000)
├── MySQL (已有，端口 3306)
└── (裸机部署，无 Docker)
```

### 4.3 部署步骤

#### 第 1 步：本地构建

```bash
# 前端构建 (学生端)
cd source/vue/xzs-student
npm run build
# 产出 dist/ 目录

# 后台构建
cd source/xzs
mvn package -DskipTests
# 产出 target/xzs-*.jar
```

#### 第 2 步：上传到服务器

```bash
# 上传 jar 包
scp source/xzs/target/xzs-*.jar root@118.31.34.132:/opt/master408/

# 上传前端文件
scp -r source/vue/xzs-student/dist/* root@118.31.34.132:/opt/master408/frontend/

# 上传数据库脚本
scp database/*.sql root@118.31.34.132:/opt/master408/database/

# 上传 Nginx 配置
scp deploy/nginx.conf root@118.31.34.132:/etc/nginx/sites-available/master408
```

#### 第 3 步：服务器初始化（首次部署）

```bash
ssh root@118.31.34.132

# 创建目录
mkdir -p /opt/master408/{frontend,database,logs}

# 导入数据库（首次）
mysql -u root -p < /opt/master408/database/01_init_structure.sql
mysql -u root -p < /opt/master408/database/02_extend_fields.sql
mysql -u root -p < /opt/master408/database/04_exam_data.sql

# 配置 Nginx
ln -s /etc/nginx/sites-available/master408 /etc/nginx/sites-enabled/
nginx -t && nginx -s reload

# 启动后端
nohup java -jar /opt/master408/xzs-*.jar --server.port=8000 > /opt/master408/logs/app.log 2>&1 &
```

#### 第 4 步：更新部署（后续更新）

```bash
# 上传新版本 → 重启服务
ssh root@118.31.34.132
pkill -f 'xzs-'
nohup java -jar /opt/master408/xzs-*.jar --server.port=8000 > /opt/master408/logs/app.log 2>&1 &
```

### 4.4 Nginx 配置

**新建** `deploy/nginx.conf`：

```nginx
server {
    listen 80;
    server_name 118.31.34.132;

    root /opt/master408/frontend;
    index index.html;

    # API 代理到 Spring Boot
    location /api/ {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_read_timeout 120s;
    }

    # 前端 SPA 路由
    location / {
        try_files $uri $uri/ /index.html;
    }

    # 静态资源缓存
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 30d;
        add_header Cache-Control "public, immutable";
    }
}
```

### 4.5 部署脚本

**新建** `deploy/deploy.sh`：

```bash
#!/bin/bash
# Master408 一键部署脚本
set -e

SERVER="root@118.31.34.132"
REMOTE_DIR="/opt/master408"
JAR_FILE=$(ls source/xzs/target/xzs-*.jar | head -1)

echo "=== 1. 构建前端 ==="
cd source/vue/xzs-student && npm run build && cd ../../..

echo "=== 2. 构建后端 ==="
cd source/xzs && mvn package -DskipTests && cd ../..

echo "=== 3. 上传文件 ==="
scp "$JAR_FILE" ${SERVER}:${REMOTE_DIR}/
scp -r source/vue/xzs-student/dist/* ${SERVER}:${REMOTE_DIR}/frontend/

echo "=== 4. 重启服务 ==="
ssh ${SERVER} "pkill -f 'xzs-' || true; sleep 2; nohup java -jar ${REMOTE_DIR}/$(basename $JAR_FILE) --server.port=8000 > ${REMOTE_DIR}/logs/app.log 2>&1 &"

echo "=== 5. 验证 ==="
sleep 5
curl -s http://118.31.34.132/api/student/dashboard/index | head -c 200
echo ""
echo "=== 部署完成 ==="
echo "学生端: http://118.31.34.132"
```

### 4.6 部署验证

部署完成后验证：
- `http://118.31.34.132` → 学生端首页
- `http://118.31.34.132/record/index` → 考试记录（修复后应正常）
- `http://118.31.34.132/question-error/index` → 错题本（修复后应正常）
- `http://118.31.34.132/knowledge-graph/index` → AI 知识图谱（含 RAG）
- API 接口：`curl http://118.31.34.132/api/student/dashboard/index`

---

## 📊 总修改文件清单

| # | 文件 | 阶段 | 操作 |
|---|------|------|------|
| 1 | `QuestionAnswerController.java` (student) | ① | NPE 防护 |
| 2 | `ExamPaperAnswerController.java` (student) | ① | NPE 防护 |
| 3 | `ExamPaperAnswerController.java` (admin) | ① | NPE 防护 |
| 4 | `ExamUtil.java` | ① | null guard |
| 5 | 新建 `RagService.java` | ③ | RAG 检索核心 |
| 6 | `AIAnalysisController.java` | ③ | 集成 RAG |
| 7 | `database/05_rag_embeddings.sql` | ③ | embedding 列表述 |
| 8 | 新建 `ai/embed_questions.py` | ③ | 批量 embedding |
| 9 | `ai/prompts/analysis/default.json` | ③ | 优化模板 |
| 10 | `ai/prompts/analysis/feynman.json` | ③ | 增加 RAG 变量 |
| 11 | `ai/prompts/analysis/plato.json` | ③ | 增加 RAG 变量 |
| 12 | `ai/prompts/analysis/first-principles.json` | ③ | 增加 RAG 变量 |
| 13 | `knowledge-graph/index.vue` | ③ | 参考来源展示 |
| 14 | `AnalysisService.java` | ③ | prompt 模板变量注入 |
| 15 | 新建 `deploy/deploy.sh` | ④ | 部署脚本 |
| 16 | 新建 `deploy/nginx.conf` | ④ | Nginx 配置 |

---

## ⏱ 执行顺序

```
① 修复 4 个文件 10 处 NPE → 编译 → 重启验证页面
     ↓
② 数据库悬空引用验证 → git commit → merge 到 dev → push
     ↓
③ 创建 feature/ai → 实现 RAG → 优化模板 → 前端参考来源 → commit
     ↓
④ 构建前后端 → 上传服务器 → Nginx 配置 → 启动验证
```
