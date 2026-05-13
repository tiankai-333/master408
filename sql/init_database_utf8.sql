/*
 * ============================================
 * 408刷题系统 - 数据库初始化脚本 (UTF-8完整版)
 * ============================================
 *
 * 问题修复：解决前端界面显示"???"乱码问题
 * 原因：数据库字符编码不正确或连接字符集不对
 *
 * 使用方法：
 * 1. 先备份现有数据库（如果有重要数据）
 * 2. 进入MySQL命令行：
 *    mysql -u root -p
 * 3. 设置连接字符集：
 *    set names utf8mb4;
 * 4. 执行脚本：
 *    source C:/Dev/Workspaces/master408/sql/init_database_utf8.sql
 *
 * ============================================
 */

-- ----------------------------
-- 0. 设置连接字符集（关键！）
-- ----------------------------
SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;
SET character_set_client = utf8mb4;
SET character_set_results = utf8mb4;
SET character_set_connection = utf8mb4;

-- ----------------------------
-- 1. 创建数据库（如果不存在）
-- ----------------------------
DROP DATABASE IF EXISTS xzs;
CREATE DATABASE IF NOT EXISTS xzs
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

USE xzs;

-- 再次设置会话字符集
SET NAMES utf8mb4;

-- ----------------------------
-- 2. 创建学科表 t_subject
-- ----------------------------
DROP TABLE IF EXISTS `t_subject`;
CREATE TABLE `t_subject` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '学科ID',
  `name` varchar(255) NOT NULL COMMENT '学科名称',
  `level` int DEFAULT NULL COMMENT '年级等级：1=期末考, 2=考研, 3=复试',
  `level_name` varchar(255) DEFAULT NULL COMMENT '年级名称',
  `item_order` int DEFAULT NULL COMMENT '排序号',
  `deleted` bit(1) DEFAULT b'0' COMMENT '是否删除',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='学科表';

-- ----------------------------
-- 3. 创建题目内容表 t_text_content
-- ----------------------------
DROP TABLE IF EXISTS `t_text_content`;
CREATE TABLE `t_text_content` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '内容ID',
  `content` text NOT NULL COMMENT 'JSON格式的题目内容',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='题目内容表';

