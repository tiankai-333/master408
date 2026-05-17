# 408考研真题爬虫

## 概述

本爬虫用于从 [csgraduates.com](https://www.csgraduates.com) 网站爬取计算机学科专业基础综合考试（408）的历年真题和知识点数据。

当前 AI/RAG 分支最重要的爬虫入口是 `knowledge_crawler.py`，它会把 408 四科知识点写入 `knowledge_point` 和 `t_ai_knowledge_base`，供知识图谱、RAG 和四种 AI Skill 使用。

## 功能特性

- 爬取 2011-2024 年 408 历年真题（选择题 + 综合应用题）
- 爬取 408 四门课知识点页面，导入 `knowledge_point` 与 `t_ai_knowledge_base`
- 自动识别题型：选择题（1-40 题）、综合应用题（41-47 题）
- 自动提取每道题的知识标签（如"复杂度分析"、"链表"、"虚拟页式管理"等）
- 支持图片本地化下载（SVG/JPG）
- 智能识别题目科目（数据结构、组成原理、操作系统、计算机网络）
- 生成 CSV 和 JSON 格式数据
- 自动生成 SQL 导入文件（`generate_sql.py`）
- 直接更新数据库中的知识标签（`crawl_tags.py`）

## 目录结构

```
crawler/
├── README.md                    # 本文件
├── config.json                  # 配置文件
├── requirements.txt             # Python 依赖
├── main.py                      # 主入口
├── quick_start.py               # 快速启动脚本
├── exam_crawler_with_images.py  # 选择题爬虫（含图片）
├── improved_exam_crawler.py     # 改进版选择题爬虫
├── improved_essay_crawler.py    # 综合应用题爬虫
├── crawl_tags.py                # 知识标签爬虫（更新数据库）
├── knowledge_crawler.py         # 408知识点爬虫（知识图谱 + AI知识库）
├── sync_image_paths.py          # 图片路径审计/同步工具
├── generate_sql.py              # 从 JSON/CSV 生成 SQL 导入文件
├── analyze_html.py              # HTML 结构分析工具
├── check_images.py              # 图片检查工具
├── data/                        # 爬取的数据
│   ├── exam_questions.json      # 选择题 JSON（616 道）
│   ├── essay_questions.csv      # 综合应用题 CSV（98 道）
│   ├── knowledge_tags.json      # 知识标签 JSON（658 道）
│   ├── knowledge_pages.json     # 408知识点页面 JSON（116 条）
│   ├── image_manifest.json      # 图片清单
│   └── images/                  # 本地图片
│       ├── 2011_OS_27_1.svg
│       └── ...
```

## 安装

```bash
cd crawler
pip install -r requirements.txt
pip install pymysql
```

依赖包括：
- `requests`: HTTP 请求
- `beautifulsoup4`: HTML 解析
- `lxml`: 快速 XML/HTML 解析器
- `pymysql`: 数据库连接（知识标签爬虫需要）

## 使用方法

### 爬取选择题（含图片）

```bash
python exam_crawler_with_images.py --start-year 2011 --end-year 2024 --manifest
```

### 爬取综合应用题

```bash
python improved_essay_crawler.py
```

### 爬取知识标签并更新数据库

```bash
python crawl_tags.py
```

该脚本会：
1. 从 csgraduates.com 获取每道题的知识标签
2. 直接更新 `t_question` 表的 `tags` 字段
3. 导出 `data/knowledge_tags.json` 备份

### 爬取 408 知识点并导入知识库

```bash
python3 crawler/knowledge_crawler.py --import-db --clear-existing --delay 0.2 --timeout 12
```

如果已经有 `crawler/data/knowledge_pages.json` 快照，只想重新导入数据库：

```bash
python3 crawler/knowledge_crawler.py --skip-crawl --import-db --clear-existing
```

如果数据库不在默认 `127.0.0.1:3306 root/123456`，请显式传入连接信息：

```bash
python3 crawler/knowledge_crawler.py \
  --skip-crawl \
  --import-db \
  --clear-existing \
  --db-host 127.0.0.1 \
  --db-port 3306 \
  --db-user root \
  --db-password '你的密码' \
  --db-name xzs \
  --output crawler/data/knowledge_pages.json
```

该脚本会：

1. 抓取 CSGraduates 上数据结构、组成原理、操作系统、计算机网络四门课知识点。
2. 保存 JSON 快照到 `crawler/data/knowledge_pages.json`。
3. 写入 `knowledge_point`，供知识图谱使用。
4. 写入 `t_ai_knowledge_base`，供 RAG 和 AI skill 使用。

当前快照统计：**116 条知识点页面**，其中数据结构 30、组成原理 30、操作系统 22、计算机网络 34。

### 审计并同步真题图片路径

先 dry-run 查看会修改哪些记录：

```bash
python3 crawler/sync_image_paths.py
```

确认后同步到数据库：

```bash
python3 crawler/sync_image_paths.py --apply
```

同步逻辑按图片文件名中的年份、科目代码、题号匹配 `t_question` 和 `t_essay_question`，并把路径统一为 `images/{year}/{year}_{question_no}.{ext}`。后端静态资源目录应包含对应文件：`source/xzs/src/main/resources/static/images/`。

### 生成 SQL 导入文件

```bash
python generate_sql.py
```

该脚本会读取 `data/` 下的 JSON/CSV 文件，生成 `database/current/04_exam_data.sql`。

### 指定年份范围

```bash
python main.py --start-year 2020 --end-year 2024
```

## 数据格式

### 知识标签 JSON（knowledge_tags.json）

```json
{
  "source": "2024年408真题",
  "question_no": 1,
  "question_type": "choice",
  "tags": "链表"
}
```

字段说明：

| 字段 | 类型 | 说明 |
|------|------|------|
| `source` | string | 来源，格式为 `YYYY年408真题` |
| `question_no` | int | 题号（1-40 选择题，41-47 综合应用题） |
| `question_type` | string | 题型：`choice`（选择题）或 `essay`（综合应用题） |
| `tags` | string | 知识标签，逗号分隔（如 `链表,二叉树的遍历`） |

### 选择题 JSON（exam_questions.json）

```json
{
  "year": "2024",
  "subject": "数据结构",
  "question_type": "真题",
  "question_number": 1,
  "question": "题目内容...",
  "options": "A.选项1 B.选项2 C.选项3 D.选项4",
  "answer": "A",
  "analysis": "解析内容...",
  "images": ""
}
```

### 综合应用题 CSV（essay_questions.csv）

```csv
year,subject,question_no,title,total_score,answer,analysis,images
2024,数据结构,41,"题目内容...",10,"参考答案...","解析...",""
```

### 图片命名规则

```
{年份}_{科目代码}_{题号}_{图片序号}.{扩展名}
```

科目代码：DS=数据结构, CO=计组, OS=操作系统, CN=计算机网络

## 数据统计

### 选择题

| 年份 | 数据结构 | 计组 | 操作系统 | 计算机网络 | 总计 |
|------|---------|------|---------|-----------|------|
| 2011-2024（每年） | 10 | 10 | 10 | 8 | 38 |

总计：**616 道**选择题（计算机网络每年缺 2 道，待补全）

### 综合应用题

每年 7 道：数据结构 2 + 计组 2 + OS 2 + 网络 1

总计：**98 道**综合应用题（2011-2024 年）

### 知识标签

- 覆盖率：**100%**（658/658 道题全部有标签）
- 热门标签：排序算法(19)、中断IO(18)、虚拟页式管理(16)、处理机调度算法(13)

### 图片

- 选择题图片清单：17 条原始下载记录（SVG 为主，含重复来源）
- 当前唯一静态图片文件：15 个
- 数据库 `t_question` 已挂图：15 道
- 数据库 `t_essay_question` 已挂图：4 条

图片静态路径统一放在：

```
source/xzs/src/main/resources/static/images/{year}/{year}_{question_no}.{ext}
```

## 数据库字段映射

爬虫数据与 `t_question` 表的对应关系：

| 爬虫字段 | 数据库字段 | 类型 | 说明 |
|----------|-----------|------|------|
| year | `source_year` | int | 年份 |
| - | `source` | varchar(100) | 来源，如 `2024年408真题` |
| subject | `subject_id` | int | 科目 ID（1=DS, 2=CO, 3=OS, 4=CN） |
| question_number | `source_question_no` | int | 原始题号 |
| - | `question_type` | int | 1=单选, 5=综合应用题 |
| tags | `tags` | text | 知识标签，逗号分隔 |
| question | `title` / `title_text` | text | 题目内容 |
| answer | `correct_answer` | text | 正确答案 |
| analysis | `analysis` / `analysis_text` | text | 解析 |
| images | `images` | text | 图片路径 |

### 分数存储说明

xzs 系统中分数以**整数存储**（实际分值 × 10），例如：
- 选择题 2 分 → 数据库存储 `20`
- 综合应用题 10 分 → 数据库存储 `100`
- 试卷总分 150 分 → 数据库存储 `1500`

后端通过 `ExamUtil.scoreToVM()` 除以 10 返回给前端显示。

## 已知问题

1. **选项数据不完整**：616 道选择题中，仅 35 道有独立的 `options` 字段，其余 581 道的选项混在 `question` 文本中。`generate_sql.py` 会尝试从题目文本中解析 ABCD 选项，但无法保证 100% 成功。
2. **综合应用题内容为空**：98 道应用题中约 83 道内容为空（显示"待补充"），需要完善爬虫补全。
3. **计算机网络选择题缺失**：每年只有 8 道，缺第 39、40 题。
4. **RAG 向量未自动生成**：知识点正文已入 `t_ai_knowledge_base`，但 embedding 需要后续脚本或后台任务生成。未生成向量时，后端会用关键词检索兜底。

## 许可证

本项目仅供学习交流使用，请勿用于商业目的。
