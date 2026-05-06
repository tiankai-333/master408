<template>
  <div class="register-page">
    <div class="register-container">
      <div class="register-header">
        <div class="register-brand">
          <img src="@/assets/logo2.png" alt="logo">
        </div>
        <h2 class="system-title">学之思开源考试系统</h2>
      </div>

      <div class="register-box">
        <el-form ref="loginForm" :model="loginForm" class="register-form">
          <div class="form-title">
            <h3><i class="el-icon-user-plus"></i> 用户注册</h3>
          </div>

          <el-form-item>
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

          <el-form-item>
            <div class="input-wrapper">
              <i class="el-icon-lock"></i>
              <el-input
                ref="password"
                v-model="loginForm.password"
                type="password"
                placeholder="请输入密码"
                name="password"
                tabindex="2"
                auto-complete="on"
                @keyup.enter.native="handleRegister"
              />
            </div>
          </el-form-item>

          <el-form-item>
            <div class="input-wrapper">
              <i class="el-icon-s-order"></i>
              <el-select v-model="loginForm.userLevel" placeholder="请选择年级" class="level-select">
                <el-option v-for="item in levelEnum" :key="item.key" :value="item.key" :label="item.value"></el-option>
              </el-select>
            </div>
          </el-form-item>

          <el-form-item>
            <el-button type="primary" class="register-btn" @click.native.prevent="handleRegister">
              <i class="el-icon-check"></i> 注册
            </el-button>
          </el-form-item>

          <div class="form-footer">
            <span>已有账号?</span>
            <router-link to="/login">
              <i class="el-icon-arrow-left"></i> 返回登录
            </router-link>
          </div>
        </el-form>
      </div>

      <div class="register-footer">
        <span>Copyright ©2019-2026 武汉思维跳跃科技有限公司 版权所有</span>
      </div>
    </div>

    <div class="register-background">
      <div class="bg-gradient"></div>
    </div>
  </div>
</template>

<script>
import { mapMutations, mapState } from 'vuex'
import registerApi from '@/api/register'

export default {
  name: 'Login',
  data () {
    return {
      loginForm: {
        userName: '',
        password: '',
        userLevel: 1
      }
    }
  },
  methods: {
    handleRegister () {
      let _this = this
      registerApi.register(this.loginForm).then(function (result) {
        if (result && result.code === 1) {
          _this.$message.success('注册成功，请登录')
          _this.$router.push({ path: '/login' })
        } else {
          _this.$message.error(result.message)
        }
      })
    },
    ...mapMutations('user', ['setUserName'])
  },
  computed: {
    ...mapState('enumItem', {
      levelEnum: state => state.user.levelEnum
    })
  }
}
</script>

<style lang="scss" scoped>
.register-page {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #0c0c1c;
  position: relative;
  overflow: hidden;
}

.register-background {
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

.register-container {
  position: relative;
  z-index: 1;
  width: 420px;
  padding: 40px;
}

.register-header {
  text-align: center;
  margin-bottom: 40px;
}

.register-brand {
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

.register-box {
  background: rgba(255, 255, 255, 0.95);
  border-radius: 16px;
  padding: 40px 35px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  backdrop-filter: blur(10px);
}

.register-form {
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

    .level-select {
      flex: 1;

      ::v-deep .el-input__inner {
        border: none;
        background: transparent;
        padding: 12px 0;
        font-size: 15px;
        color: #1f2f3d;
      }
    }
  }

  ::v-deep .el-form-item {
    margin-bottom: 20px;
  }
}

.register-btn {
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

.register-footer {
  text-align: center;
  margin-top: 40px;

  span {
    color: rgba(255, 255, 255, 0.6);
    font-size: 13px;
  }
}

@media screen and (max-width: 480px) {
  .register-container {
    width: 100%;
    padding: 20px;
  }

  .register-box {
    padding: 30px 25px;
  }

  .system-title {
    font-size: 22px;
  }
}
</style>
