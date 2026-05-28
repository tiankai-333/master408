<template>
  <div class="poster-page">
    <div class="toolbar">
      <a :href="`${basePath}developer`">返回 Developer Brief</a>
      <button type="button" @click="printPoster">打印 / 导出 PDF</button>
    </div>

    <main class="poster-sheet">
      <section class="poster-hero">
        <div>
          <p class="eyebrow">408Master Intelligent Learning System</p>
          <h1>408Master<br />智能学习系统</h1>
          <p class="subtitle">
            从真题、知识图谱到 AI Orchestrator 的考研学习平台
          </p>
        </div>
        <img :src="logoSrc" alt="408Master" class="brand-mark" />
      </section>

      <section class="value-band">
        <div>
          <strong>真题与模拟卷</strong>
          <span>408 / 数学 / 英语 / 政治 HTML 题库</span>
        </div>
        <div>
          <strong>知识图谱</strong>
          <span>知识点、关联真题、错题与学习状态</span>
        </div>
        <div>
          <strong>AI 学习工作台</strong>
          <span>讲解、画像、针对练习、函数调用</span>
        </div>
      </section>

      <section class="poster-section">
        <div class="section-heading">
          <span>01</span>
          <h2>项目定位</h2>
        </div>
        <p class="lead">
          408Master 不是单纯刷题站，而是把题库治理、知识点结构、学生学习事件和 AI 工具调度整合成一个可演示、可部署、可继续扩展的智能学习系统。
        </p>
        <div class="feature-grid">
          <article>
            <b>学生端</b>
            <p>试卷中心、答题、错题本、知识图谱、AI 学习工作台。</p>
          </article>
          <article>
            <b>管理端</b>
            <p>题库、试卷、用户、AI Provider、用量分析与开发者说明。</p>
          </article>
          <article>
            <b>微信小程序</b>
            <p>移动端刷题、错题、我的页面与后续大师功能入口。</p>
          </article>
          <article>
            <b>本地静态资产</b>
            <p>HTML 题干、解析、图片、SVG、表格和公式在前端静态目录渲染。</p>
          </article>
        </div>
      </section>

      <section class="poster-section architecture-section">
        <div class="section-heading">
          <span>02</span>
          <h2>整体架构</h2>
        </div>
        <div class="architecture-ladder">
          <div>
            <b>学生端 / 管理端 / 小程序</b>
            <span>Vue 3、微信小程序、统一后端 API</span>
          </div>
          <div>
            <b>Spring Boot API</b>
            <span>Student、Admin、Wx、AI Workbench、Question、Paper</span>
          </div>
          <div>
            <b>规范题库与静态 HTML 资产</b>
            <span>t_question、question_content、question_source、knowledge_content</span>
          </div>
          <div>
            <b>RAG 与 AI Provider</b>
            <span>MySQL 元数据、Qdrant 向量检索、GLM / DeepSeek / OpenAI 兼容接口</span>
          </div>
          <div>
            <b>AI Orchestrator</b>
            <span>intent、context、style、tool routing、SSE 统一事件流</span>
          </div>
        </div>
      </section>

      <section class="poster-section">
        <div class="section-heading">
          <span>03</span>
          <h2>AI 工作台设计</h2>
        </div>
        <div class="orchestrator">
          <div class="flow-step">
            <span>Intent</span>
            <b>我要 AI 做什么</b>
            <p>讲题、讲知识点、生成学习画像、生成针对练习、直接组卷、自由对话。</p>
          </div>
          <div class="flow-step">
            <span>Context</span>
            <b>当前围绕什么内容</b>
            <p>真题、错题、知识点、粘贴题目、学习统计与 RAG 引用。</p>
          </div>
          <div class="flow-step">
            <span>Style</span>
            <b>希望它怎么表达</b>
            <p>常规解析、费曼、第一性原理、柏拉图式追问，只影响表达层。</p>
          </div>
          <div class="flow-step">
            <span>Tool</span>
            <b>后端确定调用什么</b>
            <p>AnalysisService、RAG、Agent 草案、AiPaperComposeService、用量日志。</p>
          </div>
        </div>
      </section>

      <section class="poster-section split">
        <div>
          <div class="section-heading">
            <span>04</span>
            <h2>数据治理</h2>
          </div>
          <ul class="poster-list">
            <li>题目数据库只保存轻引用、摘要、来源和元数据。</li>
            <li>完整 HTML、图片、表格、代码块、KaTeX 公式放入本地静态目录。</li>
            <li>408 综合卷用 subject_id=5，题目仍精确归属四个单科。</li>
            <li>错题、统计、知识点关联都优先使用题目的精确单科口径。</li>
          </ul>
        </div>
        <div>
          <div class="section-heading">
            <span>05</span>
            <h2>UML 说明</h2>
          </div>
          <p>
            <code>docs/06-uml-standard</code> 使用 PlantUML 标准图补充了用例图、组件图、时序图、领域类图、RAG、AI Runtime 和部署图，让答辩时可以从“产品功能”自然讲到“工程结构”。
          </p>
        </div>
      </section>

      <section class="poster-footer">
        <div>
          <p class="eyebrow">Mini Program</p>
          <h2>微信小程序入口</h2>
          <p>扫码体验移动端刷题、错题与后续 408Master 大师功能。</p>
        </div>
        <img :src="qrSrc" alt="微信小程序二维码" class="qr-code" />
      </section>
    </main>
  </div>
</template>

<script setup>
const basePath = import.meta.env.BASE_URL || '/'
const assetBase = basePath
const qrSrc = `${assetBase}poster/wx-mini-program-qr.png`
const logoSrc = `${assetBase}poster/master408-logo.png`

const printPoster = () => {
  window.print()
}
</script>

