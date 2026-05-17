# GitHub 团队协作与分支工作流记录

## 价值定位

这部分适合在项目汇报中作为“工程协作能力”来讲。它不只是代码提交记录，而是体现团队如何把需求拆成分支、通过 PR 合并、保留审查记录、逐步把功能集成到 `main`。

可以总结为：

- 使用 GitHub 远端分支隔离不同任务，降低互相覆盖风险。
- 使用 Pull Request 作为更新与合并入口，保留需求、变更说明和合并记录。
- 使用 `dev`、`feature/*`、`refactor/*`、`deploy/*` 等分支表达不同工作类型。
- 使用 Copilot coding agent 辅助 UI 改造，并由团队成员发起/合并 PR。
- 通过 `main` 保持相对稳定版本，通过功能分支推进较大改造。

## 当前可见分支

| 分支 | 作用 |
|---|---|
| `main` | 稳定主线，已经合入 UI、AI、部署等阶段成果。 |
| `dev` | 开发集成分支，承接 AI RAG、Skill、NPE 修复等集成工作。 |
| `codex/ai-knowledge-rag` | 当前 AI 知识库、RAG、Agent、爬虫、文档整理分支。 |
| `feature/ai` | AI RAG 原始开发分支。 |
| `feature/crawler-and-exam-data` | 408 真题爬虫、题库数据和前端视图重构分支。 |
| `feature/ui-branding` | 前端品牌和 UI 修改分支。 |
| `refactor/vue3-migration` | Vue2 到 Vue3 迁移相关分支。 |
| `deploy/docker-infra` | Docker 部署配置分支。 |
| `copilot/*` | Copilot agent 创建的自动化辅助修改分支。 |

旧的临时分支如果没有形成独立可演示能力，不建议在汇报中突出。

## 可见 Pull Request 记录

| PR | 时间 | 发起方 | 主题 | 结果 | 汇报价值 |
|---|---|---|---|---|---|
| [#1](https://github.com/tiankai-333/master408/pull/1) | 2026-04-22 | Copilot | 管理端现代扁平 UI、408master 品牌、去版权 | 已合并到 `main` | 说明从旧系统到项目品牌化的第一步。 |
| [#2](https://github.com/tiankai-333/master408/pull/2) | 2026-04-22 | Copilot | 管理端全局视觉优化 | 已合并到 `main`，有 APPROVED 审核记录 | 体现 PR 审核和设计系统迭代。 |
| [#3](https://github.com/tiankai-333/master408/pull/3) | 2026-04-22 | Copilot | 前端统一 408master 品牌和视觉刷新 | 已合并到 `dev` | 体现先在开发分支集成，再逐步进入主线。 |
| [#4](https://github.com/tiankai-333/master408/pull/4) | 2026-04-24 | 团队成员 | 系统名、版权、图标修改 | 已合并到 `main` | 体现人工确认和团队维护。 |
| [#5](https://github.com/tiankai-333/master408/pull/5) | 2026-04-28 | Copilot | 学生端 UI 对齐管理端 408master 品牌 | 已合并到 `feature/ui-branding` | 体现跨端一致性和可访问性修复。 |
| [#6](https://github.com/tiankai-333/master408/pull/6) | 2026-04-28 | 团队成员 | 前端修改 | 已合并到 `main` | 体现功能分支成果进入稳定主线。 |

其中 PR #2 可见一次 `APPROVED` 审核记录，说明项目不是单纯直接推送，而是出现过明确的审核动作。

## 分支演进线索

从当前 git 历史可见几条比较适合讲的演进线：

1. UI 品牌化线：`copilot/*` → `feature/ui-branding` → `main`
2. Vue 迁移线：`refactor/vue3-migration` → 后续功能分支复用前端基础
3. 数据和爬虫线：`feature/crawler-and-exam-data` → AI/RAG 知识库建设
4. AI 能力线：`feature/ai` → `dev` → `main` / `codex/ai-knowledge-rag`
5. 部署线：`deploy/docker-infra` → `main`

这些线索可以在汇报中说明团队不是一次性堆代码，而是按“界面、数据、AI、部署”分阶段推进。

## 可以写进项目汇报的经验

### 1. 分支命名让工作边界更清楚

例如 `feature/ai`、`feature/crawler-and-exam-data`、`refactor/vue3-migration`、`deploy/docker-infra` 分别对应功能、数据、重构和部署。相比所有人直接提交到 `main`，这种方式更容易定位问题来源。

### 2. PR 描述沉淀了变更原因

多个 PR 的正文保留了需求目标、修改范围、构建问题和风险提示。例如 UI 改造 PR 中记录了 Node/Sass 兼容问题、构建环境网络限制等，这些都是后续复盘和汇报的材料。

### 3. 人工成员和 AI agent 可以协作

Copilot agent 负责部分可拆解、边界清晰的前端 UI 改造，团队成员负责发起、确认、合并和后续集成。这可以作为“AI 辅助软件工程”的实践点来讲。

### 4. 先功能分支验证，再合入稳定主线

学生端 UI 先合入 `feature/ui-branding`，再由 PR #6 合入 `main`。这比直接改主线更适合多人协作。

### 5. 当前仍可改进

- PR 标题和正文可以更规范，统一使用 `feat:`、`fix:`、`docs:`、`deploy:`。
- 每个 PR 可以补充测试截图、构建命令和验证结果。
- 重要 PR 应要求至少一名同学 review 后再合并。
- `main` 可设置保护规则，要求 PR 合并、禁止直接 push。
- 分支完成后及时删除无用短期分支，降低噪音。

## 汇报表述建议

可以这样概括：

> 项目采用 GitHub 分支协作方式推进。团队将 UI 品牌化、Vue3 迁移、AI/RAG、爬虫数据、Docker 部署拆分到不同分支，通过 Pull Request 合并到 `dev` 或 `main`。PR 记录保留了需求目标、变更范围、审核状态和合并历史，使项目不仅能展示最终功能，也能展示工程化协作过程。部分前端改造由 Copilot coding agent 辅助完成，团队成员进行确认与合并，形成了人机协作的软件开发实践。
