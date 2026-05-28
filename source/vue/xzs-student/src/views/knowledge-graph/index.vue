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
          <el-icon><Search /></el-icon>
          生成学习画像
        </button>
        <button @click="draftGeneratePaper">
          <el-icon><MagicStick /></el-icon>
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
            <p>当前讲法：{{ currentStyle.name }}</p>
          </div>
          <el-tag v-if="activeContextTag" effect="plain">{{ activeContextTag }}</el-tag>
        </div>

        <div class="conversation-actions">
          <button :class="{ active: activeQuickAction === 'knowledge' }" @click="pickRandomKnowledgePoint">
            <span>知识点</span>
            <strong>{{ randomKnowledgeButtonText }}</strong>
          </button>
          <button :class="{ active: activeQuickAction === 'exam' }" @click="pickRandomExamQuestion">
            <span>真题</span>
            <strong>{{ randomExamButtonText }}</strong>
          </button>
          <button :class="{ active: activeQuickAction === 'wrong' }" @click="pickRandomWrongQuestion">
            <span>错题</span>
            <strong>{{ randomWrongButtonText }}</strong>
          </button>
          <button :class="{ active: activeQuickAction === 'paste' }" @click="focusPasteInput">
            <span>输入</span>
            <strong>粘贴</strong>
          </button>
        </div>

        <div v-if="hasActiveContext" class="context-card" :class="{ 'knowledge-context-card': contextMode === 'knowledge' }">
          <div v-if="contextMode === 'knowledge'">
            <strong>{{ activeContextTitle }}</strong>
            <KnowledgeHtml
              v-if="selectedPointDetail.htmlRef"
              class="knowledge-html-content"
              :src="selectedPointDetail.htmlRef"
              :fallback="activeContextDescription"
            />
            <p v-else>{{ activeContextDescription }}</p>
          </div>
          <p v-else class="question-context-text">{{ activeContextDescription }}</p>
        </div>

        <div ref="messagesRef" class="chat-messages">
          <div v-for="(msg, index) in messages" :key="index" :class="['message-bubble', msg.role]">
            <div v-if="msg.agentDraft" class="agent-draft-card">
              <div class="draft-card-title">
                <span>Agent 草案</span>
                <strong>{{ msg.agentDraft.title || 'AI 练习草案' }}</strong>
              </div>
              <p>{{ msg.agentDraft.confirmText || msg.agentDraft.reason }}</p>
              <div class="draft-meta">
                <span>题量：{{ msg.agentDraft.questionCount }} 题</span>
                <span>限时：{{ msg.agentDraft.minutes }} 分钟</span>
                <span>候选：{{ (msg.agentDraft.candidateQuestionIds || []).length }} 道</span>
                <span v-if="msg.agentDraft.knowledgePoint">知识点：{{ msg.agentDraft.knowledgePoint }}</span>
              </div>
              <div v-if="msg.agentDraft.reason" class="draft-reason">{{ msg.agentDraft.reason }}</div>
              <div v-if="msg.agentDraft.fallbackKnowledgePoints && msg.agentDraft.fallbackKnowledgePoints.length" class="draft-fallback">
                可放宽到：{{ msg.agentDraft.fallbackKnowledgePoints.join('、') }}
              </div>
              <div v-if="msg.agentDraft.candidateQuestionIds && msg.agentDraft.candidateQuestionIds.length" class="draft-ids">
                题目 ID：{{ msg.agentDraft.candidateQuestionIds.join(', ') }}
              </div>
              <div class="draft-actions">
                <el-button
                  type="primary"
                  size="small"
                  :disabled="isTyping || !(msg.agentDraft.candidateQuestionIds || []).length"
                  @click="confirmAgentDraft(msg)"
                >
                  确认生成
                </el-button>
                <el-button size="small" :disabled="isTyping" @click="reviseAgentDraft(msg)">调整条件</el-button>
              </div>
            </div>
            <div v-else v-html="formatMessage(msg.content)"></div>
          </div>
          <div v-if="isTyping" class="typing-line">
            <span></span><span></span><span></span>
          </div>
        </div>

        <div class="chat-input">
          <el-input
            ref="inputRef"
            v-model="inputMessage"
            type="textarea"
            :rows="4"
            placeholder="粘贴题目，或围绕当前上下文向 AI 提问..."
            @keydown.enter.ctrl="sendMessage"
          />
          <div class="input-footer">
            <span>Ctrl + Enter 发送</span>
            <div class="send-actions">
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
              <button
                v-for="question in relatedQuestions"
                :key="question.id"
                class="question-row"
                :class="{ active: contextMode === 'question' && selectedQuestion && selectedQuestion.id === question.id }"
                @click="draftRelatedQuestion(question)"
              >
                <span>{{ getQuestionSourceTitle(question) }}</span>
                <em>{{ getQuestionBody(question) || '点击设为题目上下文' }}</em>
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
import { ElMessage } from 'element-plus'
import { ArrowDown, MagicStick, Search } from '@element-plus/icons-vue'
import { get, post, postStream } from '@/utils/request'
import KnowledgeHtml from '@/components/KnowledgeHtml.vue'

