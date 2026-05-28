<template>
  <div v-loading="qLoading" class="question-answer-show">
    <div v-if="effectiveQType === 1 || effectiveQType === 2 || effectiveQType === 3 || effectiveQType === 4 || effectiveQType === 5">
      <div v-if="effectiveQType === 1">
        <QuestionHtml class="q-title" :content="question.title" />
        <div class="q-content">
          <el-radio-group v-model="answer.content">
            <el-radio v-for="(item, index) in choiceItems" :key="choiceKey(item, index)" :label="item.prefix">
              <span class="question-prefix">{{ item.prefix }}.</span>
              <QuestionHtml v-if="item.content" :content="item.content" inline class="q-item-span-content" />
              <span v-else class="q-item-span-content">选项 {{ item.prefix }}</span>
            </el-radio>
          </el-radio-group>
        </div>
      </div>
      <div v-else-if="effectiveQType === 2">
        <QuestionHtml class="q-title" :content="question.title" />
        <div class="q-content">
          <el-checkbox-group v-model="displayedMultipleAnswer">
            <el-checkbox v-for="(item, index) in choiceItems" :label="item.prefix" :key="choiceKey(item, index)">
              <span class="question-prefix">{{ item.prefix }}.</span>
              <QuestionHtml v-if="item.content" :content="item.content" inline class="q-item-span-content" />
              <span v-else class="q-item-span-content">选项 {{ item.prefix }}</span>
            </el-checkbox>
          </el-checkbox-group>
        </div>
      </div>
      <div v-else-if="effectiveQType === 3">
        <QuestionHtml class="q-title" :content="question.title" inline style="display: inline;margin-right: 10px" />
        <span style="padding-right: 10px;">(</span>
        <el-radio-group v-model="answer.content">
          <el-radio v-for="(item, index) in choiceItems" :key="choiceKey(item, index)" :label="item.prefix">
            <QuestionHtml :content="item.content" inline class="q-item-span-content" />
          </el-radio>
        </el-radio-group>
        <span style="padding-left: 10px;">)</span>
      </div>
      <div v-else-if="effectiveQType === 4">
        <QuestionHtml class="q-title" :content="question.title" />
        <div v-if="answer.contentArray !== null">
          <el-form-item :label="String(item.prefix)" :key="choiceKey(item, index)" v-for="(item, index) in gapItems" label-width="50px" style="margin-top: 10px;margin-bottom: 10px;">
            <el-input v-model="answer.contentArray[index]" />
          </el-form-item>
        </div>
      </div>
      <div v-else-if="effectiveQType === 5">
        <QuestionHtml class="q-title" :content="question.title" />
        <div>
          <el-input v-model="answer.content" type="textarea" rows="5" />
        </div>
      </div>
      <div class="question-answer-show-item" style="margin-top: 15px">
        <span class="question-show-item">结果：</span>
        <el-tag :type="doRightTagFormatter(answer.doRight)">
          {{ doRightTextFormatter(answer.doRight) }}
        </el-tag>
      </div>
      <div class="question-answer-show-item">
        <span class="question-show-item">分数：</span>
        <span>{{ question.score }}</span>
      </div>
      <div class="question-answer-show-item">
        <span class="question-show-item">难度：</span>
        <el-rate disabled v-model="question.difficult" class="question-show-item" />
      </div>
      <div class="question-answer-show-item analysis-item">
        <span class="question-show-item analysis-label">解析：</span>
        <QuestionHtml :content="question.analyze" inline strip-leading-answer class="q-item-span-content analysis-content" />
      </div>
    </div>
    <div v-else>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useEnumItemStore } from '@/store/modules/enumItem'
import QuestionHtml from './QuestionHtml.vue'

const enumItemStore = useEnumItemStore()

const props = defineProps({
  question: {
    type: Object,
    default: () => ({})
  },
  answer: {
    type: Object,
    default: () => ({ id: null, content: '', contentArray: [], doRight: false })
  },
  qLoading: {
    type: Boolean,
    default: false
  },
  qType: {
    type: Number,
    default: 0
  }
})

const doRightTagFormatter = (status) => {
  return enumItemStore.enumFormat(enumItemStore.exam.question.answer.doRightTag, status)
}

const doRightTextFormatter = (status) => {
  return enumItemStore.enumFormat(enumItemStore.exam.question.answer.doRightEnum, status)
}

const rawItems = computed(() => Array.isArray(props.question.items) ? props.question.items : [])

