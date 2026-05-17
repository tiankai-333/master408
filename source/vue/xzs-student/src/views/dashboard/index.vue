<template>
  <div class="dashboard-page">
    <section class="hero-shell">
      <div class="hero-bg-grid"></div>
      <div class="hero-orbit hero-orbit-one"></div>
      <div class="hero-orbit hero-orbit-two"></div>

      <div class="hero-inner">
        <div class="hero-copy">
          <div class="hero-kicker">
            <span class="live-dot"></span>
            RAG 知识库正在接入 408 真题
          </div>
          <h1>408Master</h1>
          <p class="hero-subtitle">
            把真题、知识点、四种 AI 解析视角和学生学习档案连接起来，让每一次做题都沉淀成下一次更准确的讲解。
          </p>

          <div class="hero-actions">
            <router-link :to="{ path: '/paper/index' }">
              <el-button type="primary" size="large">
                <el-icon><VideoPlay /></el-icon>
                开始刷题
              </el-button>
            </router-link>
            <router-link :to="{ path: '/knowledge-graph/index' }">
              <el-button class="ghost-button" size="large">
                <el-icon><MagicStick /></el-icon>
                查看知识图谱
              </el-button>
            </router-link>
          </div>

          <div class="hero-metrics">
            <div v-for="metric in heroMetrics" :key="metric.label" class="metric-item">
              <strong>{{ metric.value }}</strong>
              <span>{{ metric.label }}</span>
            </div>
          </div>
        </div>

        <div class="hero-visual" aria-hidden="true">
          <div class="knowledge-stage">
            <div class="stage-core">
              <el-icon><Reading /></el-icon>
              <span>RAG</span>
            </div>
            <div
              v-for="node in knowledgeNodes"
              :key="node.label"
              class="knowledge-node"
              :class="node.className"
            >
              <span>{{ node.label }}</span>
            </div>
            <div class="signal-line signal-one"></div>
            <div class="signal-line signal-two"></div>
            <div class="signal-line signal-three"></div>
          </div>
        </div>
      </div>
    </section>

    <section class="quick-panel">
      <div v-for="item in quickLinks" :key="item.title" class="quick-card" @click="go(item.path)">
        <div class="quick-icon" :class="item.tone">
          <el-icon><component :is="item.icon" /></el-icon>
        </div>
        <div>
          <h3>{{ item.title }}</h3>
          <p>{{ item.desc }}</p>
        </div>
      </div>
    </section>

    <main class="content-wrapper">
      <section class="section-row task-section">
        <div class="section-header">
          <div>
            <span class="section-eyebrow">Today</span>
            <h2>今日学习流</h2>
          </div>
          <router-link :to="{ path: '/record/index' }">
            <el-button text>
              查看记录
              <el-icon><View /></el-icon>
            </el-button>
          </router-link>
        </div>

        <div class="task-content" v-loading="taskLoading">
          <el-collapse accordion v-if="taskList.length !== 0" class="task-collapse">
            <el-collapse-item :title="taskItem.title" :name="taskItem.id" :key="taskItem.id" v-for="taskItem in taskList">
              <table class="index-task-table">
                <tr v-for="paperItem in taskItem.paperItems" :key="paperItem.examPaperId">
                  <td class="index-task-table-paper">
                    <el-icon><Document /></el-icon>
                    {{ paperItem.examPaperName }}
                  </td>
                  <td width="90px">
                    <el-tag :type="statusTagFormatter(paperItem.status)" v-if="paperItem.status !== null" size="small">
                      {{ statusTextFormatter(paperItem.status) }}
                    </el-tag>
                    <el-tag v-else size="small" effect="plain">待完成</el-tag>
                  </td>
                  <td width="132px">
                    <router-link target="_blank" :to="{ path: '/do', query: { id: paperItem.examPaperId } }" v-if="paperItem.status === null">
                      <el-button type="primary" size="small"><el-icon><VideoPlay /></el-icon>开始答题</el-button>
                    </router-link>
                    <router-link target="_blank" :to="{ path: '/edit', query: { id: paperItem.examPaperAnswerId } }" v-else-if="paperItem.status === 1">
                      <el-button type="warning" size="small"><el-icon><Edit /></el-icon>批改试卷</el-button>
                    </router-link>
                    <router-link target="_blank" :to="{ path: '/read', query: { id: paperItem.examPaperAnswerId } }" v-else-if="paperItem.status === 2">
                      <el-button type="success" size="small"><el-icon><View /></el-icon>查看试卷</el-button>
                    </router-link>
                  </td>
                </tr>
              </table>
            </el-collapse-item>
          </el-collapse>
          <div v-else class="empty-flow">
            <div class="empty-pulse">
              <el-icon><Tickets /></el-icon>
            </div>
            <h3>今天还没有任务</h3>
            <p>可以从 408 综合真题开始，系统会在做题后积累你的学习轨迹。</p>
          </div>
        </div>
      </section>

      <section class="section-row">
        <div class="section-header">
          <div>
            <span class="section-eyebrow">Papers</span>
            <h2>真题入口</h2>
          </div>
          <router-link :to="{ path: '/paper/index' }">
            <el-button text>
              全部试卷
              <el-icon><Document /></el-icon>
            </el-button>
          </router-link>
        </div>

        <div class="paper-grid" v-loading="loading">
          <article v-for="(item, index) in featuredPapers" :key="item.id || index" class="paper-card">
            <div class="paper-year">{{ getPaperYear(item.name) }}</div>
            <div class="paper-glow"></div>
            <div class="paper-info">
              <span class="paper-type">408 综合真题</span>
              <h3>{{ item.name }}</h3>
              <p>用真题触发知识点、解析 Skill 和学习画像记录。</p>
            </div>
            <router-link target="_blank" :to="{ path: '/do', query: { id: item.id } }">
              <el-button type="primary" class="paper-button">
                <el-icon><VideoPlay /></el-icon>
                开始
              </el-button>
            </router-link>
          </article>
        </div>
      </section>

      <section class="insight-grid">
        <article class="skill-panel">
          <div class="section-header compact">
            <div>
              <span class="section-eyebrow">Skills</span>
              <h2>四种解析视角</h2>
            </div>
          </div>
          <div class="skill-list">
            <div v-for="skill in skillModes" :key="skill.title" class="skill-item">
              <span class="skill-mark" :class="skill.tone"></span>
              <div>
                <h3>{{ skill.title }}</h3>
                <p>{{ skill.desc }}</p>
              </div>
            </div>
          </div>
        </article>

        <article class="agent-panel">
          <div class="agent-radar">
            <div class="radar-ring"></div>
            <div class="radar-ring radar-ring-two"></div>
            <div class="radar-sweep"></div>
            <div class="agent-dot dot-one"></div>
            <div class="agent-dot dot-two"></div>
            <div class="agent-dot dot-three"></div>
          </div>
          <div class="agent-copy">
            <span class="section-eyebrow">Agent</span>
            <h2>学习档案持续生长</h2>
            <p>做题结果、AI 反馈和知识点命中会进入学生画像，后续解析会更贴近你的薄弱点。</p>
          </div>
        </article>
      </section>

      <section class="section-row time-section" v-if="timeLimitPaper.length">
        <div class="section-header">
          <div>
            <span class="section-eyebrow">Limited</span>
            <h2>限时试卷</h2>
          </div>
        </div>
        <div class="time-paper-list">
          <div v-for="(item, index) in timeLimitPaper.slice(0, 4)" :key="item.id || index" class="time-paper">
            <div class="time-icon">
              <el-icon><Timer /></el-icon>
            </div>
            <div>
              <h3>{{ item.name }}</h3>
              <p>
                <el-icon><Calendar /></el-icon>
                {{ item.startTime }} - {{ item.endTime }}
              </p>
            </div>
            <router-link target="_blank" :to="{ path: '/do', query: { id: item.id } }">
              <el-button type="warning" size="small">进入</el-button>
            </router-link>
          </div>
        </div>
      </section>
    </main>
  </div>
