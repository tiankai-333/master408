<template>
  <div class="developer-page">
    <header class="hero">
      <div class="hero-copy">
        <p class="eyebrow">408Master Engineering Overview</p>
        <h1>408 智能学习平台工程总览</h1>
        <p class="subtitle">
          本页面向评审和开发协作，提供系统架构、数据状态、AI/RAG 设计、接口和部署的快速导航。详细报告和开发记录见交付材料区。
        </p>
      </div>
      <div class="hero-actions">
        <a href="/student/index" class="action primary">学生端</a>
        <a href="/admin/" class="action">管理端</a>
        <a href="/admin/ai/config" class="action">AI 密钥与用量</a>
        <a :href="`${basePath}developer/poster`" class="action">80×180 易拉宝</a>
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

      <!-- 01 项目定位 -->
      <section class="panel">
        <div class="section-title">
          <span>01</span>
          <h2>项目定位</h2>
        </div>
        <p class="lead">
          408Master 基于学之思考试系统改造，把 408 真题、知识库、AI 解析、RAG 检索、学生学习事件和管理端运营能力整合成一个智能学习系统。
        </p>
        <ul class="plain-list">
          <li>学生端：刷题、批改、错题本、知识图谱和 AI 学习工作台。</li>
          <li>管理端：题库、试卷、用户、AI Provider、用量分析和数据治理。</li>
          <li>后端：Spring Boot + MyBatis，保证旧功能兼容。</li>
          <li>数据库：渐进式改造，新规范表作为长期权威来源，旧表先保留。</li>
        </ul>
      </section>

      <!-- 02 推荐演示路线 -->
      <section class="panel">
        <div class="section-title">
          <span>02</span>
          <h2>推荐演示路线</h2>
        </div>
        <div class="demo-script">
          <b>演示步骤</b>
          <ol>
            <li>打开本页讲总体架构。</li>
            <li>进入学生端 408Master，演示讲解、真题、草案、工具四个按钮。</li>
            <li>点击"草案"生成 Agent 组卷建议，再确认生成限时卷。</li>
            <li>输入 <code>/compose paper</code> 展示显式工具调用。</li>
            <li>切到管理端看题库、AI 配置、用量分析和工程记录。</li>
          </ol>
        </div>
      </section>

      <!-- 03 系统架构 -->
      <section class="panel">
        <div class="section-title">
          <span>03</span>
          <h2>系统架构</h2>
        </div>
        <div class="architecture">
          <div class="arch-row">
            <div class="arch-node">学生端 Vue<br><small>/student/index · Cookie 认证</small></div>
            <div class="arch-arrow">→</div>
            <div class="arch-node">Student API<br><small>/api/student</small></div>
            <div class="arch-arrow">→</div>
            <div class="arch-node arch-center">Spring Boot<br><small>Java 8 · 业务服务层</small></div>
            <div class="arch-arrow">→</div>
            <div class="arch-node">Admin API<br><small>/api/admin</small></div>
            <div class="arch-arrow">→</div>
            <div class="arch-node">管理端 Vue<br><small>/admin · Cookie 认证</small></div>
          </div>
          <div class="arch-row">
            <div class="arch-node">微信小程序<br><small>4 Tab · 16 页面 · Token 认证</small></div>
            <div class="arch-arrow">→</div>
            <div class="arch-node">WeChat API<br><small>/api/wx/student</small></div>
            <div class="arch-arrow">→</div>
            <div class="arch-spacer"></div>
            <div class="arch-arrow">→</div>
            <div class="arch-node">MySQL 8<br><small>业务数据 + RAG 元数据</small></div>
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
          MySQL 保存题库、用户、学习记录、AI 配置和 RAG 元数据；Qdrant 只保存向量检索所需的 vector 和 payload。
        </p>
      </section>

      <!-- 04 核心功能 -->
      <section class="panel">
        <div class="section-title">
          <span>04</span>
          <h2>核心功能</h2>
        </div>
        <ul class="plain-list">
          <li>多年 408 真题与相关题源，支持选择题和综合应用题。</li>
          <li>四种 AI 解析风格：常规、费曼、第一性原理、柏拉图式对话。</li>
          <li>AI 题目图片识别：拍照上传 → 多模态识别 → AI 解析。</li>
          <li>知识图谱与 RAG 知识库，用于减少 AI 解析幻觉。</li>
          <li>AI 学习工作台：显式区分 intent、context、style、tool，统一返回流式文本、引用、Agent 草案和组卷结果。</li>
          <li>学生学习事件、答题记录、错题本。</li>
          <li>微信小程序学生端：4 个 Tab、16 个页面、独立 /api/wx 接口和微信绑定登录。</li>
        </ul>
      </section>

      <!-- 05 数据与数据库改造 -->
      <section class="two-column">
        <article class="panel">
          <div class="section-title">
            <span>05</span>
            <h2>数据规模</h2>
          </div>
          <div class="data-table">
            <div><span>选择题</span><b>约 560 道</b></div>
            <div><span>综合题</span><b>约 98 道</b></div>
            <div><span>知识标签</span><b>658 条</b></div>
            <div><span>知识点</span><b>116</b></div>
            <div><span>题目-知识点关系</span><b>524</b></div>
            <div><span>RAG 文档 / Chunk</span><b>119</b></div>
            <div><span>Qdrant</span><b>119 个向量，维度由 API 动态决定</b></div>
          </div>
        </article>

        <article class="panel">
          <div class="section-title">
            <span>05</span>
            <h2>数据库改造</h2>
          </div>
          <div class="table-grid">
            <article v-for="group in tableGroups" :key="group.title" class="mini-card">
              <b>{{ group.title }}</b>
              <p>{{ group.desc }}</p>
              <code>{{ group.tables }}</code>
            </article>
          </div>
        </article>
      </section>

      <!-- 06 AI 与 RAG 架构 -->
      <section class="panel">
        <div class="section-title">
          <span>06</span>
          <h2>AI 与 RAG 架构</h2>
        </div>
        <p class="lead">
          AI 架构分三层：前端交互层（收集问题和上下文，SSE 接收流式响应）、后端编排层（意图路由 → Prompt 组装 → RAG 检索 → 模型调用 → 日志记录）、模型调用层（对接多服务商 OpenAI 兼容 API）。
        </p>
        <div class="flow-grid">
          <article v-for="item in aiFlow" :key="item.title" class="flow-card">
            <b>{{ item.title }}</b>
            <p>{{ item.desc }}</p>
            <code>{{ item.detail }}</code>
          </article>
        </div>
        <p class="note">
          RAG 检索支持两条路径：Qdrant 向量数据库（需显式启用）和内存余弦相似度（默认路径）。Qdrant 未启用时系统仍能正常运行。
        </p>
      </section>

      <!-- 07 知识图谱与题目关联 -->
      <section class="panel">
        <div class="section-title">
          <span>07</span>
          <h2>知识图谱与题目关联</h2>
        </div>
        <ul class="plain-list">
          <li><code>knowledge_point</code> 表支持父子层级，<code>question_knowledge_point</code> 多对多关联（含 relevance 权重）。</li>
          <li>知识图谱页面按科目展示目录树，支持搜索和层级浏览。</li>
          <li>选择知识点后查看详情、关联知识点和关联真题。</li>
          <li>列表展示使用摘要，AI 讲题时加载完整题干、选项、答案和解析。</li>
        </ul>
      </section>

      <!-- 08 小程序端 -->
      <section class="panel">
        <div class="section-title">
          <span>08</span>
          <h2>小程序端</h2>
        </div>
        <ul class="plain-list">
          <li>微信小程序原生开发，16 个页面，4 个 Tab（首页、刷题、错题、大师）。</li>
          <li>通过 <code>/api/wx/</code> 前缀的 7 个 Controller 复用后端 Service 层。</li>
          <li>支持做题、错题本、AI 多模态识题和 4 种风格 AI 分析。</li>
          <li>当前 API 地址使用 HTTP，正式上线需配置 HTTPS。</li>
        </ul>
        <div class="qrcode-block">
          <img :src="`${basePath}miniprogram-qrcode.jpg`" alt="小程序二维码" class="qrcode-img" />
          <p>微信扫码预览小程序</p>
        </div>
      </section>

      <!-- 09 接口概览 -->
      <section class="panel">
        <div class="section-title">
          <span>09</span>
          <h2>接口概览</h2>
        </div>
        <div class="api-grid">
          <div v-for="api in apis" :key="api.path" class="api-row">
            <code>{{ api.method }}</code>
            <strong>{{ api.path }}</strong>
            <span>{{ api.desc }}</span>
          </div>
        </div>
      </section>

      <!-- 10 UML 图 -->
      <section class="panel">
        <div class="section-title">
          <span>10</span>
          <h2>UML 图</h2>
        </div>
        <p class="lead">
          以下 PlantUML 生成的标准 UML 图用于说明系统结构、模块边界、AI/RAG 调用链路和核心业务对象关系。
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
      </section>

      <!-- 11 部署说明 -->
      <section class="panel">
        <div class="section-title">
          <span>11</span>
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

      <!-- 12 数据质量与边界说明 -->
      <section class="panel">
        <div class="section-title">
          <span>12</span>
          <h2>数据质量与边界说明</h2>
        </div>
        <div class="table-grid">
          <article v-for="item in dataQualityNotes" :key="item.title" class="mini-card">
            <b>{{ item.title }}</b>
            <p>{{ item.desc }}</p>
          </article>
        </div>
      </section>

      <!-- 13 Agent 与组卷能力 -->
      <section class="panel">
        <div class="section-title">
          <span>13</span>
          <h2>Agent 与组卷能力</h2>
        </div>
        <div class="agent-grid">
          <article v-for="item in agentCards" :key="item.title" class="mini-card">
            <b>{{ item.title }}</b>
            <p>{{ item.desc }}</p>
          </article>
        </div>
      </section>

      <!-- 14 文档索引 -->
      <section class="panel">
        <div class="section-title">
          <span>14</span>
          <h2>文档索引</h2>
        </div>
        <div class="doc-list">
          <div v-for="doc in docs" :key="doc.path">
            <b>{{ doc.name }}</b>
            <code>{{ doc.path }}</code>
            <p>{{ doc.desc }}</p>
          </div>
        </div>
      </section>

      <!-- 15 交付材料 -->
      <section class="panel">
        <div class="section-title">
          <span>15</span>
          <h2>交付材料</h2>
        </div>
        <div class="data-table">
          <div><span>正式报告</span><b>docs/00-deliverables/project-report-draft-v4.md</b></div>
          <div><span>开发记录</span><b>docs/00-deliverables/development-log.md</b></div>
          <div><span>工程总览页</span><b>本页（/developer）</b></div>
          <div><span>展示海报</span><b>/developer/poster</b></div>
        </div>
      </section>

      <!-- 16 开发记录入口 -->
      <section class="panel">
        <div class="section-title">
          <span>16</span>
          <h2>开发记录</h2>
        </div>
        <p class="lead">
          完整开发记录（时间线、具体改动、问题与解决方案）见 <code>docs/00-deliverables/development-log.md</code>。
          以下列出主要里程碑。
        </p>
        <div class="data-table">
          <div v-for="item in milestones" :key="item.date">
            <span>{{ item.date }}</span>
            <b>{{ item.title }}</b>
          </div>
        </div>
      </section>
    </main>
  </div>
