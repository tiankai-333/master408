<template>
  <div class="app-container">
    <el-form :model="form" ref="formRef" label-width="100px" v-loading="formLoading" :rules="rules">
      <el-form-item label="标题：" prop="title" required>
        <el-input v-model="form.title"/>
      </el-form-item>
      <el-form-item label="内容：" prop="content" required>
        <el-input v-model="form.content" type="textarea" :rows="10"/>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="submitForm">发送</el-button>
        <el-button @click="resetForm">重置</el-button>
      </el-form-item>
    </el-form>
  </div>
</template>

<script setup>
import { ElMessage } from 'element-plus'
import { reactive, ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import messageApi from '@/api/message'
import { useTagsViewStore } from '@/stores/tagsView'

const router = useRouter()
const tagsViewStore = useTagsViewStore()

const form = reactive({
  title: '',
  content: ''
})

const formLoading = ref(false)
const formRef = ref(null)

const rules = {
  title: [
    { required: true, message: '请输入标题', trigger: 'blur' }
  ],
  content: [
    { required: true, message: '请输入内容', trigger: 'blur' }
  ]
}

const submitForm = () => {
  formRef.value.validate((valid) => {
    if (valid) {
      formLoading.value = true
      messageApi.send(form).then(re => {
        if (re.code === 1) {
          ElMessage.success(re.message)
          tagsViewStore.delVisitedView({ path: '/message/send' }).then(() => {
            router.push('/message/list')
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

const resetForm = () => {
  formRef.value.resetFields()
  Object.assign(form, {
    title: '',
    content: ''
  })
}

onMounted(() => {})
</script>