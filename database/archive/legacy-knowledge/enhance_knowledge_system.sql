-- ============================================
-- 408刷题系统 V2.0 - 数据库增强脚本 (简化版)
-- ============================================
-- 新增功能：
-- 1. 知识点标签体系 (支撑RAG、AI解析、Agent图谱)
-- 2. 题目向量化存储 (支撑RAG检索)
-- 3. 用户知识掌握图谱 (支撑Agent个性化学习)
-- 4. AI解析多风格表 (支撑柏拉图/费曼/第一性/默认风格)
--
-- 使用方法：
-- mysql -u root -p123456 xzs < enhance_knowledge_system.sql
-- ============================================

USE xzs;

-- ----------------------------
-- 1. 知识点表 (知识图谱节点)
-- ----------------------------
DROP TABLE IF EXISTS `t_knowledge_point`;
CREATE TABLE `t_knowledge_point` (
  `id` INT NOT NULL AUTO_INCREMENT COMMENT '知识点ID',
  `name` VARCHAR(255) NOT NULL COMMENT '知识点名称',
  `parent_id` INT NULL COMMENT '父知识点ID (用于构建知识树)',
  `subject_id` INT NOT NULL COMMENT '所属学科ID',
  `level` INT NOT NULL DEFAULT 1 COMMENT '层级: 1=章, 2=节, 3=小节',
  `code` VARCHAR(50) NULL COMMENT '知识点编码 (如: DS-01-03-02)',
  `description` TEXT NULL COMMENT '知识点描述',
  `difficulty` INT DEFAULT 3 COMMENT '难度等级 1-5',
  `importance` INT DEFAULT 3 COMMENT '重要程度 1-5',
  `embedding` TEXT NULL COMMENT '知识点文本的向量表示 (JSON格式)',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` BIT(1) DEFAULT b'0',
  PRIMARY KEY (`id`),
  INDEX `idx_parent_id`(`parent_id`),
  INDEX `idx_subject_id`(`subject_id`),
  INDEX `idx_code`(`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='知识点表';

-- ----------------------------
-- 2. 题目-知识点关联表 (知识图谱边)
-- ----------------------------
DROP TABLE IF EXISTS `t_question_knowledge`;
CREATE TABLE `t_question_knowledge` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `question_id` INT NOT NULL COMMENT '题目ID',
  `knowledge_id` INT NOT NULL COMMENT '知识点ID',
  `weight` DECIMAL(3,2) DEFAULT 1.00 COMMENT '关联权重 0.1-1.0 (一题可能涉及多个知识点)',
  `knowledge_type` VARCHAR(20) DEFAULT 'main' COMMENT '知识点类型: main=主要考察, sub=涉及, hint=提示',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_question_knowledge`(`question_id`, `knowledge_id`),
  INDEX `idx_knowledge_id`(`knowledge_id`),
  INDEX `idx_question_id`(`question_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='题目-知识点关联表';

-- ----------------------------
-- 3. 用户知识掌握表 (Agent个人知识图谱核心)
-- ----------------------------
DROP TABLE IF EXISTS `t_user_knowledge_mastery`;
CREATE TABLE `t_user_knowledge_mastery` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `user_id` INT NOT NULL COMMENT '用户ID',
  `knowledge_id` INT NOT NULL COMMENT '知识点ID',
  `mastery_level` INT DEFAULT 0 COMMENT '掌握程度 0-100',
  `times_practiced` INT DEFAULT 0 COMMENT '练习次数',
  `times_correct` INT DEFAULT 0 COMMENT '正确次数',
  `correct_rate` DECIMAL(5,2) DEFAULT 0.00 COMMENT '正确率 0.00-100.00',
  `last_practice_time` DATETIME NULL COMMENT '最后练习时间',
  `ease_factor` DECIMAL(3,2) DEFAULT 2.50 COMMENT '记忆 Ease Factor (类似SM2算法)',
  `interval_days` INT DEFAULT 0 COMMENT '下次复习间隔天数',
  `next_review_time` DATETIME NULL COMMENT '下次复习时间',
  `status` VARCHAR(20) DEFAULT 'learning' COMMENT '状态: learning/new/reviewing/mastered/forgotten',
  `source` VARCHAR(50) NULL COMMENT '最近一次来源: exam_paper/task/practice',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_knowledge`(`user_id`, `knowledge_id`),
  INDEX `idx_user_id`(`user_id`),
  INDEX `idx_knowledge_id`(`knowledge_id`),
  INDEX `idx_mastery_level`(`mastery_level`),
  INDEX `idx_next_review`(`next_review_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户知识掌握表';

-- ----------------------------
-- 4. 题目向量表 (支撑RAG检索)
-- ----------------------------
DROP TABLE IF EXISTS `t_question_vector`;
CREATE TABLE `t_question_vector` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `question_id` INT NOT NULL COMMENT '题目ID',
  `content_type` VARCHAR(30) NOT NULL COMMENT '内容类型: question/answer/explain/analyze/all',
  `text_content` TEXT NOT NULL COMMENT '原始文本内容',
  `vector` TEXT NULL COMMENT '文本向量 (JSON数组格式)',
  `embedding_model` VARCHAR(50) DEFAULT 'text-embedding-ada-002' COMMENT '向量化模型',
  `dimension` INT DEFAULT 1536 COMMENT '向量维度',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_question_content_type`(`question_id`, `content_type`),
  INDEX `idx_question_id`(`question_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='题目向量表';

-- ----------------------------
-- 5. AI解析风格表 (支撑多风格AI解析)
-- ----------------------------
DROP TABLE IF EXISTS `t_question_ai_analysis`;
CREATE TABLE `t_question_ai_analysis` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `question_id` INT NOT NULL COMMENT '题目ID',
  `style` VARCHAR(30) NOT NULL COMMENT '解析风格: plato/feynman/first_principles/default',
  `title` VARCHAR(255) NULL COMMENT '解析标题 (可选)',
  `content` TEXT NOT NULL COMMENT 'AI生成的解析内容',
  `prompt_template` TEXT NULL COMMENT '使用的提示词模板',
  `model` VARCHAR(50) NULL COMMENT '使用的AI模型',
  `token_count` INT NULL COMMENT '消耗的Token数',
  `embedding` TEXT NULL COMMENT '解析内容的向量 (用于RAG检索)',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` BIT(1) DEFAULT b'0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_question_style`(`question_id`, `style`),
  INDEX `idx_question_id`(`question_id`),
  INDEX `idx_style`(`style`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='AI解析风格表';

-- ----------------------------
-- 6. 用户学习行为表 (支撑Agent分析)
-- ----------------------------
DROP TABLE IF EXISTS `t_user_learning_behavior`;
CREATE TABLE `t_user_learning_behavior` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `user_id` INT NOT NULL COMMENT '用户ID',
  `behavior_type` VARCHAR(30) NOT NULL COMMENT '行为类型: view/practice/wrong/review/study',
  `target_type` VARCHAR(30) NOT NULL COMMENT '目标类型: question/knowledge/paper/explain',
  `target_id` INT NOT NULL COMMENT '目标ID (题目/知识点/试卷/解析ID)',
  `target_content` TEXT NULL COMMENT '行为内容摘要',
  `duration_seconds` INT DEFAULT 0 COMMENT '花费时长(秒)',
  `result` VARCHAR(20) NULL COMMENT '结果: correct/incorrect/skipped',
  `ip_address` VARCHAR(50) NULL COMMENT 'IP地址',
  `user_agent` VARCHAR(500) NULL COMMENT '浏览器UA',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  INDEX `idx_user_id`(`user_id`),
  INDEX `idx_behavior_type`(`behavior_type`),
  INDEX `idx_target`(`target_type`, `target_id`),
  INDEX `idx_create_time`(`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户学习行为表';

-- ----------------------------
-- 7. 知识图谱关系表 (支撑复杂推理)
-- ----------------------------
DROP TABLE IF EXISTS `t_knowledge_relation`;
CREATE TABLE `t_knowledge_relation` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `knowledge_id_from` INT NOT NULL COMMENT '源知识点ID',
  `knowledge_id_to` INT NOT NULL COMMENT '目标知识点ID',
  `relation_type` VARCHAR(30) NOT NULL COMMENT '关系类型: prerequisite/contains/similar/contrast/applied',
  `weight` DECIMAL(3,2) DEFAULT 1.00 COMMENT '关系权重',
  `description` VARCHAR(255) NULL COMMENT '关系描述',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_knowledge_relation`(`knowledge_id_from`, `knowledge_id_to`, `relation_type`),
  INDEX `idx_from`(`knowledge_id_from`),
  INDEX `idx_to`(`knowledge_id_to`),
  INDEX `idx_relation_type`(`relation_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='知识点关系表';

-- ----------------------------
-- 8. 用户学习会话表 (支撑Agent连续对话)
-- ----------------------------
DROP TABLE IF EXISTS `t_user_learning_session`;
CREATE TABLE `t_user_learning_session` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `user_id` INT NOT NULL COMMENT '用户ID',
  `session_type` VARCHAR(30) DEFAULT 'study' COMMENT '会话类型: study/exam/review/rag_query',
  `context` JSON NULL COMMENT '会话上下文 (JSON格式存储历史状态)',
  `current_topic` INT NULL COMMENT '当前学习主题/知识点ID',
  `goal` VARCHAR(255) NULL COMMENT '学习目标',
  `status` VARCHAR(20) DEFAULT 'active' COMMENT '状态: active/completed/abandoned',
  `start_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `end_time` DATETIME NULL,
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_user_id`(`user_id`),
  INDEX `idx_status`(`status`),
  INDEX `idx_current_topic`(`current_topic`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户学习会话表';

-- ============================================
-- 初始化数据：408学科的知识点体系
-- ============================================

-- 数据结构 (101)
INSERT INTO `t_knowledge_point` (`id`, `name`, `parent_id`, `subject_id`, `level`, `code`, `description`, `difficulty`, `importance`) VALUES
(10101, '数据结构', NULL, 101, 1, 'DS', '研究数据的逻辑结构和物理结构以及它们之间的操作', 3, 5),
(1010101, '线性表', 10101, 101, 2, 'DS-01', 'n个有序元素的序列', 2, 5),
(101010101, '顺序表', 1010101, 101, 3, 'DS-01-01', '用顺序存储结构的线性表', 2, 4),
(101010102, '链表', 1010101, 101, 3, 'DS-01-02', '用链式存储结构的线性表', 2, 5),
(10101010201, '单链表', 101010102, 101, 3, 'DS-01-02-01', '每个节点只含一个指针的链表', 2, 5),
(10101010202, '双向链表', 101010102, 101, 3, 'DS-01-02-02', '每个节点包含前驱和后继指针的链表', 3, 4),
(10101010203, '循环链表', 101010102, 101, 3, 'DS-01-02-03', '首尾相接的链表', 2, 3),
(1010102, '栈', 1010101, 101, 2, 'DS-02', '后进先出(LIFO)的线性表', 2, 5),
(1010103, '队列', 1010101, 101, 2, 'DS-03', '先进先出(FIFO)的线性表', 2, 5),
(101010301, '顺序队列', 1010103, 101, 3, 'DS-03-01', '用顺序存储的队列', 2, 4),
(101010302, '链式队列', 1010103, 101, 3, 'DS-03-02', '用链式存储的队列', 2, 4),
(101010303, '循环队列', 1010103, 101, 3, 'DS-03-03', '一种顺序队列的改进形式', 3, 5),
(1010104, '字符串', 1010101, 101, 2, 'DS-04', '由字符序列组成的数据结构', 2, 4),
(10102, '树和二叉树', 10101, 101, 2, 'DS-05', '层次结构的数据组织方式', 3, 5),
(1010201, '二叉树', 10102, 101, 3, 'DS-05-01', '每个节点最多两个子树的树形结构', 3, 5),
(101020101, '二叉树的遍历', 1010201, 101, 3, 'DS-05-01-01', '前序、中序、后序、层序遍历', 3, 5),
(101020102, '二叉排序树', 1010201, 101, 3, 'DS-05-01-02', '左子树小于根、右子树大于根的二叉树', 3, 4),
(101020103, '平衡二叉树', 1010201, 101, 3, 'DS-05-01-03', '左右子树高度差不超过1的二叉树', 4, 5),
(101020104, '哈夫曼树', 1010201, 101, 3, 'DS-05-01-04', '带权路径长度最短的二叉树', 3, 4),
(1010202, '树和森林', 10102, 101, 3, 'DS-05-02', '树的存储结构和转换', 3, 4),
(1010203, '堆', 10102, 101, 3, 'DS-05-03', '一种特殊的完全二叉树', 3, 5),
(10103, '图', 10101, 101, 2, 'DS-06', '顶点集合和边集合组成的数据结构', 4, 5),
(1010301, '图的存储', 10103, 101, 3, 'DS-06-01', '邻接矩阵、邻接表等存储方式', 3, 5),
(1010302, '图的遍历', 10103, 101, 3, 'DS-06-02', '深度优先搜索和广度优先搜索', 3, 5),
(1010303, '最短路径', 10103, 101, 3, 'DS-06-03', 'Dijkstra、Floyd等算法', 4, 5),
(1010304, '拓扑排序', 10103, 101, 3, 'DS-06-04', '有向无环图的应用', 3, 4),
(10104, '查找', 10101, 101, 2, 'DS-07', '在数据集合中寻找特定元素', 3, 5),
(1010401, '顺序查找', 10104, 101, 3, 'DS-07-01', '线性搜索', 2, 3),
(1010402, '二分查找', 10104, 101, 3, 'DS-07-02', '在有序数组中折半查找', 3, 5),
(1010403, '二叉搜索树', 10104, 101, 3, 'DS-07-03', '基于二叉树的查找', 3, 5),
(1010404, '哈希查找', 10104, 101, 3, 'DS-07-04', '通过哈希函数直接访问', 4, 5),
(10105, '排序', 10101, 101, 2, 'DS-08', '将数据按特定顺序排列', 3, 5),
(1010501, '内部排序', 10105, 101, 3, 'DS-08-01', '所有数据放在内存中排序', 3, 5),
(101050101, '插入排序', 1010501, 101, 3, 'DS-08-01-01', '直接插入、折半插入、希尔排序', 3, 4),
(101050102, '交换排序', 1010501, 101, 3, 'DS-08-01-02', '冒泡排序、快速排序', 3, 5),
(101050103, '选择排序', 1010501, 101, 3, 'DS-08-01-03', '简单选择、堆排序', 3, 5),
(101050104, '归并排序', 1010501, 101, 3, 'DS-08-01-04', '分治思想的排序应用', 3, 4),
(101050105, '基数排序', 1010501, 101, 3, 'DS-08-01-05', '按位进行多趟排序', 3, 3),
(1010502, '外部排序', 10105, 101, 3, 'DS-08-02', '数据量大于内存的排序', 4, 4),
(10106, '算法基础', 10101, 101, 2, 'DS-09', '算法的复杂度分析和设计策略', 3, 5),
(1010601, '时间空间复杂度', 10106, 101, 3, 'DS-09-01', '渐进时间复杂度和空间复杂度', 3, 5),
(1010602, '递归', 10106, 101, 3, 'DS-09-02', '函数自我调用的技术', 3, 5),
(1010603, '分治法', 10106, 101, 3, 'DS-09-03', '分而治之的问题解决方法', 3, 4),
(1010604, '动态规划', 10106, 101, 3, 'DS-09-04', '最优子结构和重叠子问题', 4, 5),
(1010605, '贪心算法', 10106, 101, 3, 'DS-09-05', '局部最优策略得到全局最优', 4, 4),
(1010606, '回溯法', 10106, 101, 3, 'DS-09-06', '搜索解空间的算法框架', 4, 4);

-- 计算机组成原理 (104)
INSERT INTO `t_knowledge_point` (`id`, `name`, `parent_id`, `subject_id`, `level`, `code`, `description`, `difficulty`, `importance`) VALUES
(10401, '计算机组成原理', NULL, 104, 1, 'CO', '计算机硬件系统的基本组成和工作原理', 3, 5),
(1040101, '数据的表示和运算', 10401, 104, 2, 'CO-01', '数制、编码、运算方法', 3, 5),
(104010101, '数制与编码', 1040101, 104, 3, 'CO-01-01', '进制转换、原码、反码、补码', 2, 5),
(104010102, '定点数的表示', 1040101, 104, 3, 'CO-01-02', '定点数的表示范围', 3, 4),
(104010103, '浮点数的表示', 1040101, 104, 3, 'CO-01-03', 'IEEE754浮点数标准', 4, 5),
(104010104, '算术逻辑单元', 1040101, 104, 3, 'CO-01-04', 'ALU的结构和功能', 3, 5),
(1040102, '存储系统', 10401, 104, 2, 'CO-02', '存储器的层次结构', 4, 5),
(104010201, '存储器的层次结构', 1040102, 104, 3, 'CO-02-01', 'Cache、主存、辅存层次', 3, 5),
(104010202, '半导体存储器', 1040102, 104, 3, 'CO-02-02', 'RAM、ROM类型和特点', 2, 4),
(104010203, 'Cache', 1040102, 104, 3, 'CO-02-03', '高速缓存的映射和替换策略', 4, 5),
(104010204, '虚拟存储器', 1040102, 104, 3, 'CO-02-04', '页式、段式、段页式存储管理', 4, 5),
(1040103, '指令系统', 10401, 104, 2, 'CO-03', '指令格式、寻址方式', 3, 5),
(104010301, '指令格式', 1040103, 104, 3, 'CO-03-01', '操作码、地址码结构', 2, 5),
(104010302, '寻址方式', 1040103, 104, 3, 'CO-03-02', '立即/直接/间接/寄存器寻址', 3, 5),
(104010303, 'CISC和RISC', 1040103, 104, 3, 'CO-03-03', '复杂指令集和精简指令集', 3, 4),
(1040104, '中央处理器', 10401, 104, 2, 'CO-04', 'CPU的结构和功能', 4, 5),
(104010401, 'CPU结构', 1040104, 104, 3, 'CO-04-01', '寄存器、控制器、运算器', 3, 5),
(104010402, '指令执行', 1040104, 104, 3, 'CO-04-02', '指令周期、时序系统', 4, 5),
(104010403, '流水线', 1040104, 104, 3, 'CO-04-03', '指令流水线技术', 4, 5),
(1040105, '总线', 10401, 104, 2, 'CO-05', '计算机总线系统', 3, 4),
(104010501, '总线概念', 1040105, 104, 3, 'CO-05-01', '总线的分类和性能指标', 2, 4),
(104010502, '总线仲裁', 1040105, 104, 3, 'CO-05-02', '总线仲裁方式', 3, 4),
(104010503, '总线标准', 1040105, 104, 3, 'CO-05-03', '常见总线标准', 2, 3),
(1040106, '输入输出系统', 10401, 104, 2, 'CO-06', 'I/O接口和控制方式', 3, 4),
(104010601, 'I/O接口', 1040106, 104, 3, 'CO-06-01', 'I/O端口编址方式', 2, 4),
(104010602, 'I/O控制方式', 1040106, 104, 3, 'CO-06-02', '程序查询、中断、DMA', 4, 5),
(104010603, '中断系统', 1040106, 104, 3, 'CO-06-03', '中断处理过程', 4, 5);

-- 操作系统 (107)
INSERT INTO `t_knowledge_point` (`id`, `name`, `parent_id`, `subject_id`, `level`, `code`, `description`, `difficulty`, `importance`) VALUES
(10701, '操作系统', NULL, 107, 1, 'OS', '管理和控制计算机系统软硬件资源的系统软件', 3, 5),
(1070101, '进程管理', 10701, 107, 2, 'OS-01', '进程调度、同步、通信', 4, 5),
(107010101, '进程与线程', 1070101, 107, 3, 'OS-01-01', '进程和线程的概念与区别', 2, 5),
(107010102, '进程调度', 1070101, 107, 3, 'OS-01-02', '调度算法: FCFS/SJF/RR等', 4, 5),
(107010103, '进程同步', 1070101, 107, 3, 'OS-01-03', '临界区、信号量、管程', 4, 5),
(107010104, '死锁', 1070101, 107, 3, 'OS-01-04', '死锁原因、必要条件、处理', 4, 5),
(1070102, '内存管理', 10701, 107, 2, 'OS-02', '内存分配和地址转换', 4, 5),
(107010201, '内存分配', 1070102, 107, 3, 'OS-02-01', '连续分配、分页、分段', 3, 5),
(107010202, '虚拟内存', 1070102, 107, 3, 'OS-02-02', '页面置换算法', 4, 5),
(107010203, '动态分区分配', 1070102, 107, 3, 'OS-02-03', '首次适应、最佳适应等', 3, 4),
(1070103, '文件管理', 10701, 107, 2, 'OS-03', '文件的组织和管理', 3, 4),
(107010301, '文件系统', 1070103, 107, 3, 'OS-03-01', '文件的逻辑结构和物理结构', 3, 4),
(107010302, '目录管理', 1070103, 107, 3, 'OS-03-02', '单级、两级、多级目录', 2, 3),
(107010303, '文件操作', 1070103, 107, 3, 'OS-03-03', '文件的创建、删除、读写', 2, 3),
(1070104, '设备管理', 10701, 107, 2, 'OS-04', 'I/O设备的调度和控制', 3, 4),
(107010401, 'I/O控制方式', 1070104, 107, 3, 'OS-04-01', '程序直接控制、中断、DMA、通道', 3, 5),
(107010402, '缓冲管理', 1070104, 107, 3, 'OS-04-02', '单缓冲、双缓冲、循环缓冲', 3, 4),
(107010403, '磁盘调度', 1070104, 107, 3, 'OS-04-03', 'FCFS、SCAN、CSCAN等算法', 4, 5),
(1070105, '操作系统概述', 10701, 107, 2, 'OS-05', '操作系统的基本概念和特征', 2, 4),
(107010501, 'OS基本概念', 1070105, 107, 3, 'OS-05-01', '定义、发展、分类', 2, 4),
(107010502, '进程和程序', 1070105, 107, 3, 'OS-05-02', '程序与进程的区别', 2, 5),
(107010503, '内核和中断', 1070105, 107, 3, 'OS-05-03', '特权级、系统调用、异常', 3, 4),
(1070106, '并发控制', 10701, 107, 2, 'OS-06', '并发执行的协调', 4, 5),
(107010601, 'PV操作', 1070106, 107, 3, 'OS-06-01', '信号量机制的P、V操作', 4, 5),
(107010602, '管程', 1070106, 107, 3, 'OS-06-02', '管程的概念和实现', 4, 4),
(107010603, '经典同步问题', 1070106, 107, 3, 'OS-06-03', '生产者-消费者、哲学家就餐等', 4, 5);

-- 计算机网络 (110)
INSERT INTO `t_knowledge_point` (`id`, `name`, `parent_id`, `subject_id`, `level`, `code`, `description`, `difficulty`, `importance`) VALUES
(11001, '计算机网络', NULL, 110, 1, 'NET', '计算机之间的通信和网络技术', 3, 5),
(1100101, '计算机网络体系结构', 11001, 110, 2, 'NET-01', 'OSI和TCP/IP模型', 3, 5),
(110010101, 'OSI参考模型', 1100101, 110, 3, 'NET-01-01', '七层协议体系结构', 2, 5),
(110010102, 'TCP/IP模型', 1100101, 110, 3, 'NET-01-02', '四层协议体系结构', 2, 5),
(110010103, '网络协议', 1100101, 110, 3, 'NET-01-03', '协议的概念和服务', 2, 4),
(1100102, '物理层', 11001, 110, 2, 'NET-02', '数据传输的物理载体', 2, 4),
(110010201, '数据传输基础', 1100102, 110, 3, 'NET-02-01', '奈奎斯特、香农定理', 3, 4),
(110010202, '传输介质', 1100102, 110, 3, 'NET-02-02', '双绞线、光纤、无线', 2, 3),
(110010203, '物理层设备', 1100102, 110, 3, 'NET-02-03', '中继器、集线器', 2, 3),
(1100103, '数据链路层', 11001, 110, 2, 'NET-03', '节点间的可靠传输', 3, 5),
(110010301, '帧封装', 1100103, 110, 3, 'NET-03-01', '帧的结构和封装', 2, 5),
(110010302, '差错控制', 1100103, 110, 3, 'NET-03-02', 'CRC、奇偶校验', 3, 5),
(110010303, '流量控制', 1100103, 110, 3, 'NET-03-03', '停止-等待、滑动窗口', 4, 5),
(110010304, '介质访问控制', 1100103, 110, 3, 'NET-03-04', 'CSMA/CD、CSMA/CA', 4, 5),
(110010305, '局域网', 1100103, 110, 3, 'NET-03-05', '以太网、令牌环', 2, 4),
(1100104, '网络层', 11001, 110, 2, 'NET-04', 'IP协议和路由', 4, 5),
(110010401, 'IP协议', 1100104, 110, 3, 'NET-04-01', 'IP地址、子网划分', 3, 5),
(110010402, '路由协议', 1100104, 110, 3, 'NET-04-02', 'RIP、OSPF、BGP', 4, 4),
(110010403, 'ARP和ICMP', 1100104, 110, 3, 'NET-04-03', '地址解析和差错控制', 3, 4),
(110010404, 'IPv6', 1100104, 110, 3, 'NET-04-04', '下一代IP协议', 3, 4),
(1100105, '传输层', 11001, 110, 2, 'NET-05', '端到端的可靠传输', 4, 5),
(110010501, 'TCP协议', 1100105, 110, 3, 'NET-05-01', '可靠传输、流量控制、拥塞控制', 4, 5),
(110010502, 'UDP协议', 1100105, 110, 3, 'NET-05-02', '无连接传输', 2, 4),
(110010503, '端口', 1100105, 110, 3, 'NET-05-03', '端口号和套接字', 2, 5),
(1100106, '应用层', 11001, 110, 2, 'NET-06', '网络服务和应用协议', 3, 4),
(110010601, 'DNS', 1100106, 110, 3, 'NET-06-01', '域名系统', 3, 4),
(110010602, 'HTTP', 1100106, 110, 3, 'NET-06-02', '超文本传输协议', 3, 5),
(110010603, 'FTP和Email', 1100106, 110, 3, 'NET-06-03', '文件传输和电子邮件', 2, 3);

-- ----------------------------
-- 知识点关系初始化 (构建知识图谱边)
-- ----------------------------
INSERT INTO `t_knowledge_relation` (`knowledge_id_from`, `knowledge_id_to`, `relation_type`, `weight`, `description`) VALUES
-- 数据结构内部关系
(1010101, 10102, 'prerequisite', 1.0, '学习栈之前需掌握线性表'),
(1010101, 1010103, 'prerequisite', 1.0, '学习队列之前需掌握线性表'),
(101010102, 10102, 'contains', 0.8, '链表可以用于实现栈'),
(101010102, 1010103, 'contains', 0.8, '链表可以用于实现队列'),
(10102, 10103, 'prerequisite', 0.9, '学习图之前需掌握树结构'),
(101020101, 101020102, 'prerequisite', 0.9, '学习BST之前需掌握遍历'),
(101020101, 101020103, 'prerequisite', 0.8, '学习AVL之前需掌握遍历'),
(1010603, 1010604, 'contains', 0.7, '分治法是动态规划的基础思想'),
(1010604, 1010605, 'contrast', 0.6, '动态规划与贪心算法对比'),
-- 组成原理内部关系
(1040101, 1040102, 'prerequisite', 1.0, '数据的表示和运算是存储系统的基础'),
(1040103, 1040104, 'prerequisite', 1.0, '指令系统是CPU功能的基础'),
(104010402, 104010403, 'prerequisite', 0.9, '理解指令执行后才能学流水线'),
-- 操作系统内部关系
(107010601, 107010103, 'prerequisite', 1.0, 'PV操作是进程同步的基础'),
(107010104, 107010601, 'contains', 0.8, '死锁处理涉及PV操作'),
(107010201, 107010202, 'prerequisite', 0.9, '理解基本内存分配后再学虚拟内存'),
-- 计算机网络内部关系
(1100102, 1100103, 'prerequisite', 1.0, '物理层是数据链路层的基础'),
(1100103, 1100104, 'prerequisite', 1.0, '网络层需要链路层的帧封装'),
(1100104, 1100105, 'prerequisite', 1.0, '传输层基于网络层的IP'),
(1100105, 1100106, 'prerequisite', 1.0, '应用层协议基于TCP/UDP');

-- ============================================
-- 输出完成信息
-- ============================================
SELECT '========================================' AS '';
SELECT '数据库增强脚本执行完成！' AS result;
SELECT '' AS '';
SELECT COUNT(*) AS 知识点总数 FROM t_knowledge_point;
SELECT COUNT(*) AS 知识点关系数 FROM t_knowledge_relation;
