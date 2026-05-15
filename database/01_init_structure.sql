-- ============================================
-- 初始化SQL (1) - 数据库表结构初始化
-- ============================================

-- 创建数据库（如果不存在）
CREATE DATABASE IF NOT EXISTS xzs DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE xzs;

-- ============================================
-- 1. 用户表 t_user
-- ============================================
DROP TABLE IF EXISTS `t_user`;
CREATE TABLE `t_user` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `username` varchar(50) NOT NULL COMMENT '用户名/学号',
  `password` varchar(100) NOT NULL COMMENT '密码',
  `real_name` varchar(50) NOT NULL COMMENT '真实姓名',
  `phone` varchar(20) DEFAULT '' COMMENT '手机号',
  `email` varchar(100) DEFAULT '' COMMENT '邮箱',
  `school` varchar(100) DEFAULT '' COMMENT '学校',
  `major` varchar(100) DEFAULT '' COMMENT '专业',
  `grade` varchar(20) DEFAULT '' COMMENT '年级',
  `class_name` varchar(50) DEFAULT '' COMMENT '班级',
  `gender` varchar(10) DEFAULT '' COMMENT '性别',
  `birthday` date DEFAULT NULL COMMENT '出生日期',
  `avatar` varchar(255) DEFAULT '' COMMENT '头像URL',
  `status` int DEFAULT '1' COMMENT '状态 1-正常 0-禁用',
  `role` varchar(20) DEFAULT 'student' COMMENT '角色 student/teacher/admin',
  `last_login_time` datetime DEFAULT NULL COMMENT '最后登录时间',
  `last_login_ip` varchar(50) DEFAULT '' COMMENT '最后登录IP',
  `total_login_count` int DEFAULT '0' COMMENT '累计登录次数',
  `create_user` int DEFAULT '1' COMMENT '创建用户ID',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) DEFAULT b'0' COMMENT '删除标记',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_username` (`username`),
  KEY `idx_status` (`status`),
  KEY `idx_role` (`role`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户表';

-- ============================================
-- 2. 学科表 t_subject
-- ============================================
DROP TABLE IF EXISTS `t_subject`;
CREATE TABLE `t_subject` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '学科ID',
  `name` varchar(50) NOT NULL COMMENT '学科名称',
  `code` varchar(20) NOT NULL COMMENT '学科代码',
  `description` varchar(500) DEFAULT '' COMMENT '学科描述',
  `icon` varchar(255) DEFAULT '' COMMENT '图标',
  `sort` int DEFAULT '0' COMMENT '排序',
  `enabled` bit(1) DEFAULT b'1' COMMENT '是否启用',
  `create_user` int DEFAULT '1' COMMENT '创建用户ID',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_enabled` (`enabled`),
  KEY `idx_sort` (`sort`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='学科表';

-- ============================================
-- 3. 题目表 t_question
-- ============================================
DROP TABLE IF EXISTS `t_question`;
CREATE TABLE `t_question` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '题目ID',
  `subject_id` int NOT NULL COMMENT '学科ID',
  `question_type` varchar(20) NOT NULL DEFAULT 'choice' COMMENT '题目类型 choice-选择题 multi_choice-多选题 judge-判断题',
  `title` text NOT NULL COMMENT '题目内容/题干',
  `options` text COMMENT '选项 JSON格式 [{"key":"A","value":"...","image":""}]',
  `correct_answer` varchar(10) NOT NULL COMMENT '正确答案',
  `analysis` text COMMENT '答案解析',
  `difficulty` int DEFAULT '2' COMMENT '难度 1-简单 2-中等 3-困难',
  `score` int DEFAULT '2' COMMENT '分值',
  `knowledge_point` varchar(200) DEFAULT '' COMMENT '知识点',
  `source` varchar(100) DEFAULT '' COMMENT '来源 如: 2011年真题',
  `source_year` int DEFAULT NULL COMMENT '来源年份',
  `source_question_no` int DEFAULT NULL COMMENT '来源题号',
  `tags` varchar(255) DEFAULT '' COMMENT '标签',
  `images` text COMMENT '图片路径，多个用逗号分隔',
  `total_count` int DEFAULT '0' COMMENT '作答总次数',
  `correct_count` int DEFAULT '0' COMMENT '答对次数',
  `error_count` int DEFAULT '0' COMMENT '答错次数',
  `avg_score` decimal(5,2) DEFAULT '0.00' COMMENT '平均得分率',
  `status` int DEFAULT '1' COMMENT '状态 1-启用 0-禁用',
  `create_user` int DEFAULT '1' COMMENT '创建用户ID',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) DEFAULT b'0' COMMENT '删除标记',
  PRIMARY KEY (`id`),
  KEY `idx_subject_id` (`subject_id`),
  KEY `idx_question_type` (`question_type`),
  KEY `idx_difficulty` (`difficulty`),
  KEY `idx_status` (`status`),
  KEY `idx_source_year` (`source_year`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='题目表';

-- ============================================
-- 4. 试卷表 t_exam_paper
-- ============================================
DROP TABLE IF EXISTS `t_exam_paper`;
CREATE TABLE `t_exam_paper` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '试卷ID',
  `name` varchar(200) NOT NULL COMMENT '试卷名称',
  `subject_id` int NOT NULL COMMENT '学科ID',
  `paper_type` varchar(20) NOT NULL DEFAULT 'year_paper' COMMENT '试卷类型 year_paper-年真题卷 chapter_paper-章节卷 mock_paper-模拟卷',
  `source_year` int DEFAULT NULL COMMENT '真题年份',
  `total_score` int DEFAULT '100' COMMENT '总分',
  `pass_score` int DEFAULT '60' COMMENT '及格分数',
  `duration` int DEFAULT '120' COMMENT '考试时长(分钟)',
  `question_count` int DEFAULT '0' COMMENT '题目数量',
  `description` text COMMENT '试卷说明',
  `suggestion` text COMMENT '复习建议',
  `difficulty` int DEFAULT '2' COMMENT '难度系数 1-简单 2-中等 3-困难',
  `total_count` int DEFAULT '0' COMMENT '考试总人次',
  `avg_score` decimal(5,2) DEFAULT '0.00' COMMENT '平均分',
  `max_score` decimal(5,2) DEFAULT '0.00' COMMENT '最高分',
  `min_score` decimal(5,2) DEFAULT '0.00' COMMENT '最低分',
  `status` int DEFAULT '1' COMMENT '状态 1-启用 0-禁用',
  `create_user` int DEFAULT '1' COMMENT '创建用户ID',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) DEFAULT b'0' COMMENT '删除标记',
  PRIMARY KEY (`id`),
  KEY `idx_subject_id` (`subject_id`),
  KEY `idx_paper_type` (`paper_type`),
  KEY `idx_source_year` (`source_year`),
  KEY `idx_status` (`status`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='试卷表';

-- ============================================
-- 5. 试卷题目关联表 t_exam_paper_question
-- ============================================
DROP TABLE IF EXISTS `t_exam_paper_question`;
CREATE TABLE `t_exam_paper_question` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `exam_paper_id` int NOT NULL COMMENT '试卷ID',
  `question_id` int NOT NULL COMMENT '题目ID',
  `question_no` int NOT NULL COMMENT '题号',
  `score` int NOT NULL DEFAULT '2' COMMENT '分值',
  `sort` int DEFAULT '0' COMMENT '排序',
  PRIMARY KEY (`id`),
  KEY `idx_exam_paper_id` (`exam_paper_id`),
  KEY `idx_question_id` (`question_id`),
  UNIQUE KEY `uk_paper_question` (`exam_paper_id`, `question_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='试卷题目关联表';

-- ============================================
-- 6. 学生答题记录表 t_student_answer
-- ============================================
DROP TABLE IF EXISTS `t_student_answer`;
CREATE TABLE `t_student_answer` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `exam_paper_id` int NOT NULL COMMENT '试卷ID',
  `question_id` int NOT NULL COMMENT '题目ID',
  `user_id` int NOT NULL COMMENT '用户ID',
  `answer` varchar(500) DEFAULT '' COMMENT '学生答案',
  `correct_answer` varchar(10) NOT NULL COMMENT '正确答案',
  `is_correct` bit(1) DEFAULT b'0' COMMENT '是否正确',
  `score` int DEFAULT '0' COMMENT '得分',
  `answer_time` int DEFAULT '0' COMMENT '答题时长(秒)',
  `ip_address` varchar(50) DEFAULT '' COMMENT 'IP地址',
  `client_type` varchar(20) DEFAULT 'web' COMMENT '客户端类型 web/app/wechat',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '作答时间',
  PRIMARY KEY (`id`),
  KEY `idx_exam_paper_id` (`exam_paper_id`),
  KEY `idx_question_id` (`question_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_is_correct` (`is_correct`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='学生答题记录表';

-- ============================================
-- 7. 学生考试记录表 t_exam_record
-- ============================================
DROP TABLE IF EXISTS `t_exam_record`;
CREATE TABLE `t_exam_record` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `exam_paper_id` int NOT NULL COMMENT '试卷ID',
  `user_id` int NOT NULL COMMENT '用户ID',
  `score` int DEFAULT '0' COMMENT '得分',
  `total_score` int DEFAULT '100' COMMENT '总分',
  `correct_count` int DEFAULT '0' COMMENT '答对题数',
  `total_count` int DEFAULT '0' COMMENT '总题数',
  `duration` int DEFAULT '0' COMMENT '考试时长(分钟)',
  `score_rate` decimal(5,2) DEFAULT '0.00' COMMENT '得分率',
  `status` varchar(20) DEFAULT 'completed' COMMENT '状态 completed-已完成 submitted-已提交 grading-批改中',
  `start_time` datetime DEFAULT NULL COMMENT '开始时间',
  `submit_time` datetime DEFAULT NULL COMMENT '提交时间',
  `ip_address` varchar(50) DEFAULT '' COMMENT 'IP地址',
  `client_type` varchar(20) DEFAULT 'web' COMMENT '客户端类型',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_exam_paper_id` (`exam_paper_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_status` (`status`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='学生考试记录表';

-- ============================================
-- 插入基础数据
-- ============================================

-- 插入学科数据
INSERT INTO `t_subject` (`id`, `name`, `code`, `description`, `sort`, `enabled`) VALUES
(1, '数据结构', 'DS', '计算机专业基础课程，主要包括线性表、栈、队列、树、图等数据结构', 1, 1),
(2, '计算机组成原理', 'CO', '计算机系统组成和工作原理，包括数据表示、运算器、存储器、指令系统等', 2, 1),
(3, '操作系统', 'OS', '操作系统原理，包括进程管理、存储管理、文件管理、设备管理等', 3, 1),
(4, '计算机网络', 'CN', '计算机网络原理，包括网络体系结构、物理层、数据链路层、网络层等', 4, 1);

-- 插入测试用户
INSERT INTO `t_user` (`id`, `username`, `password`, `real_name`, `phone`, `email`, `status`, `role`) VALUES
(1, 'admin', '123456', '管理员', '13800138000', 'admin@example.com', 1, 'admin'),
(2, 'teacher', '123456', '教师用户', '13800138001', 'teacher@example.com', 1, 'teacher');

-- ============================================
-- 初始化完成
-- ============================================
