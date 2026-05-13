import { defineStore } from 'pinia'
import Cookies from 'js-cookie'
import userApi from '@/api/user'

export const useUserStore = defineStore('user', {
  state: () => ({
    userName: Cookies.get('studentUserName'),
    userInfo: Cookies.get('studentUserInfo'),
    imagePath: Cookies.get('studentImagePath'),
    messageCount: 0
  }),
  actions: {
    initUserInfo () {
      userApi.getCurrentUser().then(re => {
        this.setUserInfo(re.response)
      })
    },
    getUserMessageInfo () {
      userApi.getMessageCount().then(re => {
        this.messageCount = re.response
      })
    },
    setUserName (userName) {
      this.userName = userName
      Cookies.set('studentUserName', userName, { expires: 30 })
    },
    setUserInfo (userInfo) {
      this.userInfo = userInfo
      Cookies.set('studentUserInfo', userInfo, { expires: 30 })
    },
    setImagePath (imagePath) {
      this.imagePath = imagePath
      Cookies.set('studentImagePath', imagePath, { expires: 30 })
    },
    messageCountSubtract (num) {
      this.messageCount = this.messageCount - num
    },
    clearLogin () {
      Cookies.remove('studentUserName')
      Cookies.remove('studentUserInfo')
      Cookies.remove('studentImagePath')
      this.userName = null
      this.userInfo = null
      this.imagePath = null
    }
  }
})
