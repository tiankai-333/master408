function escapeHtml(text) {
  return String(text)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
}

function renderInlineMarkdown(text) {
  return escapeHtml(text)
    .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
    .replace(/\*(.*?)\*/g, '<em>$1</em>')
    .replace(/`(.*?)`/g, '<code>$1</code>')
    .replace(/\[([^\]]+)\]\((https?:\/\/[^)\s]+)\)/g, '<a href="$2">$1</a>')
}

function normalizeMarkdown(content) {
  return content
    .replace(/\r\n/g, '\n')
    .replace(/([^\n])\s*(#{1,4})(?=\S)/g, '$1\n\n$2 ')
    .replace(/^(#{1,4})(\S)/gm, '$1 $2')
    .replace(/([。；;：:！!?？])\s*(\d+\.\s*\S)/g, '$1\n$2')
}

function renderMarkdown(content) {
  var lines = normalizeMarkdown(content).split('\n')
  var html = []
  var listType = ''
  var inCode = false
  var codeLines = []

  function closeList() {
    if (listType) {
      html.push('</' + listType + '>')
      listType = ''
    }
  }

  function openList(type) {
    if (listType !== type) {
      closeList()
      html.push('<' + type + '>')
      listType = type
    }
  }

  for (var i = 0; i < lines.length; i++) {
    var line = lines[i]

    if (line.trim().indexOf('```') === 0) {
      if (inCode) {
        html.push('<pre><code>' + escapeHtml(codeLines.join('\n')) + '</code></pre>')
        codeLines = []
        inCode = false
      } else {
        closeList()
        inCode = true
      }
      continue
    }

    if (inCode) {
      codeLines.push(line)
      continue
    }

    var trimmed = line.trim()
    if (!trimmed) {
      closeList()
      continue
    }

    if (/^---+$/.test(trimmed)) {
      closeList()
      html.push('<hr>')
      continue
    }

    var heading = trimmed.match(/^(#{1,4})\s+(.+)$/)
    if (heading) {
      closeList()
      var level = Math.min(heading[1].length + 1, 4)
      html.push('<h' + level + '>' + renderInlineMarkdown(heading[2]) + '</h' + level + '>')
      continue
    }

    var quote = trimmed.match(/^>\s+(.+)$/)
    if (quote) {
      closeList()
      html.push('<blockquote>' + renderInlineMarkdown(quote[1]) + '</blockquote>')
      continue
    }

    var listItem = trimmed.match(/^[-*]\s+(.+)$/)
    if (listItem) {
      openList('ul')
      html.push('<li>' + renderInlineMarkdown(listItem[1]) + '</li>')
      continue
    }

    var numberedItem = trimmed.match(/^\d+\.\s+(.+)$/)
    if (numberedItem) {
      openList('ol')
      html.push('<li>' + renderInlineMarkdown(numberedItem[1]) + '</li>')
      continue
    }

    closeList()
    html.push('<p>' + renderInlineMarkdown(trimmed) + '</p>')
  }

  closeList()
  if (inCode) {
    html.push('<pre><code>' + escapeHtml(codeLines.join('\n')) + '</code></pre>')
  }
  return html.join('')
}

module.exports = { renderMarkdown: renderMarkdown }
