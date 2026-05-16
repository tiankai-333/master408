<template>
  <div class="app-container">
    <el-form :model="queryParam" ref="queryForm" :inline="true">
      <el-form-item label="操作人：">
        <el-input v-model="queryParam.userName" clearable></el-input>
      </el-form-item>
      <el-form-item label="操作类型：">
        <el-input v-model="queryParam.operation" clearable></el-input>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="submitForm">查询</el-button>
      </el-form-item>
    </el-form>
    <el-table v-loading="listLoading" :data="tableData" border fit highlight-current-row style="width: 100%">
      <el-table-column prop="id" label="Id" width="80px"/>
      <el-table-column prop="userName" label="操作人" width="120px"/>
      <el-table-column prop="operation" label="操作类型" width="150px"/>
      <el-table-column prop="method" label="请求方式" width="100px"/>
      <el-table-column prop="requestUri" label="请求路径"/>
      <el-table-column prop="ip" label="IP" width="120px"/>
      <el-table-column prop="createTime" label="操作时间" width="160px"/>
    </el-table>
    <pagination v-show="total>0" :total="total" v-model:page="queryParam.pageIndex" v-model:limit="queryParam.pageSize"
                @pagination="search"/>
  </div>
</template>

<script setup>
import { reactive, ref, onMounted } from 'vue'
import Pagination from '@/components/Pagination'
import logApi from '@/api/log'

const queryParam = reactive({
  userName: null,
  operation: null,
  pageIndex: 1,
  pageSize: 10
})

const listLoading = ref(true)
const tableData = ref([])
const total = ref(0)

const search = () => {
  listLoading.value = true
  logApi.pageList(queryParam).then(data => {
    const re = data.response
    tableData.value = re.list
    total.value = re.total
    queryParam.pageIndex = re.pageNum
    listLoading.value = false
  })
}

const submitForm = () => {
  queryParam.pageIndex = 1
  search()
}

onMounted(() => {
  search()
})
</script>