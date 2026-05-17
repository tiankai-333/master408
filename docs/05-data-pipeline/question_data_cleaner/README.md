# 2024年408真题 - 数据清洗工具

本工具用于将2024年408计算机专业基础综合真题从PDF格式转换为可导入数据库的结构化数据。

## 文件说明

| 文件 | 说明 |
|------|------|
| `ocr_processor.py` | OCR识别脚本，从图片中提取文字 |
| `question_parser.py` | 题目解析器，构建题目结构 |
| `sql_generator.py` | SQL生成器，生成数据库导入脚本 |
| `main.py` | 主流程脚本，一键执行所有步骤 |
| `quick_start.py` | 快速启动脚本，直接从图片创建题目数据（推荐） |
| `merge_files.py` | 文件合并工具，支持将分开的题目和答案文件合并 |
| `question_editor.html` | Web可视化题目编辑器（v1） |
| `question_editor_v2.html` | Web可视化题目编辑器（v2，支持多文件导入合并）⭐ |
| `examples/` | 示例文件目录，包含题目文件和答案文件的模板 |
| `README.md` | 本文档 |

## 环境要求

- Python 3.7+
- Tesseract OCR（仅用于 ocr_processor.py）
- 依赖库：
  ```bash
  pip install pytesseract pillow
  ```

## 使用方式

### 方式一：快速开始（最推荐）

适合没有OCR环境，直接从图片创建题目结构的情况。

1. **运行快速启动脚本**
   ```bash
   cd docs/05-data-pipeline/question_data_cleaner
   python quick_start.py
   ```
   这将：
   - 从图片目录加载所有题目图片
   - 创建48道题目的基础结构
   - 生成 `parsed_questions.json`

2. **使用Web编辑器编辑题目**
   - 在浏览器中打开 `question_editor_v2.html`
   - 选择「方式二：直接导入完整数据」，加载 `parsed_questions.json`
   - 从左侧选择题目，在右侧编辑：
     - 题目描述
     - 选项内容
     - 正确答案
     - 答案解析
     - 分值、难度等
   - 可以在最右侧查看对应的题目图片作为参考
   - 编辑完成后点击「保存数据」

3. **生成最终SQL**
   - 在Web编辑器中点击「导出 SQL」，或运行：
   ```bash
   python sql_generator.py
   ```

4. **导入数据库**
   ```bash
   mysql -u root -p xzs < insert_2024_questions.sql
   ```

---

### 方式二：题目和答案分开处理（推荐多人协作）

适合题目和答案由不同人员整理，最后合并的情况。

#### 1. 准备数据文件

准备两个JSON文件：

**题目文件** (`questions_only.json`)：
```json
[
  {
    "question_num": 1,
    "type": "choice",
    "subject": "data_structure",
    "titleContent": "若一个栈的输入序列为1,2,3,4,5...",
    "options": [
      {"prefix": "A", "content": "选项A"},
      {"prefix": "B", "content": "选项B"}
    ],
    "score": 2,
    "difficult": 3,
    "page_num": 4
  }
]
```

**答案文件** (`answers_only.json`)：
```json
[
  {
    "question_num": 1,
    "correct": "D",
    "correctAnswerText": "4,5,2,3,1",
    "analyze": "栈遵循后进先出规则..."
  }
]
```

具体示例可参考 `examples/` 目录下的模板文件。

#### 2. 合并文件

**方法A：使用Python脚本**
```bash
python merge_files.py examples/questions_only.json examples/answers_only.json merged_output.json ../2024_408/images
```

**方法B：使用Web编辑器（推荐）**
1. 在浏览器中打开 `question_editor_v2.html`
2. 在「数据导入」标签页中，选择「方式一：分别导入题目和答案」
3. 分别上传题目文件和答案文件
4. 点击「合并题目和答案」
5. 切换到「题目编辑」标签页进行编辑
6. 最后保存数据和导出SQL

---

### 方式三：使用完整OCR流程

适合PDF是可提取文本的情况。

1. **运行主脚本**
   ```bash
   cd docs/05-data-pipeline/question_data_cleaner
   python main.py
   ```
   这将依次执行：
   - OCR识别页面内容
   - 解析题目结构
   - 生成初始SQL脚本

2. **使用Web编辑器编辑题目**（同方式一步骤2）

3. **生成最终SQL**（同方式一步骤3）

4. **导入数据库**（同方式一步骤4）

---

### 方式四：分步执行

1. **OCR识别**
   ```bash
   python ocr_processor.py
   ```
   生成 `ocr_results.json`

2. **解析题目**
   ```bash
   python question_parser.py
   ```
   生成 `parsed_questions.json`

3. **生成SQL**
   ```bash
   python sql_generator.py
   ```
   生成 `insert_2024_questions.sql`

## 题目数据结构

### 完整题目数据（用于导入数据库）

```json
{
  "id": 2001,
  "question_type": 1,
  "subject_id": 101,
  "score": 2,
  "grade_level": 2,
  "difficult": 3,
  "correct": "A",
  "info_text_content_id": 2001,
  "create_user": 1,
  "status": 1,
  "text_content": {
    "titleContent": "题目描述",
    "analyze": "答案解析",
    "questionItemObjects": [
      {"prefix": "A", "content": "选项A", "itemUuid": "..."},
      {"prefix": "B", "content": "选项B", "itemUuid": "..."}
    ],
    "correct": "正确答案描述"
  }
}
```

### 拆分格式（题目文件）

```json
{
  "question_num": 1,
  "type": "choice",
  "subject": "data_structure",
  "titleContent": "题目内容",
  "options": [
    {"prefix": "A", "content": "选项A"},
    {"prefix": "B", "content": "选项B"}
  ],
  "page_num": 4
}
```

### 拆分格式（答案文件）

```json
{
  "question_num": 1,
  "correct": "D",
  "correctAnswerText": "答案文本",
  "analyze": "解析内容"
}
```

## 字段说明

### question_type（题目类型）
- 1: 单选题
- 2: 多选题
- 3: 判断题
- 4: 填空题
- 5: 简答题

### subject / subject_id（学科）
- `data_structure` / 101: 数据结构（考研）
- `computer_organization` / 104: 计算机组成原理（考研）
- `operating_system` / 107: 操作系统（考研）
- `computer_network` / 110: 计算机网络（考研）

### grade_level（年级等级）
- 1: 期末考
- 2: 考研
- 3: 复试

### difficult（难度）
- 1-5，1最简单，5最难

## 注意事项

1. **图片处理**：由于PDF是扫描件，题目内容以图片形式保存到JSON中，SQL导出时会移除图片数据以减小文件大小
2. **数据验证**：建议在导入前先在测试库中验证
3. **备份数据**：导入前请先备份现有数据库
4. **ID冲突**：题目ID从2001开始，避免与现有数据冲突
5. **多人协作**：推荐使用「方式二」，题目和答案可分开编辑，最后合并

## 常见问题

### Tesseract未找到
在 `ocr_processor.py` 中指定Tesseract路径：
```python
pytesseract.pytesseract.tesseract_cmd = r'C:\Program Files\Tesseract-OCR\tesseract.exe'
```

### 中文识别不准确
由于是扫描件，OCR识别可能不够准确，建议使用Web编辑器配合图片人工核对和编辑题目内容。

### 如何只编辑部分题目？
可以在Web编辑器中加载完整数据，只编辑需要修改的题目，然后保存。

### 合并时答案匹配不上？
确保 `question_num` 字段在题目文件和答案文件中是一致的。
