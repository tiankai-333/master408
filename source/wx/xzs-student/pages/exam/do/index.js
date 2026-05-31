var util = require('../../../utils/util.js')
var questionHtml = require('../../../utils/questionHtml.js')

var app = getApp()
Page({
  data: {
    spinShow: false,
    paperId: null,
    form: {},
    timer: null,
    doTime: 0,
    remainTime: 0,
    remainTimeStr: '',
    modalShow: false,
    result: 0,
    timeOutShow: false,
    submitting: false,
    answeredCount: 0,
    totalQuestions: 0
  },
  onLoad: function(options) {
    var paperId = options.id
    var _this = this
    _this.setData({ spinShow: true })
    app.formPost('/api/wx/student/exampaper/select/' + paperId, null)
      .then(function(res) {
        if (res.code === 1) {
          questionHtml.resolveExamPaper(res.response).then(function(resolved) {
            var suggestTime = resolved.suggestTime || 120
            var totalQ = 0
            if (resolved.titleItems) {
              resolved.titleItems.forEach(function(t) {
                totalQ += (t.questionItems || []).length
              })
            }
            _this.setData({
              spinShow: false,
              form: resolved,
              paperId: paperId,
              remainTime: suggestTime * 60,
              totalQuestions: totalQ
            })
            var savedAnswers = _this.restoreDraft()
            if (savedAnswers) {
              _this.setData({ restoredAnswers: savedAnswers })
            }
            _this.timeReduce()
          })
        } else {
          _this.setData({ spinShow: false })
        }
      }).catch(function(e) {
        _this.setData({ spinShow: false })
        app.message(e, 'error')
      })
  },
  timeReduce: function() {
    var _this = this
    var timer = setInterval(function() {
      var remainTime = _this.data.remainTime
      if (remainTime <= 0) {
        _this.timeOut()
      } else {
        _this.setData({
          remainTime: remainTime - 1,
          remainTimeStr: util.formatSeconds(remainTime),
          doTime: _this.data.doTime + 1
        })
      }
    }, 1000)
    _this.setData({ timer: timer })
  },
  onAnswerChange: function() {
    var form = this.data.form
    if (!form || !form.titleItems) return
    var answered = 0
    form.titleItems.forEach(function(t) {
      (t.questionItems || []).forEach(function(q) {
        if (q.answer !== null && q.answer !== undefined && q.answer !== '') answered++
      })
    })
    this.setData({ answeredCount: answered })
  },
  onUnload: function() {
    clearInterval(this.data.timer)
    this.saveDraft()
  },
  onHide: function() {
    this.saveDraft()
  },
  saveDraft: function() {
    if (!this.data.paperId) return
    var form = this.data.form
    if (!form || !form.titleItems) return
    var answers = {}
    form.titleItems.forEach(function(titleItem) {
      titleItem.questionItems.forEach(function(q) {
        var key = q.itemOrder + '_' + q.id + '_' + q.questionType
        answers[key] = q.answer != null ? q.answer : ''
      })
    })
    wx.setStorageSync('exam_draft_' + this.data.paperId, {
      answers: answers,
      remainTime: this.data.remainTime,
      doTime: this.data.doTime
    })
  },
  restoreDraft: function() {
    var draft = wx.getStorageSync('exam_draft_' + this.data.paperId)
    if (!draft || !draft.answers) return false
    this.setData({
      remainTime: draft.remainTime,
      doTime: draft.doTime
    })
    return draft.answers
  },
  returnRecord: function() {
    wx.navigateTo({ url: '/pages/record/index' })
  },
  timeOut: function() {
    clearInterval(this.data.timer)
    this.setData({ timeOutShow: true })
  },
  formSubmit: function(e) {
    var _this = this
    if (_this.data.submitting) return
    if (_this.data.timer) {
      clearInterval(_this.data.timer)
    }
    _this.setData({ submitting: true })
    wx.showLoading({ title: '提交中', mask: true })
    var formData = {}
    var keys = Object.keys(e.detail.value || {})
    for (var i = 0; i < keys.length; i++) {
      formData[keys[i]] = e.detail.value[keys[i]]
    }
    formData.id = _this.data.paperId
    formData.doTime = _this.data.doTime
    console.log('[exam-submit] paperId:', formData.id, 'doTime:', formData.doTime, 'fields:', keys.length)
    app.formPost('/api/wx/student/exampaper/answer/answerSubmit', formData)
      .then(function(res) {
        _this.setData({ submitting: false })
        wx.hideLoading()
        if (res.code === 1) {
          wx.removeStorageSync('exam_draft_' + _this.data.paperId)
          _this.setData({ modalShow: true, result: res.response })
        } else {
          console.error('[exam-submit] fail:', res)
          wx.showToast({ title: res.message || '提交失败', icon: 'none', duration: 3000 })
        }
      }).catch(function(err) {
        _this.setData({ submitting: false })
        wx.hideLoading()
        console.error('[exam-submit] error:', err)
        wx.showToast({ title: String(err || '提交失败'), icon: 'none', duration: 3000 })
      })
  }
})
