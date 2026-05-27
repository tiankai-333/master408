<template>
  <div style="line-height:1.8">
    <div v-if="qType==1" v-loading="qLoading">
      <QuestionHtml class="q-title" :content="question.title"/>
      <div class="q-content">
          <span :key="item.id" v-for="item in question.items" class="q-item-contain">
            <span class="q-item-prefix">{{item.prefix}}</span>
            <QuestionHtml :content="item.content" class="q-item-content" inline />
          </span>
      </div>
    </div>
    <div v-else-if="qType==2" v-loading="qLoading">
      <QuestionHtml class="q-title" :content="question.title"/>
      <div class="q-content">
          <span :key="item.id" v-for="item in question.items" class="q-item-contain">
            <span class="q-item-prefix">{{item.prefix}}</span>
            <QuestionHtml :content="item.content" class="q-item-content" inline />
          </span>
      </div>
    </div>
    <div v-else-if="qType==3" v-loading="qLoading">
      <QuestionHtml class="q-title" :content="question.title" inline style="display: inline;margin-right: 10px"/>
      <span>（</span>
      <span :key="item.id" v-for="item in question.items">
        <QuestionHtml :content="item.content" class="q-item-content" inline />
       </span>
      <span>）</span>
    </div>
    <div v-else-if="qType==4" v-loading="qLoading">
      <QuestionHtml class="q-title" :content="question.title"/>
    </div>
    <div v-else-if="qType==5" v-loading="qLoading">
      <QuestionHtml class="q-title" :content="question.title"/>
    </div>
    <div v-else>
    </div>
  </div>
</template>

<script setup>
import QuestionHtml from './QuestionHtml.vue'

defineProps({
  question: {
    type: Object,
    default: () => ({})
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
