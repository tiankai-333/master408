import { post } from '@/utils/request'

export default {
  publicProviders: () => post('/api/student/ai-config/providers'),
  testPublicProvider: id => post('/api/student/ai-config/provider/' + id + '/test'),
  userKeys: () => post('/api/student/ai-config/user-keys'),
  saveUserKey: query => post('/api/student/ai-config/user-key/save', query),
  testUserKey: id => post('/api/student/ai-config/user-key/' + id + '/test'),
  deleteUserKey: id => post('/api/student/ai-config/user-key/delete/' + id),
  usage: query => post('/api/student/ai-config/usage', query)
}
