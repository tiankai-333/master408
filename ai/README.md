# AI Agent Skill - 408刷题系统

## 📁 目录结构

```
ai/
├── README.md                          # 本文档
├── prompts/                           # 提示词模板
│   ├── analysis/                      # 题目解析提示词
│   │   ├── default.json               # 默认风格
│   │   ├── feynman.json               # 费曼风格
│   │   ├── plato.json                 # 柏拉图风格
│   │   └── first-principles.json      # 第一性原理风格
│   ├── knowledge/                     # 知识点讲解提示词
│   └── error-analysis/                # 错题分析提示词
├── services/                          # AI服务调用
│   ├── openai/                        # OpenAI API封装
│   └── local-llm/                     # 本地大模型封装
└── examples/                          # 使用示例
```

## 🎨 解析风格

| 风格 | 特点 | 适用场景 |
|------|------|----------|
| `default` | 标准解析，讲清楚知识点和答案 | 日常学习 |
| `feynman` | 通俗易懂，像给小白讲解一样 | 基础薄弱 |
| `plato` | 启发式提问，引导自己思考 | 深度学习 |
| `first-principles` | 从本质出发，逐步推导 | 深刻理解 |

## 📝 提示词模板格式

每个提示词模板为JSON格式：

```json
{
  "name": "风格名称",
  "description": "风格描述",
  "system_prompt": "系统提示词",
  "user_prompt_template": "用户提示词模板，使用 {question} 占位符",
  "variables": ["question", "knowledge_points"]
}
```
