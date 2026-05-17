CREATE TABLE IF NOT EXISTS `t_question_wrong_analysis` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `question_id` INT(11) NOT NULL COMMENT '题目ID',
  `user_id` INT(11) NOT NULL COMMENT '用户ID',
  `analysis_content` TEXT NOT NULL COMMENT '分析内容',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_question_user` (`question_id`, `user_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_question_id` (`question_id`),
  CONSTRAINT `fk_question_wrong_analysis_question` FOREIGN KEY (`question_id`) REFERENCES `t_question` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_question_wrong_analysis_user` FOREIGN KEY (`user_id`) REFERENCES `t_user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='错题分析表';
