-- ============================================================
-- 12_canonical_ai_architecture.sql
-- Canonical question content, student graph, RAG, and Agent/Skill schema.
-- This migration is additive: it does not drop or rewrite legacy tables.
-- ============================================================

-- ------------------------------------------------------------
-- 1. Canonical question content
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `question_content` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `question_id` INT NOT NULL,
  `version` INT NOT NULL DEFAULT 1,
  `title` LONGTEXT NULL COMMENT '题干，HTML/Markdown/plain 均可',
  `options` LONGTEXT NULL COMMENT '选项 JSON',
  `correct_answer` LONGTEXT NULL COMMENT '规范答案',
  `analysis` LONGTEXT NULL COMMENT '解析',
  `title_text` LONGTEXT NULL COMMENT '题干纯文本',
  `analysis_text` LONGTEXT NULL COMMENT '解析纯文本',
  `content_format` VARCHAR(20) NOT NULL DEFAULT 'html',
  `has_image` BIT(1) NOT NULL DEFAULT b'0',
  `has_code` BIT(1) NOT NULL DEFAULT b'0',
  `legacy_text_content_id` INT DEFAULT NULL COMMENT '兼容旧 t_text_content.id',
  `source_hash` VARCHAR(64) DEFAULT NULL COMMENT '内容指纹，用于幂等回填',
  `is_current` BIT(1) NOT NULL DEFAULT b'1',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_question_content_version` (`question_id`, `version`),
  KEY `idx_question_content_current` (`question_id`, `is_current`),
  KEY `idx_question_content_legacy` (`legacy_text_content_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='规范题目内容表';

CREATE TABLE IF NOT EXISTS `question_asset` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `question_id` INT NOT NULL,
  `question_content_id` INT DEFAULT NULL,
  `asset_type` VARCHAR(30) NOT NULL DEFAULT 'image' COMMENT 'image/formula/code/original_file',
  `asset_url` VARCHAR(500) NOT NULL,
  `storage_key` VARCHAR(500) DEFAULT NULL,
  `alt_text` VARCHAR(500) DEFAULT NULL,
  `source_type` VARCHAR(50) DEFAULT NULL,
  `source_ref` VARCHAR(255) DEFAULT NULL,
  `sort_order` INT NOT NULL DEFAULT 0,
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_question_asset_question` (`question_id`, `sort_order`),
  KEY `idx_question_asset_content` (`question_content_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='题目图片/附件资源';

CREATE TABLE IF NOT EXISTS `question_source` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `question_id` INT NOT NULL,
  `source_type` VARCHAR(50) NOT NULL DEFAULT 'exam' COMMENT 'exam/crawler/ocr/manual/import',
  `source_name` VARCHAR(255) DEFAULT NULL,
  `source_year` INT DEFAULT NULL,
  `source_question_no` VARCHAR(50) DEFAULT NULL,
  `paper_name` VARCHAR(255) DEFAULT NULL,
  `page_no` VARCHAR(50) DEFAULT NULL,
  `raw_ref` VARCHAR(500) DEFAULT NULL,
  `crawler_batch` VARCHAR(100) DEFAULT NULL,
  `ocr_batch` VARCHAR(100) DEFAULT NULL,
  `metadata` LONGTEXT NULL COMMENT 'JSON',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_question_source_question` (`question_id`),
  KEY `idx_question_source_exam` (`source_year`, `source_question_no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='题目来源与溯源';

-- ------------------------------------------------------------
-- 2. Knowledge graph and student graph
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `knowledge_point_relation` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `source_knowledge_point_id` INT NOT NULL,
  `target_knowledge_point_id` INT NOT NULL,
  `relation_type` VARCHAR(30) NOT NULL COMMENT 'prerequisite/contains/similar/confusing/co_exam',
  `weight` DECIMAL(6,4) NOT NULL DEFAULT 1.0000,
  `description` VARCHAR(500) DEFAULT NULL,
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_kp_relation` (`source_knowledge_point_id`, `target_knowledge_point_id`, `relation_type`),
  KEY `idx_kp_relation_target` (`target_knowledge_point_id`, `relation_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='知识点关系图';

