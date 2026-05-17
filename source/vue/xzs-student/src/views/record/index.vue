<template>
  <div class="record-container">
    <div class="record-header">
      <div class="header-icon">
        <el-icon><Tickets /></el-icon>
      </div>
      <h2>考试记录</h2>
      <p>查看历史考试记录和成绩分析</p>
    </div>

    <div class="record-content">
      <el-row :gutter="30">
        <el-col :span="16">
          <el-card class="record-table-card" shadow="hover">
            <template #header>
              <div class="card-header">
                <el-icon><Document /></el-icon>
                <span>考试记录列表</span>
              </div>
            </template>

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
                <template #default="{ $index }">
                  <span class="row-index">{{ $index + 1 }}</span>
                </template>
              </el-table-column>
              <el-table-column prop="paperName" label="试卷名称">
                <template #default="{ row }">
                  <div class="paper-name">
                    <el-icon><Notebook /></el-icon>
                    <span>{{ row.paperName }}</span>
                  </div>
                </template>
              </el-table-column>
              <el-table-column prop="subjectName" label="学科" width="100">
                <template #default="{ row }">
                  <el-tag type="info" size="small">{{ row.subjectName }}</el-tag>
                </template>
              </el-table-column>
              <el-table-column label="状态" prop="status" width="100">
                <template #default="{ row }">
                  <el-tag :type="statusTagFormatter(row.status)" size="small">
                    {{ statusTextFormatter(row.status) }}
                  </el-tag>
                </template>
              </el-table-column>
              <el-table-column prop="createTime" label="考试时间" width="160" />
              <el-table-column align="right" width="120">
                <template #default="{ row }">
                  <router-link target="_blank" :to="{ path: '/edit', query: { id: row.id } }" v-if="row.status === 1">
                    <el-button type="warning" size="small" class="action-btn">批改</el-button>
                  </router-link>
                  <router-link target="_blank" :to="{ path: '/read', query: { id: row.id } }" v-if="row.status === 2">
                    <el-button type="primary" size="small" class="action-btn">查看</el-button>
                  </router-link>
                </template>
              </el-table-column>
            </el-table>

            <pagination
              v-show="total > 0"
              :total="total"
              :background="false"
              v-model:page="queryParam.pageIndex"
              :limit="queryParam.pageSize"
              @pagination="search"
              class="custom-pagination"
            />
          </el-card>
        </el-col>

        <el-col :span="8">
          <el-card class="record-info-card" shadow="hover">
            <template #header>
              <div class="card-header">
                <el-icon><DataAnalysis /></el-icon>
                <span>成绩分析</span>
              </div>
            </template>

            <div class="info-content">
              <div class="info-item">
                <div class="info-label"><el-icon><Opportunity /></el-icon> 系统判分</div>
                <div class="info-value"><span class="score">{{ selectItem.systemScore || 0 }}</span><span class="unit">分</span></div>
              </div>
              <div class="info-item highlight">
                <div class="info-label"><el-icon><Stamp /></el-icon> 最终得分</div>
                <div class="info-value"><span class="score primary">{{ selectItem.userScore || 0 }}</span><span class="unit">分</span></div>
              </div>
              <div class="info-item">
                <div class="info-label"><el-icon><TrendCharts /></el-icon> 试卷总分</div>
                <div class="info-value"><span class="score">{{ selectItem.paperScore || 0 }}</span><span class="unit">分</span></div>
              </div>
              <div class="divider"></div>
              <div class="info-item">
                <div class="info-label"><el-icon><CircleCheck /></el-icon> 正确题数</div>
                <div class="info-value"><span class="score success">{{ selectItem.questionCorrect || 0 }}</span><span class="unit">题</span></div>
              </div>
              <div class="info-item">
                <div class="info-label"><el-icon><Document /></el-icon> 总题数</div>
                <div class="info-value"><span class="score">{{ selectItem.questionCount || 0 }}</span><span class="unit">题</span></div>
              </div>
              <div class="info-item">
                <div class="info-label"><el-icon><Timer /></el-icon> 用时</div>
                <div class="info-value"><span class="score">{{ selectItem.doTime || '0' }}</span></div>
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
import { useEnumItemStore } from '@/store/modules/enumItem'
import Pagination from '@/components/Pagination/index.vue'
import examPaperAnswerApi from '@/api/examPaperAnswer'
import { scrollTo } from '@/utils/scroll-to'
import { Tickets, Document, Notebook, DataAnalysis, Opportunity, Stamp, TrendCharts, CircleCheck, Timer } from '@element-plus/icons-vue'

const enumItemStore = useEnumItemStore()

const queryParam = reactive({ pageIndex: 1, pageSize: 10 })
const listLoading = ref(false)
const tableData = ref([])
const total = ref(0)
const selectItem = ref({
  systemScore: '0', userScore: '0', doTime: '0',
  paperScore: '0', questionCorrect: 0, questionCount: 0
})

