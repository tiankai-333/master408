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
      <el-form-item label="填空答案：" prop="items" required>
        <div v-for="(item, index) in form.items" :key="index" class="item-row">
          <span>填空{{ index + 1 }}：</span>
          <el-input v-model="item.content" placeholder="答案"/>
          <el-button v-if="form.items.length > 1" type="text" @click="removeItem(index)">删除</el-button>
        </div>
        <el-button type="text" @click="addItem">添加填空</el-button>
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
  questionType: 3,
  difficult: 1,
  score: 5,
  title: '',
  items: [{ content: '' }]
})

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
  title: [{ required: true, message: '请输入题干', trigger: 'blur' }],
  items: [{ validator: (rule, value, callback) => {
    const hasContent = value.every(item => item.content.trim())
    if (!hasContent) {
      callback(new Error('请填写所有填空答案'))
    } else {
      callback()
    }
  }, trigger: 'blur' }]
}

const addItem = () => {
  form.items.push({ content: '' })
}

const removeItem = (index) => {
  form.items.splice(index, 1)
}

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
    questionType: 3,
    difficult: 1,
    score: 5,
    title: '',
    items: [{ content: '' }]
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
    questionApi.select(id).then(re => {
      Object.assign(form, re.response)
      formLoading.value = false
    })
  }
})
</script>

<style scoped>
.item-row {
  display: flex;
  align-items: center;
  margin-bottom: 10px;
}
</style>