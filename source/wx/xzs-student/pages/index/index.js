var app = getApp()

Page({
  data: {
    spinShow: false,
    userStats: null,
    greeting: '',
    weekdays: ['日', '一', '二', '三', '四', '五', '六'],
    weekDays: [],
    weekLabel: '',
    selectedDate: '',
    dayDetail: null,
    monthData: {},
    weekOffset: 0
  },

  onLoad: function () {
    var now = new Date()
    var h = now.getHours()
    var g = h >= 6 && h < 12 ? '早上好 ☀️' : h >= 12 && h < 14 ? '中午好 🌤' : h >= 14 && h < 18 ? '下午好 🌅' : '晚上好 🌙'
    this.setData({ selectedDate: this.formatDate(now), greeting: g })
    this.buildWeek(0)
  },

  onShow: function () {
    this.loadMonthData()
    this.loadUserStats()
  },

  formatDate: function (d) {
    var y = d.getFullYear()
    var m = (d.getMonth() + 1 < 10 ? '0' : '') + (d.getMonth() + 1)
    var day = (d.getDate() < 10 ? '0' : '') + d.getDate()
    return y + '-' + m + '-' + day
  },

  // ====== Stats ======

  loadUserStats: function () {
    var _this = this
    app.formPost('/api/wx/student/user/stats', {}).then(function (res) {
      if (res.code === 1) {
        _this.setData({ userStats: res.response })
      } else if (res.code !== 401) {
        wx.showToast({ title: res.message || '加载统计失败', icon: 'none', duration: 2000 })
      }
    }).catch(function (e) {
      app.message(e, 'error')
    })
  },

  // ====== Week calendar ======

  prevWeek: function () {
    this.setData({ weekOffset: this.data.weekOffset - 1 })
    this.buildWeek(this.data.weekOffset)
    this.loadMonthData()
  },

  nextWeek: function () {
    this.setData({ weekOffset: this.data.weekOffset + 1 })
    this.buildWeek(this.data.weekOffset)
    this.loadMonthData()
  },

  buildWeek: function (offset) {
    var now = new Date()
    var target = new Date(now.getFullYear(), now.getMonth(), now.getDate() + offset * 7)
    var dow = target.getDay()
    var monday = new Date(target.getFullYear(), target.getMonth(), target.getDate() - dow)

    var today = this.formatDate(new Date())
    var days = []
    var firstDate, lastDate
    for (var i = 0; i < 7; i++) {
      var d = new Date(monday.getFullYear(), monday.getMonth(), monday.getDate() + i)
      var date = this.formatDate(d)
      if (i === 0) firstDate = (d.getMonth() + 1) + '/' + d.getDate()
      if (i === 6) lastDate = (d.getMonth() + 1) + '/' + d.getDate()
      days.push({ day: d.getDate(), date: date, isToday: date === today, hasStudy: false })
    }
    var label = firstDate + ' — ' + lastDate
    this.setData({ weekDays: days, weekLabel: label })
  },

  loadMonthData: function () {
    // Load data for the month(s) that the current week spans
    var _this = this
    var weekDays = this.data.weekDays
    if (!weekDays || weekDays.length === 0) return
    // Derive month from first day of week
    var firstDay = weekDays[0].date
    var parts = firstDay.split('-')
    var monthStr = parts[0] + '-' + parts[1]

    app.formPost('/api/wx/student/user/calendar', { month: monthStr }).then(function (res) {
      if (res.code === 1 && res.response && res.response.days) {
        var map = {}
        res.response.days.forEach(function (d) { map[d.date] = d })
        _this.setData({ monthData: map })
        _this.updateStudyDots()
        _this.updateDayDetail()
      } else if (res.code !== 401) {
        wx.showToast({ title: res.message || '加载日历失败', icon: 'none', duration: 2000 })
      }
    }).catch(function (err) {
      console.error('[calendar] failed:', err)
      _this.setData({ monthData: {} })
    })
  },

  updateStudyDots: function () {
    var emojis = ['😊','😄','🎉','💪','🔥','⭐','🌟','👏','😎','🍀','✨','💯']
    var weekDays = this.data.weekDays
    var monthData = this.data.monthData
    var updated = weekDays.map(function (day) {
      var hasStudy = !!(monthData[day.date] && monthData[day.date].questionCount > 0)
      return {
        day: day.day,
        date: day.date,
        isToday: day.isToday,
        hasStudy: hasStudy,
        emoji: hasStudy ? emojis[Math.floor(Math.random() * emojis.length)] : ''
      }
    })
    this.setData({ weekDays: updated })
  },

  selectDay: function (e) {
    var date = e.currentTarget.dataset.date
    if (!date) return
    this.setData({ selectedDate: date })
    this.updateDayDetail()
  },

  updateDayDetail: function () {
    this.setData({ dayDetail: this.data.monthData[this.data.selectedDate] || null })
  },

  // ====== Navigation ======

  goPage: function (e) {
    var url = e.currentTarget.dataset.url
    if (url) wx.navigateTo({ url: url })
  },

  copyLink: function (e) {
    wx.setClipboardData({
      data: e.currentTarget.dataset.url,
      success: function () {
        wx.showToast({ title: '已复制', icon: 'success' })
      }
    })
  },

  goTab: function (e) {
    var url = e.currentTarget.dataset.url
    if (url) wx.switchTab({ url: url })
  }
})
