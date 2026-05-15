# AI Agent 系统测试指南

## 快速开始

### 1. 导入数据库

在MySQL中执行以下命令：

```bash
# 1. 先导入表结构
mysql -u root -p xzs < sql/ai_agent_import.sql

# 2. 再导入初始数据
mysql -u root -p xzs < sql/ai_agent_tables.sql
```

或者在MySQL客户端中：

```sql
USE xzs;
SOURCE C:/Dev/Workspaces/master408/sql/ai_agent_import.sql;
SOURCE C:/Dev/Workspaces/master408/sql/ai_agent_tables.sql;
```

### 2. 验证数据导入

```sql
-- 检查表是否创建成功
SHOW TABLES LIKE 't_ai_%';

-- 检查提示词模板
SELECT id, style, name, icon FROM t_ai_prompt_template;

-- 检查知识库
SELECT id, category, title, source_name FROM t_ai_knowledge_base;
```

预期输出：
- 4个模板：default, feyman, plato, first-principles
- 10+条知识库数据

### 3. 启动后端服务

```bash
cd source/xzs
mvn spring-boot:run
```

或者使用IDE运行 `XzsApplication.java`

### 4. 测试API接口

#### 4.1 获取所有模板
```bash
curl http://localhost:8080/api/admin/ai-agent/templates
```

#### 4.2 获取单个模板
```bash
curl http://localhost:8080/api/admin/ai-agent/template/style/default
```

#### 4.3 获取知识库
```bash
curl http://localhost:8080/api/admin/ai-agent/knowledge-base
```

#### 4.4 测试AI分析（需要配置API Key）
```bash
curl -X POST http://localhost:8080/api/student/ai/analyze \
  -H "Content-Type: application/json" \
  -d '{
    "style": "feynman",
    "question": "若一个栈的输入序列为1,2,3,4,5，则下列序列中不可能是栈的输出序列的是（）",
    "aiType": "glm",
    "apiKey": "your-api-key"
  }'
```

### 5. 测试前端

1. 启动前端开发服务器
```bash
cd source/vue/xzs-student
npm run dev
```

2. 访问 http://localhost:9528

3. 登录后访问 AI多风格解析 页面

4. 在页面顶部配置AI：
   - 选择AI类型（智谱GLM）
   - 填写API Key
   - 保存配置

5. 输入测试题目，点击"生成解析"

## 测试用例

### 测试题目1：栈的基本概念
**题目**：若一个栈的输入序列为1,2,3,4,5，则下列序列中不可能是栈的输出序列的是（）
A. 2,3,4,1,5
B. 5,4,3,2,1
C. 2,4,3,5,1
D. 4,5,2,3,1

### 测试题目2：二叉树遍历
**题目**：已知一棵二叉树的前序遍历为ABDEGCFH，中序遍历为DBGEAFHC，请还原该二叉树，并写出后序遍历序列。

### 测试题目3：进程调度
**题目**：有三个作业，到达时间分别为0、1、2，运行时间分别为3、2、1，采用非抢占式短作业优先（SJF）调度，平均周转时间为（）

## 预期输出示例

### 费曼风格输出示例
```
## 这道题在考什么？

这道题考的是**栈（Stack）**这个数据结构的特点。

### 生活化的理解

想象栈就像一个**羽毛球桶**：
- 你只能从桶口放球（push）
- 你也只能从桶口取球（pop）

这就是"后进先出"（Last In First Out）的意思！

### 一步步教你解题

1. 栈的输入序列是：1 → 2 → 3 → 4 → 5
2. 这意味着1先进桶底，5最后进桶口
3. 取球的时候，5必须先出来，然后4，然后3...

### 答案

正确答案是 **D. 4,5,2,3,1**

为什么？
- 先出4和5，说明4和5在栈顶附近 ✓
- 但是出完4、5后，栈里还有1、2、3
- 此时栈顶是3，下一个应该是3，而不是2 ✗
- 所以D是不可能的！
```

## 调试技巧

### 查看后端日志

```bash
# 查看Spring Boot日志
tail -f logs/spring.log
```

### 检查数据库连接

```sql
-- 测试连接
SELECT 1;

-- 检查表内容
SELECT COUNT(*) FROM t_ai_prompt_template;
SELECT COUNT(*) FROM t_ai_knowledge_base;
```

### 常见问题

#### Q: API调用失败
A: 检查：
1. API Key是否正确
2. API地址是否正确
3. 网络是否能访问

#### Q: 模板加载失败
A: 检查：
1. 数据库表是否创建
2. 数据是否导入
3. MyBatis Mapper是否正确扫描

#### Q: 前端页面空白
A: 检查：
1. 控制台是否有错误
2. API请求是否发出
3. 浏览器网络请求

## 性能测试

### 测试不同风格的响应时间

```sql
-- 查看使用记录
SELECT style, AVG(duration_ms) as avg_duration, COUNT(*) as total
FROM t_ai_usage_log
GROUP BY style;
```

## 下一步

测试完成后，你可以：

1. **调整模板**：在管理页面修改提示词
2. **添加知识库**：创建新的知识库内容
3. **查看日志**：分析使用情况
4. **优化提示词**：根据测试结果调整

---

祝测试愉快！🎉
