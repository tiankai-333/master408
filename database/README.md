# 数据库说明

## 基本信息

- **数据库名**: xzs
- **字符集**: utf8mb4 / utf8mb4_unicode_ci
- **MySQL 版本**: 8.0.36

## 快速导入（全新环境）

```bash
cd database
mysql -u root -p123456 -e "CREATE DATABASE IF NOT EXISTS xzs DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci"
python ../import_db.py
```

> **注意**：不要用 PowerShell 的 `Get-Content | mysql` 管道导入，会导致中文乱码。使用 `import_db.py` 脚本通过 pymysql 连接，保证 UTF-8 编码正确。

## 文件列表

| 文件 | 说明 | 执行顺序 |
|------|------|---------|
| `01_init_structure.sql` | 表结构（19 张表，从代码反推） | 1 |
| `02_extend_fields.sql` | 408 真题扩展字段 | 2 |
| `04_exam_data.sql` | 全量数据（由 `crawler/generate_sql.py` 生成） | 3 |
| `init_knowledge_data.sql` | 知识体系初始化数据 | 4 |
| `enhance_knowledge_system.sql` | 知识体系增强 | 5 |
| `supplement_knowledge_system.sql` | 知识体系补充 | 6 |
| `optimize_study_system.sql` | 学习系统优化 | 7 |
| `create_question_wrong_analysis.sql` | 错题分析表 | 8 |
| `05_rag_embeddings.sql` | 题目解析 embedding 字段 | 9 |
| `06_ai_knowledge_rag.sql` | AI知识库、RAG、学生档案与反馈闭环增强 | 10 |
| `xzs-20260515.sql` | 完整数据库备份（参考用） | - |

## 数据统计

| 数据 | 数量 |
|------|------|
| 选择题 | 560 道（2011-2024） |
| 综合应用题 | 98 道（2011-2024） |
| 试卷 | 14 份（2011-2024） |
| 科目 | 5 个（408综合 + 数据结构、计组、OS、网络） |
| 用户 | 4 个（admin/student/teacher/231310423） |
| 知识标签 | 652 道有标签，6 道无标签（网站缺失） |
| 文本内容 | 672 条（题目内容 + 试卷框架） |
| AI知识库 | 116 条 408 知识点 + 方法论摘要 |

## 表结构来源

所有表结构从以下代码反推，保证与代码 100% 一致：

- `source/xzs/src/main/resources/mapper/*.xml`（19 个 Mapper XML）
- `source/xzs/src/main/java/com/mindskip/xzs/domain/*.java`（16 个 Domain 类）

## 核心表说明

### t_question（题目表）

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | int | 主键 |
| `question_type` | int | 1=单选, 2=多选, 3=判断, 4=填空, 5=综合应用题 |
| `subject_id` | int | 科目 ID（1=DS, 2=CO, 3=OS, 4=CN） |
| `score` | int | 分数 × 10（2 分存为 20，10 分存为 100） |
| `correct` | varchar(255) | 正确答案（选择题 A/B/C/D） |
| `info_text_content_id` | int | 指向 t_text_content（题目内容 JSON） |
| `source` | varchar(100) | 来源（如 `2024年408真题`） |
| `source_year` | int | 来源年份 |
| `source_question_no` | int | 原始题号（1-47） |
| `tags` | text | 知识标签，逗号分隔 |

### t_text_content（文本内容表）

存储题目内容和试卷框架，以 JSON 格式。

**题目内容格式**（对应 QuestionObject.java）：
```json
{
  "titleContent": "题干文本",
  "analyze": "解析文本",
  "questionItemObjects": [
    {"prefix": "A", "content": "选项内容", "itemUuid": "xxx"}
  ]
}
```

**试卷框架格式**（对应 ExamPaperTitleItemObject.java）：
```json
[
  {
    "name": "一、单项选择题（数据结构，1-10题，每题2分）",
    "questionItems": [{"id": 1, "itemOrder": 1}]
  }
]
```

### t_exam_paper（试卷表）

| 字段 | 类型 | 说明 |
|------|------|------|
| `subject_id` | int | 科目 ID（5=408综合，所有真题试卷统一指向此科目） |
| `paper_type` | int | 1=固定试卷, 4=时段试卷, 6=任务试卷 |
| `grade_level` | int | 年级（已废弃，保留字段兼容旧代码） |
| `score` | int | 总分 × 10（150 分存为 1500） |
| `frame_text_content_id` | int | 指向 t_text_content（试卷框架 JSON） |
| `source_year` | int | 来源年份 |

### t_subject（科目表）

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | int | 1=数据结构, 2=计组, 3=OS, 4=网络, 5=408综合 |
| `level` | int | 年级（已废弃，不再使用） |
| `deleted` | bit(1) | 软删除 |

### knowledge_point（知识点表）

注意：表名无 `t_` 前缀，与 Mapper XML 一致。

### question_knowledge_point（题目-知识点关联表）

注意：表名无 `t_` 前缀，与 Mapper XML 一致。

### t_ai_knowledge_base（AI知识库/RAG文档表）

用于 RAG 检索与 skill 解析参考资料。`06_ai_knowledge_rag.sql` 会在原表基础上增加 `embedding`、`embedding_model`、`embedding_dimension`、`chunk_index`、`content_hash` 字段。408 知识点爬虫写入 `source_type='csgraduates'`，方法论摘要写入 `source_type='method_summary'`。

### t_user_learning_profile / t_user_learning_event / t_user_skill_feedback

用于 agent 学生档案和反馈闭环。v1 只做个人上下文修饰，不自动改写全局 prompt 模板。

## 分数存储机制

xzs 系统中分数以**整数存储**（实际分值 × 10），避免浮点精度问题：

| 实际分值 | 数据库存储 | 前端显示 |
|---------|-----------|---------|
| 2 分 | 20 | `ExamUtil.scoreToVM(20)` → "2" |
| 10 分 | 100 | `ExamUtil.scoreToVM(100)` → "10" |
| 150 分 | 1500 | `ExamUtil.scoreToVM(1500)` → "150" |

## 常用账号

| 用户名 | 密码 | 角色 |
|--------|------|------|
| admin | 123456 | 管理员 |
| student | 123456 | 学生 |
| teacher | 123456 | 教师 |
| 231310423 | 123456 | 学生（测试） |

## 验证数据

```sql
SELECT question_type, COUNT(*) FROM t_question GROUP BY question_type;
SELECT source, COUNT(*) FROM t_question GROUP BY source;
SELECT id, name, score FROM t_exam_paper LIMIT 5;
```

## 注意事项

1. `knowledge_point` 和 `question_knowledge_point` 表名无 `t_` 前缀（与 Mapper XML 一致）
2. `paper_type` 和 `question_type` 是 `int` 类型（不是 varchar）
3. 用户密码使用 BCrypt 加密
4. `t_text_content.content` 实际是 TEXT 类型（存储 JSON）
5. **导入数据必须用 `import_db.py`**，不要用 PowerShell 管道（会乱码）
