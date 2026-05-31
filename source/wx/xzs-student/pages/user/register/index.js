var app = getApp()
Page({
  data: {
    levelIndex: 0,
    submitting: false
  },
  bindLevelChange: function(e) {
    this.setData({ levelIndex: e.detail.value })
  },
  formSubmit: function(e) {
    var _this = this
    if (_this.data.submitting) return
    var form = e.detail.value
    if (!form.userName || !form.userName.trim()) {
      app.message('用户名不能为空', 'error')
      return
    }
    if (!form.password || !form.password.trim()) {
      app.message('密码不能为空', 'error')
      return
    }
    if (!form.userLevel) {
      app.message('年级不能为空', 'error')
      return
    }
    _this.setData({ spinShow: true, submitting: true })
    app.formPost('/api/wx/student/user/register', form)
      .then(function(res) {
        _this.setData({ spinShow: false, submitting: false })
        if (res.code == 1) {
          app.message('注册成功，正在自动登录...', 'success')
          _this.autoLogin(form.userName, form.password)
        } else {
          app.message(res.message, 'error')
        }
      }).catch(function(e) {
        _this.setData({ spinShow: false, submitting: false })
        app.message(e, 'error')
      })
  },
  autoLogin: function(userName, password) {
    var _this = this
    wx.login({
      success: function(wxres) {
        if (wxres.code) {
          app.formPost('/api/wx/student/auth/bind', {
            userName: userName,
            password: password,
            code: wxres.code
          }).then(function(res) {
            if (res.code == 1) {
              wx.setStorageSync('token', res.response)
              wx.switchTab({ url: '/pages/index/index' })
            } else {
              wx.reLaunch({ url: '/pages/user/bind/index' })
            }
          }).catch(function() {
            wx.reLaunch({ url: '/pages/user/bind/index' })
          })
        } else {
          wx.reLaunch({ url: '/pages/user/bind/index' })
        }
      }
    })
  }
})
