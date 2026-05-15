-- ============================================
-- 真题题目导入SQL (2) - 2011-2024年408真题
-- 共616道选择题
-- ============================================

USE xzs;

-- ============================================
-- 2011年真题 - 数据结构 (1-11题)
-- ============================================

INSERT INTO `t_question` (`subject_id`, `question_type`, `title`, `options`, `correct_answer`, `analysis`, `difficulty`, `score`, `knowledge_point`, `source`, `source_year`, `source_question_no`, `tags`, `images`) VALUES
(1, 'choice', '设 n 是描述问题规模的非负整数，下面程序片段的时间复杂度是（ ）。 x=2;while(x<n/2)x=2*x;', '[{"key":"A","value":"O(logn)"},{"key":"B","value":"O(n)"},{"key":"C","value":"O(nlog₂ⁿ)"},{"key":"D","value":"O(n²)"}]', 'A', '在程序中，执行频率最高的语句为 x = x * 2，设该语句总共执行了 T(n) 次，则 2T(n)+1≤n/2，故 T(n)=log₂(n/2)−1=log₂n−2，得 T(n)=O(log₂n)。', 2, 2, '复杂度分析', '2011年真题', 2011, 1, '时间复杂度,算法分析', '', '');

INSERT INTO `t_question` (`subject_id`, `question_type`, `title`, `options`, `correct_answer`, `analysis`, `difficulty`, `score`, `knowledge_point`, `source`, `source_year`, `source_question_no`, `tags`, `images`) VALUES
(1, 'choice', '元素 a，b，c，d，e 依次进入初始为空的栈中，若元素进栈后可停留、可出栈，直到所有元素都出栈，则在所有可能的出现序列中，以元素 d 开头的序列个数是（ ）', '[{"key":"A","value":"3"},{"key":"B","value":"4"},{"key":"C","value":"5"},{"key":"D","value":"6"}]', 'B', '本题考察入栈出栈序列，d 为第 1 个出栈元素，则 d 之前的元素必定是进栈后在栈中停留。因而出栈顺序必为 d_c_b_a_，e 的顺序不定，在任一 "_" 上都有可能，一共有 4 种可能。', 2, 2, '入栈出栈序列', '2011年真题', 2011, 2, '栈,入栈出栈序列', '', '');

INSERT INTO `t_question` (`subject_id`, `question_type`, `title`, `options`, `correct_answer`, `analysis`, `difficulty`, `score`, `knowledge_point`, `source`, `source_year`, `source_question_no`, `tags`, `images`) VALUES
(1, 'choice', '已知循环队列存储在一维数组A[0..n-1]中，且队列非空时front和rear分别指向队头元素和队尾元素。若初始时队列空，且要求第一个进入队列的元素存储在A[0]处，则初始时front和rear的值分别是（ ）', '[{"key":"A","value":"0，0"},{"key":"B","value":"0，n-1"},{"key":"C","value":"n-1，0"},{"key":"D","value":"n-1，n-1"}]', 'B', '根据题意，第一个元素进入队列后存储在 A[0] 处，此时 front 和 rear 值都为 0。入队时由于要执行 (rear+1) % n 操作，所以如果入队后指针指向 0，则 rear 初值为 n-1，而由于第一个元素在 A[0] 中，插入操作只改变 rear 指针，所以 front 为 0 不变。', 2, 2, '队列', '2011年真题', 2011, 3, '循环队列,队列', '', '');

-- 由于数据量太大，让我创建一个Python脚本来生成完整的SQL
-- 这里先创建一个模板，然后通过程序生成完整SQL

-- 为了高效处理，让我创建一个生成脚本
