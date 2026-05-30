var app = getApp()

Page({
  data: {
    mode: 'real',
    subjects: [
      { id: 1, name: '数据结构', icon: '🧱' },
      { id: 2, name: '计算机组成原理', icon: '⚙️' },
      { id: 3, name: '操作系统', icon: '🖥' },
      { id: 4, name: '计算机网络', icon: '🌐' }
    ],
    selectedSubjectId: null,
    currentSubjectName: '',
    spinShow: false,
    loadMoreLoad: false,
    loadMoreTip: '',
    queryParam: {
      paperType: 1,
      pageIndex: 1,
      pageSize: app.globalData.pageSize
    },
    tableData: [],
    total: 1
  },

  onLoad: function (options) {
    var mode = 'real'
    if (options && options.type === 'special') mode = 'special'
    if (options && options.type === 'timed') mode = 'timed'
    this.setData({ mode: mode })

    if (mode === 'real') {
      // 真题模式：先显示科目选择，不加载试卷
      return
    }
    // 限时/专项模式：直接加载限时试卷
    this.setData({ spinShow: true, queryParam: { paperType: 4, pageIndex: 1, pageSize: app.globalData.pageSize } })
    this.search(true)
  },

  selectSubject: function (e) {
    var id = e.currentTarget.dataset.id
    var name = ''
    for (var i = 0; i < this.data.subjects.length; i++) {
      if (this.data.subjects[i].id === id) { name = this.data.subjects[i].name; break }
    }
    this.setData({
      selectedSubjectId: id,
      currentSubjectName: name,
      spinShow: true,
      queryParam: { paperType: 1, pageIndex: 1, pageSize: app.globalData.pageSize, subjectId: id }
    })
    this.search(true)
  },

  backToSubjects: function () {
    this.setData({ selectedSubjectId: null, currentSubjectName: '', tableData: [] })
  },

  onPullDownRefresh: function () {
    this.setData({ spinShow: true })
    if (!this.loading) {
      this.setData({ 'queryParam.pageIndex': 1 })
      this.search(true)
    }
  },

  onReachBottom: function () {
    if (!this.loading && this.data.queryParam.pageIndex < this.data.total) {
      this.setData({ loadMoreLoad: true, loadMoreTip: '正在加载' })
      this.setData({ 'queryParam.pageIndex': this.data.queryParam.pageIndex + 1 })
      this.search(false)
    }
  },

  search: function (override) {
    var _this = this
    app.formPost('/api/wx/student/exampaper/pageList', this.data.queryParam).then(function (res) {
      _this.setData({ spinShow: false })
      wx.stopPullDownRefresh()
      if (res.code === 1) {
        var re = res.response
        _this.setData({
          'queryParam.pageIndex': re.pageNum,
          tableData: override ? re.list : _this.data.tableData.concat(re.list),
          total: re.pages
        })
        if (re.pageNum >= re.pages) {
          _this.setData({ loadMoreLoad: false, loadMoreTip: re.list.length > 0 ? '没有更多了' : '' })
        }
      }
    }).catch(function (e) {
      _this.setData({ spinShow: false })
      app.message(e, 'error')
    })
  },

  goExam: function (e) {
    var id = e.currentTarget.dataset.id
    if (id) wx.navigateTo({ url: '/pages/exam/do/index?id=' + id })
  }
})
