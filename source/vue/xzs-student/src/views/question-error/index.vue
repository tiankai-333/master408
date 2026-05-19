<template>
  <div class="question-error-container">
    <div class="question-error-header">
      <div class="header-icon"><el-icon><WarningFilled /></el-icon></div>
      <h2>错题本</h2>
      <p>温故而知新，助您巩固知识点</p>
    </div>
    <div class="question-error-content">
      <el-row :gutter="30">
        <el-col :span="14">
          <el-card class="question-list-card" shadow="hover">
            <template #header>
              <div class="card-header"><el-icon><Document /></el-icon><span>错题列表</span></div>
            </template>
            <div class="mobile-table-scroll">
              <el-table v-loading="listLoading" :data="tableData" fit highlight-current-row style="width: 100%" @row-click="itemSelect" class="question-table"
                :header-cell-style="{ background: '#f8f9fa', color: '#1f2f3d', fontWeight: '600' }">
                <el-table-column prop="shortTitle" label="题干" min-width="220" show-overflow-tooltip>
                  <template #default="{ row }">
                    <div class="question-title"><el-icon><Edit /></el-icon><span>{{ row.shortTitle }}</span></div>
                  </template>
                </el-table-column>
                <el-table-column prop="questionType" label="题型" width="88">
                  <template #default="{ row }">
                    <el-tag type="warning" size="small">{{ questionTypeFormatter(row.questionType) }}</el-tag>
                  </template>
                </el-table-column>
                <el-table-column prop="subjectName" label="学科" width="78">
                  <template #default="{ row }">
                    <el-tag type="info" size="small">{{ row.subjectName }}</el-tag>
                  </template>
                </el-table-column>
                <el-table-column prop="createTime" label="做题时间" width="150" />
              </el-table>
            </div>
            <pagination v-show="total > 0" :total="total" :background="false" v-model:page="queryParam.pageIndex"
              :limit="queryParam.pageSize" @pagination="search" class="custom-pagination" />
          </el-card>
        </el-col>
        <el-col :span="10">
          <el-card class="question-detail-card" shadow="hover">
            <template #header>
              <div class="card-header">
                <el-icon><View /></el-icon><span>题目详情</span>
                <div class="ai-analyze-wrapper">
                  <el-select v-model="selectedStyle" size="small" class="style-select" placeholder="选择解析风格">
                    <el-option
                      v-for="style in aiStyles"
                      :key="style.id"
                      :label="style.name"
                      :value="style.id">
                      <span style="float: left">{{ style.name }}</span>
                      <span style="float: right; color: #8492a6; font-size: 12px">{{ style.description }}</span>
                    </el-option>
                  </el-select>
                  <el-button type="primary" size="small" class="ai-analyze-btn" :loading="aiAnalyzing" @click="analyzeQuestion" :disabled="!selectItem.questionItem">
                    <el-icon><MagicStick /></el-icon> {{ aiAnalyzing ? 'AI分析中...' : 'AI分析' }}
                  </el-button>
                </div>
              </div>
            </template>
            <div class="question-answer-wrapper">
              <QuestionAnswerShow :qType="selectItem.questionType" :qLoading="qAnswerLoading" :question="selectItem.questionItem" :answer="selectItem.answerItem" />
            </div>
            <div v-if="aiAnalysisResult" class="ai-analysis-section">
              <div class="ai-analysis-header">
                <el-icon><Document /></el-icon><span>AI解题分析</span>
                <el-tag size="small" type="success" style="margin-left: 10px;">{{ aiAnalysisResult.styleName }}</el-tag>
              </div>
              <div class="ai-analysis-content">
                <div v-if="aiAnalysisResult.isMarkdown" class="markdown-content" v-html="formatMarkdown(aiAnalysisResult.content)"></div>
              </div>
            </div>
          </el-card>
        </el-col>
      </el-row>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { WarningFilled, Document, Edit, View, MagicStick } from '@element-plus/icons-vue'
import { useEnumItemStore } from '@/store/modules/enumItem'
import Pagination from '@/components/Pagination/index.vue'
import questionAnswerApi from '@/api/questionAnswer'
import questionApi from '@/api/question'
import QuestionAnswerShow from '../exam/components/QuestionAnswerShow.vue'

