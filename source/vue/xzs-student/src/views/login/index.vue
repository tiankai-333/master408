<template>
  <div class="login-page">
    <div class="login-container">
      <div class="login-header">
        <div class="login-brand">
          <img src="@/assets/logo2.png" alt="logo">
        </div>
        <h2 class="system-title">学之思开源考试系统</h2>
      </div>

      <div class="login-box">
        <el-form ref="loginForm" :model="loginForm" :rules="loginRules" class="login-form">
          <div class="form-title">
            <h3><i class="el-icon-user"></i> 用户登录</h3>
          </div>

          <el-form-item prop="userName">
            <div class="input-wrapper">
              <i class="el-icon-user"></i>
              <el-input
                ref="userName"
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
              <i class="el-icon-lock"></i>
              <el-input
                :key="passwordType"
                ref="password"
                v-model="loginForm.password"
                :type="passwordType"
                placeholder="请输入密码"
                name="password"
                tabindex="2"
                auto-complete="on"
                @keyup.native="checkCapslock"
                @blur="capsTooltip = false"
                @keyup.enter.native="handleLogin"
              />
              <i class="el-icon-view password-toggle" @click="showPwd"></i>
            </div>
          </el-form-item>

          <el-form-item>
            <el-button :loading="loading" type="primary" class="login-btn" @click.native.prevent="handleLogin">
              <i class="el-icon-arrow-right"></i> 登录
            </el-button>
          </el-form-item>

          <div class="form-footer">
            <span>还没有账号?</span>
            <router-link to="/register">
              <i class="el-icon-plus"></i> 立即注册
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

<script>
import { mapMutations } from 'vuex'
import loginApi from '@/api/login'

export default {
  name: 'Login',
  data () {
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
    return {
      loginForm: {
        userName: '',
        password: '',
        remember: false
      },
      loginRules: {
        userName: [{ required: true, trigger: 'blur', validator: validateUsername }],
        password: [{ required: true, trigger: 'blur', validator: validatePassword }]
      },
      passwordType: 'password',
      capsTooltip: false,
      loading: false,
      showDialog: false
    }
  },
  created () {
  },
  mounted () {
    if (this.loginForm.userName === '') {
      this.$refs.userName.focus()
    } else if (this.loginForm.password === '') {
      this.$refs.password.focus()
    }
  },
  destroyed () {
  },
  methods: {
    checkCapslock ({ shiftKey, key } = {}) {
      if (key && key.length === 1) {
        if ((shiftKey && (key >= 'a' && key <= 'z')) || (!shiftKey && (key >= 'A' && key <= 'Z'))) {
          this.capsTooltip = true
        } else {
          this.capsTooltip = false
        }
      }
      if (key === 'CapsLock' && this.capsTooltip === true) {
        this.capsTooltip = false
      }
    },
    showPwd () {
      if (this.passwordType === 'password') {
        this.passwordType = ''
      } else {
        this.passwordType = 'password'
      }
      this.$nextTick(() => {
        this.$refs.password.focus()
      })
    },
    handleLogin () {
      let _this = this
      this.$refs.loginForm.validate(valid => {
        if (valid) {
          this.loading = true
          loginApi.login(this.loginForm).then(function (result) {
            if (result && result.code === 1) {
              _this.setUserName(_this.loginForm.userName)
              _this.$router.push({ path: '/' })
            } else {
              _this.loading = false
              _this.$message.error(result.message)
            }
          }).catch(function (reason) {
            _this.loading = false
          })
        } else {
          return false
        }
      })
    },
    ...mapMutations('user', ['setUserName'])
  }
}
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
  0%, 100% {
    transform: translate(0, 0) rotate(0deg);
  }
  50% {
    transform: translate(-5%, -5%) rotate(180deg);
  }
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
  0%, 100% {
    transform: translateY(0);
  }
  50% {
    transform: translateY(-10px);
  }
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

      i {
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

    > i {
      color: #667eea;
      font-size: 18px;
      margin-right: 10px;
    }

    .el-input {
      flex: 1;

      ::v-deep .el-input__inner {
        border: none;
        background: transparent;
        padding: 12px 0;
        font-size: 15px;
        color: #1f2f3d;

        &::placeholder {
          color: #909399;
        }
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

  ::v-deep .el-form-item {
    margin-bottom: 20px;
  }

  ::v-deep .el-form-item__error {
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

  i {
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

    i {
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