CREATE TABLE IF NOT EXISTS `student_learning_event` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `user_id` INT NOT NULL,
  `event_type` VARCHAR(50) NOT NULL COMMENT 'answer/view_analysis/ai_question/correct/review/favorite',
  `target_type` VARCHAR(50) DEFAULT NULL COMMENT 'question/knowledge_point/rag_chunk/agent_run',
  `target_id` INT DEFAULT NULL,
  `question_id` INT DEFAULT NULL,
  `knowledge_point_id` INT DEFAULT NULL,
  `exam_paper_answer_id` INT DEFAULT NULL,
  `customer_answer_id` INT DEFAULT NULL,
  `is_correct` BIT(1) DEFAULT NULL,
  `score_rate` DECIMAL(6,4) DEFAULT NULL,
  `duration_seconds` INT DEFAULT NULL,
  `summary` TEXT NULL,
  `metadata` LONGTEXT NULL COMMENT 'JSON',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_student_event_user_time` (`user_id`, `create_time`),
  KEY `idx_student_event_question` (`question_id`, `user_id`),
  KEY `idx_student_event_kp` (`knowledge_point_id`, `user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='学生学习事件流水';

CREATE TABLE IF NOT EXISTS `student_knowledge_state` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `user_id` INT NOT NULL,
  `knowledge_point_id` INT NOT NULL,
  `mastery` DECIMAL(6,4) NOT NULL DEFAULT 0.0000 COMMENT '0-1 掌握度',
  `confidence` DECIMAL(6,4) NOT NULL DEFAULT 0.0000 COMMENT '0-1 置信度',
  `attempt_count` INT NOT NULL DEFAULT 0,
  `correct_count` INT NOT NULL DEFAULT 0,
  `wrong_count` INT NOT NULL DEFAULT 0,
  `review_count` INT NOT NULL DEFAULT 0,
  `last_event_time` DATETIME DEFAULT NULL,
  `next_review_time` DATETIME DEFAULT NULL,
  `error_pattern` TEXT NULL,
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_student_kp_state` (`user_id`, `knowledge_point_id`),
  KEY `idx_student_state_review` (`user_id`, `next_review_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='学生知识点掌握状态';

CREATE TABLE IF NOT EXISTS `student_mistake_book` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `user_id` INT NOT NULL,
  `question_id` INT NOT NULL,
  `knowledge_point_id` INT DEFAULT NULL,
  `first_wrong_answer_id` INT DEFAULT NULL,
  `last_answer_id` INT DEFAULT NULL,
  `mistake_reason` VARCHAR(255) DEFAULT NULL,
  `correction_note` TEXT NULL,
  `status` VARCHAR(30) NOT NULL DEFAULT 'open' COMMENT 'open/corrected/mastered/ignored',
  `wrong_count` INT NOT NULL DEFAULT 1,
  `review_count` INT NOT NULL DEFAULT 0,
  `last_wrong_time` DATETIME DEFAULT NULL,
  `last_review_time` DATETIME DEFAULT NULL,
  `next_review_time` DATETIME DEFAULT NULL,
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_student_mistake_question` (`user_id`, `question_id`),
  KEY `idx_student_mistake_status` (`user_id`, `status`, `next_review_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='独立错题本';

-- ------------------------------------------------------------
-- 3. RAG metadata; vector data lives in Qdrant/Milvus/etc.
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `rag_document` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `document_type` VARCHAR(50) NOT NULL DEFAULT 'knowledge_base' COMMENT 'knowledge_base/question/exam/method/raw_import',
  `title` VARCHAR(255) NOT NULL,
  `summary` TEXT NULL,
  `subject_id` INT DEFAULT NULL,
  `knowledge_point_id` INT DEFAULT NULL,
  `source_type` VARCHAR(50) DEFAULT NULL,
  `source_name` VARCHAR(255) DEFAULT NULL,
  `source_ref` VARCHAR(500) DEFAULT NULL,
  `permission_scope` VARCHAR(50) NOT NULL DEFAULT 'public',
  `version` INT NOT NULL DEFAULT 1,
  `content_hash` VARCHAR(64) DEFAULT NULL,
  `status` VARCHAR(30) NOT NULL DEFAULT 'ready' COMMENT 'draft/ready/disabled',
  `legacy_knowledge_base_id` INT DEFAULT NULL,
  `create_user` INT DEFAULT NULL,
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_rag_document_hash` (`content_hash`),
  KEY `idx_rag_document_source` (`source_type`, `source_name`),
  KEY `idx_rag_document_kp` (`knowledge_point_id`, `status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='RAG文档主表';

