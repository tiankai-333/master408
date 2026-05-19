-- ============================================
-- 01_init_structure.sql
-- 从代码反推的表结构（Mapper XML + Domain Java）
-- 适用于 master408 智能考试系统
-- ============================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `t_exam_paper_question_customer_answer`;
DROP TABLE IF EXISTS `t_exam_paper_answer`;
DROP TABLE IF EXISTS `t_task_exam_customer_answer`;
DROP TABLE IF EXISTS `t_user_event_log`;
DROP TABLE IF EXISTS `t_user_token`;
DROP TABLE IF EXISTS `t_message_user`;
DROP TABLE IF EXISTS `t_message`;
DROP TABLE IF EXISTS `t_exam_paper`;
DROP TABLE IF EXISTS `t_question`;
DROP TABLE IF EXISTS `t_text_content`;
DROP TABLE IF EXISTS `t_subject`;
DROP TABLE IF EXISTS `t_task_exam`;
DROP TABLE IF EXISTS `t_user`;
DROP TABLE IF EXISTS `question_knowledge_point`;
DROP TABLE IF EXISTS `knowledge_point`;
DROP TABLE IF EXISTS `t_ai_usage_log`;
DROP TABLE IF EXISTS `t_ai_prompt_template`;
DROP TABLE IF EXISTS `t_ai_knowledge_base`;
DROP TABLE IF EXISTS `t_ai_adjustment_log`;

