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
              <li>进入学生端做一道 408 题。</li>
              <li>展示 AI 解析和知识点关联。</li>
              <li>切到管理端看题库与 AI 配置。</li>
              <li>回到本页讲数据库、RAG、部署和协作记录。</li>
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
          <div class="arch-node">学生端 Vue<br><small>/student/index</small></div>
          <div class="arch-arrow">→</div>
          <div class="arch-node">Student API<br><small>/api/student</small></div>
          <div class="arch-arrow">→</div>
          <div class="arch-node">Spring Boot<br><small>业务服务层</small></div>
          <div class="arch-node">管理端 Vue<br><small>/admin</small></div>
          <div class="arch-arrow">→</div>
          <div class="arch-node">Admin API<br><small>/api/admin</small></div>
          <div class="arch-arrow">→</div>
          <div class="arch-node">MySQL 8<br><small>权威业务数据</small></div>
          <div class="arch-node muted">Qdrant<br><small>向量检索</small></div>
          <div class="arch-arrow muted">←</div>
          <div class="arch-node muted">RAG Service<br><small>chunk / citation / log</small></div>
          <div class="arch-arrow muted">←</div>
          <div class="arch-node muted">AI Provider<br><small>GLM / DeepSeek / OpenAI</small></div>
        </div>
        <p class="note">
          MySQL 保存题库、用户、学习记录、AI 配置和 RAG 元数据；Qdrant 只保存向量检索所需的 vector 和 payload。这样云服务器不必长期运行本地大模型，离线或 API 生成 embedding 后再上传即可。
        </p>
      </section>

      <section class="two-column">
        <article class="panel">
          <div class="section-title">
            <span>03</span>
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
            <span>04</span>
            <h2>核心能力</h2>
          </div>
          <ul class="plain-list">
            <li>2011-2024 年 408 真题题库，支持选择题和综合应用题。</li>
            <li>四种 AI 解析 Skill：常规、费曼、第一性原理、柏拉图式对话。</li>
            <li>知识图谱与 RAG 知识库，用于减少 AI 解析幻觉。</li>
            <li>学生学习事件、答题记录、错题本，为学生图谱打基础。</li>
            <li>微信小程序学生端已跑通基础登录、试卷列表、做题记录链路。</li>
          </ul>
        </article>
      </section>

      <section class="panel">
        <div class="section-title">
          <span>05</span>
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
            <span>06</span>
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
            <span>07</span>
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
          <span>08</span>
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
          <span>09</span>
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
          <span>10</span>
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

      <section class="two-column">
        <article class="panel">
          <div class="section-title">
            <span>12</span>
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
            <span>13</span>
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
          <span>14</span>
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
    desc: 'Agent 可以调用题目推荐、错题查询、知识图谱、RAG 检索、任务生成等工具。',
    detail: 'ai_agent + ai_skill + ai_tool + ai_run_log'
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

