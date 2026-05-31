var app = getApp()
Page({
  data: {
    spinShow: false,
    userName: '',
    password: '',
    submitting: false
  },
  formSubmit: function(e) {
    var _this = this
    if (_this.data.submitting) return
    var form = e.detail.value
    if (!form.userName || !form.userName.trim()) {
      app.message('请输入用户名', 'error')
      return
    }
    if (!form.password || !form.password.trim()) {
      app.message('请输入密码', 'error')
      return
    }
    _this.setData({ spinShow: true, submitting: true })
    wx.login({
      success: function(wxres) {
        if (wxres.code) {
          form.code = wxres.code
          app.formPost('/api/wx/student/auth/bind', form)
            .then(function(res) {
              _this.setData({ spinShow: false, submitting: false })
              if (res.code == 1) {
                wx.setStorageSync('token', res.response)
                wx.switchTab({ url: '/pages/index/index' })
              } else {
                app.message(res.message, 'error')
              }
            }).catch(function(e) {
              _this.setData({ spinShow: false, submitting: false })
              app.message(e, 'error')
            })
        } else {
          _this.setData({ spinShow: false, submitting: false })
          app.message(wxres.errMsg, 'error')
        }
      }
    })
  },
  register: function() {
    wx.navigateTo({ url: '../register/index' })
  }
})
