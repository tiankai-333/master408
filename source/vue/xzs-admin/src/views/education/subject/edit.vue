<template>
  <div class="app-container">
    <el-form :model="form" ref="formRef" label-width="100px" v-loading="formLoading" :rules="rules">
      <el-form-item label="学科名称：" prop="name" required>
        <el-input v-model="form.name"/>
      </el-form-item>
      <el-form-item label="排序：" prop="sort" required>
        <el-input v-model.number="form.sort" type="number"/>
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
import subjectApi from '@/api/subject'
import { useEnumItemStore } from '@/stores/enumItem'
import { useTagsViewStore } from '@/stores/tagsView'

const route = useRoute()
const router = useRouter()
const enumItemStore = useEnumItemStore()
const tagsViewStore = useTagsViewStore()

const form = reactive({
  id: null,
  name: '',
  sort: 0
})

const formLoading = ref(false)
const formRef = ref(null)

const rules = {
  name: [
    { required: true, message: '请输入学科名称', trigger: 'blur' }
  ],
  sort: [
    { required: true, message: '请输入排序号', trigger: 'blur' }
  ]
}

const submitForm = () => {
  formRef.value.validate((valid) => {
    if (valid) {
      formLoading.value = true
      subjectApi.edit(form).then(re => {
        if (re.code === 1) {
          ElMessage.success(re.message)
          tagsViewStore.delVisitedView({ path: route.path }).then(() => {
            router.push('/education/subject/list')
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
  const lastId = form.id
  formRef.value.resetFields()
  Object.assign(form, {
    id: null,
    name: '',
    sort: 0
  })
  form.id = lastId
}

onMounted(() => {
  const id = route.query.id
  if (id && parseInt(id) !== 0) {
    formLoading.value = true
    subjectApi.select(id).then(re => {
      Object.assign(form, re.response)
      formLoading.value = false
    })
  }
})
</script>