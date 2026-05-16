<template>
  <div class="master-container">
    <div class="master-header">
      <div class="avatar-circle">
        <el-icon><MagicStick /></el-icon>
      </div>
      <div class="header-info">
        <h2>408Master</h2>
        <p>你的专属考研408智能导师</p>
      </div>
      <div class="header-stats">
        <div class="stat-item">
          <span class="stat-value">{{ userStats.totalQuestions }}</span>
          <span class="stat-label">总做题</span>
        </div>
        <div class="stat-item">
          <span class="stat-value">{{ userStats.accuracy }}%</span>
          <span class="stat-label">正确率</span>
        </div>
        <div class="stat-item">
          <span class="stat-value">{{ userStats.weakPoints }}</span>
          <span class="stat-label">薄弱点</span>
        </div>
      </div>
    </div>

    <div class="master-content">
      <div class="left-panel">
        <el-card class="profile-card" shadow="hover">
          <template #header>
            <div class="card-header"><el-icon><User /></el-icon><span>学习状态</span></div>
          </template>
          <div class="profile-content">
            <div class="accuracy-bar">
              <div class="bar-label">正确率</div>
              <el-progress :percentage="userStats.accuracy" :color="progressColor" :stroke-width="10" />
            </div>
            <div class="subject-stats">
              <div v-for="subject in subjectStats" :key="subject.id" class="subject-item">
                <span class="subject-name">{{ subject.name }}</span>
                <el-progress :percentage="subject.accuracy" :stroke-width="8" />
              </div>
            </div>
          </div>
        </el-card>

        <el-card class="quick-actions" shadow="hover">
          <template #header>
            <div class="card-header"><el-icon><MagicStick /></el-icon><span>快捷工具</span></div>
          </template>
          <div class="action-buttons">
            <el-button type="primary" size="small" class="action-btn" @click="quickAction('analyze')">
              <el-icon><Search /></el-icon>
              <span>题目解析</span>
            </el-button>
            <el-button type="success" size="small" class="action-btn" @click="quickAction('practice')">
              <el-icon><Edit /></el-icon>
              <span>生成练习</span>
            </el-button>
            <el-button type="warning" size="small" class="action-btn" @click="quickAction('review')">
              <el-icon><Document /></el-icon>
              <span>错题回顾</span>
            </el-button>
            <el-button type="info" size="small" class="action-btn" @click="quickAction('suggestion')">
              <el-icon><MagicStick /></el-icon>
              <span>学习建议</span>
            </el-button>
          </div>
        </el-card>

        <el-card class="knowledge-mini" shadow="hover">
          <template #header>
            <div class="card-header"><el-icon><MagicStick /></el-icon><span>AI 解析风格</span></div>
          </template>
          <div class="style-buttons">
            <div v-for="style in aiStyles" :key="style.id"
                 :class="['style-btn', { active: selectedStyle === style.id }]"
                 @click="switchStyle(style.id)">
              <span class="style-emoji">{{ style.emoji }}</span>
              <span class="style-name">{{ style.name }}</span>
              <span class="style-desc">{{ style.description }}</span>
            </div>
          </div>
        </el-card>
      </div>

      <div class="center-panel">
        <div class="chat-container">
          <div class="chat-messages" ref="messagesRef">
            <div v-for="(msg, index) in messages" :key="index" 
                 :class="['message-item', msg.role === 'user' ? 'user-message' : 'ai-message']">
              <template v-if="msg.role === 'assistant'">
                <div class="message-avatar">
                  <el-icon><MagicStick /></el-icon>
                </div>
                <div class="message-content" v-html="formatMessage(msg.content)"></div>
              </template>
              <template v-else>
                <div class="message-content" v-html="formatMessage(msg.content)"></div>
                <div class="message-avatar user-avatar">
                  <el-icon><User /></el-icon>
                </div>
              </template>
            </div>
            <div v-if="isTyping" class="typing-indicator">
              <div class="typing-dot"></div>
              <div class="typing-dot"></div>
              <div class="typing-dot"></div>
            </div>
          </div>
          <div class="chat-input">
            <el-input
              v-model="inputMessage"
              type="textarea"
              :rows="2"
              placeholder="问我任何关于408的问题..."
              @keydown.enter.ctrl="sendMessage"
            />
            <div class="input-actions">
              <span class="tip-text">Ctrl + Enter 发送</span>
              <el-button type="primary" :loading="isTyping" @click="sendMessage">
                <el-icon><Edit /></el-icon>
                发送
              </el-button>
            </div>
          </div>
        </div>
      </div>

      <div class="right-panel">
        <el-card class="graph-panel" shadow="hover">
          <template #header>
            <div class="card-header">
              <el-icon><Share /></el-icon>
              <span>知识图谱</span>
              <el-select v-model="filterSubject" size="small" placeholder="选择学科" @change="loadGraph" style="margin-left: auto;">
                <el-option label="全部" :value="null" />
                <el-option v-for="subject in subjects" :key="subject.id" :label="subject.name" :value="subject.id" />
              </el-select>
            </div>
          </template>
          <div ref="chartRef" class="graph-chart"></div>
        </el-card>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted, nextTick } from 'vue'