const enumItemStore = useEnumItemStore()
const questionTypeEnum = enumItemStore.exam.question.typeEnum

const queryParam = reactive({ pageIndex: 1, pageSize: 10 })
const listLoading = ref(false)
const tableData = ref([])
const total = ref(0)
const qAnswerLoading = ref(false)
const selectItem = ref({ questionType: 0, questionItem: null, answerItem: null })
const aiAnalyzing = ref(false)
const aiAnalysisResult = ref(null)
const selectedStyle = ref('default')

const aiStyles = ref([
  { id: 'default', name: '📚 标准解析', description: '老师讲课式' },
  { id: 'feynman', name: '🎓 费曼风格', description: '小白讲故事' },
  { id: 'plato', name: '❓ 柏拉图式', description: '自问自答式' },
  { id: 'first-principles', name: '⚡ 第一性原理', description: '拆解到本质' }
])

const questionTypeFormatter = (cellValue) => enumItemStore.enumFormat(questionTypeEnum, cellValue)

const search = () => {
  listLoading.value = true
  questionAnswerApi.pageList(queryParam).then(data => {
    const re = data.response
    tableData.value = re.list
    total.value = re.total
    queryParam.pageIndex = re.pageNum
    listLoading.value = false
    if (re.list.length !== 0) {
      qAnswerShow(re.list[0].id)
    }
  })
}

const itemSelect = (row) => {
  aiAnalysisResult.value = null
  qAnswerShow(row.id)
}

const qAnswerShow = (id) => {
  qAnswerLoading.value = true
  aiAnalysisResult.value = null
  questionAnswerApi.select(id).then(re => {
    const response = re.response
    selectItem.value.questionType = response.questionVM.questionType
    selectItem.value.questionItem = response.questionVM
    selectItem.value.answerItem = response.questionAnswerVM
    qAnswerLoading.value = false
  })
}

const analyzeQuestion = async () => {
  if (!selectItem.value.questionItem) {
    ElMessage.warning('请先选择一道题目')
    return
  }
  aiAnalyzing.value = true
  aiAnalysisResult.value = {
    content: '',
    isMarkdown: true,
    styleName: aiStyles.value.find(s => s.id === selectedStyle.value)?.name
  }
  const question = selectItem.value.questionItem
  const answer = selectItem.value.answerItem
  let options = ''
  if (question.items && Array.isArray(question.items)) {
    options = question.items.map(item => (item.prefix ? item.prefix + '. ' : '') + item.content).join('\n')
  }
  let correctAnswer = question.correct || (answer && answer.correct ? answer.correct : '')
  let questionType = ''
  switch (question.questionType) {
    case 1: questionType = '单选题'; break
    case 2: questionType = '多选题'; break
    case 3: questionType = '判断题'; break
    case 4: questionType = '填空题'; break
    case 5: questionType = '简答题'; break
    default: questionType = '未知'
  }
  const titleContent = question.title || question.titleContent || question.content || ''
  const payload = { questionType, questionContent: titleContent, options, correctAnswer, style: selectedStyle.value }
  try {
    let received = ''
    await questionApi.analyzeQuestionStream(payload, {
      onStatus: (status) => {
        if (!received) updateAnalysisContent(status)
      },
      onChunk: (chunk) => {
        if (!received) updateAnalysisContent('')
        received += chunk
        updateAnalysisContent(received)
      },
      onError: (message) => {
        throw new Error(message || '分析失败')
      }
    })
    if (!received.trim()) {
      throw new Error('AI返回内容为空')
    }
  } catch (streamError) {
    try {
      const response = await questionApi.analyzeQuestion(payload)
      if (response.code === 1 && response.response) {
        aiAnalysisResult.value = {
          content: response.response,
          isMarkdown: true,
          styleName: aiStyles.value.find(s => s.id === selectedStyle.value)?.name
        }
      } else {
        ElMessage.error(response.message || '分析失败')
      }
    } catch (error) {
      ElMessage.error('分析失败：' + (error.message || streamError.message || '网络错误'))
    }
  } finally {
    aiAnalyzing.value = false
  }
}

