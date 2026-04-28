<template>
  <div class="login-page">
    <!-- decorative background blobs -->
    <div class="login-bg" aria-hidden="true">
      <span class="blob blob-1" />
      <span class="blob blob-2" />
      <span class="blob blob-3" />
      <span class="grid-lines" />
    </div>

    <div class="login-shell">
      <div class="login-card">
        <div class="brand">
          <div class="brand__logo">
            <svg width="36" height="36" viewBox="0 0 36 36" fill="none" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">
              <rect width="36" height="36" rx="10" fill="#1890ff"/>
              <path d="M9 18L15 12L21 18L27 12" stroke="white" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
              <path d="M9 24L15 18L21 24L27 18" stroke="white" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" opacity="0.6"/>
            </svg>
          </div>
          <div class="brand__title">408master</div>
          <div class="brand__subtitle">创建新账号</div>
        </div>

        <el-form
          ref="loginForm"
          :model="loginForm"
          class="login-form"
          auto-complete="on"
          label-position="left"
        >
          <el-form-item class="form-item">
            <span class="svg-container" aria-hidden="true">
              <svg-icon icon-class="user" />
            </span>
            <el-input
              ref="userName"
              v-model="loginForm.userName"
              placeholder="用户名"
              name="userName"
              type="text"
              tabindex="1"
              auto-complete="on"
            />
          </el-form-item>

          <el-form-item class="form-item">
            <span class="svg-container" aria-hidden="true">
              <svg-icon icon-class="password" />
            </span>
            <el-input
              ref="password"
              v-model="loginForm.password"
              type="password"
              placeholder="密码"
              name="password"
              tabindex="2"
              auto-complete="on"
              @keyup.enter.native="handleRegister"
            />
          </el-form-item>

          <el-form-item class="form-item form-item--select">
            <span class="svg-container" aria-hidden="true">
              <svg-icon icon-class="education" />
            </span>
            <el-select
              v-model="loginForm.userLevel"
              placeholder="请选择年级"
              class="level-select"
            >
              <el-option
                v-for="item in levelEnum"
                :key="item.key"
                :value="item.key"
                :label="item.value"
              />
            </el-select>
          </el-form-item>

          <el-button
            type="primary"
            class="login-btn"
            @click.native.prevent="handleRegister"
          >
            注 册
          </el-button>

          <div class="text-foot">
            已有账号?
            <router-link to="/login" class="login-link">登录</router-link>
          </div>
        </el-form>
      </div>
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

<style lang="scss">
/* Reset Element-UI input styles inside register card */
.login-page {
  .login-form {
    .el-input {
      display: inline-block;
      flex: 1;
      height: 48px;

      input {
        background: transparent;
        border: 0;
        -webkit-appearance: none;
        border-radius: 0;
        padding: 12px 12px 12px 4px;
        color: #0f172a;
        height: 48px;
        caret-color: #1890ff;

        &::placeholder {
          color: #94a3b8;
        }

        &:-webkit-autofill {
          box-shadow: 0 0 0px 1000px #fff inset !important;
          -webkit-text-fill-color: #0f172a !important;
        }
      }
    }

    .el-form-item {
      border: none;
      background: none;
      border-radius: 0;
      color: inherit;
      margin-bottom: 0;
    }

    .el-form-item__content {
      display: flex;
      align-items: center;
      background: #fff;
      border: 1px solid #dde1e8;
      border-radius: 10px;
      height: 48px;
      overflow: hidden;
      transition: border-color 0.18s, box-shadow 0.18s;

      &:focus-within {
        border-color: #1890ff;
        box-shadow: 0 0 0 3px rgba(24, 144, 255, 0.12);
      }
    }

    .el-form-item__error {
      padding-top: 4px;
      padding-left: 4px;
    }

    .level-select {
      flex: 1;
      height: 48px;

      .el-input {
        height: 48px;
      }

      .el-input__inner {
        border: 0 !important;
        border-radius: 0 !important;
        height: 48px !important;
        background: transparent !important;
        padding-left: 4px;
      }

      .el-input__suffix {
        right: 8px;
      }
    }
  }
}
</style>

