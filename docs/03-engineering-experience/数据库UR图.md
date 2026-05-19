# 408Master 数据库 UR/ER 图

> 说明：本图按业务域拆分，避免一张总图在 Markdown 预览中缩得过小。当前数据库没有完整声明外键，图中的关系按字段语义、Mapper 查询和业务流程整理。

## 1. 总体业务域

```mermaid
flowchart TB
    User["用户与登录"]
    Exam["题库与试卷"]
    Answer["答题与记录"]
    Knowledge["知识点体系"]
    AI["AI 知识库与学习画像"]
    Message["消息与动态"]

    User --> Answer
    Exam --> Answer
    Exam --> Knowledge
    Knowledge --> AI
    User --> AI
    User --> Message
```

## 2. 用户与登录

```mermaid
erDiagram
    t_user {
        int id PK
        varchar user_uuid
        varchar user_name UK
        varchar password
        varchar real_name
        int role
        int status
        varchar image_path
        varchar wx_open_id
        datetime create_time
        bit deleted
    }

    t_user_token {
        int id PK
        varchar token
        int user_id FK
        varchar wx_open_id
        datetime create_time
        datetime end_time
        varchar user_name
    }

    t_user_event_log {
        int id PK
        int user_id FK
        varchar user_name
        varchar real_name
        text content
        datetime create_time
    }

    t_user ||--o{ t_user_token : "登录/小程序绑定"
    t_user ||--o{ t_user_event_log : "产生动态"
```

## 3. 题库、试卷与答题记录

```mermaid
erDiagram
    t_subject {
        int id PK
        varchar name
        int level
        varchar level_name
        int item_order
        bit deleted
    }

    t_text_content {
        int id PK
        text content
        datetime create_time
    }

    t_question {
        int id PK
        int question_type
        int subject_id FK
        int score
        int difficult
        varchar correct
        int info_text_content_id FK
        text title
        text options
        text correct_answer
        text analysis
        varchar knowledge_point
        varchar source
        int source_year
        text tags
        bit deleted
    }

    t_exam_paper {
        int id PK
        varchar name
        int subject_id FK
        int paper_type
        int score
        int question_count
        int suggest_time
        datetime limit_start_time
        datetime limit_end_time
        int frame_text_content_id FK
        int task_exam_id FK
        int source_year
        bit deleted
    }

    t_task_exam {
        int id PK
        varchar title
        int grade_level
        int frame_text_content_id FK
        int create_user FK
        varchar create_user_name
        bit deleted
    }

    t_exam_paper_answer {
        int id PK
        int exam_paper_id FK
        varchar paper_name
        int paper_type
        int subject_id FK
        int system_score
        int user_score
        int question_correct
        int question_count
        int do_time
        int status
        int create_user FK
        datetime create_time
    }

    t_exam_paper_question_customer_answer {
        int id PK
        int question_id FK
        int exam_paper_id FK
        int exam_paper_answer_id FK
        int subject_id FK
        int customer_score
        int question_score
        int question_text_content_id FK
        varchar answer
        int text_content_id FK
        bit do_right
        int create_user FK
        datetime create_time
    }

    t_subject ||--o{ t_question : "包含题目"
    t_subject ||--o{ t_exam_paper : "包含试卷"
    t_text_content ||--o{ t_question : "旧版题干 JSON"
    t_text_content ||--o{ t_exam_paper : "试卷框架内容"
    t_task_exam ||--o{ t_exam_paper : "任务关联试卷"
    t_exam_paper ||--o{ t_exam_paper_answer : "产生提交记录"
    t_exam_paper_answer ||--o{ t_exam_paper_question_customer_answer : "包含答题明细"
    t_question ||--o{ t_exam_paper_question_customer_answer : "被作答"
```

## 4. 知识点体系

