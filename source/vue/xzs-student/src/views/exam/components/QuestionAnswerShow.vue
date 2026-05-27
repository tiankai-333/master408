<template>
  <div v-loading="qLoading" style="line-height:1.8">
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
      <br />
      <div class="question-answer-show-item" style="line-height: 1.8">
        <span class="question-show-item">解析：</span>
        <QuestionHtml :content="question.analyze" inline class="q-item-span-content" />
      </div>
      <div class="question-answer-show-item">
        <span class="question-show-item">正确答案：</span>
        <QuestionHtml v-if="qType === 1 || qType === 2 || qType === 5" :content="question.correct" inline class="q-item-span-content" />
        <QuestionHtml v-if="qType === 3" :content="trueFalseFormatter(question)" inline class="q-item-span-content" />
        <span v-if="qType === 4">{{ question.correctArray }}</span>
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

const trueFalseFormatter = (question) => {
  return question.items.filter(d => d.prefix === question.correct)[0].content
}

const doRightTagFormatter = (status) => {
  return enumItemStore.enumFormat(enumItemStore.exam.question.answer.doRightTag, status)
}

const doRightTextFormatter = (status) => {
  return enumItemStore.enumFormat(enumItemStore.exam.question.answer.doRightEnum, status)
}
</script>