-- ----------------------------
-- 4. 创建题目表 t_question
-- ----------------------------
DROP TABLE IF EXISTS `t_question`;
CREATE TABLE `t_question` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '题目ID',
  `question_type` int DEFAULT NULL COMMENT '题型：1=单选, 2=多选, 3=判断, 4=填空, 5=简答',
  `subject_id` int DEFAULT NULL COMMENT '学科ID',
  `score` int DEFAULT NULL COMMENT '分值',
  `grade_level` int DEFAULT NULL COMMENT '年级等级',
  `difficult` int DEFAULT NULL COMMENT '难度：1-5',
  `correct` text DEFAULT NULL COMMENT '正确答案',
  `info_text_content_id` int DEFAULT NULL COMMENT '关联的内容ID',
  `create_user` int DEFAULT NULL COMMENT '创建用户ID',
  `status` int DEFAULT NULL COMMENT '状态：0=禁用, 1=启用',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `deleted` bit(1) DEFAULT b'0' COMMENT '是否删除',
  PRIMARY KEY (`id`),
  INDEX `subject_id`(`subject_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='题目表';

-- ----------------------------
-- 5. 创建用户表 t_user
-- ----------------------------
DROP TABLE IF EXISTS `t_user`;
CREATE TABLE `t_user` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `user_uuid` varchar(36) DEFAULT NULL COMMENT '用户UUID',
  `user_name` varchar(255) NOT NULL COMMENT '用户名',
  `password` varchar(255) NOT NULL COMMENT '密码',
  `real_name` varchar(255) DEFAULT NULL COMMENT '真实姓名',
  `age` int DEFAULT NULL COMMENT '年龄',
  `sex` int DEFAULT NULL COMMENT '性别：1=男, 2=女',
  `birth_day` datetime DEFAULT NULL COMMENT '出生日期',
  `user_level` int DEFAULT NULL COMMENT '年级',
  `phone` varchar(255) DEFAULT NULL COMMENT '手机号',
  `role` int DEFAULT NULL COMMENT '角色：1=管理员, 2=学生',
  `status` int DEFAULT NULL COMMENT '状态：0=禁用, 1=启用',
  `image_path` varchar(255) DEFAULT NULL COMMENT '头像路径',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `modify_time` datetime DEFAULT NULL COMMENT '修改时间',
  `last_active_time` datetime DEFAULT NULL COMMENT '最后活跃时间',
  `deleted` bit(1) DEFAULT b'0' COMMENT '是否删除',
  `wx_open_id` varchar(255) DEFAULT NULL COMMENT '微信OpenID',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';

-- ----------------------------
-- 6. 创建试卷表 t_exam_paper
-- ----------------------------
DROP TABLE IF EXISTS `t_exam_paper`;
CREATE TABLE `t_exam_paper` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '试卷ID',
  `name` varchar(255) DEFAULT NULL COMMENT '试卷名称',
  `subject_id` int DEFAULT NULL COMMENT '学科ID',
  `paper_type` int DEFAULT NULL COMMENT '试卷类型',
  `score` int DEFAULT NULL COMMENT '总分',
  `question_count` int DEFAULT NULL COMMENT '题目数量',
  `suggest_time` int DEFAULT NULL COMMENT '建议时长(分钟)',
  `type_text` varchar(255) DEFAULT NULL COMMENT '类型文本',
  `grade_level` int DEFAULT NULL COMMENT '年级等级',
  `frame_text_content_id` int DEFAULT NULL COMMENT '框架内容ID',
  `create_user` int DEFAULT NULL COMMENT '创建用户ID',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `deleted` bit(1) DEFAULT b'0' COMMENT '是否删除',
  `create_user_name` varchar(255) DEFAULT NULL COMMENT '创建用户名',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='试卷表';

-- ----------------------------
-- 7. 创建用户答题表 t_exam_paper_answer
-- ----------------------------
DROP TABLE IF EXISTS `t_exam_paper_answer`;
CREATE TABLE `t_exam_paper_answer` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '答题记录ID',
  `exam_paper_id` int DEFAULT NULL COMMENT '试卷ID',
  `paper_name` varchar(255) DEFAULT NULL COMMENT '试卷名称',
  `subject_id` int DEFAULT NULL COMMENT '学科ID',
  `score` int DEFAULT NULL COMMENT '得分',
  `paper_score` int DEFAULT NULL COMMENT '试卷总分',
  `question_correct` int DEFAULT NULL COMMENT '正确题数',
  `question_count` int DEFAULT NULL COMMENT '总题数',
  `do_time` int DEFAULT NULL COMMENT '做题时长(秒)',
  `status` int DEFAULT NULL COMMENT '状态',
  `create_user` int DEFAULT NULL COMMENT '做题用户ID',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `task_exam_id` int DEFAULT NULL COMMENT '任务考试ID',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='试卷答题记录表';

-- ----------------------------
-- 8. 创建答题详情表 t_exam_paper_question_customer_answer
-- ----------------------------
DROP TABLE IF EXISTS `t_exam_paper_question_customer_answer`;
CREATE TABLE `t_exam_paper_question_customer_answer` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '答题详情ID',
  `question_id` int DEFAULT NULL COMMENT '题目ID',
  `exam_paper_id` int DEFAULT NULL COMMENT '试卷ID',
  `exam_paper_answer_id` int DEFAULT NULL COMMENT '答题记录ID',
  `question_type` int DEFAULT NULL COMMENT '题型',
  `subject_id` int DEFAULT NULL COMMENT '学科ID',
  `customer_score` int DEFAULT NULL COMMENT '用户得分',
  `question_score` int DEFAULT NULL COMMENT '题目满分',
  `question_text_content_id` int DEFAULT NULL COMMENT '题目内容ID',
  `answer` varchar(255) DEFAULT NULL COMMENT '用户答案',
  `text_content_id` int DEFAULT NULL COMMENT '答案内容ID',
  `do_right` bit(1) DEFAULT NULL COMMENT '是否正确',
  `create_user` int DEFAULT NULL COMMENT '做题用户ID',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `item_order` int DEFAULT NULL COMMENT '排序号',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='试卷答题详情表';

-- ----------------------------
-- 9. 创建消息表 t_message
-- ----------------------------
DROP TABLE IF EXISTS `t_message`;
CREATE TABLE `t_message` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '消息ID',
  `title` varchar(255) DEFAULT NULL COMMENT '消息标题',
  `content` varchar(500) DEFAULT NULL COMMENT '消息内容',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `send_user_id` int DEFAULT NULL COMMENT '发送者用户ID',
  `send_user_name` varchar(255) DEFAULT NULL COMMENT '发送者用户名',
  `send_real_name` varchar(255) DEFAULT NULL COMMENT '发送者真实姓名',
  `receive_user_count` int DEFAULT NULL COMMENT '接收人数',
  `read_count` int DEFAULT NULL COMMENT '已读人数',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='消息表';

-- ----------------------------
-- 10. 创建消息用户关联表 t_message_user
-- ----------------------------
DROP TABLE IF EXISTS `t_message_user`;
CREATE TABLE `t_message_user` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '关联ID',
  `message_id` int DEFAULT NULL COMMENT '消息ID',
  `receive_user_id` int DEFAULT NULL COMMENT '接收用户ID',
  `receive_user_name` varchar(255) DEFAULT NULL COMMENT '接收用户名',
  `receive_real_name` varchar(255) DEFAULT NULL COMMENT '接收用户真实姓名',
  `readed` bit(1) DEFAULT NULL COMMENT '是否已读',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `read_time` datetime DEFAULT NULL COMMENT '阅读时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='消息用户关联表';

-- ----------------------------
-- 11. 创建任务考试表 t_task_exam
-- ----------------------------
DROP TABLE IF EXISTS `t_task_exam`;
CREATE TABLE `t_task_exam` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '任务考试ID',
  `title` varchar(255) DEFAULT NULL COMMENT '任务标题',
  `grade_level` int DEFAULT NULL COMMENT '年级等级',
  `frame_text_content_id` int DEFAULT NULL COMMENT '框架内容ID',
  `create_user` int DEFAULT NULL COMMENT '创建用户ID',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `deleted` bit(1) DEFAULT b'0' COMMENT '是否删除',
  `create_user_name` varchar(255) DEFAULT NULL COMMENT '创建用户名',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='任务考试表';

-- ----------------------------
-- 12. 创建任务考试答题表 t_task_exam_customer_answer
-- ----------------------------
DROP TABLE IF EXISTS `t_task_exam_customer_answer`;
CREATE TABLE `t_task_exam_customer_answer` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '答题ID',
  `task_exam_id` int DEFAULT NULL COMMENT '任务考试ID',
  `create_user` int DEFAULT NULL COMMENT '答题用户ID',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `text_content_id` int DEFAULT NULL COMMENT '答案内容ID',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='任务考试答题表';

-- ----------------------------
-- 13. 创建用户事件日志表 t_user_event_log
-- ----------------------------
DROP TABLE IF EXISTS `t_user_event_log`;
CREATE TABLE `t_user_event_log` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '日志ID',
  `user_id` int DEFAULT NULL COMMENT '用户ID',
  `user_name` varchar(255) DEFAULT NULL COMMENT '用户名',
  `real_name` varchar(255) DEFAULT NULL COMMENT '真实姓名',
  `content` text DEFAULT NULL COMMENT '日志内容',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户事件日志表';

-- ----------------------------
-- 14. 创建用户Token表 t_user_token
-- ----------------------------
DROP TABLE IF EXISTS `t_user_token`;
CREATE TABLE `t_user_token` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT 'TokenID',
  `token` varchar(36) DEFAULT NULL COMMENT 'Token值',
  `user_id` int DEFAULT NULL COMMENT '用户ID',
  `wx_open_id` varchar(255) DEFAULT NULL COMMENT '微信OpenID',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `end_time` datetime DEFAULT NULL COMMENT '过期时间',
  `user_name` varchar(255) DEFAULT NULL COMMENT '用户名',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户Token表';

-- ============================================
-- 数据插入部分
-- ============================================

-- ----------------------------
-- 插入学科数据
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
-- ----------------------------
INSERT INTO `t_text_content` (`id`, `content`, `create_time`) VALUES
-- 数据结构单选题1
(1001, '{"titleContent":"若一个栈的输入序列为1,2,3,4,5，则下列序列中不可能是栈的输出序列的是（）","analyze":"栈遵循后进先出规则。D选项中，当输出4、5后，栈内剩余元素为1、2、3，此时栈顶是3，下一个输出不可能是2（必须先弹出3才能弹出2），因此该序列非法。","questionItemObjects":[{"prefix":"A","content":"2,3,4,1,5","itemUuid":"a1b2c3d4-0001"},{"prefix":"B","content":"5,4,3,2,1","itemUuid":"a1b2c3d4-0002"},{"prefix":"C","content":"2,4,3,5,1","itemUuid":"a1b2c3d4-0003"},{"prefix":"D","content":"4,5,2,3,1","itemUuid":"a1b2c3d4-0004"}]}', NOW()),

-- 数据结构单选题2
(1002, '{"titleContent":"一棵3阶B树，除根节点外，每个节点的关键字个数最少为（）","analyze":"m阶B树的规则：每个节点的子节点数最多为m，最少为⌈m/2⌉（根节点除外）。3阶B树的最少子节点数为⌈3/2⌉=2，而关键字数=子节点数-1，因此最少关键字数为1。","questionItemObjects":[{"prefix":"A","content":"1","itemUuid":"b1b2c3d4-0001"},{"prefix":"B","content":"2","itemUuid":"b1b2c3d4-0002"},{"prefix":"C","content":"3","itemUuid":"b1b2c3d4-0003"},{"prefix":"D","content":"4","itemUuid":"b1b2c3d4-0004"}]}', NOW()),

-- 数据结构单选题3
(1003, '{"titleContent":"在长度为n的顺序表中插入一个元素的平均时间复杂度为（）","analyze":"在顺序表中插入元素，平均需要移动n/2个元素，因此时间复杂度为O(n)。","questionItemObjects":[{"prefix":"A","content":"O(1)","itemUuid":"c1b2c3d4-0001"},{"prefix":"B","content":"O(n)","itemUuid":"c1b2c3d4-0002"},{"prefix":"C","content":"O(n²)","itemUuid":"c1b2c3d4-0003"},{"prefix":"D","content":"O(log n)","itemUuid":"c1b2c3d4-0004"}]}', NOW()),

-- 数据结构判断题1
(1004, '{"titleContent":"完全二叉树中，度为1的节点个数要么是0，要么是1。","analyze":"完全二叉树的定义：除最后一层外，每一层上的节点数均达到最大值；在最后一层上只缺少右边的若干节点。因此，度为1的节点最多只有1个，且要么没有，要么只有1个。","questionItemObjects":[],"correct":"正确"}', NOW()),

-- 计算机组成原理单选题1
(1005, '{"titleContent":"某计算机Cache容量为16KB，块大小为16B，采用2路组相联映射，则Cache的组数为（）","analyze":"总块数 = Cache容量 / 块大小 = 16KB / 16B = 1024 块。2路组相联意味着每组包含2个块，因此组数 = 总块数 / 路数 = 1024 / 2 = 512。","questionItemObjects":[{"prefix":"A","content":"128","itemUuid":"d1b2c3d4-0001"},{"prefix":"B","content":"256","itemUuid":"d1b2c3d4-0002"},{"prefix":"C","content":"512","itemUuid":"d1b2c3d4-0003"},{"prefix":"D","content":"1024","itemUuid":"d1b2c3d4-0004"}]}', NOW()),

-- 计算机组成原理单选题2
(1006, '{"titleContent":"某指令系统指令字长16位，每个操作数地址码6位，指令分为二地址、一地址、零地址三种。若二地址指令有12种，零地址指令有64种，则一地址指令最多有（）种。","analyze":"二地址指令的操作码占16-6-6=4位，最多16种，用了12种，剩余4个编码用来扩展。这4个编码可以扩展出4*2^6=256种一地址指令，其中最后一部分编码用来扩展零地址，零地址有64种，占用了64/2^6=1个一地址的编码。因此一地址最多有256-1=255种。","questionItemObjects":[{"prefix":"A","content":"255","itemUuid":"e1b2c3d4-0001"},{"prefix":"B","content":"256","itemUuid":"e1b2c3d4-0002"},{"prefix":"C","content":"511","itemUuid":"e1b2c3d4-0003"},{"prefix":"D","content":"1024","itemUuid":"e1b2c3d4-0004"}]}', NOW()),

-- 计算机组成原理单选题3
(1007, '{"titleContent":"在补码加减运算中，判断溢出的规则是（）","analyze":"补码运算中，两个正数相加结果为负，或两个负数相加结果为正，则发生溢出。即：最高位进位和次高位进位不同则溢出。","questionItemObjects":[{"prefix":"A","content":"最高位进位和次高位进位相同","itemUuid":"f1b2c3d4-0001"},{"prefix":"B","content":"最高位进位和次高位进位不同","itemUuid":"f1b2c3d4-0002"},{"prefix":"C","content":"最高位有进位","itemUuid":"f1b2c3d4-0003"},{"prefix":"D","content":"次高位有进位","itemUuid":"f1b2c3d4-0004"}]}', NOW()),

-- 操作系统单选题1
(1009, '{"titleContent":"有三个作业，到达时间分别为0、1、2，运行时间分别为3、2、1，采用非抢占式短作业优先（SJF）调度，平均周转时间为（）","analyze":"非抢占式SJF会等当前作业运行完再调度：作业1先运行3个单位，结束时间3；作业2运行2个单位，结束时间5；作业3运行1个单位，结束时间6。平均周转时间：(3+4+4)/3 ≈ 3.67","questionItemObjects":[{"prefix":"A","content":"3.33","itemUuid":"g1b2c3d4-0001"},{"prefix":"B","content":"3.67","itemUuid":"g1b2c3d4-0002"},{"prefix":"C","content":"4.0","itemUuid":"g1b2c3d4-0003"},{"prefix":"D","content":"4.33","itemUuid":"g1b2c3d4-0004"}]}', NOW()),

-- 操作系统单选题2
(1010, '{"titleContent":"进程页面走向为4,3,2,1,4,3,5,4,3,2,1,5，物理块数为3，采用LRU置换算法，缺页次数为（）","analyze":"LRU会淘汰最久未使用的页面。缺页发生在第1、2、3、4、5、6、7、9、10、12次访问，共10次缺页。","questionItemObjects":[{"prefix":"A","content":"9","itemUuid":"h1b2c3d4-0001"},{"prefix":"B","content":"10","itemUuid":"h1b2c3d4-0002"},{"prefix":"C","content":"11","itemUuid":"h1b2c3d4-0003"},{"prefix":"D","content":"12","itemUuid":"h1b2c3d4-0004"}]}', NOW()),

-- 操作系统单选题3
(1011, '{"titleContent":"在死锁的四个必要条件中，不可破坏的是（）","analyze":"死锁的四个必要条件：互斥条件、请求和保持条件、不可抢占条件、循环等待条件。其中互斥条件是不可破坏的，因为资源本身需要互斥访问。","questionItemObjects":[{"prefix":"A","content":"互斥条件","itemUuid":"i1b2c3d4-0001"},{"prefix":"B","content":"请求和保持条件","itemUuid":"i1b2c3d4-0002"},{"prefix":"C","content":"不可抢占条件","itemUuid":"i1b2c3d4-0003"},{"prefix":"D","content":"循环等待条件","itemUuid":"i1b2c3d4-0004"}]}', NOW()),

-- 计算机网络单选题1
(1013, '{"titleContent":"TCP拥塞控制中，初始cwnd=1，ssthresh=8，当cwnd增长到12时发生了超时，此时新的ssthresh和cwnd分别为（）","analyze":"TCP超时后，会将ssthresh设置为当前cwnd的一半（12/2=6），同时将cwnd重置为1，重新开始慢开始。","questionItemObjects":[{"prefix":"A","content":"6,1","itemUuid":"j1b2c3d4-0001"},{"prefix":"B","content":"6,6","itemUuid":"j1b2c3d4-0002"},{"prefix":"C","content":"8,1","itemUuid":"j1b2c3d4-0003"},{"prefix":"D","content":"8,6","itemUuid":"j1b2c3d4-0004"}]}', NOW()),

-- 计算机网络单选题2
(1014, '{"titleContent":"网络192.168.5.0/24，要划分5个子网，每个子网最少18台主机，子网掩码应为（）","analyze":"每个子网需要18台主机，主机位至少需要5位（2^5-2=30≥18）。因此网络位为32-5=27位，子网掩码为255.255.255.224。","questionItemObjects":[{"prefix":"A","content":"255.255.255.192","itemUuid":"k1b2c3d4-0001"},{"prefix":"B","content":"255.255.255.224","itemUuid":"k1b2c3d4-0002"},{"prefix":"C","content":"255.255.255.240","itemUuid":"k1b2c3d4-0003"},{"prefix":"D","content":"255.255.255.248","itemUuid":"k1b2c3d4-0004"}]}', NOW()),

-- 计算机网络判断题1
(1015, '{"titleContent":"ARP协议的作用是将IP地址转换为MAC地址。","analyze":"ARP（地址解析协议）的主要作用是根据IP地址查找对应的MAC地址。当主机需要发送数据到同一网络中的另一台主机时，需要知道对方的MAC地址，这时就需要使用ARP协议。","questionItemObjects":[],"correct":"正确"}', NOW());

-- ----------------------------
-- 插入题目记录（t_question）
-- question_type: 1=单选, 3=判断, 5=简答
-- ----------------------------
-- 数据结构（期末考）
INSERT INTO `t_question` (`id`, `question_type`, `subject_id`, `score`, `grade_level`, `difficult`, `correct`, `info_text_content_id`, `create_user`, `status`, `create_time`, `deleted`) VALUES
(1001, 1, 100, 5, 1, 3, 'D', 1001, 1, 1, NOW(), b'0'),
(1002, 1, 100, 5, 1, 3, 'A', 1002, 1, 1, NOW(), b'0'),
(1003, 1, 100, 5, 1, 2, 'B', 1003, 1, 1, NOW(), b'0'),
(1004, 3, 100, 5, 1, 2, '正确', 1004, 1, 1, NOW(), b'0');

-- 计算机组成原理（期末考）
INSERT INTO `t_question` (`id`, `question_type`, `subject_id`, `score`, `grade_level`, `difficult`, `correct`, `info_text_content_id`, `create_user`, `status`, `create_time`, `deleted`) VALUES
(1031, 1, 103, 5, 1, 3, 'C', 1005, 1, 1, NOW(), b'0'),
(1032, 1, 103, 5, 1, 4, 'A', 1006, 1, 1, NOW(), b'0'),
(1033, 1, 103, 5, 1, 3, 'B', 1007, 1, 1, NOW(), b'0');

-- 操作系统（期末考）
INSERT INTO `t_question` (`id`, `question_type`, `subject_id`, `score`, `grade_level`, `difficult`, `correct`, `info_text_content_id`, `create_user`, `status`, `create_time`, `deleted`) VALUES
(1061, 1, 106, 5, 1, 3, 'B', 1009, 1, 1, NOW(), b'0'),
(1062, 1, 106, 5, 1, 3, 'B', 1010, 1, 1, NOW(), b'0'),
(1063, 1, 106, 5, 1, 4, 'A', 1011, 1, 1, NOW(), b'0');

-- 计算机网络（期末考）
INSERT INTO `t_question` (`id`, `question_type`, `subject_id`, `score`, `grade_level`, `difficult`, `correct`, `info_text_content_id`, `create_user`, `status`, `create_time`, `deleted`) VALUES
(1091, 1, 109, 5, 1, 3, 'A', 1013, 1, 1, NOW(), b'0'),
(1092, 1, 109, 5, 1, 3, 'B', 1014, 1, 1, NOW(), b'0'),
(1093, 3, 109, 5, 1, 2, '正确', 1015, 1, 1, NOW(), b'0');

-- ----------------------------
-- 插入测试用户
-- 用户名: admin, 密码: 123456 (BCrypt加密)
-- 用户名: student, 密码: 123456 (BCrypt加密)
-- ----------------------------
INSERT INTO `t_user` (`id`, `user_uuid`, `user_name`, `password`, `real_name`, `age`, `sex`, `birth_day`, `user_level`, `phone`, `role`, `status`, `image_path`, `create_time`, `modify_time`, `last_active_time`, `deleted`, `wx_open_id`) VALUES
(1, 'd2d29da2-dcb3-4013-b874-727626236f47', 'student', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH', '学生小明', 20, 1, '2004-01-01 00:00:00', 1, '19171171610', 2, 1, 'https://www.mindskip.net:9008/image/ba607a75-83ba-4530-8e23-660b72dc4953/头像.jpg', NOW(), NOW(), NULL, b'0', NULL),
(2, '52045f5f-a13f-4ccc-93dd-f7ee8270ad4c', 'admin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH', '系统管理员', 30, 1, '1994-01-01 00:00:00', NULL, NULL, 1, 1, NULL, NOW(), NOW(), NULL, b'0', NULL);

-- ============================================
-- 验证查询
-- ============================================
SELECT '========================================' AS '';
SELECT '数据库初始化完成！' AS result;
SELECT '' AS '';
SELECT '学科数量：' AS info, COUNT(*) AS count FROM t_subject;
SELECT '题目数量：' AS info, COUNT(*) AS count FROM t_question;
SELECT '用户数量：' AS info, COUNT(*) AS count FROM t_user;
SELECT '' AS '';
SELECT '测试账号：' AS info;
SELECT '  admin / 123456 (管理员)' AS account;
SELECT '  student / 123456 (学生)' AS account;
