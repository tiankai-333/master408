-- 清理知识目录展示中的爬虫图例残留。
-- 重点处理根知识点“数据结构”开头混入的 A/B/C/D/E 与数字节点标签。

UPDATE knowledge_point
SET description = CONCAT(
  '数据结构在 408 试卷中占据 45 分，和计算机组成原理一样，是分数占比最大的科目，',
  '包含选择题和综合题。复习时应优先掌握线性表、栈和队列、树与二叉树、图、查找、排序等主线，',
  '并能把抽象结构落实到存储方式、基本操作、算法复杂度和典型真题场景中。'
)
WHERE subject_id = 1
  AND name = '数据结构'
  AND description LIKE CONCAT('%', CHAR(10), 'A', CHAR(10), 'B', CHAR(10), 'C', CHAR(10), 'D', CHAR(10), 'E', CHAR(10), '%');