import { ElMessage } from 'element-plus'
import * as echarts from 'echarts'
import { User, MagicStick, Search, Edit, Document, Picture, WarningFilled, Share } from '@element-plus/icons-vue'
import { get, post } from '@/utils/request'

const inputMessage = ref('')
const isTyping = ref(false)
const messages = ref([])
const filterSubject = ref(null)
const subjects = ref([])
const chartRef = ref(null)
const messagesRef = ref(null)
const chartInstance = ref(null)
const graphData = reactive({ nodes: [], links: [], categories: [] })

const selectedStyle = ref('default')
const aiStyles = [
  { id: 'default', emoji: '📚', name: '标准解析', description: '清晰讲透知识点' },
  { id: 'feynman', emoji: '🎓', name: '费曼风格', description: '像给小白讲故事' },
  { id: 'plato', emoji: '❓', name: '柏拉图式', description: '启发式自问自答' },
  { id: 'first-principles', emoji: '⚡', name: '第一性原理', description: '从本质逐步推导' }
]

const userStats = reactive({
  totalQuestions: 0,
  accuracy: 0,
  weakPoints: 0
})

const subjectStats = ref([
  { id: 1, name: '数据结构', accuracy: 75 },
  { id: 2, name: '组成原理', accuracy: 62 },
  { id: 3, name: '操作系统', accuracy: 80 },
  { id: 4, name: '计算机网络', accuracy: 70 }
])

const progressColor = computed(() => {
  if (userStats.accuracy >= 80) return '#67c23a'
  if (userStats.accuracy >= 60) return '#e6a23c'
  return '#f56c6c'
})

