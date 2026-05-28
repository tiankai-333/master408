<template>
  <div v-loading="qLoading" class="question-answer-show">
    <div v-if="qType === 1 || qType === 2 || qType === 3 || qType === 4 || qType === 5">
      <div v-if="qType === 1">
        <QuestionHtml class="q-title" :content="question.title" />
        <div class="q-content">
          <el-radio-group v-model="answer.content">
            <el-radio v-for="item in question.items" :key="item.prefix" :label="item.prefix">
              <span class="question-prefix">{{ item.prefix }}.</span>
              <QuestionHtml :content="item.content" inline class="q-item-span-content" />
            </el-radio>
          </el-radio-group>
        </div>
      </div>
      <div v-else-if="qType === 2">
        <QuestionHtml class="q-title" :content="question.title" />
        <div class="q-content">
          <el-checkbox-group v-model="answer.contentArray">
            <el-checkbox v-for="item in question.items" :label="item.prefix" :key="item.prefix">
              <span class="question-prefix">{{ item.prefix }}.</span>
              <QuestionHtml :content="item.content" inline class="q-item-span-content" />
            </el-checkbox>
          </el-checkbox-group>
        </div>
      </div>
      <div v-else-if="qType === 3">
        <QuestionHtml class="q-title" :content="question.title" inline style="display: inline;margin-right: 10px" />
        <span style="padding-right: 10px;">(</span>
        <el-radio-group v-model="answer.content">
          <el-radio v-for="item in question.items" :key="item.prefix" :label="item.prefix">
            <QuestionHtml :content="item.content" inline class="q-item-span-content" />
          </el-radio>
        </el-radio-group>
        <span style="padding-left: 10px;">)</span>
      </div>
      <div v-else-if="qType === 4">
        <QuestionHtml class="q-title" :content="question.title" />
        <div v-if="answer.contentArray !== null">
          <el-form-item :label="item.prefix" :key="item.prefix" v-for="item in question.items" label-width="50px" style="margin-top: 10px;margin-bottom: 10px;">
            <el-input v-model="answer.contentArray[item.prefix - 1]" />
          </el-form-item>
        </div>
      </div>
      <div v-else-if="qType === 5">
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
