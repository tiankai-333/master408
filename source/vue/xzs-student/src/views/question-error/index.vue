<template>
  <div class="question-error-container">
    <div class="question-error-header">
      <div class="header-icon">
        <i class="el-icon-warning"></i>
      </div>
      <h2>错题本</h2>
      <p>温故而知新，助您巩固知识点</p>
    </div>

    <div class="question-error-content">
      <el-row :gutter="30">
        <el-col :span="14">
          <el-card class="question-list-card" shadow="hover">
            <div slot="header" class="card-header">
              <i class="el-icon-document"></i>
              <span>错题列表</span>
            </div>

            <el-table
              v-loading="listLoading"
              :data="tableData"
              fit
              highlight-current-row
              style="width: 100%"
              @row-click="itemSelect"
              class="question-table"
              :header-cell-style="{ background: '#f8f9fa', color: '#1f2f3d', fontWeight: '600' }"
            >
              <el-table-column prop="shortTitle" label="题干" show-overflow-tooltip>
                <template slot-scope="{row}">
                  <div class="question-title">
                    <i class="el-icon-edit-outline"></i>
                    <span>{{ row.shortTitle }}</span>
                  </div>
                </template>
              </el-table-column>
              <el-table-column prop="questionType" label="题型" :formatter="questionTypeFormatter" width="90">
                <template slot-scope="{row}">
                  <el-tag type="warning" size="small">
                    {{ questionTypeFormatter(row, null, row.questionType, null) }}
                  </el-tag>
                </template>
              </el-table-column>
              <el-table-column prop="subjectName" label="学科" width="80">
                <template slot-scope="{row}">
                  <el-tag type="info" size="small">{{ row.subjectName }}</el-tag>
                </template>
              </el-table-column>
              <el-table-column prop="createTime" label="做题时间" width="160" />
            </el-table>

            <pagination
              v-show="total>0"
              :total="total"
              :background="false"
              :page.sync="queryParam.pageIndex"
              :limit.sync="queryParam.pageSize"
              @pagination="search"
              class="custom-pagination"
            />
          </el-card>
        </el-col>

        <el-col :span="10">
          <el-card class="question-detail-card" shadow="hover">
            <div slot="header" class="card-header">
              <i class="el-icon-view"></i>
              <span>题目详情</span>
              <el-button 
                type="primary" 
                size="small" 
                class="ai-analyze-btn"
                :loading="aiAnalyzing"
                @click="analyzeQuestion"
                :disabled="!selectItem.questionItem"
              >
                <i class="el-icon-brain"></i>
                {{ aiAnalyzing ? 'AI分析中...' : 'AI分析' }}
              </el-button>
            </div>

            <div class="question-answer-wrapper">
              <QuestionAnswerShow
                :qType="selectItem.questionType"
                :qLoading="qAnswerLoading"
                :question="selectItem.questionItem"
                :answer="selectItem.answerItem"
              />
            </div>

            <div v-if="aiAnalysisResult" class="ai-analysis-section">
              <div class="ai-analysis-header">
                <i class="el-icon-document"></i>
                <span>AI解题分析</span>
              </div>
              <div class="ai-analysis-content">
                <div v-if="aiAnalysisResult.isPlainText" class="analysis-item">
                  <div class="analysis-label">解析结果</div>
                  <div class="analysis-value">{{ aiAnalysisResult['解析结果'] }}</div>
                </div>
                <template v-else>
                  <div v-if="aiAnalysisResult['解题思路']" class="analysis-item">
                    <div class="analysis-label">解题思路</div>
                    <div class="analysis-value">{{ aiAnalysisResult['解题思路'] }}</div>
                  </div>
                  <div v-if="aiAnalysisResult['知识点']" class="analysis-item">
                    <div class="analysis-label">知识点</div>
                    <div class="analysis-value">{{ aiAnalysisResult['知识点'] }}</div>
                  </div>
                  <div v-if="aiAnalysisResult['易错点']" class="analysis-item">
                    <div class="analysis-label">易错点</div>
                    <div class="analysis-value">{{ aiAnalysisResult['易错点'] }}</div>
                  </div>
                  <div v-if="aiAnalysisResult['答案解析']" class="analysis-item">
                    <div class="analysis-label">答案解析</div>
                    <div class="analysis-value">{{ aiAnalysisResult['答案解析'] }}</div>
                  </div>
                </template>
              </div>
            </div>
          </el-card>
        </el-col>
      </el-row>
    </div>
  </div>
