<template>
  <div ref="scrollContainer" class="scroll-container" @wheel.prevent="handleScroll">
    <div ref="scrollWrapper" class="scroll-wrapper">
      <slot />
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'

const tagAndTagSpacing = 4

const scrollContainer = ref(null)
const scrollWrapper = ref(null)

const handleScroll = (e) => {
  const eventDelta = e.wheelDelta || -e.deltaY * 40
  if (scrollWrapper.value) {
    scrollWrapper.value.scrollLeft = scrollWrapper.value.scrollLeft + eventDelta / 4
  }
}

const moveToTarget = (currentTag) => {
  const $container = scrollContainer.value
  const $scrollWrapper = scrollWrapper.value
  
  if (!$container || !$scrollWrapper) return
  
  const $containerWidth = $container.offsetWidth
  const currentTagEl = currentTag?.$el
  
  if (!currentTagEl) return
  
  const tagOffsetLeft = currentTagEl.offsetLeft
  const tagWidth = currentTagEl.offsetWidth
  
  if (tagOffsetLeft < $scrollWrapper.scrollLeft) {
    $scrollWrapper.scrollLeft = tagOffsetLeft
  }
  
  const tagEnd = tagOffsetLeft + tagWidth
  if (tagEnd > $scrollWrapper.scrollLeft + $containerWidth) {
    $scrollWrapper.scrollLeft = tagEnd - $containerWidth
  }
}

defineExpose({ moveToTarget })
</script>

<style lang="scss" scoped>
.scroll-container {
  overflow: hidden;
  width: 100%;
  height: 100%;
  
  .scroll-wrapper {
    display: inline-flex;
    overflow-x: auto;
    overflow-y: hidden;
    white-space: nowrap;
    height: 100%;
    
    &::-webkit-scrollbar {
      display: none;
    }
  }
}
</style>