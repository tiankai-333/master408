<template>
  <div class="paper-container">
    <div class="paper-header">
      <div class="header-icon">
        <el-icon><Document /></el-icon>
      </div>
      <h2>试卷中心</h2>
      <p>选择科目和试卷类型，开始答题</p>
    </div>

    <div class="paper-content">
      <el-tabs tab-position="left" v-model="tabId" @tab-click="tabChange" class="subject-tabs">
        <el-tab-pane label="408综合" :name="'0'" key="0">
          <div class="tab-content">
            <paper-table :data="tableData" :loading="listLoading" :total="total" :query-param="queryParam" @search="search" />
          </div>
        </el-tab-pane>
        <el-tab-pane v-for="item in subjectList" :label="item.name" :key="item.id" :name="String(item.id)">
          <div class="tab-content">
            <paper-table :data="tableData" :loading="listLoading" :total="total" :query-param="queryParam" @search="search" />
          </div>
        </el-tab-pane>
      </el-tabs>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import examPaperApi from '@/api/examPaper'
import subjectApi from '@/api/subject'
import PaperTable from './components/PaperTable.vue'

const tabId = ref('0')
const listLoading = ref(true)
const subjectList = ref([])
const tableData = ref([])
const total = ref(0)

const queryParam = reactive({
  paperType: 1,
  subjectId: null,
  pageIndex: 1,
  pageSize: 20
})

const search = () => {
  listLoading.value = true
  examPaperApi.pageList(queryParam).then(data => {
    const re = data.response
    tableData.value = re.list
    total.value = re.total
    queryParam.pageIndex = re.pageNum
    listLoading.value = false
  })
}

const tabChange = () => {
  const id = Number(tabId.value)
  queryParam.subjectId = id === 0 ? null : id
  queryParam.pageIndex = 1
  search()
}

onMounted(() => {
  subjectApi.list().then(re => {
    subjectList.value = re.response || []
    search()
  })
})
</script>

<style lang="scss" scoped>
.paper-container {
  background: linear-gradient(180deg, #f7fbff 0%, #eef4f8 100%);
  min-height: calc(100vh - 70px);
  padding: 22px;
}

.paper-header {
  max-width: 1500px;
  margin: 0 auto 18px;
  padding: 24px 28px;
  background: linear-gradient(135deg, #13233f, #2554bc);
  border-radius: 24px;
  color: #fff;
  text-align: left;

  .header-icon {
    width: 54px;
    height: 54px;
    margin: 0 0 14px;
    background: rgba(255, 255, 255, 0.2);
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;

    .el-icon {
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

.paper-content {
  max-width: 1500px;
  margin: 0 auto;
  background: #fff;
  border: 1px solid #e2e8f0;
  border-radius: 20px;
  padding: 22px;
  box-shadow: 0 16px 44px rgba(15, 23, 42, 0.08);
}

.subject-tabs {
  :deep(.el-tabs__header) {
    background: #f8f9fa;
    border-radius: 12px;
    padding: 15px 0;
    margin-right: 30px;
  }

  :deep(.el-tabs__item) {
    height: 50px;
    line-height: 50px;
    font-size: 15px;
      color: #606266;
    padding: 0 30px;
    transition: all 0.3s;
    &:hover {
      color: #667eea;
    }
    &.is-active {
      color: #1d4ed8;
      background: #eff6ff;
      font-weight: 600;
    }
  }

  :deep(.el-tabs__nav-wrap::after) {
    display: none;
  }

  :deep(.el-tabs__content) {
    padding: 0;
  }
}

.tab-content {
  padding: 0 10px;
}

.paper-table {
  border-radius: 10px;
  overflow: hidden;

  :deep(.el-table__body) {
    tr {
      transition: all 0.3s;

      &:hover > td {
        background-color: #f8f9fa !important;
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

    .el-icon {
      margin-right: 10px;
      color: #667eea;
      font-size: 18px;
    }

    span {
      color: #1f2f3d;
      font-weight: 500;
    }
  }

  .start-btn {
    border-radius: 20px;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    border: none;
    padding: 8px 20px;
    font-size: 13px;

    .el-icon {
      margin-right: 5px;
    }

    &:hover {
      opacity: 0.9;
      transform: translateY(-1px);
    }
  }
}

.custom-pagination {
  margin-top: 30px;
  padding: 20px 0;
  text-align: center;

  :deep(.el-pagination) {
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

@media screen and (max-width: 768px) {
  .paper-container {
    padding: 15px;
  }

  .paper-header {
    padding: 30px 20px;

    h2 {
      font-size: 24px;
    }
  }

  .paper-content {
    padding: 15px;
  }
}
</style>