-- ============================================
-- 1. t_user 用户表
-- Mapper: UserMapper.xml | Domain: User.java
-- ============================================
CREATE TABLE `t_user` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_uuid` varchar(36) DEFAULT NULL,
  `user_name` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `real_name` varchar(255) DEFAULT NULL,
  `age` int DEFAULT NULL,
  `sex` int DEFAULT NULL,
  `birth_day` datetime DEFAULT NULL,
  `user_level` int DEFAULT 1,
  `phone` varchar(255) DEFAULT NULL,
  `role` int NOT NULL DEFAULT 1,
  `status` int NOT NULL DEFAULT 1,
  `image_path` varchar(255) DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `modify_time` datetime DEFAULT NULL,
  `last_active_time` datetime DEFAULT NULL,
  `deleted` bit(1) DEFAULT b'0',
  `wx_open_id` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_name` (`user_name`),
  KEY `idx_role` (`role`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 2. t_subject 科目表
-- Mapper: SubjectMapper.xml | Domain: Subject.java
-- ============================================
CREATE TABLE `t_subject` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `level` int DEFAULT NULL,
  `level_name` varchar(255) DEFAULT NULL,
  `item_order` int DEFAULT NULL,
  `deleted` bit(1) DEFAULT b'0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 3. t_text_content 文本内容表
-- Mapper: TextContentMapper.xml | Domain: TextContent.java
-- 注意: Mapper 标注 VARCHAR 但实际存储 JSON 长文本，用 TEXT
-- ============================================
CREATE TABLE `t_text_content` (
  `id` int NOT NULL AUTO_INCREMENT,
  `content` text,
  `create_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 4. t_question 题目表
-- Mapper: QuestionMapper.xml | Domain: Question.java
-- ============================================
CREATE TABLE `t_question` (
  `id` int NOT NULL AUTO_INCREMENT,
  `question_type` int NOT NULL DEFAULT 1,
  `subject_id` int NOT NULL,
  `score` int DEFAULT NULL,
  `grade_level` int DEFAULT NULL,
  `difficult` int DEFAULT NULL,
  `correct` varchar(255) DEFAULT NULL,
  `info_text_content_id` int DEFAULT NULL,
  `create_user` int DEFAULT NULL,
  `status` int NOT NULL DEFAULT 1,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `deleted` bit(1) DEFAULT b'0',
  PRIMARY KEY (`id`),
  KEY `idx_subject_id` (`subject_id`),
  KEY `idx_question_type` (`question_type`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 5. t_exam_paper 试卷表
-- Mapper: ExamPaperMapper.xml | Domain: ExamPaper.java
-- ============================================
CREATE TABLE `t_exam_paper` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `subject_id` int DEFAULT NULL,
  `paper_type` int NOT NULL DEFAULT 1,
  `grade_level` int DEFAULT NULL,
  `score` int DEFAULT NULL,
  `question_count` int DEFAULT NULL,
  `suggest_time` int DEFAULT NULL,
  `limit_start_time` datetime DEFAULT NULL,
  `limit_end_time` datetime DEFAULT NULL,
  `frame_text_content_id` int DEFAULT NULL,
  `create_user` int DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `deleted` bit(1) DEFAULT b'0',
  `task_exam_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_subject_id` (`subject_id`),
  KEY `idx_paper_type` (`paper_type`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 6. t_task_exam 任务考试表
-- Mapper: TaskExamMapper.xml | Domain: TaskExam.java
-- ============================================
CREATE TABLE `t_task_exam` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) DEFAULT NULL,
  `grade_level` int DEFAULT NULL,
  `frame_text_content_id` int DEFAULT NULL,
  `create_user` int DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `deleted` bit(1) DEFAULT b'0',
  `create_user_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 7. t_exam_paper_answer 试卷答题记录表
-- Mapper: ExamPaperAnswerMapper.xml | Domain: ExamPaperAnswer.java
-- ============================================
CREATE TABLE `t_exam_paper_answer` (
  `id` int NOT NULL AUTO_INCREMENT,
  `exam_paper_id` int DEFAULT NULL,
  `paper_name` varchar(255) DEFAULT NULL,
  `paper_type` int DEFAULT NULL,
  `subject_id` int DEFAULT NULL,
  `system_score` int DEFAULT NULL,
  `user_score` int DEFAULT NULL,
  `paper_score` int DEFAULT NULL,
  `question_correct` int DEFAULT NULL,
  `question_count` int DEFAULT NULL,
  `do_time` int DEFAULT NULL,
  `status` int DEFAULT NULL,
  `create_user` int DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `task_exam_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_exam_paper_id` (`exam_paper_id`),
  KEY `idx_create_user` (`create_user`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 8. t_exam_paper_question_customer_answer 答题详情表
-- Mapper: ExamPaperQuestionCustomerAnswerMapper.xml
-- Domain: ExamPaperQuestionCustomerAnswer.java
-- ============================================
CREATE TABLE `t_exam_paper_question_customer_answer` (
  `id` int NOT NULL AUTO_INCREMENT,
  `question_id` int DEFAULT NULL,
  `exam_paper_id` int DEFAULT NULL,
  `exam_paper_answer_id` int DEFAULT NULL,
  `question_type` int DEFAULT NULL,
  `subject_id` int DEFAULT NULL,
  `customer_score` int DEFAULT NULL,
  `question_score` int DEFAULT NULL,
  `question_text_content_id` int DEFAULT NULL,
  `answer` varchar(255) DEFAULT NULL,
  `text_content_id` int DEFAULT NULL,
  `do_right` bit(1) DEFAULT NULL,
  `create_user` int DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `item_order` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_exam_paper_answer_id` (`exam_paper_answer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 9. t_task_exam_customer_answer 任务考试答题表
-- Mapper: TaskExamCustomerAnswerMapper.xml
-- Domain: TaskExamCustomerAnswer.java
-- ============================================
CREATE TABLE `t_task_exam_customer_answer` (
  `id` int NOT NULL AUTO_INCREMENT,
  `task_exam_id` int DEFAULT NULL,
  `create_user` int DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `text_content_id` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 10. t_message 消息表
-- Mapper: MessageMapper.xml | Domain: Message.java
-- ============================================
CREATE TABLE `t_message` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) DEFAULT NULL,
  `content` varchar(500) DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `send_user_id` int DEFAULT NULL,
  `send_user_name` varchar(255) DEFAULT NULL,
  `send_real_name` varchar(255) DEFAULT NULL,
  `receive_user_count` int DEFAULT NULL,
  `read_count` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 11. t_message_user 消息用户关联表
-- Mapper: MessageUserMapper.xml | Domain: MessageUser.java
-- ============================================
CREATE TABLE `t_message_user` (
  `id` int NOT NULL AUTO_INCREMENT,
  `message_id` int DEFAULT NULL,
  `receive_user_id` int DEFAULT NULL,
  `receive_user_name` varchar(255) DEFAULT NULL,
  `receive_real_name` varchar(255) DEFAULT NULL,
  `readed` bit(1) DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `read_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_message_id` (`message_id`),
  KEY `idx_receive_user_id` (`receive_user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 12. t_user_event_log 用户事件日志表
-- Mapper: UserEventLogMapper.xml | Domain: UserEventLog.java
-- ============================================
CREATE TABLE `t_user_event_log` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `user_name` varchar(255) DEFAULT NULL,
  `real_name` varchar(255) DEFAULT NULL,
  `content` text,
  `create_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 13. t_user_token 用户Token表
-- Mapper: UserTokenMapper.xml | Domain: UserToken.java
-- ============================================
CREATE TABLE `t_user_token` (
  `id` int NOT NULL AUTO_INCREMENT,
  `token` varchar(36) DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `wx_open_id` varchar(255) DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `end_time` datetime DEFAULT NULL,
  `user_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_token` (`token`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 14. knowledge_point 知识点表
-- Mapper: KnowledgePointMapper.xml | Domain: KnowledgePoint.java
-- 注意: 表名无 t_ 前缀，与 Mapper 一致
-- ============================================
CREATE TABLE `knowledge_point` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `subject_id` int NOT NULL,
  `parent_id` int DEFAULT NULL,
  `description` varchar(500) DEFAULT NULL,
  `level` int DEFAULT NULL,
  `sort_order` int DEFAULT 0,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `deleted` bit(1) DEFAULT b'0',
  PRIMARY KEY (`id`),
  KEY `idx_subject_id` (`subject_id`),
  KEY `idx_parent_id` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 15. question_knowledge_point 题目-知识点关联表
-- Mapper: QuestionKnowledgePointMapper.xml
-- Domain: QuestionKnowledgePoint.java
-- 注意: 表名无 t_ 前缀，与 Mapper 一致
-- ============================================
CREATE TABLE `question_knowledge_point` (
  `id` int NOT NULL AUTO_INCREMENT,
  `question_id` int NOT NULL,
  `knowledge_point_id` int NOT NULL,
  `relevance` decimal(3,2) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_question_id` (`question_id`),
  KEY `idx_knowledge_point_id` (`knowledge_point_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 16. t_ai_usage_log AI使用日志表
-- Mapper: AiUsageLogMapper.xml | Domain: AiUsageLog.java
-- ============================================
CREATE TABLE `t_ai_usage_log` (
  `id` int NOT NULL AUTO_INCREMENT,
  `template_id` int DEFAULT NULL,
  `style` varchar(50) NOT NULL,
  `ai_type` varchar(20) DEFAULT '',
  `model` varchar(50) DEFAULT '',
  `question` text NOT NULL,
  `knowledge_points` text,
  `knowledge_base_ids` varchar(255) DEFAULT '',
  `prompt` text,
  `response` text,
  `response_length` int DEFAULT 0,
  `tokens_used` int DEFAULT 0,
  `cost` decimal(10,4) DEFAULT 0.0000,
  `duration_ms` int DEFAULT 0,
  `success` tinyint(1) DEFAULT 1,
  `error_message` text,
  `user_rating` int DEFAULT 0,
  `user_feedback` text,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_template_id` (`template_id`),
  KEY `idx_style` (`style`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 17. t_ai_knowledge_base AI知识库表
-- Mapper: AiKnowledgeBaseMapper.xml | Domain: AiKnowledgeBase.java
-- ============================================
CREATE TABLE `t_ai_knowledge_base` (
  `id` int NOT NULL AUTO_INCREMENT,
  `category` varchar(50) NOT NULL,
  `domain` varchar(50) NOT NULL,
  `sub_domain` varchar(50) DEFAULT '',
  `title` varchar(200) NOT NULL,
  `keywords` varchar(255) DEFAULT '',
  `content` text NOT NULL,
  `source_type` varchar(50) DEFAULT '',
  `source_name` varchar(200) DEFAULT '',
  `source_author` varchar(100) DEFAULT '',
  `core_concepts` text,
  `application_scenarios` text,
  `examples` text,
  `enabled` tinyint(1) DEFAULT 1,
  `priority` int DEFAULT 0,
  `usage_count` int DEFAULT 0,
  `create_user` int DEFAULT 1,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) DEFAULT b'0',
  PRIMARY KEY (`id`),
  KEY `idx_category` (`category`),
  KEY `idx_domain` (`domain`),
  KEY `idx_enabled` (`enabled`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 18. t_ai_prompt_template AI提示词模板表
-- Mapper: AiPromptTemplateMapper.xml | Domain: AiPromptTemplate.java
-- ============================================
CREATE TABLE `t_ai_prompt_template` (
  `id` int NOT NULL AUTO_INCREMENT,
  `style` varchar(50) NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` varchar(500) DEFAULT NULL,
  `icon` varchar(255) DEFAULT NULL,
  `system_prompt` text,
  `user_prompt_template` text,
  `knowledge_base_ids` varchar(500) DEFAULT NULL,
  `reference_materials` text,
  `variables` varchar(500) DEFAULT NULL,
  `output_format` varchar(200) DEFAULT NULL,
  `temperature` decimal(3,2) DEFAULT 0.70,
  `max_tokens` int DEFAULT 2000,
  `enabled` tinyint(1) DEFAULT 1,
  `is_default` tinyint(1) DEFAULT 0,
  `usage_count` int DEFAULT 0,
  `rating_sum` int DEFAULT 0,
  `rating_count` int DEFAULT 0,
  `create_user` int DEFAULT 1,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) DEFAULT b'0',
  PRIMARY KEY (`id`),
  KEY `idx_style` (`style`),
  KEY `idx_enabled` (`enabled`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 19. t_ai_adjustment_log AI调整日志表
-- Mapper: AiAdjustmentLogMapper.xml | Domain: AiAdjustmentLog.java
-- ============================================
CREATE TABLE `t_ai_adjustment_log` (
  `id` int NOT NULL AUTO_INCREMENT,
  `template_id` int DEFAULT NULL,
  `style` varchar(50) DEFAULT NULL,
  `adjustment_type` varchar(50) DEFAULT NULL,
  `before_content` text,
  `after_content` text,
  `adjustment_reason` text,
  `adjustment_details` text,
  `test_result` text,
  `test_question` text,
  `test_feedback` text,
  `rating` int DEFAULT NULL,
  `status` int DEFAULT NULL,
  `approver_id` int DEFAULT NULL,
  `approve_time` datetime DEFAULT NULL,
  `approve_comment` text,
  `create_user` int DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `ip_address` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_template_id` (`template_id`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;
