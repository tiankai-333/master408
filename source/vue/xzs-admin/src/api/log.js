import { post } from '@/utils/request'

export default {
  pageList: query => post('/api/admin/user/event/page/list', query)
}