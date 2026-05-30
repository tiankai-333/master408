let app = getApp()
Page({
  data: {
    spinShow: false,
    loadMoreLoad: false,
    loadMoreTip: '',
    queryParam: {
      pageIndex: 1,
      pageSize: app.globalData.pageSize
    },
    tableData: [],
    total: 1
  },
  onLoad: function (options) {
    this.setData({ spinShow: true })
    this.search(true)
  },
  onPullDownRefresh: function () {
    this.setData({ spinShow: true })
    if (!this.loading) {
      this.setData({ ['queryParam.pageIndex']: 1 })
      this.search(true)
    }
  },
  onReachBottom: function () {
    if (!this.loading && this.data.queryParam.pageIndex < this.data.total) {
      this.setData({ loadMoreLoad: true, loadMoreTip: '正在加载' })
      this.setData({ ['queryParam.pageIndex']: this.data.queryParam.pageIndex + 1 })
      this.search(false)
    }
  },
  search: function (override) {
    let _this = this
    app.formPost('/api/wx/student/question/answer/page', this.data.queryParam)
      .then(res => {
        _this.setData({ spinShow: false })
        wx.stopPullDownRefresh()
        if (res.code === 1) {
          const re = res.response
          _this.setData({
            ['queryParam.pageIndex']: re.pageNum,
            tableData: override ? re.list : _this.data.tableData.concat(re.list),
            total: re.pages
          })
          if (re.pageNum >= re.pages) {
            _this.setData({ loadMoreLoad: false, loadMoreTip: re.list.length > 0 ? '没有更多了' : '' })
          }
        }
      }).catch(e => {
        _this.setData({ spinShow: false })
        app.message(e, 'error')
      })
  },
  goDetail: function(e) {
    var id = e.currentTarget.dataset.id
    if (id) wx.navigateTo({ url: '/pages/error-book/detail/index?id=' + id })
  }
})
