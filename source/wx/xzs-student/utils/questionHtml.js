/**
 * Resolve `<div class="question-html-ref" data-src="..." data-fallback="...">`
 * placeholders by fetching external HTML files — mirrors QuestionHtml.vue.
 */

function getStaticBase() {
  return getApp().globalData.staticBase
}

var REF_REGEXP = /<div\s+class="question-html-ref"\s+data-src="([^"]+)"(?:\s+data-fallback="([^"]*)")?\s*><\/div>/g

var IMG_REGEXP = /(<img\s+[^>]*src=")(question-assets\/[^"]+)(")/g

function escapeHtml(value) {
  return String(value)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
}

function fetchHtml(url) {
  console.log('[questionHtml] fetchHtml URL:', url)
  return new Promise(function (resolve) {
    wx.request({
      url: url,
      method: 'GET',
      dataType: 'text',
      success: function (res) {
        if (res.statusCode === 200 && typeof res.data === 'string') {
          resolve(res.data)
        } else {
          console.warn('[questionHtml] fetchHtml fail:', url, 'status:', res.statusCode)
          resolve(null)
        }
      },
      fail: function (err) {
        console.error('[questionHtml] fetchHtml error:', url, err)
        resolve(null)
      }
    })
  })
}

function fixImageUrls(html) {
  var base = getStaticBase()
  return html.replace(IMG_REGEXP, '$1' + base + '$2$3')
}

function hasRef(html) {
  return html && html.indexOf('question-html-ref') !== -1
}

/**
 * Resolve a single HTML string that may contain question-html-ref placeholders.
 * Returns a Promise<string> with the resolved HTML.
 */
function resolveQuestionHtml(html) {
  if (!html || !hasRef(html)) {
    return Promise.resolve(html)
  }

  var base = getStaticBase()
  console.log('[questionHtml] staticBase:', base, 'resolving html length:', html.length)

  var matches = []
  var match
  REF_REGEXP.lastIndex = 0
  while ((match = REF_REGEXP.exec(html)) !== null) {
    matches.push({ src: match[1], fallback: match[2] || '', full: match[0] })
  }

  if (matches.length === 0) {
    return Promise.resolve(html)
  }
  var fetches = matches.map(function (m) {
    var url = base + m.src
    return fetchHtml(url).then(function (content) {
      return { ref: m, content: content }
    })
  })

  return Promise.all(fetches).then(function (results) {
    var resolved = html
    for (var i = 0; i < results.length; i++) {
      var r = results[i]
      if (r.content) {
        resolved = resolved.replace(r.ref.full, fixImageUrls(r.content))
      } else {
        resolved = resolved.replace(r.ref.full, '<p>' + escapeHtml(r.ref.fallback) + '</p>')
      }
    }
    return resolved
  })
}

/**
 * Resolve all question-html-ref placeholders in an exam paper object.
 * The paper has structure: paper.titleItems[].questionItems[]
 * Each questionItem may have title and analyze fields to resolve.
 * Returns a Promise<paper> with all fields resolved.
 */
function resolveExamPaper(paper) {
  if (!paper || !paper.titleItems) {
    return Promise.resolve(paper)
  }

  var tasks = []

  paper.titleItems.forEach(function (titleItem) {
    if (!titleItem.questionItems) return
    titleItem.questionItems.forEach(function (q) {
      if (hasRef(q.title)) {
        tasks.push(resolveQuestionHtml(q.title).then(function (html) {
          q.title = html
        }))
      }
      if (hasRef(q.analyze)) {
        tasks.push(resolveQuestionHtml(q.analyze).then(function (html) {
          q.analyze = html
        }))
      }
    })
  })

  if (tasks.length === 0) {
    return Promise.resolve(paper)
  }

  return Promise.all(tasks).then(function () {
    return paper
  })
}

/**
 * Resolve questionVM in an error-book detail response.
 */
function resolveQuestionVM(questionVM) {
  if (!questionVM) {
    return Promise.resolve(questionVM)
  }

  var tasks = []
  if (hasRef(questionVM.title)) {
    tasks.push(resolveQuestionHtml(questionVM.title).then(function (html) {
      questionVM.title = html
    }))
  }
  if (hasRef(questionVM.analyze)) {
    tasks.push(resolveQuestionHtml(questionVM.analyze).then(function (html) {
      questionVM.analyze = html
    }))
  }

  if (tasks.length === 0) {
    return Promise.resolve(questionVM)
  }

  return Promise.all(tasks).then(function () {
    return questionVM
  })
}

module.exports = {
  resolveQuestionHtml: resolveQuestionHtml,
  resolveExamPaper: resolveExamPaper,
  resolveQuestionVM: resolveQuestionVM
}