const statusTagFormatter = (status) => enumItemStore.enumFormat(enumItemStore.exam.examPaperAnswer.statusTag, status)
const statusTextFormatter = (status) => enumItemStore.enumFormat(enumItemStore.exam.examPaperAnswer.statusEnum, status)

const search = () => {
  listLoading.value = true
  examPaperAnswerApi.pageList(queryParam).then(data => {
    const re = data.response
    tableData.value = re.list
    total.value = re.total
    queryParam.pageIndex = re.pageNum
    listLoading.value = false
  })
}

const itemSelect = (row) => {
  selectItem.value = row
}

onMounted(() => {
  search()
  scrollTo(0, 800)
})
</script>

<style lang="scss" scoped>
.record-container {
  background: linear-gradient(180deg, #f7fbff 0%, #eef4f8 100%);
  min-height: calc(100vh - 70px);
  padding: 22px;
}

.record-header {
  max-width: 1500px;
  margin: 0 auto 18px;
  padding: 24px 28px;
  background: linear-gradient(135deg, #13233f, #2554bc);
  border-radius: 24px;
  color: #fff;
  text-align: left;

  .header-icon {
    width: 54px; height: 54px; margin: 0 0 14px;
    background: rgba(255, 255, 255, 0.2); border-radius: 50%;
    display: flex; align-items: center; justify-content: center;
    .el-icon { font-size: 36px; color: #fff; }
  }
  h2 { font-size: 32px; font-weight: 700; margin: 0 0 10px; }
  p { font-size: 16px; opacity: 0.9; margin: 0; }
}

.record-content { max-width: 1500px; margin: 0 auto; }

.record-table-card, .record-info-card {
  border: 1px solid #e2e8f0; border-radius: 20px; overflow: hidden;
  box-shadow: 0 16px 44px rgba(15, 23, 42, 0.08);
  .card-header {
    display: flex; align-items: center; font-size: 18px; font-weight: 600; color: #1f2f3d;
    .el-icon { margin-right: 10px; color: #2563eb; font-size: 20px; }
  }
}

.record-table {
  :deep(.el-table__body) {
    tr { transition: all 0.3s; cursor: pointer;
      &:hover > td { background-color: #f8f9fa !important; }
      &.current-row > td { background-color: rgba(102, 126, 234, 0.1) !important; }
    }
    td { border-bottom: 1px solid #f0f0f0; }
  }
  .row-index {
    display: inline-flex; align-items: center; justify-content: center;
    width: 28px; height: 28px; background: linear-gradient(135deg, #2563eb, #7c3aed);
    color: #fff; border-radius: 50%; font-size: 13px; font-weight: 600;
  }
  .paper-name {
    display: flex; align-items: center;
    .el-icon { margin-right: 10px; color: #2563eb; font-size: 18px; }
    span { color: #1f2f3d; font-weight: 500; }
  }
  .action-btn { border-radius: 16px; padding: 6px 12px; }
}

.record-info-card {
  .info-content { padding: 10px 0; }
  .info-item {
    display: flex; justify-content: space-between; align-items: center;
    padding: 15px 0; border-bottom: 1px solid #f0f0f0;
    &:last-child { border-bottom: none; }
    &.highlight {
      background: rgba(102, 126, 234, 0.05); margin: 0 -20px; padding: 20px;
      border-radius: 10px; border-bottom: none;
    }
  }
  .info-label {
    display: flex; align-items: center; color: #606266; font-size: 15px;
    .el-icon { margin-right: 10px; color: #2563eb; font-size: 18px; }
  }
  .info-value {
    display: flex; align-items: baseline;
    .score { font-size: 24px; font-weight: 700; color: #1f2f3d;
      &.primary { color: #2563eb; }
      &.success { color: #67c23a; }
    }
    .unit { margin-left: 5px; color: #909399; font-size: 14px; }
  }
  .divider { height: 1px; background: #e8e8e8; margin: 15px 0; }
}

.custom-pagination {
  margin-top: 30px; padding: 20px 0; text-align: center;
  :deep(.el-pagination) {
    display: inline-flex; gap: 10px;
    .btn-prev, .btn-next { border-radius: 8px; background: #fff; border: 1px solid #dcdfe6; transition: all 0.3s;
      &:hover { color: #667eea; border-color: #667eea; }
    }
    .el-pager li { border-radius: 8px; background: #fff; border: 1px solid #dcdfe6; margin: 0 3px; transition: all 0.3s;
      &:hover { color: #2563eb; border-color: #2563eb; }
      &.active { background: linear-gradient(135deg, #2563eb, #7c3aed); color: #fff; border-color: #2563eb; }
    }
  }
}

@media screen and (max-width: 992px) {
  .el-col-16, .el-col-8 { width: 100%; }
  .el-col-8 { margin-top: 20px; }
}
</style>
