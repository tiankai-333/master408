<template>
  <div class="developer-page">
    <header class="hero">
      <div class="hero-copy">
        <p class="eyebrow">408Master Developer Brief</p>
        <h1>408 智能学习系统工程说明</h1>
        <p class="subtitle">
          这是一页不需要登录的演示说明，面向评审、开发协作和部署交接。它把 README、数据库脚本、AI/RAG 规划、部署手册和最近工程工作收束成一条可以讲清楚的主线。
        </p>
      </div>
      <div class="hero-actions">
        <a href="/student/index" class="action primary">学生端</a>
        <a href="/admin/" class="action">管理端</a>
        <a href="/admin/ai/config" class="action">AI 密钥与用量</a>
      </div>
    </header>

    <main class="content">
      <section class="summary-grid">
        <article v-for="item in summaryCards" :key="item.label" class="metric-card">
          <span>{{ item.label }}</span>
          <strong>{{ item.value }}</strong>
          <p>{{ item.desc }}</p>
        </article>
      </section>

      <section class="panel">
        <div class="section-title">
          <span>01</span>
          <h2>项目定位</h2>
        </div>
        <div class="position-layout">
          <div>
            <p class="lead">
              408Master 基于学之思考试系统改造，目标不是只做一个刷题站，而是把 408 真题、知识库、AI 解析、RAG 检索、学生学习事件和管理端运营能力整合成一个智能学习系统。
            </p>
            <ul class="plain-list">
              <li>学生端负责刷题、批改、错题、知识图谱和 AI 学习工作台。</li>
              <li>管理端负责题库、试卷、用户、AI Provider、用量分析和数据治理。</li>
              <li>后端继续沿用 Spring Boot + MyBatis，保证旧功能兼容。</li>
              <li>数据库采用渐进式改造，新规范表作为长期权威来源，旧表先保留。</li>
            </ul>
          </div>
          <div class="demo-script">
            <b>推荐演示顺序</b>
            <ol>
              <li>打开本页讲总体架构。</li>
              <li>进入学生端 408Master，演示讲解、真题、草案、工具四个按钮。</li>
              <li>点击“草案”生成 Agent 组卷建议，再确认生成限时卷。</li>
              <li>输入 <code>/compose paper</code> 展示显式工具调用。</li>
              <li>切到管理端看题库、AI 配置、用量分析和本页工程记录。</li>
            </ol>
          </div>
        </div>
      </section>

      <section class="panel">
        <div class="section-title">
          <span>02</span>
          <h2>系统架构</h2>
        </div>
        <div class="architecture">
          <div class="arch-row">
            <div class="arch-node">学生端 Vue<br><small>/student/index · Cookie 认证</small></div>
            <div class="arch-arrow">→</div>
            <div class="arch-node">Student API<br><small>/api/student</small></div>
            <div class="arch-arrow">→</div>
            <div class="arch-node arch-center" rowspan>Spring Boot<br><small>Java 8 · 业务服务层</small></div>
            <div class="arch-arrow">→</div>
            <div class="arch-node">Admin API<br><small>/api/admin</small></div>
            <div class="arch-arrow">→</div>
            <div class="arch-node">管理端 Vue<br><small>/admin · Cookie 认证</small></div>
          </div>
          <div class="arch-row">
            <div class="arch-node">微信小程序<br><small>4 Tab · 13 页面 · Token 认证</small></div>
            <div class="arch-arrow">→</div>
            <div class="arch-node">WeChat API<br><small>/api/wx/student</small></div>
            <div class="arch-arrow">→</div>
            <div class="arch-spacer"></div>
            <div class="arch-arrow">→</div>
            <div class="arch-node">MySQL 8<br><small>权威业务数据 + RAG 元数据</small></div>
          </div>
          <div class="arch-row muted">
            <div class="arch-spacer"></div>
            <div class="arch-spacer"></div>
            <div class="arch-spacer"></div>
            <div class="arch-arrow">←</div>
            <div class="arch-node">Qdrant<br><small>向量检索 · 119 chunks</small></div>
            <div class="arch-arrow">←</div>
            <div class="arch-node">RAG Service<br><small>chunk / citation / log</small></div>
            <div class="arch-arrow">←</div>
            <div class="arch-node">AI Provider<br><small>GLM / DeepSeek / OpenAI</small></div>
          </div>
        </div>
        <p class="note">
          MySQL 保存题库、用户、学习记录、AI 配置和 RAG 元数据；Qdrant 只保存向量检索所需的 vector 和 payload。这样云服务器不必长期运行本地大模型，离线或 API 生成 embedding 后再上传即可。
        </p>
      </section>

      <section class="panel">
        <div class="section-title">
          <span>03</span>
          <h2>UML 分析与读图指南</h2>
        </div>
        <p class="lead">
          UML 适合用来讲清楚“谁在使用系统、模块怎么分工、一次 AI 请求怎么流转、核心业务对象如何关联”。本页已改用 PlantUML 生成的标准 UML SVG，不再用 Mermaid 近似模拟用例图、组件图和部署图。
        </p>
        <div class="uml-stack">
          <article v-for="item in umlViews" :key="item.title" class="uml-card">
            <div>
              <b>{{ item.title }}</b>
              <p>{{ item.desc }}</p>
            </div>
            <div class="uml-image-frame">
              <img :src="item.src" :alt="item.title" class="uml-svg" />
            </div>
            <p class="uml-source">PlantUML 源文件：<code>{{ item.source }}</code></p>
          </article>
        </div>
        <div class="decision-list">
          <div v-for="item in umlGuide" :key="item.question">
            <strong>{{ item.question }}</strong>
            <p>{{ item.answer }}</p>
          </div>
        </div>
      </section>

      <section class="two-column">
        <article class="panel">
          <div class="section-title">
            <span>04</span>
            <h2>当前数据状态</h2>
          </div>
          <div class="data-table">
            <div><span>408 题目</span><b>658</b></div>
            <div><span>知识点</span><b>116</b></div>
            <div><span>RAG 文档</span><b>119</b></div>
            <div><span>RAG Chunk</span><b>119</b></div>
            <div><span>题目-知识点关系</span><b>524</b></div>
            <div><span>Qdrant</span><b>xzs_408_chunks：119 个 1024 维向量</b></div>
          </div>
        </article>

        <article class="panel">
          <div class="section-title">
            <span>05</span>
            <h2>核心能力</h2>
          </div>
          <ul class="plain-list">
            <li>2011-2024 年 408 真题题库，支持选择题和综合应用题。</li>
            <li>四种 AI 解析 Skill：常规、费曼、第一性原理、柏拉图式对话。</li>
            <li>AI 题目图片识别：拍照上传 → OCR → AI 解析，支持拍照刷题场景。</li>
            <li>知识图谱与 RAG 知识库，用于减少 AI 解析幻觉。</li>
            <li>学生学习事件、答题记录、错题本，为学生图谱打基础。</li>
            <li>微信小程序学生端：4 个 Tab（首页/刷题/错题/我的）、13 个页面、独立 /api/wx 接口和微信绑定登录。</li>
          </ul>
        </article>
      </section>

      <section class="panel">
        <div class="section-title">
          <span>06</span>
          <h2>数据库主线</h2>
        </div>
        <div class="table-grid">
          <article v-for="group in tableGroups" :key="group.title" class="mini-card">
            <b>{{ group.title }}</b>
            <p>{{ group.desc }}</p>
            <code>{{ group.tables }}</code>
          </article>
        </div>
        <p class="note">
          当前策略是渐进兼容：旧的 <code>t_question</code>、<code>t_text_content</code>、<code>t_ai_knowledge_base</code> 继续保留；新代码逐步优先读取 <code>question_content</code>、<code>rag_document</code>、<code>rag_chunk</code>、<code>student_*</code>、<code>ai_provider_config</code> 等规范表。
        </p>
      </section>

      <section class="two-column">
        <article class="panel">
          <div class="section-title">
            <span>08</span>
            <h2>AI 密钥与安全</h2>
          </div>
          <ul class="plain-list">
            <li>管理端入口：<code>/admin/ai/config</code>。</li>
            <li>密钥保存在 <code>ai_provider_config.api_key_cipher</code>，前端只显示掩码。</li>
            <li>加密算法：<code>AES/GCM/NoPadding</code>。</li>
            <li>主密钥来自 <code>AI_SECRET_MASTER_KEY</code>，生产环境必须固定保存。</li>
            <li>智谱 GLM 的对话和 embedding 共用同一个 API Key；embedding 模型默认 <code>embedding-2</code>。</li>
          </ul>
        </article>

        <article class="panel">
          <div class="section-title">
            <span>09</span>
            <h2>RAG 设计</h2>
          </div>
          <ul class="plain-list">
            <li><code>rag_document</code> 保存文档来源、权限、版本、hash 和业务元数据。</li>
            <li><code>rag_chunk</code> 保存切片文本、位置、token 数和知识点关系。</li>
            <li><code>rag_embedding</code> 保存向量库 collection、vector_id、模型和状态。</li>
            <li><code>rag_retrieval_log</code> 和 <code>rag_answer_citation</code> 用于检索追踪和回答可溯源。</li>
            <li>向量库当前选用 Qdrant，后续通过 <code>RagIndexService</code> 替换成本可控。</li>
          </ul>
        </article>
      </section>

      <section class="panel">
        <div class="section-title">
          <span>07</span>
          <h2>数据质量与关联真题策略</h2>
        </div>
        <div class="table-grid">
          <article v-for="item in dataQualityNotes" :key="item.title" class="mini-card">
            <b>{{ item.title }}</b>
            <p>{{ item.desc }}</p>
            <code>{{ item.detail }}</code>
          </article>
        </div>
        <p class="note">
          当前产品策略是“列表轻、AI 重”：知识图谱右侧关联真题列表只展示题目摘要，避免页面拥挤；但当学生点击“结合真题讲解”时，后续应由后端加载完整题干、选项、答案、解析和来源，再交给 AI。这样既能保持界面清爽，也能避免 AI 拿半截题面讲题。
        </p>
      </section>

      <section class="panel">
        <div class="section-title">
          <span>10</span>
          <h2>模型切换与调用链路</h2>
        </div>
        <div class="flow-grid">
          <article v-for="item in modelFlow" :key="item.title" class="flow-card">
            <b>{{ item.title }}</b>
            <p>{{ item.desc }}</p>
            <code>{{ item.detail }}</code>
          </article>
        </div>
        <p class="note">
          当前实现是“管理端启用哪个 Provider，运行时优先用哪个 Provider”：AI 解析走第一个启用的对话模型，RAG embedding 走启用的智谱 embedding 配置。下一步可以升级为“模型路由”：管理端配置多个模型，学生端或 Agent Runtime 在每次请求里传入 <code>providerCode</code>、<code>model</code>、<code>taskType</code>，后端根据权限、额度、场景和 fallback 策略选择最终模型。
          AI 回复已新增 SSE 流式输出：RAG 先检索，随后模型生成内容边到达边推给前端；前端逐段追加到消息气泡，失败时自动回退旧的一次性接口。
        </p>
      </section>

      <section class="panel">
        <div class="section-title">
          <span>11</span>
          <h2>Agent、任务、卷子与 Memory</h2>
        </div>
        <div class="agent-grid">
          <article v-for="item in agentRoadmap" :key="item.title" class="mini-card">
            <b>{{ item.title }}</b>
            <p>{{ item.desc }}</p>
            <code>{{ item.tables }}</code>
          </article>
        </div>
        <div class="decision-list">
          <div v-for="item in aiDecisions" :key="item.question">
            <strong>{{ item.question }}</strong>
            <p>{{ item.answer }}</p>
          </div>
        </div>
      </section>

      <section class="panel">
        <div class="section-title">
          <span>12</span>
          <h2>显式 AI 工具调用</h2>
        </div>
        <p class="lead">
          学生端 AI 工作台已从“单纯聊天框”升级为受控工具入口：主对话区提供讲解、真题、草案、工具四类按钮；自然语言先生成组卷草案，学生点击确认后才写库；<code>/compose paper</code> 仍保留为显式快捷命令。
        </p>
        <div class="flow-grid">
          <article v-for="item in toolCallFlow" :key="item.title" class="flow-card">
            <b>{{ item.title }}</b>
            <p>{{ item.desc }}</p>
            <code>{{ item.detail }}</code>
          </article>
        </div>
        <p class="note">
          按钮语义：<code>讲解</code> 解释当前题目或知识点；<code>真题</code> 按 408 考法拆解；<code>草案</code> 进入 <code>/api/student/ai/agent/plan</code>；<code>工具</code> 填入 <code>/compose paper</code> 并走显式组卷函数。Agent 当前调用 <code>search_student_mistakes</code>、<code>search_questions</code>、<code>get_knowledge_graph_context</code> 和 <code>compose_paper</code> 四类内部工具。AI 只生成意图、参数和解释，题目真实性与落库由后端规则服务保证。
        </p>
      </section>

      <section class="panel">
        <div class="section-title">
          <span>13</span>
          <h2>接口文档摘要</h2>
        </div>
        <div class="api-grid">
          <div v-for="api in apis" :key="api.path" class="api-row">
            <code>{{ api.method }}</code>
            <strong>{{ api.path }}</strong>
            <span>{{ api.desc }}</span>
          </div>
        </div>
      </section>

      <section class="panel">
        <div class="section-title">
          <span>14</span>
          <h2>部署说明</h2>
        </div>
        <div class="deploy-steps">
          <div v-for="step in deploySteps" :key="step.title" class="step">
            <b>{{ step.title }}</b>
            <code>{{ step.command }}</code>
            <p>{{ step.desc }}</p>
          </div>
        </div>
      </section>

      <section class="two-column">
        <article class="panel">
          <div class="section-title">
            <span>15</span>
            <h2>文档索引</h2>
          </div>
          <div class="doc-list">
            <div v-for="doc in docs" :key="doc.path">
              <b>{{ doc.name }}</b>
              <code>{{ doc.path }}</code>
              <p>{{ doc.desc }}</p>
            </div>
          </div>
        </article>

        <article class="panel">
          <div class="section-title">
            <span>16</span>
            <h2>工程协作</h2>
          </div>
          <ul class="timeline">
            <li>使用 <code>main</code>、<code>dev</code>、<code>feature/*</code>、<code>refactor/*</code>、<code>deploy/*</code> 分支隔离任务。</li>
            <li>通过 Pull Request 合并 UI、品牌化、学生端、部署和 AI/RAG 阶段成果。</li>
            <li>部分前端 UI 改造由 Copilot coding agent 辅助完成，团队成员确认和合并。</li>
            <li>当前 AI/RAG 主线分支为 <code>codex/ai-knowledge-rag</code>。</li>
            <li>工程记录沉淀在 <code>docs/02-work-records</code> 和 <code>docs/03-engineering-experience</code>。</li>
          </ul>
        </article>
      </section>

      <section class="panel">
        <div class="section-title">
          <span>17</span>
          <h2>近期完成</h2>
        </div>
        <div class="work-grid">
          <div v-for="item in recentWork" :key="item" class="work-item">{{ item }}</div>
        </div>
      </section>
    </main>
  </div>
</template>

<script setup>
const assetBase = import.meta.env.BASE_URL || '/'

const summaryCards = [
  { label: 'Product', value: '408Master', desc: '408 刷题 + AI 学习辅助' },
  { label: 'Backend', value: 'Spring Boot 2.1.6', desc: 'Java 8 + MyBatis' },
  { label: 'Frontend', value: 'Vue 3', desc: '学生端 / 管理端 / 小程序' },
  { label: 'Data', value: 'MySQL + Qdrant', desc: '业务数据 + 向量检索' }
]

const tableGroups = [
  {
    title: '旧题库兼容层',
    desc: '保留原系统题库、试卷和答题记录，保证线上功能不被破坏。',
    tables: 't_question, t_text_content, t_exam_paper, t_exam_paper_answer'
  },
  {
    title: '规范题目内容层',
    desc: '把题干、答案、解析、资源、来源和知识点关系收束为长期权威模型。',
    tables: 'question_content, question_asset, question_source, question_knowledge_point'
  },
  {
    title: 'RAG 知识库层',
    desc: 'MySQL 保存文档和切片元数据，Qdrant 保存向量数据。',
    tables: 'rag_document, rag_chunk, rag_embedding, rag_retrieval_log'
  },
  {
    title: '学生图谱层',
    desc: '从答题结果升级为学习事件、知识点掌握状态和独立错题本。',
    tables: 'student_learning_event, student_knowledge_state, student_mistake_book'
  },
  {
    title: 'AI Runtime 层',
    desc: '把供应商、Skill、Agent、Prompt、Tool 和调用日志纳入数据库管理。',
    tables: 'ai_provider_config, ai_skill, ai_agent, ai_prompt_template, ai_run_log'
  },
  {
    title: '数据管线层',
    desc: '原始爬虫、OCR、清洗结果和规范导入数据分层管理。',
    tables: 'data/raw, data/staging, data/canonical, data/exports'
  }
]

const umlViews = [
  {
    title: '标准用例图：系统对谁提供什么能力',
    desc: '用 actor 和 use case 表达学生、管理员、开发者/评审与系统能力之间的关系。',
    src: `${assetBase}uml/use-case.svg`,
    source: 'docs/06-uml-standard/puml/use-case.puml'
  },
  {
    title: '标准组件图：模块边界与依赖',
    desc: '用组件和依赖关系说明客户端、API、应用服务、领域层和基础设施适配层的边界。',
    src: `${assetBase}uml/component.svg`,
    source: 'docs/06-uml-standard/puml/component.puml'
  },
  {
    title: '标准时序图：一次 AI/RAG 流式请求',
    desc: '用 lifeline、调用消息、返回消息和 alt 分支说明一次 AI 请求的检索、降级和 SSE 输出过程。',
    src: `${assetBase}uml/sequence-ai-rag.svg`,
    source: 'docs/06-uml-standard/puml/sequence-ai-rag.puml'
  },
  {
    title: '标准类图：核心学习领域',
    desc: '用类、属性、方法、多重性和中间关联类描述题目、试卷、知识点、学生答题与学习状态。',
    src: `${assetBase}uml/domain-class.svg`,
    source: 'docs/06-uml-standard/puml/domain-class.puml'
  },
  {
    title: '标准类图：RAG 元数据模型',
    desc: '单独说明 RAG 文档、切片、embedding、检索日志和引用关系，避免和核心题库领域混在一起。',
    src: `${assetBase}uml/rag-class.svg`,
    source: 'docs/06-uml-standard/puml/rag-class.puml'
  },
  {
    title: '标准类图：AI Runtime 配置模型',
    desc: '单独说明 AI Provider、Skill、Agent、Prompt 和运行日志，它是运行时配置模型，不是核心题库领域。',
    src: `${assetBase}uml/ai-runtime-class.svg`,
    source: 'docs/06-uml-standard/puml/ai-runtime-class.puml'
  },
  {
    title: '标准部署图：Docker 与外部服务',
    desc: '用 node、artifact、database 和 cloud 表达 Nginx、Backend、MySQL、Qdrant 与 AI Provider 的部署关系。',
    src: `${assetBase}uml/deployment.svg`,
    source: 'docs/06-uml-standard/puml/deployment.puml'
  }
]

const umlGuide = [
  {
    question: 'UML 是什么？',
    answer: 'UML 是统一建模语言，用图来描述软件系统。它不是某种框架，也不是必须生成代码；它的价值是让需求、模块、流程和数据关系能被看懂、讨论和复盘。'
  },
  {
    question: '这个项目最该画哪些 UML？',
    answer: '四张就够：用例图讲用户目标，组件图讲模块边界，时序图讲 AI/RAG 调用链路，领域类图讲题目、知识点、学生图谱、RAG 和 Agent 的核心对象。'
  },
  {
    question: '什么时候不该画 UML？',
    answer: '不要把每个 Controller、Mapper、字段都画进去，那会变成噪音。UML 应该服务于解释系统，而不是复印代码。'
  },
  {
    question: '怎么向评审讲？',
    answer: '先用用例图说明系统服务学生和管理员，再用组件图说明模块化单体架构，然后用时序图讲 AI 流式/RAG 过程，最后用领域类图说明数据库为什么要从旧表走向规范模型。'
  }
]

const dataQualityNotes = [
  {
    title: '关联真题为什么会截断',
    desc: '知识图谱右侧列表目前使用轻量摘要，后端会把题干缩短用于展示，因此列表里的题目不是完整题面。',
    detail: 'KnowledgeGraphServiceImpl.trimToLength(..., 72)'
  },
  {
    title: '选项从哪里来',
    desc: '选择题选项主要保存在旧题库 JSON 的 questionItemObjects，部分新字段也有 options；综合应用题天然可能没有选项。',
    detail: 't_text_content.content.questionItemObjects / t_question.options'
  },
  {
    title: 'AI 讲题应该拿完整上下文',
    desc: '列表可以保持摘要，但点击关联真题讲解时，应由后端加载完整题干、选项、答案、解析和来源，再交给 AI。',
    detail: 'list summary, prompt full context'
  },
  {
    title: '知识点过长如何处理',
    desc: '知识点列表展示会摘要化，避免页面过挤；AI 上下文不应直接依赖展示摘要，而应读取规范知识点正文或 RAG chunk。',
    detail: 'knowledgeSummary() for UI only'
  },
  {
    title: '数据治理方向',
    desc: '2026 模拟卷采用“数据库存引用 + 静态 HTML 片段渲染”的轻量方案，避免把超大 HTML、SVG、KaTeX 和表格直接塞进旧 TEXT 字段。',
    detail: 'question-html-ref + /student/question-html/2026/'
  },
  {
    title: '质量判断',
    desc: '不是简单的数据坏了，而是旧表兼容、展示摘要和 AI 输入上下文边界没有完全分开；这是渐进改造阶段的典型问题。',
    detail: 'compatibility + serving contract'
  }
]

const modelFlow = [
  {
    title: '1. 前端发起请求',
    desc: '学生在 408Master 工作台选择讲法、任务类型和上下文，后续可增加模型选择下拉框。',
    detail: 'style + taskType + question + context + optional providerCode/model'
  },
  {
    title: '2. 后端组装上下文',
    desc: 'AnalysisService 合并题目、知识点、学生状态、RAG 引用和 Skill Prompt。',
    detail: 'Question + KnowledgePoint + RagChunk + StudentGraph'
  },
  {
    title: '3. 模型路由',
    desc: '当前使用第一个启用 Provider；推荐升级为按任务选择对话模型、embedding 模型和 fallback。',
    detail: 'AiProviderConfigService.getFirstEnabled() / model router'
  },
  {
    title: '4. RAG 检索',
    desc: 'embedding 查询 Qdrant，返回 chunk 后再回 MySQL 取权威文档、来源和权限。',
    detail: 'rag_chunk + rag_embedding + Qdrant vector_id'
  },
  {
    title: '5. Agent 调用工具',
    desc: '当前先落地显式 slash 指令：/compose paper 生成限时练习卷。后续再注册为 Agent Tool。',
    detail: 'composePaper + AiPaperComposeService'
  },
  {
    title: '6. 用量与引用落库',
    desc: '模型请求、Token、费用、检索命中和回答引用写入日志，供管理端用量分析。',
    detail: 't_ai_usage_log + ai_run_log + rag_answer_citation'
  },
  {
    title: '7. 流式输出',
    desc: '后端使用 SSE 推送 status、references、chunk、done、error 事件，前端 fetch stream 边收边渲染，减少等待焦虑。',
    detail: '/api/student/ai/analyze-stream + /api/student/question/analyze-question-stream'
  }
]

const toolCallFlow = [
  {
    title: '1. 用户提出目标',
    desc: '学生用自然语言说出薄弱点或点击“生成练习卷”，前端进入 Agent 草案流程。',
    detail: '/api/student/ai/agent/plan'
  },
  {
    title: '2. Agent 查询工具',
    desc: '后端先查错题，再查题库，并读取知识图谱上下文，生成可解释草案，不写数据库。',
    detail: 'search_student_mistakes + search_questions'
  },
  {
    title: '3. 学生确认草案',
    desc: '草案卡片展示题量、限时、候选题、候选是否不足和推荐理由，学生点击确认才执行。',
    detail: '/api/student/ai/agent/confirm'
  },
  {
    title: '4. 规则服务落库',
    desc: 'AiPaperComposeService 只使用草案中的已有题目 ID 创建限时卷，不允许编造题目。',
    detail: 'compose_paper + ExamPaperService'
  },
  {
    title: '5. 保留快捷命令',
    desc: '手动输入 /compose paper 仍可直接创建限时卷，用于演示显式工具调用。',
    detail: '/compose paper'
  },
  {
    title: '6. 运行日志',
    desc: '草案和确认动作写入 ai_run_log，记录工具调用、候选题和最终试卷结果。',
    detail: 'ai_run_log.tool_call_json'
  }
]

const agentRoadmap = [
  {
    title: '草案确认型 Agent',
    desc: '已落地 agent/plan + agent/confirm。Agent 先查错题、题库和知识图谱生成草案，学生确认后才调用 compose_paper 写入限时卷。',
    tables: 'ai_run_log, QuestionMapper.selectForAiPaper, t_exam_paper'
  },
  {
    title: 'Memory 处理',
    desc: '建议分为长期记忆、学习状态、会话摘要和用户偏好。长期记忆必须可查看、可删除、可关闭，学习状态由事件自动更新。',
    tables: 'student_memory, student_learning_event, student_knowledge_state, ai_conversation_summary'
  },
  {
    title: '学生专属 Key',
    desc: '可以做，但默认不建议开放给普通学生。更安全的方式是管理员配置统一 Provider；学生 BYOK 只作为高级选项，密钥单独加密、只归本人使用、可设置限额。',
    tables: 'student_ai_provider_config, ai_usage_quota, t_ai_usage_log'
  },
  {
    title: 'Memory 维护入口',
    desc: '可以放在 /student/user/index 的新标签页里，展示“AI 记忆、学习偏好、专属 Key、用量”。这需要新增学生端 API，确保学生只能读写自己的数据。',
    tables: 'student_memory, student_preference, student_ai_provider_config'
  },
  {
    title: '权限边界',
    desc: '管理端看全局 Provider、成本和审计；学生端只能看自己的 memory、偏好和个人 key 掩码，不能读取管理员 key。',
    tables: 'admin ai_provider_config / student student_ai_provider_config'
  }
]

const aiDecisions = [
  {
    question: '模型切换会允许有好几个模型吗？',
    answer: '会，而且应该允许。Provider 是供应商层，model 是具体模型层。一个 DeepSeek、智谱或 OpenAI Provider 下可以配置多个 chatModel、embeddingModel 和默认用途。当前页面是最小可用版，先以“一行 Provider 一个默认对话模型 + 一个 embedding 模型”运行。'
  },
  {
    question: 'Agent 能不能帮学生出任务和卷子？',
    answer: '能。当前采用草案确认型 Agent：自然语言先生成组卷草案，学生确认后才调用 AiPaperComposeService。/compose paper 仍作为显式快捷命令保留。'
  },
  {
    question: '现在有 Memory 吗？',
    answer: '现在已有答题记录、错题、学习事件和知识点状态的基础，不等于完整 Memory。完整 Memory 应该新增可维护的 student_memory，并把“用户主动写入的偏好”和“系统自动推断的学习状态”分开。'
  },
  {
    question: '学生能不能在个人中心维护 Memory？',
    answer: '可以，入口适合放在 /student/user/index 的新标签页。界面应提供查看、编辑、删除、暂停记忆、清空会话摘要等操作，并明确哪些记忆来自用户输入、哪些来自系统推断。'
  },
  {
    question: '学生能不能管理自己的专属 Key？',
    answer: '可以，但要谨慎。适合做成 BYOK 高级设置：学生 key 只用于本人请求，后端加密保存，前端只显示掩码，支持测试连接、停用、删除、用量上限和费用提醒。默认仍走管理员配置，避免学生误填或泄露。'
  }
]

const apis = [
  { method: 'POST', path: '/api/user/login', desc: '管理端/学生端登录' },
  { method: 'POST', path: '/api/student/user/register', desc: '学生注册' },
  { method: 'POST', path: '/api/student/ai/analyze', desc: '学生端 AI 解析（非流式）' },
  { method: 'POST', path: '/api/student/ai/analyze-stream', desc: '学生端 AI 解析 SSE 流式：status/references/chunk/done/error' },
  { method: 'POST', path: '/api/student/ai/agent/plan', desc: 'Agent 草案：查错题、题库和知识图谱，返回组卷建议但不落库' },
  { method: 'POST', path: '/api/student/ai/agent/confirm', desc: '确认 Agent 草案：用已有题目 ID 创建限时卷' },
  { method: 'POST', path: '/api/student/ai/compose-paper', desc: '显式 AI 工具调用：从题库已有题中生成 1-5 题限时卷' },
  { method: 'POST', path: '/api/student/chat', desc: 'AI 聊天对话，408Master 人设' },
  { method: 'POST', path: '/api/student/question/analyze-question-stream', desc: '错题本 AI 分析 SSE 流式' },
  { method: 'POST', path: '/api/student/question/analyze-image', desc: '拍照上传 → OCR → AI 解析' },
  { method: 'GET', path: '/api/student/ai/styles', desc: '四种 Skill 风格列表' },
  { method: 'GET', path: '/api/student/user/stats', desc: '用户学习统计（题量、正确率、薄弱点）' },
  { method: 'GET', path: '/api/student/knowledge-graph/graph', desc: '知识图谱节点与边' },
  { method: 'GET', path: '/api/student/knowledge-graph/question/{id}/knowledge-points', desc: '题目关联知识点、子知识点和关联真题摘要' },
  { method: 'GET', path: '/api/student/knowledge-graph/knowledge-point/{id}/questions', desc: '按知识点查关联真题列表，当前返回展示摘要，后续应补完整题面接口' },
  { method: 'POST', path: '/api/admin/ai-config/providers', desc: 'AI 供应商配置列表，密钥只返回掩码' },
  { method: 'POST', path: '/api/admin/ai-config/provider/save', desc: '保存供应商、模型和 API Key' },
  { method: 'POST', path: '/api/admin/ai-config/provider/{id}/test', desc: '后端测试供应商连接' },
  { method: 'POST', path: '/api/admin/ai-config/usage', desc: 'AI 请求、Token、费用、成功率统计' },
  { method: 'GET', path: '/api/admin/ai-agent/templates', desc: 'Prompt 模板列表' },
  { method: 'GET', path: '/api/admin/ai-agent/knowledge-base', desc: '知识库条目列表' },
  { method: 'POST', path: '/api/admin/ai-agent/template/{id}/test', desc: '测试 Prompt 模板' },
  { method: 'POST', path: '/api/wx/student/auth/bind', desc: '微信账号绑定登录' },
  { method: 'POST', path: '/api/wx/student/auth/checkBind', desc: '检查微信是否已绑定' }
]

const deploySteps = [
  {
    title: '数据库初始化',
    command: 'mysql -u root -p xzs < database/current/*.sql',
    desc: '必须按 database/current/README.md 顺序导入，只导入 current，不导入 archive。'
  },
  {
    title: '后端打包',
    command: 'cd source/xzs && mvn -DskipTests package',
    desc: '生成 xzs-3.9.0.jar，复制到 deploy 目录构建 Docker 镜像。'
  },
  {
    title: '前端构建',
    command: 'cd source/vue/xzs-admin && npm run build',
    desc: '管理端生产 base 为 /admin/，学生端生产 base 为 /student/，学生端默认首页路由为 /student/index。'
  },
  {
    title: '容器启动',
    command: 'docker compose -f deploy/docker-compose.yml up -d --build',
    desc: '启动 MySQL、Qdrant、Backend、Nginx。Nginx 负责静态资源和 /api/ 反向代理。'
  },
  {
    title: '线上验证',
    command: 'curl -I http://服务器IP/',
    desc: '根地址应 302 到 /student/index；再验证学生端、管理端、API、数据库、Qdrant 和静态图片路径。'
  }
]

const docs = [
  { name: '项目总 README', path: 'README.md', desc: '系统能力、目录结构、启动方式和关键入口。' },
  { name: '文档总索引', path: 'docs/README.md', desc: '需求、记录、经验、部署、数据和交付材料索引。' },
  { name: '数据库导入顺序', path: 'database/current/README.md', desc: '当前部署必需 SQL 和每个脚本职责。' },
  { name: '部署目录说明', path: 'deploy/README.md', desc: 'Docker Compose、Nginx、后端 jar、静态资源部署方式。' },
  { name: 'AI/RAG 开发记录', path: 'docs/02-work-records/2026-05-ai-rag-development-log.md', desc: 'AI 知识库、Skill、Agent、RAG 和小程序阶段成果。' },
  { name: 'GitHub 协作记录', path: 'docs/02-work-records/github-collaboration-workflow.md', desc: '分支、PR、审核和 AI agent 协作记录。' },
  { name: '数据库改进建议', path: 'docs/03-engineering-experience/数据库分析与改进建议.md', desc: '旧表问题、索引、字符集、AI 表治理建议。' },
  { name: '部署经验', path: 'docs/04-deployment/deployment-experience.md', desc: '远程部署、SQL 顺序、localhost 配置和验证经验。' }
]

const recentWork = [
  '稳定版阶段收束：学生端试卷中心、错题本、AI 学习工作台、知识点 HTML 渲染和本地初始化脚本完成一轮可演示修复。',
  '重建 CSGraduates HTML 真题与模拟卷导入链路：数据库仅保存 HTML 轻引用、来源、纯文本摘要和元数据，题干/解析片段与图片资源放入学生端 public 静态目录。',
  '扩展题库范围：补齐 408 真题/模拟卷、数学一/二/三、英语一/二、思想政治理论的可见 HTML 题库导入脚本。',
  '新增 408 四科知识点 HTML 化导入：knowledge_content 保存 html_ref、summary_text、source_url、asset_dir，知识点正文保留表格、公式、图片、代码块和层级标题。',
  'AI 学习工作台改为“先选上下文，再生成画像/练习”：顶部保留生成学习画像、生成针对练习，中间提供随机知识点、随机真题、随机错题、粘贴四个上下文入口。',
  'AI 工作台随机范围支持三层筛选：初始全库随机，点击左侧科目后限定到科目，选择知识点后限定到该知识点关联真题/错题。',
  '优化 AI 工作台上下文展示：题目上下文显示科目标签、来源标题和题目正文，去掉重复来源；粘贴只进入上方上下文卡片，不再填充对话输入框。',
  '修复知识点富文本过宽问题：中间列 min-width 归零，右侧栏固定，宽表格、代码块、大图在上下文卡片内部滚动，装饰性 SVG 图标不再撑爆阅读区。',
  '试卷中心修复：左侧只使用真实科目，408 综合不再等同全部科目，分页按总页数显示，开始答题和科目切换改为一次点击生效。',
  '补充 408 四科近年专项卷：数据结构、计算机组成原理、操作系统、计算机网络各生成近年固定练习卷，题目仍引用原始单科题。',
  '错题本和题目详情体验修复：选项、解析、正确答案展示去重，解析布局不再和难度挤在一行，AI 分析 Provider 表缺失时后端安全降级。',
  '整理初始化 SQL：新增 database/current/00_init_database_with_seed.sql 一键导入结构、题库、HTML 真题、知识点和演示数据。',
  '测试账号更新：默认测试用户改为 test / 123456，演示数据脚本清理旧 231310423 引用并为 test 重建做题记录和错题样例。',
  '登录注册体验修复：登录页取消用户名必须大于 5 个字符的限制，注册页继续走学生注册接口和默认年级兜底。',
  '微信小程序补齐错题本与 AI 题目识别入口，复用学生端题目详情和 Markdown 渲染能力。',
  '注册取消年级强依赖，默认年级兜底为 1。',
  '修复学生端错题本分页切换问题。',
  '新增规范题目内容、RAG、学生图谱、Agent/Skill/Tool 表。',
  '从旧题库和知识库回填 question_content、question_knowledge_point、rag_document、rag_chunk。',
  '部署 Qdrant，并在后端增加 RagIndexService 抽象。',
  '使用智谱 embedding-2 写入 Qdrant：119 个 chunk 全部 indexed。',
  '新增 AI Provider 密钥管理、测试连接和用量分析页面。',
  '根地址默认跳转 /student/index，学生端 Vue Router 使用 /student/ base。',
  'API Key 采用 AES/GCM 加密保存，前端只显示掩码。',
  'AI 解析和 embedding 调用写入 t_ai_usage_log。',
  '新增 AI 回复 SSE 流式输出，知识图谱和错题本解析可以边生成边展示。',
  '管理端生产路径修正为 /admin/，Vue Router base 同步修正。',
  '新增公开 Developer Brief 页面，用于答辩和演示。',
  '学生端 Dashboard AI 学习工作台重设计：hero 区、知识节点动画、快捷入口和技能模式面板。',
  '学生端 UI 刷新：试卷列表、做题记录、错题本、AI 解析页面优化。',
  'AI 工作台 prompt 解耦和稳定性修复，讲法切换和任务类型独立。',
  '修复 AI 流式输出中 JSON null 被误当成正文 token 的问题，避免回答开头出现 nullnull。',
  '修复 AI 失败态：流式失败和非流式重试都失败时，只显示明确失败信息，不再追加本地假回答。',
  '补充 API Key 主密钥说明：本地 Docker backend 显式使用 AI_SECRET_MASTER_KEY，避免加密密钥随 application.yml 变化。',
  '梳理关联真题和知识点摘要截断原因：列表展示使用摘要，AI 讲题应改为加载完整题面、选项、答案和解析。',
  '限制 AI 练习/出卷边界：只能从题库已有题目中挑选 1-5 题，没有候选时只输出筛选条件，不能编造新题。',
  '新增显式函数调用：学生端 /compose paper 生成限时练习卷，写库操作必须由按钮/指令授权。',
  '新增草案确认型 Agent：/agent/plan 先生成组卷草案，/agent/confirm 经学生确认后创建限时卷。',
  '408Master 交流页按钮重设计：输入框底部只保留发送，主对话区提供讲解、真题、草案、工具四类入口。',
  '草案确认型 Agent 已接入前端：自然语言生成组卷草案，用户确认后才创建限时卷。',
  '显式工具调用继续保留：/compose paper 仍作为可演示的直接组卷函数入口。',
  '本地部署验证完成：学生端构建通过，静态资源同步到 Nginx，知识图谱和 AI 工作台页面可访问。',
  '新增 AiPaperComposeService：支持优先错题、知识点过滤、来源年份、排除样题、限时分钟数和题量限制。',
  '新增 2026 HTML 模拟卷轻量导入方案：数据库保存 question-html-ref、纯文本和内容标签，完整 HTML/KaTeX/表格/代码片段放在学生端静态资源中渲染。',
  '新增 QuestionHtml 组件，让试卷页面、答案查看页面能加载外部 HTML 片段并复用 /images 静态图片路径。',
  '新增 AI 题目图片识别（拍照 → OCR → 解析），学生端 /question/ai-analyze 页面。',
  'Canonical AI/RAG 架构整合提交：Agent/Provider/RAG/StudentGraph 服务、SSE 流式、5 个新数据库迁移脚本。'
]
</script>

<style scoped>
.developer-page {
  min-height: 100vh;
  background: #f5f7fb;
  color: #1f2937;
}

.hero {
  min-height: 390px;
  padding: 56px 72px 42px;
  display: flex;
  align-items: flex-end;
  justify-content: space-between;
  gap: 32px;
  background:
    linear-gradient(rgba(10, 20, 35, .66), rgba(10, 20, 35, .58)),
    url('https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1800&q=80') center/cover;
  color: #fff;
}

.hero-copy {
  max-width: 850px;
}

.eyebrow {
  margin: 0 0 10px;
  font-size: 13px;
  letter-spacing: 0;
  text-transform: uppercase;
  opacity: .82;
}

.hero h1 {
  margin: 0;
  font-size: 48px;
  line-height: 1.12;
  font-weight: 700;
}

.subtitle {
  margin: 18px 0 0;
  font-size: 17px;
  line-height: 1.8;
  opacity: .93;
}

.hero-actions {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
  justify-content: flex-end;
}

.action {
  display: inline-flex;
  align-items: center;
  height: 38px;
  padding: 0 16px;
  border-radius: 6px;
  background: rgba(255,255,255,.14);
  color: #fff;
  text-decoration: none;
  border: 1px solid rgba(255,255,255,.32);
}

.action.primary {
  background: #2f80ed;
  border-color: #2f80ed;
}

.content {
  max-width: 1320px;
  margin: -32px auto 0;
  padding: 0 24px 52px;
}

.summary-grid,
.two-column,
.table-grid,
.work-grid,
.flow-grid,
.agent-grid {
  display: grid;
  gap: 16px;
}

.summary-grid {
  grid-template-columns: repeat(4, minmax(0, 1fr));
}

.two-column {
  grid-template-columns: repeat(2, minmax(0, 1fr));
  margin-top: 16px;
}

.table-grid {
  grid-template-columns: repeat(3, minmax(0, 1fr));
}

.work-grid {
  grid-template-columns: repeat(2, minmax(0, 1fr));
}

.flow-grid {
  grid-template-columns: repeat(3, minmax(0, 1fr));
}

.uml-stack {
  display: grid;
  grid-template-columns: minmax(0, 1fr);
  gap: 22px;
  margin-top: 16px;
}

.agent-grid {
  grid-template-columns: repeat(3, minmax(0, 1fr));
}

.metric-card,
.panel,
.mini-card,
.work-item,
.flow-card,
.uml-card {
  background: #fff;
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  box-shadow: 0 12px 30px rgba(15, 23, 42, .06);
}

.metric-card,
.mini-card,
.work-item,
.flow-card,
.uml-card {
  padding: 18px;
}

.metric-card span {
  color: #64748b;
  font-size: 13px;
}

.metric-card strong {
  display: block;
  margin-top: 8px;
  font-size: 22px;
}

.metric-card p,
.mini-card p,
.flow-card p,
.uml-card p,
.doc-list p,
.step p {
  margin: 8px 0 0;
  color: #64748b;
  line-height: 1.7;
}

.panel {
  margin-top: 16px;
  padding: 24px;
}

.two-column .panel {
  margin-top: 0;
}

.section-title {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 18px;
}

.section-title span {
  width: 34px;
  height: 34px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  background: #e8f1ff;
  color: #2563eb;
  font-weight: 700;
}

.section-title h2 {
  margin: 0;
  font-size: 22px;
}

.position-layout {
  display: grid;
  grid-template-columns: minmax(0, 1fr) 360px;
  gap: 22px;
}

.lead {
  margin: 0 0 14px;
  color: #334155;
  font-size: 16px;
  line-height: 1.9;
}

.demo-script {
  border: 1px solid #dbe3ee;
  border-radius: 8px;
  background: #f8fafc;
  padding: 18px;
}

.demo-script ol {
  margin: 10px 0 0;
  padding-left: 20px;
  line-height: 1.9;
}

.architecture {
  display: grid;
  gap: 8px;
  align-items: center;
}

.arch-row {
  display: grid;
  grid-template-columns: 1fr 34px 1fr 34px 1fr 34px 1fr 34px 1fr;
  gap: 10px;
  align-items: center;
}

.arch-node {
  min-height: 78px;
  padding: 16px;
  border: 1px solid #dbe3ee;
  border-radius: 8px;
  background: #f8fafc;
  font-weight: 700;
}

.arch-node small {
  display: block;
  margin-top: 6px;
  font-weight: 400;
  color: #64748b;
}

.arch-arrow {
  text-align: center;
  color: #64748b;
  font-size: 22px;
}

.arch-spacer {
}

.arch-center {
  background: #e8f1ff;
  border-color: #93c5fd;
}

.muted {
  opacity: .82;
}

.note {
  margin: 18px 0 0;
  color: #475569;
  line-height: 1.8;
}

.plain-list,
.timeline {
  margin: 0;
  padding-left: 18px;
  line-height: 1.9;
  color: #334155;
}

code {
  background: #f1f5f9;
  border: 1px solid #e2e8f0;
  border-radius: 4px;
  padding: 2px 6px;
  color: #0f172a;
}

.data-table {
  display: grid;
  gap: 10px;
}

.data-table div {
  display: flex;
  justify-content: space-between;
  gap: 12px;
  padding: 11px 12px;
  background: #f8fafc;
  border: 1px solid #e2e8f0;
  border-radius: 6px;
}

.data-table span {
  color: #64748b;
}

.data-table b {
  text-align: right;
}

.api-grid {
  display: grid;
  gap: 10px;
}

.api-row {
  display: grid;
  grid-template-columns: 90px minmax(240px, .9fr) 1fr;
  gap: 12px;
  align-items: center;
  padding: 12px;
  border: 1px solid #e2e8f0;
  border-radius: 6px;
  background: #f8fafc;
}

.deploy-steps {
  display: grid;
  grid-template-columns: repeat(5, minmax(0, 1fr));
  gap: 12px;
}

.step {
  padding: 16px;
  border: 1px solid #e2e8f0;
  border-radius: 8px;
  background: #f8fafc;
}

.step code,
.mini-card code {
  display: block;
  margin-top: 10px;
  overflow-wrap: anywhere;
}

.flow-card code {
  display: block;
  margin-top: 10px;
  overflow-wrap: anywhere;
}

.uml-image-frame {
  margin: 14px 0 0;
  padding: 16px;
  overflow-x: auto;
  border: 1px solid #dbe3ee;
  border-radius: 8px;
  background: #ffffff;
}

.uml-svg {
  display: block;
  width: 100%;
  min-width: 900px;
  height: auto;
}

.uml-source {
  margin: 10px 0 0;
  color: #64748b;
  font-size: 13px;
}

.decision-list {
  display: grid;
  gap: 12px;
  margin-top: 18px;
}

.decision-list div {
  padding: 14px 16px;
  border: 1px solid #dbeafe;
  border-radius: 8px;
  background: #f8fbff;
}

.decision-list strong {
  color: #1e3a8a;
}

.decision-list p {
  margin: 8px 0 0;
  color: #334155;
  line-height: 1.8;
}

.doc-list {
  display: grid;
  gap: 12px;
}

.doc-list div {
  padding: 12px;
  background: #f8fafc;
  border: 1px solid #e2e8f0;
  border-radius: 6px;
}

.doc-list code {
  display: inline-block;
  margin-top: 8px;
}

.work-item {
  color: #334155;
  line-height: 1.7;
}

@media (max-width: 980px) {
  .hero {
    padding: 42px 24px 34px;
    flex-direction: column;
    align-items: flex-start;
  }

  .hero h1 {
    font-size: 36px;
  }

  .summary-grid,
  .two-column,
  .table-grid,
  .work-grid,
  .flow-grid,
  .uml-grid,
  .agent-grid,
  .position-layout,
  .deploy-steps {
    grid-template-columns: 1fr;
  }

  .architecture,
  .api-row {
    grid-template-columns: 1fr;
  }

  .arch-arrow {
    display: none;
  }
}
</style>
