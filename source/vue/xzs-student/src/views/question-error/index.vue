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
            <el-table v-loading="listLoading" :data="tableData" fit highlight-current-row style="width: 100%" @row-click="itemSelect" class="question-table"
              :header-cell-style="{ background: '#f8f9fa', color: '#1f2f3d', fontWeight: '600' }">
              <el-table-column prop="shortTitle" label="题干" show-overflow-tooltip>
                <template #default="{ row }">
                  <div class="question-title"><el-icon><Edit /></el-icon><span>{{ row.shortTitle }}</span></div>
                </template>
              </el-table-column>
              <el-table-column prop="questionType" label="题型" width="90">
                <template #default="{ row }">
                  <el-tag type="warning" size="small">{{ questionTypeFormatter(row.questionType) }}</el-tag>
                </template>
              </el-table-column>
              <el-table-column prop="subjectName" label="学科" width="80">
                <template #default="{ row }">
                  <el-tag type="info" size="small">{{ row.subjectName }}</el-tag>
                </template>
              </el-table-column>
              <el-table-column prop="createTime" label="做题时间" width="160" />
            </el-table>
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

const analyzeQuestion = () => {
  if (!selectItem.value.questionItem) {
    ElMessage.warning('请先选择一道题目')
    return
  }
  aiAnalyzing.value = true
  aiAnalysisResult.value = null
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
  questionApi.analyzeQuestion({ questionType, questionContent: titleContent, options, correctAnswer, style: selectedStyle.value }).then(response => {
    if (response.code === 1 && response.response) {
      aiAnalysisResult.value = {
        content: response.response,
        isMarkdown: true,
        styleName: aiStyles.value.find(s => s.id === selectedStyle.value)?.name
      }
    } else {
      ElMessage.error(response.message || '分析失败')
    }
  }).catch(error => {
    ElMessage.error('分析失败：' + (error.message || '网络错误'))
  }).finally(() => {
    aiAnalyzing.value = false
  })
}

const formatMarkdown = (text) => {
  if (!text) return ''
  let formatted = text
    .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
    .replace(/\*(.*?)\*/g, '<em>$1</em>')
    .replace(/`(.*?)`/g, '<code>$1</code>')
    .replace(/\n/g, '<br>')
    .replace(/^###\s(.*)/gm, '<h3>$1</h3>')
    .replace(/^##\s(.*)/gm, '<h2>$1</h2>')
    .replace(/^#\s(.*)/gm, '<h1>$1</h1>')
    .replace(/^\*\s(.*)/gm, '<li>$1</li>')
    .replace(/^(\d+)\.\s(.*)/gm, '<li>$2</li>')
  return formatted
}

onMounted(() => {
  search()
})
</script>

<style lang="scss" scoped>
.question-error-container { background-color: #f5f7fa; min-height: calc(100vh - 70px); padding: 30px; }
.question-error-header {
  text-align: center; margin-bottom: 40px; padding: 40px 0;
  background: linear-gradient(135deg, #f59f5f 0%, #ff6b6b 100%); border-radius: 16px; color: #fff;
  .header-icon { width: 80px; height: 80px; margin: 0 auto 20px; background: rgba(255,255,255,0.2); border-radius: 50%; display: flex; align-items: center; justify-content: center;
    .el-icon { font-size: 36px; color: #fff; }
  }
  h2 { font-size: 32px; font-weight: 700; margin: 0 0 10px; }
  p { font-size: 16px; opacity: 0.9; margin: 0; }
}
.question-error-content { max-width: 1400px; margin: 0 auto; }
.question-list-card, .question-detail-card { border: none; border-radius: 16px; overflow: hidden; height: 100%;
  .card-header { display: flex; align-items: center; font-size: 18px; font-weight: 600; color: #1f2f3d;
    .el-icon { margin-right: 10px; color: #f59f5f; font-size: 20px; }
    .ai-analyze-wrapper { margin-left: auto; display: flex; align-items: center; gap: 10px; }
    .style-select { width: 160px; }
    .ai-analyze-btn { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); border: none; border-radius: 20px;
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
.custom-pagination { margin-top: 30px; padding: 20px 0; text-align: center;
  :deep(.el-pagination) { display: inline-flex; gap: 10px;
    .btn-prev, .btn-next { border-radius: 8px; background: #fff; border: 1px solid #dcdfe6; transition: all 0.3s;
      &:hover { color: #f59f5f; border-color: #f59f5f; }
    }
    .el-pager li { border-radius: 8px; background: #fff; border: 1px solid #dcdfe6; margin: 0 3px; transition: all 0.3s;
      &:hover { color: #f59f5f; border-color: #f59f5f; }
      &.active { background: linear-gradient(135deg, #f59f5f 0%, #ff6b6b 100%); color: #fff; border-color: #f59f5f; }
    }
  }
}
.ai-analysis-section { margin-top: 20px; padding-top: 20px; border-top: 2px dashed #e8e8e8;
  .ai-analysis-header { display: flex; align-items: center; margin-bottom: 15px; padding: 10px 15px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); border-radius: 8px; color: #fff; font-weight: 600;
    .el-icon { margin-right: 8px; font-size: 18px; }
  }
  .ai-analysis-content { padding: 0 5px;
    .analysis-item { margin-bottom: 15px; &:last-child { margin-bottom: 0; } }
    .analysis-label { font-size: 14px; font-weight: 600; color: #667eea; margin-bottom: 5px; display: flex; align-items: center;
      &::before { content: '•'; margin-right: 5px; font-size: 18px; }
    }
    .analysis-value { font-size: 14px; color: #333; line-height: 1.6; padding-left: 15px; }
    .markdown-content { font-size: 14px; color: #333; line-height: 1.8;
      h1, h2, h3 { color: #667eea; margin: 15px 0 10px; font-weight: 600; }
      h1 { font-size: 20px; }
      h2 { font-size: 17px; }
      h3 { font-size: 15px; }
      li { margin-left: 20px; list-style: disc; }
      code { background: #f0f0f0; padding: 2px 6px; border-radius: 3px; font-family: monospace; }
      strong { color: #667eea; font-weight: 600; }
      em { color: #764ba2; font-style: italic; }
    }
  }
}
@media screen and (max-width: 992px) {
  .el-col-14, .el-col-10 { width: 100%; }
  .el-col-10 { margin-top: 20px; }
}
</style>
