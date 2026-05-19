import axios from 'axios'
import { ElLoading, ElMessage } from 'element-plus'
import router from '@/router'

const request = function (loadtip, query) {
  let loading
  if (loadtip) {
    loading = ElLoading.service({
      lock: false,
      text: '正在加载中…',
      background: 'rgba(0, 0, 0, 0.5)'
    })
  }
  return axios.request(query)
    .then(res => {
      if (loadtip) {
        loading.close()
      }
      if (res.data.code === 401) {
        router.push({ path: '/login' })
        return Promise.reject(res.data)
      } else if (res.data.code === 500) {
        return Promise.reject(res.data)
      } else if (res.data.code === 501) {
        return Promise.reject(res.data)
      } else if (res.data.code === 502) {
        router.push({ path: '/login' })
        return Promise.reject(res.data)
      } else {
        return Promise.resolve(res.data)
      }
    })
    .catch(e => {
      if (loadtip) {
        loading.close()
      }
      ElMessage.error(e.message)
      return Promise.reject(e.message)
    })
}

const post = function (url, params) {
  const query = {
    url: url,
    method: 'post',
    withCredentials: true,
    timeout: 600000,
    data: params,
    headers: { 'Content-Type': 'application/json', 'request-ajax': true }
  }
  return request(false, query)
}

const postWithLoadTip = function (url, params) {
  const query = {
    url: url,
    method: 'post',
    withCredentials: true,
    timeout: 600000,
    data: params,
    headers: { 'Content-Type': 'application/json', 'request-ajax': true }
  }
  return request(true, query)
}

const get = function (url, params) {
  const query = {
    url: url,
    method: 'get',
    withCredentials: true,
    timeout: 600000,
    params: params,
    headers: { 'request-ajax': true }
  }
  return request(false, query)
}

const form = function (url, params) {
  const query = {
    url: url,
    method: 'post',
    withCredentials: true,
    timeout: 600000,
    data: params,
    headers: { 'Content-Type': 'multipart/form-data', 'request-ajax': true }
  }
  return request(false, query)
}

const postStream = async function (url, params, handlers = {}) {
  const response = await fetch(url, {
    method: 'POST',
    credentials: 'include',
    headers: {
      'Content-Type': 'application/json',
      'request-ajax': 'true'
    },
    body: JSON.stringify(params || {})
  })

  if (!response.ok || !response.body) {
    throw new Error(`请求失败：${response.status}`)
  }

  const reader = response.body.getReader()
  const decoder = new TextDecoder('utf-8')
  let buffer = ''

  const dispatchEvent = (rawEvent) => {
    const lines = rawEvent.split('\n')
    let eventName = 'message'
    const dataLines = []
    lines.forEach(line => {
      if (line.startsWith('event:')) {
        eventName = line.slice(6).trim()
      } else if (line.startsWith('data:')) {
        dataLines.push(line.slice(5).replace(/^ /, ''))
      }
    })
    const data = dataLines.join('\n')
    if (!data && eventName === 'message') return
    if (eventName === 'chunk' && handlers.onChunk) handlers.onChunk(data)
    if (eventName === 'status' && handlers.onStatus) handlers.onStatus(data)
    if (eventName === 'references' && handlers.onReferences) handlers.onReferences(data)
    if (eventName === 'done' && handlers.onDone) handlers.onDone(data)
    if (eventName === 'error' && handlers.onError) handlers.onError(data)
    if (handlers.onEvent) handlers.onEvent(eventName, data)
  }

  while (true) {
    const { done, value } = await reader.read()
    if (done) break
    buffer += decoder.decode(value, { stream: true })
    const parts = buffer.split(/\r?\n\r?\n/)
    buffer = parts.pop() || ''
    parts.forEach(dispatchEvent)
  }
  buffer += decoder.decode()
  if (buffer.trim()) dispatchEvent(buffer)
}

export {
  post,
  postWithLoadTip,
  get,
  form,
  postStream
}
