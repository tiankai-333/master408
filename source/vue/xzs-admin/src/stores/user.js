import { defineStore } from 'pinia'
import { ref } from 'vue'
import Cookies from 'js-cookie'
import userApi from '@/api/user'

export const useUserStore = defineStore('user', () => {
  const userName = ref(Cookies.get('adminUserName'))
  const userInfo = ref(Cookies.get('adminUserInfo'))

  const initUserInfo = () => {
    userApi.getCurrentUser().then(re => {
      setUserInfo(re.response)
    })
  }

  const setUserName = (name) => {
    userName.value = name
    Cookies.set('adminUserName', name, { expires: 30 })
  }

  const setUserInfo = (info) => {
    userInfo.value = info
    Cookies.set('adminUserInfo', info, { expires: 30 })
  }

  const clearLogin = () => {
    Cookies.remove('adminUserName')
    Cookies.remove('adminUserInfo')
    userName.value = null
    userInfo.value = null
  }

  return {
    userName,
    userInfo,
    initUserInfo,
    setUserName,
    setUserInfo,
    clearLogin
  }
})