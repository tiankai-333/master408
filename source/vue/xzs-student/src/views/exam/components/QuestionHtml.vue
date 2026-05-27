<template>
  <span v-if="inline" v-html="rendered" />
  <div v-else v-html="rendered" />
</template>

<script setup>
import { ref, watch } from 'vue'

const props = defineProps({
  content: {
    type: String,
    default: ''
  },
  inline: {
    type: Boolean,
    default: false
  }
})

const rendered = ref('')
let requestId = 0

const escapeHtml = (value) => String(value)
  .replace(/&/g, '&amp;')
  .replace(/</g, '&lt;')
  .replace(/>/g, '&gt;')
  .replace(/"/g, '&quot;')
  .replace(/'/g, '&#39;')

const resolveAssetUrl = (src) => {
  if (!src) return ''
  if (/^https?:\/\//i.test(src) || src.startsWith('/')) return src
  const base = import.meta.env.BASE_URL || '/'
  return `${base.replace(/\/$/, '')}/${src.replace(/^\//, '')}`
}

const renderContent = async (content) => {
  const current = ++requestId
  if (!content) {
    rendered.value = ''
    return
  }

  const parser = new DOMParser()
  const doc = parser.parseFromString(`<div>${content}</div>`, 'text/html')
  const refs = Array.from(doc.querySelectorAll('.question-html-ref[data-src]'))

  if (!refs.length) {
    rendered.value = content
    return
  }

  for (const ref of refs) {
    const fallback = ref.getAttribute('data-fallback') || '题目内容加载中...'
    try {
      const response = await fetch(resolveAssetUrl(ref.getAttribute('data-src')), { cache: 'force-cache' })
      if (!response.ok) throw new Error(`HTTP ${response.status}`)
      ref.outerHTML = await response.text()
    } catch (e) {
      ref.outerHTML = `<p>${escapeHtml(fallback)}</p>`
    }
  }

  if (current === requestId) {
    rendered.value = doc.body.firstElementChild?.innerHTML || content
  }
}

watch(() => props.content, renderContent, { immediate: true })
</script>
