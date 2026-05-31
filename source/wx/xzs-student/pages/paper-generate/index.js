const app = getApp()
const constants = require('../../utils/constants.js')

Page({
  data: {
    subjects: constants.subjects,
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

    app.jsonPost('/api/wx/student/ai/compose-paper', {
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
      app.message(err || '生成失败，请稍后再试', 'error')
    })
  }
})
