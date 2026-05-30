-- ============================================================
-- 06_ai_knowledge_rag.sql
-- AI 知识库、RAG、学生档案与反馈闭环增强
-- 基于当前实际使用的 knowledge_point / question_knowledge_point /
-- t_ai_knowledge_base 表，不启用旧版 t_knowledge_point 分叉体系。
-- ============================================================

-- ------------------------------------------------------------
-- 1. AI 知识库向量检索字段
-- ------------------------------------------------------------
SET @col_exists = 0;
SELECT COUNT(*) INTO @col_exists
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 't_ai_knowledge_base'
  AND COLUMN_NAME = 'embedding';
SET @sql = IF(@col_exists = 0,
  'ALTER TABLE t_ai_knowledge_base ADD COLUMN embedding LONGTEXT NULL COMMENT ''RAG向量(JSON float[] 格式)'' AFTER content',
  'SELECT ''t_ai_knowledge_base.embedding already exists'' AS status');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @col_exists = 0;
SELECT COUNT(*) INTO @col_exists
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 't_ai_knowledge_base'
  AND COLUMN_NAME = 'embedding_model';
SET @sql = IF(@col_exists = 0,
  'ALTER TABLE t_ai_knowledge_base ADD COLUMN embedding_model VARCHAR(50) DEFAULT NULL COMMENT ''向量模型'' AFTER embedding',
  'SELECT ''t_ai_knowledge_base.embedding_model already exists'' AS status');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @col_exists = 0;
SELECT COUNT(*) INTO @col_exists
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 't_ai_knowledge_base'
  AND COLUMN_NAME = 'embedding_dimension';
SET @sql = IF(@col_exists = 0,
  'ALTER TABLE t_ai_knowledge_base ADD COLUMN embedding_dimension INT DEFAULT NULL COMMENT ''向量维度'' AFTER embedding_model',
  'SELECT ''t_ai_knowledge_base.embedding_dimension already exists'' AS status');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @col_exists = 0;
SELECT COUNT(*) INTO @col_exists
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 't_ai_knowledge_base'
  AND COLUMN_NAME = 'chunk_index';
SET @sql = IF(@col_exists = 0,
  'ALTER TABLE t_ai_knowledge_base ADD COLUMN chunk_index INT DEFAULT 0 COMMENT ''同一来源分块序号'' AFTER embedding_dimension',
  'SELECT ''t_ai_knowledge_base.chunk_index already exists'' AS status');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @col_exists = 0;
SELECT COUNT(*) INTO @col_exists
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 't_ai_knowledge_base'
  AND COLUMN_NAME = 'content_hash';
SET @sql = IF(@col_exists = 0,
  'ALTER TABLE t_ai_knowledge_base ADD COLUMN content_hash VARCHAR(64) DEFAULT NULL COMMENT ''内容SHA256'' AFTER chunk_index',
  'SELECT ''t_ai_knowledge_base.content_hash already exists'' AS status');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @idx_exists = 0;
SELECT COUNT(*) INTO @idx_exists
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 't_ai_knowledge_base'
  AND INDEX_NAME = 'idx_kb_rag_source';
SET @sql = IF(@idx_exists = 0,
  'CREATE INDEX idx_kb_rag_source ON t_ai_knowledge_base(source_type, domain, enabled, deleted)',
  'SELECT ''idx_kb_rag_source already exists'' AS status');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ------------------------------------------------------------
