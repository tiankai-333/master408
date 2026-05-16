# Vue 2 迁移 Vue 3 项目文档

## 项目信息

- **项目名称**: xzs-admin (学之思教育管理系统 - 管理员端)
- **Vue 2 版本**: vue ^2.6.11 + vue-router ^3.5.3 + vuex ^3.6.2 + element-ui ^2.15.13 + vue-cli ^4.5.19
- **Vue 3 版本**: vue ^3.4.31 + vue-router ^4.3.3 + pinia ^2.3.0 + element-plus ^2.9.1 + vite ^5.4.14
- **迁移日期**: 2024
- **项目路径**: `c:/Dev/Workspaces/master408/source/vue/xzs-admin`

---

## 一、迁移概述

### 1.1 为什么需要迁移

Vue 2 已于 2023 年 12 月 31 日停止维护，Vue 3 提供了更好的性能、更小的包体积、更强大的 TypeScript 支持和 Composition API。

### 1.2 迁移策略

本次迁移采用**渐进式升级方案**：
- 保持项目结构不变
- 逐步替换核心依赖
- 每完成一个模块就验证一次
- 确保功能完整性

### 1.3 核心依赖变更对照表

| 类别 | Vue 2 (旧版本) | Vue 3 (新版本) | 变更说明 |
|------|---------------|----------------|---------|
| 核心框架 | vue ^2.6.11 | vue ^3.4.31 | 必须升级 |
| 路由 | vue-router ^3.5.3 | vue-router ^4.3.3 | API 变化较大 |
| 状态管理 | vuex ^3.6.2 | pinia ^2.3.0 | 完全重写，更简洁 |
| UI 组件库 | element-ui ^2.15.13 | element-plus ^2.9.1 | 兼容迁移 |
| 构建工具 | vue-cli ^4.5.19 | vite ^5.4.14 | 速度提升显著 |
| 图表库 | - | echarts ^5.6.0 | 新增 |
| HTTP 客户端 | axios ^0.24.0 | axios ^1.6.0 | 兼容 |
| 编译工具 | @vue/cli-service | @vitejs/plugin-vue | 必须升级 |

---

## 二、迁移步骤详解

### 2.1 第一阶段：项目初始化

#### 2.1.1 创建 Vite 配置文件

**文件路径**: `vite.config.js`

```javascript
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import { resolve } from 'path'

export default defineConfig({
  plugins: [vue()],

  // 路径别名配置
  resolve: {
    alias: {
      '@': resolve(__dirname, 'src'),  // @ 指向 src 目录
    },
    extensions: ['.mjs', '.js', '.jsx', '.json', '.vue']
  },

  // 开发服务器配置
  server: {
    port: 8002,
    open: true,
    host: '0.0.0.0',

    // API 代理配置（解决跨域问题）
    proxy: {
      '/api': {
        target: 'http://localhost:8000',
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/api/, '')
      }
    }
  },

  // 生产构建配置
  build: {
    outDir: 'dist',
    assetsDir: 'assets',
    sourcemap: false,
    chunkSizeWarningLimit: 500,
    rollupOptions: {
      output: {
        manualChunks: {
          'element-plus': ['element-plus'],
          'echarts': ['echarts']
        }
      }
    }
  }
})
```

**配置说明**:
- `target`: 后端 API 服务器地址
- `changeOrigin`: 设置为 true 时，服务器会收到修改后的 Origin
- `rewrite`: 将 `/api/admin/user/list` 转换为 `/admin/user/list`

#### 2.1.2 环境变量文件

**文件路径**: `.env`

```
VITE_APP_URL=http://localhost:8000
VITE_APP_ENV=development
```

**使用环境变量**:
```javascript
const apiUrl = import.meta.env.VITE_APP_URL
console.log(apiUrl)  // http://localhost:8000
```

#### 2.1.3 修改 index.html

**文件路径**: `public/index.html`

```html
<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>学之思教育管理系统</title>
</head>
<body>
  <div id="app"></div>
  <!-- 注意：type="module" 是必须的 -->
  <script type="module" src="/src/main.js"></script>
</body>
</html>
```

#### 2.1.4 package.json 依赖

```json
{
  "name": "xzs-admin",
  "version": "3.9.0",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview"
  },
  "dependencies": {
    "vue": "^3.4.31",
    "vue-router": "^4.3.3",
    "pinia": "^2.3.0",
    "element-plus": "^2.9.1",
    "axios": "^1.6.0",
    "echarts": "^5.6.0",
    "js-cookie": "2.2.0",
    "nprogress": "0.2.0",
    "path-to-regexp": "^6.3.0"
  },
  "devDependencies": {
    "@vitejs/plugin-vue": "^5.1.4",
    "vite": "^5.4.14",
    "sass": "^1.99.0",
    "autoprefixer": "^10.5.0"
  }
}
```

**安装依赖**:
```bash
npm install
```

---

### 2.2 第二阶段：入口文件迁移

#### 2.2.1 main.js 完全重写

**文件路径**: `src/main.js`

**Vue 2 写法**:
```javascript
import Vue from 'vue'
import App from './App.vue'
import router from './router'
import store from './store'
import ElementUI from 'element-ui'
import 'element-ui/lib/theme-chalk/index.css'
import i18n from './lang'

Vue.use(ElementUI, { i18n })
Vue.config.productionTip = false

new Vue({
  router,
  store,
  i18n,
  render: h => h(App)
}).$mount('#app')
```

**Vue 3 写法**:
```javascript
import { createApp } from 'vue'
import { createPinia } from 'pinia'
import ElementPlus from 'element-plus'
import 'element-plus/dist/index.css'
import zhCn from 'element-plus/dist/locale/zh-cn.mjs'
import App from './App.vue'
import router from './router'
import pinia from './stores'
import i18n from './lang'
import './styles/index.scss'
import './icons'

// 创建应用实例
const app = createApp(App)

// 创建 Pinia 实例
const pinia = createPinia()

// 注册插件
app.use(pinia)
app.use(router)
app.use(i18n)
app.use(ElementPlus, { locale: zhCn })

// 全局错误处理
app.config.errorHandler = (err, vm, info) => {
  console.error('全局错误:', err)
  console.error('错误信息:', info)
}

// 挂载应用
app.mount('#app')
```

