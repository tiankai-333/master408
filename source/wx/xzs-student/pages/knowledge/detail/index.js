var app = getApp()

Page({
  data: {
    spinShow: false,
    point: null,
    relatedQuestions: [],
    children: [],
    parentPoint: null,
    htmlContent: ''
  },

  onLoad: function (options) {
    if (options.id) {
      this.setData({ spinShow: true })
      this.loadDetail(options.id)
    }
  },

  loadDetail: function (id) {
    var _this = this
    app.formPost('/api/wx/student/knowledge-graph/knowledge-point/' + id, {})
      .then(function (res) {
        _this.setData({ spinShow: false })
        if (res.code === 1) {
          var d = res.response || {}
          var parentPoint = d.parentName ? { id: d.parentId, name: d.parentName } : null
          var children = d.children || []
          _this.setData({
            point: d,
            parentPoint: parentPoint,
            children: children
          })
          _this.loadQuestions(id)
          if (d.htmlRef) {
            _this.loadHtmlContent(d.htmlRef, d.summaryText)
          }
        }
      }).catch(function (e) {
        _this.setData({ spinShow: false })
        app.message(e, 'error')
      })
  },

  loadHtmlContent: function (htmlRef, fallbackText) {
    var _this = this
    var base = (app.globalData.baseAPI || '').replace(/\/$/, '')
    var url = htmlRef
    if (!/^https?:\/\//i.test(url)) {
      url = base + '/' + url.replace(/^\//, '')
    }
    wx.request({
      url: url,
      dataType: 'text',
      success: function (res) {
        if (res.statusCode === 200 && res.data) {
          _this.setData({ htmlContent: res.data })
        } else {
          _this.setData({ htmlContent: '' })
        }
      },
      fail: function () {
        _this.setData({ htmlContent: '' })
      }
    })
  },

  loadQuestions: function (id) {
    var _this = this
    app.formPost('/api/wx/student/knowledge-graph/knowledge-point/' + id + '/questions', { limit: 10 })
      .then(function (res) {
        if (res.code === 1) {
          _this.setData({ relatedQuestions: res.response || [] })
        }
      }).catch(function () {})
  },

  goParent: function () {
    if (this.data.parentPoint && this.data.parentPoint.id) {
      wx.redirectTo({ url: '/pages/knowledge/detail/index?id=' + this.data.parentPoint.id })
    }
  },

  goChild: function (e) {
    var id = e.currentTarget.dataset.id
    wx.redirectTo({ url: '/pages/knowledge/detail/index?id=' + id })
  },

  explainKnowledge: function () {
    var name = this.data.point ? this.data.point.name : ''
    if (!name) return
    var content = '请讲解这个408考研知识点：' + name
    wx.navigateTo({ url: '/pages/ai-workbench/index?content=' + encodeURIComponent(content) })
  }
})