</template>

<script>
import { mapState, mapGetters } from 'vuex'
import Pagination from '@/components/Pagination'
import questionAnswerApi from '@/api/questionAnswer'
import questionApi from '@/api/question'
import QuestionAnswerShow from '../exam/components/QuestionAnswerShow'

export default {
  components: { Pagination, QuestionAnswerShow },
  data () {
    return {
      queryParam: {
        pageIndex: 1,
        pageSize: 10
      },
      listLoading: false,
      tableData: [],
      total: 0,
      qAnswerLoading: false,
      selectItem: {
        questionType: 0,
        questionItem: null,
        answerItem: null
      },
      aiAnalyzing: false,
      aiAnalysisResult: null
    }
  },
  created () {
    this.search()
  },
  methods: {
    search () {
      this.listLoading = true
      let _this = this
      questionAnswerApi.pageList(this.queryParam).then(data => {
        const re = data.response
        _this.tableData = re.list
        _this.total = re.total
        _this.queryParam.pageIndex = re.pageNum
        _this.listLoading = false
        if (re.list.length !== 0) {
          _this.qAnswerShow(re.list[0].id)
        }
      })
    },
    itemSelect (row, column, event) {
      this.aiAnalysisResult = null
      this.qAnswerShow(row.id)
    },
    qAnswerShow (id) {
      let _this = this
      this.qAnswerLoading = true
      this.aiAnalysisResult = null
      questionAnswerApi.select(id).then(re => {
        let response = re.response
        _this.selectItem.questionType = response.questionVM.questionType
        _this.selectItem.questionItem = response.questionVM
        _this.selectItem.answerItem = response.questionAnswerVM
        _this.qAnswerLoading = false
      })
    },
    analyzeQuestion () {
      if (!this.selectItem.questionItem) {
        this.$message.warning('请先选择一道题目')
        return
      }

      this.aiAnalyzing = true
      this.aiAnalysisResult = null

      const question = this.selectItem.questionItem
      const answer = this.selectItem.answerItem

      let options = ''
      if (question.items && Array.isArray(question.items)) {
        options = question.items.map((item, index) => {
          return String.fromCharCode(65 + index) + '. ' + item.content
        }).join('\n')
      }

      let correctAnswer = ''
      if (answer && answer.correct) {
        correctAnswer = answer.correct
      }

      let questionType = ''
      switch (question.questionType) {
        case 1: questionType = '单选题'; break
        case 2: questionType = '多选题'; break
        case 3: questionType = '判断题'; break
        case 4: questionType = '填空题'; break
        case 5: questionType = '简答题'; break
        default: questionType = '未知'
      }

      questionApi.analyzeQuestion({
        questionType: questionType,
        questionContent: question.content || question.title || '',
        options: options,
        correctAnswer: correctAnswer
      }).then(response => {
        if (response.code === 1 && response.response) {
          console.log('AI返回原始数据:', response.response)
          try {
            this.aiAnalysisResult = JSON.parse(response.response)
            console.log('解析后的结果:', this.aiAnalysisResult)
          } catch (e) {
            console.log('JSON解析失败:', e.message)
            this.aiAnalysisResult = { '解析结果': response.response, 'isPlainText': true }
          }
        } else {
          this.$message.error(response.message || '分析失败')
        }
      }).catch(error => {
        this.$message.error('分析失败：' + (error.message || '网络错误'))
      }).finally(() => {
        this.aiAnalyzing = false
      })
    },
    questionTypeFormatter (row, column, cellValue, index) {
      return this.enumFormat(this.questionTypeEnum, cellValue)
    }
  },
  computed: {
    ...mapGetters('enumItem', ['enumFormat']),
    ...mapState('enumItem', {
      questionTypeEnum: state => state.exam.question.typeEnum
    })
  }
}
</script>

<style lang="scss" scoped>
.question-error-container {
  background-color: #f5f7fa;
  min-height: calc(100vh - 70px);
  padding: 30px;
}

