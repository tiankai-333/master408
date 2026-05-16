<template>
  <div class="has-logo">
    <logo :collapse="isCollapse" />
    <el-scrollbar wrap-class="scrollbar-wrapper">
      <el-menu
        :default-active="activeMenu"
        :collapse="isCollapse"
        background-color="#ffffff"
        text-color="#303133"
        :unique-opened="false"
        active-text-color="#1890ff"
        :collapse-transition="false"
        mode="vertical"
      >
        <template v-for="item in menuData" :key="item.path">
          <el-menu-item v-if="item.noChildren" :index="item.path">
            <span>{{ item.title }}</span>
          </el-menu-item>
          <el-sub-menu v-else :index="item.path">
            <template #title>
              <span>{{ item.title }}</span>
            </template>
            <el-menu-item v-for="child in item.children" :key="child.path" :index="child.path">
              <span>{{ child.title }}</span>
            </el-menu-item>
          </el-sub-menu>
        </template>
      </el-menu>
    </el-scrollbar>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import Logo from './Logo'
import { useAppStore } from '@/stores/app'
import { useRoute } from 'vue-router'
import router from '@/router'

const appStore = useAppStore()
const route = useRoute()

const sidebar = computed(() => appStore.sidebar)
const routes = computed(() => router.options.routes)

const menuData = computed(() => {
  return routes.value
    .filter(r => !r.hidden)
    .map(r => {
      const visibleChildren = (r.children || []).filter(c => !c.hidden)
      return {
        path: r.path,
        title: r.meta?.title || r.name || '',
        noChildren: !visibleChildren || visibleChildren.length === 0,
        children: visibleChildren.map(c => ({
          path: r.path === '/' ? c.path : `${r.path}/${c.path}`,
          title: c.meta?.title || c.name || ''
        }))
      }
    })
})

const activeMenu = computed(() => {
  const { meta, path } = route
  if (meta.activeMenu) {
    return meta.activeMenu
  }
  return path
})

const isCollapse = computed(() => !sidebar.value.opened)
</script>