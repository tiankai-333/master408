<template>
  <div class="knowledge-workspace">
    <section class="workspace-hero">
      <div>
        <span class="hero-kicker">408Master Knowledge Studio</span>
        <h1>知识点目录与 RAG 学习链接</h1>
        <p>
          408 统考卷是综合试卷，但每道题仍然属于数据结构、组成原理、操作系统或计算机网络。
          这里用目录替代杂乱图谱，把知识点、相关真题、AI 解析和模拟出题串成一条学习路径。
        </p>
      </div>
      <div class="hero-summary">
        <div>
          <strong>{{ userStats.totalQuestions }}</strong>
          <span>已做题</span>
        </div>
        <div>
          <strong>{{ userStats.accuracy }}%</strong>
          <span>综合正确率</span>
        </div>
        <div>
          <strong>{{ totalKnowledgePoints }}</strong>
          <span>知识点</span>
        </div>
      </div>
    </section>

    <div class="workspace-grid">
      <aside class="left-panel">
        <section class="panel-card accuracy-card">
          <div class="panel-title">
            <div>
              <span>Subject Accuracy</span>
              <h2>分科正确率</h2>
            </div>
            <el-progress
              type="dashboard"
              :percentage="safePercent(userStats.accuracy)"
              :width="78"
              :stroke-width="8"
              :color="progressColor"
            />
          </div>

          <div class="subject-list">
            <button
              v-for="subject in normalizedSubjectStats"
              :key="subject.id || subject.name"
              class="subject-row"
              :class="{ active: selectedSubjectName === subject.name }"
              @click="selectSubject(subject)"
            >
              <span class="subject-dot" :style="{ backgroundColor: subject.color }"></span>
              <span class="subject-main">
                <strong>{{ subject.name }}</strong>
                <em>{{ subject.done || 0 }} 题</em>
              </span>
              <span class="subject-rate">{{ subject.accuracy }}%</span>
            </button>
          </div>
        </section>

        <section class="panel-card skill-card">
          <div class="panel-title compact">
            <div>
              <span>Default Skill</span>
              <h2>AI 解析默认视角</h2>
            </div>
          </div>

          <div class="skill-grid">
            <button
              v-for="skill in aiStyles"
              :key="skill.id"
              class="skill-option"
              :class="{ active: selectedStyle === skill.id }"
              @click="setDefaultStyle(skill.id)"
            >
              <span class="skill-icon">{{ skill.short }}</span>
              <strong>{{ skill.name }}</strong>
              <em>{{ skill.description }}</em>
            </button>
          </div>

          <p class="skill-hint">
            当前默认：{{ currentStyle.name }}。RAG 讲解和模拟出题会优先使用这个视角。
          </p>
        </section>
      </aside>

      <main class="catalog-panel panel-card">
        <div class="catalog-toolbar">
          <div>
            <span>Knowledge Catalog</span>
            <h2>知识点目录</h2>
          </div>
          <el-input
            v-model="keyword"
            class="catalog-search"
            placeholder="搜索知识点，例如 虚拟存储器"
            clearable
          >
            <template #prefix>
              <el-icon><Search /></el-icon>
            </template>
          </el-input>
        </div>

        <div v-loading="graphLoading" class="catalog-body">
          <section
            v-for="group in filteredGroups"
            :key="group.name"
            class="subject-section"
          >
            <button class="subject-heading" @click="toggleGroup(group.name)">
              <span class="subject-dot" :style="{ backgroundColor: group.color }"></span>
              <strong>{{ group.name }}</strong>
              <em>{{ group.points.length }} 个知识点</em>
              <el-icon :class="{ open: expandedGroups.includes(group.name) }"><ArrowDown /></el-icon>
            </button>

            <div v-show="expandedGroups.includes(group.name)" class="knowledge-list">
              <article
                v-for="point in group.points"
                :key="point.id"
                class="knowledge-link"
                :class="{ active: selectedPoint && selectedPoint.rawId === point.rawId }"
                @click="selectPoint(point)"
              >
                <div>
                  <h3>{{ point.name }}</h3>
                  <p>{{ point.description || '暂无描述，点击后可用 RAG 生成讲解和模拟题。' }}</p>
                </div>
                <span class="level-badge">L{{ point.level || 1 }}</span>
              </article>
            </div>
          </section>

          <el-empty v-if="!filteredGroups.length && !graphLoading" description="没有匹配的知识点" />
        </div>
      </main>

      <aside class="right-panel">
        <section class="panel-card detail-card">
          <div class="panel-title compact">
            <div>
              <span>RAG Link</span>
              <h2>{{ selectedPointDetail.name || '选择一个知识点' }}</h2>
            </div>
          </div>

          <div v-if="selectedPointDetail.name" class="point-detail">
            <el-tag effect="plain">{{ selectedPointDetail.subjectName || selectedSubjectName || '408 综合' }}</el-tag>
            <p>{{ selectedPointDetail.description || selectedPoint?.description || '这个知识点还缺少详细描述，可以先用 RAG 讲解补充学习材料。' }}</p>

            <div class="detail-links">
              <button @click="askRagExplanation">
                <el-icon><MagicStick /></el-icon>
                RAG 讲解
              </button>
              <button @click="generatePractice">
                <el-icon><Edit /></el-icon>
                模拟出题
              </button>
              <button @click="goAiAnalyze">
                <el-icon><Search /></el-icon>
                题目识别
              </button>
            </div>

            <div class="related-block">
              <h3>知识链接</h3>
              <div v-if="childPoints.length" class="chip-list">
                <button v-for="child in childPoints" :key="child.id" @click="selectPointByRawId(child.id)">
                  {{ child.name }}
                </button>
              </div>
              <p v-else>暂无下级知识点，可通过 RAG 讲解补足学习路径。</p>
            </div>

            <div class="related-block">
              <h3>关联真题</h3>
              <div v-if="relatedQuestions.length" class="question-list">
                <div v-for="question in relatedQuestions" :key="question.id" class="question-row">
                  <span>{{ question.title || question.name || `题目 #${question.id}` }}</span>
                  <em>难度 {{ question.difficult || '-' }}</em>
                </div>
              </div>
              <p v-else>暂无已关联真题，适合用“模拟出题”生成针对练习。</p>
            </div>
          </div>

          <div v-else class="empty-detail">
            <el-icon><Share /></el-icon>
            <p>从中间目录选择知识点后，这里会显示 RAG 讲解、模拟出题和关联真题入口。</p>
          </div>
        </section>

        <section class="panel-card ai-card">
          <div class="panel-title compact">
            <div>
              <span>AI Workspace</span>
              <h2>RAG 输出</h2>
            </div>
          </div>
          <div ref="messagesRef" class="ai-messages">
            <div v-for="(msg, index) in messages" :key="index" :class="['ai-message', msg.role]">
              <div v-html="formatMessage(msg.content)"></div>
            </div>
            <div v-if="isTyping" class="typing-line">
              <span></span><span></span><span></span>
            </div>
          </div>
          <div class="ai-input">
            <el-input
              v-model="inputMessage"
              type="textarea"
              :rows="3"
              placeholder="围绕当前知识点继续追问..."
              @keydown.enter.ctrl="sendMessage"
            />
            <el-button type="primary" :loading="isTyping" @click="sendMessage">
              发送
            </el-button>
          </div>
        </section>
      </aside>
    </div>
  </div>
