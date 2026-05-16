import { defineStore } from 'pinia'
import subjectApi from '@/api/subject'

export const useExamStore = defineStore('exam', {
  state: () => ({
    subjects: []
  }),
  actions: {
    initSubject () {
      subjectApi.list().then(re => {
        this.subjects = re.response
      })
    }
  },
  getters: {
    subjectEnumFormat: (state) => {
      return (key) => {
        for (let item of state.subjects) {
          if (item.id === key) {
            return item.name + ' ( ' + item.levelName + ' )'
          }
        }
        return null
      }
    }
  }
})
