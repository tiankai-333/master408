<template>
  <span>{{ displayValue }}</span>
</template>

<script setup>
import { ref, watch, onMounted, onUnmounted } from 'vue'

const props = defineProps({
  startVal: {
    type: Number,
    default: 0
  },
  endVal: {
    type: Number,
    default: 2017
  },
  duration: {
    type: Number,
    default: 3000
  },
  decimals: {
    type: Number,
    default: 0
  },
  separator: {
    type: String,
    default: ','
  },
  prefix: {
    type: String,
    default: ''
  },
  suffix: {
    type: String,
    default: ''
  }
})

const displayValue = ref(props.startVal)
let rAF = null
let startTime = null
let startVal = props.startVal
let endVal = props.endVal
let decimals = props.decimals
let duration = props.duration

const easeOutQuart = (t, b, c, d) => {
  t /= d
  return -c * (t * t * t * t - 1) + b
}

const formatNumber = (num) => {
  const numStr = num.toFixed(decimals)
  const parts = numStr.split('.')
  parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, separator)
  return props.prefix + parts.join('.') + props.suffix
}

const separator = props.separator

const start = () => {
  startVal = props.startVal
  endVal = props.endVal
  duration = props.duration
  decimals = props.decimals
  startTime = null
  rAF = requestAnimationFrame(count)
}

const count = (timestamp) => {
  if (!startTime) startTime = timestamp
  const progress = timestamp - startTime
  const current = easeOutQuart(progress, startVal, endVal - startVal, duration)
  
  if (progress < duration) {
    displayValue.value = formatNumber(current)
    rAF = requestAnimationFrame(count)
  } else {
    displayValue.value = formatNumber(endVal)
  }
}

const countUp = () => {
  if (rAF) cancelAnimationFrame(rAF)
  start()
}

watch(() => props.endVal, () => {
  countUp()
})

onMounted(() => {
  if (props.autoplay !== false) {
    countUp()
  }
})

onUnmounted(() => {
  if (rAF) cancelAnimationFrame(rAF)
})
</script>