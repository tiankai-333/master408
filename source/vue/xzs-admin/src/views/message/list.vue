<template>
  <div class="app-container">
    <el-form :model="queryParam" ref="queryForm" :inline="true">
      <el-form-item label="标题：">
        <el-input v-model="queryParam.title" clearable></el-input>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="submitForm">查询</el-button>
        <router-link :to="{path:'/message/send'}" class="link-left">
          <el-button type="primary">发送消息</el-button>
        </router-link>
      </el-form-item>
    </el-form>
    <el-table v-loading="listLoading" :data="tableData" border fit highlight-current-row style="width: 100%">
      <el-table-column prop="id" label="Id" width="80px"/>
      <el-table-column prop="title" label="标题"/>
      <el-table-column prop="sendTime" label="发送时间" width="160px"/>
      <el-table-column label="操作" align="center" width="160px">
        <template #default="{row}">
          <el-button size="mini" @click="showDetail(row)">详情</el-button>
        </template>
      </el-table-column>
    </el-table>
    <pagination v-show="total>0" :total="total" v-model:page="queryParam.pageIndex" v-model:limit="queryParam.pageSize"
                @pagination="search"/>
    <el-dialog v-model="detailDialog.show" title="消息详情">
      <div v-loading="detailDialog.loading">
        <h3>{{ detailDialog.data.title }}</h3>
        <div v-html="detailDialog.data.content"></div>
      </div>
    </el-dialog>
  </div>
</template>

<script setup>
import { reactive, ref, onMounted } from 'vue'
import Pagination from '@/components/Pagination'
import messageApi from '@/api/message'

const queryParam = reactive({
  title: null,
  pageIndex: 1,
  pageSize: 10
})

const listLoading = ref(true)
const tableData = ref([])
const total = ref(0)

const detailDialog = reactive({
  show: false,
  loading: false,
  data: {
    title: '',
    content: ''
  }
})

const search = () => {
  listLoading.value = true
  messageApi.pageList(queryParam).then(data => {
    const re = data.response
    tableData.value = re.list
    total.value = re.total
    queryParam.pageIndex = re.pageNum
    listLoading.value = false
  })
}

const showDetail = (row) => {
  detailDialog.show = true
  detailDialog.loading = true
  messageApi.select(row.id).then(re => {
    detailDialog.data = re.response
    detailDialog.loading = false
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