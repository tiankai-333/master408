<template>
  <div class="app-container">
    <el-form :model="form" ref="formRef" label-width="100px" v-loading="formLoading" :rules="rules">
      <el-form-item label="年级：" prop="level" required>
        <el-select v-model="form.level" placeholder="年级"  @change="levelChange">
          <el-option v-for="item in levelEnum" :key="item.key" :value="item.key" :label="item.value"></el-option>
        </el-select>
      </el-form-item>
      <el-form-item label="学科：" prop="subjectId" required>
        <el-select v-model="form.subjectId" placeholder="学科">
          <el-option v-for="item in subjectFilter" :key="item.id" :value="item.id"
                     :label="item.name+' ( '+item.levelName+' )'"></el-option>
        </el-select>
      </el-form-item>
      <el-form-item label="试卷类型：" prop="paperType" required>
        <el-select v-model="form.paperType" placeholder="试卷类型">
          <el-option v-for="item in paperTypeEnum" :key="item.key" :value="item.key" :label="item.value"></el-option>
        </el-select>
      </el-form-item>
      <el-form-item label="时间限制：" required v-show="form.paperType===4">
        <el-date-picker v-model="form.limitDateTime" value-format="yyyy-MM-dd HH:mm:ss" type="datetimerange"
                        range-separator="至" start-placeholder="开始日期" end-placeholder="结束日期">
        </el-date-picker>
      </el-form-item>
      <el-form-item label="试卷名称："  prop="name" required>
        <el-input v-model="form.name"/>
      </el-form-item>
      <el-form-item :key="index" :label="'标题'+(index+1)+'：'" required v-for="(titleItem,index) in form.titleItems">
        <el-input v-model="titleItem.name" style="width: 80%"/>
        <el-button type="text" class="link-left" style="margin-left: 20px" size="mini" @click="addQuestion(titleItem)">
          添加题目
        </el-button>
        <el-button type="text" class="link-left" size="mini" @click="form.titleItems.splice(index,1)">删除</el-button>
        <el-card class="exampaper-item-box" v-if="titleItem.questionItems.length!==0">
          <el-form-item :key="questionIndex" :label="'题目'+(questionIndex+1)+'：'"
                        v-for="(questionItem,questionIndex) in titleItem.questionItems" style="margin-bottom: 15px">
            <el-row>
              <el-col :span="23">
                <QuestionShow :qType="questionItem.questionType" :question="questionItem"/>
              </el-col>
              <el-col :span="1">
                <el-button type="text" size="mini" @click="titleItem.questionItems.splice(questionIndex,1)">删除
                </el-button>
              </el-col>
            </el-row>
          </el-form-item>
        </el-card>
      </el-form-item>
      <el-form-item label="建议时长：" prop="suggestTime" required>
        <el-input v-model="form.suggestTime" placeholder="分钟"/>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="submitForm">提交</el-button>
        <el-button @click="resetForm">重置</el-button>
        <el-button type="success" @click="addTitle">添加标题</el-button>
      </el-form-item>
    </el-form>
    <el-dialog v-model="questionPage.showDialog"  width="70%">
      <el-form :model="questionPage.queryParam" ref="queryForm" :inline="true">
        <el-form-item label="ID：">
          <el-input v-model="questionPage.queryParam.id"  clearable></el-input>
        </el-form-item>
        <el-form-item label="题型：">
          <el-select v-model="questionPage.queryParam.questionType" clearable>
            <el-option v-for="item in questionTypeEnum" :key="item.key" :value="item.key" :label="item.value"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="queryForm">查询</el-button>
        </el-form-item>
      </el-form>
      <el-table v-loading="questionPage.listLoading" :data="questionPage.tableData"
                @selection-change="handleSelectionChange" border fit highlight-current-row style="width: 100%">
        <el-table-column type="selection" width="35"></el-table-column>
        <el-table-column prop="id" label="Id" width="60px"/>
        <el-table-column prop="questionType" label="题型" :formatter="questionTypeFormatter" width="70px"/>
        <el-table-column prop="shortTitle" label="题干" show-overflow-tooltip/>
      </el-table>
      <pagination v-show="questionPage.total>0" :total="questionPage.total"
                  v-model:page="questionPage.queryParam.pageIndex" v-model:limit="questionPage.queryParam.pageSize"
                  @pagination="search"/>
      <template #footer>
          <el-button @click="questionPage.showDialog = false">取 消</el-button>
          <el-button type="primary" @click="confirmQuestionSelect">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ElMessage } from 'element-plus'
