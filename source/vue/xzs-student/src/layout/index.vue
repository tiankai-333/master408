<template>
  <el-container class="layout-container">
    <el-header height="70" class="student-header">
      <div class="header-content">
        <div class="logo-section">
          <router-link to="/">
            <div class="logo-wrapper">
              <div class="logo-icon">
                <el-icon><Reading /></el-icon>
              </div>
              <div class="logo-text-container">
                <span class="logo-main">master408</span>
                <span class="logo-sub">智能考试系统</span>
              </div>
            </div>
          </router-link>
        </div>
        <el-menu class="el-menu-title" mode="horizontal" :default-active="defaultUrl" :router="true">
          <el-menu-item index="/index">
            <el-icon><HomeFilled /></el-icon>
            首页
          </el-menu-item>
          <el-menu-item index="/paper/index">
            <el-icon><Document /></el-icon>
            试卷中心
          </el-menu-item>
          <el-menu-item index="/record/index">
            <el-icon><Tickets /></el-icon>
            考试记录
          </el-menu-item>
          <el-menu-item index="/question/index">
            <el-icon><WarningFilled /></el-icon>
            错题本
          </el-menu-item>
          <el-menu-item index="/question/ai-analyze">
            <el-icon><Search /></el-icon>
            AI题目识别
          </el-menu-item>
          <el-menu-item index="/knowledge-graph/index">
            <el-icon><Share /></el-icon>
            知识图谱
          </el-menu-item>
        </el-menu>
        <div class="head-user">
          <el-dropdown trigger="click" placement="bottom-end">
            <el-badge :is-dot="userStore.messageCount !== 0">
              <el-avatar class="el-dropdown-avatar" size="medium" :src="userInfo.imagePath === null ? avatarDefault : userInfo.imagePath"></el-avatar>
            </el-badge>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item @click="$router.push({ path: '/user/index' })">
                  <el-icon><User /></el-icon>个人中心
                </el-dropdown-item>
                <el-dropdown-item @click="$router.push({ path: '/user/message' })">
                  <el-icon><Bell /></el-icon>
                  <el-badge :value="userStore.messageCount" v-if="userStore.messageCount !== 0">消息中心</el-badge>
                  <span v-if="userStore.messageCount === 0">消息中心</span>
                </el-dropdown-item>
                <el-dropdown-item @click="logout" divided>
                  <el-icon><SwitchButton /></el-icon>退出
                </el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </div>
    </el-header>
    <el-main class="student-main">
      <router-view />
    </el-main>
  </el-container>
</template>

<script setup>
import { ref, reactive, computed, onMounted, watch } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useUserStore } from '@/store/modules/user'
import loginApi from '@/api/login'
import userApi from '@/api/user'
import avatarDefault from '@/assets/avatar.png'
import {
  Reading, HomeFilled, Document, Tickets, WarningFilled,
  Search, Share, User, Bell, SwitchButton
} from '@element-plus/icons-vue'

const router = useRouter()
const route = useRoute()
const userStore = useUserStore()

const defaultUrl = ref('/index')
const userInfo = reactive({
  imagePath: null
})

const routeSelect = (path) => {
  const topPath = ['/', '/index', '/paper/index', '/record/index', '/question/index', '/knowledge-graph/index']
  if (topPath.indexOf(path) >= 0) {
    return path
  }
  return null
}

const logout = () => {
  loginApi.logout().then(function (result) {
    if (result && result.code === 1) {
      userStore.clearLogin()
      router.push({ path: '/login' })
    }
  })
}

onMounted(() => {
  defaultUrl.value = routeSelect(route.path) || '/index'
  userStore.getUserMessageInfo()
  userApi.getCurrentUser().then(re => {
    Object.assign(userInfo, re.response)
  })
})

watch(() => route.path, (to) => {
  defaultUrl.value = routeSelect(to) || '/index'
})
</script>

<style lang="scss" scoped>
.layout-container {
  min-height: 100vh;
}

