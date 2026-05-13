<template>
  <div class="app-container">

    <el-form :model="form" ref="formRef" label-width="100px" v-loading="formLoading" :rules="rules">
      <el-form-item label="用户名："  prop="userName" required>
        <el-input v-model="form.userName"></el-input>
      </el-form-item>
      <el-form-item label="密码："  required>
        <el-input v-model="form.password"></el-input>
      </el-form-item>
      <el-form-item label="真实姓名：" prop="realName" required>
        <el-input v-model="form.realName"></el-input>
      </el-form-item>
      <el-form-item label="年龄：">
        <el-input v-model="form.age"></el-input>
      </el-form-item>
      <el-form-item label="性别：">
        <el-select v-model="form.sex" placeholder="性别" clearable>
          <el-option v-for="item in sexEnum" :key="item.key" :value="item.key" :label="item.value"></el-option>
        </el-select>
      </el-form-item>
      <el-form-item label="出生日期：">
        <el-date-picker v-model="form.birthDay" type="date" value-format="yyyy-MM-dd" placeholder="选择日期" />
      </el-form-item>
      <el-form-item label="手机：">
        <el-input v-model="form.phone"></el-input>
      </el-form-item>
      <el-form-item label="年级：" prop="userLevel" required>
        <el-select v-model="form.userLevel" placeholder="年级">
          <el-option v-for="item in levelEnum" :key="item.key" :value="item.key" :label="item.value"></el-option>
        </el-select>
      </el-form-item>
      <el-form-item label="状态：" required>
        <el-select v-model="form.status" placeholder="状态">
          <el-option v-for="item in statusEnum" :key="item.key" :value="item.key" :label="item.value"></el-option>
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
import userApi from '@/api/user'
import { useEnumItemStore } from '@/stores/enumItem'
import { useTagsViewStore } from '@/stores/tagsView'

const route = useRoute()
const router = useRouter()
const enumItemStore = useEnumItemStore()
const tagsViewStore = useTagsViewStore()

const form = reactive({
  id: null,
  userName: '',
  password: '',
  realName: '',
  role: 1,
  status: 1,
  age: '',
  sex: '',
  birthDay: null,
  phone: null,
  userLevel: null
})

const formLoading = ref(false)
const formRef = ref(null)

const sexEnum = computed(() => enumItemStore.user.sexEnum)
const roleEnum = computed(() => enumItemStore.user.roleEnum)
const statusEnum = computed(() => enumItemStore.user.statusEnum)
const levelEnum = computed(() => enumItemStore.user.levelEnum)

const rules = {
  userName: [
    { required: true, message: '请输入用户名', trigger: 'blur' }
  ],
  realName: [
    { required: true, message: '请输入真实姓名', trigger: 'blur' }
  ],
  userLevel: [
    { required: true, message: '请选择年级', trigger: 'change' }
  ]
}

const submitForm = () => {
  formRef.value.validate((valid) => {
    if (valid) {
      formLoading.value = true
      userApi.createUser(form).then(data => {
        if (data.code === 1) {
          ElMessage.success(data.message)
          tagsViewStore.delVisitedView({ path: route.path }).then(() => {
            router.push('/user/student/list')
          })
        } else {
          ElMessage.error(data.message)
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
    userName: '',
    password: '',
    realName: '',
    role: 1,
    status: 1,
    age: '',
    sex: '',
    birthDay: null,
    phone: null,
    userLevel: null
  })
  form.id = lastId
}

onMounted(() => {
  const id = route.query.id
  if (id && parseInt(id) !== 0) {
    formLoading.value = true
    userApi.selectUser(id).then(re => {
      Object.assign(form, re.response)
      formLoading.value = false
    })
  }
})
</script>