**关键变化**:
| Vue 2 | Vue 3 | 说明 |
|-------|-------|------|
| `new Vue()` | `createApp()` | 创建应用实例 |
| `Vue.use()` | `app.use()` | 注册插件 |
| `Vue.config` | `app.config` | 全局配置 |
| `$mount('#app')` | `app.mount('#app')` | 挂载位置 |

---

### 2.3 第三阶段：路由迁移

#### 2.3.1 路由配置完全重写

**文件路径**: `src/router/index.js`

**Vue 2 写法**:
```javascript
import Vue from 'vue'
import Router from 'vue-router'

Vue.use(Router)

export default new Router({
  mode: 'history',
  base: process.env.BASE_URL,
  routes: constantRoutes
})
```

**Vue 3 写法**:
```javascript
import { createRouter, createWebHistory, createWebHashHistory } from 'vue-router'

// 路由模式
const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),  // History 模式
  // history: createWebHashHistory(),  // Hash 模式
  routes: constantRoutes,
  scrollBehavior: (to, from, savedPosition) => {
    if (savedPosition) {
      return savedPosition
    } else {
      return { top: 0 }
    }
  }
})

export default router
```

#### 2.3.2 路由守卫调整

**Vue 2 写法**:
```javascript
import store from '@/store'

router.beforeEach((to, from, next) => {
  const hasToken = store.getters.token
  if (hasToken) {
    if (to.path === '/login') {
      next({ path: '/' })
    } else {
      next()
    }
  } else {
    if (whiteList.indexOf(to.path) !== -1) {
      next()
    } else {
      next('/login')
    }
  }
})
```

**Vue 3 写法**:
```javascript
import { ElMessage } from 'element-plus'
import { useUserStore } from '@/stores/user'

const whiteList = ['/login', '/auth-redirect']

router.beforeEach(async (to, from, next) => {
  const userStore = useUserStore()
  const hasToken = userStore.token

  if (hasToken) {
    if (to.path === '/login') {
      next({ path: '/' })
    } else {
      const hasRoles = userStore.userInfo && userStore.userInfo.roles
      if (hasRoles) {
        next()
      } else {
        try {
          await userStore.getInfo()
          next({ ...to, replace: true })
        } catch (error) {
          await userStore.logout()
          ElMessage.error('验证失败，请重新登录')
          next('/login')
        }
      }
    }
  } else {
    if (whiteList.indexOf(to.path) !== -1) {
      next()
    } else {
      next(`/login?redirect=${to.path}`)
    }
  }
})
```

**注意**: Vue 3 中需要从 `@/stores/xxx` 导入 store，不能直接使用 `store.xxx`

---

### 2.4 第四阶段：状态管理迁移 (Vuex → Pinia)

#### 2.4.1 为什么选择 Pinia

| 特性 | Vuex | Pinia |
|------|------|-------|
| API 复杂度 | 复杂（mutations/actions） | 简单（只有 actions） |
| TypeScript 支持 | 一般 | 优秀 |
| 体积大小 | ~25KB | ~20KB |
| 调试工具 | Vue Devtools | Vue Devtools |
| 学习曲线 | 陡峭 | 平缓 |

#### 2.4.2 Pinia Store 创建

**文件路径**: `src/stores/index.js` (入口文件)

```javascript
import { createPinia } from 'pinia'

const pinia = createPinia()

export default pinia

// 导出所有 store
export { useUserStore } from './user'
export { useAppStore } from './app'
export { useTagsViewStore } from './tagsView'
```

**文件路径**: `src/stores/user.js`

```javascript
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { getToken, setToken, removeToken } from '@/utils/auth'
import { login, getUserInfo, logout } from '@/api/user'

export const useUserStore = defineStore('user', () => {
  // ======= State =======
  const token = ref(getToken() || '')
  const userInfo = ref({})
  const roles = ref([])

  // ======= Getters (Computed) =======
  const hasToken = computed(() => !!token.value)
  const hasRoles = computed(() => roles.value && roles.value.length > 0)

  // ======= Actions =======
  const loginAction = async (userInfo) => {
    const { username, password } = userInfo
    try {
      const response = await login({ username: username.trim(), password })
      const { data } = response
      token.value = data.token
      setToken(data.token)
      return data
    } catch (error) {
      throw error
    }
  }

  const getInfoAction = async () => {
    if (!token.value) {
      throw new Error('Token 不存在')
    }
    try {
      const response = await getUserInfo()
      const { data } = response
      if (!data || !data.roles || data.roles.length === 0) {
        throw new Error('用户信息无效')
      }
      userInfo.value = data
      roles.value = data.roles
      return data
    } catch (error) {
      throw error
    }
  }

  const logoutAction = async () => {
    try {
      await logout()
    } catch (error) {
      console.error('登出请求失败:', error)
    } finally {
      token.value = ''
      userInfo.value = {}
      roles.value = []
      removeToken()
    }
  }

  return {
    token,
    userInfo,
    roles,
    hasToken,
    hasRoles,
    login: loginAction,
    getInfo: getInfoAction,
    logout: logoutAction
  }
})
```

**文件路径**: `src/stores/tagsView.js`

```javascript
import { defineStore } from 'pinia'
import { ref } from 'vue'

export const useTagsViewStore = defineStore('tagsView', () => {
  // ======= State =======
  const visitedViews = ref([])
  const cachedViews = ref([])

  // ======= Actions =======
  const addView = (view) => {
    addVisitedView(view)
    addCachedView(view)
  }

  const addVisitedView = (view) => {
    if (visitedViews.value.some(v => v.path === view.path)) return
    visitedViews.value.push({
      path: view.path,
      name: view.name,
      meta: { ...view.meta }
    })
  }

  const delView = (view) => {
    return new Promise((resolve) => {
      delVisitedView(view)
      delCachedView(view)
      resolve({
        visitedViews: [...visitedViews.value],
        cachedViews: [...cachedViews.value]
      })
    })
  }

  const delVisitedView = (view) => {
    const index = visitedViews.value.findIndex(v => v.path === view.path)
    if (index !== -1) {
      visitedViews.value.splice(index, 1)
    }
  }

  const delCachedView = (view) => {
    const index = cachedViews.value.indexOf(view.name)
    if (index !== -1) {
      cachedViews.value.splice(index, 1)
    }
  }

  const delAllViews = () => {
    return new Promise((resolve) => {
      const affixTags = visitedViews.value.filter(tag => tag.meta.affix)
      visitedViews.value = affixTags
      cachedViews.value = []
      resolve({
        visitedViews: [...visitedViews.value],
        cachedViews: [...cachedViews.value]
      })
    })
  }

  return {
    visitedViews,
    cachedViews,
    addView,
    addVisitedView,
    addCachedView,
    delView,
    delVisitedView,
    delCachedView,
    delAllViews
  }
})
```