.student-header {
  background: linear-gradient(135deg, #1a1a2e 0%, #16213e 30%, #0f3460 60%, #533483 100%);
  background-size: 200% 200%;
  animation: gradient-shift 10s ease infinite;
  border-bottom: none !important;
  box-shadow: 0 4px 30px rgba(0, 0, 0, 0.3), 0 0 60px rgba(83, 52, 131, 0.2), inset 0 1px 0 rgba(255, 255, 255, 0.1);
  position: relative;
  overflow: hidden;

  &::before {
    content: '';
    position: absolute;
    top: 0;
    left: -100%;
    width: 100%;
    height: 100%;
    background: linear-gradient(90deg, transparent, rgba(255,255,255,0.1), transparent);
    animation: shimmer 4s infinite;
  }

  .header-content {
    display: flex;
    align-items: center;
    height: 100%;
    max-width: 1400px;
    margin: 0 auto;
    position: relative;
    z-index: 1;
  }

  .logo-section {
    margin-right: 40px;

    a {
      text-decoration: none !important;
    }

    .logo-wrapper {
      display: flex;
      align-items: center;
      gap: 12px;
      padding: 8px 18px;
      background: linear-gradient(135deg, rgba(255,255,255,0.1), rgba(255,255,255,0.05));
      backdrop-filter: blur(15px);
      border-radius: 12px;
      border: 1px solid rgba(255, 255, 255, 0.15);
      transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);

      &:hover {
        transform: translateY(-2px);
        background: linear-gradient(135deg, rgba(255,255,255,0.15), rgba(255,255,255,0.1));
        box-shadow: 0 8px 30px rgba(0, 0, 0, 0.3);
      }

      .logo-icon {
        width: 38px;
        height: 38px;
        background: linear-gradient(135deg, #a855f7, #6366f1);
        border-radius: 10px;
        display: flex;
        align-items: center;
        justify-content: center;
        box-shadow: 0 4px 15px rgba(168, 85, 247, 0.4);
        animation: icon-pulse 3s ease-in-out infinite;

        .el-icon {
          font-size: 22px;
          color: #fff;
        }
      }

      .logo-text-container {
        display: flex;
        flex-direction: column;
        gap: 2px;

        .logo-main {
          font-size: 22px;
          font-weight: 700;
          color: #fff;
          letter-spacing: 1.5px;
          text-shadow: 0 2px 10px rgba(0,0,0,0.2);
        }

        .logo-sub {
          font-size: 11px;
          color: rgba(255, 255, 255, 0.75);
          letter-spacing: 2px;
        }
      }
    }
  }

  .el-menu-title {
    flex: 1;
    background: transparent;
    border-bottom: none;

    .el-menu-item {
      color: rgba(255,255,255,0.9) !important;
      font-size: 16px;
      font-weight: 500;
      height: 70px;
      line-height: 70px;
      border-bottom: 3px solid transparent !important;
      position: relative;
      overflow: hidden;
      transition: all 0.3s ease;

      &::after {
        content: '';
        position: absolute;
        bottom: 0;
        left: 50%;
        width: 0;
        height: 3px;
        background: linear-gradient(90deg, #a855f7, #6366f1);
        transition: all 0.3s ease;
        transform: translateX(-50%);
      }

      &:hover {
        background: rgba(255, 255, 255, 0.08) !important;
        color: #fff !important;

        &::after {
          width: 80%;
        }

        .el-icon {
          transform: scale(1.15);
          color: #a855f7;
        }
      }

      &.is-active {
        color: #c4b5fd !important;

        &::after {
          width: 80%;
          background: linear-gradient(90deg, #ffd700, #ff6b6b);
        }
      }

      .el-icon {
        margin-right: 10px;
        font-size: 18px;
        transition: transform 0.3s ease;
      }
    }
  }

  .head-user {
    margin-left: 30px;

    .el-dropdown-avatar {
      cursor: pointer;
      border: 3px solid rgba(255, 255, 255, 0.8);
      transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
      box-shadow: 0 4px 15px rgba(0,0,0,0.2);

      &:hover {
        transform: scale(1.15);
        border-color: #ffd700;
        box-shadow: 0 6px 20px rgba(255, 215, 0, 0.4);
      }
    }

    :deep(.el-badge__content) {
      animation: pulse 2s infinite;
    }
  }
}

@keyframes gradient-shift {
  0% { background-position: 0% 50%; }
  50% { background-position: 100% 50%; }
  100% { background-position: 0% 50%; }
}

@keyframes shimmer {
  0% { left: -100%; }
  100% { left: 100%; }
}

@keyframes pulse {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.2); }
}

@keyframes icon-pulse {
  0%, 100% {
    transform: scale(1);
    box-shadow: 0 4px 15px rgba(255, 215, 0, 0.4);
  }
  50% {
    transform: scale(1.05);
    box-shadow: 0 8px 25px rgba(255, 215, 0, 0.6);
  }
}

.student-main {
  background-color: #f5f7fa;
  min-height: calc(100vh - 70px);
}

@media screen and (max-width: 768px) {
  .student-header {
    height: auto !important;

    .header-content {
      flex-direction: column;
      padding: 10px 0;
    }

    .el-menu-title {
      width: 100%;
      display: flex;
      flex-wrap: wrap;

      .el-menu-item {
        flex: 1 0 50%;
        text-align: center;
        height: 50px;
        line-height: 50px;
      }
    }

    .head-user {
      margin: 10px 0 0;
    }
  }
}
</style>