</template>

<script setup>
const assetBase = import.meta.env.BASE_URL || '/'
const basePath = assetBase

const summaryCards = [
  { label: 'Product', value: '408Master', desc: '408 刷题 + AI 学习辅助' },
  { label: 'Backend', value: 'Spring Boot 2.1.6', desc: 'Java 8 + MyBatis' },
  { label: 'Frontend', value: 'Vue 3', desc: '学生端 / 管理端 / 小程序' },
  { label: 'Data', value: 'MySQL + Qdrant', desc: '业务数据 + 向量检索' }
]

const tableGroups = [
  {
    title: '旧题库兼容层',
    desc: '保留原系统题库、试卷和答题记录。',
    tables: 't_question, t_text_content, t_exam_paper, t_exam_paper_answer'
  },
  {
    title: '规范题目内容层',
    desc: '题干、答案、解析、来源和知识点关系。',
    tables: 'question_content, question_source, question_knowledge_point'
  },
  {
    title: 'RAG 知识库层',
    desc: 'MySQL 保存文档和切片元数据，Qdrant 保存向量。',
    tables: 'rag_document, rag_chunk, rag_embedding'
  },
  {
    title: '学生图谱层',
    desc: '学习事件、知识点掌握状态和独立错题本。',
    tables: 'student_learning_event, student_knowledge_state, student_mistake_book'
  },
  {
    title: 'AI Runtime 层',
    desc: '供应商、Skill、Agent、Prompt 和调用日志。',
    tables: 'ai_provider_config, ai_skill, ai_agent, ai_prompt_template'
  },
  {
    title: '学习档案层',
    desc: '学习画像、风格反馈和用户密钥。',
    tables: 't_user_learning_profile, t_user_skill_feedback, ai_user_key'
  }
]