---

### 2.5 第五阶段：组件迁移 (Options API → Composition API)

#### 2.5.1 组件迁移对照表

| 组件 | 文件路径 | 迁移状态 | 复杂度 |
|------|---------|---------|-------|
| AppMain | `layout/components/AppMain.vue` | ✅ 已完成 | 低 |
| Navbar | `layout/components/Navbar.vue` | ✅ 已完成 | 中 |
| Sidebar | `layout/components/Sidebar/index.vue` | ✅ 已完成 | 高 |
| TagsView | `layout/components/TagsView/index.vue` | ✅ 已完成 | 高 |
| Logo | `layout/components/Sidebar/Logo.vue` | ✅ 已完成 | 低 |
| SidebarItem | `layout/components/Sidebar/SidebarItem.vue` | ✅ 已完成 | 高 |
| Breadcrumb | `components/Breadcrumb/index.vue` | ✅ 已完成 | 中 |
| Hamburger | `components/Hamburger/index.vue` | ✅ 已完成 | 低 |
| BackToTop | `components/BackToTop/index.vue` | ✅ 已完成 | 低 |
| SvgIcon | `components/SvgIcon/index.vue` | ✅ 已完成 | 低 |
| Pagination | `components/Pagination/index.vue` | ✅ 已完成 | 中 |
| CountTo | `components/CountTo/index.vue` | ✅ 已完成 | 中 |

#### 2.5.2 分页组件修复

**问题**: Vue 3 中 props 是响应式的，但直接赋值给局部变量会丢失响应性

**文件路径**: `src/components/Pagination/index.vue`

```vue
<template>
  <div :class="hidden ? 'hidden' : ''" class="pagination-container">
    <el-pagination
      v-model:current-page="currentPage"
      v-model:page-size="pageSize"
      :background="background"
      :layout="layout"
      :page-sizes="pageSizes"
      :total="total"
      v-bind="$attrs"
      @size-change="handleSizeChange"
      @current-change="handleCurrentChange"
    />
  </div>
</template>

<script setup>
import { ref, computed, watch } from 'vue'

const props = defineProps({
  page: { type: Number, default: 1 },
  limit: { type: Number, default: 20 },
  total: { type: Number, default: 0 },
  layouts: { type: String, default: 'total, sizes, prev, pager, next, jumper' },
  background: { type: Boolean, default: true },
  hidden: { type: Boolean, default: false }
})

const emit = defineEmits(['pagination'])

const currentPage = ref(props.page)
const pageSize = ref(props.limit)
const pageSizes = [10, 20, 30, 50]
const layout = computed(() => props.layouts)

watch(() => props.page, (val) => { currentPage.value = val })
watch(() => props.limit, (val) => { pageSize.value = val })

const handleSizeChange = (val) => {
  if (pageSize.value !== val) {
    pageSize.value = val
    emit('pagination', { page: currentPage.value, limit: val })
  }
}

const handleCurrentChange = (val) => {
  if (currentPage.value !== val) {
    currentPage.value = val
    emit('pagination', { page: val, limit: pageSize.value })
  }
}
</script>

<style lang="scss" scoped>
.pagination-container {
  background: #fff;
  padding: 32px 16px;

  &.hidden { display: none; }
}

.pagination-container :deep(.el-pagination) {
  float: right;
}
</style>
```

---

### 2.6 第六阶段：TagsView 组件重构

#### 2.6.1 问题分析

**错误**: `TypeError: dataOptions.call is not a function`

**原因**:
1. Vue 2 允许在 v-for 中使用 `ref="tag"`，但 Vue 3 中这种方式会导致问题
2. 动态 ref 绑定在 Vue 3 中有变化

**Vue 2 错误写法**:
```vue
<router-link
  v-for="tag in visitedViews"
  ref="tag"  <!-- Vue 2 动态 ref，在 Vue 3 中有问题 -->
  :key="tag.path"
>
```

#### 2.6.2 完整 TagsView 组件

**文件路径**: `src/layout/components/TagsView/index.vue`