const updateAnalysisContent = (content) => {
  aiAnalysisResult.value = {
    ...(aiAnalysisResult.value || {}),
    content,
    isMarkdown: true,
    styleName: aiStyles.value.find(s => s.id === selectedStyle.value)?.name
  }
}

const formatMarkdown = (text) => {
  if (!text) return ''
  return renderMarkdown(String(text))
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
    .replace(/\[([^\]]+)\]\((https?:\/\/[^)\s]+)\)/g, '<a href="$2" target="_blank" rel="noopener noreferrer">$1</a>')
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

    if (/^---+$/.test(trimmed)) {
      closeList()
      html.push('<hr>')
      return
    }

    const heading = trimmed.match(/^(#{1,4})\s+(.+)$/)
    if (heading) {
      closeList()
      const level = Math.min(heading[1].length + 1, 4)
      html.push(`<h${level}>${renderInlineMarkdown(heading[2])}</h${level}>`)
      return
    }

    const quote = trimmed.match(/^>\s+(.+)$/)
    if (quote) {
      closeList()
      html.push(`<blockquote>${renderInlineMarkdown(quote[1])}</blockquote>`)
      return
    }

    const listItem = trimmed.match(/^[-*]\s+(.+)$/)
    if (listItem) {
      openList('ul')
      html.push(`<li>${renderInlineMarkdown(listItem[1])}</li>`)
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

onMounted(() => {
  search()
})
</script>

<style lang="scss" scoped>
.question-error-container { background: linear-gradient(180deg, #f7fbff 0%, #eef4f8 100%); min-height: calc(100vh - 70px); padding: 22px; }
.question-error-header {
  max-width: 1500px; margin: 0 auto 18px; padding: 24px 28px;
  background: linear-gradient(135deg, #13233f, #2554bc); border-radius: 24px; color: #fff; text-align: left;
  .header-icon { width: 54px; height: 54px; margin: 0 0 14px; background: rgba(255,255,255,0.2); border-radius: 50%; display: flex; align-items: center; justify-content: center;
    .el-icon { font-size: 36px; color: #fff; }
  }
  h2 { font-size: 32px; font-weight: 700; margin: 0 0 10px; }
  p { font-size: 16px; opacity: 0.9; margin: 0; }
}
.question-error-content { max-width: 1500px; margin: 0 auto; }
.question-list-card, .question-detail-card { border: 1px solid #e2e8f0; border-radius: 20px; overflow: hidden; height: 100%; box-shadow: 0 16px 44px rgba(15, 23, 42, 0.08);
  .card-header { display: flex; align-items: center; font-size: 18px; font-weight: 600; color: #1f2f3d;
    .el-icon { margin-right: 10px; color: #2563eb; font-size: 20px; }
    .ai-analyze-wrapper { margin-left: auto; display: flex; align-items: center; gap: 10px; }
    .style-select { width: 160px; }
    .ai-analyze-btn { background: linear-gradient(135deg, #2563eb, #7c3aed); border: none; border-radius: 20px;
      &:hover { opacity: 0.9; transform: translateY(-2px); }
      .el-icon { margin-right: 5px; color: #fff; font-size: 14px; }
    }
  }
}
.question-list-card {
  .question-table {
    :deep(.el-table__body) { tr { transition: all 0.3s; cursor: pointer;
        &:hover > td { background-color: #f8f9fa !important; }
        &.current-row > td { background-color: rgba(245, 159, 95, 0.1) !important; }
      }
      td { border-bottom: 1px solid #f0f0f0; }
    }
    .question-title { display: flex; align-items: center;
      .el-icon { margin-right: 10px; color: #f59f5f; font-size: 18px; }
      span { color: #1f2f3d; font-weight: 500; }
    }
  }
  .question-answer-wrapper { padding: 20px; }
}
.mobile-table-scroll { width: 100%; overflow-x: auto; -webkit-overflow-scrolling: touch; }
.custom-pagination { margin-top: 30px; padding: 20px 0; text-align: center;
  :deep(.el-pagination) { display: inline-flex; gap: 10px;
    .btn-prev, .btn-next { border-radius: 8px; background: #fff; border: 1px solid #dcdfe6; transition: all 0.3s;
      &:hover { color: #f59f5f; border-color: #f59f5f; }
    }
    .el-pager li { border-radius: 8px; background: #fff; border: 1px solid #dcdfe6; margin: 0 3px; transition: all 0.3s;
      &:hover { color: #f59f5f; border-color: #f59f5f; }
      &.active { background: linear-gradient(135deg, #2563eb, #7c3aed); color: #fff; border-color: #2563eb; }
    }
  }
}
.ai-analysis-section { margin-top: 20px; padding-top: 20px; border-top: 2px dashed #e8e8e8;
  .ai-analysis-header { display: flex; align-items: center; margin-bottom: 15px; padding: 10px 15px; background: linear-gradient(135deg, #2563eb, #7c3aed); border-radius: 8px; color: #fff; font-weight: 600;
    .el-icon { margin-right: 8px; font-size: 18px; }
  }
  .ai-analysis-content { padding: 0 5px;
    .analysis-item { margin-bottom: 15px; &:last-child { margin-bottom: 0; } }
    .analysis-label { font-size: 14px; font-weight: 600; color: #667eea; margin-bottom: 5px; display: flex; align-items: center;
      &::before { content: '•'; margin-right: 5px; font-size: 18px; }
    }
    .analysis-value { font-size: 14px; color: #333; line-height: 1.6; padding-left: 15px; }
    .markdown-content { font-size: 14px; color: #333; line-height: 1.8;
      :deep(h1), :deep(h2), :deep(h3), :deep(h4) { color: #475569; margin: 16px 0 8px; font-weight: 700; line-height: 1.35; }
      :deep(h1) { font-size: 21px; }
      :deep(h2) { font-size: 18px; }
      :deep(h3) { font-size: 16px; }
      :deep(h4) { font-size: 15px; }
      :deep(h1:first-child), :deep(h2:first-child), :deep(h3:first-child), :deep(p:first-child) { margin-top: 0; }
      :deep(p) { margin: 8px 0; }
      :deep(ul), :deep(ol) { margin: 8px 0; padding-left: 22px; }
      :deep(li) { margin: 5px 0; }
      :deep(hr) { height: 1px; margin: 16px 0; border: 0; background: #e2e8f0; }
      :deep(blockquote) { margin: 10px 0; padding: 8px 12px; border-left: 3px solid #7c3aed; background: #f8fafc; color: #475569; }
      :deep(pre) { overflow-x: auto; margin: 10px 0; padding: 12px; border-radius: 10px; background: #0f172a; color: #e2e8f0; }
      :deep(code) { background: #f1f5f9; padding: 2px 6px; border-radius: 4px; font-family: monospace; color: #334155; }
      :deep(pre code) { background: transparent; padding: 0; color: inherit; }
      :deep(strong) { color: #334155; font-weight: 700; }
      :deep(em) { color: #7c3aed; font-style: italic; }
      :deep(a) { color: #2563eb; text-decoration: none; border-bottom: 1px solid rgba(37, 99, 235, 0.35); }
    }
  }
}
@media screen and (max-width: 992px) {
  .el-col-14, .el-col-10 { width: 100%; }
  .el-col-10 { margin-top: 20px; }
}
@media screen and (max-width: 768px) {
  .question-error-container { padding: 12px; }
  .question-error-header { padding: 20px; border-radius: 18px;
    h2 { font-size: 24px; }
  }
  .question-table { min-width: 536px; }
  .question-list-card, .question-detail-card {
    .card-header {
      flex-wrap: wrap;
      gap: 10px;
      .ai-analyze-wrapper {
        flex: 0 0 100%;
        margin-left: 0;
        align-items: stretch;
      }
      .style-select { width: 100%; }
      .ai-analyze-btn { width: 100%; }
    }
  }
  .question-list-card .question-table .question-title {
    align-items: flex-start;
    span { white-space: normal; overflow-wrap: anywhere; line-height: 1.45; }
  }
  .question-answer-wrapper { overflow-x: auto; }
  .custom-pagination {
    margin-top: 18px;
    padding: 12px 0 0;
    overflow-x: auto;
    :deep(.el-pagination) { justify-content: flex-start; gap: 4px; min-width: max-content; }
  }
}
</style>
