-- ============================================
-- 408刷题系统 V2.1 - 学习系统优化脚本
-- ============================================
-- 新增功能：
-- 1. 用户错题统计表
-- 2. 学习计划表
-- 3. 学习笔记表
-- 4. 学习任务表
--
-- 使用方法：
-- mysql -u root -p123456 xzs < optimize_study_system.sql
-- ============================================

USE xzs;

-- ----------------------------
-- 1. 用户错题统计表
-- ----------------------------
DROP TABLE IF EXISTS `t_question_wrong_stat`;
CREATE TABLE `t_question_wrong_stat` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `question_id` INT NOT NULL COMMENT '题目ID',
  `user_id` INT NOT NULL COMMENT '用户ID',
  `wrong_count` INT DEFAULT 1 COMMENT '错误次数',
  `last_wrong_time` DATETIME NULL COMMENT '最后错误时间',
  `wrong_answer` TEXT NULL COMMENT '用户错误答案记录 (JSON格式)',
  `is_reviewed` BIT(1) DEFAULT b'0' COMMENT '是否已复习',
  `review_count` INT DEFAULT 0 COMMENT '复习次数',
  `mastery_level` INT DEFAULT 0 COMMENT '掌握程度 0-100',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_question_user`(`question_id`, `user_id`),
  INDEX `idx_user_id`(`user_id`),
  INDEX `idx_question_id`(`question_id`),
  INDEX `idx_is_reviewed`(`is_reviewed`),
  INDEX `idx_wrong_count`(`wrong_count`),
  CONSTRAINT `fk_wrong_stat_question` FOREIGN KEY (`question_id`) REFERENCES `t_question` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_wrong_stat_user` FOREIGN KEY (`user_id`) REFERENCES `t_user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户错题统计表';

-- ----------------------------
-- 2. 用户学习计划表
-- ----------------------------
DROP TABLE IF EXISTS `t_user_study_plan`;
CREATE TABLE `t_user_study_plan` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `user_id` INT NOT NULL COMMENT '用户ID',
  `plan_name` VARCHAR(255) NOT NULL COMMENT '计划名称',
  `plan_type` VARCHAR(50) NOT NULL COMMENT '计划类型: daily/weekly/monthly/exam',
  `start_time` DATETIME NULL COMMENT '计划开始时间',
  `end_time` DATETIME NULL COMMENT '计划结束时间',
  `target_score` DECIMAL(5,2) NULL COMMENT '目标分数',
  `status` VARCHAR(20) DEFAULT 'active' COMMENT '状态: active/completed/abandoned',
  `config` JSON NULL COMMENT '计划配置 (JSON)',
  `progress` DECIMAL(5,2) DEFAULT 0.00 COMMENT '完成进度 0.00-100.00',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_user_id`(`user_id`),
  INDEX `idx_status`(`status`),
  CONSTRAINT `fk_study_plan_user` FOREIGN KEY (`user_id`) REFERENCES `t_user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户学习计划表';

-- ----------------------------
-- 3. 用户学习笔记表
-- ----------------------------
DROP TABLE IF EXISTS `t_user_note`;
CREATE TABLE `t_user_note` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `user_id` INT NOT NULL COMMENT '用户ID',
  `target_type` VARCHAR(30) NOT NULL COMMENT '关联类型: question/knowledge/paper',
  `target_id` INT NOT NULL COMMENT '关联ID',
  `note_title` VARCHAR(255) NULL COMMENT '笔记标题',
  `note_content` TEXT NOT NULL COMMENT '笔记内容',
  `is_public` BIT(1) DEFAULT b'0' COMMENT '是否公开',
  `tags` VARCHAR(500) NULL COMMENT '标签 (逗号分隔)',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` BIT(1) DEFAULT b'0',
  PRIMARY KEY (`id`),
  INDEX `idx_user_id`(`user_id`),
  INDEX `idx_target`(`target_type`, `target_id`),
  INDEX `idx_is_public`(`is_public`),
  INDEX `idx_create_time`(`create_time`),
  CONSTRAINT `fk_user_note_user` FOREIGN KEY (`user_id`) REFERENCES `t_user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户学习笔记表';

-- ----------------------------
-- 4. 学习任务表
-- ----------------------------
DROP TABLE IF EXISTS `t_study_task`;
CREATE TABLE `t_study_task` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `user_id` INT NOT NULL COMMENT '用户ID',
  `plan_id` INT NULL COMMENT '所属计划ID',
  `task_name` VARCHAR(255) NOT NULL COMMENT '任务名称',
  `task_type` VARCHAR(30) NOT NULL COMMENT '任务类型: question/knowledge/review/practice',
  `target_id` INT NULL COMMENT '目标ID',
  `target_count` INT DEFAULT 1 COMMENT '目标数量',
  `completed_count` INT DEFAULT 0 COMMENT '完成数量',
  `deadline` DATETIME NULL COMMENT '截止时间',
  `status` VARCHAR(20) DEFAULT 'pending' COMMENT '状态: pending/in_progress/completed/expired',
  `priority` INT DEFAULT 3 COMMENT '优先级 1-5',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `complete_time` DATETIME NULL,
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_user_id`(`user_id`),
  INDEX `idx_plan_id`(`plan_id`),
  INDEX `idx_status`(`status`),
  INDEX `idx_deadline`(`deadline`),
  CONSTRAINT `fk_study_task_user` FOREIGN KEY (`user_id`) REFERENCES `t_user` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_study_task_plan` FOREIGN KEY (`plan_id`) REFERENCES `t_user_study_plan` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='学习任务表';

-- ============================================
-- 输出完成信息
-- ============================================
SELECT '========================================' AS '';
SELECT '学习系统优化脚本执行完成！' AS result;
SELECT '' AS '';
SELECT COUNT(*) AS 新增表数量 FROM information_schema.tables WHERE table_schema = 'xzs' AND table_name IN ('t_question_wrong_stat', 't_user_study_plan', 't_user_note', 't_study_task');