const router = useRouter()

const graphLoading = ref(false)
const keyword = ref('')
const selectedStyle = ref(localStorage.getItem('master408-default-skill') || 'default')
const selectedSubjectName = ref('全部')
const contextMode = ref('none')
const questionContext = ref('')
const selectedQuestion = ref(null)
const activeQuickAction = ref('')
const selectedPoint = ref(null)
const selectedPointDetail = reactive({})
const relatedQuestions = ref([])
const childPoints = ref([])
const inputMessage = ref('')
const draftTaskType = ref('chat')
const isTyping = ref(false)
const messages = ref([])
const messagesRef = ref(null)
const inputRef = ref(null)
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
const core408SubjectNames = ['数据结构', '计算机组成原理', '操作系统', '计算机网络']

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
    return selectedQuestion.value?.source || selectedQuestion.value?.title || '当前题目 / 问题'
  }
  return '先输入题目，或从右侧选择知识点'
})

const activeContextDescription = computed(() => {
  if (contextMode.value === 'knowledge' && selectedPoint.value) {
    return cleanKnowledgeDescription(selectedPointDetail.summaryText || selectedPointDetail.description || selectedPoint.value.description) || '这个知识点还缺少详细描述，可以先让 AI 结合知识库补全。'
  }
  if (contextMode.value === 'question' && questionContext.value) {
    return selectedQuestion.value?.body || questionContext.value
  }
  return ''
})

const activeContextTag = computed(() => {
  if (contextMode.value === 'knowledge' && selectedPoint.value) {
    return selectedPoint.value.subjectName
  }
  if (contextMode.value === 'question' && questionContext.value) {
    return selectedQuestion.value?.subjectName || currentSubjectScopeName.value || '题目上下文'
  }
  return ''
})

const currentSubjectScopeName = computed(() => {
  const name = selectedSubjectName.value
  return name && name !== '全部' ? name : ''
})

const subjectIdByName = computed(() => {
  const map = new Map()
  normalizedSubjectStats.value.forEach(subject => {
    const id = Number(subject.id)
    if (subject.name && Number.isFinite(id)) {
      map.set(subject.name, id)
    }
  })
  return map
})

