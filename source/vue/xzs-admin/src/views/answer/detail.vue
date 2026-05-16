<template>
  <div class="app-container">
    <div v-loading="loading">
      <el-card style="margin-bottom: 20px">
        <el-row>
          <el-col :span="6">
            <span class="label">学生：</span>{{ answer.studentName }}
          </el-col>
          <el-col :span="6">
            <span class="label">试卷：</span>{{ answer.paperName }}
          </el-col>
          <el-col :span="6">
            <span class="label">学科：</span>{{ answer.subjectName }}
          </el-col>
          <el-col :span="6">
            <span class="label">得分：</span>{{ answer.score }}/{{ answer.totalScore }}
          </el-col>
        </el-row>
      </el-card>
      <el-card v-for="(titleItem, titleIndex) in answer.titleItems" :key="titleItem.id">
        <template #header>
          <span>{{ titleIndex + 1 }}. {{ titleItem.name }}</span>
        </template>
        <div v-for="(questionItem, questionIndex) in titleItem.questionItems" :key="questionItem.id"
             class="question-item">
          <div class="question-title">
            <span class="question-num">{{ titleIndex + 1 }}-{{ questionIndex + 1 }}</span>
            <span v-html="questionItem.title"></span>
            <span class="question-score">（{{ questionItem.score }}分）</span>
          </div>
          <div v-if="questionItem.questionType === 1 || questionItem.questionType === 2 || questionItem.questionType === 4"
               class="question-options">
            <span v-for="item in questionItem.items" :key="item.id"
                  :class="['option-item', { 'correct': item.isAnswer }, { 'selected': item.isSelected }]">
              {{ item.prefix }}. {{ item.content }}
            </span>
          </div>
          <div v-if="questionItem.questionType === 3" class="question-options">
            <span>答案：</span>
            <span v-for="item in questionItem.items" :key="item.id">{{ item.content }}</span>
          </div>
          <div v-if="questionItem.questionType === 5" class="question-options">
            <span>参考答案：</span>
            <span v-html="questionItem.answer"></span>
          </div>
          <div class="question-answer">
            <span>你的答案：</span>
            <span v-html="questionItem.userAnswer || '未作答'"></span>
          </div>
          <div v-if="questionItem.status !== null" class="question-status"
               :class="questionItem.status ? 'correct' : 'wrong'">
            {{ questionItem.status ? '正确' : '错误' }}
          </div>
        </div>
      </el-card>
    </div>
  </div>
</template>

<script setup>
import { reactive, ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import answerApi from '@/api/examPaperAnwser'

const route = useRoute()

const loading = ref(true)
const answer = reactive({
  studentName: '',
  paperName: '',
  subjectName: '',
  score: 0,
  totalScore: 0,
  titleItems: []
})

onMounted(() => {
  const id = route.query.id
  if (id) {
    answerApi.select(id).then(re => {
      Object.assign(answer, re.response)
      loading.value = false
    })
  }
})
</script>

<style scoped>
.question-item {
  margin-bottom: 20px;
  padding-bottom: 20px;
  border-bottom: 1px solid #eee;
}
.question-title {
  font-weight: bold;
  margin-bottom: 10px;
}
.question-num {
  margin-right: 10px;
}
.question-score {
  margin-left: 10px;
  color: #999;
}
.question-options {
  margin-bottom: 10px;
}
.option-item {
  display: block;
  padding: 5px;
  margin-bottom: 5px;
}
.option-item.correct {
  background-color: #e8f5e9;
}
.option-item.selected {
  background-color: #fff3e0;
}
.question-answer {
  margin-bottom: 10px;
}
.question-status {
  display: inline-block;
  padding: 2px 10px;
  border-radius: 4px;
}
.question-status.correct {
  background-color: #c8e6c9;
  color: #2e7d32;
}
.question-status.wrong {
  background-color: #ffcdd2;
  color: #c62828;
}
.label {
  color: #999;
}
</style>