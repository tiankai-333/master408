<template>
  <div class="study-workbench">
    <section class="workbench-header">
      <div>
        <span class="eyebrow">408Master AI Tutor</span>
        <h1>AI 学习工作台</h1>
        <p>选择右侧知识点，让 AI 结合知识库、真题和你的学习记录进行讲解、追问与练习。</p>
      </div>
      <div class="header-actions">
        <button @click="explainKnowledge">
          <el-icon><MagicStick /></el-icon>
          讲解当前知识点
        </button>
        <button @click="generatePractice">
          <el-icon><Edit /></el-icon>
          生成练习题
        </button>
      </div>
    </section>

    <section class="workbench-grid">
      <aside class="side-column">
        <section class="panel-card">
          <div class="panel-title">
            <span>Learning Profile</span>
            <h2>学习状态</h2>
          </div>
          <div class="profile-summary">
            <div>
              <strong>{{ userStats.totalQuestions }}</strong>
              <span>已做题</span>
            </div>
            <div>
              <strong>{{ userStats.accuracy }}%</strong>
              <span>综合正确率</span>
            </div>
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
              <span>
                <strong>{{ subject.name }}</strong>
                <em>{{ subject.done || 0 }} 题</em>
              </span>
              <b>{{ subject.accuracy }}%</b>
            </button>
          </div>
        </section>

        <section class="panel-card">
          <div class="panel-title">
            <span>Default Skill</span>
            <h2>默认讲法</h2>
          </div>
          <div class="skill-grid">
            <button
              v-for="skill in aiStyles"
              :key="skill.id"
              class="skill-card"
              :class="{ active: selectedStyle === skill.id }"
              @click="setDefaultStyle(skill.id)"
            >
              <span>{{ skill.short }}</span>
              <strong>{{ skill.name }}</strong>
              <em>{{ skill.description }}</em>
            </button>
          </div>
        </section>
      </aside>

      <main class="chat-panel panel-card">
        <div class="chat-heading">
          <div>
            <span class="eyebrow">AI Conversation</span>
            <h2>{{ selectedPointDetail.name || '先选择知识点，或直接提问' }}</h2>
            <p>
              当前讲法：{{ currentStyle.name }}
              <template v-if="selectedPoint"> · {{ selectedPoint.subjectName }}</template>
            </p>
          </div>
          <el-tag v-if="selectedPoint" effect="plain">{{ selectedPoint.subjectName }}</el-tag>
        </div>

        <div v-if="selectedPoint" class="context-card">
          <div>
            <strong>{{ selectedPointDetail.name || selectedPoint.name }}</strong>
            <p>{{ selectedPointDetail.description || selectedPoint.description || '这个知识点还缺少详细描述，可以先让 AI 结合知识库补全。' }}</p>
          </div>
          <div class="prompt-actions">
            <button @click="explainKnowledge">结合知识库讲解</button>
            <button @click="explainWithExam">结合真题讲解</button>
            <button @click="generatePractice">生成练习题</button>
          </div>
        </div>

        <div ref="messagesRef" class="chat-messages">
          <div v-for="(msg, index) in messages" :key="index" :class="['message-bubble', msg.role]">
            <div v-html="formatMessage(msg.content)"></div>
          </div>
          <div v-if="isTyping" class="typing-line">
            <span></span><span></span><span></span>
          </div>
        </div>

        <div class="chat-input">
          <el-input
            v-model="inputMessage"
            type="textarea"
            :rows="4"
            placeholder="问一个 408 问题，或围绕当前知识点继续追问..."
            @keydown.enter.ctrl="sendMessage"
          />
          <div class="input-footer">
            <span>Ctrl + Enter 发送</span>
            <el-button type="primary" :loading="isTyping" @click="sendMessage">发送</el-button>
          </div>
        </div>
      </main>

      <aside class="catalog-column">
        <section class="panel-card catalog-card">
          <div class="catalog-title">
            <div>
              <span class="eyebrow">Knowledge Context</span>
              <h2>知识目录</h2>
            </div>
            <strong>{{ totalKnowledgePoints }}</strong>
          </div>
          <el-input
            v-model="keyword"
            class="catalog-search"
            placeholder="搜索知识点"
            clearable
          >
            <template #prefix>
              <el-icon><Search /></el-icon>
            </template>
          </el-input>

          <div v-loading="graphLoading" class="catalog-body">
            <section v-for="group in filteredGroups" :key="group.name" class="subject-section">
              <button class="subject-heading" @click="toggleGroup(group.name)">
                <span class="subject-dot" :style="{ backgroundColor: group.color }"></span>
                <strong>{{ group.name }}</strong>
                <em>{{ group.points.length }}</em>
                <el-icon :class="{ open: expandedGroups.includes(group.name) }"><ArrowDown /></el-icon>
              </button>
              <div v-show="expandedGroups.includes(group.name)" class="knowledge-list">
                <button
                  v-for="point in group.points"
                  :key="point.id"
                  class="knowledge-item"
                  :class="{ active: selectedPoint && selectedPoint.rawId === point.rawId }"
                  @click="selectPoint(point)"
                >
                  <strong>{{ point.name }}</strong>
                  <span>{{ point.description || '点击后加入 AI 对话上下文' }}</span>
                </button>
              </div>
            </section>
            <el-empty v-if="!filteredGroups.length && !graphLoading" description="没有匹配的知识点" />
          </div>
        </section>

        <section class="panel-card related-card">
          <div class="panel-title">
            <span>Linked Practice</span>
            <h2>相关上下文</h2>
          </div>
          <div class="related-block">
            <h3>关联知识点</h3>
            <div v-if="childPoints.length" class="chip-list">
              <button v-for="child in childPoints" :key="child.id" @click="selectPointByRawId(child.id)">
                {{ child.name }}
              </button>
            </div>
            <p v-else>选择知识点后，这里会展示可继续学习的关联内容。</p>
          </div>
          <div class="related-block">
            <h3>关联真题</h3>
            <div v-if="relatedQuestions.length" class="question-list">
              <div v-for="question in relatedQuestions" :key="question.id" class="question-row">
                <span>{{ question.title || question.name || `题目 #${question.id}` }}</span>
                <em>{{ question.difficult ? `难度 ${question.difficult}` : '真题' }}</em>
              </div>
            </div>
            <p v-else>暂无已关联真题，可以先让 AI 生成一题练习。</p>
          </div>
          <button class="analysis-link" @click="goAiAnalyze">
            <el-icon><Search /></el-icon>
            打开题目识别
          </button>
        </section>
      </aside>
    </section>
  </div>