import { reactive, ref, onMounted, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import Pagination from '@/components/Pagination'
import QuestionShow from '../question/components/Show.vue'
import examPaperApi from '@/api/examPaper'
import questionApi from '@/api/question'
import { useEnumItemStore } from '@/stores/enumItem'
import { useExamStore } from '@/stores/exam'
import { useTagsViewStore } from '@/stores/tagsView'

const route = useRoute()
const router = useRouter()
const enumItemStore = useEnumItemStore()
const examStore = useExamStore()
const tagsViewStore = useTagsViewStore()

const form = reactive({
  id: null,
  level: null,
  subjectId: null,
  paperType: 1,
  limitDateTime: [],
  name: '',
  suggestTime: null,
  titleItems: []
})

const subjectFilter = ref(null)
const formLoading = ref(false)
const formRef = ref(null)
const currentTitleItem = ref(null)

const questionPage = reactive({
  multipleSelection: [],
  showDialog: false,
  queryParam: {
    id: null,
    questionType: null,
    subjectId: 1,
    pageIndex: 1,
    pageSize: 5
  },
  listLoading: true,
  tableData: [],
  total: 0
})

const questionTypeEnum = computed(() => [
  { key: 1, value: '单选题' },
  { key: 2, value: '多选题' },
  { key: 3, value: '填空题' },
  { key: 4, value: '判断题' },
  { key: 5, value: '简答题' }
])

const paperTypeEnum = computed(() => [
  { key: 1, value: '练习卷' },
  { key: 2, value: '作业卷' },
  { key: 3, value: '测试卷' },
  { key: 4, value: '考试卷' }
])

const levelEnum = computed(() => enumItemStore.user.levelEnum)

const rules = {
  level: [
    { required: true, message: '请选择年级', trigger: 'change' }
  ],
  subjectId: [
    { required: true, message: '请选择学科', trigger: 'change' }
  ],
  paperType: [
    { required: true, message: '请选择试卷类型', trigger: 'change' }
  ],
  name: [
    { required: true, message: '请输入试卷名称', trigger: 'blur' }
  ],
  suggestTime: [
    { required: true, message: '请输入建议时长', trigger: 'blur' }
  ]
}

const submitForm = () => {
  formRef.value.validate((valid) => {
    if (valid) {
      formLoading.value = true
      examPaperApi.edit(form).then(re => {
        if (re.code === 1) {
          ElMessage.success(re.message)
          tagsViewStore.delVisitedView({ path: route.path }).then(() => {
            router.push('/exam/paper/list')
          })
        } else {
          ElMessage.error(re.message)
          formLoading.value = false
        }
      }).catch(() => {
        formLoading.value = false
      })
    }
  })
}

const addTitle = () => {
  form.titleItems.push({
    name: '',
    questionItems: []
  })
}

const addQuestion = (titleItem) => {
  currentTitleItem.value = titleItem
  questionPage.showDialog = true
  search()
}

const queryForm = () => {
  questionPage.queryParam.pageIndex = 1
  search()
}

const confirmQuestionSelect = () => {
  questionPage.multipleSelection.forEach(q => {
    questionApi.select(q.id).then(re => {
      currentTitleItem.value.questionItems.push(re.response)
    })
  })
  questionPage.showDialog = false
}

const levelChange = () => {
  form.subjectId = null
  subjectFilter.value = examStore.subjects.filter(data => data.level === form.level)
}

const search = () => {
  questionPage.queryParam.subjectId = form.subjectId
  questionPage.listLoading = true
  questionApi.pageList(questionPage.queryParam).then(data => {
    const re = data.response
    questionPage.tableData = re.list
    questionPage.total = re.total
    questionPage.queryParam.pageIndex = re.pageNum
    questionPage.listLoading = false
  })
}

const handleSelectionChange = (val) => {
  questionPage.multipleSelection = val
}

const questionTypeFormatter = (row, column, cellValue) => {
  return enumItemStore.enumFormat(questionTypeEnum.value, cellValue)
}

const resetForm = () => {
  const lastId = form.id
  formRef.value.resetFields()
  Object.assign(form, {
    id: null,
    level: null,
    subjectId: null,
    paperType: 1,
    limitDateTime: [],
    name: '',
    suggestTime: null,
    titleItems: []
  })
  form.id = lastId
}

onMounted(() => {
  const id = route.query.id
  examStore.initSubject(() => {
    subjectFilter.value = examStore.subjects
  })
  if (id && parseInt(id) !== 0) {
    formLoading.value = true
    examPaperApi.select(id).then(re => {
      Object.assign(form, re.response)
      formLoading.value = false
    })
  }
})
</script>

<style lang="scss">
  .exampaper-item-box {
    .q-title {
      margin: 0px 5px 0px 5px;
    }
    .q-item-content {
    }
  }
</style>