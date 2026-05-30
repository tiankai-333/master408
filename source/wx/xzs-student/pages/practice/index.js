const app = getApp()

Page({
  data: {},
  goPage(e) {
    const url = e.currentTarget.dataset.url
    if (url) wx.navigateTo({ url })
  },
  goTab(e) {
    const url = e.currentTarget.dataset.url
    if (url) wx.switchTab({ url })
  }
})
