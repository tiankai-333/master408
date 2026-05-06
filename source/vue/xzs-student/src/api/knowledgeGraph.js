import { get } from '@/utils/request'

export default {
  getKnowledgeGraph: (subjectId) => {
    return get('/api/student/knowledge-graph/graph' + (subjectId ? '?subjectId=' + subjectId : ''))
  },
  getKnowledgePointDetail: (id) => {
    return get('/api/student/knowledge-graph/knowledge-point/' + id)
  },
  getQuestionKnowledgePoints: (questionId) => {
    return get('/api/student/knowledge-graph/question/' + questionId + '/knowledge-points')
  },
  getKnowledgePointQuestions: (id, limit) => {
    return get('/api/student/knowledge-graph/knowledge-point/' + id + '/questions?limit=' + (limit || 10))
  }
}