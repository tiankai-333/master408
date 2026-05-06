<template>
  <div class="record-container">
    <div class="record-header">
      <div class="header-icon">
        <i class="el-icon-tickets"></i>
      </div>
      <h2>考试记录</h2>
      <p>查看历史考试记录和成绩分析</p>
    </div>

    <div class="record-content">
      <el-row :gutter="30">
        <el-col :span="16">
          <el-card class="record-table-card" shadow="hover">
            <div slot="header" class="card-header">
              <i class="el-icon-document"></i>
              <span>考试记录列表</span>
            </div>

            <el-table
              v-loading="listLoading"
              :data="tableData"
              fit
              highlight-current-row
              style="width: 100%"
              @row-click="itemSelect"
              class="record-table"
              :header-cell-style="{ background: '#f8f9fa', color: '#1f2f3d', fontWeight: '600' }"
            >
              <el-table-column prop="id" label="序号" width="80">
                <template slot-scope="{row, $index}">
                  <span class="row-index">{{ $index + 1 }}</span>
                </template>
              </el-table-column>
              <el-table-column prop="paperName" label="试卷名称">
                <template slot-scope="{row}">
                  <div class="paper-name">
                    <i class="el-icon-notebook-2"></i>
                    <span>{{ row.paperName }}</span>
                  </div>
                </template>
              </el-table-column>
              <el-table-column prop="subjectName" label="学科" width="100">
                <template slot-scope="{row}">
                  <el-tag type="info" size="small">{{ row.subjectName }}</el-tag>
                </template>
              </el-table-column>
              <el-table-column label="状态" prop="status" width="100">
                <template slot-scope="{row}">
                  <el-tag :type="statusTagFormatter(row.status)" size="small">
                    <i :class="statusIconFormatter(row.status)"></i>
                    {{ statusTextFormatter(row.status) }}
                  </el-tag>
                </template>
              </el-table-column>
              <el-table-column prop="createTime" label="考试时间" width="160" />
              <el-table-column align="right" width="120">
                <template slot-scope="{row}">
                  <router-link target="_blank" :to="{path:'/edit',query:{id:row.id}}" v-if="row.status === 1">
                    <el-button type="warning" size="mini" icon="el-icon-edit" class="action-btn">批改</el-button>
                  </router-link>
                  <router-link target="_blank" :to="{path:'/read',query:{id:row.id}}" v-if="row.status === 2">
                    <el-button type="primary" size="mini" icon="el-icon-view" class="action-btn">查看</el-button>
                  </router-link>
                </template>
              </el-table-column>
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

        <el-col :span="8">
          <el-card class="record-info-card" shadow="hover">
            <div slot="header" class="card-header">
              <i class="el-icon-data-analysis"></i>
              <span>成绩分析</span>
            </div>

            <div class="info-content">
              <div class="info-item">
                <div class="info-label">
                  <i class="el-icon-s-opportunity"></i>
                  系统判分
                </div>
                <div class="info-value">
                  <span class="score">{{ selectItem.systemScore || 0 }}</span>
                  <span class="unit">分</span>
                </div>
              </div>

              <div class="info-item highlight">
                <div class="info-label">
                  <i class="el-icon-s-claim"></i>
                  最终得分
                </div>
                <div class="info-value">
                  <span class="score primary">{{ selectItem.userScore || 0 }}</span>
                  <span class="unit">分</span>
                </div>
              </div>

              <div class="info-item">
                <div class="info-label">
                  <i class="el-icon-s-data"></i>
                  试卷总分
                </div>
                <div class="info-value">
                  <span class="score">{{ selectItem.paperScore || 0 }}</span>
                  <span class="unit">分</span>
                </div>
              </div>

              <div class="divider"></div>

              <div class="info-item">
                <div class="info-label">
                  <i class="el-icon-circle-check"></i>
                  正确题数
                </div>
                <div class="info-value">
                  <span class="score success">{{ selectItem.questionCorrect || 0 }}</span>
                  <span class="unit">题</span>
                </div>
              </div>

              <div class="info-item">
                <div class="info-label">
                  <i class="el-icon-document-copy"></i>
                  总题数
                </div>
                <div class="info-value">
                  <span class="score">{{ selectItem.questionCount || 0 }}</span>
                  <span class="unit">题</span>
                </div>
              </div>

              <div class="info-item">
                <div class="info-label">
                  <i class="el-icon-time"></i>
                  用时
                </div>
                <div class="info-value">
                  <span class="score">{{ selectItem.doTime || '0' }}</span>
                </div>
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
import examPaperAnswerApi from '@/api/examPaperAnswer'
import { scrollTo } from '@/utils/scroll-to'
export default {
  components: { Pagination },
  data () {
    return {
      queryParam: {
        pageIndex: 1,
        pageSize: 10
      },
      listLoading: false,
      tableData: [],
      total: 0,
      selectItem: {
        systemScore: '0',
        userScore: '0',
        doTime: '0',
        paperScore: '0',
        questionCorrect: 0,
        questionCount: 0
      }
    }
  },
  created () {
    this.search()
    scrollTo(0, 800)
  },
  methods: {
    search () {
      this.listLoading = true
      let _this = this
      examPaperAnswerApi.pageList(this.queryParam).then(data => {
        const re = data.response
        _this.tableData = re.list
        _this.total = re.total
        _this.queryParam.pageIndex = re.pageNum
        _this.listLoading = false
      })
    },
    itemSelect (row, column, event) {
      this.selectItem = row
    },
    statusTagFormatter (status) {
      return this.enumFormat(this.statusTag, status)
    },
    statusTextFormatter (status) {
      return this.enumFormat(this.statusEnum, status)
    },
    statusIconFormatter (status) {
      const icons = {
        0: 'el-icon-loading',
        1: 'el-icon-edit-outline',
        2: 'el-icon-circle-check'
      }
      return icons[status] || 'el-icon-document'
    }
  },
  computed: {
    ...mapGetters('enumItem', [
      'enumFormat'
    ]),
    ...mapState('enumItem', {
      statusEnum: state => state.exam.examPaperAnswer.statusEnum,
      statusTag: state => state.exam.examPaperAnswer.statusTag
    })
  }
}
</script>

