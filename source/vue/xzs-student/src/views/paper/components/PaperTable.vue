<template>
  <el-table
    v-loading="loading"
    :data="data"
    fit
    highlight-current-row
    class="paper-table"
    :header-cell-style="{ background: '#f8f9fa', color: '#1f2f3d', fontWeight: '600' }"
  >
    <el-table-column prop="id" label="序号" width="100">
      <template #default="{ $index }">
        <span class="row-index">{{ $index + 1 }}</span>
      </template>
    </el-table-column>
    <el-table-column prop="name" label="试卷名称">
      <template #default="{ row }">
        <div class="paper-name">
          <el-icon><Document /></el-icon>
          <span>{{ row.name }}</span>
        </div>
      </template>
    </el-table-column>
    <el-table-column align="right" width="150">
      <template #default="{ row }">
        <router-link target="_blank" :to="{ path: '/do', query: { id: row.id } }">
          <el-button type="primary" size="small" class="start-btn">
            <el-icon><VideoPlay /></el-icon> 开始答题
          </el-button>
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
    @pagination="$emit('search')"
    class="custom-pagination"
  />
</template>

<script setup>
defineProps({
  data: { type: Array, default: () => [] },
  loading: { type: Boolean, default: false },
  total: { type: Number, default: 0 },
  queryParam: { type: Object, default: () => ({}) }
})

defineEmits(['search'])
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
</style>
