import { defineStore } from 'pinia'
import { ref } from 'vue'

export const useEnumItemStore = defineStore('enumItem', () => {
  const user = ref({
    sexEnum: [
      { key: 1, value: '男' },
      { key: 2, value: '女' }
    ],
    statusEnum: [
      { key: 1, value: '正常' },
      { key: 2, value: '禁用' }
    ],
    statusTag: [
      { key: 1, value: 'success' },
      { key: 2, value: 'danger' }
    ],
    statusBtn: [
      { key: 1, value: '禁用' },
      { key: 2, value: '启用' }
    ],
    roleEnum: [
      { key: 1, value: '学生' },
      { key: 2, value: '教师' },
      { key: 3, value: '管理员' }
    ]
  })

  const enumFormat = (arr, value) => {
    if (!arr || !value && value !== 0) return ''
    const item = arr.find(v => v.key === value)
    return item ? item.value : ''
  }

  return {
    user,
    enumFormat
  }
})
