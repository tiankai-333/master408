<template>
  <el-breadcrumb class="app-breadcrumb" separator="/">
    <transition-group name="breadcrumb">
      <el-breadcrumb-item v-for="(item,index) in levelList" :key="item.path">
        <span v-if="item.redirect==='noRedirect'||index==levelList.length-1" class="no-redirect">{{ item.meta.title }}</span>
        <a v-else @click.prevent="handleLink(item)">{{ item.meta.title }}</a>
      </el-breadcrumb-item>
    </transition-group>
  </el-breadcrumb>
</template>

<script setup>
import { ref, watch, onMounted } from 'vue'
import * as pathToRegexp from 'path-to-regexp'
import { useRoute, useRouter } from 'vue-router'

const route = useRoute()
const router = useRouter()
const levelList = ref(null)

const getBreadcrumb = () => {
  let matched = route.matched.filter(item => item.meta && item.meta.title)
  const first = matched[0]

  if (!isDashboard(first)) {
    matched = [{ path: '/dashboard', meta: { title: '主页' } }].concat(matched)
  }
  levelList.value = matched.filter(item => item.meta && item.meta.title && item.meta.breadcrumb !== false)
}

const isDashboard = (routeItem) => {
  const name = routeItem && routeItem.name
  if (!name) {
    return false
  }
  return name.trim().toLocaleLowerCase() === 'Dashboard'.toLocaleLowerCase()
}

const pathCompile = (path) => {
  const { params } = route
  const toPath = pathToRegexp.compile(path)
  return toPath(params)
}

const handleLink = (item) => {
  const { redirect, path } = item
  if (redirect) {
    router.push(redirect)
    return
  }
  router.push(pathCompile(path))
}

watch(() => route.path, (newPath) => {
  if (newPath.startsWith('/redirect/')) {
    return
  }
  getBreadcrumb()
})

onMounted(() => {
  getBreadcrumb()
})
</script>

<style lang="scss" scoped>
.app-breadcrumb.el-breadcrumb {
  display: inline-block;
  font-size: 14px;
  line-height: 50px;
  margin-left: 8px;

  .no-redirect {
    color: #97a8be;
    cursor: text;
  }
}
</style>