<style lang="scss" scoped>
.record-container {
  background-color: #f5f7fa;
  min-height: calc(100vh - 70px);
  padding: 30px;
}

.record-header {
  text-align: center;
  margin-bottom: 40px;
  padding: 40px 0;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
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

.record-content {
  max-width: 1400px;
  margin: 0 auto;
}

.record-table-card, .record-info-card {
  border: none;
  border-radius: 16px;
  overflow: hidden;

  .card-header {
    display: flex;
    align-items: center;
    font-size: 18px;
    font-weight: 600;
    color: #1f2f3d;

    i {
      margin-right: 10px;
      color: #667eea;
      font-size: 20px;
    }
  }
}

.record-table {
  ::v-deep .el-table__body {
    tr {
      transition: all 0.3s;
      cursor: pointer;

      &:hover > td {
        background-color: #f8f9fa !important;
      }

      &.current-row > td {
        background-color: rgba(102, 126, 234, 0.1) !important;
      }
    }

    td {
      border-bottom: 1px solid #f0f0f0;
    }
  }

  .row-index {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 28px;
    height: 28px;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: #fff;
    border-radius: 50%;
    font-size: 13px;
    font-weight: 600;
  }

  .paper-name {
    display: flex;
    align-items: center;

    i {
      margin-right: 10px;
      color: #667eea;
      font-size: 18px;
    }

    span {
      color: #1f2f3d;
      font-weight: 500;
    }
  }

  .action-btn {
    border-radius: 16px;
    padding: 6px 12px;

    i {
      margin-right: 4px;
    }
  }
}

.record-info-card {
  .info-content {
    padding: 10px 0;
  }

  .info-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 15px 0;
    border-bottom: 1px solid #f0f0f0;

    &:last-child {
      border-bottom: none;
    }

    &.highlight {
      background: rgba(102, 126, 234, 0.05);
      margin: 0 -20px;
      padding: 20px;
      border-radius: 10px;
      border-bottom: none;
    }
  }

  .info-label {
    display: flex;
    align-items: center;
    color: #606266;
    font-size: 15px;

    i {
      margin-right: 10px;
      color: #667eea;
      font-size: 18px;
    }
  }

  .info-value {
    display: flex;
    align-items: baseline;

    .score {
      font-size: 24px;
      font-weight: 700;
      color: #1f2f3d;

      &.primary {
        color: #667eea;
      }

      &.success {
        color: #67c23a;
      }
    }

    .unit {
      margin-left: 5px;
      color: #909399;
      font-size: 14px;
    }
  }

  .divider {
    height: 1px;
    background: #e8e8e8;
    margin: 15px 0;
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
        color: #667eea;
        border-color: #667eea;
      }
    }

    .el-pager li {
      border-radius: 8px;
      background: #fff;
      border: 1px solid #dcdfe6;
      margin: 0 3px;
      transition: all 0.3s;

      &:hover {
        color: #667eea;
        border-color: #667eea;
      }

      &.active {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: #fff;
        border-color: #667eea;
      }
    }
  }
}

@media screen and (max-width: 992px) {
  .el-col-16, .el-col-8 {
    width: 100%;
  }

  .el-col-8 {
    margin-top: 20px;
  }
}
</style>