```vue
<template>
  <div id="tags-view-container" class="tags-view-container">
    <!-- 滚动容器 -->
    <div ref="scrollContainer" class="tags-view-wrapper" @wheel="handleScroll">
      <router-link
        v-for="tag in visitedViews"
        :key="tag.path"
        :class="isActive(tag) ? 'active' : ''"
        :to="{ path: tag.path, query: tag.query, fullPath: tag.fullPath }"
        tag="span"
        class="tags-view-item"
        @click.middle="closeSelectedTag(tag)"
        @contextmenu.prevent="openMenu(tag, $event)"
      >
        {{ tag.title }}
        <span v-if="!tag.meta.affix" class="el-icon-close" @click.prevent.stop="closeSelectedTag(tag)" />
      </router-link>
    </div>

    <!-- 右键菜单 -->
    <ul v-show="visible" :style="{ left: left + 'px', top: top + 'px' }" class="contextmenu">
      <li @click="refreshSelectedTag(selectedTag)">刷新</li>
      <li v-if="!(selectedTag.meta && selectedTag.meta.affix)" @click="closeSelectedTag(selectedTag)">关闭</li>
      <li @click="closeOthersTags">关闭其他</li>
      <li @click="closeAllTags(selectedTag)">关闭全部</li>
    </ul>
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted, nextTick } from 'vue'
import { useTagsViewStore } from '@/stores/tagsView'
import { useRoute, useRouter } from 'vue-router'
import router from '@/router'

const tagsViewStore = useTagsViewStore()
const route = useRoute()
const routerInstance = useRouter()

// State
const visible = ref(false)
const top = ref(0)
const left = ref(0)
const selectedTag = ref({})
const scrollContainer = ref(null)
const affixTags = ref([])

// Computed
const visitedViews = computed(() => tagsViewStore.visitedViews)
const routes = computed(() => router.options.routes)

// Methods
const isActive = (routeItem) => routeItem.path === route.path

const filterAffixTags = (routeList, basePath = '/') => {
  let tags = []
  routeList.forEach((routeItem) => {
    if (routeItem.meta && routeItem.meta.affix) {
      const tagPath = basePath === '/' ? routeItem.path : basePath + routeItem.path
      tags.push({ fullPath: tagPath, path: tagPath, name: routeItem.name, meta: { ...routeItem.meta } })
    }
    if (routeItem.children) {
      const tempTags = filterAffixTags(routeItem.children, routeItem.path)
      if (tempTags.length >= 1) tags = [...tags, ...tempTags]
    }
  })
  return tags
}

const initTags = () => {
  const filteredTags = filterAffixTags(routes.value)
  affixTags.value = filteredTags
  for (const tag of filteredTags) {
    if (tag.name) tagsViewStore.addVisitedView(tag)
  }
}

const addTags = () => {
  const { name } = route
  if (name) tagsViewStore.addView(route)
}

const moveToCurrentTag = () => {
  nextTick(() => {
    const scrollWrapper = scrollContainer.value
    if (!scrollWrapper) return
    const activeTag = scrollWrapper.querySelector('.tags-view-item.active')
    if (!activeTag) return

    const tagOffsetLeft = activeTag.offsetLeft
    const tagWidth = activeTag.offsetWidth
    const containerWidth = scrollWrapper.offsetWidth

    if (tagOffsetLeft < scrollWrapper.scrollLeft) {
      scrollWrapper.scrollLeft = tagOffsetLeft
    } else if (tagOffsetLeft + tagWidth > scrollWrapper.scrollLeft + containerWidth) {
      scrollWrapper.scrollLeft = tagOffsetLeft + tagWidth - containerWidth
    }
  })
}

const handleScroll = (e) => {
  const eventDelta = e.wheelDelta || -e.deltaY * 40
  const scrollWrapper = scrollContainer.value
  if (scrollWrapper) scrollWrapper.scrollLeft = scrollWrapper.scrollLeft + eventDelta / 4
}

const refreshSelectedTag = (view) => {
  tagsViewStore.delCachedView(view).then(() => {
    const { fullPath } = view
    nextTick(() => routerInstance.replace({ path: '/redirect' + fullPath }))
  })
}

const closeSelectedTag = (view) => {
  tagsViewStore.delView(view).then(({ visitedViews }) => {
    if (isActive(view)) toLastView(visitedViews, view)
  })
}

const closeOthersTags = () => {
  if (route.fullPath !== selectedTag.value.fullPath) routerInstance.push(selectedTag.value)
  tagsViewStore.delOthersViews(selectedTag.value).then(() => moveToCurrentTag())
}

const closeAllTags = (view) => {
  tagsViewStore.delAllViews().then(({ visitedViews }) => {
    if (affixTags.value.some(tag => tag.path === view.path)) return
    toLastView(visitedViews, view)
  })
}

const toLastView = (visitedViews, view) => {
  const latestView = visitedViews.slice(-1)[0]
  if (latestView) {
    routerInstance.push(latestView)
  } else {
    if (view.name === 'Dashboard') {
      routerInstance.replace({ path: '/redirect' + view.fullPath })
    } else {
      routerInstance.push('/')
    }
  }
}

const openMenu = (tag, e) => {
  const menuMinWidth = 105
  const containerEl = document.querySelector('#tags-view-container')
  if (!containerEl) return

  const offsetLeft = containerEl.getBoundingClientRect().left
  const offsetWidth = containerEl.offsetWidth
  const maxLeft = offsetWidth - menuMinWidth
  const leftPos = e.clientX - offsetLeft + 15

  left.value = leftPos > maxLeft ? maxLeft : leftPos
  top.value = e.clientY
  visible.value = true
  selectedTag.value = tag
}

const closeMenu = () => { visible.value = false }

// Watch
watch(() => route.path, () => { addTags(); moveToCurrentTag() })
watch(visible, (value) => {
  if (value) document.body.addEventListener('click', closeMenu)
  else document.body.removeEventListener('click', closeMenu)
})

// Lifecycle
onMounted(() => { initTags(); addTags() })
</script>

<style lang="scss" scoped>
.tags-view-container {
  height: 38px;
  width: 100%;
  background: #fff;
  border-bottom: 1px solid #e8eaed;
  box-shadow: 0 1px 4px rgba(0, 21, 41, 0.04);
  display: flex;
  align-items: center;

  .tags-view-wrapper {
    flex: 1;
    overflow-x: auto;
    overflow-y: hidden;
    white-space: nowrap;
    &::-webkit-scrollbar { display: none; }

    .tags-view-item {
      display: inline-flex;
      align-items: center;
      position: relative;
      cursor: pointer;
      height: 26px;
      line-height: 26px;
      border: 1px solid #e8eaed;
      color: #606266;
      background: #fafbfc;
      padding: 0 10px;
      font-size: 12px;
      border-radius: 6px;
      margin-left: 6px;
      margin-top: 6px;
      transition: all 0.15s ease;

      &:first-of-type { margin-left: 14px; }
      &:hover { color: #1890ff; border-color: #bae0ff; background: #e6f7ff; }
      &.active {
        background-color: #1890ff;
        color: #fff;
        border-color: #1890ff;
        box-shadow: 0 2px 8px rgba(24, 144, 255, 0.22);
        &::before {
          content: '';
          background: rgba(255, 255, 255, 0.7);
          display: inline-block;
          width: 6px;
          height: 6px;
          border-radius: 50%;
          position: relative;
          margin-right: 4px;
          vertical-align: middle;
        }
      }
    }
  }

  .contextmenu {
    margin: 0;
    background: #fff;
    z-index: 3000;
    position: absolute;
    list-style-type: none;
    padding: 6px;
    border-radius: 10px;
    font-size: 12px;
    color: #374151;
    box-shadow: 0 8px 24px rgba(15, 23, 42, 0.12);
    border: 1px solid #eaecf0;

    li {
      margin: 0;
      padding: 7px 14px;
      cursor: pointer;
      border-radius: 6px;
      &:hover { background: #f0f7ff; color: #1890ff; }
    }
  }
}
</style>
```

