-- ============================================
-- 02_extend_fields.sql
-- 408真题扩展字段（在基础表结构之上添加）
-- 这些字段不被原始 xzs 代码使用，用于 408 真题管理
-- ============================================

-- ============================================
-- t_question 扩展字段
-- ============================================
ALTER TABLE `t_question`
  ADD COLUMN `title` text DEFAULT NULL COMMENT '题目内容（HTML）' AFTER `subject_id`,
  ADD COLUMN `options` text DEFAULT NULL COMMENT '选项 JSON' AFTER `title`,
  ADD COLUMN `correct_answer` text DEFAULT NULL COMMENT '正确答案' AFTER `options`,
  ADD COLUMN `analysis` text DEFAULT NULL COMMENT '解析（HTML）' AFTER `correct_answer`,
  ADD COLUMN `difficulty` int DEFAULT 2 COMMENT '难度 1=简单 2=中等 3=困难' AFTER `analysis`,
  ADD COLUMN `knowledge_point` varchar(200) DEFAULT NULL COMMENT '知识点' AFTER `difficulty`,
  ADD COLUMN `source` varchar(100) DEFAULT NULL COMMENT '来源 如 2024年408真题' AFTER `knowledge_point`,
  ADD COLUMN `source_year` int DEFAULT NULL COMMENT '来源年份' AFTER `source`,
  ADD COLUMN `source_question_no` int DEFAULT NULL COMMENT '原始题号 1-47' AFTER `source_year`,
  ADD COLUMN `tags` text DEFAULT NULL COMMENT '知识标签 逗号分隔' AFTER `source_question_no`,
  ADD COLUMN `images` text DEFAULT NULL COMMENT '图片路径' AFTER `tags`,
  ADD COLUMN `title_text` text DEFAULT NULL COMMENT '题目纯文本' AFTER `images`,
  ADD COLUMN `analysis_text` text DEFAULT NULL COMMENT '解析纯文本' AFTER `title_text`,
  ADD COLUMN `content_format` varchar(20) DEFAULT 'html' COMMENT '内容格式 html/markdown/plain' AFTER `analysis_text`,
  ADD COLUMN `has_image` bit(1) DEFAULT b'0' COMMENT '是否包含图片' AFTER `content_format`,
  ADD COLUMN `has_code` bit(1) DEFAULT b'0' COMMENT '是否包含代码' AFTER `has_image`;

-- ============================================
-- t_exam_paper 扩展字段
-- ============================================
ALTER TABLE `t_exam_paper`
  ADD COLUMN `source_year` int DEFAULT NULL COMMENT '来源年份' AFTER `task_exam_id`,
  ADD COLUMN `description` text DEFAULT NULL COMMENT '试卷描述' AFTER `source_year`;

-- ============================================
-- t_essay_question 综合应用题原始表（爬虫数据）
-- 不被原始代码直接使用，用于数据导入
-- ============================================
CREATE TABLE IF NOT EXISTS `t_essay_question` (
  `id` int NOT NULL AUTO_INCREMENT,
  `subject_id` int NOT NULL,
  `year` int NOT NULL,
  `question_no` int NOT NULL COMMENT '题号 41-47',
  `title` text NOT NULL,
  `sub_questions` text COMMENT '子问题 JSON',
  `total_score` int DEFAULT 10,
  `answer` text,
  `analysis` text,
  `images` text,
  PRIMARY KEY (`id`),
  KEY `idx_subject_year` (`subject_id`, `year`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