```mermaid
erDiagram
    knowledge_point {
        int id PK
        varchar name
        int subject_id FK
        int parent_id FK
        varchar description
        int level
        int sort_order
        datetime create_time
        bit deleted
    }

    question_knowledge_point {
        int id PK
        int question_id FK
        int knowledge_point_id FK
        decimal relevance
    }

    t_subject {
        int id PK
        varchar name
    }

    t_question {
        int id PK
        int subject_id FK
        varchar knowledge_point
        text tags
    }

    t_subject ||--o{ knowledge_point : "科目目录"
    knowledge_point ||--o{ knowledge_point : "父子层级"
    t_question }o--o{ knowledge_point : "题目映射"
    t_question ||--o{ question_knowledge_point : "关联记录"
    knowledge_point ||--o{ question_knowledge_point : "关联记录"
```

## 5. AI 知识库与学习画像

```mermaid
erDiagram
    t_ai_knowledge_base {
        int id PK
        varchar category
        varchar domain
        varchar sub_domain
        varchar title
        varchar keywords
        text content
        longtext embedding
        varchar embedding_model
        int embedding_dimension
        int chunk_index
        varchar content_hash
        varchar source_type
        varchar source_name
        tinyint enabled
        int priority
        int usage_count
        bit deleted
    }

    t_ai_prompt_template {
        int id PK
        varchar style
        varchar name
        text system_prompt
        text user_prompt_template
        varchar knowledge_base_ids
        tinyint enabled
        tinyint is_default
        int usage_count
        bit deleted
    }

    t_ai_usage_log {
        int id PK
        int template_id FK
        varchar style
        varchar ai_type
        varchar model
        text question
        text knowledge_points
        text prompt
        text response
        tinyint success
        datetime create_time
    }

    t_user_learning_profile {
        int id PK
        int user_id FK
        text profile_summary
        text strengths
        text weaknesses
        varchar preferred_style
        int total_ai_requests
        datetime last_event_time
    }

    t_user_learning_event {
        int id PK
        int user_id FK
        varchar event_type
        varchar style
        varchar target_type
        int target_id
        text summary
        text metadata
        datetime create_time
    }

    t_user_skill_feedback {
        int id PK
        int user_id FK
        int usage_log_id FK
        varchar style
        int rating
        text feedback
        text adjustment_note
        datetime create_time
    }

    t_user ||--o| t_user_learning_profile : "学习画像"
    t_user ||--o{ t_user_learning_event : "学习事件"
    t_user ||--o{ t_user_skill_feedback : "AI反馈"
    t_ai_prompt_template ||--o{ t_ai_usage_log : "被调用"
    t_ai_usage_log ||--o{ t_user_skill_feedback : "被评价"
    t_ai_knowledge_base }o--o{ t_ai_prompt_template : "模板引用知识库ID"
```

## 6. 消息与通知

```mermaid
erDiagram
    t_message {
        int id PK
        varchar title
        varchar content
        datetime create_time
        int send_user_id FK
        varchar send_user_name
        int receive_user_count
        int read_count
    }

    t_message_user {
        int id PK
        int message_id FK
        int receive_user_id FK
        varchar receive_user_name
        bit readed
        datetime create_time
        datetime read_time
    }

    t_user {
        int id PK
        varchar user_name
    }

    t_message ||--o{ t_message_user : "发送给用户"
    t_user ||--o{ t_message_user : "接收消息"
```

## 7. 当前设计要点

- 用户主线：`t_user -> t_user_token -> t_exam_paper_answer -> t_exam_paper_question_customer_answer`。
- 题库主线：`t_subject -> t_question -> t_exam_paper -> t_exam_paper_answer`。
- 知识点主线：`knowledge_point` 自关联形成目录，`question_knowledge_point` 连接题目。
- AI 主线：`t_ai_knowledge_base` 提供知识内容，`t_ai_prompt_template` 组织提示词，`t_ai_usage_log` 记录调用，学习画像表沉淀用户状态。
- 需要注意：图中 FK 多数是逻辑外键，当前 SQL 中并未普遍创建数据库级外键约束。
