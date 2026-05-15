/*
 * ============================================
 * 408刷题系统 - 数据库初始化脚本
 * ============================================
 * 执行此脚本可完成以下操作：
 * 1. 创建数据库 xzs
 * 2. 创建所有必要的表结构
 * 3. 插入基础数据（学科、题目等）
 * 4. 创建测试用户
 * 
 * 使用方法：
 * 1. 进入MySQL命令行：mysql -u root -p
 * 2. 执行脚本：source /path/to/init_database.sql
 * 
 * ============================================
 */

-- ----------------------------
-- 1. 创建数据库（如果不存在）
-- ----------------------------
DROP DATABASE IF EXISTS xzs;
CREATE DATABASE IF NOT EXISTS xzs DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE xzs;

-- ----------------------------
-- 2. 创建学科表 t_subject
-- ----------------------------
DROP TABLE IF EXISTS `t_subject`;
CREATE TABLE `t_subject` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '学科ID',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '学科名称',
  `level` int NULL DEFAULT NULL COMMENT '年级等级：1=期末考, 2=考研, 3=复试',
  `level_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '年级名称',
  `item_order` int NULL DEFAULT NULL COMMENT '排序号',
  `deleted` bit(1) NULL DEFAULT b'0' COMMENT '是否删除',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = COMPACT COMMENT = '学科表';

-- ----------------------------
-- 3. 创建题目内容表 t_text_content
-- ----------------------------
DROP TABLE IF EXISTS `t_text_content`;
CREATE TABLE `t_text_content` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '内容ID',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT 'JSON格式的题目内容',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = COMPACT COMMENT = '题目内容表';

-- ----------------------------
-- 4. 创建题目表 t_question
-- ----------------------------
DROP TABLE IF EXISTS `t_question`;
CREATE TABLE `t_question` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '题目ID',
  `question_type` int NULL DEFAULT NULL COMMENT '题型：1=单选, 2=简答',
  `subject_id` int NULL DEFAULT NULL COMMENT '学科ID',
  `score` int NULL DEFAULT NULL COMMENT '分值',
  `grade_level` int NULL DEFAULT NULL COMMENT '年级等级',
  `difficult` int NULL DEFAULT NULL COMMENT '难度：1-5',
  `correct` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '正确答案',
  `info_text_content_id` int NULL DEFAULT NULL COMMENT '关联的内容ID',
  `create_user` int NULL DEFAULT NULL COMMENT '创建用户ID',
  `status` int NULL DEFAULT NULL COMMENT '状态：0=禁用, 1=启用',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `deleted` bit(1) NULL DEFAULT b'0' COMMENT '是否删除',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `subject_id`(`subject_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = COMPACT COMMENT = '题目表';