CREATE TABLE IF NOT EXISTS `rag_chunk` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `document_id` BIGINT NOT NULL,
  `chunk_index` INT NOT NULL DEFAULT 0,
  `content` LONGTEXT NOT NULL,
  `content_text` LONGTEXT NULL,
  `token_count` INT DEFAULT NULL,
  `subject_id` INT DEFAULT NULL,
  `knowledge_point_id` INT DEFAULT NULL,
  `citation_label` VARCHAR(255) DEFAULT NULL,
  `source_position` VARCHAR(255) DEFAULT NULL,
  `content_hash` VARCHAR(64) DEFAULT NULL,
  `enabled` BIT(1) NOT NULL DEFAULT b'1',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_rag_chunk_document_index` (`document_id`, `chunk_index`),
  KEY `idx_rag_chunk_kp` (`knowledge_point_id`, `enabled`),
  KEY `idx_rag_chunk_hash` (`content_hash`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='RAG切片';

CREATE TABLE IF NOT EXISTS `rag_embedding` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `chunk_id` BIGINT NOT NULL,
  `embedding_model` VARCHAR(100) NOT NULL,
  `embedding_dimension` INT NOT NULL,
  `vector_store` VARCHAR(50) NOT NULL DEFAULT 'qdrant',
  `collection_name` VARCHAR(100) NOT NULL,
  `vector_id` VARCHAR(100) NOT NULL,
  `payload_hash` VARCHAR(64) DEFAULT NULL,
  `indexed_at` DATETIME DEFAULT NULL,
  `status` VARCHAR(30) NOT NULL DEFAULT 'pending' COMMENT 'pending/indexed/failed',
  `error_message` VARCHAR(1000) DEFAULT NULL,
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_rag_embedding_chunk_model` (`chunk_id`, `embedding_model`, `collection_name`),
  UNIQUE KEY `uk_rag_embedding_vector` (`collection_name`, `vector_id`),
  KEY `idx_rag_embedding_status` (`status`, `update_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='RAG向量库索引元数据';

CREATE TABLE IF NOT EXISTS `rag_retrieval_log` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `user_id` INT DEFAULT NULL,
  `query_text` TEXT NOT NULL,
  `query_hash` VARCHAR(64) DEFAULT NULL,
  `agent_run_id` BIGINT DEFAULT NULL,
  `top_k` INT NOT NULL DEFAULT 5,
  `result_count` INT NOT NULL DEFAULT 0,
  `latency_ms` INT DEFAULT NULL,
  `metadata` LONGTEXT NULL COMMENT 'JSON',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_rag_retrieval_user_time` (`user_id`, `create_time`),
  KEY `idx_rag_retrieval_run` (`agent_run_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='RAG检索日志';

CREATE TABLE IF NOT EXISTS `rag_answer_citation` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `retrieval_log_id` BIGINT DEFAULT NULL,
  `agent_run_id` BIGINT DEFAULT NULL,
  `chunk_id` BIGINT NOT NULL,
  `rank_no` INT DEFAULT NULL,
  `score` DECIMAL(10,6) DEFAULT NULL,
  `used_in_answer` BIT(1) NOT NULL DEFAULT b'0',
  `citation_text` VARCHAR(1000) DEFAULT NULL,
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_rag_citation_retrieval` (`retrieval_log_id`, `rank_no`),
  KEY `idx_rag_citation_run` (`agent_run_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='AI回答引用资料';

-- ------------------------------------------------------------
-- 4. Skill / Agent / Tool runtime
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `ai_skill` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `code` VARCHAR(80) NOT NULL,
  `name` VARCHAR(100) NOT NULL,
  `description` TEXT NULL,
  `skill_type` VARCHAR(50) NOT NULL DEFAULT 'analysis',
  `prompt_template_id` INT DEFAULT NULL,
  `config_json` LONGTEXT NULL,
  `enabled` BIT(1) NOT NULL DEFAULT b'1',
  `version` INT NOT NULL DEFAULT 1,
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_ai_skill_code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='AI能力模块';

CREATE TABLE IF NOT EXISTS `ai_agent` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `code` VARCHAR(80) NOT NULL,
  `name` VARCHAR(100) NOT NULL,
  `description` TEXT NULL,
  `agent_type` VARCHAR(50) NOT NULL DEFAULT 'student_tutor',
  `system_prompt` LONGTEXT NULL,
  `default_model` VARCHAR(100) DEFAULT NULL,
  `config_json` LONGTEXT NULL,
  `enabled` BIT(1) NOT NULL DEFAULT b'1',
  `version` INT NOT NULL DEFAULT 1,
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_ai_agent_code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='AI Agent';

CREATE TABLE IF NOT EXISTS `ai_agent_skill` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `agent_id` INT NOT NULL,
  `skill_id` INT NOT NULL,
  `sort_order` INT NOT NULL DEFAULT 0,
  `enabled` BIT(1) NOT NULL DEFAULT b'1',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_ai_agent_skill` (`agent_id`, `skill_id`),
  KEY `idx_ai_agent_skill_skill` (`skill_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Agent与Skill组合关系';

CREATE TABLE IF NOT EXISTS `ai_tool` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `code` VARCHAR(80) NOT NULL,
  `name` VARCHAR(100) NOT NULL,
  `description` TEXT NULL,
  `tool_type` VARCHAR(50) NOT NULL DEFAULT 'service',
  `handler_name` VARCHAR(150) DEFAULT NULL,
  `input_schema` LONGTEXT NULL,
  `output_schema` LONGTEXT NULL,
  `enabled` BIT(1) NOT NULL DEFAULT b'1',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_ai_tool_code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Agent可调用工具';

CREATE TABLE IF NOT EXISTS `ai_run_log` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `agent_id` INT DEFAULT NULL,
  `skill_id` INT DEFAULT NULL,
  `user_id` INT DEFAULT NULL,
  `session_id` VARCHAR(100) DEFAULT NULL,
  `request_text` LONGTEXT NULL,
  `response_text` LONGTEXT NULL,
  `retrieval_log_id` BIGINT DEFAULT NULL,
  `tool_call_json` LONGTEXT NULL,
  `model_name` VARCHAR(100) DEFAULT NULL,
  `prompt_tokens` INT DEFAULT NULL,
  `completion_tokens` INT DEFAULT NULL,
  `latency_ms` INT DEFAULT NULL,
  `cost_amount` DECIMAL(12,6) DEFAULT NULL,
  `status` VARCHAR(30) NOT NULL DEFAULT 'success',
  `error_message` VARCHAR(1000) DEFAULT NULL,
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_ai_run_user_time` (`user_id`, `create_time`),
  KEY `idx_ai_run_agent_time` (`agent_id`, `create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Agent运行日志';

INSERT INTO `ai_skill` (`code`, `name`, `description`, `skill_type`, `enabled`)
SELECT 'mistake_explain', '错题讲解', '结合题目、知识点和学生错因生成讲解', 'analysis', b'1'
WHERE NOT EXISTS (SELECT 1 FROM `ai_skill` WHERE `code` = 'mistake_explain');

INSERT INTO `ai_skill` (`code`, `name`, `description`, `skill_type`, `enabled`)
SELECT 'knowledge_diagnosis', '知识点诊断', '根据学习事件和错题定位薄弱知识点', 'diagnosis', b'1'
WHERE NOT EXISTS (SELECT 1 FROM `ai_skill` WHERE `code` = 'knowledge_diagnosis');

INSERT INTO `ai_skill` (`code`, `name`, `description`, `skill_type`, `enabled`)
SELECT 'exam_analysis', '真题解析', '面向408真题进行结构化解析', 'analysis', b'1'
WHERE NOT EXISTS (SELECT 1 FROM `ai_skill` WHERE `code` = 'exam_analysis');

INSERT INTO `ai_skill` (`code`, `name`, `description`, `skill_type`, `enabled`)
SELECT 'review_plan', '复习计划', '根据知识状态生成短周期复习计划', 'planning', b'1'
WHERE NOT EXISTS (SELECT 1 FROM `ai_skill` WHERE `code` = 'review_plan');

INSERT INTO `ai_agent` (`code`, `name`, `description`, `agent_type`, `default_model`, `enabled`)
SELECT 'cs408_tutor', '408 导学老师', '综合调用题库、RAG、学生图谱和错题本的默认学习 Agent', 'student_tutor', 'glm', b'1'
WHERE NOT EXISTS (SELECT 1 FROM `ai_agent` WHERE `code` = 'cs408_tutor');

INSERT INTO `ai_tool` (`code`, `name`, `description`, `tool_type`, `handler_name`, `enabled`)
SELECT 'rag_search', 'RAG 检索', '从向量库和 rag_chunk 中检索参考资料', 'service', 'ragIndexService.search', b'1'
WHERE NOT EXISTS (SELECT 1 FROM `ai_tool` WHERE `code` = 'rag_search');

INSERT INTO `ai_tool` (`code`, `name`, `description`, `tool_type`, `handler_name`, `enabled`)
SELECT 'student_graph_query', '学生图谱查询', '查询学生知识点掌握状态和错题状态', 'service', 'studentGraphService', b'1'
WHERE NOT EXISTS (SELECT 1 FROM `ai_tool` WHERE `code` = 'student_graph_query');

INSERT INTO `ai_agent_skill` (`agent_id`, `skill_id`, `sort_order`, `enabled`)
SELECT a.id, s.id, 10, b'1'
FROM `ai_agent` a, `ai_skill` s
WHERE a.code = 'cs408_tutor'
  AND s.code IN ('mistake_explain', 'knowledge_diagnosis', 'exam_analysis', 'review_plan')
  AND NOT EXISTS (
    SELECT 1 FROM `ai_agent_skill` x WHERE x.agent_id = a.id AND x.skill_id = s.id
  );

SELECT 'canonical AI architecture schema ready' AS status;
