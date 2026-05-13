import { defineStore } from 'pinia'
import { ref } from 'vue'
import examApi from '@/api/subject'

export const useExamStore = defineStore('exam', () => {
  const subjects = ref([])

  const initSubject = (callback) => {
    examApi.list().then(re => {
      subjects.value = re.response
      if (callback) callback()
    })
  }

  const subjectEnumFormat = (id) => {
    const subject = subjects.value.find(s => s.id === id)
    return subject ? `${subject.name} (${subject.levelName})` : ''
  }

  return {
    subjects,
    initSubject,
    subjectEnumFormat
  }
})