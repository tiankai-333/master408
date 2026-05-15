-- AI Agent 管理系统数据库设计

-- ============================================
-- 1. AI提示词模板表
-- ============================================
DROP TABLE IF EXISTS `t_ai_prompt_template`;
CREATE TABLE `t_ai_prompt_template` (
    `id` INT(11) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `style` VARCHAR(50) NOT NULL COMMENT '风格标识（如：default, feynman, plato, first-principles）',
    `name` VARCHAR(100) NOT NULL COMMENT '风格名称',
    `description` VARCHAR(500) DEFAULT '' COMMENT '风格描述',
    `icon` VARCHAR(50) DEFAULT '' COMMENT '图标（emoji）',
    `system_prompt` TEXT NOT NULL COMMENT '系统提示词',
    `user_prompt_template` TEXT NOT NULL COMMENT '用户提示词模板',
    `knowledge_base_ids` VARCHAR(255) DEFAULT '' COMMENT '关联的知识库ID，逗号分隔',
    `reference_materials` TEXT COMMENT '参考材料（JSON格式，包含书籍、演讲等）',
    `variables` VARCHAR(255) DEFAULT '' COMMENT '变量列表，逗号分隔',
    `output_format` VARCHAR(50) DEFAULT 'markdown' COMMENT '输出格式：markdown, json, html',
    `temperature` DECIMAL(3,2) DEFAULT 0.70 COMMENT '温度参数',
    `max_tokens` INT(11) DEFAULT 4096 COMMENT '最大token数',
    `enabled` TINYINT(1) DEFAULT 1 COMMENT '是否启用：0-禁用，1-启用',
    `is_default` TINYINT(1) DEFAULT 0 COMMENT '是否默认风格',
    `usage_count` INT(11) DEFAULT 0 COMMENT '使用次数',
    `rating_sum` INT(11) DEFAULT 0 COMMENT '评分总和',
    `rating_count` INT(11) DEFAULT 0 COMMENT '评分次数',
    `create_user` INT(11) DEFAULT 1 COMMENT '创建用户ID',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted` BIT(1) DEFAULT b'0' COMMENT '是否删除',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_style` (`style`),
    KEY `idx_enabled` (`enabled`),
    KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='AI提示词模板表';

-- ============================================
-- 2. AI知识库表
-- ============================================
DROP TABLE IF EXISTS `t_ai_knowledge_base`;
CREATE TABLE `t_ai_knowledge_base` (
    `id` INT(11) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `category` VARCHAR(50) NOT NULL COMMENT '分类：methodology（方法论）、domain（领域）、example（案例）',
    `domain` VARCHAR(50) NOT NULL COMMENT '领域：如 computer_science, math, physics',
    `sub_domain` VARCHAR(50) DEFAULT '' COMMENT '子领域：如 data_structure, algorithm',
    `title` VARCHAR(200) NOT NULL COMMENT '标题',
    `keywords` VARCHAR(255) DEFAULT '' COMMENT '关键词，逗号分隔',
    `content` TEXT NOT NULL COMMENT '知识内容',
    `source_type` VARCHAR(50) DEFAULT '' COMMENT '来源类型：book, article, speech, lecture',
    `source_name` VARCHAR(200) DEFAULT '' COMMENT '来源名称：如《理想国》、费曼演讲',
    `source_author` VARCHAR(100) DEFAULT '' COMMENT '作者/演讲者',
    `core_concepts` TEXT COMMENT '核心概念（JSON数组）',
    `application_scenarios` TEXT COMMENT '应用场景（JSON数组）',
    `examples` TEXT COMMENT '示例（JSON数组）',
    `enabled` TINYINT(1) DEFAULT 1 COMMENT '是否启用',
    `priority` INT(11) DEFAULT 0 COMMENT '优先级，数字越大越优先',
    `usage_count` INT(11) DEFAULT 0 COMMENT '使用次数',
    `create_user` INT(11) DEFAULT 1 COMMENT '创建用户ID',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted` BIT(1) DEFAULT b'0' COMMENT '是否删除',
    PRIMARY KEY (`id`),
    KEY `idx_category` (`category`),
    KEY `idx_domain` (`domain`),
    KEY `idx_enabled` (`enabled`),
    KEY `idx_priority` (`priority`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='AI知识库表';

-- ============================================
-- 3. AI调整日志表
-- ============================================
DROP TABLE IF EXISTS `t_ai_adjustment_log`;
CREATE TABLE `t_ai_adjustment_log` (
    `id` INT(11) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `template_id` INT(11) DEFAULT NULL COMMENT '关联的模板ID',
    `style` VARCHAR(50) NOT NULL COMMENT '风格标识',
    `adjustment_type` VARCHAR(50) NOT NULL COMMENT '调整类型：create, update, delete, test, optimize',
    `before_content` TEXT COMMENT '调整前的内容',
    `after_content` TEXT COMMENT '调整后的内容',
    `adjustment_reason` VARCHAR(500) DEFAULT '' COMMENT '调整原因',
    `adjustment_details` TEXT COMMENT '调整详情（JSON格式，记录具体修改）',
    `test_result` TEXT COMMENT '测试结果',
    `test_question` TEXT COMMENT '测试题目',
    `test_feedback` VARCHAR(500) DEFAULT '' COMMENT '测试反馈',
    `rating` INT(11) DEFAULT 0 COMMENT '评分：1-5',
    `status` VARCHAR(20) DEFAULT 'pending' COMMENT '状态：pending, approved, rejected',
    `approver_id` INT(11) DEFAULT NULL COMMENT '审批人ID',
    `approve_time` DATETIME DEFAULT NULL COMMENT '审批时间',
    `approve_comment` VARCHAR(500) DEFAULT '' COMMENT '审批意见',
    `create_user` INT(11) DEFAULT 1 COMMENT '操作用户ID',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
    `ip_address` VARCHAR(50) DEFAULT '' COMMENT 'IP地址',
    PRIMARY KEY (`id`),
    KEY `idx_template_id` (`template_id`),
    KEY `idx_style` (`style`),
    KEY `idx_adjustment_type` (`adjustment_type`),
    KEY `idx_create_time` (`create_time`),
    KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='AI调整日志表';

-- ============================================
-- 4. AI使用记录表
-- ============================================
DROP TABLE IF EXISTS `t_ai_usage_log`;
CREATE TABLE `t_ai_usage_log` (
    `id` INT(11) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `template_id` INT(11) DEFAULT NULL COMMENT '使用的模板ID',
    `style` VARCHAR(50) NOT NULL COMMENT '风格标识',
    `ai_type` VARCHAR(20) DEFAULT '' COMMENT 'AI类型：glm, openai',
    `model` VARCHAR(50) DEFAULT '' COMMENT '模型名称',
    `question` TEXT NOT NULL COMMENT '用户问题',
    `knowledge_points` TEXT COMMENT '关联的知识点',
    `knowledge_base_ids` VARCHAR(255) DEFAULT '' COMMENT '使用的知识库ID',
    `prompt` TEXT COMMENT '发送的完整提示词',
    `response` TEXT COMMENT 'AI响应',
    `response_length` INT(11) DEFAULT 0 COMMENT '响应长度',
    `tokens_used` INT(11) DEFAULT 0 COMMENT '使用的token数',
    `cost` DECIMAL(10,4) DEFAULT 0 COMMENT '费用',
    `duration_ms` INT(11) DEFAULT 0 COMMENT '耗时（毫秒）',
    `success` TINYINT(1) DEFAULT 1 COMMENT '是否成功',
    `error_message` TEXT COMMENT '错误信息',
    `user_rating` INT(11) DEFAULT 0 COMMENT '用户评分：1-5',
    `user_feedback` TEXT COMMENT '用户反馈',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    KEY `idx_template_id` (`template_id`),
    KEY `idx_style` (`style`),
    KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='AI使用记录表';

-- ============================================
-- 5. 初始化默认提示词模板
-- ============================================
INSERT INTO `t_ai_prompt_template` (`style`, `name`, `description`, `icon`, `system_prompt`, `user_prompt_template`, `reference_materials`, `enabled`, `is_default`) VALUES
('default', '标准解析', '清晰专业，讲清楚知识点', '📚', 
'你是一个专业的计算机考研408辅导老师。你的任务是解析题目，帮助学生理解知识点。请用清晰、专业的语言进行讲解。',
'请解析以下408考研题目：\n\n题目：{question}\n\n相关知识点：{knowledge_points}\n\n请按照以下格式回答：\n1. 题目分析\n2. 核心知识点\n3. 解题思路\n4. 详细解答\n5. 常见误区',
'[{"type":"book","name":"计算机网络：自顶向下方法","author":"James F. Kurose"},{"type":"book","name":"数据结构与算法","author":"严蔚敏"}]',
1, 1),

('feynman', '费曼风格', '通俗易懂，像给小白讲解', '🎓',
'你是一个善于用费曼学习法讲解的老师。费曼学习法的核心是：用最简单、最通俗易懂的语言，把复杂的知识讲明白，就像给一个完全不懂的小白讲解一样。避免使用专业术语，或者如果使用了，必须用大白话解释清楚。',
'请用费曼学习法讲解以下408考研题目：\n\n题目：{question}\n\n相关知识点：{knowledge_points}\n\n请按照以下格式讲解：\n1. 一句话说清楚这道题在考什么（用大白话）\n2. 用生活化的例子解释相关知识点\n3. 一步步教你怎么解这道题\n4. 总结一下，通过这道题你学会了什么',
'[{"type":"book","name":"费曼物理学讲义","author":"理查德·费曼"},{"type":"article","name":"费曼学习法详解","author":"待补充"},{"type":"speech","name":"费曼谈计算与物理","author":"理查德·费曼"}]',
1, 0),

('plato', '柏拉图风格', '启发式提问，引导思考', '❓',
'你是一个像苏格拉底一样的老师。你不直接告诉学生答案，而是通过提问和引导，让学生自己思考并发现问题。你相信"教育不是灌输，而是点燃火焰"。',
'请用苏格拉底式提问法讲解以下408考研题目：\n\n题目：{question}\n\n相关知识点：{knowledge_points}\n\n请按照以下格式讲解：\n1. 先问几个简单的问题，确认学生的基础理解\n2. 通过类比和比喻，引导学生发现问题\n3. 逐步深入，帮助学生自己推导出答案\n4. 最后引导学生总结：通过这道题，你学到了什么思维方式？',
'[{"type":"book","name":"理想国","author":"柏拉图"},{"type":"book","name":"苏菲的世界","author":"乔斯坦·贾德"},{"type":"article","name":"苏格拉底式提问法","author":"待补充"}]',
1, 0),

('first-principles', '第一性原理', '从本质出发，逐步推导', '⚡',
'你是一个善于用第一性原理思考的老师。第一性原理的核心是：把问题分解到最基本的事实和不可再简化的真理，然后从这些基本点出发重新构建理解。就像埃隆·马斯克思考火箭发射成本一样，我们要找到问题的本质。',
'请用第一性原理讲解以下408考研题目：\n\n题目：{question}\n\n相关知识点：{knowledge_points}\n\n请按照以下格式讲解：\n1. 这个问题的"基本粒子"是什么？（最不可拆分的事实）\n2. 我们已知的公理有哪些？\n3. 从这些公理出发，如何一步步推导到答案？\n4. 这个问题的"物理定律"是什么？（即：为什么这个规律是这样的？）',
'[{"type":"speech","name":"马斯克谈第一性原理","author":"埃隆·马斯克"},{"type":"article","name":"第一性原理思考法","author":"待补充"},{"type":"book","name":"从零到一","author":"彼得·蒂尔"},{"type":"article","name":"计算机科学中的第一性原理","author":"待补充"}]',
1, 0);

-- ============================================
-- 6. 初始化知识库数据
-- ============================================
INSERT INTO `t_ai_knowledge_base` (`category`, `domain`, `sub_domain`, `title`, `keywords`, `content`, `source_type`, `source_name`, `source_author`, `priority`) VALUES
-- 方法论类
('methodology', 'learning', '', '费曼学习法详解', '费曼,学习,理解,教授', 
'费曼学习法的核心步骤：\n1. 选择一个概念\n2. 假装要教给一个小孩子\n3. 遇到卡壳就回头查阅资料\n4. 用简单的话重新表述\n5. 找生活中的类比\n\n关键点：真正的理解是把复杂的知识用简单的语言表达出来。',
'book', '费曼学习法', '理查德·费曼', 10),

('methodology', 'thinking', '', '第一性原理思维', '第一性,本质,分解,重构,马斯克',
'第一性原理思考步骤：\n1. 识别当前假设\n2. 把问题分解到最基本的事实\n3. 问"我们确定这个事实吗？"\n4. 从这些不可动摇的事实重建解决方案\n\n应用示例：马斯克问"火箭发射的成本可以降低到多少？"而不是"火箭一直这么贵"。',
'speech', '埃隆·马斯克谈第一性原理', '埃隆·马斯克', 10),

('methodology', 'teaching', '', '苏格拉底式提问法', '苏格拉底,提问,引导,启发,柏拉图',
'苏格拉底式提问的四种类型：\n1. 澄清性问题："你说的XXX是什么意思？"\n2. 假设探查："你这样说的前提是什么？"\n3. 证据追问："有什么证据支持这个观点？"\n4. 观点影响："如果这个成立，那么会怎样？"\n\n核心：帮助学生通过自己的思考发现问题，而不是直接告知答案。',
'book', '理想国', '柏拉图', 9),

-- 计算机科学类
('domain', 'computer_science', 'data_structure', '数据结构中的"第一性"', '数据,结构,组织,效率',
'数据结构的"第一性"思考：\n\n1. 什么是数据？\n   - 最基本：二进制位（0和1）\n   - 组合：字节、字段、记录、文件\n\n2. 什么是结构？\n   - 线性：数组、链表（一个接一个）\n   - 层次：树（父子关系）\n   - 网状：图（任意连接）\n\n3. 为什么要组织数据？\n   - 目标：快速查找、快速插入、快速删除\n   - 约束：空间与时间的权衡\n\n4. 核心问题：\n   - "这棵树为什么是这样设计的？"\n   - "hash表的本质是什么？"（把任意key映射到固定位置）\n   - "为什么 BST 能提高查找效率？"（利用了"有序"这个信息）',
'article', '计算机科学中的第一性原理', '待补充', 10),

('domain', 'computer_science', 'algorithm', '算法的"第一性"', '算法,步骤,指令,计算',
'算法的"第一性"思考：\n\n1. 算法的本质是什么？\n   - 输入 → 一系列步骤 → 输出\n   - 核心：将问题分解为可执行的步骤\n\n2. 算法的正确性如何保证？\n   - 有穷性：一定会结束\n   - 确定性：每一步都明确\n   - 可行性：每一步都能执行\n\n3. 算法效率的本质：\n   - 时间复杂度：执行步骤的数量\n   - 空间复杂度：需要存储多少数据\n\n4. 重要思维：\n   - "这个问题为什么需要O(n log n)，能不能更快？"\n   - "分治策略的核心洞察是什么？"（分解 → 解决 → 合并）',
'article', '算法的第一性原理', '待补充', 10),

('domain', 'computer_science', 'network', '计算机网络中的"第一性"', '网络,通信,协议,分层',
'计算机网络的"第一性"思考：\n\n1. 网络的本质是什么？\n   - 目标：让两台计算机交换数据\n   - 问题：如何在不确定的环境中可靠传输？\n\n2. 为什么需要分层？\n   - 每一层只解决一个问题\n   - 层与层之间通过接口交互\n   - 如同物流系统：包装 → 快递公司 → 运输 → 快递公司 → 开箱\n\n3. 协议的本质：\n   - "如果...则..."的规则集合\n   - 双方必须遵守的约定\n\n4. 核心问题：\n   - "TCP为什么要三次握手？"（建立可靠的连接）\n   - "HTTP为什么设计成无状态的？"（简化服务器设计）\n   - "DNS为什么要分布式？"（快速响应+高可用）',
'book', '计算机网络：自顶向下方法', 'James F. Kurose', 9),

-- 通俗类比
('example', 'life', '', '生活中的数据结构', '生活,比喻,理解,形象',
'用生活理解数据结构：\n\n1. 数组 vs 链表：\n   - 数组：图书馆的固定书架（知道位置就能直接拿）\n   - 链表：游乐场的排队（必须从第一个人问起）\n\n2. 栈 vs 队列：\n   - 栈：弹匣（后进先出）\n   - 队列：排队买票（先来先服务）\n\n3. 树：\n   - 二叉树：公司组织架构（每个领导管两个下属）\n   - BST：有序的字典（翻到那一页就能找到）\n\n4. 哈希表：\n   - 想象图书馆的索书号系统\n   - 通过某种规则（一本书属于哪个字母）直接定位',
'article', '用生活理解数据结构', '待补充', 8),

('example', 'life', '', '生活中的算法思维', '生活,排序,查找,优化',
'用生活理解算法：\n\n1. 排序思想：\n   - 插入排序：整理扑克牌\n   - 快速排序：按字母分堆再整理\n   - 归并排序：先分小再合并\n\n2. 查找思想：\n   - 顺序查找：挨个问路\n   - 二分查找：猜数字游戏（每次猜中间）\n\n3. 优化思维：\n   - 贪心：每步都选当前最优\n   - 动态规划：记住之前的计算结果\n\n4. 图算法：\n   - BFS：朋友圈找人（一圈一圈扩散）\n   - DFS：走迷宫（一条路走到黑）',
'article', '用生活理解算法', '待补充', 8);
