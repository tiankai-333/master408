<template>
  <div v-html="rendered" />
</template>

<script setup>
import { ref, watch } from 'vue'

const props = defineProps({
  src: {
    type: String,
    default: ''
  },
  fallback: {
    type: String,
    default: ''
  }
})

const rendered = ref('')
let requestId = 0

const escapeHtml = (value) => String(value || '')
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

const renderContent = async () => {
  const current = ++requestId
  if (!props.src) {
    rendered.value = props.fallback ? `<p>${escapeHtml(props.fallback)}</p>` : ''
    return
  }

  try {
    const response = await fetch(resolveAssetUrl(props.src), { cache: 'force-cache' })
    if (!response.ok) throw new Error(`HTTP ${response.status}`)
    const html = await response.text()
    if (current === requestId) {
      rendered.value = html
    }
  } catch (e) {
    if (current === requestId) {
      rendered.value = props.fallback ? `<p>${escapeHtml(props.fallback)}</p>` : '<p>知识点内容暂时无法加载。</p>'
    }
  }
}

watch(() => [props.src, props.fallback], renderContent, { immediate: true })
</script>