const aiFlow = [
  {
    title: '1. 意图路由',
    desc: 'AiIntentRouter 识别 6 种意图：题目讲解、知识点讲解、学习画像、练习规划、组卷、自由对话。',
    detail: 'explain_question / explain_knowledge / learning_profile / practice_plan / compose_paper / free_chat'
  },
  {
    title: '2. 上下文组装',
    desc: '根据意图和前端传入的 context 组织题目、知识点、错题记录或粘贴文本。',
    detail: 'question + answerRecord / knowledgePoint / pastedText'
  },
  {
    title: '3. RAG 检索',
    desc: 'Embedding API 生成查询向量，从 Qdrant 或内存索引检索 Top-5 相关内容。',
    detail: 'RagService.retrieve() → Qdrant / 内存余弦相似度'
  },
  {
    title: '4. 模型调用',
    desc: '选择对应风格的 Prompt 模板，拼接 RAG 参考资料后调用大模型。',
    detail: 'AnalysisService.callAiApiStream() → SSE 流式输出'
  },
  {
    title: '5. Agent 草案',
    desc: '练习规划意图触发草案流程：查错题和题库，生成候选题列表供确认。',
    detail: 'AiAgentPlannerService.plan() → confirm()'
  },
  {
    title: '6. 密钥调度',
    desc: '按优先级选择 AI Provider：公共密钥 → 用户私钥 → 配置文件兜底。',
    detail: 'ai_provider_config / ai_user_key / application.yml'
  }
]

