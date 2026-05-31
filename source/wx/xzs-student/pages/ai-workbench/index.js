var app = getApp()
var markdown = require('../../utils/markdown.js')
var constants = require('../../utils/constants.js')

Page({
  data: {
    spinShow: false,
    subjects: constants.subjectNames,
    subjectNameToId: constants.subjectNameToId,
    selectedSubject: '',
    subjectVisible: false,
    subjectPickerVisible: false,
    knowledgePickerVisible: false,
    pickerKeyword: '',
    pickerGroups: [],
    groups: [],
    selectedPoint: null,
    selectedPointDetail: null,
    selectedExam: null,
    selectedMistake: null,
    questionContext: null,
    answerRecord: null,
    contextMode: 'none',
    contextName: '',
    contextType: '',
    messages: [],
    inputMessage: '',
    isTyping: false,
    scrollToId: 'msg-bottom',
    aiStyles: constants.aiStyleNames,
    aiStyleIds: constants.aiStyleIds,
    aiStyleIndex: 0,
    styleVisible: false,
    composeVisible: false,
    composeCount: 3,
    welcomeMsg: '准备好了~ 随便抛个问题过来吧！'
  },

  onLoad: function () {
    this.loadKnowledgeGraph()
    this.loadSubjects()
    this.restoreSession()
  },

  onShow: function () {
    if (this.data.messages && this.data.messages.length > 0) this.scrollToBottom()
  },

  onHide: function () {
    this.saveSession()
  },

  onUnload: function () {
    this.saveSession()
  },

  saveSession: function () {
    var data = this.data
    try {
      wx.setStorageSync('ai_session', {
        messages: data.messages,
        selectedSubject: data.selectedSubject,
        selectedPoint: data.selectedPoint,
        selectedExam: data.selectedExam,
        selectedMistake: data.selectedMistake,
        contextMode: data.contextMode,
        contextName: data.contextName,
        contextType: data.contextType,
        aiStyleIndex: data.aiStyleIndex,
        inputMessage: data.inputMessage
      })
    } catch (e) {}
  },

  restoreSession: function () {
    try {
      var session = wx.getStorageSync('ai_session')
      if (!session) return
      this.setData({
        messages: session.messages || [],
        selectedSubject: session.selectedSubject || '',
        selectedPoint: session.selectedPoint || null,
        selectedExam: session.selectedExam || null,
        selectedMistake: session.selectedMistake || null,
        contextMode: session.contextMode || 'none',
        contextName: session.contextName || '',
        contextType: session.contextType || '',
        aiStyleIndex: session.aiStyleIndex || 0,
        inputMessage: session.inputMessage || ''
      })
    } catch (e) {}
  },

  // ====== Subjects ======

  loadSubjects: function () {
    var _this = this
    app.formPost('/api/wx/student/subject/list', {}).then(function (res) {
      if (res.code === 1 && res.response && res.response.length > 0) {
        var subjects = res.response
        var names = []
        var nameToId = {}
        for (var i = 0; i < subjects.length; i++) {
          var s = subjects[i]
          if (s.deleted) continue
          names.push(s.name)
          nameToId[s.name] = s.id
        }
        _this.setData({ subjects: names, subjectNameToId: nameToId })
      }
    }).catch(function () {})
  },

  // ====== Knowledge graph ======

  loadKnowledgeGraph: function () {
    var _this = this
    app.formPost('/api/wx/student/knowledge-graph/graph', {}).then(function (res) {
      if (res.code === 1) {
        var data = res.response || {}
        _this.setData({ groups: _this.buildGroups(data.nodes || [], data.categories || []) })
      }
    }).catch(function (e) {
      app.message('加载知识图谱失败', 'error')
    })
  },

  buildGroups: function (nodes, categories) {
    var pointNodes = []
    var i, node
    for (i = 0; i < nodes.length; i++) {
      if (nodes[i].type === 'knowledge_point') pointNodes.push(nodes[i])
    }
    var groupMap = {}
    for (i = 0; i < categories.length; i++) {
      var catName = (typeof categories[i] === 'string') ? categories[i] : (categories[i].name || '')
      if (catName) groupMap[catName] = []
    }
    for (i = 0; i < pointNodes.length; i++) {
      node = pointNodes[i]
      var catIdx = node.category
      var groupName = ''
      if (typeof catIdx === 'number' && catIdx < categories.length) {
        var cat = categories[catIdx]
        groupName = (typeof cat === 'string') ? cat : (cat.name || '')
      }
      if (!groupName) groupName = node.subjectName || node.categoryName || '未分类'
      if (!groupMap[groupName]) groupMap[groupName] = []
      groupMap[groupName].push({ id: node.id, name: node.name, description: node.description || '' })
    }
    return groupMap
  },

  // ====== Four grid actions ======

  toggleSubject: function () {
    if (this.data.selectedSubject) {
      this.setData({ selectedSubject: '', selectedPoint: null, selectedPointDetail: null })
    } else {
      this.setData({ subjectPickerVisible: true })
    }
  },

  confirmSubjectPick: function (e) {
    var subject = e.currentTarget.dataset.subject
    this.setData({ selectedSubject: subject, selectedPoint: null, selectedPointDetail: null, subjectPickerVisible: false })
  },

  clearSubjectPick: function () {
    this.setData({ selectedSubject: '', selectedPoint: null, selectedPointDetail: null, subjectPickerVisible: false })
  },

  closeSubjectPicker: function () {
    this.setData({ subjectPickerVisible: false })
  },

  toggleKnowledge: function () {
    if (this.data.selectedPoint) {
      this.setData({ selectedPoint: null, selectedPointDetail: null })
    } else {
      var groups = this.buildPickerGroups('')
      this.setData({ knowledgePickerVisible: true, pickerKeyword: '', pickerGroups: groups })
    }
  },

  confirmKnowledgePick: function (e) {
    var point = { id: e.currentTarget.dataset.id, name: e.currentTarget.dataset.name, description: e.currentTarget.dataset.desc || '' }
    var groupName = e.currentTarget.dataset.group
    var update = { selectedPoint: point, knowledgePickerVisible: false }
    if (!this.data.selectedSubject && groupName) {
      update.selectedSubject = groupName
    }
    this.setData(update)
  },

  loadPointDetail: function (id) {
    var _this = this
    app.formPost('/api/wx/student/knowledge-graph/knowledge-point/' + id, {}).then(function (res) {
      if (res.code === 1) {
        _this.setData({ selectedPointDetail: res.response || {} })
      }
    }).catch(function (e) {
      app.message('加载知识点详情失败', 'error')
    })
  },

  clearKnowledgePick: function () {
    this.setData({ selectedPoint: null, selectedPointDetail: null, knowledgePickerVisible: false })
  },

  closeKnowledgePicker: function () {
    this.setData({ knowledgePickerVisible: false })
  },

  onPickerSearch: function (e) {
    var keyword = (e.detail.value || '').trim().toLowerCase()
    this.setData({ pickerKeyword: e.detail.value || '', pickerGroups: this.buildPickerGroups(keyword) })
  },

  buildPickerGroups: function (keyword) {
    var groups = this.data.groups
    var subject = this.data.selectedSubject
    var result = []
    var keys = Object.keys(groups)
    for (var i = 0; i < keys.length; i++) {
      if (subject && keys[i] !== subject) continue
      var pts = groups[keys[i]]
      var filtered = []
      for (var j = 0; j < pts.length; j++) {
        if (!keyword || pts[j].name.toLowerCase().indexOf(keyword) >= 0 || (pts[j].description || '').toLowerCase().indexOf(keyword) >= 0) {
          filtered.push(pts[j])
        }
      }
      if (filtered.length > 0) result.push({ name: keys[i], points: filtered })
    }
    return result
  },

  // ====== 真题: fetch real exam question ======

  randomExam: function () {
    var _this = this
    var point = _this.data.selectedPoint

    _this.setData({ isTyping: true })

    if (point && point.id) {
      _this.fetchRelatedQuestionsAndPick(point.id)
    } else {
      var subject = _this.data.selectedSubject
      _this.fetchRandomExamFromAll(subject)
    }
  },

  fetchRelatedQuestionsAndPick: function (pointId) {
    var _this = this
    app.formPost('/api/wx/student/knowledge-graph/knowledge-point/' + pointId + '/questions', { limit: 20 }).then(function (res) {
      if (res.code === 1 && res.response && res.response.length > 0) {
        var questions = res.response
        var idx = Math.floor(Math.random() * questions.length)
        var q = questions[idx]
        _this.setExamContext(q)
      } else {
        _this.setData({ isTyping: false })
        app.message('该知识点暂无真题', 'error')
      }
    }).catch(function () {
      _this.setData({ isTyping: false })
      app.message('获取真题失败', 'error')
    })
  },

  fetchRandomExamFromAll: function (subject) {
    var _this = this
    var groups = _this.data.groups
    var allPoints = []
    var keys = Object.keys(groups)
    for (var i = 0; i < keys.length; i++) {
      if (subject && keys[i] !== subject) continue
      var pts = groups[keys[i]]
      for (var j = 0; j < pts.length; j++) {
        allPoints.push(pts[j])
      }
    }
    if (allPoints.length === 0) {
      _this.setData({ isTyping: false })
      app.message('暂无可用的知识点', 'error')
      return
    }

    var shuffled = allPoints.slice().sort(function () { return Math.random() - 0.5 })
    var tried = 0

    var tryNext = function () {
      if (tried >= shuffled.length || tried >= 5) {
        _this.setData({ isTyping: false })
        app.message('暂无真题可推荐', 'error')
        return
      }
      var pt = shuffled[tried++]
      app.formPost('/api/wx/student/knowledge-graph/knowledge-point/' + pt.id + '/questions', { limit: 10 }).then(function (res) {
        if (res.code === 1 && res.response && res.response.length > 0) {
          var questions = res.response
          var idx = Math.floor(Math.random() * questions.length)
          _this.setExamContext(questions[idx])
        } else {
          tryNext()
        }
      }).catch(function () {
        tryNext()
      })
    }
    tryNext()
  },

  setExamContext: function (q) {
    var shortTitle = q.title || ('真题 #' + q.id)
    if (shortTitle.length > 24) shortTitle = shortTitle.substring(0, 24) + '...'
    var questionTypeMap = constants.questionTypeMap

    this.setData({
      isTyping: false,
      selectedExam: { id: q.id, name: shortTitle, source: q.source || '' },
      selectedMistake: null,
      questionContext: {
        id: q.id,
        source: q.source || '',
        title: q.title || '',
        body: q.title || '',
        questionType: q.questionType,
        questionTypeName: questionTypeMap[q.questionType] || '未知',
        subjectId: q.subjectId,
        sourceYear: q.sourceYear || ''
      },
      answerRecord: null,
      contextMode: 'question',
      contextName: shortTitle,
      contextType: 'exam_question'
    })
    this.updateWelcome()
  },

  // ====== 错题: fetch real wrong answer ======

  randomMistake: function () {
    var _this = this
    var subject = _this.data.selectedSubject
    var point = _this.data.selectedPoint

    _this.setData({ isTyping: true })

    var queryParam = { pageIndex: 1, pageSize: 50 }
    if (subject) {
      var subjectMap = _this.data.subjectNameToId
      if (subjectMap[subject]) queryParam.subjectId = subjectMap[subject]
    }

    app.formPost('/api/wx/student/question/answer/page', queryParam).then(function (res) {
      if (res.code === 1 && res.response && res.response.list && res.response.list.length > 0) {
        var items = res.response.list
        var idx = Math.floor(Math.random() * items.length)
        var item = items[idx]
        _this.fetchWrongAnswerDetail(item.id)
      } else {
        _this.setData({ isTyping: false })
        app.message('错题本暂无记录', 'error')
      }
    }).catch(function () {
      _this.setData({ isTyping: false })
      app.message('获取错题失败', 'error')
    })
  },

  fetchWrongAnswerDetail: function (answerId) {
    var _this = this
    app.formPost('/api/wx/student/question/answer/select/' + answerId, {}).then(function (res) {
      if (res.code === 1 && res.response) {
        var qVM = res.response.questionVM || {}
        var aVM = res.response.questionAnswerVM || res.response.questionAnswer || {}
        _this.setWrongContext(qVM, aVM, answerId)
      } else {
        _this.setData({ isTyping: false })
        app.message('获取错题详情失败', 'error')
      }
    }).catch(function () {
      _this.setData({ isTyping: false })
      app.message('获取错题详情失败', 'error')
    })
  },

  setWrongContext: function (qVM, aVM, answerId) {
    var questionTypeMap = constants.questionTypeMap
    var title = qVM.titleContent || qVM.title || ''
    var shortTitle = title
    if (shortTitle.length > 24) shortTitle = shortTitle.substring(0, 24) + '...'

    var options = []
    if (qVM.items && qVM.items.length > 0) {
      for (var i = 0; i < qVM.items.length; i++) {
        options.push({ key: qVM.items[i].prefix, text: qVM.items[i].content })
      }
    }

    var correctAnswer = qVM.correct || ''
    if (qVM.questionType === 4 && qVM.correctArray) {
      correctAnswer = qVM.correctArray.join(', ')
    }

    this.setData({
      isTyping: false,
      selectedExam: null,
      selectedMistake: { id: qVM.id, shortTitle: shortTitle },
      questionContext: {
        id: qVM.id,
        source: qVM.source || '',
        title: title,
        body: title,
        options: options,
        correctAnswer: correctAnswer,
        analysis: qVM.analyze || '',
        questionType: qVM.questionType,
        questionTypeName: questionTypeMap[qVM.questionType] || '未知'
      },
      answerRecord: {
        answerId: answerId,
        userAnswer: aVM.answer || aVM.userAnswer || '',
        correct: false,
        doTime: aVM.doTime || ''
      },
      contextMode: 'question',
      contextName: shortTitle,
      contextType: 'wrong_question'
    })
    this.updateWelcome()
  },

  // ====== Context ======

  updateWelcome: function () {
    var msg = '准备好了~ 随便抛个问题过来吧！'
    if (this.data.contextType === 'knowledge' && this.data.selectedPoint) {
      msg = '这个知识点我熟，想了解哪方面？'
    } else if (this.data.contextType === 'exam_question') {
      msg = '真题已就绪，想了解哪方面？'
    } else if (this.data.contextType === 'wrong_question') {
      msg = '错题已就绪，我来帮你分析！'
    }
    this.setData({ welcomeMsg: msg })
  },

  clearContext: function () {
    this.setData({
      selectedPoint: null, selectedPointDetail: null,
      selectedExam: null, selectedMistake: null,
      questionContext: null, answerRecord: null,
      contextMode: 'none', contextName: '', contextType: ''
    })
    this.updateWelcome()
  },

  // ====== Chat ======

  onInput: function (e) { this.setData({ inputMessage: e.detail.value, canSend: !!(e.detail.value || '').trim() }) },

  sendMessage: function () {
    var msg = (this.data.inputMessage || '').trim()
    if (!msg || this.data.isTyping) return
    this.sendDirect(msg)
    this.setData({ inputMessage: '', canSend: false })
  },

  sendDirect: function (msg) {
    var userMsg = { role: 'user', content: msg, html: markdown.renderMarkdown(msg) }
    this.setData({ messages: this.data.messages.concat([userMsg]), isTyping: true })
    this.scrollToBottom()
    this.callWorkbench(msg)
  },

  callWorkbench: function (userMessage) {
    var _this = this
    var payload = {
      intent: this.resolveIntent(userMessage),
      style: this.data.aiStyleIds[this.data.aiStyleIndex],
      userMessage: userMessage
    }
    var ctx = this.buildContext()
    if (ctx) payload.context = ctx

    app.jsonPost('/api/wx/student/ai/workbench', payload).then(function (res) {
      _this.setData({ isTyping: false })
      if (res.code === 1) {
        var data = res.response || {}
        var assistantMsg = { role: 'assistant', content: data.analysis || '', html: data.analysis ? markdown.renderMarkdown(data.analysis) : '' }
        if (data.agentDraft) assistantMsg.agentDraft = data.agentDraft
        _this.setData({ messages: _this.data.messages.concat([assistantMsg]) })
      } else {
        _this.setData({ messages: _this.data.messages.concat([{ role: 'assistant', content: '处理失败：' + (res.message || ''), html: '<p>处理失败</p>' }]) })
      }
      _this.scrollToBottom()
    }).catch(function (e) {
      _this.setData({ isTyping: false })
      app.message(e || '网络错误', 'error')
    })
  },

  resolveIntent: function (msg) {
    if (!msg) return 'free_chat'
    var lower = msg.toLowerCase()
    if (lower.indexOf('组卷') >= 0 || lower.indexOf('出题') >= 0 || lower.indexOf('练习') >= 0) return 'practice_plan'
    if (lower.indexOf('画像') >= 0 || lower.indexOf('复习建议') >= 0) return 'learning_profile'
    if (this.data.contextType === 'wrong_question' || this.data.contextType === 'exam_question') return 'explain_question'
    if (this.data.contextType === 'knowledge') return 'explain_knowledge'
    return 'free_chat'
  },

  buildContext: function () {
    var ctxType = this.data.contextType
    if (!ctxType || ctxType === 'none') return null

    var ctx = { contextType: ctxType }

    if (ctxType === 'knowledge' && this.data.selectedPoint) {
      var detail = this.data.selectedPointDetail || {}
      var relatedIds = []
      if (detail.relatedQuestions) {
        for (var i = 0; i < detail.relatedQuestions.length; i++) {
          if (detail.relatedQuestions[i].id) relatedIds.push(detail.relatedQuestions[i].id)
        }
      }
      ctx.knowledgePoint = {
        id: this.data.selectedPoint.id,
        name: this.data.selectedPoint.name,
        summary: detail.summaryText || '',
        description: this.data.selectedPoint.description || '',
        htmlRef: detail.htmlRef || '',
        sourceUrl: detail.sourceUrl || '',
        relatedQuestionIds: relatedIds
      }
      if (detail.subjectId) ctx.subjectId = detail.subjectId
      if (detail.subjectName) ctx.subjectName = detail.subjectName
    }

    if ((ctxType === 'exam_question' || ctxType === 'wrong_question') && this.data.questionContext) {
      ctx.question = {
        id: this.data.questionContext.id,
        source: this.data.questionContext.source || '',
        title: this.data.questionContext.title || '',
        body: this.data.questionContext.body || '',
        options: this.data.questionContext.options || [],
        correctAnswer: this.data.questionContext.correctAnswer || '',
        analysis: this.data.questionContext.analysis || '',
        questionType: this.data.questionContext.questionType,
        sourceYear: this.data.questionContext.sourceYear || ''
      }
      if (this.data.questionContext.subjectId) ctx.subjectId = this.data.questionContext.subjectId
    }

    if (ctxType === 'wrong_question' && this.data.answerRecord) {
      ctx.answerRecord = {
        answerId: this.data.answerRecord.answerId,
        userAnswer: this.data.answerRecord.userAnswer,
        correct: false,
        doTime: this.data.answerRecord.doTime
      }
    }

    return ctx
  },

  scrollToBottom: function () { var _this = this; setTimeout(function () { _this.setData({ scrollToId: 'msg-bottom' }) }, 100) },

  // ====== Compose from top ======

  onComposeTap: function () {
    this.setData({ composeVisible: true })
  },

  doWeakCompose: function () {
    var _this = this
    var msg = '请根据我的错题记录生成针对性练习'
    var userMsg = { role: 'user', content: msg, html: markdown.renderMarkdown(msg) }
    _this.setData({ messages: _this.data.messages.concat([userMsg]), isTyping: true })
    _this.scrollToBottom()

    var payload = {
      intent: 'practice_plan',
      style: _this.data.aiStyleIds[_this.data.aiStyleIndex],
      userMessage: msg
    }
    app.jsonPost('/api/wx/student/ai/workbench', payload).then(function (res) {
      _this.setData({ isTyping: false })
      if (res.code === 1) {
        var data = res.response || {}
        var assistantMsg = { role: 'assistant', content: data.analysis || '', html: data.analysis ? markdown.renderMarkdown(data.analysis) : '' }
        if (data.agentDraft) assistantMsg.agentDraft = data.agentDraft
        _this.setData({ messages: _this.data.messages.concat([assistantMsg]) })
      } else {
        _this.setData({ messages: _this.data.messages.concat([{ role: 'assistant', content: '处理失败：' + (res.message || ''), html: '<p>处理失败</p>' }]) })
      }
      _this.scrollToBottom()
    }).catch(function (e) {
      _this.setData({ isTyping: false })
      app.message(e || '网络错误', 'error')
    })
  },

  // ====== Action bar ======

  quickAction: function (e) {
    var action = e.currentTarget.dataset.action
    if (action === 'compose') {
      this.setData({ composeVisible: true })
      return
    }
    var _this = this
    var msg = '请分析我的薄弱知识点并给出复习建议'
    var userMsg = { role: 'user', content: msg, html: markdown.renderMarkdown(msg) }
    _this.setData({ messages: _this.data.messages.concat([userMsg]), isTyping: true })
    _this.scrollToBottom()

    app.formPost('/api/wx/student/user/stats', {}).then(function (statsRes) {
      var payload = {
        intent: 'learning_profile',
        style: _this.data.aiStyleIds[_this.data.aiStyleIndex],
        userMessage: msg
      }
      var ctx = _this.buildContext()
      if (!ctx) ctx = { contextType: 'none' }
      if (statsRes.code === 1 && statsRes.response) {
        ctx.userStats = statsRes.response
      }
      payload.context = ctx
      app.jsonPost('/api/wx/student/ai/workbench', payload).then(function (res) {
        _this.setData({ isTyping: false })
        if (res.code === 1) {
          var data = res.response || {}
          var assistantMsg = { role: 'assistant', content: data.analysis || '', html: data.analysis ? markdown.renderMarkdown(data.analysis) : '' }
          if (data.agentDraft) assistantMsg.agentDraft = data.agentDraft
          _this.setData({ messages: _this.data.messages.concat([assistantMsg]) })
        } else {
          _this.setData({ messages: _this.data.messages.concat([{ role: 'assistant', content: '处理失败：' + (res.message || ''), html: '<p>处理失败</p>' }]) })
        }
        _this.scrollToBottom()
      }).catch(function (e) {
        _this.setData({ isTyping: false })
        app.message(e || '网络错误', 'error')
      })
    }).catch(function () {
      _this.setData({ isTyping: false })
      app.message('获取学习统计失败', 'error')
    })
  },

  onPaste: function () {
    var _this = this
    wx.getClipboardData({
      success: function (res) {
        if (res.data) {
          var current = _this.data.inputMessage || ''
          _this.setData({ inputMessage: current + res.data, canSend: true })
        }
      }
    })
  },

  clearChat: function () {
    this.setData({ messages: [], inputMessage: '', canSend: false })
    this.saveSession()
  },

  // ====== Style ======

  showStylePicker: function () { this.setData({ styleVisible: true }) },
  closeStyle: function () { this.setData({ styleVisible: false }) },
  selectStyle: function (e) { this.setData({ aiStyleIndex: parseInt(e.currentTarget.dataset.index), styleVisible: false }) },

  // ====== Compose ======

  closeCompose: function () { this.setData({ composeVisible: false }) },
  changeCount: function (e) {
    var c = this.data.composeCount + parseInt(e.currentTarget.dataset.delta)
    if (c < 1) c = 1; if (c > 10) c = 10
    this.setData({ composeCount: c })
  },

  doCompose: function () {
    var _this = this
    var point = _this.data.selectedPoint
    var count = _this.data.composeCount
    var hasSubject = !!_this.data.selectedSubject
    var subjectId = _this.data.subjectNameToId ? _this.data.subjectNameToId[_this.data.selectedSubject] : null
    _this.setData({ composeVisible: false })

    var label = hasSubject ? ('生成' + count + '道练习') : ('生成' + count + '道错题练习')
    var userMsg = { role: 'user', content: label, html: '<p>' + label + '</p>' }
    _this.setData({ messages: _this.data.messages.concat([userMsg]), isTyping: true })
    _this.scrollToBottom()

    app.jsonPost('/api/wx/student/ai/agent/plan', {
      message: hasSubject ? '生成练习' : '根据错题生成练习',
      subjectId: subjectId,
      contextKnowledgePoint: point ? point.name : '',
      questionCount: count, minutes: Math.max(count * 3, 10), preferMistakes: !hasSubject
    }).then(function (res) {
      _this.setData({ isTyping: false })
      if (res.code === 1 && res.response) {
        var plan = res.response
        if (plan.candidateEnough && plan.candidateQuestionIds && plan.candidateQuestionIds.length > 0) {
          var assistantMsg = {
            role: 'assistant',
            content: '已为你准备好练习草案',
            html: '<p>已为你准备好练习草案</p>',
            agentDraft: plan
          }
          _this.setData({ messages: _this.data.messages.concat([assistantMsg]) })
          _this.scrollToBottom()
        } else {
          _this.setData({ messages: _this.data.messages.concat([{ role: 'assistant', content: '题目不足，请换一个知识点试试', html: '<p>题目不足，请换一个知识点试试</p>' }]) })
          _this.scrollToBottom()
        }
      } else {
        _this.setData({ messages: _this.data.messages.concat([{ role: 'assistant', content: '生成失败：' + (res.message || ''), html: '<p>生成失败</p>' }]) })
        _this.scrollToBottom()
      }
    }).catch(function () {
      _this.setData({ isTyping: false })
      app.message('网络错误', 'error')
    })
  },

  confirmDraft: function (e) {
    var draft = this.data.messages[e.currentTarget.dataset.index].agentDraft
    if (!draft) return
    var _this = this
    _this.setData({ isTyping: true })
    app.jsonPost('/api/wx/student/ai/agent/confirm', {
      title: draft.title || 'AI练习', knowledgePoint: draft.knowledgePoint || '',
      questionCount: draft.questionCount || 3, minutes: draft.minutes || 10,
      preferMistakes: draft.preferMistakes !== false, questionIds: draft.candidateQuestionIds || [], runLogId: draft.runLogId
    }).then(function (res) {
      _this.setData({ isTyping: false })
      if (res.code === 1 && res.response) { wx.navigateTo({ url: '/pages/exam/do/index?id=' + res.response.paperId }) }
      else { app.message(res.message || '组卷失败', 'error') }
    }).catch(function () { _this.setData({ isTyping: false }); app.message('确认失败', 'error') })
  }
})
