<template>
  <div class="mobile-table-scroll">
    <el-table
      v-loading="loading"
      :data="data"
      fit
      highlight-current-row
      class="paper-table"
      :header-cell-style="{ background: '#f8f9fa', color: '#1f2f3d', fontWeight: '600' }"
    >
      <el-table-column prop="id" label="序号" width="76">
        <template #default="{ $index }">
          <span class="row-index">{{ rowIndex($index) }}</span>
        </template>
      </el-table-column>
      <el-table-column prop="name" label="试卷名称" min-width="220">
        <template #default="{ row }">
          <div class="paper-name">
            <el-icon><Document /></el-icon>
            <span>{{ row.name }}</span>
          </div>
        </template>
      </el-table-column>
      <el-table-column align="right" width="160">
        <template #default="{ row }">
          <a class="start-btn" :href="examHref(row)" @click.stop>
            <el-icon><VideoPlay /></el-icon> 开始答题
          </a>
        </template>
      </el-table-column>
    </el-table>
  </div>

  <pagination
    v-show="total > 0"
    :total="total"
    :background="false"
    v-model:page="queryParam.pageIndex"
    v-model:limit="queryParam.pageSize"
    :page-sizes="[20, 50, 100]"
    layout="total, sizes, prev, pager, next, jumper"
    @pagination="$emit('search')"
    class="custom-pagination"
  />

  <div v-if="data.length > 0" class="simple-page-actions">
    <el-button :disabled="currentPage <= 1 || loading" @click="changePage(currentPage - 1)">
      上一页
    </el-button>
    <span class="page-status">
      第 {{ currentPage }} 页<span v-if="totalPages"> / 共 {{ totalPages }} 页</span>
    </span>
    <el-button :type="canGoNext && !loading ? 'primary' : 'default'" :disabled="!canGoNext || loading" @click="changePage(currentPage + 1)">
      下一页
    </el-button>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useRouter } from 'vue-router'

const props = defineProps({
  data: { type: Array, default: () => [] },
  loading: { type: Boolean, default: false },
  total: { type: Number, default: 0 },
  queryParam: { type: Object, default: () => ({}) }
})

const emit = defineEmits(['search'])

const router = useRouter()

const currentPage = computed(() => Number(props.queryParam.pageIndex || 1))
const currentPageSize = computed(() => Number(props.queryParam.pageSize || 20))
const totalPages = computed(() => {
  const totalCount = Number(props.total || 0)
  if (!totalCount) return 0
  return Math.max(1, Math.ceil(totalCount / currentPageSize.value))
})
const canGoNext = computed(() => {
  return totalPages.value > 0 && currentPage.value < totalPages.value
})

const rowIndex = (index) => {
  return (currentPage.value - 1) * currentPageSize.value + index + 1
}

const examHref = (row) => {
  if (!row?.id) return '#'
  return router.resolve({ path: '/do', query: { id: row.id } }).href
}

const changePage = (page) => {
  if (page < 1 || props.loading) return
  props.queryParam.pageIndex = page
  emit('search')
}
</script>

<style lang="scss" scoped>
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
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 110px;
    min-height: 28px;
    box-sizing: border-box;
    border-radius: 20px;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    border: none;
    padding: 8px 20px;
    color: #fff;
    font-size: 13px;
    line-height: 1;
    text-decoration: none;
    white-space: nowrap;
    .el-icon {
      margin-right: 5px;
    }
    &:hover {
      opacity: 0.9;
      transform: translateY(-1px);
    }
  }
}

.mobile-table-scroll {
  width: 100%;
  overflow-x: auto;
  -webkit-overflow-scrolling: touch;
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

.simple-page-actions {
  position: sticky;
  bottom: 0;
  z-index: 2;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 14px;
  margin-top: 18px;
  padding: 16px 12px 8px;
  background: linear-gradient(180deg, rgba(255, 255, 255, 0.72), #fff 42%);
}

.page-status {
  min-width: 96px;
  color: #475569;
  font-size: 14px;
  text-align: center;
}

.simple-page-actions :deep(.el-button--primary) {
  border: none;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: #fff;
}

@media screen and (max-width: 768px) {
  .paper-table {
    min-width: 430px;
  }

  .paper-table .paper-name {
    align-items: flex-start;

    span {
      white-space: normal;
      overflow-wrap: anywhere;
      line-height: 1.45;
    }
  }

  .custom-pagination {
    margin-top: 18px;
    padding: 12px 0 0;
    overflow-x: auto;

    :deep(.el-pagination) {
      justify-content: flex-start;
      gap: 4px;
      min-width: max-content;
    }
  }
}
</style>