const formatMessage = (content) => {
  if (!content) return ''
  let formatted = content
    .replace(/\n/g, '<br>')
    .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
    .replace(/`(.*?)`/g, '<code>$1</code>')
    .replace(/^###\s(.*)/gm, '<h3>$1</h3>')
    .replace(/^##\s(.*)/gm, '<h2>$1</h2>')
    .replace(/^\*\s(.*)/gm, '<li>$1</li>')
    .replace(/^(\d+)\.\s(.*)/gm, '<li>$2</li>')
  return formatted
}

const loadSubjects = async () => {
  try {
    const response = await get('/api/student/subject/list')
    if (response.code === 1) {
      subjects.value = response.response || []
    }
  } catch (error) {
    console.error('加载学科失败:', error)
  }
}

const loadUserStats = async () => {
  try {
    const response = await get('/api/student/user/stats')
    if (response.code === 1) {
      Object.assign(userStats, response.response)
    }
  } catch (error) {
    userStats.totalQuestions = 156
    userStats.accuracy = 72
    userStats.weakPoints = 8
  }
}

const loadGraph = async () => {
  try {
    const response = await get('/api/student/knowledge-graph', { subjectId: filterSubject.value })
    if (response.code === 1) {
      graphData.nodes = response.response.nodes
      graphData.links = response.response.links
      graphData.categories = response.response.categories
      renderChart()
    }
  } catch (error) {
    console.error('加载知识图谱失败:', error)
    renderMockGraph()
  }
}

const renderMockGraph = () => {
  graphData.nodes = [
    { id: 1, name: '进程', symbolSize: 60, type: 'knowledge_point', category: 0 },
    { id: 2, name: '线程', symbolSize: 50, type: 'knowledge_point', category: 0 },
    { id: 3, name: '调度算法', symbolSize: 55, type: 'knowledge_point', category: 0 },
    { id: 4, name: '内存管理', symbolSize: 65, type: 'knowledge_point', category: 0 },
    { id: 5, name: '分页', symbolSize: 45, type: 'knowledge_point', category: 0 },
    { id: 6, name: '分段', symbolSize: 45, type: 'knowledge_point', category: 0 }
  ]
  graphData.links = [
    { source: 1, target: 2, relation: '包含' },
    { source: 1, target: 3, relation: '需要' },
    { source: 4, target: 5, relation: '实现方式' },
    { source: 4, target: 6, relation: '实现方式' }
  ]
  graphData.categories = [{ name: '操作系统' }]
  renderChart()
}

const initChart = () => {
  if (!chartRef.value) return
  chartInstance.value = echarts.init(chartRef.value)
}

const renderChart = () => {
  if (!chartInstance.value || !graphData.nodes.length) return
  const option = {
    backgroundColor: '#fff',
    tooltip: { trigger: 'item', formatter: (params) => params.name },
    animationDuration: 1000,
    series: [{
      name: '知识图谱',
      type: 'graph',
      layout: 'force',
      data: graphData.nodes.map(node => ({
        name: node.name, id: node.id,
        symbolSize: node.symbolSize || 40,
        itemStyle: { color: node.type === 'subject' ? '#667eea' : '#f59f5f' },
        label: { show: true, position: 'bottom', fontSize: 11 }
      })),
      links: graphData.links.map(link => ({
        source: link.source, target: link.target,
        lineStyle: { color: '#ddd', width: 1 }
      })),
      categories: graphData.categories,
      roam: true, draggable: true,
      force: { repulsion: 300, gravity: 0.1, edgeLength: 80 }
    }]
  }
  chartInstance.value.setOption(option)
}

const sendMessage = async () => {
  if (!inputMessage.value.trim()) return
  
  const userMsg = inputMessage.value.trim()
  messages.value.push({ role: 'user', content: userMsg })
  inputMessage.value = ''
  isTyping.value = true
  
  await nextTick()
  scrollToBottom()
  
  try {
    const response = await post('/api/student/chat', {
      message: userMsg,
      history: messages.value.slice(-10)
    })
    
    if (response.code === 1) {
      messages.value.push({ role: 'assistant', content: response.response })
    } else {
      messages.value.push({ 
        role: 'assistant', 
        content: `我是你的408Master导师！我注意到你在"进程调度"这部分的正确率只有40%，要不要我用**第一性原理**的方式帮你讲透这部分内容？

📊 你的学习数据：
- 总做题数：${userStats.totalQuestions}
- 正确率：${userStats.accuracy}%
- 薄弱知识点：${userStats.weakPoints}个

💡 你可以问我：
- "帮我分析一下这道题"
- "进程调度有哪些算法？"
- "给我生成一些进程调度的练习题"
- "我的薄弱点是什么？"`
      })
    }
  } catch (error) {
    messages.value.push({ 
      role: 'assistant', 
      content: `我是你的408Master导师！我注意到你在"进程调度"这部分的正确率只有40%，要不要我用**第一性原理**的方式帮你讲透这部分内容？

📊 你的学习数据：
- 总做题数：${userStats.totalQuestions}
- 正确率：${userStats.accuracy}%
- 薄弱知识点：${userStats.weakPoints}个

💡 你可以问我：
- "帮我分析一下这道题"
- "进程调度有哪些算法？"
- "给我生成一些进程调度的练习题"
- "我的薄弱点是什么？"`
    })
  } finally {
    isTyping.value = false
    await nextTick()
    scrollToBottom()
  }
}

const scrollToBottom = () => {
  if (messagesRef.value) {
    messagesRef.value.scrollTop = messagesRef.value.scrollHeight
  }
}

const quickAction = (type) => {
  const prompts = {
    analyze: '帮我分析一下这道题应该怎么做',
    practice: '给我生成5道进程调度的练习题',
    review: '帮我回顾一下我的错题',
    suggestion: '根据我的学习数据，给我一些学习建议'
  }
  inputMessage.value = prompts[type]
  sendMessage()
}

const switchStyle = (styleId) => {
  selectedStyle.value = styleId
  const styleNames = { default: '标准解析', feynman: '费曼风格', plato: '柏拉图式', 'first-principles': '第一性原理' }
  inputMessage.value = `请用${styleNames[styleId]}的风格帮我解析题目`
  sendMessage()
}

onMounted(async () => {
  await loadSubjects()
  await loadUserStats()
  initChart()
  await loadGraph()
  
  messages.value.push({
    role: 'assistant',
    content: `你好！我是 **408Master**，你的专属考研408智能导师 🤖

📊 我已经分析了你的学习数据：
- 总做题数：**${userStats.totalQuestions}道**
- 正确率：**${userStats.accuracy}%**
- 需要强化的知识点：**${userStats.weakPoints}个**

🎯 我发现你最近在"**进程调度**"这部分错题较多，需要我帮你重点突破吗？

💡 你可以这样和我交流：
- **题目解析**：把题目发给我，我会用不同风格给你讲解
- **知识讲解**：问我任何408相关的知识点
- **生成练习**：让我给你出针对性的练习题
- **学习建议**：让我分析你的薄弱点并给出建议`
  })
})
</script>

<style lang="scss" scoped>
.master-container { 
  background-color: #f5f7fa; 
  min-height: calc(100vh - 70px); 
  padding: 20px;
}

.master-header {
  display: flex;
  align-items: center;
  gap: 20px;
  padding: 30px 40px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 16px;
  margin-bottom: 20px;
  color: #fff;
  
  .avatar-circle {
    width: 70px;
    height: 70px;
    background: rgba(255,255,255,0.2);
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    .el-icon { font-size: 36px; }
  }
  
  .header-info {
    flex: 1;
    h2 { font-size: 28px; margin: 0 0 5px; font-weight: 700; }
    p { font-size: 14px; margin: 0; opacity: 0.9; }
  }
  
  .header-stats {
    display: flex;
    gap: 30px;
    
    .stat-item {
      text-align: center;
      .stat-value { display: block; font-size: 28px; font-weight: 700; }
      .stat-label { font-size: 13px; opacity: 0.8; }
    }
  }
}

.master-content {
  display: flex;
  gap: 20px;
  height: calc(100vh - 220px);
}

.left-panel {
  width: 280px;
  flex-shrink: 0;
  display: flex;
  flex-direction: column;
  gap: 20px;
  overflow-y: auto;
}

.center-panel {
  flex: 1;
  min-width: 0;
}

.right-panel {
  width: 350px;
  flex-shrink: 0;
}

.card-header {
  display: flex;
  align-items: center;
  font-size: 15px;
  font-weight: 600;
  color: #1f2f3d;
  .el-icon { margin-right: 8px; color: #667eea; font-size: 16px; }
}

.profile-card, .quick-actions, .knowledge-mini, .graph-panel {
  border: none;
  border-radius: 12px;
  
  :deep(.el-card__body) {
    padding: 18px;
  }
}

.profile-content {
  .accuracy-bar {
    margin-bottom: 20px;
    .bar-label { font-size: 13px; color: #666; margin-bottom: 10px; }
  }
  
  .subject-stats {
    .subject-item {
      margin-bottom: 12px;
      &:last-child { margin-bottom: 0; }
      .subject-name {
        display: block;
        font-size: 13px;
        color: #333;
        margin-bottom: 5px;
      }
    }
  }
}

.action-buttons {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 10px;
  
  .action-btn {
    width: 100%;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 5px;
    padding: 12px 8px;
    height: auto;
    font-size: 12px;
    
    .el-icon { font-size: 18px; }
  }
}

.style-buttons {
  display: flex;
  flex-direction: column;
  gap: 8px;

  .style-btn {
    display: flex;
    align-items: center;
    gap: 10px;
    padding: 10px 12px;
    border-radius: 10px;
    cursor: pointer;
    transition: all 0.25s;
    border: 2px solid transparent;
    background: #f8f9fa;

    .style-emoji {
      font-size: 20px;
      width: 32px;
      text-align: center;
      flex-shrink: 0;
    }

    .style-name {
      font-size: 13px;
      font-weight: 600;
      color: #1f2f3d;
      flex-shrink: 0;
    }

    .style-desc {
      font-size: 11px;
      color: #909399;
      margin-left: auto;
    }

    &:hover {
      background: #eef0ff;
      border-color: #c0c8ff;
      transform: translateX(4px);
    }

    &.active {
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      border-color: #667eea;
      box-shadow: 0 4px 15px rgba(102, 126, 234, 0.35);

      .style-name, .style-desc { color: #fff; }
    }
  }
}

.chat-container {
  display: flex;
  flex-direction: column;
  height: 100%;
  background: #fff;
  border-radius: 12px;
  box-shadow: 0 2px 12px rgba(0,0,0,0.08);
  overflow: hidden;
}

.chat-messages {
  flex: 1;
  padding: 20px;
  overflow-y: auto;
  
  .message-item {
    display: flex;
    margin-bottom: 20px;
    gap: 12px;
    
    .message-avatar {
      width: 36px;
      height: 36px;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      flex-shrink: 0;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      color: #fff;
      .el-icon { font-size: 18px; }
    }
    
    .user-avatar {
      background: #f59f5f;
    }
    
    .message-content {
      max-width: 75%;
      padding: 14px 18px;
      border-radius: 12px;
      font-size: 14px;
      line-height: 1.7;
      word-break: break-word;
      
      code {
        background: #f0f0f0;
        padding: 2px 6px;
        border-radius: 3px;
        font-family: monospace;
      }
      
      strong { color: #667eea; }
      h2, h3 { color: #667eea; margin: 10px 0 5px; }
      li { margin-left: 15px; }
    }
    
    &.user-message {
      flex-direction: row-reverse;
      .message-content {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: #fff;
        
        code { background: rgba(255,255,255,0.2); }
        strong { color: #fff; }
      }
    }
    
    &.ai-message {
      .message-content {
        background: #f5f7fa;
        color: #333;
      }
    }
  }
  
  .typing-indicator {
    display: flex;
    gap: 4px;
    padding: 14px 18px;
    
    .typing-dot {
      width: 8px;
      height: 8px;
      background: #667eea;
      border-radius: 50%;
      animation: typing 1.4s infinite ease-in-out;
      
      &:nth-child(2) { animation-delay: 0.2s; }
      &:nth-child(3) { animation-delay: 0.4s; }
    }
  }
}

@keyframes typing {
  0%, 100% { transform: scale(0.5); opacity: 0.5; }
  50% { transform: scale(1); opacity: 1; }
}

.chat-input {
  padding: 15px 20px;
  border-top: 1px solid #eee;
  
  :deep(.el-textarea__inner) {
    resize: none;
    border-radius: 10px;
  }
  
  .input-actions {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-top: 10px;
    
    .tip-text { font-size: 12px; color: #999; }
  }
}

.graph-panel {
  height: 100%;
  display: flex;
  flex-direction: column;
  
  :deep(.el-card__body) {
    flex: 1;
    padding: 0;
    display: flex;
  }
  
  .graph-chart {
    flex: 1;
    min-height: 0;
  }
}

@media screen and (max-width: 1400px) {
  .right-panel { display: none; }
}

@media screen and (max-width: 992px) {
  .master-content { flex-direction: column; height: auto; }
  .left-panel { width: 100%; flex-direction: row; flex-wrap: wrap; }
  .profile-card, .quick-actions, .knowledge-mini { width: calc(33.333% - 15px); }
  .center-panel { min-height: 500px; }
}
</style>