const titleText = computed(() => String(props.question.title || props.question.titleContent || ''))

const correctText = computed(() => String(props.question.correct || '').toUpperCase())

const isStoredSingleButMultiple = computed(() => {
  return props.qType === 1 && (
    titleText.value.includes('多项选择题') ||
    /^[A-Z]{2,}$/.test(correctText.value)
  )
})

const effectiveQType = computed(() => isStoredSingleButMultiple.value ? 2 : props.qType)

const choiceItems = computed(() => {
  if (rawItems.value.length > 0) {
    return rawItems.value
  }
  if (effectiveQType.value === 1 || effectiveQType.value === 2) {
    return fallbackChoiceItems()
  }
  return rawItems.value
})

const gapItems = computed(() => {
  if (rawItems.value.length > 0) {
    return rawItems.value
  }
  return Array.from({ length: inferGapCount() }, (_, index) => ({
    prefix: index + 1,
    content: ''
  }))
})

const displayedMultipleAnswer = computed({
  get() {
    if (Array.isArray(props.answer.contentArray) && props.answer.contentArray.length > 0) {
      return props.answer.contentArray
    }
    return splitAnswerLetters(props.answer.content)
  },
  set(value) {
    props.answer.contentArray = value
    if (isStoredSingleButMultiple.value) {
      props.answer.content = [...value].sort().join('')
    }
  }
})

const fallbackChoiceItems = () => {
  const letters = ['A', 'B', 'C', 'D']
  const maxLetter = correctText.value.match(/[A-Z]/g)?.sort().pop()
  if (maxLetter && maxLetter > 'D') {
    const maxCode = Math.min(maxLetter.charCodeAt(0), 'G'.charCodeAt(0))
    for (let code = 'E'.charCodeAt(0); code <= maxCode; code++) {
      letters.push(String.fromCharCode(code))
    }
  }
  return letters.map(prefix => ({ prefix, content: '' }))
}

const inferGapCount = () => {
  const correct = String(props.question.correct || '')
  if (correct.trim().startsWith('[')) {
    try {
      const parsed = JSON.parse(correct)
      if (Array.isArray(parsed) && parsed.length > 0) {
        return parsed.length
      }
    } catch (e) {
      // Keep the one-input fallback below for legacy data.
    }
  }
  const blanks = titleText.value.match(/_{2,}|（\s*）|\(\s*\)/g)
  return Math.max(1, blanks?.length || 1)
}

const splitAnswerLetters = (value) => {
  return String(value || '').toUpperCase().match(/[A-Z]/g) || []
}

const choiceKey = (item, index) => `${item.prefix || 'item'}-${index}`
</script>

<style lang="scss" scoped>
.question-answer-show {
  color: #1f2937;
  font-size: 17px;
  line-height: 1.85;
}

.q-title {
  display: block;
  margin-bottom: 14px;
  color: #111827;
  font-size: 18px;
  font-weight: 600;
  line-height: 1.85;
}

.question-prefix,
.question-show-item {
  margin-right: 6px;
  color: #2563eb;
  font-weight: 700;
}

.question-answer-show-item {
  margin: 8px 0;
  font-size: 17px;
  line-height: 1.75;
}

.analysis-item {
  clear: both;
  width: 100%;
  margin-top: 12px;
}

.analysis-label {
  float: none !important;
}

.analysis-content {
  display: inline;
}

.q-item-span-content {
  font-size: 17px;
  line-height: 1.75;
}

:deep(.el-radio__label),
:deep(.el-checkbox__label),
:deep(p),
:deep(li),
:deep(td),
:deep(th) {
  font-size: 17px;
  line-height: 1.75;
}

:deep(table) {
  width: 100%;
  margin: 12px 0;
  border-collapse: collapse;
}

:deep(td),
:deep(th) {
  padding: 8px 10px;
  border: 1px solid #d1d5db;
}

:deep(img) {
  max-width: 100%;
  height: auto;
}

:deep(code),
:deep(pre) {
  font-size: 16px;
}

:deep(pre) {
  max-width: 100%;
  margin: 14px 0;
  padding: 14px 16px;
  overflow-x: auto;
  border: 1px solid #d1d5db;
  border-radius: 8px;
  background: #f8fafc !important;
  color: #111827 !important;
  line-height: 1.7;
}

:deep(pre code),
:deep(pre span) {
  background: transparent !important;
}

:deep(.highlight) {
  max-width: 100%;
  overflow-x: auto;
}
</style>
