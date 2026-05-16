import { createPinia } from 'pinia'

const pinia = createPinia()

export default pinia

export { useAppStore } from './app'
export { useUserStore } from './user'
export { useTagsViewStore } from './tagsView'
export { useExamStore } from './exam'
export { useEnumItemStore } from './enumItem'