</template>

<script setup>
import { computed, nextTick, onMounted, reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { ArrowDown, Edit, MagicStick, Search } from '@element-plus/icons-vue'
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
        await selectPoint(groupedKnowledge.value[0].points[0], false)
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

const selectPoint = async (point, announce = true) => {
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

  if (announce) {
    messages.value.push({
      role: 'assistant',
      content: `已切换到「${point.name}」。你可以让我讲解定义、结合真题说明考法，或生成一题练习。`
    })
    await nextTick()
    scrollToBottom()
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

const explainKnowledge = () => {
  if (!selectedPoint.value) {
    inputMessage.value = `请用${currentStyle.value.name}给我梳理 408 的一个高频知识点，并说明如何复习。`
  } else {
    inputMessage.value = `请用${currentStyle.value.name}讲解 408 知识点「${selectedPoint.value.name}」，说明定义、常见考法和易错点。`
  }
  sendAnalyzeMessage(inputMessage.value)
}

const explainWithExam = () => {
  if (!selectedPoint.value) return
  inputMessage.value = `请结合 408 真题讲解「${selectedPoint.value.name}」，指出常见设问方式、解题步骤和容易掉坑的地方。`
  sendAnalyzeMessage(inputMessage.value)
}

const generatePractice = () => {
  if (!selectedPoint.value) {
    inputMessage.value = `请生成一道 408 统考风格练习题，并给出答案、解析和对应学科。`
  } else {
    inputMessage.value = `请围绕 408 知识点「${selectedPoint.value.name}」生成一道统考风格练习题，并给出答案、解析和对应学科。`
  }
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
    content: `欢迎来到 AI 学习工作台。你可以从右侧选择知识点，或直接问我一个 408 问题。我会优先使用「${currentStyle.value.name}」来回答。`
  })
})
</script>

