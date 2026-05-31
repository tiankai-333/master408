var questionHtml = require('../../../utils/questionHtml.js')

var app = getApp()
Page({
  data: {
    spinShow: false,
    paperId: null,
    paper: {},
    answer: {}
  },
  onLoad: function(options) {
    var paperId = options.id
    var _this = this
    _this.setData({ spinShow: true })
    app.formPost('/api/wx/student/exampaper/answer/read/' + paperId, null)
      .then(function(res) {
        if (res.code === 1) {
          questionHtml.resolveExamPaper(res.response.paper).then(function(resolved) {
            _this.setData({
              spinShow: false,
              paper: resolved,
              answer: res.response.answer,
              paperId: paperId
            })
          })
        } else {
          _this.setData({ spinShow: false })
        }
      }).catch(function(e) {
        _this.setData({ spinShow: false })
        app.message(e, 'error')
      })
  },

  judgeQuestion: function(e) {
    var _this = this
    var itemOrder = e.currentTarget.dataset.order
    var isCorrect = e.currentTarget.dataset.correct === 'true'
    var answer = _this.data.answer
    var item = answer.answerItems[itemOrder - 1]

    if (!item) return

    var questionScore = item.questionScore || '0'
    var score = isCorrect ? questionScore : '0'

    var judgeItem = {
      id: item.id,
      doRight: isCorrect,
      score: score,
      questionScore: questionScore
    }

    wx.showLoading({ title: '批改中', mask: true })
    app.jsonPost('/api/wx/student/exampaper/answer/judge', {
      id: Number(_this.data.paperId),
      answerItems: [judgeItem]
    }).then(function(res) {
      wx.hideLoading()
      if (res.code === 1) {
        var newAnswer = JSON.parse(JSON.stringify(answer))
        newAnswer.answerItems[itemOrder - 1].doRight = isCorrect
        newAnswer.answerItems[itemOrder - 1].score = score
        newAnswer.score = res.response || answer.score
        _this.setData({ answer: newAnswer })
        app.message('批改完成', 'success')
      } else {
        app.message(res.message || '批改失败', 'error')
      }
    }).catch(function(e) {
      wx.hideLoading()
      app.message(e || '批改失败', 'error')
    })
  },

  returnRecord: function() {
    wx.navigateBack()
  }
})
