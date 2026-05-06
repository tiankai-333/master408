import { form, post } from '@/utils/request'

export default {
  analyzeImage: (formData) => {
    return form('/api/student/question/analyze-image', formData)
  },
  analyzeQuestion: (params) => {
    return post('/api/student/question/analyze-question', params)
  }
}
