# 408刷题系统 - 数据库设计文档

## 📁 目录结构

```
database/
├── README.md                          # 本文档
├── create_question_wrong_analysis.sql # 错题分析表 (V2.1)
├── enhance_knowledge_system.sql       # 知识体系增强脚本 (V2.0)
├── init_knowledge_data.sql            # 知识点初始化数据
├── optimize_study_system.sql          # 学习系统优化脚本 (V2.1)
└── supplement_knowledge_system.sql    # 知识体系补充
```

## 🏗️ 数据库架构

### 核心表 (基础系统)
| 表名 | 说明 |
|------|------|
| `t_user` | 用户表 |
| `t_subject` | 学科表 |
| `t_question` | 题目表 |
| `t_text_content` | 题目内容表 (JSON存储) |
| `t_exam_paper` | 试卷表 |
| ... | 其他基础表 |

### 知识体系表 (V2.0新增)
| 表名 | 说明 | 用途 |
|------|------|------|
| `t_knowledge_point` | 知识点表 | 存储知识点树结构 |
| `t_question_knowledge` | 题目-知识点关联 | 题目与知识点多对多关系 |
| `t_knowledge_relation` | 知识点关系 | 知识图谱边关系 |
| `t_question_vector` | 题目向量表 | 支持RAG检索 |
| `t_question_ai_analysis` | AI解析风格表 | 多风格AI解析 |
| `t_user_knowledge_mastery` | 用户知识掌握表 | Agent个人知识图谱 |
| `t_user_learning_behavior` | 用户学习行为 | 学习行为记录 |
| `t_user_learning_session` | 学习会话表 | 连续对话上下文 |

### 学习系统表 (V2.1新增)
| 表名 | 说明 |
|------|------|
| `t_question_wrong_analysis` | 错题分析表 |
| `t_question_wrong_stat` | 用户错题统计表 |
| `t_user_study_plan` | 学习计划表 |
| `t_user_note` | 学习笔记表 |
| `t_study_task` | 学习任务表 |

## 📋 表结构详解

### 1. 知识体系 (enhance_knowledge_system.sql)

#### t_knowledge_point - 知识点表
```sql
字段说明:
- id: 知识点ID (层级编码)
- name: 知识点名称
- parent_id: 父知识点ID (构建树形)
- subject_id: 学科ID
- level: 层级 (1=章, 2=节, 3=小节)
- code: 知识点编码 (如: DS-01-03-02)
- description: 描述
- difficulty: 难度 (1-5)
- importance: 重要程度 (1-5)
- embedding: 向量表示 (JSON)
```

**408知识点树结构:**
```
数据结构 (DS)
├── 线性表
│   ├── 顺序表
│   └── 链表
│       ├── 单链表
│       ├── 双向链表
│       └── 循环链表
├── 栈
├── 队列
├── 树和二叉树
├── 图
├── 查找
├── 排序
└── 算法基础

计算机组成原理 (CO)
操作系统 (OS)
计算机网络 (NET)
```

#### t_question_knowledge - 题目-知识点关联
```sql
字段说明:
- question_id: 题目ID
- knowledge_id: 知识点ID
- weight: 关联权重 (0.1-1.0)
- knowledge_type: 知识点类型 (main/sub/hint)
```

#### t_knowledge_relation - 知识点关系
```sql
关系类型:
- prerequisite: 前置知识 (A是B的前提)
- contains: 包含关系 (A包含B)
- similar: 相似关系
- contrast: 对比关系
- applied: 应用关系 (A应用于B)
```

#### t_user_knowledge_mastery - 用户知识掌握表
```sql
字段说明:
- user_id: 用户ID
- knowledge_id: 知识点ID
- mastery_level: 掌握程度 (0-100)
- times_practiced: 练习次数
- times_correct: 正确次数
- correct_rate: 正确率
- ease_factor: 记忆Ease因子 (SM2算法)
- interval_days: 下次复习间隔天数
- next_review_time: 下次复习时间
- status: 状态 (learning/new/reviewing/mastered/forgotten)
```

**艾宾浩斯记忆算法集成:**
- 基于SM-2算法计算复习间隔
- 支持动态调整复习计划

