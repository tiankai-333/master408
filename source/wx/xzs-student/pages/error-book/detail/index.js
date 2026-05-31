var markdownUtil = require('../../../utils/markdown.js')
var questionHtml = require('../../../utils/questionHtml.js')
var constants = require('../../../utils/constants.js')
var app = getApp()

Page({
  data: {
    spinShow: false,
    questionVM: null,
    answerVM: null,
    answerId: null,
    deleting: false,
    aiAnalyzing: false,
    aiResult: '',
    aiResultHtml: '',
    aiStyleIndex: 0,
    aiStyleNames: constants.aiStyles.map(function (s) { return s.name })
  },

  onLoad: function (options) {
    if (options.id) {
      this.setData({ spinShow: true, answerId: parseInt(options.id) })
      this.loadDetail(options.id)
    }
  },

  loadDetail: function (id) {
    var _this = this
    app.formPost('/api/wx/student/question/answer/select/' + id, {})
      .then(function (res) {
        if (res.code === 1) {
          questionHtml.resolveQuestionVM(res.response.questionVM).then(function (resolved) {
            _this.setData({
              spinShow: false,
              questionVM: resolved,
              answerVM: res.response.questionAnswerVM
            })
          })
        } else {
          _this.setData({ spinShow: false })
        }
      }).catch(function (e) {
        _this.setData({ spinShow: false })
        app.message(e, 'error')
      })
  },

  onStyleChange: function (e) {
    this.setData({ aiStyleIndex: e.detail.value })
  },

  analyzeQuestion: function () {
    var q = this.data.questionVM
    var a = this.data.answerVM
    if (!q) return

    var style = constants.aiStyles[this.data.aiStyleIndex].id
    var questionType = constants.questionTypeMap[q.questionType] || '未知'

    var options = ''
    if (q.items && q.items.length > 0) {
      options = q.items.map(function (item) {
        return item.prefix + '. ' + item.content
      }).join('\n')
    }

    var correctAnswer = q.correct || ''
    if (q.questionType === 4 && q.correctArray) {
      correctAnswer = q.correctArray.join(', ')
    }

    var data = {
      questionType: questionType,
      questionContent: q.titleContent || q.title || '',
      options: options,
      correctAnswer: correctAnswer,
      style: style
    }

    var _this = this
    _this.setData({ aiAnalyzing: true, aiResult: '', aiResultHtml: '' })

    app.formPost('/api/wx/student/question/analyze-question', data)
      .then(function (res) {
        _this.setData({ aiAnalyzing: false })
        if (res.code === 1) {
          var html = markdownUtil.renderMarkdown(String(res.response))
          _this.setData({ aiResult: res.response, aiResultHtml: html })
        } else {
          app.message(res.message, 'error')
        }
      }).catch(function (e) {
        _this.setData({ aiAnalyzing: false })
        app.message(e, 'error')
      })
  },

  deleteAnswer: function () {
    var _this = this
    var answerId = this.data.answerId
    if (!answerId) return

    wx.showModal({
      title: '确认删除',
      content: '确定要将此题移出错题本吗？',
      confirmColor: '#f56c6c',
      success: function (res) {
        if (!res.confirm) return
        _this.setData({ deleting: true })
        app.formPost('/api/wx/student/question/answer/delete/' + answerId, {})
          .then(function (res) {
            _this.setData({ deleting: false })
            if (res.code === 1) {
              wx.showToast({ title: '已移出错题本', icon: 'success' })
              setTimeout(function () {
                wx.navigateBack()
              }, 1200)
            } else {
              app.message(res.message, 'error')
            }
          }).catch(function (e) {
            _this.setData({ deleting: false })
            app.message(e, 'error')
          })
      }
    })
  }
})