const currentSubjectScopeIds = computed(() => {
  const scope = currentSubjectScopeName.value
  if (!scope) return []
  if (scope.includes('408综合')) {
    const ids = core408SubjectNames
      .map(name => subjectIdByName.value.get(name))
      .filter(id => Number.isFinite(id))
    return ids.length ? ids : [1, 2, 3, 4]
  }
  const id = subjectIdByName.value.get(scope)
  return Number.isFinite(id) ? [id] : []
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
  const groups = scopedKnowledgeGroups.value

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

const isInCurrentSubjectScope = (subjectName) => {
  const scope = currentSubjectScopeName.value
  if (!scope) return true
  if (scope.includes('408综合')) {
    return core408SubjectNames.includes(subjectName)
  }
  return subjectName === scope
}

const isQuestionInCurrentSubjectScope = (question) => {
  if (!currentSubjectScopeName.value) return true
  const id = Number(question?.subjectId)
  if (Number.isFinite(id) && currentSubjectScopeIds.value.length) {
    return currentSubjectScopeIds.value.includes(id)
  }
  return isInCurrentSubjectScope(question?.subjectName || question?.subject)
}

const scopedKnowledgeGroups = computed(() => {
  if (!currentSubjectScopeName.value) return groupedKnowledge.value
  return groupedKnowledge.value.filter(group => isInCurrentSubjectScope(group.name))
})

const allKnowledgePoints = computed(() => groupedKnowledge.value.flatMap(group => group.points))
const scopedKnowledgePoints = computed(() => scopedKnowledgeGroups.value.flatMap(group => group.points))

const randomScopeLabel = computed(() => {
  if (selectedPoint.value) {
    return selectedPointDetail.name || selectedPoint.value.name
  }
  return currentSubjectScopeName.value
})

const randomKnowledgeButtonText = computed(() => currentSubjectScopeName.value || '随机知识点')
const randomExamButtonText = computed(() => randomScopeLabel.value || '随机真题')
const randomWrongButtonText = computed(() => randomScopeLabel.value || '随机错题')

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
  if (subject.name === '全部') {
    clearKnowledgeContext()
    return
  }
  const groupNames = groupedKnowledge.value
    .filter(group => isInCurrentSubjectScope(group.name))
    .map(group => group.name)
  expandedGroups.value = Array.from(new Set([...expandedGroups.value, ...groupNames]))
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

const setQuestionContext = (question, meta = null, quickAction = '') => {
  contextMode.value = 'question'
  questionContext.value = question
  selectedQuestion.value = meta
  if (quickAction) activeQuickAction.value = quickAction
}

const getQuestionSourceTitle = (question) => {
  return question?.source || question?.paperName || question?.title || question?.name || `题目 #${question?.id || ''}`.trim()
}

const getQuestionBody = (question) => {
  const source = getQuestionSourceTitle(question)
  const body = question?.body || question?.title || question?.name || question?.shortTitle || ''
  return body === source ? '' : body
}

const loadQuestionDetail = async (questionId) => {
  if (!questionId) return null
  try {
    const response = await post('/api/student/question/select/' + questionId)
    return response.code === 1 ? response.response : null
  } catch (error) {
    return null
  }
}

const setRelatedQuestionContext = async (question, quickAction = '') => {
  const source = getQuestionSourceTitle(question)
  const detail = await loadQuestionDetail(question.id)
  const fullBody = detail ? formatQuestionContext(detail) : ''
  const body = fullBody || getQuestionBody(question) || source
  contextMode.value = 'question'
  questionContext.value = body
  selectedQuestion.value = {
    ...question,
    source,
    title: source,
    body,
    subjectName: question.subjectName || question.subject || selectedPoint.value?.subjectName || currentSubjectScopeName.value || '题目上下文'
  }
  if (quickAction) activeQuickAction.value = quickAction
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
  return `${selectedPoint.value.name}\n${cleanKnowledgeDescription(selectedPointDetail.summaryText || selectedPointDetail.description || selectedPoint.value.description)}`
}

const selectPoint = async (point, announce = true) => {
  const seq = ++selectPointSeq
  contextMode.value = 'knowledge'
  questionContext.value = ''
  selectedQuestion.value = null
  if (announce) activeQuickAction.value = ''
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
      selectedPointDetail.summaryText = cleanKnowledgeDescription(selectedPointDetail.summaryText)
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

const currentKnowledgeName = () => {
  if (contextMode.value === 'knowledge' && selectedPoint.value) {
    return selectedPointDetail.name || selectedPoint.value.name
  }
  return ''
}

const randomItem = (items) => {
  if (!items || !items.length) return null
  return items[Math.floor(Math.random() * items.length)]
}

const shuffleItems = (items) => {
  return [...items].sort(() => Math.random() - 0.5)
}

const stripHtml = (text) => {
  const raw = String(text || '')
  const fallbackMatch = raw.match(/data-fallback=(["'])(.*?)\1/)
  const source = fallbackMatch?.[2] || raw
  return source
    .replace(/<[^>]+>/g, ' ')
    .replace(/&nbsp;/g, ' ')
    .replace(/&quot;/g, '"')
    .replace(/&#39;/g, "'")
    .replace(/&lt;/g, '<')
    .replace(/&gt;/g, '>')
    .replace(/&amp;/g, '&')
    .replace(/\s+/g, ' ')
    .trim()
}

const formatQuestionContext = (question, answer = null) => {
  const lines = []
  const title = stripHtml(question?.title || question?.titleContent || question?.content || question?.shortTitle)
  if (title) lines.push(title)

  if (Array.isArray(question?.items) && question.items.length) {
    question.items.forEach(item => {
      const optionText = stripHtml(item.content)
      if (optionText) {
        lines.push(`${item.prefix ? item.prefix + '. ' : ''}${optionText}`)
      }
    })
  }

  const correct = stripHtml(question?.correct || (Array.isArray(question?.correctArray) ? question.correctArray.join('、') : ''))
  const userAnswer = stripHtml(answer?.content || (Array.isArray(answer?.contentArray) ? answer.contentArray.join('、') : ''))
  if (correct) lines.push(`正确答案：${correct}`)
  if (userAnswer) lines.push(`我的作答：${userAnswer}`)

  return lines.filter(Boolean).join('\n')
}

const expandGroupForPoint = (point) => {
  if (point?.subjectName && !expandedGroups.value.includes(point.subjectName)) {
    expandedGroups.value = [...expandedGroups.value, point.subjectName]
  }
}

const pickRandomKnowledgePoint = async () => {
  const point = randomItem(scopedKnowledgePoints.value)
  if (!point) {
    ElMessage.warning(currentSubjectScopeName.value ? `「${currentSubjectScopeName.value}」下暂时没有可选择的知识点` : '当前还没有可选择的知识点')
    return
  }
  expandGroupForPoint(point)
  await selectPoint(point)
  activeQuickAction.value = 'knowledge'
  ElMessage.success(`已选择知识点：${point.name}`)
}

const pickRandomExamQuestion = async () => {
  const canUseCurrentRelated = Boolean(selectedPoint.value)
  const localQuestion = canUseCurrentRelated
    ? randomItem(relatedQuestions.value.filter(question => isQuestionInCurrentSubjectScope(question)))
    : null
  if (localQuestion) {
    await setRelatedQuestionContext(localQuestion, 'exam')
    draftTaskType.value = 'exam'
    ElMessage.success('已选择一道关联真题')
    return
  }

  const candidates = shuffleItems(scopedKnowledgePoints.value).slice(0, 12)
  for (const point of candidates) {
    await selectPoint(point, false)
    const question = randomItem(relatedQuestions.value)
    if (question) {
      expandGroupForPoint(point)
      await setRelatedQuestionContext(question, 'exam')
      draftTaskType.value = 'exam'
      ElMessage.success('已选择一道随机真题')
      return
    }
  }

  ElMessage.warning(currentSubjectScopeName.value ? `「${currentSubjectScopeName.value}」下暂时没有可用的关联真题` : '暂时没有可用的关联真题，请先从右侧选择一个知识点')
}

const pickRandomWrongQuestion = async () => {
  try {
    const scopeIds = currentSubjectScopeIds.value
    const payload = {
      pageIndex: 1,
      pageSize: 50
    }
    if (scopeIds.length === 1) {
      payload.subjectId = scopeIds[0]
    } else if (scopeIds.length > 1) {
      payload.subjectIds = scopeIds
    }
    const response = await post('/api/student/question/answer/page', {
      ...payload
    })
    let wrongItems = (response.response?.list || []).filter(item => isQuestionInCurrentSubjectScope(item))
    if (selectedPoint.value && relatedQuestions.value.length) {
      const relatedIds = new Set(relatedQuestions.value.map(item => Number(item.id || item.questionId)).filter(Number.isFinite))
      wrongItems = wrongItems.filter(item => relatedIds.has(Number(item.questionId || item.id)))
    }
    const wrong = randomItem(wrongItems)
    if (!wrong) {
      ElMessage.warning(currentSubjectScopeName.value ? `「${currentSubjectScopeName.value}」下暂时没有可选择的错题` : '错题本里暂时没有可选择的错题')
      return
    }

    const detail = await post('/api/student/question/answer/select/' + wrong.id)
    if (detail.code !== 1 || !detail.response?.questionVM) {
      ElMessage.warning('这道错题暂时无法读取详情')
      return
    }

    const question = detail.response.questionVM
    const answer = detail.response.questionAnswerVM
    const context = formatQuestionContext(question, answer) || stripHtml(wrong.shortTitle) || `错题 #${wrong.id}`
    setQuestionContext(context, {
      id: wrong.questionId || question.id || wrong.id,
      title: `错题 #${wrong.id}`,
      source: `错题 #${wrong.id}`,
      body: context,
      subjectName: wrong.subjectName || question.subjectName || '错题'
    }, 'wrong')
    draftTaskType.value = 'exam'
    ElMessage.success('已选择一道随机错题')
  } catch (error) {
    ElMessage.error('随机错题读取失败，请稍后重试')
  }
}

const focusPasteInput = async () => {
  try {
    const text = await navigator.clipboard?.readText?.()
    const pasted = String(text || '').trim()
    if (pasted) {
      setQuestionContext(pasted, {
        title: '粘贴题目',
        source: '粘贴题目',
        body: pasted,
        subjectName: selectedSubjectName.value !== '全部' ? selectedSubjectName.value : '题目上下文'
      }, 'paste')
      draftTaskType.value = 'chat'
      ElMessage.success('已粘贴到当前上下文')
      return
    }
  } catch (error) {
    // 浏览器可能禁止读取剪贴板，退回手动粘贴。
  }
  await nextTick()
  inputRef.value?.focus?.()
  ElMessage.info('可以直接粘贴题目，Ctrl + Enter 发送')
}

const draftLearningProfile = () => {
  const subjectLines = normalizedSubjectStats.value
    .filter(subject => subject.name !== '全部')
    .map(subject => `${subject.name}：已做 ${subject.done || 0} 题，正确率 ${subject.accuracy || 0}%`)
    .join('\n')
  const context = hasActiveContext.value
    ? `当前上下文：${activeContextTitle.value}\n${activeContextDescription.value}`
    : '当前上下文：未选择具体知识点或题目'

  draftPrompt(`请根据下面的学习数据，生成我的 408 学习画像，并给出下一步复习建议。

总体数据：
已做题：${userStats.totalQuestions || 0}
综合正确率：${safePercent(userStats.accuracy)}%

分科表现：
${subjectLines || '暂无分科做题数据'}

${context}

请输出：
1. 当前学习画像
2. 可能薄弱点
3. 建议优先复习的知识点
4. 下一组针对练习应该怎么选题`, 'profile')
}

const explainKnowledge = () => {
  const target = getCurrentTarget(false)
  if (contextMode.value === 'knowledge' && selectedPoint.value && !inputMessage.value.trim()) {
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
  if (contextMode.value === 'knowledge' && selectedPoint.value && !inputMessage.value.trim()) {
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
  if (contextMode.value === 'knowledge' && selectedPoint.value && !inputMessage.value.trim()) {
    draftPrompt(`请从题库已经存在的题目中，围绕 408 知识点「${selectedPoint.value.name}」挑选 1-5 道练习题。要求标注题目 ID、知识点和题目来源；如果当前上下文没有可选题目，请只给筛选条件，不要编造新题。`, 'practice')
  } else if (target) {
    draftPrompt(`请基于下面这道题或问题，从题库已经存在的题目中挑选 1-5 道同考点练习题。要求标注题目 ID、知识点和题目来源；如果当前上下文没有可选题目，请只给筛选条件，不要编造新题：\n${target}`, 'practice')
    setQuestionContext(target)
  } else {
    draftPrompt('请从题库已经存在的题目中挑选 1-5 道 408 练习题。要求标注题目 ID、知识点和题目来源；如果当前上下文没有可选题目，请只给筛选条件，不要编造新题。', 'practice')
  }
}

const draftGeneratePaper = () => {
  const knowledgeName = currentKnowledgeName()
  draftPrompt(`请帮我生成一份 408 针对练习草案。
题量：3 题。
限时：10 分钟。
选题：${knowledgeName ? `围绕「${knowledgeName}」` : '优先结合我的错题和薄弱点'}。
约束：先给出草案，确认后再生成试卷；只能使用题库中已经存在的题目，不要编造新题。`, 'practice')
}

const draftComposePaperCommand = () => {
  const knowledgeName = currentKnowledgeName()
  draftPrompt(`/compose paper
目标：直接生成一张 408 限时练习卷。
题量：3 题。
限时：10 分钟。
选题：${knowledgeName ? `围绕「${knowledgeName}」` : '优先结合我的错题和薄弱点'}。
约束：只能使用题库中已经存在的题目，不要编造新题。`, 'practice')
}

const draftRelatedQuestion = (question) => {
  setRelatedQuestionContext(question)
  draftTaskType.value = 'exam'
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
  const isCurrentQuestionContext = contextMode.value === 'question' && questionContext.value === question
  if (!isCurrentQuestionContext && !(taskType !== 'chat' && hasStableContext)) {
    setQuestionContext(question)
  }
  draftTaskType.value = 'chat'
  sendAnalyzeMessage(question, taskType)
}

const buildFunctionPayload = (question) => {
  const lower = question.toLowerCase()
  if (!lower.includes('/compose paper')) {
    return {}
  }

  const knowledgeName = currentKnowledgeName()
  return {
    composePaper: true,
    preferMistakes: true,
    questionCount: 3,
    minutes: 10,
    name: knowledgeName ? `AI限时练习-${knowledgeName}` : 'AI限时练习',
    knowledgePoint: knowledgeName
  }
}

const shouldUseAgentPlan = (question, taskType, functionPayload) => {
  if (functionPayload.composePaper) {
    return false
  }
  return taskType === 'practice' && /练习|组卷|出题|挑选|生成|卷子|试卷/.test(question)
}

const sendAnalyzeMessage = async (question, taskType = 'chat') => {
  if (!question.trim()) return

  const userQuestion = question.trim()
  const knowledgeText = getKnowledgeText()
  const functionPayload = buildFunctionPayload(userQuestion)

  messages.value.push({ role: 'user', content: userQuestion })
  const assistantMessage = { role: 'assistant', content: '' }
  messages.value.push(assistantMessage)
  inputMessage.value = ''
  isTyping.value = true

  await nextTick()
  scrollToBottom()

  try {
    if (functionPayload.composePaper) {
      const response = await post('/api/student/ai/analyze', {
        style: selectedStyle.value,
        taskType,
        question: userQuestion,
        knowledgePoints: knowledgeText,
        ...functionPayload
      })

      if (response.code === 1) {
        const result = response.response || {}
        updateAssistantMessage(assistantMessage, result.analysis || '')
      } else {
        updateAssistantMessage(assistantMessage, normalizeComposeError(response.message))
      }
      return
    }

    if (shouldUseAgentPlan(userQuestion, taskType, functionPayload)) {
      const response = await post('/api/student/ai/agent/plan', {
        message: userQuestion,
        contextKnowledgePoint: currentKnowledgeName(),
        mode: 'compose_paper',
        questionCount: 3,
        minutes: 10,
        preferMistakes: true
      })

      if (response.code === 1) {
        assistantMessage.content = ''
        assistantMessage.agentDraft = response.response
        messages.value = messages.value.slice()
      } else {
        updateAssistantMessage(assistantMessage, normalizeComposeError(response.message))
      }
      return
    }

    let received = ''
    let references = []
    await postStream('/api/student/ai/analyze-stream', {
      style: selectedStyle.value,
      taskType,
      question: userQuestion,
      knowledgePoints: knowledgeText,
      ...functionPayload
    }, {
      onStatus: (status) => {
        if (!received) updateAssistantMessage(assistantMessage, status)
        nextTick().then(scrollToBottom)
      },
      onReferences: (raw) => {
        try {
          references = JSON.parse(raw) || []
        } catch (e) {
          references = []
        }
      },
      onChunk: (chunk) => {
        if (!received) updateAssistantMessage(assistantMessage, '')
        received += chunk
        updateAssistantMessage(assistantMessage, received)
        nextTick().then(scrollToBottom)
      },
      onError: (message) => {
        throw new Error(message || 'AI分析失败')
      }
    })

    if (!received.trim()) {
      throw new Error('AI返回内容为空')
    }
    if (references.length > 0) {
      let contentWithReferences = assistantMessage.content + '\n\n---\n参考来源\n'
      references.forEach((ref, idx) => {
        contentWithReferences += `\n${idx + 1}. [${ref.similarity}] ${ref.title}`
      })
      updateAssistantMessage(assistantMessage, contentWithReferences)
    }
  } catch (streamError) {
    try {
      const response = await post('/api/student/ai/analyze', {
        style: selectedStyle.value,
        taskType,
        question: userQuestion,
        knowledgePoints: knowledgeText,
        ...functionPayload
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
        updateAssistantMessage(assistantMessage, content)
    } else {
        updateAssistantMessage(assistantMessage, normalizeAiError(response.message))
      }
    } catch (error) {
      updateAssistantMessage(assistantMessage, normalizeAiError(error.message))
    }
  } finally {
    isTyping.value = false
    await nextTick()
    scrollToBottom()
  }
}

const confirmAgentDraft = async (message) => {
  if (!message.agentDraft || isTyping.value) return

  const draft = message.agentDraft
  const assistantMessage = { role: 'assistant', content: '正在生成限时练习卷...' }
  messages.value.push(assistantMessage)
  isTyping.value = true

  await nextTick()
  scrollToBottom()

  try {
    const response = await post('/api/student/ai/agent/confirm', {
      title: draft.title,
      knowledgePoint: draft.knowledgePoint,
      questionCount: draft.questionCount,
      minutes: draft.minutes,
      preferMistakes: draft.preferMistakes,
      questionIds: draft.candidateQuestionIds,
      runLogId: draft.runLogId
    })

    if (response.code === 1) {
      const paper = response.response
      updateAssistantMessage(assistantMessage, formatPaperResult(paper))
      message.agentDraft.status = 'confirmed'
      messages.value = messages.value.slice()
    } else {
      updateAssistantMessage(assistantMessage, normalizeComposeError(response.message))
    }
  } catch (error) {
    updateAssistantMessage(assistantMessage, normalizeComposeError(error.message))
  } finally {
    isTyping.value = false
    await nextTick()
    scrollToBottom()
  }
}

const reviseAgentDraft = (message) => {
  const draft = message.agentDraft || {}
  draftPrompt(`请调整这份练习草案：
知识点：${draft.knowledgePoint || '不限'}
当前候选题：${(draft.candidateQuestionIds || []).join(', ') || '无'}
我想调整为：`, 'practice')
}

const formatPaperResult = (paper) => {
  if (!paper) return '练习卷已生成。'
  return `## 已生成限时练习

- 试卷：${paper.paperName}
- 题量：${paper.questionCount} 道
- 限时：${paper.minutes} 分钟
- 选题策略：${paper.strategy || 'Agent 草案确认'}
- 题目 ID：${(paper.questionIds || []).join(', ')}

[开始答题](${paper.url})`
}

const updateAssistantMessage = (message, content) => {
  message.content = cleanAiDisplayContent(content)
  messages.value = messages.value.slice()
}

const formatMessage = (content) => {
  if (!content) return ''
  return renderMarkdown(cleanAiDisplayContent(content))
}

const cleanAiDisplayContent = (content) => {
  return String(content || '').replace(/^(?:null\s*)+/i, '').trimStart()
}

const normalizeComposeError = (message) => {
  const cleaned = String(message || '').replace(/^AI分析失败[:：]\s*/, '').trim()
  return cleaned || '没有生成练习卷，请放宽知识点、年份或题型限制后重试。'
}

const normalizeAiError = (message) => {
  if (String(message || '').includes('没有找到符合条件的题目')) {
    return normalizeComposeError(message)
  }
  return 'AI 服务暂时不可用，请稍后重试。'
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
    .replace(/\*(.*?)\*/g, '<em>$1</em>')
    .replace(/`(.*?)`/g, '<code>$1</code>')
    .replace(/\[([^\]]+)\]\(((?:https?:\/\/|\/)[^)\s]+)\)/g, '<a href="$2" target="_blank" rel="noopener noreferrer">$1</a>')
}

const normalizeMarkdown = (content) => {
  return content
    .replace(/\r\n/g, '\n')
    .replace(/([^\n])\s*(#{1,4})(?=\S)/g, '$1\n\n$2 ')
    .replace(/^(#{1,4})(\S)/gm, '$1 $2')
    .replace(/([。；;：:！!?？])\s*(\d+\.\s*\S)/g, '$1\n$2')
}

const renderMarkdown = (content) => {
  const lines = normalizeMarkdown(content).split('\n')
  const html = []
  let listType = ''
  let inCode = false
  const codeLines = []

  const closeList = () => {
    if (listType) {
      html.push(`</${listType}>`)
      listType = ''
    }
  }

  const openList = (type) => {
    if (listType !== type) {
      closeList()
      html.push(`<${type}>`)
      listType = type
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
      openList('ul')
      html.push(`<li>${renderInlineMarkdown(listItem[1])}</li>`)
      return
    }

    if (/^---+$/.test(trimmed)) {
      closeList()
      html.push('<hr>')
      return
    }

    const quote = trimmed.match(/^>\s+(.+)$/)
    if (quote) {
      closeList()
      html.push(`<blockquote>${renderInlineMarkdown(quote[1])}</blockquote>`)
      return
    }

    const numberedItem = trimmed.match(/^\d+\.\s+(.+)$/)
    if (numberedItem) {
      openList('ol')
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
  min-width: 0;
  display: grid;
  gap: 16px;
}

.panel-card {
  min-width: 0;
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
  min-width: 0;
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

.conversation-actions {
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 10px;
  margin-bottom: 14px;

  button {
    display: grid;
    gap: 4px;
    min-height: 64px;
    padding: 12px;
    border: 1px solid #dbeafe;
    border-radius: 14px;
    color: #334155;
    background: #f8fbff;
    text-align: left;
    cursor: pointer;
    transition: border-color 0.18s ease, background 0.18s ease, transform 0.18s ease;

    &:hover {
      border-color: #60a5fa;
      background: #eff6ff;
      transform: translateY(-1px);
    }

    &.active {
      border-color: #2563eb;
      background: #eff6ff;
      box-shadow: inset 0 0 0 1px rgba(37, 99, 235, 0.18);
    }

    span {
      color: #2563eb;
      font-size: 12px;
      font-weight: 800;
    }

    strong {
      font-size: 13px;
      line-height: 1.35;
    }

  }
}

.context-card {
  display: grid;
  gap: 14px;
  min-width: 0;
  max-width: 100%;
  margin-bottom: 14px;
  padding: 16px;
  overflow: hidden;
  border: 1px solid #bfdbfe;
  border-radius: 18px;
  background: #eff6ff;

  > div {
    min-width: 0;
    max-width: 100%;
  }

  strong {
    font-size: 17px;
  }

  p {
    margin: 7px 0 0;
    color: #475569;
    line-height: 1.7;
  }

  .question-context-text {
    white-space: pre-wrap;
  }

  :deep(.knowledge-html-content) {
    min-width: 0;
    max-width: 100%;
    margin-top: 10px;
    overflow-x: auto;
    overflow-y: hidden;
    color: #334155;
    line-height: 1.75;
    overscroll-behavior-x: contain;
    scrollbar-width: thin;
  }

  :deep(.knowledge-html-content *) {
    box-sizing: border-box;
  }

  :deep(.knowledge-html-content h1),
  :deep(.knowledge-html-content h2),
  :deep(.knowledge-html-content h3),
  :deep(.knowledge-html-content h4) {
    margin: 16px 0 8px;
    color: #172033;
    line-height: 1.35;
  }

  :deep(.knowledge-html-content h1:first-child),
  :deep(.knowledge-html-content h2:first-child),
  :deep(.knowledge-html-content h3:first-child),
  :deep(.knowledge-html-content p:first-child) {
    margin-top: 0;
  }

  :deep(.knowledge-html-content p),
  :deep(.knowledge-html-content ul),
  :deep(.knowledge-html-content ol) {
    margin: 8px 0;
  }

  :deep(.knowledge-html-content ul),
  :deep(.knowledge-html-content ol) {
    padding-left: 22px;
  }

  :deep(.knowledge-html-content img) {
    display: block;
    max-width: 100%;
    height: auto;
    margin: 10px 0;
    border-radius: 10px;
  }

  :deep(.knowledge-html-content svg) {
    display: none;
  }

  :deep(.knowledge-html-content .svg-wrapper svg),
  :deep(.knowledge-html-content .svg-container svg) {
    display: block;
    width: auto !important;
    height: auto !important;
    max-width: none !important;
    max-height: none !important;
    margin: 10px 0 !important;
  }

  :deep(.knowledge-html-content table) {
    display: block;
    width: max-content;
    max-width: 100%;
    margin: 12px 0;
    overflow-x: auto;
    border-collapse: collapse;
    border-radius: 10px;
    white-space: nowrap;
  }

  :deep(.knowledge-html-content th),
  :deep(.knowledge-html-content td) {
    padding: 8px 10px;
    border: 1px solid #bfdbfe;
    vertical-align: top;
  }

  :deep(.knowledge-html-content th) {
    background: #dbeafe;
  }

  :deep(.knowledge-html-content pre) {
    max-width: 100%;
    overflow-x: auto;
    padding: 12px;
    border-radius: 12px;
    background: #f8fafc;
    color: #111827;
    white-space: pre;
    overscroll-behavior-x: contain;
  }

  :deep(.knowledge-html-content code) {
    padding: 2px 5px;
    border-radius: 4px;
    background: rgba(37, 99, 235, 0.1);
  }

  :deep(.knowledge-html-content pre code) {
    padding: 0;
    background: transparent;
  }
}

.knowledge-context-card {
  max-height: 560px;
  overflow: auto;
  overscroll-behavior: contain;
  scrollbar-width: thin;

  :deep(.knowledge-html-content) {
    overflow: visible;
  }

  :deep(.knowledge-html-content table) {
    max-width: none;
  }

  :deep(.knowledge-html-content pre) {
    width: max-content;
    min-width: 100%;
    max-width: none;
    overflow: visible;
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

  :deep(ul),
  :deep(ol) {
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

  &.active {
    border-color: #2563eb;
    background: #dbeafe;
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

.agent-draft-card {
  display: grid;
  gap: 12px;
  min-width: min(560px, 76vw);

  p {
    margin: 0;
    line-height: 1.7;
  }
}

.draft-card-title {
  display: grid;
  gap: 4px;

  span {
    color: #93c5fd;
    font-size: 12px;
    letter-spacing: 0.08em;
    text-transform: uppercase;
  }

  strong {
    font-size: 18px;
  }
}

.draft-meta {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;

  span {
    padding: 5px 8px;
    border-radius: 999px;
    color: #dbeafe;
    background: rgba(37, 99, 235, 0.28);
    font-size: 12px;
  }
}

.draft-reason,
.draft-fallback,
.draft-ids {
  color: #cbd5e1;
  font-size: 13px;
  line-height: 1.6;
}

.draft-actions {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
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

  .conversation-actions {
    grid-template-columns: repeat(2, minmax(0, 1fr));
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
  .skill-grid,
  .conversation-actions {
    grid-template-columns: 1fr;
  }
}
</style>