-- ----------------------------
-- 5. 创建用户表 t_user
-- ----------------------------
DROP TABLE IF EXISTS `t_user`;
CREATE TABLE `t_user` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `user_uuid` varchar(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '用户UUID',
  `user_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '用户名',
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '密码',
  `real_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '真实姓名',
  `age` int NULL DEFAULT NULL COMMENT '年龄',
  `sex` int NULL DEFAULT NULL COMMENT '性别：1=男, 2=女',
  `birth_day` datetime NULL DEFAULT NULL COMMENT '出生日期',
  `user_level` int NULL DEFAULT NULL COMMENT '年级',
  `phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '手机号',
  `role` int NULL DEFAULT NULL COMMENT '角色：1=管理员, 2=学生, 3=学生',
  `status` int NULL DEFAULT NULL COMMENT '状态：0=禁用, 1=启用',
  `image_path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '头像路径',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `modify_time` datetime NULL DEFAULT NULL COMMENT '修改时间',
  `last_active_time` datetime NULL DEFAULT NULL COMMENT '最后活跃时间',
  `deleted` bit(1) NULL DEFAULT b'0' COMMENT '是否删除',
  `wx_open_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '微信OpenID',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = COMPACT COMMENT = '用户表';

-- ----------------------------
-- 6. 创建试卷表 t_exam_paper
-- ----------------------------
DROP TABLE IF EXISTS `t_exam_paper`;
CREATE TABLE `t_exam_paper` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '试卷ID',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '试卷名称',
  `subject_id` int NULL DEFAULT NULL COMMENT '学科ID',
  `paper_type` int NULL DEFAULT NULL COMMENT '试卷类型',
  `grade_level` int NULL DEFAULT NULL COMMENT '年级等级',
  `score` int NULL DEFAULT NULL COMMENT '总分',
  `question_count` int NULL DEFAULT NULL COMMENT '题目数量',
  `suggest_time` int NULL DEFAULT NULL COMMENT '建议时长(分钟)',
  `limit_start_time` datetime NULL DEFAULT NULL COMMENT '开始时间限制',
  `limit_end_time` datetime NULL DEFAULT NULL COMMENT '结束时间限制',
  `frame_text_content_id` int NULL DEFAULT NULL COMMENT '试卷框架内容ID',
  `create_user` int NULL DEFAULT NULL COMMENT '创建用户ID',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `deleted` bit(1) NULL DEFAULT b'0' COMMENT '是否删除',
  `task_exam_id` int NULL DEFAULT NULL COMMENT '任务考试ID',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = COMPACT COMMENT = '试卷表';

-- ----------------------------
-- 7. 创建试卷题目关联表 t_exam_paper_question
-- ----------------------------
DROP TABLE IF EXISTS `t_exam_paper_question`;
CREATE TABLE `t_exam_paper_question` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '关联ID',
  `exam_paper_id` int NULL DEFAULT NULL COMMENT '试卷ID',
  `question_id` int NULL DEFAULT NULL COMMENT '题目ID',
  `question_type` int NULL DEFAULT NULL COMMENT '题型',
  `subject_id` int NULL DEFAULT NULL COMMENT '学科ID',
  `score` int NULL DEFAULT NULL COMMENT '本题分值',
  `item_order` int NULL DEFAULT NULL COMMENT '排序号',
  `question_text_content_id` int NULL DEFAULT NULL COMMENT '题目内容ID',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `exam_paper_id`(`exam_paper_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = COMPACT COMMENT = '试卷题目关联表';

-- ----------------------------
-- 8. 创建试卷答题记录表 t_exam_paper_answer
-- ----------------------------
DROP TABLE IF EXISTS `t_exam_paper_answer`;
CREATE TABLE `t_exam_paper_answer` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '答题记录ID',
  `exam_paper_id` int NULL DEFAULT NULL COMMENT '试卷ID',
  `paper_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '试卷名称',
  `paper_type` int NULL DEFAULT NULL COMMENT '试卷类型',
  `subject_id` int NULL DEFAULT NULL COMMENT '学科ID',
  `system_score` int NULL DEFAULT NULL COMMENT '系统评分',
  `user_score` int NULL DEFAULT NULL COMMENT '用户评分',
  `paper_score` int NULL DEFAULT NULL COMMENT '试卷总分',
  `question_correct` int NULL DEFAULT NULL COMMENT '正确题数',
  `question_count` int NULL DEFAULT NULL COMMENT '总题数',
  `do_time` int NULL DEFAULT NULL COMMENT '做题时长(秒)',
  `status` int NULL DEFAULT NULL COMMENT '状态',
  `create_user` int NULL DEFAULT NULL COMMENT '做题用户ID',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `task_exam_id` int NULL DEFAULT NULL COMMENT '任务考试ID',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = COMPACT COMMENT = '试卷答题记录表';

-- ----------------------------
-- 9. 创建试卷答题详情表 t_exam_paper_question_customer_answer
-- ----------------------------
DROP TABLE IF EXISTS `t_exam_paper_question_customer_answer`;
CREATE TABLE `t_exam_paper_question_customer_answer` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '答题详情ID',
  `question_id` int NULL DEFAULT NULL COMMENT '题目ID',
  `exam_paper_id` int NULL DEFAULT NULL COMMENT '试卷ID',
  `exam_paper_answer_id` int NULL DEFAULT NULL COMMENT '答题记录ID',
  `question_type` int NULL DEFAULT NULL COMMENT '题型',
  `subject_id` int NULL DEFAULT NULL COMMENT '学科ID',
  `customer_score` int NULL DEFAULT NULL COMMENT '用户得分',
  `question_score` int NULL DEFAULT NULL COMMENT '题目满分',
  `question_text_content_id` int NULL DEFAULT NULL COMMENT '题目内容ID',
  `answer` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '用户答案',
  `text_content_id` int NULL DEFAULT NULL COMMENT '答案内容ID',
  `do_right` bit(1) NULL DEFAULT NULL COMMENT '是否正确',
  `create_user` int NULL DEFAULT NULL COMMENT '做题用户ID',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `item_order` int NULL DEFAULT NULL COMMENT '排序号',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = COMPACT COMMENT = '试卷答题详情表';

-- ----------------------------
-- 10. 创建消息表 t_message
-- ----------------------------
DROP TABLE IF EXISTS `t_message`;
CREATE TABLE `t_message` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '消息ID',
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '消息标题',
  `content` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '消息内容',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `send_user_id` int NULL DEFAULT NULL COMMENT '发送者用户ID',
  `send_user_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '发送者用户名',
  `send_real_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '发送者真实姓名',
  `receive_user_count` int NULL DEFAULT NULL COMMENT '接收人数',
  `read_count` int NULL DEFAULT NULL COMMENT '已读人数',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = COMPACT COMMENT = '消息表';

-- ----------------------------
-- 11. 创建消息用户关联表 t_message_user
-- ----------------------------
DROP TABLE IF EXISTS `t_message_user`;
CREATE TABLE `t_message_user` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '关联ID',
  `message_id` int NULL DEFAULT NULL COMMENT '消息ID',
  `receive_user_id` int NULL DEFAULT NULL COMMENT '接收用户ID',
  `receive_user_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '接收用户名',
  `receive_real_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '接收用户真实姓名',
  `readed` bit(1) NULL DEFAULT NULL COMMENT '是否已读',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `read_time` datetime NULL DEFAULT NULL COMMENT '阅读时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = COMPACT COMMENT = '消息用户关联表';

-- ----------------------------
-- 12. 创建任务考试表 t_task_exam
-- ----------------------------
DROP TABLE IF EXISTS `t_task_exam`;
CREATE TABLE `t_task_exam` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '任务考试ID',
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '任务标题',
  `grade_level` int NULL DEFAULT NULL COMMENT '年级等级',
  `frame_text_content_id` int NULL DEFAULT NULL COMMENT '框架内容ID',
  `create_user` int NULL DEFAULT NULL COMMENT '创建用户ID',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `deleted` bit(1) NULL DEFAULT b'0' COMMENT '是否删除',
  `create_user_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '创建用户名',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = COMPACT COMMENT = '任务考试表';

-- ----------------------------
-- 13. 创建任务考试答题表 t_task_exam_customer_answer
-- ----------------------------
DROP TABLE IF EXISTS `t_task_exam_customer_answer`;
CREATE TABLE `t_task_exam_customer_answer` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '答题ID',
  `task_exam_id` int NULL DEFAULT NULL COMMENT '任务考试ID',
  `create_user` int NULL DEFAULT NULL COMMENT '答题用户ID',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `text_content_id` int NULL DEFAULT NULL COMMENT '答案内容ID',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = COMPACT COMMENT = '任务考试答题表';

-- ----------------------------
-- 14. 创建用户事件日志表 t_user_event_log
-- ----------------------------
DROP TABLE IF EXISTS `t_user_event_log`;
CREATE TABLE `t_user_event_log` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '日志ID',
  `user_id` int NULL DEFAULT NULL COMMENT '用户ID',
  `user_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '用户名',
  `real_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '真实姓名',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '日志内容',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = COMPACT COMMENT = '用户事件日志表';

-- ----------------------------
-- 15. 创建用户Token表 t_user_token
-- ----------------------------
DROP TABLE IF EXISTS `t_user_token`;
CREATE TABLE `t_user_token` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT 'TokenID',
  `token` varchar(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'Token值',
  `user_id` int NULL DEFAULT NULL COMMENT '用户ID',
  `wx_open_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '微信OpenID',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `end_time` datetime NULL DEFAULT NULL COMMENT '过期时间',
  `user_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '用户名',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = COMPACT COMMENT = '用户Token表';

-- ============================================
-- 数据插入部分
-- ============================================

-- ----------------------------
-- 插入学科数据
-- level: 1=期末考, 2=考研, 3=复试
-- ----------------------------
INSERT INTO `t_subject` (`id`, `name`, `level`, `level_name`, `item_order`, `deleted`) VALUES
(100, '数据结构', 1, '期末考', 1, b'0'),
(101, '数据结构', 2, '考研', 2, b'0'),
(102, '数据结构', 3, '复试', 3, b'0'),
(103, '计算机组成原理', 1, '期末考', 4, b'0'),
(104, '计算机组成原理', 2, '考研', 5, b'0'),
(105, '计算机组成原理', 3, '复试', 6, b'0'),
(106, '操作系统', 1, '期末考', 7, b'0'),
(107, '操作系统', 2, '考研', 8, b'0'),
(108, '操作系统', 3, '复试', 9, b'0'),
(109, '计算机网络', 1, '期末考', 10, b'0'),
(110, '计算机网络', 2, '考研', 11, b'0'),
(111, '计算机网络', 3, '复试', 12, b'0');

-- ----------------------------
-- 插入题目内容（t_text_content）
-- JSON格式说明见下方注释
-- ----------------------------
INSERT INTO `t_text_content` (`id`, `content`, `create_time`) VALUES
-- 数据结构单选题1
(1001, '{"titleContent":"若一个栈的输入序列为1,2,3,4,5，则下列序列中不可能是栈的输出序列的是（）","analyze":"栈遵循后进先出规则。D选项中，当输出4、5后，栈内剩余元素为1、2、3，此时栈顶是3，下一个输出不可能是2（必须先弹出3才能弹出2），因此该序列非法。","questionItemObjects":[{"prefix":"A","content":"2,3,4,1,5","itemUuid":"a1b2c3d4-0001"},{"prefix":"B","content":"5,4,3,2,1","itemUuid":"a1b2c3d4-0002"},{"prefix":"C","content":"2,4,3,5,1","itemUuid":"a1b2c3d4-0003"},{"prefix":"D","content":"4,5,2,3,1","itemUuid":"a1b2c3d4-0004"}]}', NOW()),
-- 数据结构单选题2
(1002, '{"titleContent":"一棵3阶B树，除根节点外，每个节点的关键字个数最少为（）","analyze":"m阶B树的规则：每个节点的子节点数最多为m，最少为⌈m/2⌉（根节点除外）。3阶B树的最少子节点数为⌈3/2⌉=2，而关键字数=子节点数-1，因此最少关键字数为1。","questionItemObjects":[{"prefix":"A","content":"1","itemUuid":"b1b2c3d4-0001"},{"prefix":"B","content":"2","itemUuid":"b1b2c3d4-0002"},{"prefix":"C","content":"3","itemUuid":"b1b2c3d4-0003"},{"prefix":"D","content":"4","itemUuid":"b1b2c3d4-0004"}]}', NOW()),
-- 数据结构简答题1
(1003, '{"titleContent":"设计一个算法，删除单链表中所有值为x的节点，要求时间复杂度O(n)，空间复杂度O(1)。","analyze":"通过双指针遍历链表，找到目标节点直接修改前驱指针完成删除，仅遍历一次，无需额外空间。pre指向当前节点的前驱，p指向当前节点。当p->data==x时，修改pre->next=p->next，释放p，然后p=pre->next；否则pre和p都后移。","questionItemObjects":[{"prefix":"代码","content":"typedef struct LNode { int data; struct LNode *next; } LNode, *LinkList; void deleteX(LinkList &L, int x) { LNode *pre = L, *p = L->next; while (p != NULL) { if (p->data == x) { pre->next = p->next; free(p); p = pre->next; } else { pre = p; p = p->next; } } }","itemUuid":"c1b2c3d4-0001"}], "correct":"通过双指针遍历链表，找到目标节点直接修改前驱指针完成删除，仅遍历一次，无需额外空间。"}', NOW()),
-- 数据结构简答题2
(1004, '{"titleContent":"已知一棵二叉树的前序遍历为ABDEGCFH，中序遍历为DBGEAFHC，请还原该二叉树，并写出后序遍历序列。","analyze":"1. 前序第一个节点A是根节点，中序中A左边的DBGE是左子树，右边的FHC是右子树。2. 左子树前序为BDEG，根为B，中序左子树中B左边D是左节点，右边GE是右子树。3. 以此类推还原出完整二叉树，最终后序遍历序列为：DGEBHFCA。","questionItemObjects":[],"correct":"后序遍历序列为：DGEBHFCA"}', NOW()),
-- 计算机组成原理单选题1
(1005, '{"titleContent":"某计算机Cache容量为16KB，块大小为16B，采用2路组相联映射，则Cache的组数为（）","analyze":"总块数 = Cache容量 / 块大小 = 16KB / 16B = 1024 块。2路组相联意味着每组包含2个块，因此组数 = 总块数 / 路数 = 1024 / 2 = 512。","questionItemObjects":[{"prefix":"A","content":"128","itemUuid":"d1b2c3d4-0001"},{"prefix":"B","content":"256","itemUuid":"d1b2c3d4-0002"},{"prefix":"C","content":"512","itemUuid":"d1b2c3d4-0003"},{"prefix":"D","content":"1024","itemUuid":"d1b2c3d4-0004"}]}', NOW()),
-- 计算机组成原理单选题2
(1006, '{"titleContent":"某指令系统指令字长16位，每个操作数地址码6位，指令分为二地址、一地址、零地址三种。若二地址指令有12种，零地址指令有64种，则一地址指令最多有（）种。","analyze":"二地址指令的操作码占16-6-6=4位，最多16种，用了12种，剩余4个编码用来扩展。这4个编码可以扩展出4*2^6=256种一地址指令，其中最后一部分编码用来扩展零地址，零地址有64种，占用了64/2^6=1个一地址的编码。因此一地址最多有256-1=255种。","questionItemObjects":[{"prefix":"A","content":"255","itemUuid":"e1b2c3d4-0001"},{"prefix":"B","content":"256","itemUuid":"e1b2c3d4-0002"},{"prefix":"C","content":"511","itemUuid":"e1b2c3d4-0003"},{"prefix":"D","content":"1024","itemUuid":"e1b2c3d4-0004"}]}', NOW()),
-- 计算机组成原理简答题1
(1007, '{"titleContent":"已知两个浮点数（阶码用移码，尾数用补码）：x=2^01 × 0.11011011，y=2^10 × 0.10101100，求x+y的结果。","analyze":"1. 对阶：小阶向大阶对齐，x的阶码1，y的阶码2，x的阶码加1，尾数右移1位：x=2^10 × 0.011011011\\n2. 尾数相加：0.011011011 + 0.10101100 = 1.000110011\\n3. 规格化：结果需要右规一次，阶码+1，变为2^11 × 0.100011001\\n4. 舍入：尾数保留8位，采用0舍1入，最终尾数为0.10001101\\n最终结果：x+y=2^11 × 0.10001101","questionItemObjects":[],"correct":"x+y=2^11 × 0.10001101"}', NOW()),
-- 操作系统单选题1
(1009, '{"titleContent":"有三个作业，到达时间分别为0、1、2，运行时间分别为3、2、1，采用非抢占式短作业优先（SJF）调度，平均周转时间为（）","analyze":"非抢占式SJF会等当前作业运行完再调度：\\n- 作业1：0时刻到达，先运行3个单位，结束时间3，周转时间3-0=3\\n- 作业2：接下来运行2个单位，结束时间5，周转时间5-1=4\\n- 作业3：最后运行1个单位，结束时间6，周转时间6-2=4\\n平均周转时间：(3+4+4)/3 ≈ 3.67","questionItemObjects":[{"prefix":"A","content":"3.33","itemUuid":"f1b2c3d4-0001"},{"prefix":"B","content":"3.67","itemUuid":"f1b2c3d4-0002"},{"prefix":"C","content":"4.0","itemUuid":"f1b2c3d4-0003"},{"prefix":"D","content":"4.33","itemUuid":"f1b2c3d4-0004"}]}', NOW()),
-- 操作系统单选题2
(1010, '{"titleContent":"进程页面走向为4,3,2,1,4,3,5,4,3,2,1,5，物理块数为3，采用LRU置换算法，缺页次数为（）","analyze":"LRU会淘汰最久未使用的页面，逐次模拟后，缺页发生在第1、2、3、4、5、6、7、9、10、12次访问，共10次缺页。\\n具体过程：\\n4(缺),3(缺),2(缺),1(缺-淘汰4),4(缺-淘汰3),3(缺-淘汰2),5(缺-淘汰1),4(命中),3(命中),2(缺-淘汰5),1(缺-淘汰4),5(缺-淘汰3)","questionItemObjects":[{"prefix":"A","content":"9","itemUuid":"g1b2c3d4-0001"},{"prefix":"B","content":"10","itemUuid":"g1b2c3d4-0002"},{"prefix":"C","content":"11","itemUuid":"g1b2c3d4-0003"},{"prefix":"D","content":"12","itemUuid":"g1b2c3d4-0004"}]}', NOW()),
-- 操作系统简答题1
(1011, '{"titleContent":"有一个大小为1的缓冲区，生产者负责生产产品放入缓冲区，消费者负责取出产品消费，用PV操作实现同步互斥。","analyze":"通过empty和full实现同步，保证生产者不会在缓冲区满时放入，消费者不会在空时取出；mutex实现互斥，保证同一时间只有一个进程访问缓冲区。\\n\\nsemaphore empty = 1; semaphore full = 0; semaphore mutex = 1;\\n\\n生产者：\\nP(empty); P(mutex); 放入产品; V(mutex); V(full);\\n\\n消费者：\\nP(full); P(mutex); 取出产品; V(mutex); V(empty);","questionItemObjects":[],"correct":"使用三个信号量：empty=1（缓冲区空位），full=0（缓冲区产品数），mutex=1（互斥锁）。生产者先P(empty)再P(mutex)，放入后V(mutex)V(full)；消费者先P(full)再P(mutex)，取出后V(mutex)V(empty)。"}', NOW()),
-- 计算机网络单选题1
(1013, '{"titleContent":"TCP拥塞控制中，初始cwnd=1，ssthresh=8，当cwnd增长到12时发生了超时，此时新的ssthresh和cwnd分别为（）","analyze":"TCP超时后，会将ssthresh设置为当前cwnd的一半（12/2=6），同时将cwnd重置为1，重新开始慢开始。","questionItemObjects":[{"prefix":"A","content":"6,1","itemUuid":"h1b2c3d4-0001"},{"prefix":"B","content":"6,6","itemUuid":"h1b2c3d4-0002"},{"prefix":"C","content":"8,1","itemUuid":"h1b2c3d4-0003"},{"prefix":"D","content":"8,6","itemUuid":"h1b2c3d4-0004"}]}', NOW()),
-- 计算机网络单选题2
(1014, '{"titleContent":"网络192.168.5.0/24，要划分5个子网，每个子网最少18台主机，子网掩码应为（）","analyze":"每个子网需要18台主机，主机位至少需要5位（2^5-2=30≥18，减2是去掉网络号和广播号）。因此网络位为32-5=27位，子网掩码为255.255.255.224，刚好可以划分8个子网，满足5个的需求。","questionItemObjects":[{"prefix":"A","content":"255.255.255.192","itemUuid":"i1b2c3d4-0001"},{"prefix":"B","content":"255.255.255.224","itemUuid":"i1b2c3d4-0002"},{"prefix":"C","content":"255.255.255.240","itemUuid":"i1b2c3d4-0003"},{"prefix":"D","content":"255.255.255.248","itemUuid":"i1b2c3d4-0004"}]}', NOW()),
-- 计算机网络简答题1
(1015, '{"titleContent":"TCP连接中，接收方的接收窗口rwnd=400，发送方拥塞窗口cwnd=500，MSS=100B。\\n1. 此时发送方最多可以发送多少字节？\\n2. 之后发送方收到了确认号300，接收方更新rwnd=300，此时发送方最多还能发送多少字节？","analyze":"1. 发送方的实际窗口是min(cwnd, rwnd) = min(500,400)=400B，因此最多发送400B。\\n2. 确认号300说明前300B已经被确认，剩下100B未确认。新的rwnd=300，所以可用窗口是300，减去未确认的100B，还能发送300-100=200B。","questionItemObjects":[],"correct":"1. 最多发送400字节\\n2. 还能发送200字节"}', NOW());

-- ----------------------------
-- 插入题目记录（t_question）
-- question_type: 1=单选, 5=简答
-- ----------------------------
-- 数据结构（期末考）
INSERT INTO `t_question` (`id`, `question_type`, `subject_id`, `score`, `grade_level`, `difficult`, `correct`, `info_text_content_id`, `create_user`, `status`, `create_time`, `deleted`) VALUES
(1001, 1, 100, 20, 1, 3, 'D', 1001, 1, 1, NOW(), b'0'),
(1002, 1, 100, 20, 1, 3, 'A', 1002, 1, 1, NOW(), b'0'),
(1003, 5, 100, 30, 1, 4, '双指针遍历', 1003, 1, 1, NOW(), b'0'),
(1004, 5, 100, 30, 1, 4, 'DGEBHFCA', 1004, 1, 1, NOW(), b'0');

-- 计算机组成原理（期末考）
INSERT INTO `t_question` (`id`, `question_type`, `subject_id`, `score`, `grade_level`, `difficult`, `correct`, `info_text_content_id`, `create_user`, `status`, `create_time`, `deleted`) VALUES
(1031, 1, 103, 20, 1, 3, 'C', 1005, 1, 1, NOW(), b'0'),
(1032, 1, 103, 20, 1, 4, 'A', 1006, 1, 1, NOW(), b'0'),
(1033, 5, 103, 30, 1, 4, '2^11×0.10001101', 1007, 1, 1, NOW(), b'0');

-- 操作系统（期末考）
INSERT INTO `t_question` (`id`, `question_type`, `subject_id`, `score`, `grade_level`, `difficult`, `correct`, `info_text_content_id`, `create_user`, `status`, `create_time`, `deleted`) VALUES
(1061, 1, 106, 20, 1, 3, 'B', 1009, 1, 1, NOW(), b'0'),
(1062, 1, 106, 20, 1, 3, 'B', 1010, 1, 1, NOW(), b'0'),
(1063, 5, 106, 30, 1, 4, 'PV操作同步互斥', 1011, 1, 1, NOW(), b'0');

-- 计算机网络（期末考）
INSERT INTO `t_question` (`id`, `question_type`, `subject_id`, `score`, `grade_level`, `difficult`, `correct`, `info_text_content_id`, `create_user`, `status`, `create_time`, `deleted`) VALUES
(1091, 1, 109, 20, 1, 3, 'A', 1013, 1, 1, NOW(), b'0'),
(1092, 1, 109, 20, 1, 3, 'B', 1014, 1, 1, NOW(), b'0'),
(1093, 5, 109, 30, 1, 4, '400B,200B', 1015, 1, 1, NOW(), b'0');

-- ----------------------------
-- 插入测试用户
-- 密码已加密（原始密码：123456）
-- ----------------------------
INSERT INTO `t_user` (`id`, `user_uuid`, `user_name`, `password`, `real_name`, `age`, `sex`, `birth_day`, `user_level`, `phone`, `role`, `status`, `image_path`, `create_time`, `modify_time`, `last_active_time`, `deleted`, `wx_open_id`) VALUES
(1, 'd2d29da2-dcb3-4013-b874-727626236f47', 'student', 'D1AGFL+Gx37t0NPG4d6biYP5Z31cNbwhK5w1lUeiHB2zagqbk8efYfSjYoh1Z/j1dkiRjHU+b0EpwzCh8IGsksJjzD65ci5LsnodQVf4Uj6D3pwoscXGqmkjjpzvSJbx42swwNTA+QoDU8YLo7JhtbUK2X0qCjFGpd+8eJ5BGvk=', '学生', 18, 1, '2019-09-01 16:00:00', 1, '19171171610', 1, 1, 'https://www.mindskip.net:9008/image/ba607a75-83ba-4530-8e23-660b72dc4953/头像.jpg', '2019-09-07 18:55:02', '2020-02-04 08:26:54', NULL, b'0', NULL),
(2, '52045f5f-a13f-4ccc-93dd-f7ee8270ad4c', 'admin', 'D1AGFL+Gx37t0NPG4d6biYP5Z31cNbwhK5w1lUeiHB2zagqbk8efYfSjYoh1Z/j1dkiRjHU+b0EpwzCh8IGsksJjzD65ci5LsnodQVf4Uj6D3pwoscXGqmkjjpzvSJbx42swwNTA+QoDU8YLo7JhtbUK2X0qCjFGpd+8eJ5BGvk=', '管理员', 30, 1, '2019-09-07 18:56:07', NULL, NULL, 3, 1, NULL, '2019-09-07 18:56:21', NULL, NULL, b'0', NULL);

-- ============================================
-- 题目SQL格式规范说明
-- ============================================
/*
 * 题目数据分为两部分存储：
 * 1. t_text_content: 存储题目的详细内容（JSON格式）
 * 2. t_question: 存储题目的元信息
 * 
 * t_text_content.content 字段 JSON 格式规范：
 * {
 *   "titleContent": "题目描述文本",           // 必填，题目的正文
 *   "analyze": "答案解析文本",               // 必填，题目的解析说明
 *   "questionItemObjects": [                 // 选择题必填，简答题可为空数组
 *     {
 *       "prefix": "A",                      // 选项前缀（A、B、C、D等）
 *       "content": "选项内容",               // 选项具体内容
 *       "itemUuid": "唯一标识符"             // UUID格式的唯一标识
 *     }
 *   ],
 *   "correct": "正确答案描述"                // 简答题可用，存储正确答案
 * }
 * 
 * t_question 字段说明：
 * - question_type: 题型（1=单选, 2=多选, 3=判断, 4=填空, 5=简答）
 * - subject_id: 关联学科ID（从t_subject表获取）
 * - grade_level: 年级等级（1=期末考, 2=考研, 3=复试）
 * - difficult: 难度（1-5，1最简单，5最难）
 * - correct: 正确答案（选择题填A/B/C/D，简答题填答案摘要）
 * - info_text_content_id: 关联t_text_content表的ID
 * - status: 状态（0=禁用, 1=启用）
 * 
 * 数据关联关系：
 * t_question.info_text_content_id -> t_text_content.id
 * t_question.subject_id -> t_subject.id
 */

-- 执行完成提示
SELECT '数据库初始化完成！' AS result;
SELECT COUNT(*) AS subject_count FROM t_subject;
SELECT COUNT(*) AS question_count FROM t_question;
SELECT COUNT(*) AS text_content_count FROM t_text_content;
SELECT COUNT(*) AS user_count FROM t_user;

SET FOREIGN_KEY_CHECKS = 1;