</template>

<script setup>
import { computed, onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import {
  Tickets,
  Document,
  VideoPlay,
  Edit,
  View,
  Timer,
  Calendar,
  MagicStick,
  Reading,
  Search,
  DataAnalysis
} from '@element-plus/icons-vue'
import indexApi from '@/api/dashboard'
import { useEnumItemStore } from '@/store/modules/enumItem'

const router = useRouter()
const enumItemStore = useEnumItemStore()

const fixedPaper = ref([])
const timeLimitPaper = ref([])
const loading = ref(false)
const taskLoading = ref(false)
const taskList = ref([])

const knowledgeNodes = [
  { label: '数据结构', className: 'node-ds' },
  { label: '组成原理', className: 'node-co' },
  { label: '操作系统', className: 'node-os' },
  { label: '计算机网络', className: 'node-cn' },
  { label: '真题', className: 'node-paper' },
  { label: '反馈', className: 'node-feedback' }
]

const skillModes = [
  { title: '常规解析', desc: '考点、过程、易错点清晰拆解。', tone: 'blue' },
  { title: '费曼学习法', desc: '用更朴素的语言把复杂概念讲明白。', tone: 'green' },
  { title: '第一性原理', desc: '从基本定义和约束推导到答案。', tone: 'orange' },
  { title: '柏拉图式对话', desc: '用追问帮助你自己推出关键结论。', tone: 'purple' }
]

const quickLinks = [
  { title: '试卷中心', desc: '2011-2024 真题训练', path: '/paper/index', icon: Document, tone: 'blue' },
  { title: 'AI 题目识别', desc: '上传题目获得多视角解析', path: '/question/ai-analyze', icon: Search, tone: 'purple' },
  { title: '知识图谱', desc: '查看知识点关联和薄弱区域', path: '/knowledge-graph/index', icon: MagicStick, tone: 'green' },
  { title: '考试记录', desc: '回看做题轨迹和批改结果', path: '/record/index', icon: DataAnalysis, tone: 'orange' }
]

const featuredPapers = computed(() => fixedPaper.value.slice(0, 6))

const heroMetrics = computed(() => [
  { value: fixedPaper.value.length || 14, label: '套 408 真题' },
  { value: '4', label: '种解析 Skill' },
  { value: '116', label: '条知识点快照' }
])

const statusTagFormatter = (status) => {
  return enumItemStore.enumFormat(enumItemStore.exam.examPaperAnswer.statusTag, status)
}

const statusTextFormatter = (status) => {
  return enumItemStore.enumFormat(enumItemStore.exam.examPaperAnswer.statusEnum, status)
}

const getPaperYear = (name) => {
  const match = String(name || '').match(/20\d{2}/)
  return match ? match[0] : '408'
}

const go = (path) => {
  router.push({ path })
}

onMounted(() => {
  loading.value = true
  indexApi.index()
    .then(re => {
      fixedPaper.value = re.response?.fixedPaper || []
      timeLimitPaper.value = re.response?.timeLimitPaper || []
    })
    .finally(() => {
      loading.value = false
    })

  taskLoading.value = true
  indexApi.task()
    .then(re => {
      taskList.value = re.response || []
    })
    .finally(() => {
      taskLoading.value = false
    })
})
</script>

<style lang="scss" scoped>
.dashboard-page {
  min-height: 100%;
  background:
    radial-gradient(circle at 18% 14%, rgba(99, 102, 241, 0.12), transparent 28%),
    radial-gradient(circle at 86% 8%, rgba(14, 165, 233, 0.14), transparent 30%),
    linear-gradient(180deg, #f8fbff 0%, #eef3f8 42%, #f6f8fb 100%);
  color: #172033;
}

.hero-shell {
  position: relative;
  min-height: 520px;
  overflow: hidden;
  background:
    linear-gradient(135deg, rgba(10, 17, 40, 0.96), rgba(24, 46, 96, 0.92)),
    #101827;
}

.hero-bg-grid {
  position: absolute;
  inset: 0;
  background-image:
    linear-gradient(rgba(255, 255, 255, 0.055) 1px, transparent 1px),
    linear-gradient(90deg, rgba(255, 255, 255, 0.055) 1px, transparent 1px);
  background-size: 42px 42px;
  mask-image: linear-gradient(to bottom, #000 0%, transparent 90%);
}

.hero-orbit {
  position: absolute;
  width: 460px;
  height: 460px;
  border: 1px solid rgba(125, 211, 252, 0.16);
  border-radius: 50%;
  animation: spin 28s linear infinite;
}

.hero-orbit-one {
  right: 6%;
  top: -130px;
}

.hero-orbit-two {
  right: -120px;
  bottom: -210px;
  width: 620px;
  height: 620px;
  border-color: rgba(196, 181, 253, 0.14);
  animation-direction: reverse;
  animation-duration: 36s;
}

.hero-inner {
  position: relative;
  z-index: 1;
  max-width: 1240px;
  min-height: 520px;
  margin: 0 auto;
  padding: 72px 28px 64px;
  display: grid;
  grid-template-columns: minmax(0, 1.02fr) minmax(360px, 0.98fr);
  gap: 44px;
  align-items: center;
}

.hero-copy {
  color: #fff;
}

.hero-kicker {
  display: inline-flex;
  align-items: center;
  gap: 10px;
  padding: 8px 14px;
  border: 1px solid rgba(255, 255, 255, 0.16);
  border-radius: 999px;
  background: rgba(255, 255, 255, 0.08);
  color: rgba(255, 255, 255, 0.82);
  font-size: 14px;
}

.live-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: #34d399;
  box-shadow: 0 0 0 6px rgba(52, 211, 153, 0.16);
  animation: live-pulse 1.8s ease-in-out infinite;
}

.hero-copy h1 {
  margin: 24px 0 18px;
  font-size: clamp(48px, 7vw, 86px);
  line-height: 0.95;
  font-weight: 800;
  letter-spacing: 0;
}

.hero-subtitle {
  max-width: 660px;
  margin: 0;
  color: rgba(255, 255, 255, 0.78);
  font-size: 18px;
  line-height: 1.9;
}

.hero-actions {
  display: flex;
  flex-wrap: wrap;
  gap: 14px;
  margin-top: 34px;

  a {
    text-decoration: none;
  }

  .el-button {
    border-radius: 999px;
    padding: 18px 24px;
    font-weight: 700;
  }
}

.ghost-button {
  color: #fff;
  border-color: rgba(255, 255, 255, 0.28);
  background: rgba(255, 255, 255, 0.08);

  &:hover {
    color: #fff;
    border-color: rgba(255, 255, 255, 0.5);
    background: rgba(255, 255, 255, 0.14);
  }
}

.hero-metrics {
  display: flex;
  flex-wrap: wrap;
  gap: 14px;
  margin-top: 34px;
}

.metric-item {
  min-width: 132px;
  padding: 16px 18px;
  border-radius: 18px;
  background: rgba(255, 255, 255, 0.08);
  border: 1px solid rgba(255, 255, 255, 0.12);
  backdrop-filter: blur(12px);

  strong {
    display: block;
    font-size: 26px;
    line-height: 1;
  }

  span {
    display: block;
    margin-top: 8px;
    color: rgba(255, 255, 255, 0.7);
    font-size: 13px;
  }
}

.hero-visual {
  min-height: 420px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.knowledge-stage {
  position: relative;
  width: min(430px, 86vw);
  aspect-ratio: 1;
  border-radius: 36px;
  background:
    radial-gradient(circle at 50% 50%, rgba(59, 130, 246, 0.22), transparent 32%),
    linear-gradient(145deg, rgba(255, 255, 255, 0.13), rgba(255, 255, 255, 0.05));
  border: 1px solid rgba(255, 255, 255, 0.16);
  box-shadow: 0 34px 120px rgba(0, 0, 0, 0.38);
  backdrop-filter: blur(18px);
}

.stage-core {
  position: absolute;
  left: 50%;
  top: 50%;
  width: 118px;
  height: 118px;
  transform: translate(-50%, -50%);
  border-radius: 34px;
  display: grid;
  place-items: center;
  color: #fff;
  background: linear-gradient(135deg, #2563eb, #7c3aed);
  box-shadow: 0 18px 50px rgba(37, 99, 235, 0.42);
  animation: core-float 4s ease-in-out infinite;

  .el-icon {
    font-size: 30px;
  }

  span {
    font-size: 17px;
    font-weight: 800;
  }
}

.knowledge-node {
  position: absolute;
  min-width: 90px;
  padding: 10px 14px;
  text-align: center;
  border-radius: 999px;
  color: #eaf2ff;
  background: rgba(15, 23, 42, 0.66);
  border: 1px solid rgba(255, 255, 255, 0.16);
  box-shadow: 0 14px 32px rgba(0, 0, 0, 0.24);
  animation: node-breathe 3.8s ease-in-out infinite;

  span {
    font-size: 14px;
    font-weight: 700;
  }
}

.node-ds { left: 38px; top: 72px; animation-delay: 0s; }
.node-co { right: 34px; top: 78px; animation-delay: 0.4s; }
.node-os { left: 28px; bottom: 104px; animation-delay: 0.8s; }
.node-cn { right: 28px; bottom: 104px; animation-delay: 1.2s; }
.node-paper { left: 50%; top: 26px; transform: translateX(-50%); animation-delay: 1.6s; }
.node-feedback { left: 50%; bottom: 34px; transform: translateX(-50%); animation-delay: 2s; }

.signal-line {
  position: absolute;
  left: 50%;
  top: 50%;
  width: 78%;
  height: 1px;
  transform-origin: center;
  background: linear-gradient(90deg, transparent, rgba(125, 211, 252, 0.46), transparent);
  animation: signal-flow 3.6s ease-in-out infinite;
}

.signal-one { transform: translate(-50%, -50%) rotate(22deg); }
.signal-two { transform: translate(-50%, -50%) rotate(90deg); animation-delay: 0.7s; }
.signal-three { transform: translate(-50%, -50%) rotate(146deg); animation-delay: 1.4s; }

.quick-panel {
  max-width: 1240px;
  margin: -48px auto 0;
  padding: 0 28px;
  position: relative;
  z-index: 2;
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 16px;
}

.quick-card {
  min-height: 124px;
  padding: 20px;
  display: flex;
  gap: 14px;
  align-items: center;
  border-radius: 22px;
  background: rgba(255, 255, 255, 0.9);
  border: 1px solid rgba(226, 232, 240, 0.9);
  box-shadow: 0 18px 48px rgba(15, 23, 42, 0.1);
  cursor: pointer;
  transition: transform 0.24s ease, box-shadow 0.24s ease;

  &:hover {
    transform: translateY(-6px);
    box-shadow: 0 24px 60px rgba(15, 23, 42, 0.16);
  }

  h3 {
    margin: 0 0 8px;
    font-size: 17px;
    color: #172033;
  }

  p {
    margin: 0;
    color: #64748b;
    line-height: 1.6;
    font-size: 13px;
  }
}

.quick-icon {
  width: 48px;
  height: 48px;
  flex: 0 0 48px;
  border-radius: 16px;
  display: grid;
  place-items: center;

  .el-icon {
    font-size: 24px;
    color: #fff;
  }
}

.quick-icon.blue { background: linear-gradient(135deg, #2563eb, #38bdf8); }
.quick-icon.purple { background: linear-gradient(135deg, #7c3aed, #c084fc); }
.quick-icon.green { background: linear-gradient(135deg, #059669, #34d399); }
.quick-icon.orange { background: linear-gradient(135deg, #ea580c, #f59e0b); }

.content-wrapper {
  max-width: 1240px;
  margin: 0 auto;
  padding: 32px 28px 56px;
}

.section-row,
.skill-panel,
.agent-panel {
  background: rgba(255, 255, 255, 0.92);
  border: 1px solid rgba(226, 232, 240, 0.9);
  border-radius: 26px;
  box-shadow: 0 18px 52px rgba(15, 23, 42, 0.08);
}

.section-row {
  padding: 26px;
  margin-bottom: 24px;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 16px;
  margin-bottom: 22px;

  h2 {
    margin: 4px 0 0;
    font-size: 25px;
    color: #172033;
  }

  a {
    text-decoration: none;
  }
}

.section-header.compact {
  margin-bottom: 16px;
}

.section-eyebrow {
  color: #2563eb;
  font-size: 12px;
  font-weight: 800;
  text-transform: uppercase;
}

.task-content {
  min-height: 128px;
}

.task-collapse {
  border: none;

  :deep(.el-collapse-item__header) {
    min-height: 52px;
    padding: 0 14px;
    border-radius: 16px;
    border: 1px solid #e2e8f0;
    font-size: 16px;
    font-weight: 700;
    color: #172033;
  }

  :deep(.el-collapse-item__wrap) {
    border-bottom: none;
  }

  :deep(.el-collapse-item__content) {
    padding: 16px 4px 0;
  }
}

.index-task-table {
  width: 100%;
  border-collapse: collapse;

  tr {
    transition: background 0.2s ease;
  }

  tr:hover {
    background-color: #f8fafc;
  }

  td {
    padding: 13px 10px;
    border-bottom: 1px solid #eef2f7;
  }

  .index-task-table-paper {
    color: #334155;
    font-size: 15px;

    .el-icon {
      color: #2563eb;
      margin-right: 8px;
    }
  }
}

.empty-flow {
  padding: 34px 16px;
  text-align: center;
  border-radius: 22px;
  background: linear-gradient(135deg, #f8fbff, #eef6ff);

  h3 {
    margin: 14px 0 8px;
    color: #172033;
  }

  p {
    margin: 0;
    color: #64748b;
  }
}

.empty-pulse {
  width: 64px;
  height: 64px;
  margin: 0 auto;
  border-radius: 22px;
  display: grid;
  place-items: center;
  color: #2563eb;
  background: #dbeafe;
  animation: core-float 3.8s ease-in-out infinite;

  .el-icon {
    font-size: 30px;
  }
}

.paper-grid {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 18px;
}

.paper-card {
  position: relative;
  min-height: 224px;
  overflow: hidden;
  padding: 22px;
  border-radius: 24px;
  background:
    linear-gradient(145deg, rgba(15, 23, 42, 0.94), rgba(30, 64, 175, 0.82)),
    #172033;
  color: #fff;
  box-shadow: 0 16px 40px rgba(30, 64, 175, 0.18);
  transition: transform 0.24s ease, box-shadow 0.24s ease;

  &:hover {
    transform: translateY(-6px);
    box-shadow: 0 22px 56px rgba(30, 64, 175, 0.28);

    .paper-glow {
      transform: translate(18px, -18px) scale(1.08);
    }
  }
}

.paper-year {
  position: relative;
  z-index: 1;
  font-size: 42px;
  line-height: 1;
  font-weight: 800;
}

.paper-glow {
  position: absolute;
  right: -34px;
  top: -34px;
  width: 140px;
  height: 140px;
  border-radius: 50%;
  background: rgba(96, 165, 250, 0.34);
  transition: transform 0.28s ease;
}

.paper-info {
  position: relative;
  z-index: 1;
  margin-top: 28px;

  .paper-type {
    color: rgba(255, 255, 255, 0.64);
    font-size: 13px;
  }

  h3 {
    margin: 8px 0 10px;
    font-size: 18px;
    line-height: 1.5;
  }

  p {
    min-height: 42px;
    margin: 0;
    color: rgba(255, 255, 255, 0.72);
    line-height: 1.7;
    font-size: 13px;
  }
}

.paper-button {
  position: relative;
  z-index: 1;
  margin-top: 18px;
  width: 100%;
  border-radius: 999px;
}

.insight-grid {
  display: grid;
  grid-template-columns: minmax(0, 1fr) minmax(320px, 0.8fr);
  gap: 24px;
  margin-bottom: 24px;
}

.skill-panel,
.agent-panel {
  padding: 26px;
}

.skill-list {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 14px;
}

.skill-item {
  display: flex;
  gap: 12px;
  min-height: 108px;
  padding: 16px;
  border-radius: 18px;
  background: #f8fafc;
  border: 1px solid #e2e8f0;

  h3 {
    margin: 0 0 8px;
    font-size: 16px;
    color: #172033;
  }

  p {
    margin: 0;
    color: #64748b;
    line-height: 1.7;
    font-size: 13px;
  }
}

.skill-mark {
  width: 12px;
  height: 38px;
  flex: 0 0 12px;
  border-radius: 999px;
}

.skill-mark.blue { background: #2563eb; }
.skill-mark.green { background: #059669; }
.skill-mark.orange { background: #ea580c; }
.skill-mark.purple { background: #7c3aed; }

.agent-panel {
  position: relative;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  min-height: 320px;
  background:
    radial-gradient(circle at 60% 28%, rgba(14, 165, 233, 0.18), transparent 32%),
    #ffffff;
}

.agent-radar {
  position: relative;
  width: 220px;
  height: 220px;
  margin: 0 auto 18px;
  border-radius: 50%;
  background: radial-gradient(circle, rgba(37, 99, 235, 0.12), transparent 64%);
}

.radar-ring {
  position: absolute;
  inset: 34px;
  border: 1px solid rgba(37, 99, 235, 0.24);
  border-radius: 50%;
}

.radar-ring-two {
  inset: 68px;
}

.radar-sweep {
  position: absolute;
  left: 50%;
  top: 50%;
  width: 98px;
  height: 2px;
  transform-origin: left center;
  background: linear-gradient(90deg, rgba(37, 99, 235, 0.9), transparent);
  animation: radar-spin 4s linear infinite;
}

.agent-dot {
  position: absolute;
  width: 10px;
  height: 10px;
  border-radius: 50%;
  background: #2563eb;
  box-shadow: 0 0 0 8px rgba(37, 99, 235, 0.12);
}

.dot-one { left: 56px; top: 72px; }
.dot-two { right: 46px; top: 118px; background: #7c3aed; }
.dot-three { left: 118px; bottom: 42px; background: #059669; }

.agent-copy {
  h2 {
    margin: 6px 0 10px;
    color: #172033;
  }

  p {
    margin: 0;
    color: #64748b;
    line-height: 1.8;
  }
}

.time-paper-list {
  display: grid;
  gap: 14px;
}

.time-paper {
  display: grid;
  grid-template-columns: 52px minmax(0, 1fr) auto;
  gap: 14px;
  align-items: center;
  padding: 16px;
  border-radius: 18px;
  background: #fff7ed;
  border: 1px solid #fed7aa;

  h3 {
    margin: 0 0 8px;
    color: #172033;
  }

  p {
    margin: 0;
    color: #9a3412;
    font-size: 13px;
  }
}

.time-icon {
  width: 52px;
  height: 52px;
  border-radius: 18px;
  display: grid;
  place-items: center;
  background: #fed7aa;
  color: #c2410c;

  .el-icon {
    font-size: 24px;
  }
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

@keyframes live-pulse {
  0%, 100% { transform: scale(1); opacity: 1; }
  50% { transform: scale(1.35); opacity: 0.7; }
}

@keyframes core-float {
  0%, 100% { transform: translate(-50%, -50%) translateY(0); }
  50% { transform: translate(-50%, -50%) translateY(-8px); }
}

.empty-pulse {
  animation-name: empty-float;
}

@keyframes empty-float {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-8px); }
}

@keyframes node-breathe {
  0%, 100% { filter: brightness(1); }
  50% { filter: brightness(1.24); }
}

@keyframes signal-flow {
  0%, 100% { opacity: 0.24; }
  50% { opacity: 0.82; }
}

@keyframes radar-spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

@media (prefers-reduced-motion: reduce) {
  *,
  *::before,
  *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}

@media screen and (max-width: 1100px) {
  .hero-inner {
    grid-template-columns: 1fr;
    padding-top: 58px;
  }

  .hero-visual {
    min-height: 360px;
  }

  .quick-panel {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }

  .paper-grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }

  .insight-grid {
    grid-template-columns: 1fr;
  }
}

@media screen and (max-width: 720px) {
  .hero-shell {
    min-height: auto;
  }

  .hero-inner {
    padding: 42px 18px 74px;
    gap: 24px;
  }

  .hero-visual {
    display: none;
  }

  .hero-actions,
  .hero-metrics {
    align-items: stretch;
  }

  .hero-actions .el-button,
  .metric-item {
    width: 100%;
  }

  .quick-panel,
  .content-wrapper {
    padding-left: 16px;
    padding-right: 16px;
  }

  .quick-panel,
  .paper-grid,
  .skill-list {
    grid-template-columns: 1fr;
  }

  .section-row,
  .skill-panel,
  .agent-panel {
    padding: 20px;
    border-radius: 22px;
  }

  .section-header {
    align-items: flex-start;
    flex-direction: column;

    h2 {
      font-size: 22px;
    }
  }

  .time-paper {
    grid-template-columns: 48px minmax(0, 1fr);

    a {
      grid-column: 1 / -1;
    }

    .el-button {
      width: 100%;
    }
  }
}
</style>
