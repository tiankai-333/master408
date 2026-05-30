import { post } from '@/utils/request'

export default {
  providers: () => post('/api/admin/ai-config/providers'),
  saveProvider: query => post('/api/admin/ai-config/provider/save', query),
  testProvider: id => post('/api/admin/ai-config/provider/' + id + '/test'),
  deleteProvider: id => post('/api/admin/ai-config/provider/delete/' + id),
  usage: query => post('/api/admin/ai-config/usage', query)
}
