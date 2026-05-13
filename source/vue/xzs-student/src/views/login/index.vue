<template>
  <div class="login-page">
    <div class="login-container">
      <div class="login-header">
        <div class="login-brand">
          <img src="@/assets/logo2.png" alt="logo">
        </div>
        <h2 class="system-title">408刷题系统</h2>
      </div>

      <div class="login-box">
        <el-form ref="loginFormRef" :model="loginForm" :rules="loginRules" class="login-form">
          <div class="form-title">
            <h3><el-icon><User /></el-icon> 用户登录</h3>
          </div>

          <el-form-item prop="userName">
            <div class="input-wrapper">
              <el-icon><User /></el-icon>
              <el-input
                ref="userNameRef"
                v-model="loginForm.userName"
                placeholder="请输入用户名"
                name="userName"
                type="text"
                tabindex="1"
                auto-complete="on"
              />
            </div>
          </el-form-item>

          <el-form-item prop="password">
            <div class="input-wrapper">
              <el-icon><Lock /></el-icon>
              <el-input
                ref="passwordRef"
                v-model="loginForm.password"
                :type="passwordType"
                placeholder="请输入密码"
                name="password"
                tabindex="2"
                auto-complete="on"
                @keyup="checkCapslock"
                @blur="capsTooltip = false"
                @keyup.enter="handleLogin"
              />
              <el-icon class="password-toggle" @click="showPwd"><View v-if="passwordType === 'password'" /><Hide v-else /></el-icon>
            </div>
          </el-form-item>

          <el-form-item>
            <el-button :loading="loading" type="primary" class="login-btn" @click="handleLogin">
              <el-icon><ArrowRight /></el-icon> 登录
            </el-button>
          </el-form-item>

          <div class="form-footer">
            <span>还没有账号?</span>
            <router-link to="/register">
              <el-icon><Plus /></el-icon> 立即注册
            </router-link>
          </div>
        </el-form>
      </div>

      <div class="login-footer">
        <span>Copyright ©2019-2026 武汉思维跳跃科技有限公司 版权所有</span>
      </div>
    </div>

    <div class="login-background">
      <div class="bg-gradient"></div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, nextTick } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { User, Lock, View, Hide, ArrowRight, Plus } from '@element-plus/icons-vue'
import loginApi from '@/api/login'
import { useUserStore } from '@/store/modules/user'

const router = useRouter()
const userStore = useUserStore()

const loginFormRef = ref(null)
const userNameRef = ref(null)
const passwordRef = ref(null)

const loginForm = reactive({
  userName: '',
  password: ''
})

const passwordType = ref('password')
const capsTooltip = ref(false)
const loading = ref(false)

const validateUsername = (rule, value, callback) => {
  if (value.length < 5) {
    callback(new Error('用户名不能少于5个字符'))
  } else {
    callback()
  }
}

const validatePassword = (rule, value, callback) => {
  if (value.length < 5) {
    callback(new Error('密码不能少于5个字符'))
  } else {
    callback()
  }
}

const loginRules = {
  userName: [{ required: true, trigger: 'blur', validator: validateUsername }],
  password: [{ required: true, trigger: 'blur', validator: validatePassword }]
}

const checkCapslock = ({ shiftKey, key } = {}) => {
  if (key && key.length === 1) {
    if ((shiftKey && (key >= 'a' && key <= 'z')) || (!shiftKey && (key >= 'A' && key <= 'Z'))) {
      capsTooltip.value = true
    } else {
      capsTooltip.value = false
    }
  }
  if (key === 'CapsLock' && capsTooltip.value === true) {
    capsTooltip.value = false
  }
}

const showPwd = () => {
  if (passwordType.value === 'password') {
    passwordType.value = ''
  } else {
    passwordType.value = 'password'
  }
  nextTick(() => {
    passwordRef.value?.focus()
  })
}

const handleLogin = () => {
  loginFormRef.value.validate(valid => {
    if (valid) {
      loading.value = true
      loginApi.login(loginForm).then(function (result) {
        if (result && result.code === 1) {
          userStore.setUserName(loginForm.userName)
          router.push({ path: '/' })
        } else {
          loading.value = false
          ElMessage.error(result.message)
        }
      }).catch(function () {
        loading.value = false
      })
    } else {
      return false
    }
  })
}