const agentRoadmap = [
  {
    title: 'Agent 出任务',
    desc: '可以做。Agent 根据学生知识点掌握度、错题、近期练习和目标日期生成学习任务，最后落到现有 task/task_exam 体系或新的 ai_generated_task 草稿表。',
    tables: 'student_knowledge_state, student_mistake_book, task_exam, ai_generated_task'
  },
  {
    title: 'Agent 出卷子',
    desc: '可以做，但应分两步：先生成“组卷方案”，由规则校验题型、难度、知识点覆盖和重复题；再写入 exam_paper。不要让模型直接写最终试卷。',
    tables: 'question_knowledge_point, question_content, exam_paper, exam_paper_question_customer_answer'
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
    answer: '能。推荐让 Agent 输出结构化计划：目标、知识点覆盖、题目数量、难度比例、来源限制，然后由后端规则服务真正选题和落库。这样既能利用 AI 的规划能力，又不会让模型绕过题库、权限和组卷规则。'
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
  { method: 'POST', path: '/api/user/login', desc: '管理端登录' },
  { method: 'POST', path: '/api/student/user/register', desc: '学生注册，年级字段默认兜底' },
  { method: 'POST', path: '/api/admin/question/page', desc: '管理端题目分页' },
  { method: 'POST', path: '/api/admin/question/edit', desc: '题目录入/编辑，同步 question_content' },
  { method: 'POST', path: '/api/student/ai/analyze', desc: '学生端 AI 解析' },
  { method: 'POST', path: '/api/student/ai/analyze-stream', desc: '学生端 AI 解析流式输出，SSE 事件：status/references/chunk/done/error' },
  { method: 'POST', path: '/api/student/question/analyze-question-stream', desc: '错题本 AI 分析流式输出，前端逐段追加到解析区' },
  { method: 'GET', path: '/api/student/ai/styles', desc: '四种 Skill 风格列表' },
  { method: 'GET', path: '/api/student/knowledge-graph/graph', desc: '学生端知识图谱' },
  { method: 'POST', path: '/api/admin/ai-config/providers', desc: 'AI 供应商配置列表，密钥只返回掩码' },
  { method: 'POST', path: '/api/admin/ai-config/provider/save', desc: '保存供应商、模型和 API Key' },
  { method: 'POST', path: '/api/admin/ai-config/provider/{id}/test', desc: '后端测试供应商连接' },
  { method: 'POST', path: '/api/admin/ai-config/usage', desc: 'AI 请求、Token、费用、成功率统计' },
  { method: 'GET', path: '/api/admin/ai-agent/rag/debug', desc: 'RAG 调试检索' },
  { method: 'POST', path: '/api/student/agent/chat', desc: '建议新增：学生端 Agent 对话，支持模型路由、memory 和工具调用' },
  { method: 'POST', path: '/api/student/agent/task-plan', desc: '建议新增：Agent 生成学习任务草稿' },
  { method: 'POST', path: '/api/student/agent/paper-plan', desc: '建议新增：Agent 生成组卷方案，由后端规则服务落卷' },
  { method: 'GET', path: '/api/student/memory/list', desc: '建议新增：学生查看自己的 AI 记忆' },
  { method: 'POST', path: '/api/student/memory/save', desc: '建议新增：学生维护自己的偏好和长期记忆' },
  { method: 'POST', path: '/api/student/ai-key/save', desc: '建议新增：学生保存个人专属 Key，只返回掩码' }
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
  '注册取消年级强依赖，默认年级兜底为 1。',
  '修复学生端错题本分页切换问题。',
  '新增规范题目内容、RAG、学生图谱、Agent/Skill/Tool 表。',
  '从旧题库和知识库回填 question_content、question_knowledge_point、rag_document、rag_chunk。',
  '部署 Qdrant，并在后端增加 RagIndexService 抽象。',
  '使用智谱 embedding-2 写入 Qdrant：119 个 chunk 全部 indexed。',
  '新增 AI Provider 密钥管理、测试连接和用量分析页面。',
  '根地址默认跳转 /student/index，学生端 Vue Router 使用 /student/ base，修复不带后缀访问出错。',
  'API Key 采用 AES/GCM 加密保存，前端只显示掩码。',
  'AI 解析和 embedding 调用写入 t_ai_usage_log。',
  '新增 AI 回复 SSE 流式输出，408Master 和错题本解析可以边生成边展示。',
  '管理端生产路径修正为 /admin/，Vue Router base 同步修正。',
  '新增公开 Developer Brief 页面，用于答辩和演示。'
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

.agent-grid {
  grid-template-columns: repeat(3, minmax(0, 1fr));
}

.metric-card,
.panel,
.mini-card,
.work-item,
.flow-card {
  background: #fff;
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  box-shadow: 0 12px 30px rgba(15, 23, 42, .06);
}

.metric-card,
.mini-card,
.work-item,
.flow-card {
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
  grid-template-columns: 1fr 34px 1fr 34px 1fr;
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
