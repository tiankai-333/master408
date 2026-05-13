<template>
  <div id="tags-view-container" class="tags-view-container">
    <div ref="scrollContainer" class="tags-view-wrapper" @wheel="handleScroll">
      <router-link
        v-for="tag in visitedViews"
        :key="tag.path"
        :class="isActive(tag)?'active':''"
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
    <ul v-show="visible" :style="{left:left+'px',top:top+'px'}" class="contextmenu">
      <li @click="refreshSelectedTag(selectedTag)">刷新</li>
      <li v-if="!(selectedTag.meta&&selectedTag.meta.affix)" @click="closeSelectedTag(selectedTag)">关闭</li>
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

const visible = ref(false)
const top = ref(0)
const left = ref(0)
const selectedTag = ref({})
const scrollContainer = ref(null)

const visitedViews = computed(() => tagsViewStore.visitedViews)
const routes = computed(() => router.options.routes)

const isActive = (routeItem) => {
  return routeItem.path === route.path
}

const filterAffixTags = (routes, basePath = '/') => {
  let tags = []
  routes.forEach(routeItem => {
    if (routeItem.meta && routeItem.meta.affix) {
      const tagPath = basePath === '/' ? routeItem.path : basePath + routeItem.path
      tags.push({
        fullPath: tagPath,
        path: tagPath,
        name: routeItem.name,
        meta: { ...routeItem.meta }
      })
    }
    if (routeItem.children) {
      const tempTags = filterAffixTags(routeItem.children, routeItem.path)
      if (tempTags.length >= 1) {
        tags = [...tags, ...tempTags]
      }
    }
  })
  return tags
}

const initTags = () => {
  const affixTags = filterAffixTags(routes.value)
  for (const tag of affixTags) {
    if (tag.name) {
      tagsViewStore.addVisitedView(tag)
    }
  }
}

const addTags = () => {
  const { name } = route
  if (name) {
    tagsViewStore.addView(route)
  }
}

const moveToCurrentTag = () => {
  nextTick(() => {
    const scrollWrapper = scrollContainer.value
    if (!scrollWrapper) return
    
    const activeTag = scrollWrapper.querySelector('.tags-view-item.active')
    if (activeTag) {
      const tagOffsetLeft = activeTag.offsetLeft
      const tagWidth = activeTag.offsetWidth
      const containerWidth = scrollWrapper.offsetWidth
      
      if (tagOffsetLeft < scrollWrapper.scrollLeft) {
        scrollWrapper.scrollLeft = tagOffsetLeft
      } else if (tagOffsetLeft + tagWidth > scrollWrapper.scrollLeft + containerWidth) {
        scrollWrapper.scrollLeft = tagOffsetLeft + tagWidth - containerWidth
      }
    }
  })
}

const refreshSelectedTag = (view) => {
  tagsViewStore.delCachedView(view).then(() => {
    const { fullPath } = view
    nextTick(() => {
      routerInstance.replace({
        path: '/redirect' + fullPath
      })
    })
  })
}

const closeSelectedTag = (view) => {
  tagsViewStore.delView(view).then(({ visitedViews }) => {
    if (isActive(view)) {
      toLastView(visitedViews, view)
    }
  })
}

const closeOthersTags = () => {
  if (route.fullPath !== selectedTag.value.fullPath) {
    routerInstance.push(selectedTag.value)
  }
  tagsViewStore.delOthersViews(selectedTag.value).then(() => {
    moveToCurrentTag()
  })
}

const closeAllTags = (view) => {
  tagsViewStore.delAllViews().then(({ visitedViews }) => {
    if (affixTags.value.some(tag => tag.path === view.path)) {
      return
    }
    toLastView(visitedViews, view)
  })
}

const affixTags = ref([])

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

const handleScroll = (e) => {
  const eventDelta = e.wheelDelta || -e.deltaY * 40
  const scrollWrapper = scrollContainer.value
  if (scrollWrapper) {
    scrollWrapper.scrollLeft = scrollWrapper.scrollLeft + eventDelta / 4
  }
}

const openMenu = (tag, e) => {
  const menuMinWidth = 105
  const offsetLeft = document.querySelector('#tags-view-container').getBoundingClientRect().left
  const offsetWidth = document.querySelector('#tags-view-container').offsetWidth
  const maxLeft = offsetWidth - menuMinWidth
  const leftPos = e.clientX - offsetLeft + 15

  if (leftPos > maxLeft) {
    left.value = maxLeft
  } else {
    left.value = leftPos
  }

  top.value = e.clientY
  visible.value = true
  selectedTag.value = tag
}

const closeMenu = () => {
  visible.value = false
}

watch(() => route.path, () => {
  addTags()
  moveToCurrentTag()
})

watch(visible, (value) => {
  if (value) {
    document.body.addEventListener('click', closeMenu)
  } else {
    document.body.removeEventListener('click', closeMenu)
  }
})

onMounted(() => {
  initTags()
  addTags()
})
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

    &::-webkit-scrollbar {
      display: none;
    }

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

      &:first-of-type {
        margin-left: 14px;
      }

      &:hover {
        color: #1890ff;
        border-color: #bae0ff;
        background: #e6f7ff;
      }

      &.active {
        background-color: #1890ff;
        color: #fff;
        border-color: #1890ff;
        box-shadow: 0 2px 8px rgba(24, 144, 255, 0.22);

        &::before {
          content: '';
          background: rgba(255,255,255,0.7);
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
    font-weight: 400;
    color: #374151;
    box-shadow: 0 8px 24px rgba(15, 23, 42, 0.12);
    border: 1px solid #eaecf0;

    li {
      margin: 0;
      padding: 7px 14px;
      cursor: pointer;
      border-radius: 6px;
      transition: background 0.15s, color 0.15s;

      &:hover {
        background: #f0f7ff;
        color: #1890ff;
      }
    }
  }
}
</style>

<style lang="scss">
.tags-view-wrapper {
  .tags-view-item {
    .el-icon-close {
      width: 14px;
      height: 14px;
      vertical-align: 1px;
      border-radius: 50%;
      text-align: center;
      transition: all .2s;
      transform-origin: 100% 50%;
      margin-left: 4px;

      &:before {
        transform: scale(.6);
        display: inline-block;
        vertical-align: -3px;
      }

      &:hover {
        background-color: rgba(0, 0, 0, 0.18);
        color: #fff;
      }
    }
  }
}
</style>