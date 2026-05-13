<template>
  <div class="app-container">
    <el-form :model="queryParam" ref="queryForm" :inline="true">
      <el-form-item label="题目ID：">
        <el-input v-model="queryParam.id" clearable></el-input>
      </el-form-item>
      <el-form-item label="年级：">
        <el-select v-model="queryParam.level" placeholder="年级" @change="levelChange" clearable>
          <el-option v-for="item in levelEnum" :key="item.key" :value="item.key" :label="item.value"></el-option>
        </el-select>
      </el-form-item>
      <el-form-item label="学科：" >
        <el-select v-model="queryParam.subjectId"  clearable>
          <el-option v-for="item in subjectFilter" :key="item.id" :value="item.id" :label="item.name+' ( '+item.levelName+' )'"></el-option>
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="submitForm">查询</el-button>
        <router-link :to="{path:'/exam/paper/edit'}" class="link-left">
          <el-button type="primary">添加</el-button>
        </router-link>
      </el-form-item>
    </el-form>
    <el-table v-loading="listLoading" :data="tableData" border fit highlight-current-row style="width: 100%">
      <el-table-column prop="id" label="Id" width="90px"/>
      <el-table-column prop="subjectId" label="学科" :formatter="subjectFormatter" width="120px" />
      <el-table-column prop="name" label="名称"  />
      <el-table-column prop="createTime" label="创建时间" width="160px"/>
      <el-table-column  label="操作" align="center"  width="160px">
        <template #default="{row}">
          <el-button size="mini" @click="router.push({path:'/exam/paper/edit',query:{id:row.id}})" >编辑</el-button>
          <el-button size="mini" type="danger"  @click="deletePaper(row)" class="link-left">删除</el-button>
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
import examPaperApi from '@/api/examPaper'
import { useEnumItemStore } from '@/stores/enumItem'
import { useExamStore } from '@/stores/exam'

const router = useRouter()
const enumItemStore = useEnumItemStore()
const examStore = useExamStore()

const queryParam = reactive({
  id: null,
  level: null,
  subjectId: null,
  pageIndex: 1,
  pageSize: 10
})

const subjectFilter = ref(null)
const listLoading = ref(true)
const tableData = ref([])
const total = ref(0)

const levelEnum = computed(() => enumItemStore.user.levelEnum)

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

const deletePaper = (row) => {
  examPaperApi.deletePaper(row.id).then(re => {
    if (re.code === 1) {
      search()
      ElMessage.success(re.message)
    } else {
      ElMessage.error(re.message)
    }
  })
}

const levelChange = () => {
  queryParam.subjectId = null
  subjectFilter.value = examStore.subjects.filter(data => data.level === queryParam.level)
}

const subjectFormatter = (row, column, cellValue) => {
  return examStore.subjectEnumFormat(cellValue)
}

const submitForm = () => {
  queryParam.pageIndex = 1
  search()
}

onMounted(() => {
  examStore.initSubject()
  subjectFilter.value = examStore.subjects
  search()
})
</script>