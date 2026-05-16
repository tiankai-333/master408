<template>
  <div class="app-container">
    <el-form :model="queryParam" ref="queryForm" :inline="true">
      <el-form-item label="学生姓名：">
        <el-input v-model="queryParam.studentName" clearable></el-input>
      </el-form-item>
      <el-form-item label="试卷名称：">
        <el-input v-model="queryParam.paperName" clearable></el-input>
      </el-form-item>
      <el-form-item label="状态：">
        <el-select v-model="queryParam.status" clearable>
          <el-option v-for="item in statusEnum" :key="item.key" :value="item.key" :label="item.value"></el-option>
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="submitForm">查询</el-button>
      </el-form-item>
    </el-form>
    <el-table v-loading="listLoading" :data="tableData" border fit highlight-current-row style="width: 100%">
      <el-table-column prop="id" label="Id" width="80px"/>
      <el-table-column prop="studentName" label="学生姓名" width="120px"/>
      <el-table-column prop="paperName" label="试卷名称"/>
      <el-table-column prop="subjectName" label="学科" width="100px"/>
      <el-table-column prop="score" label="得分" width="80px"/>
      <el-table-column prop="totalScore" label="总分" width="80px"/>
      <el-table-column prop="status" label="状态" :formatter="statusFormatter" width="100px"/>
      <el-table-column prop="submitTime" label="提交时间" width="160px"/>
      <el-table-column label="操作" align="center" width="160px">
        <template #default="{row}">
          <el-button size="mini" @click="router.push({path:'/answer/detail',query:{id:row.id}})">详情</el-button>
        </template>
      </el-table-column>
    </el-table>
    <pagination v-show="total>0" :total="total" v-model:page="queryParam.pageIndex" v-model:limit="queryParam.pageSize"
                @pagination="search"/>
  </div>
</template>

<script setup>
import { reactive, ref, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import Pagination from '@/components/Pagination'
import answerApi from '@/api/examPaperAnwser'
import { useEnumItemStore } from '@/stores/enumItem'

const router = useRouter()
const enumItemStore = useEnumItemStore()

const queryParam = reactive({
  studentName: null,
  paperName: null,
  status: null,
  pageIndex: 1,
  pageSize: 10
})

const listLoading = ref(true)
const tableData = ref([])
const total = ref(0)

const statusEnum = computed(() => [
  { key: 1, value: '待批改' },
  { key: 2, value: '已批改' },
  { key: 3, value: '已完成' }
])

const search = () => {
  listLoading.value = true
  answerApi.pageList(queryParam).then(data => {
    const re = data.response
    tableData.value = re.list
    total.value = re.total
    queryParam.pageIndex = re.pageNum
    listLoading.value = false
  })
}

const statusFormatter = (row, column, cellValue) => {
  return enumItemStore.enumFormat(statusEnum.value, cellValue)
}

const submitForm = () => {
  queryParam.pageIndex = 1
  search()
}

onMounted(() => {
  search()
})
</script>