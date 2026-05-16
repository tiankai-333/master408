import { createApp } from 'vue'
import App from './App.vue'
import router from './router'
import { createPinia } from 'pinia'
import 'normalize.css/normalize.css'
import ElementPlus from 'element-plus'
import zhCn from 'element-plus/dist/locale/zh-cn.mjs'
import './styles/element-variables.scss'
import 'element-plus/dist/index.css'

import '@/styles/index.scss'
import './icons'
import NProgress from 'nprogress'
import 'nprogress/nprogress.css'

const app = createApp(App)
const pinia = createPinia()

app.use(ElementPlus, {
  locale: zhCn,
  size: 'medium'
})

app.use(pinia)
app.use(router)

NProgress.configure({ showSpinner: false })

router.beforeEach((to, from, next) => {
  NProgress.start()
  if (to.meta.title !== undefined) {
    document.title = to.meta.title
  } else {
    document.title = '\u200E'
  }

  next()
})

router.afterEach(() => {
  NProgress.done()
})

app.mount('#app')