<style lang="scss" scoped>
.study-workbench {
  min-height: calc(100vh - 70px);
  padding: 22px;
  background: linear-gradient(180deg, #f7fbff 0%, #eef4f8 100%);
  color: #172033;
}

.workbench-header {
  max-width: 1500px;
  margin: 0 auto 18px;
  display: grid;
  grid-template-columns: minmax(0, 1fr) auto;
  gap: 18px;
  align-items: center;
  padding: 24px 28px;
  border-radius: 24px;
  background: linear-gradient(135deg, #13233f, #2554bc);
  color: #fff;

  h1 {
    margin: 6px 0 8px;
    font-size: 32px;
    line-height: 1.2;
  }

  p {
    max-width: 760px;
    margin: 0;
    color: rgba(255, 255, 255, 0.78);
    line-height: 1.7;
  }
}

.eyebrow,
.panel-title span,
.catalog-title span {
  color: #5b8cff;
  font-size: 12px;
  font-weight: 800;
  letter-spacing: 0;
  text-transform: uppercase;
}

.workbench-header .eyebrow {
  color: #93c5fd;
}

.header-actions {
  display: flex;
  gap: 10px;

  button {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    min-height: 42px;
    padding: 0 16px;
    border: 1px solid rgba(255, 255, 255, 0.28);
    border-radius: 999px;
    color: #fff;
    background: rgba(255, 255, 255, 0.12);
    cursor: pointer;
  }
}

.workbench-grid {
  max-width: 1500px;
  margin: 0 auto;
  display: grid;
  grid-template-columns: 290px minmax(0, 1fr) 360px;
  gap: 18px;
  align-items: start;
}

.side-column,
.catalog-column {
  display: grid;
  gap: 16px;
}

.panel-card {
  padding: 18px;
  border: 1px solid #e2e8f0;
  border-radius: 20px;
  background: rgba(255, 255, 255, 0.96);
  box-shadow: 0 16px 44px rgba(15, 23, 42, 0.08);
}

.panel-title,
.catalog-title,
.chat-heading {
  display: flex;
  justify-content: space-between;
  gap: 14px;
  align-items: flex-start;

  h2 {
    margin: 4px 0 0;
    font-size: 20px;
  }
}

.profile-summary {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 10px;
  margin: 16px 0;

  div {
    padding: 14px;
    border-radius: 14px;
    background: #f2f7ff;
  }

  strong,
  span {
    display: block;
  }

  strong {
    font-size: 24px;
  }

  span {
    margin-top: 4px;
    color: #64748b;
    font-size: 12px;
  }
}

.subject-list,
.catalog-body,
.knowledge-list,
.question-list {
  display: grid;
  gap: 9px;
}

.subject-row {
  display: grid;
  grid-template-columns: 10px minmax(0, 1fr) auto;
  gap: 10px;
  align-items: center;
  width: 100%;
  padding: 11px;
  border: 1px solid #e2e8f0;
  border-radius: 14px;
  background: #f8fafc;
  text-align: left;
  cursor: pointer;

  &:hover,
  &.active {
    border-color: #93c5fd;
    background: #eff6ff;
  }

  strong,
  em {
    display: block;
  }

  strong {
    font-size: 14px;
  }

  em {
    color: #64748b;
    font-size: 12px;
    font-style: normal;
  }

  b {
    font-size: 15px;
  }
}

.subject-dot {
  width: 9px;
  height: 9px;
  border-radius: 50%;
}

.skill-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 9px;
  margin-top: 14px;
}

.skill-card {
  min-height: 112px;
  padding: 12px;
  border: 1px solid #e2e8f0;
  border-radius: 16px;
  background: #f8fafc;
  text-align: left;
  cursor: pointer;

  &:hover,
  &.active {
    border-color: #2563eb;
    background: #eff6ff;
    box-shadow: 0 12px 28px rgba(37, 99, 235, 0.12);
  }

  span {
    display: grid;
    place-items: center;
    width: 32px;
    height: 32px;
    border-radius: 12px;
    color: #fff;
    background: linear-gradient(135deg, #2563eb, #7c3aed);
    font-weight: 800;
  }

  strong,
  em {
    display: block;
  }

  strong {
    margin: 10px 0 5px;
    font-size: 14px;
  }

  em {
    color: #64748b;
    font-size: 12px;
    font-style: normal;
    line-height: 1.45;
  }
}

.chat-panel {
  min-height: 780px;
  display: grid;
  grid-template-rows: auto auto minmax(360px, 1fr) auto;
}

.chat-heading {
  margin-bottom: 14px;

  p {
    margin: 5px 0 0;
    color: #64748b;
  }
}

.context-card {
  display: grid;
  gap: 14px;
  margin-bottom: 14px;
  padding: 16px;
  border: 1px solid #bfdbfe;
  border-radius: 18px;
  background: #eff6ff;

  strong {
    font-size: 17px;
  }

  p {
    margin: 7px 0 0;
    color: #475569;
    line-height: 1.7;
  }
}

.prompt-actions {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;

  button {
    padding: 8px 12px;
    border: 1px solid #93c5fd;
    border-radius: 999px;
    color: #1d4ed8;
    background: #fff;
    cursor: pointer;
  }
}

.chat-messages {
  min-height: 360px;
  max-height: 520px;
  overflow-y: auto;
  display: flex;
  flex-direction: column;
  gap: 12px;
  padding: 10px 4px 16px;
}

.message-bubble {
  max-width: 82%;
  padding: 14px 16px;
  border-radius: 18px;
  color: #334155;
  background: #f1f5f9;
  line-height: 1.75;

  &.user {
    align-self: flex-end;
    color: #fff;
    background: linear-gradient(135deg, #2563eb, #7c3aed);
  }

  &.assistant {
    align-self: flex-start;
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

.chat-input {
  padding-top: 12px;
  border-top: 1px solid #e2e8f0;
}

.input-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 12px;
  margin-top: 10px;

  span {
    color: #94a3b8;
    font-size: 12px;
  }

  .el-button {
    border-radius: 999px;
  }
}

.catalog-title {
  align-items: center;
  margin-bottom: 12px;

  strong {
    display: grid;
    place-items: center;
    width: 44px;
    height: 44px;
    border-radius: 14px;
    color: #1d4ed8;
    background: #dbeafe;
  }
}

.catalog-search {
  margin-bottom: 12px;
}

.catalog-body {
  max-height: 560px;
  overflow-y: auto;
  padding-right: 2px;
}

.subject-section {
  border: 1px solid #e2e8f0;
  border-radius: 16px;
  overflow: hidden;
  background: #fff;
}

.subject-heading {
  display: grid;
  grid-template-columns: 10px minmax(0, 1fr) auto auto;
  gap: 9px;
  align-items: center;
  width: 100%;
  padding: 13px;
  border: 0;
  background: #f8fafc;
  text-align: left;
  cursor: pointer;

  em {
    color: #64748b;
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
  padding: 10px;
}

.knowledge-item {
  width: 100%;
  padding: 12px;
  border: 1px solid #e2e8f0;
  border-radius: 14px;
  background: #fff;
  text-align: left;
  cursor: pointer;

  &:hover,
  &.active {
    border-color: #60a5fa;
    background: #eff6ff;
  }

  strong,
  span {
    display: block;
  }

  strong {
    font-size: 14px;
  }

  span {
    margin-top: 5px;
    color: #64748b;
    font-size: 12px;
    line-height: 1.55;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
  }
}

.related-block {
  margin-top: 16px;
  padding-top: 16px;
  border-top: 1px solid #e2e8f0;

  h3 {
    margin: 0 0 10px;
    font-size: 15px;
  }

  p {
    margin: 0;
    color: #64748b;
    font-size: 13px;
    line-height: 1.6;
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

.question-row {
  display: grid;
  gap: 4px;
  padding: 10px;
  border-radius: 12px;
  background: #f8fafc;

  span {
    color: #334155;
    line-height: 1.5;
  }

  em {
    color: #64748b;
    font-size: 12px;
    font-style: normal;
  }
}

.analysis-link {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  width: 100%;
  min-height: 42px;
  margin-top: 16px;
  border: 0;
  border-radius: 14px;
  color: #fff;
  background: linear-gradient(135deg, #2563eb, #7c3aed);
  cursor: pointer;
}

@keyframes typing {
  0%, 100% { opacity: 0.35; transform: translateY(0); }
  50% { opacity: 1; transform: translateY(-4px); }
}

@media screen and (max-width: 1280px) {
  .workbench-grid {
    grid-template-columns: 280px minmax(0, 1fr);
  }

  .catalog-column {
    grid-column: 1 / -1;
    grid-template-columns: 1fr 1fr;
  }
}

@media screen and (max-width: 900px) {
  .study-workbench {
    padding: 14px;
  }

  .workbench-header,
  .workbench-grid,
  .catalog-column {
    grid-template-columns: 1fr;
  }

  .header-actions,
  .prompt-actions {
    flex-direction: column;
  }

  .message-bubble {
    max-width: 94%;
  }
}

@media screen and (max-width: 560px) {
  .workbench-header {
    padding: 20px;

    h1 {
      font-size: 28px;
    }
  }

  .profile-summary,
  .skill-grid {
    grid-template-columns: 1fr;
  }
}
</style>
