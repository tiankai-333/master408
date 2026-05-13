<template>
  <div>
    <el-row class="do-exam-title" style="background-color: #F5F5DC">
      <el-col :span="24">
        <span :key="item.itemOrder" v-for="item in answer.answerItems">
          <el-tag :type="questionDoRightTag(item.doRight)" class="do-exam-title-tag" @click="goAnchor('#question-' + item.itemOrder)">{{ item.itemOrder }}</el-tag>
        </span>
      </el-col>
    </el-row>
    <el-row class="do-exam-title-hidden">
      <el-col :span="24">
        <span :key="item.itemOrder" v-for="item in answer.answerItems">
          <el-tag class="do-exam-title-tag">{{ item.itemOrder }}</el-tag>
        </span>
      </el-col>
    </el-row>
    <el-container class="app-item-contain">
      <el-header class="align-center">
        <h1>{{ form.name }}</h1>
        <div>
          <span class="question-title-padding">试卷得分：{{ answer.score }}</span>
          <span class="question-title-padding">试卷耗时：{{ formatSecondsLocal(answer.doTime) }}</span>
        </div>
      </el-header>
      <el-main>
        <el-form :model="form" ref="formRef" v-loading="formLoading" label-width="100px">
          <el-row :key="index" v-for="(titleItem, index) in form.titleItems">
            <h3>{{ titleItem.name }}</h3>
            <el-card class="exampaper-item-box" v-if="titleItem.questionItems.length !== 0">
              <el-form-item :key="questionItem.itemOrder" :label="questionItem.itemOrder + '.'"
                v-for="questionItem in titleItem.questionItems"
                class="exam-question-item" label-width="50px" :id="'question-' + questionItem.itemOrder">
                <QuestionAnswerShow :qType="questionItem.questionType" :question="questionItem" :answer="answer.answerItems[questionItem.itemOrder - 1]" />
              </el-form-item>
            </el-card>
          </el-row>
        </el-form>
      </el-main>
    </el-container>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useEnumItemStore } from '@/store/modules/enumItem'
import { formatSeconds } from '@/utils'
import QuestionAnswerShow from '../components/QuestionAnswerShow.vue'
import examPaperAnswerApi from '@/api/examPaperAnswer'

const enumItemStore = useEnumItemStore()
const doRightTag = enumItemStore.exam.question.answer.doRightTag

const formRef = ref(null)
const form = ref({})
const formLoading = ref(false)
const answer = reactive({
  id: null, score: 0, doTime: 0, answerItems: [], doRight: false
})

const formatSecondsLocal = (theTime) => formatSeconds(theTime)

const questionDoRightTag = (status) => enumItemStore.enumFormat(doRightTag, status)

const goAnchor = (selector) => {
  document.querySelector(selector).scrollIntoView({ behavior: 'instant', block: 'center', inline: 'nearest' })
}

onMounted(() => {
  const id = new URLSearchParams(window.location.search).get('id')
  if (id && parseInt(id) !== 0) {
    formLoading.value = true
    examPaperAnswerApi.read(id).then(re => {
      form.value = re.response.paper
      answer.id = re.response.answer.id
      answer.score = re.response.answer.score
      answer.doTime = re.response.answer.doTime
      answer.answerItems = re.response.answer.answerItems
      formLoading.value = false
    })
  }
})
</script>

<style lang="scss" scoped>
.align-center { text-align: center; }
.exam-question-item { padding: 10px;
  :deep(.el-form-item__label) { font-size: 15px !important; }
}
.question-title-padding { padding-left: 25px; padding-right: 25px; }
</style>
