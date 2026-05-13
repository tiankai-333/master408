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
      <el-form-item label="难度：" prop="difficult" required>
        <el-select v-model="form.difficult" placeholder="难度">
          <el-option v-for="item in difficultEnum" :key="item.key" :value="item.key" :label="item.value"></el-option>
        </el-select>
      </el-form-item>
      <el-form-item label="分数：" prop="score" required>
        <el-input v-model.number="form.score" type="number"/>
      </el-form-item>
      <el-form-item label="题干：" prop="title" required>
        <el-input v-model="form.title" type="textarea" :rows="3"/>
      </el-form-item>
      <el-form-item label="正确答案：" prop="items" required>
        <el-radio-group v-model="answerValue">
          <el-radio :label="1">正确</el-radio>
          <el-radio :label="0">错误</el-radio>
        </el-radio-group>
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
import { reactive, ref, onMounted, computed, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
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
  questionType: 4,
  difficult: 1,
  score: 2,
  title: '',
  items: [{ content: '', isAnswer: false }]
})

const answerValue = ref(0)
const subjectFilter = ref(null)
const formLoading = ref(false)
const formRef = ref(null)

const levelEnum = computed(() => enumItemStore.user.levelEnum)
const difficultEnum = computed(() => [
  { key: 1, value: '简单' },
  { key: 2, value: '中等' },
  { key: 3, value: '困难' }
])

const rules = {
  level: [{ required: true, message: '请选择年级', trigger: 'change' }],
  subjectId: [{ required: true, message: '请选择学科', trigger: 'change' }],
  difficult: [{ required: true, message: '请选择难度', trigger: 'change' }],
  score: [{ required: true, message: '请输入分数', trigger: 'blur' }],
  title: [{ required: true, message: '请输入题干', trigger: 'blur' }]
}

watch(answerValue, (val) => {
  form.items[0].isAnswer = val === 1
})

const submitForm = () => {
  formRef.value.validate((valid) => {
    if (valid) {
      formLoading.value = true
      questionApi.edit(form).then(re => {
        if (re.code === 1) {
          ElMessage.success(re.message)
          tagsViewStore.delVisitedView({ path: route.path }).then(() => {
            router.push('/exam/question/list')
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

const resetForm = () => {
  const lastId = form.id
  formRef.value.resetFields()
  Object.assign(form, {
    id: null,
    level: null,
    subjectId: null,
    questionType: 4,
    difficult: 1,
    score: 2,
    title: '',
    items: [{ content: '', isAnswer: false }]
  })
  answerValue.value = 0
  form.id = lastId
}

onMounted(() => {
  examStore.initSubject(() => {
    subjectFilter.value = examStore.subjects
  })
  
  const id = route.query.id
  if (id && parseInt(id) !== 0) {
    formLoading.value = true
    questionApi.select(id).then(re => {
      Object.assign(form, re.response)
      answerValue.value = form.items[0]?.isAnswer ? 1 : 0
      formLoading.value = false
    })
  }
})
</script>