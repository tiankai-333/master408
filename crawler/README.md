# 408考研真题爬虫

## 概述

本爬虫用于从 [csgraduates.com](https://www.csgraduates.com) 网站爬取计算机学科专业基础综合考试（408）的历年真题和知识点数据。

## 功能特性

- ✅ 爬取2011-2024年408历年真题（选择题+综合应用题）
- ✅ 支持图片本地化下载，避免依赖外部URL
- ✅ 智能识别题目科目（数据结构、组成原理、操作系统、计算机网络）
- ✅ 生成CSV和JSON格式数据
- ✅ 自动生成SQL导入文件
- ✅ 支持断点续爬

## 目录结构

```
crawler/
├── README.md                    # 本文件
├── config.json                  # 配置文件
├── requirements.txt             # Python依赖
├── main.py                     # 主入口
├── quick_start.py              # 快速启动脚本
├── exam_crawler_with_images.py  # 选择题爬虫（含图片）
├── improved_exam_crawler.py     # 改进版选择题爬虫
├── improved_essay_crawler.py    # 综合应用题爬虫
├── analyze_html.py              # HTML结构分析工具
├── check_images.py              # 图片检查工具
├── check_detailed_images.py     # 详细图片检查
├── data/                       # 爬取的数据
│   ├── exam_questions.csv       # 选择题数据
│   ├── exam_questions.json      # 选择题JSON
│   ├── essay_questions.csv      # 综合应用题数据
│   ├── image_manifest.json      # 图片清单
│   └── images/                 # 本地图片
│       ├── 2011_OS_27_1.svg    # 图片示例
│       └── ...
└── __pycache__/               # Python缓存
```

## 安装

### 1. 安装Python依赖

```bash
cd crawler
pip install -r requirements.txt
```

依赖包括：
- requests: HTTP请求
- beautifulsoup4: HTML解析
- lxml: 快速XML/HTML解析器

### 2. 配置

编辑 `config.json` 文件：

```json
{
  "base_url": "https://www.csgraduates.com",
  "crawl_settings": {
    "delay_seconds": 1,
    "max_retries": 3,
    "timeout_seconds": 30
  },
  "output": {
    "knowledge_base": "data/knowledge_base.json",
    "exam_papers": "data/exam_papers.json"
  }
}
```

## 使用方法

### 方法一：快速启动

```bash
python quick_start.py
```

### 方法二：命令行参数

#### 查看所有可爬取内容
```bash
python main.py --list-chapters
```

#### 爬取所有内容
```bash
python main.py
```

#### 只爬取选择题
```bash
python main.py --exam-only
```

#### 只爬取综合应用题
```bash
python main.py --essay-only
```

#### 指定年份范围
```bash
python main.py --start-year 2020 --end-year 2024
```

#### 只爬取特定科目
```bash
python main.py --subject data_structure
```

#### 自定义输出文件
```bash
python main.py --output my_data.json
```

### 方法三：使用专业爬虫

#### 爬取选择题（含图片）
```bash
python exam_crawler_with_images.py --start-year 2011 --end-year 2024 --manifest
```

#### 爬取综合应用题
```bash
python improved_essay_crawler.py
```

## 数据格式

### 选择题 CSV 格式

```csv
year,subject,question_type,question_number,question,options,answer,analysis,images
2011,数据结构,真题,1,"题目内容...","[{"key":"A","value":"选项A"},{"key":"B","value":"选项B"}]","A","解析内容...","data/images/xxx.svg"
```

### 综合应用题 CSV 格式

```csv
year,subject,question_no,title,total_score,answer,analysis,images
2011,数据结构,41,"题目内容...",10,"参考答案...","解析...","data/images/xxx.svg"
```

### 图片清单 JSON 格式

```json
{
  "total_images": 17,
  "images": [
    {
      "original_url": "https://www.csgraduates.com/images/xxx.svg",
      "local_path": "data\\images\\2011_OS_27_1.svg"
    }
  ]
}
```

## 图片处理

### 下载的图片类型

- **SVG图片**: 矢量图形，如流程图、框图
- **PNG/JPG图片**: 位图，如照片、复杂图形
- **ASCII图形**: 直接作为文本提取

### 图片命名规则

```
{年份}_{科目代码}_{题号}_{图片序号}.{扩展名}
```

科目代码对照：
- 数据结构 → DS
- 计算机组成原理 → CO
- 操作系统 → OS
- 计算机网络 → CN

示例：
- `2011_OS_27_1.svg` = 2011年操作系统第27题第1张图片

## 爬取数据统计

### 选择题

| 年份 | 数据结构 | 组成原理 | 操作系统 | 计算机网络 | 总计 |
|------|---------|---------|---------|-----------|------|
| 2011 | 11 | 11 | 10 | 8 | 40 |
| 2012-2024 | ... | ... | ... | ... | 40 |

总计：**616道** 选择题

### 综合应用题

每年7道大题，分布如下：
- 数据结构: 2道
- 计算机组成原理: 2道
- 操作系统: 2道
- 计算机网络: 1道

总计：**98道** 综合应用题（2011-2024年）

### 图片

- 选择题图片: ~17张
- 综合应用题图片: ~3张

## 生成SQL文件

爬虫可以自动生成SQL导入文件：

```bash
python exam_crawler_with_images.py --start-year 2011 --end-year 2024 --manifest
```

这会生成以下SQL文件：
- `database/02_exam_questions.sql` - 选择题SQL
- `database/06_essay_questions.sql` - 综合应用题SQL

## 注意事项

1. **尊重网站规则**: 爬虫已设置1秒延迟，避免对服务器造成压力
2. **图片本地化**: 所有图片会下载到本地，不再依赖外部URL
3. **断点续爬**: 爬虫支持中断后继续
4. **字符编码**: 所有文件使用UTF-8编码，确保中文正常显示

## 故障排除

### 问题：图片下载失败

检查：
1. 网络连接是否正常
2. 目标URL是否可访问
3. 是否有防火墙阻止

### 问题：爬取数据不完整

检查：
1. 网站结构是否变化
2. 配置文件是否正确
3. 是否有反爬虫机制

### 问题：中文乱码

解决：
1. 确保文件保存为UTF-8编码
2. 数据库使用utf8mb4字符集

## 相关文档

- [数据库说明文档](../database/README.md) - 数据库结构和导入说明
- [数据库更新日志](../database/README.md#数据库更新说明) - 最新更新内容

## 许可证

本项目仅供学习交流使用，请勿用于商业目的。
