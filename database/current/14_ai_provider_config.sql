-- ============================================================
-- 14_ai_provider_config.sql
-- Admin-managed AI provider credentials and usage indexes.
-- API keys are stored encrypted by the backend and are never returned
-- to the admin frontend in plaintext.
-- ============================================================

CREATE TABLE IF NOT EXISTS `ai_provider_config` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `provider_code` VARCHAR(50) NOT NULL COMMENT 'deepseek/openai/zhipu/custom',
  `provider_name` VARCHAR(100) NOT NULL,
  `api_base_url` VARCHAR(500) DEFAULT NULL,
  `chat_model` VARCHAR(100) DEFAULT NULL,
  `embedding_model` VARCHAR(100) DEFAULT NULL,
  `api_key_cipher` LONGTEXT DEFAULT NULL,
  `api_key_mask` VARCHAR(80) DEFAULT NULL,
  `enabled` BIT(1) NOT NULL DEFAULT b'0',
  `priority` INT NOT NULL DEFAULT 100,
  `last_test_success` BIT(1) DEFAULT NULL,
  `last_test_message` VARCHAR(1000) DEFAULT NULL,
  `last_test_time` DATETIME DEFAULT NULL,
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_ai_provider_code` (`provider_code`),
  KEY `idx_ai_provider_enabled` (`enabled`, `priority`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='AI供应商密钥配置';

INSERT INTO `ai_provider_config`
  (`provider_code`, `provider_name`, `api_base_url`, `chat_model`, `embedding_model`, `enabled`, `priority`)
SELECT 'deepseek', 'DeepSeek', 'https://api.deepseek.com', 'deepseek-v4-pro', NULL, b'0', 10
WHERE NOT EXISTS (SELECT 1 FROM `ai_provider_config` WHERE `provider_code` = 'deepseek');

INSERT INTO `ai_provider_config`
  (`provider_code`, `provider_name`, `api_base_url`, `chat_model`, `embedding_model`, `enabled`, `priority`)
SELECT 'zhipu', '智谱 GLM', 'https://open.bigmodel.cn/api/paas/v4', 'glm-4.5-air', 'embedding-2', b'0', 20
WHERE NOT EXISTS (SELECT 1 FROM `ai_provider_config` WHERE `provider_code` = 'zhipu');

INSERT INTO `ai_provider_config`
  (`provider_code`, `provider_name`, `api_base_url`, `chat_model`, `embedding_model`, `enabled`, `priority`)
SELECT 'openai', 'OpenAI', 'https://api.openai.com/v1', 'gpt-4.1-mini', 'text-embedding-3-small', b'0', 30
WHERE NOT EXISTS (SELECT 1 FROM `ai_provider_config` WHERE `provider_code` = 'openai');

SELECT 'AI provider config schema ready' AS status;