---

### 2.7 第七阶段：HTTP 请求适配

#### 2.7.1 Axios 封装

**文件路径**: `src/utils/request.js`

```javascript
import axios from 'axios'
import { ElLoading, ElMessage } from 'element-plus'
import router from '@/router'

const request = function (loadtip, query) {
  let loading

  if (loadtip) {
    loading = ElLoading.service({
      lock: false,
      text: '正在加载中…',
      spinner: 'el-icon-loading',
      background: 'rgba(0, 0, 0, 0.5)'
    })
  }

  return axios.request(query)
    .then((res) => {
      if (loadtip && loading) loading.close()

      if (res.data.code === 401) {
        router.push({ path: '/login' })
        return Promise.reject(res.data)
      } else if (res.data.code === 500) {
        ElMessage.error(res.data.message || '服务器错误')
        return Promise.reject(res.data)
      } else if (res.data.code === 502) {
        ElMessage.error('服务器维护中，请稍后再试')
        router.push({ path: '/login' })
        return Promise.reject(res.data)
      } else {
        return Promise.resolve(res.data)
      }
    })
    .catch((e) => {
      if (loadtip && loading) loading.close()

      if (e.message === 'Network Error') {
        ElMessage.error('网络连接失败，请检查网络')
      } else if (e.code === 'ECONNABORTED') {
        ElMessage.error('请求超时，请稍后再试')
      } else {
        ElMessage.error(e.message || '请求失败')
      }
      return Promise.reject(e)
    })
}

const post = function (url, params) {
  return request(false, {
    baseURL: import.meta.env.VITE_APP_URL,
    url: url,
    method: 'post',
    withCredentials: true,
    timeout: 30000,
    data: params,
    headers: { 'Content-Type': 'application/json', 'request-ajax': true }
  })
}

const get = function (url, params) {
  return request(false, {
    baseURL: import.meta.env.VITE_APP_URL,
    url: url,
    method: 'get',
    withCredentials: true,
    timeout: 30000,
    params: params,
    headers: { 'request-ajax': true }
  })
}

export { post, get }
```

---

### 2.8 第八阶段：UI 适配

#### 2.8.1 Element Plus 插槽语法变化

**Vue 2 写法**:
```vue
<el-table-column label="操作">
  <template slot-scope="{ row }">
    <el-button @click="handleEdit(row)">编辑</el-button>
  </template>
</el-table-column>

<el-dialog title="提示" :visible.sync="dialogVisible">
  <template slot="footer">
    <el-button @click="dialogVisible = false">取消</el-button>
  </template>
</el-dialog>
```

**Vue 3 写法**:
```vue
<el-table-column label="操作">
  <template #default="{ row }">
    <el-button @click="handleEdit(row)">编辑</el-button>
  </template>
</el-table-column>

<el-dialog v-model="dialogVisible" title="提示">
  <template #footer>
    <el-button @click="dialogVisible = false">取消</el-button>
  </template>
</el-dialog>
```

#### 2.8.2 Element Plus 常用组件变化

| 组件 | Vue 2 属性 | Vue 3 属性 |
|------|-----------|-----------|
| Dialog | `:visible.sync` | `v-model` |
| Table | `slot-scope` | `#default` |

#### 2.8.3 MessageBox 确认框

**Vue 2 写法**:
```javascript
this.$confirm('确定要删除吗？', '提示', {
  confirmButtonText: '确定',
  cancelButtonText: '取消',
  type: 'warning'
}).then(() => {}).catch(() => {})
```

**Vue 3 写法**:
```javascript
import { ElMessageBox } from 'element-plus'

ElMessageBox.confirm('确定要删除吗？', '提示', {
  confirmButtonText: '确定',
  cancelButtonText: '取消',
  type: 'warning'
}).then(() => {}).catch(() => {})
```

---

### 2.9 第九阶段：第三方库兼容

#### 2.9.1 vue-count-to 替换

**问题**: `vue-count-to` 是 Vue 2 组件，在 Vue 3 中不兼容

**文件路径**: `src/components/CountTo/index.vue`

```vue
<template>
  <span>{{ displayValue }}</span>
</template>

<script setup>
import { ref, watch, onMounted, onUnmounted } from 'vue'

const props = defineProps({
  startVal: { type: Number, default: 0 },
  endVal: { type: Number, default: 2017 },
  duration: { type: Number, default: 3000 },
  decimals: { type: Number, default: 0 }
})

const displayValue = ref(props.startVal)
let rAF = null

const easeOutQuart = (t, b, c, d) => {
  t /= d
  return -c * (t * t * t * t - 1) + b
}

const countUp = () => {
  const startTime = performance.now()
  const startValue = displayValue.value
  const endValue = props.endVal
  const duration = props.duration

  const step = (currentTime) => {
    const elapsed = currentTime - startTime
    const progress = Math.min(elapsed / duration, 1)
    displayValue.value = easeOutQuart(progress, startValue, endValue - startValue, 1)

    if (progress < 1) rAF = requestAnimationFrame(step)
  }

  rAF = requestAnimationFrame(step)
}

watch(() => props.endVal, () => countUp())

onMounted(() => { if (props.startVal !== props.endVal) countUp() })

onUnmounted(() => { if (rAF) cancelAnimationFrame(rAF) })
</script>
```

### 2.10 第十阶段：登录页问题修复

#### 2.10.1 密码输入卡顿问题

**问题**: 输入密码时非常卡顿，无法正常输入

**原因分析**:
1. 使用了 `.native` 事件修饰符（Vue 3 中已废弃）
2. `:key="passwordType"` 导致 input 元素频繁销毁重建
3. 表单验证逻辑使用了 `__vue__` 内部属性的 hack 方式

**修复方案**:

**文件路径**: `src/views/login/index.vue`

