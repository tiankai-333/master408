module.exports = {
  subjects: [
    { id: 1, name: '数据结构' },
    { id: 2, name: '计算机组成原理' },
    { id: 3, name: '操作系统' },
    { id: 4, name: '计算机网络' }
  ],
  subjectNames: ['数据结构', '计算机组成原理', '操作系统', '计算机网络'],
  subjectNameToId: { '数据结构': 1, '计算机组成原理': 2, '操作系统': 3, '计算机网络': 4 },
  questionTypeMap: { 1: '单选题', 2: '多选题', 3: '判断题', 4: '填空题', 5: '简答题' },
  aiStyles: [
    { id: 'default', name: '标准解析' },
    { id: 'feynman', name: '费曼风格' },
    { id: 'plato', name: '柏拉图式' },
    { id: 'first-principles', name: '第一性原理' }
  ],
  aiStyleNames: ['标准解析', '费曼风格', '柏拉图式', '第一性原理'],
  aiStyleIds: ['default', 'feynman', 'plato', 'first-principles']
}
