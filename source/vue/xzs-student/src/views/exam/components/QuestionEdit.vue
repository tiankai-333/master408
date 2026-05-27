<template>
  <div style="line-height:1.8">
    <div v-if="qType === 1" v-loading="qLoading">
      <QuestionHtml class="q-title" :content="question.title" />
      <div class="q-content">
        <el-radio-group v-model="answer.content" @change="answer.completed = true">
          <el-radio v-for="item in question.items" :key="item.prefix" :label="item.prefix">
            <span class="question-prefix">{{ item.prefix }}.</span>
            <QuestionHtml :content="item.content" inline class="q-item-span-content" />
          </el-radio>
        </el-radio-group>
      </div>
    </div>
    <div v-else-if="qType === 2" v-loading="qLoading">
      <QuestionHtml class="q-title" :content="question.title" />
      <div class="q-content">
        <el-checkbox-group v-model="answer.contentArray" @change="answer.completed = true">
          <el-checkbox v-for="item in question.items" :label="item.prefix" :key="item.prefix">
            <span class="question-prefix">{{ item.prefix }}.</span>
            <QuestionHtml :content="item.content" inline class="q-item-span-content" />
          </el-checkbox>
        </el-checkbox-group>
      </div>
    </div>
    <div v-else-if="qType === 3" v-loading="qLoading">
      <QuestionHtml class="q-title" :content="question.title" inline style="display: inline;margin-right: 10px" />
      <span style="padding-right: 10px;">(</span>
      <el-radio-group v-model="answer.content" @change="answer.completed = true">
        <el-radio v-for="item in question.items" :key="item.prefix" :label="item.prefix">
          <QuestionHtml :content="item.content" inline class="q-item-span-content" />
        </el-radio>
      </el-radio-group>
      <span style="padding-left: 10px;">)</span>
    </div>
    <div v-else-if="qType === 4" v-loading="qLoading">
      <QuestionHtml class="q-title" :content="question.title" />
      <div>
        <el-form-item :label="item.prefix" :key="item.prefix" v-for="item in question.items" label-width="50px" style="margin-top: 10px;margin-bottom: 10px;">
          <el-input v-model="answer.contentArray[item.prefix - 1]" @change="answer.completed = true" />
        </el-form-item>
      </div>
    </div>
    <div v-else-if="qType === 5" v-loading="qLoading">
      <QuestionHtml class="q-title" :content="question.title" />
      <div>
        <el-input v-model="answer.content" type="textarea" rows="5" @change="answer.completed = true" />
      </div>
    </div>
    <div v-else>
    </div>
  </div>
</template>

<script setup>
import QuestionHtml from './QuestionHtml.vue'

const props = defineProps({
  question: {
    type: Object,
    default: () => ({})
  },
  answer: {
    type: Object,
    default: () => ({ id: null, content: '', contentArray: [] })
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
</script>