const umlViews = [
  {
    title: '用例图',
    desc: '学生、管理员与系统能力之间的关系。',
    src: `${assetBase}uml/use-case.svg`,
    source: 'docs/06-uml-standard/puml/use-case.puml'
  },
  {
    title: '组件图',
    desc: '客户端、API、应用服务、领域层和基础设施适配层的边界。',
    src: `${assetBase}uml/component.svg`,
    source: 'docs/06-uml-standard/puml/component.puml'
  },
  {
    title: '时序图：AI/RAG 流式请求',
    desc: '一次 AI 请求的检索、降级和 SSE 输出过程。',
    src: `${assetBase}uml/sequence-ai-rag.svg`,
    source: 'docs/06-uml-standard/puml/sequence-ai-rag.puml'
  },
  {
    title: '类图：核心学习领域',
    desc: '题目、试卷、知识点、学生答题与学习状态。',
    src: `${assetBase}uml/domain-class.svg`,
    source: 'docs/06-uml-standard/puml/domain-class.puml'
  },
  {
    title: '类图：RAG 元数据模型',
    desc: 'RAG 文档、切片、embedding、检索日志和引用关系。',
    src: `${assetBase}uml/rag-class.svg`,
    source: 'docs/06-uml-standard/puml/rag-class.puml'
  },
  {
    title: '类图：AI Runtime 配置',
    desc: 'AI Provider、Skill、Agent、Prompt 和运行日志。',
    src: `${assetBase}uml/ai-runtime-class.svg`,
    source: 'docs/06-uml-standard/puml/ai-runtime-class.puml'
  },
  {
    title: '部署图',
    desc: 'Nginx、Backend、MySQL、Qdrant 与 AI Provider 的部署关系。',
    src: `${assetBase}uml/deployment.svg`,
    source: 'docs/06-uml-standard/puml/deployment.puml'
  }
]

const dataQualityNotes = [
  {
    title: '关联真题展示摘要',
    desc: '知识图谱右侧列表使用轻量摘要，AI 讲题时应加载完整题干、选项、答案和解析。'
  },
  {
    title: 'HTML 题目轻量方案',
    desc: '数据库保存 HTML 引用和元数据，完整 HTML/KaTeX/表格/代码片段放在学生端静态资源中渲染。'
  },
  {
    title: 'AI 出卷边界',
    desc: '只能从题库已有题目中挑选，没有候选时只输出筛选条件，不能编造新题。写库操作必须由按钮或指令授权。'
  },
  {
    title: '展示与 AI 上下文分离',
    desc: '列表展示使用摘要，AI 上下文读取完整题面或 RAG chunk。旧表兼容阶段的典型问题。'
  }
]

const agentCards = [
  {
    title: '草案确认型 Agent',
    desc: 'agent/plan 查错题、题库和知识图谱生成草案，学生确认后 agent/confirm 调用组卷服务创建限时卷。只能使用题库已有题目。'
  },
  {
    title: '显式工具调用',
    desc: '/compose paper 作为显式快捷命令，直接创建限时卷。AiPaperComposeService 支持优先错题、知识点过滤、来源年份和题量限制。'
  },
  {
    title: 'AI 工作台 Orchestrator',
    desc: '前端只提交 intent + context + style + userMessage，后端按任务路由到画像、讲解、Agent 草案或组卷工具。'
  }
]

