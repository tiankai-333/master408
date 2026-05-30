var app = getApp()

Page({
  data: {
    spinShow: false,
    keyword: '',
    groups: [],
    filteredGroups: [],
    expandedGroup: ''
  },

  onLoad: function () {
    this.setData({ spinShow: true })
    this.loadGraph()
  },

  loadGraph: function () {
    var _this = this
    app.formPost('/api/wx/student/knowledge-graph/graph', {})
      .then(function (res) {
        _this.setData({ spinShow: false })
        if (res.code === 1) {
          var data = res.response || {}
          var nodes = data.nodes || []
          var categories = data.categories || []
          var groups = _this.buildGroups(nodes, categories)
          _this.setData({ groups: groups, filteredGroups: groups })
        }
      }).catch(function (e) {
        _this.setData({ spinShow: false })
        app.message(e, 'error')
      })
  },

  buildGroups: function (nodes, categories) {
    var pointNodes = []
    var i, node
    for (i = 0; i < nodes.length; i++) {
      node = nodes[i]
      if (node.type === 'knowledge_point') {
        pointNodes.push(node)
      }
    }

    var groupMap = {}
    var catName
    for (i = 0; i < categories.length; i++) {
      catName = (typeof categories[i] === 'string') ? categories[i] : (categories[i].name || '')
      if (catName) groupMap[catName] = { name: catName, points: [] }
    }

    for (i = 0; i < pointNodes.length; i++) {
      node = pointNodes[i]
      var catIdx = node.category
      var groupName = ''
      if (typeof catIdx === 'number' && catIdx < categories.length) {
        var cat = categories[catIdx]
        groupName = (typeof cat === 'string') ? cat : (cat.name || '')
      }
      if (!groupName) {
        groupName = node.subjectName || node.categoryName || '未分类'
      }
      if (!groupMap[groupName]) {
        groupMap[groupName] = { name: groupName, points: [] }
      }
      var desc = (node.description || '')
      if (desc.length > 80) desc = desc.substring(0, 80) + '...'
      groupMap[groupName].points.push({
        id: node.id,
        name: node.name,
        description: desc
      })
    }

    var result = []
    for (var key in groupMap) {
      if (groupMap[key].points.length > 0) {
        result.push(groupMap[key])
      }
    }
    return result
  },

  onKeywordInput: function (e) {
    var keyword = (e.detail.value || '').trim().toLowerCase()
    this.setData({ keyword: keyword })
    if (!keyword) {
      this.setData({ filteredGroups: this.data.groups })
      return
    }
    var filtered = []
    var groups = this.data.groups
    for (var i = 0; i < groups.length; i++) {
      var g = groups[i]
      var points = []
      for (var j = 0; j < g.points.length; j++) {
        var p = g.points[j]
        if (p.name.toLowerCase().indexOf(keyword) >= 0 ||
            (p.description || '').toLowerCase().indexOf(keyword) >= 0) {
          points.push(p)
        }
      }
      if (points.length > 0) {
        filtered.push({ name: g.name, points: points })
      }
    }
    this.setData({ filteredGroups: filtered })
  },

  onCollapseChange: function (e) {
    this.setData({ expandedGroup: e.detail })
  },

  goDetail: function (e) {
    var id = e.currentTarget.dataset.id
    wx.navigateTo({ url: '/pages/knowledge/detail/index?id=' + id })
  }
})
