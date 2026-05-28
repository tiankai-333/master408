var markdownUtil = require('../../../utils/markdown.js')
var app = getApp()

var questionTypeMap = {
  1: '单选题',
  2: '多选题',
  3: '判断题',
  4: '填空题',
  5: '简答题'
}

var aiStyles = [
  { id: 'default', name: '标准解析' },
  { id: 'feynman', name: '费曼风格' },
  { id: 'plato', name: '柏拉图式' },
  { id: 'first-principles', name: '第一性原理' }
]

Page({
  data: {
    spinShow: false,
    questionVM: null,
    answerVM: null,
    aiAnalyzing: false,
    aiResult: '',
    aiResultHtml: '',
    aiStyleIndex: 0,
    aiStyleNames: aiStyles.map(function (s) { return s.name })
  },

  onLoad: function (options) {
    if (options.id) {
      this.setData({ spinShow: true })
      this.loadDetail(options.id)
    }
  },

  loadDetail: function (id) {
    var _this = this
    app.formPost('/api/wx/student/question/answer/select/' + id, {})
      .then(function (res) {
        _this.setData({ spinShow: false })
        if (res.code === 1) {
          _this.setData({
            questionVM: res.response.questionVM,
            answerVM: res.response.questionAnswerVM
          })
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

    var style = aiStyles[this.data.aiStyleIndex].id
    var questionType = questionTypeMap[q.questionType] || '未知'

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
  }
})
