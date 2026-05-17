# docs

项目文档、工作记录、工程经验和交付材料目录。这里的目标是把“做了什么、为什么做、怎么做、遇到什么问题、如何协作和部署”沉淀下来，方便后续写项目汇报、答辩展示、复盘总结和团队交接。

## 目录索引

| 目录 | 用途 | 适合什么时候看 |
|---|---|---|
| `00-deliverables/` | 最终报告、答辩 PPT 等交付物。 | 提交、答辩、展示。 |
| `01-requirements-plan/` | 需求文档、功能规划、开发流程总览。 | 写开题/需求分析/总体设计。 |
| `02-work-records/` | 实际开发记录、GitHub 协作、阶段成果。 | 写项目过程、团队协作、个人贡献。 |
| `03-engineering-experience/` | Vue 迁移、数据库治理、AI 测试、问题排查经验。 | 写技术难点、工程经验、踩坑复盘。 |
| `04-deployment/` | 云端部署、远程交接、上线排查。 | 部署上线、交接给能 SSH 的同学。 |
| `05-data-pipeline/` | 真题 OCR、题目清洗、知识点/题库数据处理资料。 | 写数据来源、数据清洗、知识库建设。 |
| `99-legacy-doc-site/` | 原文档站静态产物和旧 guide 页面。 | 只作历史保留，不作为当前汇报主线。 |

## 汇报主线建议

可以按 5 条线组织汇报：

1. **需求与规划**：从传统考试系统升级为 408 智能学习系统。
2. **数据底座**：真题 OCR、题目清洗、数据库整理、知识点爬虫。
3. **核心功能**：RAG 减少幻觉、四种 Skill 解析、Agent 学习档案和反馈闭环。
4. **工程升级**：Vue2 到 Vue3 迁移、数据库治理、乱码和部署问题处理。
5. **团队协作**：GitHub 分支、PR、审核、Copilot agent 辅助开发。

## 推荐阅读顺序

1. `01-requirements-plan/development-workflow-overview.md`
2. `02-work-records/2026-05-ai-rag-development-log.md`
3. `02-work-records/github-collaboration-workflow.md`
4. `02-work-records/ui-learning-experience-branch.md`
5. `03-engineering-experience/Vue2ToVue3Migration.md`
6. `03-engineering-experience/数据库结构分析报告.md`
7. `03-engineering-experience/problem-solving-log.md`
8. `04-deployment/deployment-experience.md`
9. `04-deployment/朋友远程部署操作手册.md`
10. `00-deliverables/408Master_AI_RAG_项目报告.docx`
11. `00-deliverables/408Master_AI_RAG_答辩展示.pptx`

## 维护原则

- 新的开发过程、问题排查和验证结果优先写 Markdown，便于 Git diff。
- 最终提交材料可放 DOCX/PPTX，但应保留清晰文件名。
- 旧静态文档站和构建产物统一放入 `99-legacy-doc-site/`，避免干扰当前项目资料。
- 重要变更要同步到 `02-work-records/`，以后写项目汇报会省很多力气。