</template>

<script setup>
import { computed, nextTick, onMounted, reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { ArrowDown, Edit, MagicStick, Search, Share } from '@element-plus/icons-vue'
import { get, post } from '@/utils/request'

const router = useRouter()

const graphLoading = ref(false)
const keyword = ref('')
const selectedStyle = ref(localStorage.getItem('master408-default-skill') || 'default')
const selectedSubjectName = ref('全部')
const selectedPoint = ref(null)
const selectedPointDetail = reactive({})
const relatedQuestions = ref([])
const childPoints = ref([])
const inputMessage = ref('')
const isTyping = ref(false)
const messages = ref([])
const messagesRef = ref(null)
const expandedGroups = ref([])

const graphData = reactive({
  nodes: [],
  links: [],
  categories: []
})

const userStats = reactive({
  totalQuestions: 0,
  accuracy: 0,
  weakPoints: 0,
  subjects: []
})

const subjectColors = ['#2563eb', '#059669', '#ea580c', '#7c3aed', '#0891b2', '#dc2626']

const aiStyles = [
  { id: 'default', short: '常', name: '常规解析', description: '考点清晰，适合作为默认' },
  { id: 'feynman', short: '费', name: '费曼学习法', description: '用白话和类比讲明白' },
  { id: 'first-principles', short: '一', name: '第一性原理', description: '从底层定义推导' },
  { id: 'plato', short: '问', name: '柏拉图式对话', description: '通过追问启发理解' }
]

const currentStyle = computed(() => aiStyles.find(item => item.id === selectedStyle.value) || aiStyles[0])

const progressColor = computed(() => {
  if (userStats.accuracy >= 80) return '#059669'
  if (userStats.accuracy >= 60) return '#ea580c'
  return '#dc2626'
})

const totalKnowledgePoints = computed(() => {
  return graphData.nodes.filter(node => normalizeType(node.type) === 'knowledge_point').length
})

const groupedKnowledge = computed(() => {
  const categoryNames = graphData.categories.map(item => item.name)
  const subjectNodes = graphData.nodes.filter(node => normalizeType(node.type) === 'subject')
  const groups = new Map()

  categoryNames.forEach((name, index) => {
    groups.set(name, {
      name,
      color: subjectColors[index % subjectColors.length],
      points: []
    })
  })

  subjectNodes.forEach((node, index) => {
    if (!groups.has(node.name)) {
      groups.set(node.name, {
        name: node.name,
        color: subjectColors[index % subjectColors.length],
        points: []
      })
    }
  })

  graphData.nodes
    .filter(node => normalizeType(node.type) === 'knowledge_point')
    .forEach(node => {
      const groupName = categoryNames[node.category] || findSubjectNameByLink(node.id) || '未分类'
      if (!groups.has(groupName)) {
        groups.set(groupName, {
          name: groupName,
          color: subjectColors[groups.size % subjectColors.length],
          points: []
        })
      }
      groups.get(groupName).points.push({
        id: node.id,
        rawId: parseKnowledgeId(node.id),
        name: node.name,
        level: node.level,
        description: node.description,
        category: node.category,
        subjectName: groupName
      })
    })

  return Array.from(groups.values())
    .map(group => ({
      ...group,
      points: group.points.sort((a, b) => (a.level || 1) - (b.level || 1) || a.name.localeCompare(b.name))
    }))
    .filter(group => group.points.length)
})

const filteredGroups = computed(() => {
  const kw = keyword.value.trim().toLowerCase()
  const groups = selectedSubjectName.value === '全部'
    ? groupedKnowledge.value
    : groupedKnowledge.value.filter(group => group.name === selectedSubjectName.value)

  if (!kw) return groups

  return groups
    .map(group => ({
      ...group,
      points: group.points.filter(point => {
        return point.name.toLowerCase().includes(kw) ||
          String(point.description || '').toLowerCase().includes(kw)
      })
    }))
    .filter(group => group.points.length)
})

const normalizedSubjectStats = computed(() => {
  const statItems = (userStats.subjects || []).map((item, index) => ({
    id: item.id,
    name: item.name || item.subjectName || `学科 ${index + 1}`,
    accuracy: safePercent(item.accuracy),
    done: item.totalQuestions || item.done || item.questionCount || 0,
    color: subjectColors[index % subjectColors.length]
  }))

  const existing = new Set(statItems.map(item => item.name))
  groupedKnowledge.value.forEach((group, index) => {
    if (!existing.has(group.name)) {
      statItems.push({
        id: group.name,
        name: group.name,
        accuracy: 0,
        done: 0,
        color: group.color || subjectColors[index % subjectColors.length]
      })
    }
  })

  return [
    {
      id: 'all',
      name: '全部',
      accuracy: safePercent(userStats.accuracy),
      done: userStats.totalQuestions || 0,
      color: '#172033'
    },
    ...statItems
  ]
})

const safePercent = (value) => {
  const number = Number(value || 0)
  if (Number.isNaN(number)) return 0
  return Math.max(0, Math.min(100, Math.round(number)))
}

const normalizeType = (type) => {
  return String(type || '').replace('-', '_')
}

const parseKnowledgeId = (id) => {
  const match = String(id || '').match(/kp_(\d+)/)
  return match ? Number(match[1]) : id
}

const findSubjectNameByLink = (nodeId) => {
  const link = graphData.links.find(item => item.target === nodeId && String(item.source).startsWith('subject_'))
  if (!link) return null
  const subject = graphData.nodes.find(node => node.id === link.source)
  return subject ? subject.name : null
}

const loadGraph = async () => {
  graphLoading.value = true
  try {
    const response = await get('/api/student/knowledge-graph/graph')
    if (response.code === 1) {
      graphData.nodes = response.response?.nodes || []
      graphData.links = response.response?.links || []
      graphData.categories = response.response?.categories || []
      expandedGroups.value = groupedKnowledge.value.slice(0, 4).map(group => group.name)
      if (!selectedPoint.value && groupedKnowledge.value[0]?.points[0]) {
        await selectPoint(groupedKnowledge.value[0].points[0])
      }
    }
  } catch (error) {
    graphData.nodes = []
    graphData.links = []
    graphData.categories = []
  } finally {
    graphLoading.value = false
  }
}

const loadUserStats = async () => {
  try {
    const response = await get('/api/student/user/stats')
    if (response.code === 1) {
      Object.assign(userStats, response.response || {})
      userStats.subjects = response.response?.subjects || []
    }
  } catch (error) {
    userStats.totalQuestions = 0
    userStats.accuracy = 0
    userStats.weakPoints = 0
    userStats.subjects = []
  }
}

const selectSubject = (subject) => {
  selectedSubjectName.value = subject.name
  if (subject.name !== '全部' && !expandedGroups.value.includes(subject.name)) {
    expandedGroups.value = [...expandedGroups.value, subject.name]
  }
}

const toggleGroup = (name) => {
  if (expandedGroups.value.includes(name)) {
    expandedGroups.value = expandedGroups.value.filter(item => item !== name)
  } else {
    expandedGroups.value = [...expandedGroups.value, name]
  }
}

const selectPoint = async (point) => {
  selectedPoint.value = point
  Object.keys(selectedPointDetail).forEach(key => delete selectedPointDetail[key])
  relatedQuestions.value = []
  childPoints.value = []

  try {
    const response = await get('/api/student/knowledge-graph/knowledge-point/' + point.rawId)
    if (response.code === 1) {
      Object.assign(selectedPointDetail, response.response || {})
      selectedPointDetail.subjectName = selectedPointDetail.subjectName || point.subjectName
      relatedQuestions.value = response.response?.relatedQuestions || []
      childPoints.value = response.response?.children || []
    }
  } catch (error) {
    Object.assign(selectedPointDetail, {
      id: point.rawId,
      name: point.name,
      description: point.description,
      subjectName: point.subjectName
    })
  }
}

const selectPointByRawId = async (id) => {
  const point = groupedKnowledge.value
    .flatMap(group => group.points)
    .find(item => item.rawId === id)
  if (point) {
    await selectPoint(point)
  }
}

const setDefaultStyle = (styleId) => {
  selectedStyle.value = styleId
  localStorage.setItem('master408-default-skill', styleId)
}

const askRagExplanation = () => {
  if (!selectedPoint.value) return
  inputMessage.value = `请用${currentStyle.value.name}讲解 408 知识点「${selectedPoint.value.name}」，结合 RAG 知识库说明定义、常见考法和易错点。`
  sendAnalyzeMessage(inputMessage.value)
}

const generatePractice = () => {
  if (!selectedPoint.value) return
  inputMessage.value = `请围绕 408 知识点「${selectedPoint.value.name}」模拟出一道统考风格题目，并给出答案、解析和对应学科。`
  sendAnalyzeMessage(inputMessage.value)
}

const goAiAnalyze = () => {
  router.push({ path: '/question/ai-analyze' })
}

const sendMessage = () => {
  if (!inputMessage.value.trim()) return
  sendAnalyzeMessage(inputMessage.value.trim())
}

const sendAnalyzeMessage = async (question) => {
  if (!question.trim()) return

  const userQuestion = question.trim()
  const knowledgeText = selectedPoint.value
    ? `${selectedPoint.value.name}\n${selectedPoint.value.description || selectedPointDetail.description || ''}`
    : ''

  messages.value.push({ role: 'user', content: userQuestion })
  inputMessage.value = ''
  isTyping.value = true

  await nextTick()
  scrollToBottom()

  try {
    const response = await post('/api/student/ai/analyze', {
      style: selectedStyle.value,
      question: userQuestion,
      knowledgePoints: knowledgeText
    })

    if (response.code === 1) {
      const result = response.response || {}
      let content = result.analysis || result || ''
      if (result.references && result.references.length > 0) {
        content += '\n\n---\n参考来源\n'
        result.references.forEach((ref, idx) => {
          content += `\n${idx + 1}. [${ref.similarity}] ${ref.title}`
        })
      }
      messages.value.push({ role: 'assistant', content })
    } else {
      messages.value.push({ role: 'assistant', content: fallbackAnswer(userQuestion) })
    }
  } catch (error) {
    messages.value.push({ role: 'assistant', content: fallbackAnswer(userQuestion) })
  } finally {
    isTyping.value = false
    await nextTick()
    scrollToBottom()
  }
}

const fallbackAnswer = (question) => {
  const pointName = selectedPoint.value?.name || '当前知识点'
  return `当前 AI 服务暂时不可用，但可以先按 ${currentStyle.value.name} 的思路学习「${pointName}」：

1. 先确认它属于哪一科以及常见题型。
2. 再把定义、约束条件和典型公式写清楚。
3. 最后用一道真题或模拟题验证是否真的会用。

你的问题：${question}`
}

const formatMessage = (content) => {
  if (!content) return ''
  return String(content)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/\n/g, '<br>')
    .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
    .replace(/`(.*?)`/g, '<code>$1</code>')
}

