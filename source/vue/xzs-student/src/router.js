import { createRouter, createWebHistory } from 'vue-router'
import NProgress from 'nprogress'
import 'nprogress/nprogress.css'

NProgress.configure({ showSpinner: false })

const router = createRouter({
  history: createWebHistory(),
  routes: [
    { path: '/login', name: 'Login', component: () => import('@/views/login/index.vue'), meta: { title: '登录', bodyBackground: '#fbfbfb' } },
    { path: '/register', name: 'Register', component: () => import('@/views/register/index.vue'), meta: { title: '注册', bodyBackground: '#fbfbfb' } },
    {
      path: '/',
      component: () => import('@/layout/index.vue'),
      redirect: '/index',
      children: [
        {
          path: 'index',
          component: () => import('@/views/dashboard/index.vue'),
          name: 'Dashboard',
          meta: { title: '首页' }
        }
      ]
    },
    {
      path: '/paper',
      component: () => import('@/layout/index.vue'),
      children: [
        {
          path: 'index',
          component: () => import('@/views/paper/index.vue'),
          name: 'PaperIndex',
          meta: { title: '试卷中心' }
        }
      ]
    },
    {
      path: '/record',
      component: () => import('@/layout/index.vue'),
      children: [
        {
          path: 'index',
          component: () => import('@/views/record/index.vue'),
          name: 'RecordIndex',
          meta: { title: '考试记录' }
        }
      ]
    },
    {
      path: '/question',
      component: () => import('@/layout/index.vue'),
      children: [
        {
          path: 'index',
          component: () => import('@/views/question-error/index.vue'),
          name: 'QuestionErrorIndex',
          meta: { title: '错题本' }
        },
        {
          path: 'ai-analyze',
          component: () => import('@/views/question/ai-analyze.vue'),
          name: 'QuestionAiAnalyze',
          meta: { title: 'AI题目识别' }
        }
      ]
    },
    {
      path: '/knowledge-graph',
      component: () => import('@/layout/index.vue'),
      children: [
        {
          path: 'index',
          component: () => import('@/views/knowledge-graph/index.vue'),
          name: 'KnowledgeGraph',
          meta: { title: '知识图谱' }
        }
      ]
    },
    {
      path: '/user',
      component: () => import('@/layout/index.vue'),
      children: [
        {
          path: 'index',
          component: () => import('@/views/user-info/index.vue'),
          name: 'UserInfo',
          meta: { title: '个人中心' }
        }
      ]
    },
    {
      path: '/user',
      component: () => import('@/layout/index.vue'),
      children: [
        {
          path: 'message',
          component: () => import('@/views/user-info/message.vue'),
          name: 'UserMessage',
          meta: { title: '消息中心' }
        }
      ]
    },
    { path: '/do', name: 'ExamPaperDo', component: () => import('@/views/exam/paper/do.vue'), meta: { title: '试卷答题' } },
    { path: '/edit', name: 'ExamPaperEdit', component: () => import('@/views/exam/paper/edit.vue'), meta: { title: '试卷批改' } },
    { path: '/read', name: 'ExamPaperRead', component: () => import('@/views/exam/paper/read.vue'), meta: { title: '试卷查看' } },
    { path: '/:pathMatch(.*)*', component: () => import('@/views/error-page/404.vue'), meta: { title: '404' } }
  ]
})

router.beforeEach(async (to, from, next) => {
  NProgress.start()
  if (to.meta.title !== undefined) {
    document.title = to.meta.title
  } else {
    document.title = '\u200E'
  }

  if (to.meta.bodyBackground !== undefined) {
    document.querySelector('body').setAttribute('style', 'background: ' + to.meta.bodyBackground)
  } else {
    document.querySelector('body').removeAttribute('style')
  }

  next()
})

router.afterEach(() => {
  NProgress.done()
})

export default router
