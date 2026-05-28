const app = getApp()
Page({
  data: {
    spinShow: false,
    info: {},
    displayName: '408Master',
    avatarPath: '/assets/tabBar/my-select.png'
  },

  onLoad: function(options) {
    this.loadUserInfo()
  },
  loadUserInfo() {
    let _this = this
    _this.setData({
      spinShow: true
    });
    app.formPost('/api/wx/student/user/current', null).then(res => {
      if (res.code == 1) {
        _this.setData({
          info: res.response,
          displayName: res.response && res.response.userName ? res.response.userName : '408Master',
          avatarPath: res.response && res.response.imagePath ? res.response.imagePath : '/assets/tabBar/my-select.png'
        });
      }
      _this.setData({
        spinShow: false
      });
    }).catch(e => {
      _this.setData({
        spinShow: false
      });
      app.message(e, 'error')
    })
  },
  openPage(e) {
    const url = e.currentTarget.dataset.url
    if (!url) return
    wx.navigateTo({ url })
  },
  openTab(e) {
    const url = e.currentTarget.dataset.url
    if (!url) return
    wx.switchTab({ url })
  },
  logOut() {
    let _this = this
    _this.setData({
      spinShow: true
    });
    app.formPost('/api/wx/student/auth/unBind', null).then(res => {
      if (res.code == 1) {
        wx.setStorageSync('token', '')
        wx.reLaunch({
          url: '/pages/user/bind/index',
        });
      }
      _this.setData({
        spinShow: false
      });
    }).catch(e => {
      _this.setData({
        spinShow: false
      });
      app.message(e, 'error')
    })
  }
})