const scrollToBottom = () => {
  if (messagesRef.value) {
    messagesRef.value.scrollTop = messagesRef.value.scrollHeight
  }
}

onMounted(async () => {
  await Promise.all([loadGraph(), loadUserStats()])
  messages.value.push({
    role: 'assistant',
    content: `已进入 408Master 知识工作台。你可以先选一个知识点，再用默认 Skill「${currentStyle.value.name}」进行 RAG 讲解或模拟出题。`
  })
})
</script>

<style lang="scss" scoped>
.knowledge-workspace {
  min-height: calc(100vh - 70px);
  padding: 24px;
  background:
    radial-gradient(circle at 16% 12%, rgba(37, 99, 235, 0.12), transparent 28%),
    radial-gradient(circle at 88% 8%, rgba(124, 58, 237, 0.1), transparent 30%),
    linear-gradient(180deg, #f8fbff 0%, #edf3f8 100%);
  color: #172033;
}

.workspace-hero {
  display: grid;
  grid-template-columns: minmax(0, 1fr) auto;
  gap: 24px;
  max-width: 1480px;
  margin: 0 auto 22px;
  padding: 28px 32px;
  border-radius: 28px;
  background:
    linear-gradient(135deg, rgba(15, 23, 42, 0.96), rgba(30, 64, 175, 0.88)),
    #172033;
  color: #fff;
  overflow: hidden;

  h1 {
    margin: 8px 0 12px;
    font-size: 36px;
    line-height: 1.2;
  }

  p {
    max-width: 860px;
    margin: 0;
    color: rgba(255, 255, 255, 0.76);
    line-height: 1.8;
  }
}

.hero-kicker,
.panel-title span,
.catalog-toolbar span {
  color: #60a5fa;
  font-size: 12px;
  font-weight: 800;
  text-transform: uppercase;
}

.hero-summary {
  display: grid;
  grid-template-columns: repeat(3, 110px);
  gap: 12px;
  align-self: center;

  div {
    padding: 16px;
    border-radius: 18px;
    background: rgba(255, 255, 255, 0.09);
    border: 1px solid rgba(255, 255, 255, 0.12);
  }

  strong {
    display: block;
    font-size: 28px;
  }

  span {
    color: rgba(255, 255, 255, 0.68);
    font-size: 13px;
  }
}

.workspace-grid {
  max-width: 1480px;
  margin: 0 auto;
  display: grid;
  grid-template-columns: 300px minmax(0, 1fr) 380px;
  gap: 22px;
  align-items: start;
}

.left-panel,
.right-panel {
  display: grid;
  gap: 18px;
}

.panel-card {
  background: rgba(255, 255, 255, 0.94);
  border: 1px solid rgba(226, 232, 240, 0.95);
  border-radius: 24px;
  box-shadow: 0 18px 52px rgba(15, 23, 42, 0.08);
}

.accuracy-card,
.skill-card,
.detail-card,
.ai-card,
.catalog-panel {
  padding: 22px;
}

.panel-title,
.catalog-toolbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;

  h2 {
    margin: 4px 0 0;
    font-size: 21px;
  }
}