<style scoped>
.poster-page {
  min-height: 100vh;
  padding: 28px 16px 56px;
  background: #e9eef5;
  color: #0f172a;
  font-family: Inter, "Microsoft YaHei", Arial, sans-serif;
}

.toolbar {
  max-width: 900px;
  margin: 0 auto 18px;
  display: flex;
  justify-content: flex-end;
  gap: 12px;
}

.toolbar a,
.toolbar button {
  height: 38px;
  padding: 0 16px;
  border-radius: 6px;
  border: 1px solid #cbd5e1;
  background: #fff;
  color: #1e293b;
  text-decoration: none;
  font-weight: 600;
  cursor: pointer;
}

.toolbar button {
  background: #1d4ed8;
  border-color: #1d4ed8;
  color: #fff;
}

.poster-sheet {
  width: min(88vw, 860px);
  aspect-ratio: 4 / 9;
  margin: 0 auto;
  overflow: hidden;
  background: #f8fafc;
  border: 1px solid #dbe4f0;
  box-shadow: 0 24px 60px rgba(15, 23, 42, .18);
  display: flex;
  flex-direction: column;
}

.poster-hero {
  min-height: 17%;
  padding: 46px 52px 36px;
  display: flex;
  justify-content: space-between;
  gap: 32px;
  align-items: flex-start;
  background: #12366f;
  color: #fff;
}

.eyebrow {
  margin: 0 0 10px;
  font-size: 13px;
  line-height: 1.4;
  letter-spacing: 0;
  text-transform: uppercase;
  color: #bfdbfe;
  font-weight: 800;
}

.poster-hero h1 {
  margin: 0;
  font-size: 48px;
  line-height: 1.08;
  letter-spacing: 0;
}

.subtitle {
  margin: 20px 0 0;
  font-size: 20px;
  line-height: 1.55;
  color: #dbeafe;
}

.brand-mark {
  width: 118px;
  height: 118px;
  object-fit: cover;
  border-radius: 18px;
  background: #fff;
  padding: 8px;
}

.value-band {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  border-bottom: 1px solid #dbe4f0;
  background: #fff;
}

.value-band div {
  padding: 20px 24px;
  border-right: 1px solid #e2e8f0;
}

.value-band div:last-child {
  border-right: 0;
}

.value-band strong,
.value-band span {
  display: block;
}

.value-band strong {
  font-size: 17px;
  color: #0f172a;
}

.value-band span {
  margin-top: 8px;
  font-size: 13px;
  line-height: 1.55;
  color: #475569;
}

.poster-section {
  padding: 30px 52px 0;
}

.section-heading {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 16px;
}

.section-heading span {
  width: 34px;
  height: 34px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  border-radius: 6px;
  background: #dbeafe;
  color: #1d4ed8;
  font-weight: 900;
}

.section-heading h2 {
  margin: 0;
  font-size: 25px;
  line-height: 1.2;
}

.lead,
.poster-section p {
  margin: 0;
  font-size: 16px;
  line-height: 1.85;
  color: #334155;
}

.feature-grid {
  margin-top: 22px;
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 14px;
}

.feature-grid article,
.flow-step,
.architecture-ladder div {
  background: #fff;
  border: 1px solid #dbe4f0;
  border-radius: 8px;
}

.feature-grid article {
  padding: 16px;
}

.feature-grid b,
.flow-step b,
.architecture-ladder b {
  display: block;
  font-size: 17px;
  line-height: 1.4;
}

.feature-grid p,
.flow-step p {
  margin-top: 8px;
  font-size: 13px;
  line-height: 1.65;
}

.architecture-section {
  padding-top: 34px;
}

.architecture-ladder {
  display: grid;
  gap: 10px;
}

.architecture-ladder div {
  padding: 14px 18px;
  display: flex;
  justify-content: space-between;
  gap: 18px;
  align-items: center;
}

.architecture-ladder span {
  max-width: 54%;
  text-align: right;
  font-size: 13px;
  line-height: 1.55;
  color: #475569;
}

.orchestrator {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 14px;
}

.flow-step {
  padding: 16px;
}

.flow-step span {
  display: inline-flex;
  margin-bottom: 8px;
  padding: 4px 8px;
  border-radius: 4px;
  background: #eef2ff;
  color: #3730a3;
  font-size: 12px;
  font-weight: 900;
}

.split {
  display: grid;
  grid-template-columns: 1.2fr .8fr;
  gap: 28px;
}

.poster-list {
  margin: 0;
  padding-left: 20px;
  color: #334155;
  font-size: 15px;
  line-height: 1.8;
}

.poster-section code {
  padding: 2px 6px;
  border-radius: 4px;
  background: #e2e8f0;
  color: #0f172a;
}

.poster-footer {
  margin-top: auto;
  padding: 34px 52px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 32px;
  background: #0f172a;
  color: #fff;
}

.poster-footer h2 {
  margin: 0;
  font-size: 30px;
}

.poster-footer p:not(.eyebrow) {
  margin: 12px 0 0;
  color: #cbd5e1;
  line-height: 1.7;
  font-size: 16px;
}

.qr-code {
  width: 150px;
  height: 150px;
  object-fit: cover;
  border-radius: 12px;
  background: #fff;
  padding: 8px;
}

@media (max-width: 760px) {
  .poster-sheet {
    width: 100%;
  }

  .toolbar {
    justify-content: center;
  }
}

@media print {
  @page {
    size: 80cm 180cm;
    margin: 0;
  }

  .poster-page {
    padding: 0;
    background: #fff;
  }

  .toolbar {
    display: none;
  }

  .poster-sheet {
    width: 80cm;
    height: 180cm;
    border: 0;
    box-shadow: none;
  }
}
</style>
