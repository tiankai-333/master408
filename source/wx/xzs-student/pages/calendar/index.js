const app = getApp()

Page({
  data: {
    year: 2026,
    month: 5,
    weeks: [],
    selectedDate: '',
    dayDetail: null,
    monthData: {},
    weekdays: ['日', '一', '二', '三', '四', '五', '六']
  },

  onLoad() {
    const now = new Date()
    const year = now.getFullYear()
    const month = now.getMonth() + 1
    this.setData({
      year,
      month,
      selectedDate: this.formatDate(now)
    })
    this.buildCalendar(year, month)
    this.loadMonthData()
  },

  onShow() {
    this.loadMonthData()
  },

  formatDate(d) {
    const y = d.getFullYear()
    const m = String(d.getMonth() + 1).padStart(2, '0')
    const day = String(d.getDate()).padStart(2, '0')
    return y + '-' + m + '-' + day
  },

  prevMonth() {
    let { year, month } = this.data
    month--
    if (month < 1) { month = 12; year-- }
    this.setData({ year, month })
    this.buildCalendar(year, month)
    this.loadMonthData()
  },

  nextMonth() {
    let { year, month } = this.data
    month++
    if (month > 12) { month = 1; year++ }
    this.setData({ year, month })
    this.buildCalendar(year, month)
    this.loadMonthData()
  },

  buildCalendar(year, month) {
    if (year === undefined) { year = this.data.year }
    if (month === undefined) { month = this.data.month }
    const firstDay = new Date(year, month - 1, 1).getDay()
    const daysInMonth = new Date(year, month, 0).getDate()
    const today = this.formatDate(new Date())

    const days = []
    for (let i = 0; i < firstDay; i++) {
      days.push({ day: '', date: '', isToday: false, hasStudy: false })
    }
    for (let d = 1; d <= daysInMonth; d++) {
      const date = year + '-' + String(month).padStart(2, '0') + '-' + String(d).padStart(2, '0')
      days.push({
        day: d,
        date,
        isToday: date === today,
        hasStudy: false
      })
    }

    const weeks = []
    for (let i = 0; i < days.length; i += 7) {
      weeks.push(days.slice(i, i + 7))
    }

    this.setData({ weeks })
  },

  loadMonthData() {
    const { year, month } = this.data
    const monthStr = year + '-' + String(month).padStart(2, '0')
    const _this = this

    app.formPost('/api/wx/student/user/calendar', { month: monthStr }).then(res => {
      if (res.code === 1 && res.response && res.response.days) {
        const map = {}
        res.response.days.forEach(d => { map[d.date] = d })
        _this.setData({ monthData: map })
        _this.updateStudyDots()
        _this.updateDayDetail()
      }
    }).catch(() => {
      _this.setData({ monthData: {} })
    })
  },

  updateStudyDots() {
    const { weeks, monthData } = this.data
    const updated = weeks.map(week =>
      week.map(day => ({
        ...day,
        hasStudy: !!(monthData[day.date] && monthData[day.date].questionCount > 0)
      }))
    )
    this.setData({ weeks: updated })
  },

  selectDay(e) {
    const date = e.currentTarget.dataset.date
    if (!date) return
    this.setData({ selectedDate: date })
    this.updateDayDetail()
  },

  updateDayDetail() {
    const { selectedDate, monthData } = this.data
    const detail = monthData[selectedDate] || null
    this.setData({ dayDetail: detail })
  },

  goPractice() {
    wx.switchTab({ url: '/pages/practice/index' })
  }
})
