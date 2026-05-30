-- source.sql 后置统一修复补丁
-- 原则：source.sql 作为主快照，source 之后缺失/错位的结构和数据都递补到这里。

-- 1. 增量：补充 t_ai_usage_log 缺失的用户/来源/token 统计字段
-- 原因：Mapper XML 引用了这些列但 source.sql 表结构中不存在，导致 AI 配置页 500

SET @dbname = DATABASE();
SET @tablename = 't_ai_usage_log';

-- user_id
SET @colname = 'user_id';
SET @preparedStatement = (SELECT IF(
  (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = @dbname AND TABLE_NAME = @tablename AND COLUMN_NAME = @colname) > 0,
  'SELECT 1',
  CONCAT('ALTER TABLE ', @tablename, ' ADD COLUMN ', @colname, ' INT DEFAULT NULL AFTER id')
));
PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;

-- key_source
SET @colname = 'key_source';
SET @preparedStatement = (SELECT IF(
  (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = @dbname AND TABLE_NAME = @tablename AND COLUMN_NAME = @colname) > 0,
  'SELECT 1',
  CONCAT('ALTER TABLE ', @tablename, ' ADD COLUMN ', @colname, ' VARCHAR(20) DEFAULT ''public'' AFTER user_id')
));
PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;

-- cache_hit_tokens
SET @colname = 'cache_hit_tokens';
SET @preparedStatement = (SELECT IF(
  (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = @dbname AND TABLE_NAME = @tablename AND COLUMN_NAME = @colname) > 0,
  'SELECT 1',
  CONCAT('ALTER TABLE ', @tablename, ' ADD COLUMN ', @colname, ' INT DEFAULT 0 AFTER tokens_used')
));
PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;

-- input_tokens
SET @colname = 'input_tokens';
SET @preparedStatement = (SELECT IF(
  (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = @dbname AND TABLE_NAME = @tablename AND COLUMN_NAME = @colname) > 0,
  'SELECT 1',
  CONCAT('ALTER TABLE ', @tablename, ' ADD COLUMN ', @colname, ' INT DEFAULT 0 AFTER cache_hit_tokens')
));
PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;

-- output_tokens
SET @colname = 'output_tokens';
SET @preparedStatement = (SELECT IF(
  (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = @dbname AND TABLE_NAME = @tablename AND COLUMN_NAME = @colname) > 0,
  'SELECT 1',
  CONCAT('ALTER TABLE ', @tablename, ' ADD COLUMN ', @colname, ' INT DEFAULT 0 AFTER input_tokens')
));
PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;

-- 2. 补表：ai_user_key
-- 原因：AiUserKeyMapper.xml / AiUserKey.java 引用了用户私有 AI Key 表，但 source.sql 未包含该表。

CREATE TABLE IF NOT EXISTS `ai_user_key` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `provider_code` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'deepseek/openai/zhipu/custom',
  `provider_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `api_base_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `chat_model` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `embedding_model` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `api_key_cipher` longtext COLLATE utf8mb4_unicode_ci,
  `api_key_mask` varchar(80) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `enabled` tinyint(1) NOT NULL DEFAULT 0,
  `priority` int NOT NULL DEFAULT '100',
  `last_test_success` tinyint(1) DEFAULT NULL,
  `last_test_message` varchar(1000) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `last_test_time` datetime DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_ai_user_key_user` (`user_id`,`enabled`,`priority`),
  KEY `idx_ai_user_key_provider` (`provider_code`,`enabled`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户私有AI供应商密钥配置';

-- 3. 补列：vision_model（视觉模型）
-- ai_provider_config
SET @colname = 'vision_model';
SET @preparedStatement = (SELECT IF(
  (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = @dbname AND TABLE_NAME = 'ai_provider_config' AND COLUMN_NAME = @colname) > 0,
  'SELECT 1',
  CONCAT('ALTER TABLE ai_provider_config ADD COLUMN ', @colname, ' VARCHAR(100) DEFAULT NULL AFTER embedding_model')
));
PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;

-- ai_user_key
SET @preparedStatement = (SELECT IF(
  (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = @dbname AND TABLE_NAME = 'ai_user_key' AND COLUMN_NAME = @colname) > 0,
  'SELECT 1',
  CONCAT('ALTER TABLE ai_user_key ADD COLUMN ', @colname, ' VARCHAR(100) DEFAULT NULL AFTER embedding_model')
));
PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;

-- 4. 清理孤儿试卷：papers 22-24 引用了已被 migration 17 删除的旧 question ID (521-530)
-- 导致 ExamPaperServiceImpl.examPaperToVM Optional.get() 抛 NoSuchElementException

DELETE FROM t_text_content WHERE id IN (789, 791, 792);
DELETE FROM t_exam_paper WHERE id IN (22, 23, 24);
