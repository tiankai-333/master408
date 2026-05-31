var app = getApp()

Page({
  data: {
    loading: false,
    publicProviders: [],
    privateKeys: [],
    testingId: null,
    testResults: {}
  },

  onLoad: function () {
    this.loadData()
  },

  onPullDownRefresh: function () {
    this.loadData()
  },

  loadData: function () {
    var _this = this
    _this.setData({ loading: true })

    var p1 = app.formPost('/api/wx/student/ai-config/providers', {}).then(function (res) {
      if (res.code === 1) {
        _this.setData({ publicProviders: res.response || [] })
      } else if (res.code !== 401) {
        wx.showToast({ title: res.message || '加载公共密钥失败', icon: 'none', duration: 2000 })
      }
    }).catch(function (err) {
      wx.showToast({ title: '公共密钥请求失败', icon: 'none', duration: 2000 })
    })

    var p2 = app.formPost('/api/wx/student/ai-config/user-keys', {}).then(function (res) {
      if (res.code === 1) {
        _this.setData({ privateKeys: res.response || [] })
      } else if (res.code !== 401) {
        wx.showToast({ title: res.message || '加载私人密钥失败', icon: 'none', duration: 2000 })
      }
    }).catch(function (err) {
      wx.showToast({ title: '私人密钥请求失败', icon: 'none', duration: 2000 })
    })

    Promise.all([p1, p2]).then(function () {
      _this.setData({ loading: false })
      wx.stopPullDownRefresh()
    })
  },

  testProvider: function (e) {
    var id = e.currentTarget.dataset.id
    var type = e.currentTarget.dataset.type
    this.doTest(id, type)
  },

  doTest: function (id, type) {
    var _this = this
    var key = type + '_' + id
    _this.setData({ testingId: key })

    var url = type === 'public'
      ? '/api/wx/student/ai-config/provider/' + id + '/test'
      : '/api/wx/student/ai-config/user-key/' + id + '/test'

    app.formPost(url, {}).then(function (res) {
      var results = _this.data.testResults
      results[key] = res.code === 1 ? res.response : { success: false, message: res.message || '测试失败' }
      _this.setData({ testingId: null, testResults: results })
    }).catch(function (err) {
      var results = _this.data.testResults
      results[key] = { success: false, message: String(err || '网络错误') }
      _this.setData({ testingId: null, testResults: results })
    })
  }
})
