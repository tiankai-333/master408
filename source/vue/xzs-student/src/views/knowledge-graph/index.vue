<template>
  <div class="study-workbench">
    <section class="workbench-header">
      <div>
        <span class="eyebrow">408Master AI Tutor</span>
        <h1>AI 学习工作台</h1>
        <p>先粘贴题目，或从右侧选择知识点，AI 会围绕当前上下文进行讲解、追问与练习。</p>
      </div>
      <div class="header-actions">
        <button @click="draftLearningProfile">
          <el-icon><MagicStick /></el-icon>
          生成学习画像
        </button>
        <button @click="draftTargetedPractice">
          <el-icon><Edit /></el-icon>
          生成针对练习
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
            <h2>{{ activeContextTitle }}</h2>
            <p>
              当前讲法：{{ currentStyle.name }}
              <template v-if="activeContextTag"> · {{ activeContextTag }}</template>
            </p>
          </div>
          <el-tag v-if="activeContextTag" effect="plain">{{ activeContextTag }}</el-tag>
        </div>

        <div v-if="hasActiveContext" class="context-card">
          <div>
            <strong>{{ activeContextTitle }}</strong>
            <p>{{ activeContextDescription }}</p>
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
            <div class="send-actions">
              <button @click="explainKnowledge">结合知识库讲解</button>
              <button @click="explainWithExam">结合真题讲解</button>
              <button @click="generatePractice">生成练习题</button>
              <el-button type="primary" :loading="isTyping" @click="sendMessage">发送</el-button>
            </div>
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
                  :class="{ active: contextMode === 'knowledge' && selectedPoint && selectedPoint.rawId === point.rawId }"
                  @click="selectPoint(point)"
                >
                  <strong>{{ point.name }}</strong>
                  <span>{{ knowledgeSummary(point.description) || '点击后加入 AI 对话上下文' }}</span>
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
            <p v-else>右侧点击知识点后，这里会展示可继续学习的关联内容。</p>
          </div>
          <div class="related-block">
            <h3>关联真题</h3>
            <div v-if="relatedQuestions.length" class="question-list">
              <button v-for="question in relatedQuestions" :key="question.id" class="question-row" @click="draftRelatedQuestion(question)">
                <span>{{ question.title || question.name || `题目 #${question.id}` }}</span>
                <em>{{ question.source || question.difficult ? `${question.source || '真题'} · 难度 ${question.difficult || '-'}` : '点击加入输入框' }}</em>
              </button>
            </div>
            <p v-else>点击知识点后会显示已关联真题；直接提交题目时，AI 会优先围绕题目本身回答。</p>
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
const contextMode = ref('none')
const questionContext = ref('')
const selectedPoint = ref(null)
const selectedPointDetail = reactive({})
const relatedQuestions = ref([])
const childPoints = ref([])
const inputMessage = ref('')
const draftTaskType = ref('chat')
const isTyping = ref(false)
const messages = ref([])
const messagesRef = ref(null)
const expandedGroups = ref([])
let selectPointSeq = 0

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

const hasActiveContext = computed(() => {
  return (contextMode.value === 'knowledge' && selectedPoint.value) ||
    (contextMode.value === 'question' && questionContext.value)
})

const activeContextTitle = computed(() => {
  if (contextMode.value === 'knowledge' && selectedPoint.value) {
    return selectedPointDetail.name || selectedPoint.value.name
  }
  if (contextMode.value === 'question' && questionContext.value) {
    return '当前题目 / 问题'
  }
  return '先输入题目，或从右侧选择知识点'
})

const activeContextDescription = computed(() => {
  if (contextMode.value === 'knowledge' && selectedPoint.value) {
    return cleanKnowledgeDescription(selectedPointDetail.description || selectedPoint.value.description) || '这个知识点还缺少详细描述，可以先让 AI 结合知识库补全。'
  }
  if (contextMode.value === 'question' && questionContext.value) {
    return questionContext.value
  }
  return ''
})

const activeContextTag = computed(() => {
  if (contextMode.value === 'knowledge' && selectedPoint.value) {
    return selectedPoint.value.subjectName
  }
  if (contextMode.value === 'question' && questionContext.value) {
    return '题目上下文'
  }
  return ''
})

const totalKnowledgePoints = computed(() => {
  return graphData.nodes.filter(node => normalizeType(node.type) === 'knowledge_point').length
})