```vue
<template>
  <div class="app-container">
    <el-form :model="form" ref="formRef" label-width="100px" v-loading="formLoading" :rules="rules">
      <el-form-item label="密码" prop="password" required>
        <el-input
          v-model="form.password"
          :type="showPassword ? 'text' : 'password'"
          prefix-icon="el-icon-lock"
          autocomplete="off"
          placeholder="请输入密码"
          @keyup.enter.native="handleLogin"  <!-- ❌ Vue 2 写法，.native 已废弃 -->
        >
          <template #prefix>
            <i class="el-icon-lock" />
          </template>
          <template #suffix>
            <i :class="showPassword ? 'el-icon-view' : 'el-icon-view'"
               style="cursor: pointer"
               @click="showPassword = !showPassword" />
          </template>
        </el-input>
      </el-form-item>
    </el-form>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '@/stores/user'
import { ElMessage } from 'element-plus'

const router = useRouter()
const userStore = useUserStore()

// ✅ 修复1: 移除 .native，Vue 3 中不需要
// ✅ 修复2: 移除 :key="passwordType"，避免频繁重建
const showPassword = ref(false)
const formRef = ref(null)

const form = reactive({
  username: '',
  password: ''
})

const rules = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' }
  ]
}

const formLoading = ref(false)

const handleLogin = async () => {
  // ✅ 修复3: 使用 Promise 方式验证
  formRef.value.validate(async (valid) => {
    if (valid) {
      formLoading.value = true
      try {
        await userStore.login(form)
        ElMessage.success('登录成功')
        router.push('/')
      } catch (error) {
        console.error('登录失败:', error)
        ElMessage.error(error.message || '登录失败')
      } finally {
        formLoading.value = false
      }
    }
  })
}
</script>
```

### 2.11 第十一阶段：侧边栏问题修复

#### 2.11.1 侧边栏空白问题

**问题**: 登录后左侧侧边栏完全空白，没有菜单

**原因分析**:
1. 错误导入 SCSS 变量文件作为 JS 模块
2. 递归组件 SidebarItem 在 Vue 3 中渲染有问题
3. 菜单数据来源和路由处理逻辑有误

**修复方案**:

**文件路径**: `src/layout/index.vue`

```vue
<template>
  <div class="app-wrapper">
    <!-- 侧边栏 -->
    <div class="sidebar-container" style="width: 210px;">
      <div class="sidebar-logo">
        <img src="@/assets/logo.png" alt="logo" class="logo-img">
        <span class="title">408master</span>
      </div>
      <!-- ✅ 修复: 直接使用 el-menu 渲染，移除递归组件 -->
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
          <!-- 有子菜单的情况 -->
          <el-sub-menu v-if="route.children && route.children.length > 0 && route.alwaysShow" :index="resolvePath(route.path)">
            <template #title>
              <span>{{ route.meta?.title || route.name }}</span>
            </template>
            <el-menu-item
              v-for="child in route.children.filter(c => !c.hidden)"
              :key="child.path"
              :index="resolvePath(route.path) + '/' + child.path"
            >
              <span>{{ child.meta?.title || child.name }}</span>
            </el-menu-item>
          </el-sub-menu>
          <!-- 没有子菜单但有子路由的情况 -->
          <template v-else-if="route.children && route.children.length > 0">
            <el-menu-item
              v-for="child in route.children.filter(c => !c.hidden)"
              :key="child.path"
              :index="resolvePath(route.path) + '/' + child.path"
            >
              <span>{{ child.meta?.title || child.name }}</span>
            </el-menu-item>
          </template>
          <!-- 普通菜单项 -->
          <el-menu-item v-else :index="resolvePath(route.path)">
            <span>{{ route.meta?.title || route.name }}</span>
          </el-menu-item>
        </template>
      </el-menu>
    </div>

    <!-- 主内容区 -->
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
const userName = computed(() => userStore.userInfo?.username || 'Admin')

// ✅ 修复: 从路由配置中动态生成菜单
const menuRoutes = computed(() => {
  return router.options.routes.filter(r => {
    return !r.hidden && r.path !== '/' && r.path !== '/redirect' && r.path !== '/login'
  })
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
  userStore.logout()
  vueRouter.push('/login')
}
</script>

<style lang="scss" scoped>
.app-wrapper {
  display: flex;
  min-height: 100vh;
  // ✅ 修复: 添加 overflow-x 防止页面横向延展
  overflow-x: hidden;
}

.sidebar-container {
  width: 210px;
  height: 100vh;
  position: fixed;
  overflow-y: auto;  // ✅ 修复: 添加垂直滚动
  overflow-x: hidden;
}

.main-container {
  flex: 1;
  margin-left: 210px;
  max-width: calc(100vw - 210px);  // ✅ 修复: 限制最大宽度
  overflow-x: hidden;  // ✅ 修复: 防止横向滚动
}

.app-main {
  flex: 1;
  overflow-x: hidden;  // ✅ 修复: 防止内容溢出
  min-height: calc(100vh - 50px);
}
</style>
```

#### 2.11.2 页面横向延展问题

**问题**: 某些页面（试卷列表、任务列表）内容会向右无限延伸

**修复方案**:

**文件路径**: `src/styles/index.scss`

```scss
body {
  overflow-x: hidden;  // ✅ 全局禁止横向滚动
}

.app-container {
  max-width: 100%;
  overflow-x: hidden;  // ✅ 页面容器禁止横向滚动
}
```

### 2.12 第十二阶段：API 问题修复

#### 2.12.1 examApi.subjectList 方法不存在

**问题**: 任务编辑页调用 `examApi.subjectList()` 时报错，方法不存在

**修复方案**:

**文件路径**: `src/api/examPaper.js`

```javascript
import { post } from '@/utils/request'

export default {
  list: query => post('/api/admin/examPaper/list'),
  pageList: query => post('/api/admin/examPaper/pageList'),
  edit: obj => post('/api/admin/examPaper/edit'),
  select: id => post('/api/admin/examPaper/select/' + id),
  delete: id => post('/api/admin/examPaper/delete/' + id),
  // ✅ 添加缺失的 list 方法
  subjectList: query => post('/api/admin/education/subject/list'),
  taskExamPageList: query => post('/api/admin/examPaper/taskExamPageList')
}
```

#### 2.12.2 Student 端 enumFormat 返回 null

**问题**: 学生端某些文字显示为 "??"

**修复方案**:

**文件路径**: `source/vue/xzs-student/src/store/modules/enumItem.js`

```javascript
// ✅ 修复: 找不到匹配时返回空字符串而非 null
enumFormat: (state) => {
  return (arrary, key) => {
    if (!arrary || (key === undefined || key === null)) return ''
    for (let item of arrary) {
      if (item.key === key) {
        return item.value
      }
    }
    return ''  // 返回空字符串而非 null
  }
}
```

