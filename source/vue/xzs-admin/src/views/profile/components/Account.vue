<template>
  <el-card title="账号设置">
    <el-form :model="form" ref="formRef" label-width="100px" :rules="rules">
      <el-form-item label="用户名：" prop="userName">
        <el-input v-model="form.userName" disabled/>
      </el-form-item>
      <el-form-item label="邮箱：" prop="email">
        <el-input v-model="form.email"/>
      </el-form-item>
      <el-form-item label="电话：" prop="phone">
        <el-input v-model="form.phone"/>
      </el-form-item>
      <el-form-item label="旧密码：" prop="oldPassword">
        <el-input v-model="form.oldPassword" type="password"/>
      </el-form-item>
      <el-form-item label="新密码：" prop="newPassword">
        <el-input v-model="form.newPassword" type="password"/>
      </el-form-item>
      <el-form-item label="确认密码：" prop="confirmPassword">
        <el-input v-model="form.confirmPassword" type="password"/>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="submitForm">保存修改</el-button>
      </el-form-item>
    </el-form>
  </el-card>
</template>

<script setup>
import { ElMessage } from 'element-plus'
import { reactive, ref, onMounted } from 'vue'
import adminApi from '@/api/user'
import { useUserStore } from '@/stores/user'

const userStore = useUserStore()

const form = reactive({
  userName: '',
  email: '',
  phone: '',
  oldPassword: '',
  newPassword: '',
  confirmPassword: ''
})

const formRef = ref(null)

const rules = {
  email: [
    { required: true, message: '请输入邮箱', trigger: 'blur' },
    { type: 'email', message: '请输入正确的邮箱格式', trigger: 'blur' }
  ],
  phone: [
    { required: true, message: '请输入电话', trigger: 'blur' },
    { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号码', trigger: 'blur' }
  ],
  newPassword: [
    { min: 6, max: 20, message: '密码长度在6到20个字符', trigger: 'blur' }
  ],
  confirmPassword: [
    { validator: (rule, value, callback) => {
      if (value !== form.newPassword) {
        callback(new Error('两次输入的密码不一致'))
      } else {
        callback()
      }
    }, trigger: 'blur' }
  ]
}

const submitForm = () => {
  formRef.value.validate((valid) => {
    if (valid) {
      adminApi.updateProfile(form).then(re => {
        if (re.code === 1) {
          ElMessage.success(re.message)
          if (form.newPassword) {
            userStore.clearLogin()
          }
        } else {
          ElMessage.error(re.message)
        }
      })
    }
  })
}

onMounted(() => {
  const user = userStore.userInfo
  form.userName = user.userName || ''
  form.email = user.email || ''
  form.phone = user.phone || ''
})
</script>