<style lang="scss" scoped>
.login-page {
  min-height: 100vh;
  width: 100%;
  position: relative;
  overflow: hidden;
  background: #f5f7fb;
}

.login-bg {
  position: absolute;
  inset: 0;
  overflow: hidden;
  pointer-events: none;

  .grid-lines {
    position: absolute;
    inset: -2px;
    opacity: 0.18;
    background-image:
      linear-gradient(to right, rgba(24, 144, 255, 0.12) 1px, transparent 1px),
      linear-gradient(to bottom, rgba(24, 144, 255, 0.12) 1px, transparent 1px);
    background-size: 60px 60px;
    mask-image: radial-gradient(ellipse at 50% 30%, rgba(0,0,0,1), rgba(0,0,0,0.1) 60%, rgba(0,0,0,0) 80%);
  }

  .blob {
    position: absolute;
    border-radius: 50%;
    filter: blur(32px);
    opacity: 0.45;
  }

  .blob-1 {
    width: 520px;
    height: 520px;
    left: -200px;
    top: -240px;
    background: radial-gradient(circle at 30% 30%, rgba(24,144,255,0.38), rgba(24,144,255,0));
  }

  .blob-2 {
    width: 480px;
    height: 480px;
    right: -180px;
    top: -160px;
    background: radial-gradient(circle at 30% 30%, rgba(19,206,102,0.20), rgba(19,206,102,0));
  }

  .blob-3 {
    width: 400px;
    height: 400px;
    left: 22%;
    bottom: -200px;
    background: radial-gradient(circle at 30% 30%, rgba(255,186,0,0.16), rgba(255,186,0,0));
  }
}

.login-shell {
  position: relative;
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 40px 16px;
}

.login-card {
  width: 420px;
  max-width: 100%;
  background: rgba(255, 255, 255, 0.94);
  backdrop-filter: blur(8px);
  border: 1px solid rgba(15, 23, 42, 0.07);
  border-radius: 18px;
  box-shadow: 0 24px 64px rgba(15, 23, 42, 0.10), 0 2px 8px rgba(15, 23, 42, 0.04);
  padding: 36px 32px 32px;
}

.brand {
  text-align: center;
  margin-bottom: 28px;

  &__logo {
    margin-bottom: 12px;

    svg {
      display: inline-block;
    }
  }

  &__title {
    font-size: 24px;
    font-weight: 800;
    letter-spacing: 0.2px;
    color: #0f172a;
    line-height: 1.2;
  }

  &__subtitle {
    margin-top: 6px;
    font-size: 13px;
    color: #64748b;
    line-height: 1.4;
  }
}

.login-form {
  .form-item {
    position: relative;
    margin-bottom: 16px;
  }

  .form-item--select {
    ::v-deep .el-form-item__content {
      padding-right: 0;
    }
  }
}

.svg-container {
  width: 44px;
  height: 48px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  color: #94a3b8;
  border-right: 1px solid #f0f2f5;
  flex-shrink: 0;
}

.login-btn {
  width: 100%;
  height: 46px;
  border-radius: 10px;
  font-size: 15px;
  font-weight: 700;
  letter-spacing: 0.5px;
  box-shadow: 0 8px 24px rgba(24, 144, 255, 0.22);
  transition: all 0.2s ease;

  &:hover {
    box-shadow: 0 12px 32px rgba(24, 144, 255, 0.30);
    transform: translateY(-1px);
  }

  &:active {
    transform: translateY(0);
  }
}

.text-foot {
  text-align: center;
  margin-top: 20px;
  font-size: 13px;
  color: #64748b;

  .login-link {
    color: #1890ff;
    font-weight: 600;
    text-decoration: none;
    border-bottom: none;

    &:hover {
      text-decoration: underline;
    }
  }
}
</style>