-- 2. 学生档案与反馈闭环
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `t_user_learning_profile` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `user_id` INT NOT NULL,
  `profile_summary` TEXT NULL COMMENT 'Agent可读的学生画像摘要',
  `strengths` TEXT NULL COMMENT '优势知识点/科目摘要',
  `weaknesses` TEXT NULL COMMENT '薄弱知识点/科目摘要',
  `preferred_style` VARCHAR(50) DEFAULT NULL COMMENT '偏好的解析风格',
  `total_ai_requests` INT DEFAULT 0,
  `last_event_time` DATETIME DEFAULT NULL,
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_learning_profile` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='学生学习档案';

CREATE TABLE IF NOT EXISTS `t_user_learning_event` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `user_id` INT NOT NULL,
  `event_type` VARCHAR(50) NOT NULL COMMENT 'ai_analyze/ai_feedback/practice等',
  `style` VARCHAR(50) DEFAULT NULL,
  `target_type` VARCHAR(50) DEFAULT NULL,
  `target_id` INT DEFAULT NULL,
  `summary` TEXT NULL,
  `metadata` TEXT NULL COMMENT 'JSON字符串',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_event_time` (`user_id`, `create_time`),
  KEY `idx_event_type` (`event_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='学生学习事件流水';

CREATE TABLE IF NOT EXISTS `t_user_skill_feedback` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `user_id` INT NOT NULL,
  `usage_log_id` INT DEFAULT NULL,
  `style` VARCHAR(50) NOT NULL,
  `rating` INT DEFAULT 0,
  `feedback` TEXT NULL,
  `adjustment_note` TEXT NULL COMMENT '供个人化prompt注入的改进说明',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_style_time` (`user_id`, `style`, `create_time`),
  KEY `idx_usage_log` (`usage_log_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户对skill解析风格的反馈';

-- ------------------------------------------------------------
-- 3. 方法论摘要资料。只存摘要和来源，不保存长篇原文。
-- ------------------------------------------------------------
INSERT INTO `t_ai_knowledge_base`
  (`category`, `domain`, `sub_domain`, `title`, `keywords`, `content`,
   `source_type`, `source_name`, `source_author`, `core_concepts`,
   `application_scenarios`, `examples`, `enabled`, `priority`, `usage_count`,
   `create_user`, `create_time`, `update_time`, `deleted`, `chunk_index`,
   `content_hash`)
SELECT '学习方法论', 'feynman_method', 'skill_style', '费曼学习法摘要',
       '费曼学习法,类比,大白话,检查理解',
       '费曼学习法用于把复杂概念讲到足够简单：先选择概念，用自己的话解释；遇到卡住的地方回到资料补洞；再用类比、例子和简洁语言重新表达；最后通过输出或提问检查理解。用于408讲解时，应优先把术语翻译成可感知的场景，再回到严谨定义。',
       'method_summary', 'public_summary:feynman_method', '408Master',
       '简化解释;发现理解漏洞;类比表达',
       '费曼风格解析、知识点讲解、错题复盘',
       '把TCP可靠传输类比成快递签收和重发机制。',
       1, 85, 0, 1, NOW(), NOW(), b'0', 0,
       SHA2('public_summary:feynman_method', 256)
WHERE NOT EXISTS (
  SELECT 1 FROM `t_ai_knowledge_base`
  WHERE source_type = 'method_summary'
    AND source_name = 'public_summary:feynman_method'
);

INSERT INTO `t_ai_knowledge_base`
  (`category`, `domain`, `sub_domain`, `title`, `keywords`, `content`,
   `source_type`, `source_name`, `source_author`, `core_concepts`,
   `application_scenarios`, `examples`, `enabled`, `priority`, `usage_count`,
   `create_user`, `create_time`, `update_time`, `deleted`, `chunk_index`,
   `content_hash`)
SELECT '思维模型', 'first_principles', 'skill_style', '第一性原理摘要',
       '第一性原理,基本定义,假设拆解,逻辑推导',
       '第一性原理强调不要停留在经验规则，而是把问题拆到基本定义、约束和事实，再从这些基础重新推导结论。用于408题目解析时，应明确题目条件、定义、必要条件和充分条件，避免只背套路。',
       'method_summary', 'public_summary:first_principles', '408Master',
       '定义;假设;推导链;反事实检验',
       '第一性原理解析、复杂概念讲解',
       '分析虚拟存储器时，从地址空间、页表映射、缺页中断这些定义开始推导。',
       1, 85, 0, 1, NOW(), NOW(), b'0', 0,
       SHA2('public_summary:first_principles', 256)
WHERE NOT EXISTS (
  SELECT 1 FROM `t_ai_knowledge_base`
  WHERE source_type = 'method_summary'
    AND source_name = 'public_summary:first_principles'
);

INSERT INTO `t_ai_knowledge_base`
  (`category`, `domain`, `sub_domain`, `title`, `keywords`, `content`,
   `source_type`, `source_name`, `source_author`, `core_concepts`,
   `application_scenarios`, `examples`, `enabled`, `priority`, `usage_count`,
   `create_user`, `create_time`, `update_time`, `deleted`, `chunk_index`,
   `content_hash`)
SELECT '思维模型', 'plato_dialogue', 'skill_style', '柏拉图式对话摘要',
       '柏拉图式对话,苏格拉底式提问,启发式',
       '柏拉图式对话通过连续提问帮助学生自己发现矛盾、澄清概念并走向答案。用于408讲解时，应避免一开始直接给结论，而是围绕题干关键词、相关定义、选项矛盾和边界条件提出递进问题。',
       'method_summary', 'public_summary:plato_dialogue', '408Master',
       '递进提问;概念澄清;自我发现',
       '柏拉图式解析、互动式知识讲解',
       '先问学生题目限制了哪些条件，再追问这些条件排除了哪些选项。',
       1, 85, 0, 1, NOW(), NOW(), b'0', 0,
       SHA2('public_summary:plato_dialogue', 256)
WHERE NOT EXISTS (
  SELECT 1 FROM `t_ai_knowledge_base`
  WHERE source_type = 'method_summary'
    AND source_name = 'public_summary:plato_dialogue'
);

SELECT 'AI knowledge RAG schema ready' AS status;
