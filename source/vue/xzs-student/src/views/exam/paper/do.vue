<template>
  <div>
    <el-row class="do-exam-title">
      <el-col :span="24">
        <span :key="item.itemOrder" v-for="item in answer.answerItems">
          <el-tag :type="questionCompleted(item.completed)" class="do-exam-title-tag" @click="goAnchor('#question-' + item.itemOrder)">{{ item.itemOrder }}</el-tag>
        </span>
        <span class="do-exam-time">
          <label>剩余时间：</label>
          <label>{{ formatSeconds(remainTime) }}</label>
        </span>
      </el-col>
    </el-row>
    <el-row class="do-exam-title-hidden">
      <el-col :span="24">
        <span :key="item.itemOrder" v-for="item in answer.answerItems">
          <el-tag class="do-exam-title-tag">{{ item.itemOrder }}</el-tag>
        </span>
        <span class="do-exam-time"><label>剩余时间：</label></span>
      </el-col>
    </el-row>
    <el-container class="app-item-contain">
      <el-header class="align-center">
        <h1>{{ form.name }}</h1>
        <div>
          <span class="question-title-padding">试卷总分：{{ form.score }}</span>
          <span class="question-title-padding">考试时间：{{ form.suggestTime }}分钟</span>
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
                <QuestionEdit :qType="questionItem.questionType" :question="questionItem"
                  :answer="answer.answerItems[questionItem.itemOrder - 1]" />
              </el-form-item>
            </el-card>
          </el-row>
          <el-row class="do-align-center">
            <el-button type="primary" @click="submitForm">提交</el-button>
            <el-button>取消</el-button>
          </el-row>
        </el-form>
      </el-main>
    </el-container>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, onBeforeUnmount } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { useEnumItemStore } from '@/store/modules/enumItem'
import { formatSeconds } from '@/utils'
import QuestionEdit from '../components/QuestionEdit.vue'
import examPaperApi from '@/api/examPaper'
import examPaperAnswerApi from '@/api/examPaperAnswer'

const router = useRouter()
const route = useRoute()
const enumItemStore = useEnumItemStore()
const doCompletedTag = enumItemStore.exam.question.answer.doCompletedTag

const formRef = ref(null)
const form = ref({})
const formLoading = ref(false)
const answer = reactive({
  questionId: null,
  doTime: 0,
  answerItems: []
})
const timer = ref(null)
const remainTime = ref(0)

const formatSecondsLocal = (theTime) => formatSeconds(theTime)

const questionCompleted = (completed) => {
  return enumItemStore.enumFormat(doCompletedTag, completed)
}

const goAnchor = (selector) => {
  document.querySelector(selector).scrollIntoView({ behavior: 'instant', block: 'center', inline: 'nearest' })
}

const initAnswer = () => {
  answer.id = form.value.id
  const titleItemArray = form.value.titleItems
  for (const tIndex in titleItemArray) {
    const questionArray = titleItemArray[tIndex].questionItems
    for (const qIndex in questionArray) {
      const question = questionArray[qIndex]
      answer.answerItems.push({
        questionId: question.id, content: null, contentArray: [], completed: false, itemOrder: question.itemOrder
      })
    }
  }
}

const timeReduce = () => {
  timer.value = setInterval(() => {
    if (remainTime.value <= 0) {
      submitForm()
    } else {
      ++answer.doTime
      --remainTime.value
    }
  }, 1000)
}

const submitForm = () => {
  clearInterval(timer.value)
  formLoading.value = true
  examPaperAnswerApi.answerSubmit(answer).then(re => {
    if (re.code === 1) {
      ElMessageBox.alert('试卷得分：' + re.response + '分', '考试结果', {
        confirmButtonText: '返回考试记录',
        callback: () => {
          router.push('/record/index')
        }
      })
    } else {
      ElMessage.error(re.message)
    }
    formLoading.value = false
  }).catch(() => {
    formLoading.value = false
  })
}

onMounted(() => {
  const id = route.query.id
  if (id && parseInt(id) !== 0) {
    formLoading.value = true
    examPaperApi.select(id).then(re => {
      form.value = re.response
      remainTime.value = re.response.suggestTime * 60
      initAnswer()
      timeReduce()
      formLoading.value = false
    })
  }
})

onBeforeUnmount(() => {
  clearInterval(timer.value)
})
</script>

<style lang="scss" scoped>
.align-center { text-align: center; }
.exam-question-item { padding: 10px;
  :deep(.el-form-item__label) { font-size: 15px !important; }
}
.question-title-padding { padding-left: 25px; padding-right: 25px; }
</style>