const groupedKnowledge = computed(() => {
  const categoryNames = graphData.categories.map(item => typeof item === 'string' ? item : item.name)
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
    .filter(node => isUsefulKnowledgeName(node.name))
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
        description: cleanKnowledgeDescription(node.description),
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

const isUsefulKnowledgeName = (name) => {
  const value = String(name || '').trim()
  if (!value) return false
  if (/^[a-e]{3,}$/i.test(value)) return false
  if (/^([a-zA-Z][,，、\s]*){3,}$/.test(value) && /[,，、\s]/.test(value)) return false
  return true
}

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

const cleanKnowledgeDescription = (text) => {
  const raw = String(text || '')
    .replace(/\r\n/g, '\n')
    .replace(/#{1,6}\s*/g, '')
    .replace(/\*\*(.*?)\*\*/g, '$1')
    .replace(/`(.*?)`/g, '$1')

  const lines = raw.split('\n')
    .map(line => line.trim())
    .filter(line => {
      if (!line) return false
      if (/^[A-E]$/i.test(line)) return false
      if (/^\d{1,3}$/.test(line)) return false
      if (/^mindmap$/i.test(line)) return false
      if (/^root\(\(/i.test(line)) return false
      if (/^[A-Za-z]\d+$/.test(line)) return false
      if (/^[A-Za-z0-9_]+->[A-Za-z0-9_]+$/.test(line)) return false
      return true
    })

  return lines.join(' ')
    .replace(/\s+/g, ' ')
    .replace(/\s+([，。；：、,.!?])/g, '$1')
    .trim()
}

const knowledgeSummary = (text, limit = 92) => {
  const value = cleanKnowledgeDescription(text)
  return value.length > limit ? `${value.slice(0, limit)}...` : value
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
      expandedGroups.value = []
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
}

const toggleGroup = (name) => {
  if (expandedGroups.value.includes(name)) {
    expandedGroups.value = expandedGroups.value.filter(item => item !== name)
  } else {
    expandedGroups.value = [...expandedGroups.value, name]
  }
}

const clearKnowledgeContext = () => {
  selectedPoint.value = null
  Object.keys(selectedPointDetail).forEach(key => delete selectedPointDetail[key])
  relatedQuestions.value = []
  childPoints.value = []
}

const setQuestionContext = (question) => {
  contextMode.value = 'question'
  questionContext.value = question
  clearKnowledgeContext()
}

const stripDraftInstruction = (text) => {
  return text
    .replace(/^请用.+?结合知识库讲解下面这道题或问题：\n/, '')
    .replace(/^请结合 408 真题讲解下面这道题或问题，指出考点、解题抓手和易错点：\n/, '')
    .replace(/^请基于下面这道题或问题，生成一道同考点的 408 统考风格变式练习题：\n/, '')
    .replace(/^请结合这道关联真题讲解考点、解题步骤和易错点：\n/, '')
    .trim()
}

const getCurrentTarget = (preferDraft = true) => {
  const draft = inputMessage.value.trim()
  if (!preferDraft) {
    if (contextMode.value === 'question' && questionContext.value) return questionContext.value
    if (contextMode.value === 'knowledge' && selectedPoint.value) return selectedPoint.value.name
    return stripDraftInstruction(draft)
  }
  if (draft) return stripDraftInstruction(draft)
  if (contextMode.value === 'question' && questionContext.value) return questionContext.value
  if (contextMode.value === 'knowledge' && selectedPoint.value) return selectedPoint.value.name
  return ''
}

const getKnowledgeText = () => {
  if (contextMode.value !== 'knowledge' || !selectedPoint.value) return ''
  return `${selectedPoint.value.name}\n${cleanKnowledgeDescription(selectedPointDetail.description || selectedPoint.value.description)}`
}

const selectPoint = async (point, announce = true) => {
  const seq = ++selectPointSeq
  contextMode.value = 'knowledge'
  questionContext.value = ''
  selectedPoint.value = point
  Object.keys(selectedPointDetail).forEach(key => delete selectedPointDetail[key])
  relatedQuestions.value = []
  childPoints.value = []

  try {
    const response = await get('/api/student/knowledge-graph/knowledge-point/' + point.rawId)
    if (seq !== selectPointSeq) return
    if (response.code === 1) {
      Object.assign(selectedPointDetail, response.response || {})
      selectedPointDetail.subjectName = selectedPointDetail.subjectName || point.subjectName
      selectedPointDetail.description = cleanKnowledgeDescription(selectedPointDetail.description)
      relatedQuestions.value = response.response?.relatedQuestions || []
      childPoints.value = response.response?.children || []
    }
  } catch (error) {
    if (seq !== selectPointSeq) return
    Object.assign(selectedPointDetail, {
      id: point.rawId,
      name: point.name,
      description: point.description,
      subjectName: point.subjectName
    })
  }

  if (announce) await nextTick()
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

const draftPrompt = (content, taskType = 'chat') => {
  inputMessage.value = content
  draftTaskType.value = taskType
}

const appendIntent = (intent, taskType = 'chat') => {
  const draft = inputMessage.value.trim()
  inputMessage.value = draft ? `${draft}\n\n${intent}` : intent
  draftTaskType.value = taskType
}

const explainKnowledge = () => {
  const target = getCurrentTarget(false)
  if (inputMessage.value.trim()) {
    appendIntent(`请用${currentStyle.value.name}结合知识库讲解，补充定义、常见考法和易错点。`, 'explain')
  } else if (contextMode.value === 'knowledge' && selectedPoint.value) {
    draftPrompt(`请用${currentStyle.value.name}讲解 408 知识点「${selectedPoint.value.name}」，说明定义、常见考法和易错点。`, 'explain')
  } else if (target) {
    draftPrompt(`请用${currentStyle.value.name}结合知识库讲解下面这道题或问题：\n${target}`, 'explain')
    setQuestionContext(target)
  } else {
    draftPrompt(`请用${currentStyle.value.name}给我梳理 408 的一个高频知识点，并说明如何复习。`, 'explain')
  }
}

const explainWithExam = () => {
  const target = getCurrentTarget(false)
  if (inputMessage.value.trim()) {
    appendIntent('请结合 408 真题讲解，指出考点、解题抓手和易错点。', 'exam')
  } else if (contextMode.value === 'knowledge' && selectedPoint.value) {
    draftPrompt(`请结合 408 真题讲解「${selectedPoint.value.name}」，指出常见设问方式、解题步骤和容易掉坑的地方。`, 'exam')
  } else if (target) {
    draftPrompt(`请结合 408 真题讲解下面这道题或问题，指出考点、解题抓手和易错点：\n${target}`, 'exam')
    setQuestionContext(target)
  } else {
    draftPrompt('请举一个 408 真题风格场景，说明常见考法和解题抓手。', 'exam')
  }
}

const generatePractice = () => {
  const target = getCurrentTarget(false)
  if (inputMessage.value.trim()) {
    appendIntent('请基于上面的内容生成一道同考点的 408 统考风格练习题，并给出答案与解析。', 'practice')
  } else if (contextMode.value === 'knowledge' && selectedPoint.value) {
    draftPrompt(`请围绕 408 知识点「${selectedPoint.value.name}」生成一道统考风格练习题。`, 'practice')
  } else if (target) {
    draftPrompt(`请基于下面这道题或问题，生成一道同考点的 408 统考风格变式练习题：\n${target}`, 'practice')
    setQuestionContext(target)
  } else {
    draftPrompt('请生成一道 408 统考风格练习题。', 'practice')
  }
}

const draftLearningProfile = () => {
  draftPrompt(`请根据我的学习状态、做题记录、错题和薄弱学科，生成一份 408 学习画像。要求包括：\n1. 当前整体水平判断\n2. 四门科目的掌握情况\n3. 最值得优先补的知识点\n4. 接下来一周的复习安排`, 'chat')
}

const draftTargetedPractice = () => {
  draftPrompt(`请根据我的错题、薄弱知识点和近期做题情况，生成一组针对性 408 练习题。要求优先使用真题风格，覆盖薄弱科目，并给出答案与解析。`, 'practice')
}

const draftRelatedQuestion = (question) => {
  const title = question.title || question.name || `题目 #${question.id}`
  draftPrompt(`请结合这道关联真题讲解考点、解题步骤和易错点：\n${title}`, 'exam')
}

const goAiAnalyze = () => {
  router.push({ path: '/question/ai-analyze' })
}

const sendMessage = () => {
  const question = inputMessage.value.trim()
  if (!question) return
  const taskType = draftTaskType.value || 'chat'
  const hasStableContext = (contextMode.value === 'knowledge' && selectedPoint.value) ||
    (contextMode.value === 'question' && questionContext.value)
  if (!(taskType !== 'chat' && hasStableContext)) {
    setQuestionContext(question)
  }
  draftTaskType.value = 'chat'
  sendAnalyzeMessage(question, taskType)
}

const sendAnalyzeMessage = async (question, taskType = 'chat') => {
  if (!question.trim()) return

  const userQuestion = question.trim()
  const knowledgeText = getKnowledgeText()

  messages.value.push({ role: 'user', content: userQuestion })
  inputMessage.value = ''
  isTyping.value = true

  await nextTick()
  scrollToBottom()

  try {
    const response = await post('/api/student/ai/analyze', {
      style: selectedStyle.value,
      taskType,
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
  const contextName = contextMode.value === 'knowledge' && selectedPoint.value ? selectedPoint.value.name : '当前题目 / 问题'
  return `当前 AI 服务暂时不可用，但可以先按 ${currentStyle.value.name} 的思路学习「${contextName}」：

1. 先确认它属于哪一科以及常见题型。
2. 再把定义、约束条件和典型公式写清楚。
3. 最后用一道真题或模拟题验证是否真的会用。

你的问题：${question}`
}

const formatMessage = (content) => {
  if (!content) return ''
  return renderMarkdown(String(content))
}

const escapeHtml = (text) => {
  return String(text)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
}

const renderInlineMarkdown = (text) => {
  return escapeHtml(text)
    .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
    .replace(/`(.*?)`/g, '<code>$1</code>')
}

const renderMarkdown = (content) => {
  const lines = content.replace(/\r\n/g, '\n').split('\n')
  const html = []
  let inList = false
  let inCode = false
  const codeLines = []

  const closeList = () => {
    if (inList) {
      html.push('</ul>')
      inList = false
    }
  }

  lines.forEach(line => {
    if (line.trim().startsWith('```')) {
      if (inCode) {
        html.push(`<pre><code>${escapeHtml(codeLines.join('\n'))}</code></pre>`)
        codeLines.length = 0
        inCode = false
      } else {
        closeList()
        inCode = true
      }
      return
    }

    if (inCode) {
      codeLines.push(line)
      return
    }

    const trimmed = line.trim()
    if (!trimmed) {
      closeList()
      return
    }

    const heading = trimmed.match(/^(#{1,4})\s+(.+)$/)
    if (heading) {
      closeList()
      const level = Math.min(heading[1].length + 2, 5)
      html.push(`<h${level}>${renderInlineMarkdown(heading[2])}</h${level}>`)
      return
    }

    const listItem = trimmed.match(/^[-*]\s+(.+)$/)
    if (listItem) {
      if (!inList) {
        html.push('<ul>')
        inList = true
      }
      html.push(`<li>${renderInlineMarkdown(listItem[1])}</li>`)
      return
    }

    const numberedItem = trimmed.match(/^\d+\.\s+(.+)$/)
    if (numberedItem) {
      if (!inList) {
        html.push('<ul>')
        inList = true
      }
      html.push(`<li>${renderInlineMarkdown(numberedItem[1])}</li>`)
      return
    }

    closeList()
    html.push(`<p>${renderInlineMarkdown(trimmed)}</p>`)
  })

  closeList()
  if (inCode) {
    html.push(`<pre><code>${escapeHtml(codeLines.join('\n'))}</code></pre>`)
  }
  return html.join('')
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
    content: '欢迎来到 AI 学习工作台。你可以先粘贴题目，也可以从右侧知识目录手动选择上下文。'
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

  :deep(h3),
  :deep(h4),
  :deep(h5) {
    margin: 12px 0 8px;
    color: #172033;
    line-height: 1.35;
  }

  :deep(h3:first-child),
  :deep(h4:first-child),
  :deep(h5:first-child),
  :deep(p:first-child) {
    margin-top: 0;
  }

  :deep(p) {
    margin: 8px 0;
  }

  :deep(ul) {
    margin: 8px 0;
    padding-left: 20px;
  }

  :deep(li) {
    margin: 5px 0;
  }

  :deep(pre) {
    overflow-x: auto;
    margin: 10px 0;
    padding: 12px;
    border-radius: 12px;
    background: #e2e8f0;
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

.send-actions {
  display: flex;
  flex-wrap: wrap;
  justify-content: flex-end;
  gap: 8px;

  button {
    min-height: 32px;
    padding: 0 11px;
    border: 1px solid #93c5fd;
    border-radius: 999px;
    color: #1d4ed8;
    background: #fff;
    cursor: pointer;
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
  width: 100%;
  padding: 10px;
  border: 1px solid transparent;
  border-radius: 12px;
  background: #f8fafc;
  text-align: left;
  cursor: pointer;

  &:hover {
    border-color: #93c5fd;
    background: #eff6ff;
  }

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
  .send-actions,
  .input-footer {
    flex-direction: column;
    align-items: stretch;
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