onMounted(() => {
  if (loginForm.userName === '') {
    userNameRef.value?.focus()
  } else if (loginForm.password === '') {
    passwordRef.value?.focus()
  }
})
</script>

<style lang="scss" scoped>
.login-page {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #0c0c1c;
  position: relative;
  overflow: hidden;
}

.login-background {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  z-index: 0;

  .bg-gradient {
    position: absolute;
    top: -50%;
    left: -50%;
    width: 200%;
    height: 200%;
    background: radial-gradient(circle at 30% 30%, rgba(102, 126, 234, 0.3) 0%, transparent 50%),
                radial-gradient(circle at 70% 70%, rgba(118, 75, 162, 0.3) 0%, transparent 50%);
    animation: bgMove 20s ease-in-out infinite;
  }
}

@keyframes bgMove {
  0%, 100% { transform: translate(0, 0) rotate(0deg); }
  50% { transform: translate(-5%, -5%) rotate(180deg); }
}

.login-container {
  position: relative;
  z-index: 1;
  width: 420px;
  padding: 40px;
}

.login-header {
  text-align: center;
  margin-bottom: 40px;
}

.login-brand {
  width: 90px;
  height: 90px;
  margin: 0 auto 20px;
  border-radius: 50%;
  overflow: hidden;
  box-shadow: 0 8px 30px rgba(102, 126, 234, 0.4);
  background: #fff;
  padding: 8px;
  animation: brandFloat 3s ease-in-out infinite;

  img {
    width: 100%;
    height: 100%;
    object-fit: contain;
  }
}

@keyframes brandFloat {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-10px); }
}

.system-title {
  font-size: 28px;
  font-weight: 700;
  color: #fff;
  margin: 0;
  text-shadow: 0 2px 10px rgba(102, 126, 234, 0.5);
}

.login-box {
  background: rgba(255, 255, 255, 0.95);
  border-radius: 16px;
  padding: 40px 35px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  backdrop-filter: blur(10px);
}

.login-form {
  .form-title {
    text-align: center;
    margin-bottom: 30px;

    h3 {
      font-size: 22px;
      font-weight: 600;
      color: #1f2f3d;
      margin: 0;
      display: flex;
      align-items: center;
      justify-content: center;

      .el-icon {
        margin-right: 10px;
        color: #667eea;
      }
    }
  }

  .input-wrapper {
    position: relative;
    display: flex;
    align-items: center;
    background: #f8f9fa;
    border-radius: 8px;
    padding: 0 15px;
    transition: all 0.3s;

    &:focus-within {
      background: #fff;
      box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.2);
    }

    > .el-icon {
      color: #667eea;
      font-size: 18px;
      margin-right: 10px;
    }

    .el-input {
      flex: 1;

      :deep(.el-input__wrapper) {
        border: none;
        background: transparent;
        box-shadow: none;
        padding: 8px 0;
      }
    }

    .password-toggle {
      cursor: pointer;
      color: #909399;
      transition: color 0.3s;
      margin-left: 10px;

      &:hover {
        color: #667eea;
      }
    }
  }

  :deep(.el-form-item) {
    margin-bottom: 20px;
  }

  :deep(.el-form-item__error) {
    font-size: 12px;
    padding-top: 4px;
  }
}

.login-btn {
  width: 100%;
  height: 48px;
  border: none;
  border-radius: 8px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: #fff;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
  box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);

  .el-icon {
    margin-right: 8px;
  }

  &:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 20px rgba(102, 126, 234, 0.5);
  }

  &:active {
    transform: translateY(0);
  }

  &.is-loading {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  }
}

.form-footer {
  text-align: center;
  margin-top: 25px;
  font-size: 14px;
  color: #909399;

  span {
    margin-right: 5px;
  }

  a {
    color: #667eea;
    text-decoration: none;
    font-weight: 500;
    transition: color 0.3s;

    .el-icon {
      margin-right: 5px;
    }

    &:hover {
      color: #764ba2;
    }
  }
}

.login-footer {
  text-align: center;
  margin-top: 40px;

  span {
    color: rgba(255, 255, 255, 0.6);
    font-size: 13px;
  }
}

@media screen and (max-width: 480px) {
  .login-container {
    width: 100%;
    padding: 20px;
  }

  .login-box {
    padding: 30px 25px;
  }

  .system-title {
    font-size: 22px;
  }
}
</style>