.panel-title.compact {
  align-items: flex-start;
  margin-bottom: 16px;
}

.subject-list {
  display: grid;
  gap: 10px;
  margin-top: 18px;
}

.subject-row {
  width: 100%;
  display: grid;
  grid-template-columns: 12px minmax(0, 1fr) auto;
  gap: 10px;
  align-items: center;
  padding: 12px;
  border: 1px solid #e2e8f0;
  border-radius: 16px;
  background: #f8fafc;
  text-align: left;
  cursor: pointer;
  transition: 0.2s ease;

  &:hover,
  &.active {
    border-color: #93c5fd;
    background: #eff6ff;
  }
}

.subject-dot {
  width: 10px;
  height: 10px;
  border-radius: 50%;
}

.subject-main {
  min-width: 0;

  strong,
  em {
    display: block;
  }

  strong {
    color: #172033;
    font-size: 14px;
  }

  em {
    margin-top: 3px;
    color: #64748b;
    font-size: 12px;
    font-style: normal;
  }
}

.subject-rate {
  color: #172033;
  font-weight: 800;
}

.skill-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 10px;
}

.skill-option {
  min-height: 118px;
  padding: 14px;
  border: 1px solid #e2e8f0;
  border-radius: 18px;
  background: #f8fafc;
  text-align: left;
  cursor: pointer;
  transition: 0.2s ease;

  &:hover,
  &.active {
    transform: translateY(-2px);
    border-color: #2563eb;
    background: #eff6ff;
    box-shadow: 0 12px 28px rgba(37, 99, 235, 0.12);
  }

  strong,
  em {
    display: block;
  }

  strong {
    margin: 10px 0 6px;
    color: #172033;
  }

  em {
    color: #64748b;
    font-size: 12px;
    font-style: normal;
    line-height: 1.5;
  }
}

