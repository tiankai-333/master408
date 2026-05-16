<template>
  <div class="app-container">
    <el-form :model="queryParam" ref="queryForm" :inline="true">
      <el-form-item label="学科名称：">
        <el-input v-model="queryParam.name" clearable></el-input>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="submitForm">查询</el-button>
        <router-link :to="{path:'/education/subject/edit'}" class="link-left">
          <el-button type="primary">添加</el-button>
        </router-link>
      </el-form-item>
    </el-form>
    <el-table v-loading="listLoading" :data="tableData" border fit highlight-current-row style="width: 100%">
      <el-table-column prop="id" label="Id" width="80px"/>
      <el-table-column prop="name" label="学科名称"/>
      <el-table-column prop="sort" label="排序" width="80px"/>
      <el-table-column prop="createTime" label="创建时间" width="160px"/>
      <el-table-column label="操作" align="center" width="200px">
        <template #default="{row}">
          <el-button size="mini" @click="router.push({path:'/education/subject/edit',query:{id:row.id}})">编辑</el-button>
          <el-button size="mini" type="danger" @click="deleteSubject(row)" class="link-left">删除</el-button>
        </template>
      </el-table-column>
    </el-table>
    <pagination v-show="total>0" :total="total" v-model:page="queryParam.pageIndex" v-model:limit="queryParam.pageSize"
                @pagination="search"/>
  </div>
</template>

<script setup>
import { ElMessage } from 'element-plus'
import { reactive, ref, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import Pagination from '@/components/Pagination'
import subjectApi from '@/api/subject'
import { useEnumItemStore } from '@/stores/enumItem'

const router = useRouter()
const enumItemStore = useEnumItemStore()

const queryParam = reactive({
  name: null,
  pageIndex: 1,
  pageSize: 10
})

const listLoading = ref(true)
const tableData = ref([])
const total = ref(0)
const search = () => {
  listLoading.value = true
  subjectApi.pageList(queryParam).then(data => {
    const re = data.response
    tableData.value = re.list
    total.value = re.total
    queryParam.pageIndex = re.pageNum
    listLoading.value = false
  })
}

const deleteSubject = (row) => {
  subjectApi.deleteSubject(row.id).then(re => {
    if (re.code === 1) {
      search()
      ElMessage.success(re.message)
    } else {
      ElMessage.error(re.message)
    }
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