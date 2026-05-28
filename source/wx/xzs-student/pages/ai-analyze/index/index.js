var app = getApp()

Page({
  data: {
    imageUrl: '',
    isAnalyzing: false,
    results: [],
    errorMessage: ''
  },

  chooseImage: function () {
    var _this = this
    wx.chooseMedia({
      count: 1,
      mediaType: ['image'],
      sizeType: ['compressed'],
      sourceType: ['album', 'camera'],
      success: function (res) {
        var file = res.tempFiles[0]
        if (file.size > 10 * 1024 * 1024) {
          app.message('图片大小不能超过10MB', 'error')
          return
        }
        _this.setData({
          imageUrl: file.tempFilePath,
          results: [],
          errorMessage: ''
        })
      }
    })
  },

  clearImage: function () {
    this.setData({ imageUrl: '', results: [], errorMessage: '' })
  },

  analyzeImage: function () {
    if (!this.data.imageUrl) {
      app.message('请先选择图片', 'warning')
      return
    }

    var _this = this
    _this.setData({ isAnalyzing: true, results: [], errorMessage: '' })

    wx.uploadFile({
      url: app.globalData.baseAPI + '/api/wx/student/question/analyze-image',
      filePath: _this.data.imageUrl,
      name: 'file',
      header: { token: wx.getStorageSync('token') },
      success: function (res) {
        _this.setData({ isAnalyzing: false })
        try {
          var data = JSON.parse(res.data)
          if (data.code === 1) {
            var parsed = _this.parseResponse(data.response)
            _this.setData({ results: parsed })
          } else {
            _this.setData({ errorMessage: data.message || '识别失败' })
          }
        } catch (e) {
          _this.setData({ errorMessage: '解析结果失败' })
        }
      },
      fail: function (err) {
        _this.setData({ isAnalyzing: false, errorMessage: '上传失败：' + (err.errMsg || '网络错误') })
      }
    })
  },

  parseResponse: function (response) {
    if (!response) return []
    var text = typeof response === 'string' ? response : JSON.stringify(response)

    try {
      var parsed = JSON.parse(text)
      if (Array.isArray(parsed)) {
        return parsed.map(this.parseQuestionItem)
      }
      return [this.parseQuestionItem(parsed)]
    } catch (e) {
      return [{ title: text, questionType: '未知', options: [], correct: '', analyze: '' }]
    }
  },

  parseQuestionItem: function (item) {
    var getType = function (obj) {
      return obj.questionType || obj['题目类型'] || '未知'
    }
    var getTitle = function (obj) {
      return obj.title || obj['题目内容'] || obj['题干'] || ''
    }
    var getOptions = function (obj) {
      var opts = obj.options || obj['选项']
      if (!opts) return []
      if (typeof opts === 'string') {
        return opts.split(/[；\n]/).filter(function (s) { return s.trim() })
      }
      if (Array.isArray(opts)) {
        return opts.map(function (o) {
          if (typeof o === 'object' && o !== null) {
            var keys = Object.keys(o)
            return keys.length > 0 ? keys[0] + '. ' + o[keys[0]] : ''
          }
          return String(o)
        })
      }
      return []
    }
    var getCorrect = function (obj) {
      return obj.correct || obj['正确答案'] || obj['答案'] || ''
    }
    var getAnalyze = function (obj) {
      return obj.analyze || obj['解析'] || obj['分析'] || ''
    }

    return {
      questionType: getType(item),
      title: getTitle(item),
      options: getOptions(item),
      correct: getCorrect(item),
      analyze: getAnalyze(item)
    }
  }
})