.skill-icon {
  display: grid;
  place-items: center;
  width: 34px;
  height: 34px;
  border-radius: 12px;
  color: #fff;
  background: linear-gradient(135deg, #2563eb, #7c3aed);
  font-weight: 800;
}

.skill-hint {
  margin: 14px 0 0;
  color: #64748b;
  font-size: 13px;
  line-height: 1.6;
}

.catalog-panel {
  min-height: 760px;
}

.catalog-toolbar {
  margin-bottom: 18px;
}

.catalog-search {
  max-width: 360px;
}

.catalog-body {
  display: grid;
  gap: 14px;
}

.subject-section {
  border: 1px solid #e2e8f0;
  border-radius: 20px;
  overflow: hidden;
  background: #fff;
}

.subject-heading {
  width: 100%;
  display: grid;
  grid-template-columns: 12px auto 1fr auto;
  gap: 10px;
  align-items: center;
  padding: 16px;
  border: 0;
  background: #f8fafc;
  text-align: left;
  cursor: pointer;

  strong {
    color: #172033;
    font-size: 16px;
  }

  em {
    color: #64748b;
    font-size: 13px;
    font-style: normal;
  }

  .el-icon {
    transition: transform 0.2s ease;
  }

  .el-icon.open {
    transform: rotate(180deg);
  }
}

.knowledge-list {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 12px;
  padding: 14px;
}

.knowledge-link {
  display: grid;
  grid-template-columns: minmax(0, 1fr) auto;
  gap: 12px;
  min-height: 126px;
  padding: 16px;
  border: 1px solid #e2e8f0;
  border-radius: 18px;
  background: #ffffff;
  cursor: pointer;
  transition: 0.2s ease;

  &:hover,
  &.active {
    border-color: #60a5fa;
    box-shadow: 0 14px 32px rgba(37, 99, 235, 0.12);
    transform: translateY(-2px);
  }

  h3 {
    margin: 0 0 8px;
    font-size: 16px;
    color: #172033;
  }

  p {
    margin: 0;
    color: #64748b;
    font-size: 13px;
    line-height: 1.65;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
  }
}

.level-badge {
  align-self: start;
  padding: 4px 8px;
  border-radius: 999px;
  background: #dbeafe;
  color: #1d4ed8;
  font-size: 12px;
  font-weight: 800;
}

.point-detail {
  p {
    color: #475569;
    line-height: 1.8;
  }
}

.detail-links {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 10px;
  margin: 18px 0;

  button {
    min-height: 72px;
    border: 0;
    border-radius: 16px;
    color: #fff;
    background: linear-gradient(135deg, #2563eb, #7c3aed);
    font-weight: 800;
    cursor: pointer;
  }

  .el-icon {
    display: block;
    margin: 0 auto 6px;
    font-size: 20px;
  }
}

.related-block {
  margin-top: 18px;
  padding-top: 18px;
  border-top: 1px solid #e2e8f0;

  h3 {
    margin: 0 0 12px;
    font-size: 16px;
  }

  p {
    margin: 0;
    color: #64748b;
    font-size: 13px;
  }
}

.chip-list {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;

  button {
    padding: 7px 10px;
    border: 1px solid #bfdbfe;
    border-radius: 999px;
    color: #1d4ed8;
    background: #eff6ff;
    cursor: pointer;
  }
}

.question-list {
  display: grid;
  gap: 8px;
}

.question-row {
  display: flex;
  justify-content: space-between;
  gap: 12px;
  padding: 10px;
  border-radius: 12px;
  background: #f8fafc;
  color: #334155;

  em {
    color: #64748b;
    font-style: normal;
  }
}

.empty-detail {
  min-height: 280px;
  display: grid;
  place-items: center;
  text-align: center;
  color: #64748b;

  .el-icon {
    font-size: 48px;
    color: #93c5fd;
  }
}

.ai-card {
  min-height: 420px;
}

.ai-messages {
  max-height: 260px;
  overflow-y: auto;
  display: grid;
  gap: 10px;
  padding: 4px 4px 12px;
}

.ai-message {
  padding: 12px 14px;
  border-radius: 16px;
  color: #334155;
  background: #f8fafc;
  line-height: 1.7;
  font-size: 13px;

  &.user {
    color: #fff;
    background: linear-gradient(135deg, #2563eb, #7c3aed);
  }

  :deep(strong) {
    color: #1d4ed8;
  }

  :deep(code) {
    padding: 2px 5px;
    border-radius: 4px;
    background: #e2e8f0;
  }
}

.typing-line {
  display: flex;
  gap: 5px;
  padding: 8px 4px;

  span {
    width: 7px;
    height: 7px;
    border-radius: 50%;
    background: #2563eb;
    animation: typing 1.2s infinite ease-in-out;
  }

  span:nth-child(2) { animation-delay: 0.15s; }
  span:nth-child(3) { animation-delay: 0.3s; }
}

.ai-input {
  display: grid;
  gap: 10px;
  margin-top: 12px;

  .el-button {
    justify-self: end;
    border-radius: 999px;
  }
}

@keyframes typing {
  0%, 100% { opacity: 0.35; transform: translateY(0); }
  50% { opacity: 1; transform: translateY(-4px); }
}

@media screen and (max-width: 1280px) {
  .workspace-grid {
    grid-template-columns: 280px minmax(0, 1fr);
  }

  .right-panel {
    grid-column: 1 / -1;
    grid-template-columns: 1fr 1fr;
  }
}

@media screen and (max-width: 900px) {
  .knowledge-workspace {
    padding: 16px;
  }

  .workspace-hero,
  .workspace-grid,
  .right-panel {
    grid-template-columns: 1fr;
  }

  .hero-summary {
    grid-template-columns: repeat(3, minmax(0, 1fr));
  }

  .knowledge-list,
  .skill-grid {
    grid-template-columns: 1fr;
  }

  .catalog-toolbar {
    align-items: stretch;
    flex-direction: column;
  }

  .catalog-search {
    max-width: none;
  }
}

@media screen and (max-width: 560px) {
  .workspace-hero {
    padding: 22px;

    h1 {
      font-size: 28px;
    }
  }

  .hero-summary,
  .detail-links {
    grid-template-columns: 1fr;
  }
}
</style>
