<template>
  <div class="app-container">
    <el-form :model="queryParam" ref="queryForm" :inline="true">
      <el-form-item label="题目ID：">
        <el-input v-model="queryParam.id" clearable></el-input>
      </el-form-item>
      <el-form-item label="题目内容：">
        <el-input v-model="queryParam.content" clearable></el-input>
      </el-form-item>

      <el-form-item label="学科：">
        <el-select v-model="queryParam.subjectId" clearable>
          <el-option v-for="item in subjectFilter" :key="item.id" :value="item.id"
                     :label="item.name+' ( '+item.levelName+' )'"></el-option>
        </el-select>
      </el-form-item>
      <el-form-item label="题型：">
        <el-select v-model="queryParam.questionType" clearable>
          <el-option v-for="item in questionType" :key="item.key" :value="item.key" :label="item.value"></el-option>
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="submitForm">查询</el-button>
        <el-popover placement="bottom" trigger="click">
          <template #default>
            <el-button type="warning" size="mini" v-for="item in editUrlEnum" :key="item.key"
                       @click="router.push({path:item.value})">{{item.name}}
            </el-button>
          </template>
          <template #reference>
            <el-button type="primary" class="link-left">添加</el-button>
          </template>
        </el-popover>
      </el-form-item>
    </el-form>
    <el-table v-loading="listLoading" :data="tableData" border fit highlight-current-row style="width: 100%">
      <el-table-column prop="id" label="Id" width="90px"/>
      <el-table-column prop="subjectId" label="学科" :formatter="subjectFormatter" width="120px"/>
      <el-table-column prop="questionType" label="题型" :formatter="questionTypeFormatter" width="70px"/>
      <el-table-column prop="shortTitle" label="题干" show-overflow-tooltip/>
      <el-table-column prop="score" label="分数" width="60px"/>
      <el-table-column prop="difficult" label="难度" width="60px"/>
      <el-table-column prop="createTime" label="创建时间" width="160px"/>
      <el-table-column label="操作" align="center" width="220px">
        <template #default="{row}">
          <el-button size="mini"   @click="showQuestion(row)">预览</el-button>
          <el-button size="mini"  @click="editQuestion(row)">编辑</el-button>
          <el-button size="mini"  type="danger" @click="deleteQuestion(row)" class="link-left">删除</el-button>
        </template>
      </el-table-column>
    </el-table>
    <pagination v-show="total>0" :total="total" v-model:page="queryParam.pageIndex" v-model:limit="queryParam.pageSize"
                @pagination="search"/>
    <el-dialog v-model="questionShow.dialog" style="width: 100%;height: 100%">
      <QuestionShow :qType="questionShow.qType" :question="questionShow.question" :qLoading="questionShow.loading"/>
    </el-dialog>
  </div>
</template>

<script setup>
import { ElMessage } from 'element-plus'
import { reactive, ref, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import Pagination from '@/components/Pagination'
import QuestionShow from './components/Show.vue'
import questionApi from '@/api/question'
import { useEnumItemStore } from '@/stores/enumItem'
import { useExamStore } from '@/stores/exam'

const router = useRouter()
const enumItemStore = useEnumItemStore()
const examStore = useExamStore()

const queryParam = reactive({
  id: null,
  questionType: null,
  subjectId: null,
  pageIndex: 1,
  pageSize: 10
})

const subjectFilter = ref(null)
const listLoading = ref(true)
const tableData = ref([])
const total = ref(0)

const questionShow = reactive({
  qType: 0,
  dialog: false,
  question: null,
  loading: false
})

const questionType = computed(() => [
  { key: 1, value: '单选题' },
  { key: 2, value: '多选题' },
  { key: 3, value: '填空题' },
  { key: 4, value: '判断题' },
  { key: 5, value: '简答题' }
])

const editUrlEnum = computed(() => [
  { key: 1, name: '单选题', value: '/exam/question/edit/single-choice' },
  { key: 2, name: '多选题', value: '/exam/question/edit/multiple-choice' },
  { key: 3, name: '填空题', value: '/exam/question/edit/gap-filling' },
  { key: 4, name: '判断题', value: '/exam/question/edit/true-false' },
  { key: 5, name: '简答题', value: '/exam/question/edit/short-answer' }
])
const search = () => {
  listLoading.value = true
  questionApi.pageList(queryParam).then(data => {
    const re = data.response
    tableData.value = re.list
    total.value = re.total
    queryParam.pageIndex = re.pageNum
    listLoading.value = false
  })
}



const showQuestion = (row) => {
  questionShow.dialog = true
  questionShow.loading = true
  questionApi.select(row.id).then(re => {
    questionShow.qType = re.response.questionType
    questionShow.question = re.response
    questionShow.loading = false
  })
}

const editQuestion = (row) => {
  const url = enumItemStore.enumFormat(editUrlEnum.value, row.questionType)
  router.push({ path: url, query: { id: row.id } })
}

const deleteQuestion = (row) => {
  questionApi.deleteQuestion(row.id).then(re => {
    if (re.code === 1) {
      search()
      ElMessage.success(re.message)
    } else {
      ElMessage.error(re.message)
    }
  })
}

const questionTypeFormatter = (row, column, cellValue) => {
  return enumItemStore.enumFormat(questionType.value, cellValue)
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