### 2. AI解析系统

#### t_question_ai_analysis - AI解析风格表
```sql
解析风格:
- default: 默认风格 (标准解析)
- plato: 柏拉图风格 (启发式提问)
- feynman: 费曼风格 (通俗易懂讲解)
- first_principles: 第一性原理 (从本质出发)
```

**提示词模板示例:**
- **费曼风格**: "请用通俗易懂的语言，就像给初学者讲解一样..."
- **柏拉图风格**: "请通过连续提问的方式，引导用户自己思考..."
- **第一性原理**: "请从最基本的原理出发，一步步推导..."

### 3. 学习系统 (optimize_study_system.sql)

#### t_question_wrong_stat - 用户错题统计
```sql
功能:
- 记录每道题的错误次数
- 保存用户的错误答案历史
- 跟踪复习状态
- 计算掌握程度
```

#### t_user_study_plan - 学习计划
```sql
计划类型:
- daily: 日计划
- weekly: 周计划
- monthly: 月计划
- exam: 考试冲刺计划

配置JSON示例:
{
  "target_subjects": [101, 104, 107, 110],
  "daily_question_count": 20,
  "focus_weak_points": true
}
```

## 🚀 使用指南

### 完整初始化步骤

```bash
# 1. 先执行基础库初始化 (sql/init_database.sql)
mysql -u root -p < ../sql/init_database.sql

# 2. 执行知识体系增强
mysql -u root -p xzs < enhance_knowledge_system.sql

# 3. 初始化知识点数据
mysql -u root -p xzs < init_knowledge_data.sql

# 4. 执行学习系统优化
mysql -u root -p xzs < optimize_study_system.sql

# 5. 错题分析表 (已有)
mysql -u root -p xzs < create_question_wrong_analysis.sql
```

### 检查初始化结果

```sql
USE xzs;

-- 查看表数量
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'xzs' 
ORDER BY table_name;

-- 查看知识点数量
SELECT COUNT(*) FROM t_knowledge_point;

-- 查看知识点关系
SELECT * FROM t_knowledge_relation LIMIT 20;
```

## 💡 设计思路

### 1. 知识图谱设计
- **树形结构**: 知识点按章-节-小节组织
- **多关系支持**: 前置、包含、相似、对比等关系
- **权重机制**: 支持关联强度调整

### 2. RAG检索支持
- 题目向量化存储
- 知识点向量化存储
- 支持语义检索

### 3. AI多风格解析
- 四种预设风格
- 可扩展提示词模板
- 向量支持语义检索解析

### 4. Agent学习辅助
- 用户知识图谱
- 学习行为追踪
- 智能复习计划
- 会话上下文管理

## 📊 ER图示意

```
t_user (用户)
  │
  ├─ t_user_knowledge_mastery ── t_knowledge_point
  │
  ├─ t_user_learning_behavior
  │
  ├─ t_user_learning_session
  │
  ├─ t_user_note
  │
  ├─ t_user_study_plan ── t_study_task
  │
  └─ t_question_wrong_stat ── t_question ── t_question_knowledge ── t_knowledge_point
                                                              │
                                                              └─ t_question_ai_analysis
                                                              │
                                                              └─ t_question_vector

t_knowledge_point
  │
  └─ t_knowledge_relation (自关联)
```

## 🔧 后续优化方向

1. **向量检索**: 集成Milvus/Pinecone等向量数据库
2. **实时推荐**: 基于知识图谱的题目推荐
3. **学习分析**: 更深入的学习行为分析
4. **协作学习**: 好友系统、团队学习功能

## 📝 更新日志

### V2.1 (2026-05-14)
- ✅ 新增错题分析表
- ✅ 新增错题统计表
- ✅ 新增学习计划表
- ✅ 新增学习笔记表
- ✅ 新增学习任务表

### V2.0 (2026-05-14)
- ✅ 知识点体系
- ✅ 题目-知识点关联
- ✅ 知识图谱关系
- ✅ 用户知识掌握
- ✅ AI多风格解析
- ✅ RAG向量支持
- ✅ 学习行为追踪
- ✅ 学习会话管理
