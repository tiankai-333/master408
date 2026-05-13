<template>
  <div class="app-container">
    <el-form :model="form" ref="formRef" label-width="100px" v-loading="formLoading" :rules="rules">
      <el-form-item label="年级：" prop="level" required>
        <el-select v-model="form.level" placeholder="年级" @change="levelChange">
          <el-option v-for="item in levelEnum" :key="item.key" :value="item.key" :label="item.value"></el-option>
        </el-select>
      </el-form-item>
      <el-form-item label="学科：" prop="subjectId" required>
        <el-select v-model="form.subjectId" placeholder="学科">
          <el-option v-for="item in subjectFilter" :key="item.id" :value="item.id"
                     :label="item.name+' ( '+item.levelName+' )'"></el-option>
        </el-select>
      </el-form-item>
      <el-form-item label="任务名称：" prop="name" required>
        <el-input v-model="form.name"/>
      </el-form-item>
      <el-form-item label="开始时间：" prop="startTime" required>
        <el-date-picker v-model="form.startTime" value-format="yyyy-MM-dd HH:mm:ss" type="datetime"
                        placeholder="选择开始时间">
        </el-date-picker>
      </el-form-item>
      <el-form-item label="结束时间：" prop="endTime" required>
        <el-date-picker v-model="form.endTime" value-format="yyyy-MM-dd HH:mm:ss" type="datetime"
                        placeholder="选择结束时间">
        </el-date-picker>
      </el-form-item>
      <el-form-item label="试卷：" prop="paperId" required>
        <el-select v-model="form.paperId" placeholder="试卷">
          <el-option v-for="item in paperList" :key="item.id" :value="item.id" :label="item.name"></el-option>
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="submitForm">提交</el-button>
        <el-button @click="resetForm">重置</el-button>
      </el-form-item>
    </el-form>
  </div>
</template>

<script setup>
import { ElMessage } from 'element-plus'
import { reactive, ref, onMounted, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import taskApi from '@/api/task'
import examPaperApi from '@/api/examPaper'
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
  name: '',
  startTime: '',
  endTime: '',
  paperId: null
})

const subjectFilter = ref(null)
const formLoading = ref(false)
const formRef = ref(null)
const paperList = ref([])

const levelEnum = computed(() => enumItemStore.user.levelEnum)

const rules = {
  level: [
    { required: true, message: '请选择年级', trigger: 'change' }
  ],
  subjectId: [
    { required: true, message: '请选择学科', trigger: 'change' }
  ],
  name: [
    { required: true, message: '请输入任务名称', trigger: 'blur' }
  ],
  startTime: [
    { required: true, message: '请选择开始时间', trigger: 'change' }
  ],
  endTime: [
    { required: true, message: '请选择结束时间', trigger: 'change' }
  ],
  paperId: [
    { required: true, message: '请选择试卷', trigger: 'change' }
  ]
}

const submitForm = () => {
  formRef.value.validate((valid) => {
    if (valid) {
      formLoading.value = true
      taskApi.edit(form).then(re => {
        if (re.code === 1) {
          ElMessage.success(re.message)
          tagsViewStore.delVisitedView({ path: route.path }).then(() => {
            router.push('/task/list')
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

const levelChange = () => {
  form.subjectId = null
  subjectFilter.value = examStore.subjects.filter(data => data.level === form.level)
}

const loadPaperList = () => {
  examPaperApi.list({ subjectId: form.subjectId }).then(data => {
    paperList.value = data.response
  })
}

const resetForm = () => {
  const lastId = form.id
  formRef.value.resetFields()
  Object.assign(form, {
    id: null,
    level: null,
    subjectId: null,
    name: '',
    startTime: '',
    endTime: '',
    paperId: null
  })
  form.id = lastId
}

onMounted(() => {
  examStore.initSubject(() => {
    subjectFilter.value = examStore.subjects
  })
  
  const id = route.query.id
  if (id && parseInt(id) !== 0) {
    formLoading.value = true
    taskApi.select(id).then(re => {
      Object.assign(form, re.response)
      loadPaperList()
      formLoading.value = false
    })
  }
})
</script>