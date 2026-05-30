const app = getApp()

Page({
  data: {
    subjects: [
      { id: 1, name: '数据结构' },
      { id: 2, name: '计算机组成原理' },
      { id: 3, name: '操作系统' },
      { id: 4, name: '计算机网络' }
    ],
    selectedSubject: null,
    questionCount: 10,
    generating: false
  },

  selectSubject(e) {
    const id = e.currentTarget.dataset.id
    this.setData({ selectedSubject: id })
  },

  setCount(e) {
    this.setData({ questionCount: Number(e.detail.value) })
  },

  generate() {
    const { selectedSubject, questionCount } = this.data
    if (!selectedSubject) {
      app.message('请选择科目', 'warning')
      return
    }

    this.setData({ generating: true })

    app.formPost('/api/wx/student/exampaper/auto-generate', {
      subjectId: selectedSubject,
      questionCount
    }).then(res => {
      this.setData({ generating: false })
      if (res.code === 1 && res.response) {
        wx.navigateTo({ url: '/pages/exam/do/index?id=' + res.response.paperId })
      } else {
        app.message(res.message || '生成失败，请稍后再试', 'error')
      }
    }).catch(err => {
      this.setData({ generating: false })
      app.message('自动组卷接口待接入', 'error')
    })
  }
})
