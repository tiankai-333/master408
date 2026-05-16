<template>
  <section class="app-main">
    <transition name="fade-transform" mode="out-in">
      <keep-alive :include="cachedViews">
        <router-view :key="key" />
      </keep-alive>
    </transition>
  </section>
</template>

<script setup>
import { computed } from 'vue'
import { useTagsViewStore } from '@/stores/tagsView'

const tagsViewStore = useTagsViewStore()
const cachedViews = computed(() => tagsViewStore.cachedViews)

import { useRoute } from 'vue-router'
const route = useRoute()
const key = computed(() => route.path)
</script>

<style lang="scss" scoped>
  .app-main {
    min-height: calc(100vh - 50px);
    width: 100%;
    position: relative;
    overflow: hidden;
  }

  .fixed-header+.app-main {
    padding-top: 50px;
  }

  .hasTagsView {
    .app-main {
      min-height: calc(100vh - 84px);
    }

    .fixed-header+.app-main {
      padding-top: 84px;
    }
  }
</style>

<style lang="scss">
  .el-popup-parent--hidden {
    .fixed-header {
      padding-right: 15px;
    }
  }
</style>