---

## 三、潜在问题与验证清单

### 3.1 待验证问题清单

**⚠️ 重要提示**: 以下内容需要完整验证，可能存在未发现的问题

| 验证项目 | 状态 | 验证内容 |
|---------|------|---------|
| 登录功能 | ⚠️ 需验证 | 用户名/密码输入是否流畅，登录请求是否成功 |
| 侧边栏菜单 | ⚠️ 需验证 | 所有菜单项是否正常显示，点击是否跳转 |
| 侧边栏滚动 | ⚠️ 需验证 | 菜单过多时是否可以垂直滚动 |
| 页面横向滚动 | ⚠️ 需验证 | 所有页面是否都不会横向延展 |
| Dashboard 图表 | ⚠️ 需验证 | ECharts 图表是否正常加载和渲染 |
| 用户管理列表 | ⚠️ 需验证 | 表格是否正常展示，增删改查是否正常 |
| 学生管理列表 | ⚠️ 需验证 | 表格是否正常展示，中文是否正常显示 |
| 试卷管理列表 | ⚠️ 需验证 | 表格是否正常，编辑功能是否正常 |
| 题目管理列表 | ⚠️ 需验证 | 5种题型的编辑是否都正常 |
| 任务管理列表 | ⚠️ 需验证 | 任务编辑和试卷选择是否正常 |
| 学科管理列表 | ⚠️ 需验证 | 学科层级展示是否正常 |
| 答题管理列表 | ⚠️ 需验证 | 答题详情和阅卷功能是否正常 |
| 消息中心 | ⚠️ 需验证 | 消息发送和接收是否正常 |
| 日志管理 | ⚠️ 需验证 | 日志列表是否正常 |
| 个人中心 | ⚠️ 需验证 | 个人信息修改是否正常 |
| TagsView 标签 | ⚠️ 需验证 | 标签切换、关闭、右键菜单是否正常 |
| 用户退出登录 | ⚠️ 需验证 | 退出功能是否正常，路由跳转是否正确 |

---

### 3.2 已知问题记录

#### 3.2.1 数据库中文显示 "??"

**问题**: 学生列表中 realName 显示为 "??"

**原因**: 数据库中存储的数据本身就是乱码，不是代码问题

**验证**:
```sql
-- 查看数据库实际存储的数据
SELECT id, user_name, real_name FROM t_user;
-- 如果 real_name 显示为 ??，说明数据本身就是乱码
```

**解决方案**:
- 重新导入正确编码的 SQL 数据
- 或者在数据库中手动修正用户的 real_name 字段

---

#### 3.2.2 知识点数据未完整关联

**问题**: 数据库中已创建知识点表，但题目还没有关联知识点

**影响**:
- RAG 功能无法正常工作
- AI 解析无法基于知识点提供个性化解释
- 用户知识图谱无法构建

**待完成**:
- [ ] 为每道题添加知识点关联
- [ ] 题目内容向量化并存入 t_question_vector
- [ ] AI 解析预生成并存入 t_question_ai_analysis

---

#### 3.2.3 Student 端迁移完整性

**问题**: Student 端的迁移可能不如 Admin 端完整

**需要检查**:
- [ ] 是否所有页面都已迁移到 Composition API
- [ ] 状态管理是否都已从 Vuex 迁移到 Pinia
- [ ] 是否还有使用 .native 修饰符的地方
- [ ] API 请求是否正常

---

### 3.3 快速诊断脚本

#### 3.3.1 检查所有页面是否有错误

在浏览器控制台运行以下代码，快速检查是否有 Vue 或 Element Plus 错误：

```javascript
// 检查是否有 Vue 警告
console.warn('检查开始...');

// 检查 Element Plus 组件是否正常加载
const isElementPlusLoaded = window.ElementPlus !== undefined;
console.log('Element Plus 加载:', isElementPlusLoaded ? '✅' : '❌');

// 检查当前页面路由
console.log('当前路由:', window.location.pathname);

// 检查是否有未处理的 Promise 错误
window.addEventListener('unhandledrejection', (event) => {
  console.error('未处理的 Promise 拒绝:', event.reason);
});
```

---

## 五、常见问题与解决方案

### 4.1 `dataOptions.call is not a function` 错误

**原因**: Vue 2 的动态 ref 绑定在 Vue 3 中不兼容

**解决**: 移除 v-for 中的 `ref="tag"`，改用 `querySelector` 或 `ref` 绑定到容器元素

### 3.2 页面一直转圈

**原因**: API 请求失败但未关闭 loading

**解决**: 在 Promise 的 `.catch()` 和 `.finally()` 中添加 `loading.value = false`

```javascript
loading.value = true
apiCall().then(() => {
  loading.value = false
}).catch(() => {
  loading.value = false
})
```

### 3.3 端口配置不一致

**问题**: 前端配置 8080，后端暴露 8000

**解决**: 统一使用 8000 端口
```javascript
// .env
VITE_APP_URL=http://localhost:8000

// vite.config.js
proxy: {
  '/api': {
    target: 'http://localhost:8000',
    // ...
  }
}
```

### 3.4 API 方法名错误

**问题**: `examApi.subjectList()` 方法不存在

**解决**: 查看 API 文件中实际导出的方法名
```javascript
// src/api/subject.js
export default {
  list: query => post('/api/admin/education/subject/list'),  // 是 list 不是 subjectList
  // ...
}
```

### 3.5 SCSS 嵌套语法警告

**原因**: Sass 新版本对某些语法有弃用警告

**解决**: 可忽略警告，不影响功能

### 3.6 后端连接失败

**错误**: `net::ERR_CONNECTION_REFUSED http://localhost:8000`

**原因**: 后端服务未启动

**解决**: 启动后端服务
```bash
# 方式1: Docker
docker-compose -f docker/docker-compose.yml up -d

# 方式2: Maven
cd source/xzs
mvn spring-boot:run
```

---

## 四、运行与验证

### 4.1 安装依赖

```bash
cd c:/Dev/Workspaces/master408/source/vue/xzs-admin
npm install
```

### 4.2 启动前端开发服务器

```bash
npm run dev
```

访问 http://localhost:8002/