const apis = [
  { method: 'POST', path: '/api/user/login', desc: '管理端/学生端登录' },
  { method: 'POST', path: '/api/student/ai/analyze', desc: 'AI 解析（非流式）' },
  { method: 'POST', path: '/api/student/ai/analyze-stream', desc: 'AI 解析 SSE 流式' },
  { method: 'POST', path: '/api/student/ai/workbench/stream', desc: 'AI 工作台统一入口' },
  { method: 'POST', path: '/api/student/ai/agent/plan', desc: 'Agent 草案' },
  { method: 'POST', path: '/api/student/ai/agent/confirm', desc: '确认 Agent 草案' },
  { method: 'POST', path: '/api/student/ai/compose-paper', desc: 'AI 辅助组卷' },
  { method: 'POST', path: '/api/student/question/analyze-image', desc: '多模态图片识别' },
  { method: 'POST', path: '/api/student/question/analyze-question-stream', desc: '错题本 AI 分析 SSE' },
  { method: 'GET', path: '/api/student/ai/styles', desc: '四种解析风格列表' },
  { method: 'GET', path: '/api/student/user/stats', desc: '用户学习统计' },
  { method: 'GET', path: '/api/student/knowledge-graph/graph', desc: '知识图谱数据' },
  { method: 'GET', path: '/api/student/knowledge-graph/knowledge-point/{id}', desc: '知识点详情' },
  { method: 'POST', path: '/api/admin/ai-config/providers', desc: 'AI 供应商列表（脱敏）' },
  { method: 'POST', path: '/api/admin/ai-config/provider/save', desc: '保存供应商（密钥加密）' },
  { method: 'POST', path: '/api/admin/ai-config/rag/index', desc: 'RAG 索引构建' },
  { method: 'POST', path: '/api/wx/student/auth/bind', desc: '微信绑定' }
]

const deploySteps = [
  {
    title: '数据库初始化',
    command: 'mysql -u root -p xzs < database/current/*.sql',
    desc: '按 database/current/README.md 顺序导入。'
  },
  {
    title: '后端打包',
    command: 'cd source/xzs && mvn -DskipTests package',
    desc: '生成 xzs-3.9.0.jar，复制到 deploy 目录。'
  },
  {
    title: '前端构建',
    command: 'cd source/vue/xzs-admin && npm run build',
    desc: '管理端 base 为 /admin/，学生端 base 为 /student/。'
  },
  {
    title: '容器启动',
    command: 'docker compose -f deploy/docker-compose.yml up -d --build',
    desc: '启动 MySQL、Qdrant、Backend、Nginx。'
  },
  {
    title: '验证',
    command: 'curl -I http://服务器IP/',
    desc: '根地址应 302 到 /student/index。'
  }
]

const docs = [
  { name: '项目总 README', path: 'README.md', desc: '系统能力、目录结构和启动方式。' },
  { name: '文档总索引', path: 'docs/README.md', desc: '需求、记录、经验、部署和交付材料索引。' },
  { name: '数据库导入顺序', path: 'database/current/README.md', desc: '当前部署必需 SQL 和每个脚本职责。' },
  { name: '部署目录说明', path: 'deploy/README.md', desc: 'Docker Compose、Nginx、后端和静态资源部署方式。' },
  { name: 'AI/RAG 开发记录', path: 'docs/02-work-records/2026-05-ai-rag-development-log.md', desc: 'AI、Skill、Agent、RAG 和小程序阶段成果。' },
  { name: '部署经验', path: 'docs/04-deployment/deployment-experience.md', desc: '远程部署、SQL 顺序和验证经验。' }
]

const milestones = [
  { date: '2026-04-22', title: '项目启动：Fork 开源系统，UI 品牌化' },
  { date: '2026-05-14', title: 'Vue 2 → Vue 3 完整迁移，数据库扩展' },
  { date: '2026-05-15', title: '题库爬虫与数据导入' },
  { date: '2026-05-16', title: 'AI 解析风格、SSE 流式、Docker 部署' },
  { date: '2026-05-17', title: '知识图谱页面' },
  { date: '2026-05-17~19', title: 'AI 工作台、RAG、意图路由、Agent 草案' },
  { date: '2026-05-27~28', title: 'HTML 题库扩展、AI 编排器完善' },
  { date: '2026-05-29', title: 'UI 修复、测试账号、小程序补齐' }
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
.flow-card,
.uml-card {
  background: #fff;
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  box-shadow: 0 12px 30px rgba(15, 23, 42, .06);
}

.metric-card,
.mini-card,
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

.plain-list {
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

.qrcode-block {
  margin-top: 18px;
  text-align: center;
}

.qrcode-img {
  width: 180px;
  height: 180px;
  border-radius: 8px;
  border: 1px solid #e2e8f0;
}

.qrcode-block p {
  margin: 8px 0 0;
  color: #64748b;
  font-size: 13px;
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
  .flow-grid,
  .agent-grid,
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