.question-error-header {
  text-align: center;
  margin-bottom: 40px;
  padding: 40px 0;
  background: linear-gradient(135deg, #f59f5f 0%, #ff6b6b 100%);
  border-radius: 16px;
  color: #fff;

  .header-icon {
    width: 80px;
    height: 80px;
    margin: 0 auto 20px;
    background: rgba(255, 255, 255, 0.2);
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;

    i {
      font-size: 36px;
      color: #fff;
    }
  }

  h2 {
    font-size: 32px;
    font-weight: 700;
    margin: 0 0 10px;
  }

  p {
    font-size: 16px;
    opacity: 0.9;
    margin: 0;
  }
}

.question-error-content {
  max-width: 1400px;
  margin: 0 auto;
}

.question-list-card, .question-detail-card {
  border: none;
  border-radius: 16px;
  overflow: hidden;
  height: 100%;

  .card-header {
    display: flex;
    align-items: center;
    font-size: 18px;
    font-weight: 600;
    color: #1f2f3d;

    i {
      margin-right: 10px;
      color: #f59f5f;
      font-size: 20px;
    }

    .ai-analyze-btn {
      margin-left: auto;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      border: none;
      border-radius: 20px;

      &:hover {
        opacity: 0.9;
        transform: translateY(-2px);
      }

      i {
        margin-right: 5px;
        color: #fff;
        font-size: 14px;
      }
    }
  }
}

.question-list-card {
  .question-table {
    ::v-deep .el-table__body {
      tr {
        transition: all 0.3s;
        cursor: pointer;

        &:hover > td {
          background-color: #f8f9fa !important;
        }

        &.current-row > td {
          background-color: rgba(245, 159, 95, 0.1) !important;
        }
      }

      td {
        border-bottom: 1px solid #f0f0f0;
      }
    }

    .question-title {
      display: flex;
      align-items: center;

      i {
        margin-right: 10px;
        color: #f59f5f;
        font-size: 18px;
      }

      span {
        color: #1f2f3d;
        font-weight: 500;
      }
    }
  }

  .question-answer-wrapper {
    padding: 20px;
  }
}

.custom-pagination {
  margin-top: 30px;
  padding: 20px 0;
  text-align: center;

  ::v-deep .el-pagination {
    display: inline-flex;
    gap: 10px;

    .btn-prev, .btn-next {
      border-radius: 8px;
      background: #fff;
      border: 1px solid #dcdfe6;
      transition: all 0.3s;

      &:hover {
        color: #f59f5f;
        border-color: #f59f5f;
      }
    }

    .el-pager li {
      border-radius: 8px;
      background: #fff;
      border: 1px solid #dcdfe6;
      margin: 0 3px;
      transition: all 0.3s;

      &:hover {
        color: #f59f5f;
        border-color: #f59f5f;
      }

      &.active {
        background: linear-gradient(135deg, #f59f5f 0%, #ff6b6b 100%);
        color: #fff;
        border-color: #f59f5f;
      }
    }
  }
}

@media screen and (max-width: 992px) {
  .el-col-14, .el-col-10 {
    width: 100%;
  }

  .el-col-10 {
    margin-top: 20px;
  }
}

.ai-analysis-section {
  margin-top: 20px;
  padding-top: 20px;
  border-top: 2px dashed #e8e8e8;

  .ai-analysis-header {
    display: flex;
    align-items: center;
    margin-bottom: 15px;
    padding: 10px 15px;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    border-radius: 8px;
    color: #fff;
    font-weight: 600;

    i {
      margin-right: 8px;
      font-size: 18px;
    }
  }

  .ai-analysis-content {
    padding: 0 5px;

    .analysis-item {
      margin-bottom: 15px;

      &:last-child {
        margin-bottom: 0;
      }
    }

    .analysis-label {
      font-size: 14px;
      font-weight: 600;
      color: #667eea;
      margin-bottom: 5px;
      display: flex;
      align-items: center;

      &::before {
        content: '•';
        margin-right: 5px;
        font-size: 18px;
      }
    }

    .analysis-value {
      font-size: 14px;
      color: #333;
      line-height: 1.6;
      padding-left: 15px;
    }
  }
}
</style>