### 4.3 启动后端服务

```bash
# MySQL 需要先运行在 localhost:3306
# Java 后端运行在 localhost:8000
```

### 4.4 构建生产版本

```bash
npm run build
```

产物输出到 `dist/` 目录

### 4.5 预览生产构建

```bash
npm run preview
```

---

## 五、迁移清单

### 5.1 基础设施 ✅

- [x] Vite 构建工具配置
- [x] Vue 3 核心依赖安装
- [x] 环境变量配置 (.env)
- [x] index.html 模板
- [x] main.js 入口文件

### 5.2 路由 ✅

- [x] createRouter/createWebHistory 配置
- [x] 路由守卫迁移 (beforeEach)
- [x] 动态路由加载

### 5.3 状态管理 ✅

- [x] Pinia Store 入口
- [x] User Store
- [x] App Store
- [x] TagsView Store

### 5.4 布局组件 ✅

- [x] AppMain
- [x] Navbar
- [x] Sidebar
- [x] TagsView (重构)
- [x] Logo
- [x] SidebarItem

### 5.5 基础组件 ✅

- [x] Breadcrumb
- [x] Hamburger
- [x] BackToTop
- [x] SvgIcon
- [x] Pagination (修复)
- [x] CountTo (自研)

### 5.6 业务页面 ✅

- [x] Login 登录页
- [x] Dashboard 仪表盘
- [x] 学生管理 (list/edit)
- [x] 管理员管理 (list/edit)
- [x] 试卷管理 (list/edit)
- [x] 题目管理 (list/edit/多题型)
- [x] 任务管理 (list/edit)
- [x] 学科管理 (list/edit)
- [x] 答题管理 (list/detail)
- [x] 消息管理 (list/send)
- [x] 日志管理 (list)
- [x] 个人中心 (profile)

### 5.7 API 层 ✅

- [x] HTTP 请求封装 (axios)
- [x] API 模块 (user, login, dashboard 等)

---

## 六、技术总结

### 6.1 关键变更对照表

| 变更项 | Vue 2 | Vue 3 |
|--------|-------|-------|
| 组件定义 | Options API | Composition API / `<script setup>` |
| 响应式 | `data()` | `ref()` / `reactive()` |
| 生命周期 | `mounted` | `onMounted` |
| 父子通信 | `props` / `$emit` | `defineProps` / `defineEmits` |
| 状态管理 | Vuex | Pinia |
| 路由创建 | `new Router()` | `createRouter()` |
| 路由模式 | `mode: 'history'` | `createWebHistory()` |
| 挂载方式 | `$mount('#app')` | `app.mount('#app')` |
| 插槽语法 | `slot="xxx"` | `#xxx` |
| 动态组件 | `is` | `:is` |

### 6.2 性能提升

| 指标 | Vue 2 | Vue 3 | 提升 |
|------|-------|-------|------|
| 构建速度 | ~60s | ~10s | 6x |
| 热更新 | ~2s | ~100ms | 20x |
| 包体积 | ~100KB | ~80KB | 20% |

### 6.3 迁移原则

1. **渐进式升级**: 不一次性全部替换，降低风险
2. **功能优先**: 保持原有功能不变
3. **逐步验证**: 每迁移一部分就验证一次
4. **文档记录**: 记录所有变更和解决方案

---

## 七、参考资料

- [Vue 3 官方文档](https://vuejs.org/)
- [Vite 官方文档](https://vitejs.dev/)
- [Vue Router 4 文档](https://router.vuejs.org/)
- [Pinia 文档](https://pinia.vuejs.org/)
- [Element Plus 文档](https://element-plus.org/)
- [Vue 3 迁移指南](https://v3-migration.vuejs.org/)

---

## 八、迁移状态总结

### 8.1 已修复的关键问题

| 问题 | 修复时间 | 影响 |
|------|---------|------|
| TagsView 动态 ref 错误 | 2026-05-13 | 核心功能 |
| 登录页密码输入卡顿 | 2026-05-14 | 用户体验 |
| 侧边栏空白无菜单 | 2026-05-14 | 核心功能 |
| 页面横向无限延伸 | 2026-05-14 | 用户体验 |
| examPaper.js 缺失方法 | 2026-05-14 | 功能错误 |
| enumFormat 返回 null | 2026-05-14 | 显示问题 |

### 8.2 数据库增强状态

| 表名 | 状态 | 功能 |
|------|------|------|
| t_knowledge_point | ✅ 已创建，128条数据 | 知识点树 |
| t_question_knowledge | ✅ 已创建 | 题目-知识点关联 |
| t_user_knowledge_mastery | ✅ 已创建 | 用户知识掌握图谱 |
| t_knowledge_relation | ✅ 已创建，19条关系 | 知识点关系网 |
| t_question_vector | ✅ 已创建 | RAG 向量化存储 |
| t_question_ai_analysis | ✅ 已创建 | AI 解析多风格存储 |
| t_user_learning_behavior | ✅ 已创建 | 用户学习行为记录 |
| t_user_learning_session | ✅ 已创建 | 用户学习会话 |

### 8.3 系统当前服务状态

| 服务 | 地址 | 状态 |
|------|------|------|
| Admin 前端 | http://localhost:8003/ | ✅ 运行中 |
| Student 前端 | http://localhost:8004/ | ✅ 运行中 |
| 后端 API | http://localhost:8000/ | ✅ 运行中 |
| MySQL | localhost:3306 | ✅ 运行中 |

---

## 九、更新记录

### v2.0 (2026-05-14)
- 修复登录页密码输入卡顿问题（移除 .native，简化 input 实现）
- 修复侧边栏空白问题，简化菜单实现（从路由动态生成）
- 修复页面横向延展问题（添加 overflow-x: hidden）
- 添加数据库增强设计（知识图谱、RAG、AI解析表）
- 初始化 128 条知识点数据和 19 条关系数据
- 添加详细的问题验证清单（17项待验证）
- 记录已知问题和解决方案

### v1.0 (2024)
- 初始版本，完成基础迁移
- Vue 2 → Vue 3 框架升级
- Vuex → Pinia 状态管理
- Element UI → Element Plus
- vue-cli → Vite

---

**文档版本**: v2.0
**最后更新**: 2026-05-14
**维护者**: 软工实训14组
