<template>
  <div class="app-wrapper">
    <div class="sidebar-container">
      <div class="sidebar-logo">
        <img src="@/assets/logo.png" alt="logo" class="logo-img">
        <span class="title">408master</span>
      </div>
      <el-menu
        :default-active="activeMenu"
        :collapse="isCollapse"
        background-color="#ffffff"
        text-color="#303133"
        :unique-opened="false"
        active-text-color="#1890ff"
        :collapse-transition="false"
        mode="vertical"
        router
      >
        <template v-for="route in menuRoutes" :key="route.path">
          <el-sub-menu v-if="route.children && route.children.length > 0 && route.alwaysShow" :index="route.path">
            <template #title>
              <span>{{ route.meta?.title || route.name }}</span>
            </template>
            <el-menu-item
              v-for="child in route.children.filter(c => !c.hidden)"
              :key="child.path"
              :index="route.path + '/' + child.path"
            >
              <span>{{ child.meta?.title || child.name }}</span>
            </el-menu-item>
          </el-sub-menu>
          <el-menu-item v-else :index="route.path">
            <span>{{ route.meta?.title || route.name }}</span>
          </el-menu-item>
        </template>
      </el-menu>
    </div>

    <div class="main-container">
      <div class="navbar">
        <div class="right-menu">
          <span>{{ userName }}</span>
          <el-button size="small" @click="logout">退出</el-button>
        </div>
      </div>
      <div class="app-main">
        <router-view />
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useUserStore } from '@/stores/user'
import { useAppStore } from '@/stores/app'
import router from '@/router'

const route = useRoute()
const vueRouter = useRouter()
const userStore = useUserStore()
const appStore = useAppStore()

const sidebar = computed(() => appStore.sidebar)
const userName = computed(() => userStore.userName || 'Admin')

const menuRoutes = computed(() => {
  const routes = []
  const allRoutes = router.options.routes || []
  
  allRoutes.forEach(r => {
    if (r.hidden || r.path === '/redirect' || r.path === '/login') {
      return
    }
    
    if (r.children && r.children.length > 0) {
      if (r.alwaysShow) {
        routes.push(r)
      } else if (r.path === '/') {
        r.children.forEach(child => {
          if (!child.hidden) {
            routes.push({ ...child, path: '/' + child.path })
          }
        })
      } else {
        r.children.forEach(child => {
          if (!child.hidden) {
            routes.push({ ...child, path: r.path + '/' + child.path })
          }
        })
      }
    } else {
      routes.push(r)
    }
  })
  
  return routes
})

const resolvePath = (routePath) => {
  if (routePath === '/') return ''
  return routePath
}

const activeMenu = computed(() => {
  const { meta, path } = route
  if (meta.activeMenu) {
    return meta.activeMenu
  }
  return path
})

const isCollapse = computed(() => !sidebar.value.opened)

const logout = () => {
  userStore.clearLogin()
  vueRouter.push('/login')
}
</script>

<style lang="scss" scoped>
.app-wrapper {
  display: flex;
  height: 100vh;
  width: 100%;
}

.sidebar-container {
  width: 210px;
  background: #fff;
  border-right: 1px solid #e8eaed;
  height: 100vh;
  position: fixed;
  overflow-y: auto;
  overflow-x: hidden;

  .sidebar-logo {
    height: 50px;
    line-height: 50px;
    padding: 0 16px;
    display: flex;
    align-items: center;
    border-bottom: 1px solid #e8eaed;

    .logo-img {
      width: 32px;
      height: 32px;
      margin-right: 8px;
    }

    .title {
      font-weight: 600;
      font-size: 16px;
    }
  }
}

.main-container {
  flex: 1;
  margin-left: 210px;
  display: flex;
  flex-direction: column;
  min-height: 100vh;
  max-width: calc(100vw - 210px);
  overflow-x: hidden;
}

.navbar {
  height: 50px;
  border-bottom: 1px solid #e8eaed;
  display: flex;
  align-items: center;
  justify-content: flex-end;
  padding: 0 20px;
  background: #fff;

  .right-menu {
    display: flex;
    align-items: center;
    gap: 12px;
  }
}

.app-main {
  flex: 1;
  padding: 20px;
  background: #f5f7fb;
  overflow-x: hidden;
}
</style>
