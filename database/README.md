# 数据库导出说明

## 导出信息

- **导出日期**: 2026-05-15
- **数据库名**: xzs
- **MySQL 版本**: 8.0.36
- **文件大小**: 98KB
- **表数量**: 18

## 文件列表

| 文件 | 说明 |
|------|------|
| `xzs-20260515.sql` | 完整数据库导出（含表结构和数据） |

## 导入步骤

### 方法一：MySQL 命令行

```bash
# 登录 MySQL
mysql -u root -p

# 创建数据库（如果不存在）
CREATE DATABASE xzs DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

# 退出 MySQL
exit;

# 导入数据
mysql -u root -p xzs < xzs-20260515.sql
```

### 方法二：Navicat 或其他 GUI 工具

1. 打开 Navicat，连接到本地 MySQL
2. 新建数据库 `xzs`，字符集选 `utf8mb4`，排序规则选 `utf8mb4_unicode_ci`
3. 右键数据库 → 运行 SQL 文件
4. 选择 `xzs-20260515.sql`
5. 点击开始，等待导入完成

### 方法三：MySQL Workbench

1. 打开 MySQL Workbench，连接到本地 MySQL
2. Server → Data Import
3. 选择 `Import from Self-Contained File`
4. 选择 `xzs-20260515.sql`
5. 目标 Schema 选择 `xzs`（没有就新建）
6. 点击 `Start Import`

## 数据库配置

项目中使用的数据库配置（`application-dev.yml`）：

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/xzs?useSSL=false&useUnicode=true&serverTimezone=Asia/Shanghai&characterEncoding=UTF-8&zeroDateTimeBehavior=convertToNull&allowPublicKeyRetrieval=true&allowMultiQueries=true&connectionCollation=utf8mb4_unicode_ci
    username: root
    password: 123456
```

## 注意事项

1. **字符集**: 请确保数据库字符集为 `utf8mb4`，否则中文可能乱码
2. **权限**: 确保用户有创建表和插入数据的权限
3. **外键**: SQL 文件已临时关闭外键检查，导入时不会有外键冲突问题
4. **存储过程/触发器**: 已包含存储过程和触发器的导出

## 包含的表

数据库包含以下表（共 18 个）：

- 用户相关: t_user, t_user_token, t_user_event_log
- 题目相关: t_question, t_question_type
- 试卷相关: t_exam_paper, t_exam_paper_type, t_text_content
- 答题记录: t_exam_paper_answer, t_exam_paper_question_customer_answer
- 作业相关: t_task_exam, t_task_exam_customer_answer
- 消息相关: t_message, t_message_user
- 其他: t_subject, t_dict
- AI 相关: t_ai_adjustment_log, t_ai_knowledge_base, t_ai_prompt_template, t_ai_usage_record

## 常用账号

### 管理员账号
- 用户名: admin
- 密码: 123456

### 学生账号
- 用户名: student
- 密码: 123456

（如有其他账号，请自行查看 t_user 表）

## 数据库更新说明

如需更新数据库，请：

1. 修改数据库
2. 重新导出：
   ```bash
   mysqldump -u root -p123456 --default-character-set=utf8mb4 --routines --triggers xzs > xzs-YYYYMMDD.sql
   ```
3. 提交新的 SQL 文件到版本控制
