import { onMounted, onUnmounted, watch } from 'vue'
import { useRoute } from 'vue-router'
import { useAppStore } from '@/stores/app'

const WIDTH = 992

export default function () {
  const appStore = useAppStore()
  const route = useRoute()

  const isMobile = () => {
    const rect = document.body.getBoundingClientRect()
    return rect.width - 1 < WIDTH
  }

  const resizeHandler = () => {
    if (!document.hidden) {
      const mobile = isMobile()
      appStore.toggleDevice(mobile ? 'mobile' : 'desktop')

      if (mobile) {
        appStore.closeSideBar(true)
      }
    }
  }

  watch(() => route.path, () => {
    if (appStore.device === 'mobile' && appStore.sidebar.opened) {
      appStore.closeSideBar(false)
    }
  })

  onMounted(() => {
    window.addEventListener('resize', resizeHandler)
    const mobile = isMobile()
    if (mobile) {
      appStore.toggleDevice('mobile')
      appStore.closeSideBar(true)
    }
  })

  onUnmounted(() => {
    window.removeEventListener('resize', resizeHandler)
  })
}