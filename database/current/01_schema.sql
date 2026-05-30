-- MySQL dump 10.13  Distrib 8.0.33, for Linux (x86_64)
--
-- Host: localhost    Database: xzs
-- ------------------------------------------------------
-- Server version	8.0.33

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

DROP TABLE IF EXISTS `ai_agent`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ai_agent` (
  `id` int NOT NULL AUTO_INCREMENT,
  `code` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `agent_type` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'student_tutor',
  `system_prompt` longtext COLLATE utf8mb4_unicode_ci,
  `default_model` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `config_json` longtext COLLATE utf8mb4_unicode_ci,
  `enabled` bit(1) NOT NULL DEFAULT b'1',
  `version` int NOT NULL DEFAULT '1',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_ai_agent_code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='AI Agent';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `ai_agent_skill`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ai_agent_skill` (
  `id` int NOT NULL AUTO_INCREMENT,
  `agent_id` int NOT NULL,
  `skill_id` int NOT NULL,
  `sort_order` int NOT NULL DEFAULT '0',
  `enabled` bit(1) NOT NULL DEFAULT b'1',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_ai_agent_skill` (`agent_id`,`skill_id`),
  KEY `idx_ai_agent_skill_skill` (`skill_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Agent与Skill组合关系';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `ai_provider_config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ai_provider_config` (
  `id` int NOT NULL AUTO_INCREMENT,
  `provider_code` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'deepseek/openai/zhipu/custom',
  `provider_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `api_base_url` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `chat_model` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `embedding_model` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `api_key_cipher` longtext COLLATE utf8mb4_unicode_ci,
  `api_key_mask` varchar(80) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `enabled` bit(1) NOT NULL DEFAULT b'0',
  `priority` int NOT NULL DEFAULT '100',
  `last_test_success` bit(1) DEFAULT NULL,
  `last_test_message` varchar(1000) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `last_test_time` datetime DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_ai_provider_code` (`provider_code`),
  KEY `idx_ai_provider_enabled` (`enabled`,`priority`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='AI供应商密钥配置';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `ai_run_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ai_run_log` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `agent_id` int DEFAULT NULL,
  `skill_id` int DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `session_id` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `request_text` longtext COLLATE utf8mb4_unicode_ci,
  `response_text` longtext COLLATE utf8mb4_unicode_ci,
  `retrieval_log_id` bigint DEFAULT NULL,
  `tool_call_json` longtext COLLATE utf8mb4_unicode_ci,
  `model_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `prompt_tokens` int DEFAULT NULL,
  `completion_tokens` int DEFAULT NULL,
  `latency_ms` int DEFAULT NULL,
  `cost_amount` decimal(12,6) DEFAULT NULL,
  `status` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'success',
  `error_message` varchar(1000) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_ai_run_user_time` (`user_id`,`create_time`),
  KEY `idx_ai_run_agent_time` (`agent_id`,`create_time`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Agent运行日志';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `ai_skill`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ai_skill` (
  `id` int NOT NULL AUTO_INCREMENT,
  `code` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `skill_type` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'analysis',
  `prompt_template_id` int DEFAULT NULL,
  `config_json` longtext COLLATE utf8mb4_unicode_ci,
  `enabled` bit(1) NOT NULL DEFAULT b'1',
  `version` int NOT NULL DEFAULT '1',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_ai_skill_code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='AI能力模块';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `ai_tool`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ai_tool` (
  `id` int NOT NULL AUTO_INCREMENT,
  `code` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `tool_type` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'service',
  `handler_name` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `input_schema` longtext COLLATE utf8mb4_unicode_ci,
  `output_schema` longtext COLLATE utf8mb4_unicode_ci,
  `enabled` bit(1) NOT NULL DEFAULT b'1',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_ai_tool_code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Agent可调用工具';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `knowledge_content`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `knowledge_content` (
  `id` int NOT NULL AUTO_INCREMENT,
  `knowledge_point_id` int NOT NULL,
  `html_ref` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL,
  `summary_text` text COLLATE utf8mb4_unicode_ci,
  `source_url` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `asset_dir` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `metadata` longtext COLLATE utf8mb4_unicode_ci COMMENT 'JSON',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_knowledge_content_point` (`knowledge_point_id`),
  KEY `idx_knowledge_content_source` (`source_url`)
) ENGINE=InnoDB AUTO_INCREMENT=124 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='知识点富文本与本地资产引用';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `knowledge_point`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `knowledge_point` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `subject_id` int NOT NULL,
  `parent_id` int DEFAULT NULL,
  `description` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `level` int DEFAULT NULL,
  `sort_order` int DEFAULT '0',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `deleted` bit(1) DEFAULT b'0',
  PRIMARY KEY (`id`),
  KEY `idx_subject_id` (`subject_id`),
  KEY `idx_parent_id` (`parent_id`)
) ENGINE=InnoDB AUTO_INCREMENT=352 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `knowledge_point_relation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `knowledge_point_relation` (
  `id` int NOT NULL AUTO_INCREMENT,
  `source_knowledge_point_id` int NOT NULL,
  `target_knowledge_point_id` int NOT NULL,
  `relation_type` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'prerequisite/contains/similar/confusing/co_exam',
  `weight` decimal(6,4) NOT NULL DEFAULT '1.0000',
  `description` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_kp_relation` (`source_knowledge_point_id`,`target_knowledge_point_id`,`relation_type`),
  KEY `idx_kp_relation_target` (`target_knowledge_point_id`,`relation_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='知识点关系图';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `question_asset`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `question_asset` (
  `id` int NOT NULL AUTO_INCREMENT,
  `question_id` int NOT NULL,
  `question_content_id` int DEFAULT NULL,
  `asset_type` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'image' COMMENT 'image/formula/code/original_file',
  `asset_url` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL,
  `storage_key` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `alt_text` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `source_type` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `source_ref` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sort_order` int NOT NULL DEFAULT '0',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_question_asset_question` (`question_id`,`sort_order`),
  KEY `idx_question_asset_content` (`question_content_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='题目图片/附件资源';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `question_content`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `question_content` (
  `id` int NOT NULL AUTO_INCREMENT,
  `question_id` int NOT NULL,
  `version` int NOT NULL DEFAULT '1',
  `title` longtext COLLATE utf8mb4_unicode_ci COMMENT '题干，HTML/Markdown/plain 均可',
  `options` longtext COLLATE utf8mb4_unicode_ci COMMENT '选项 JSON',
  `correct_answer` longtext COLLATE utf8mb4_unicode_ci COMMENT '规范答案',
  `analysis` longtext COLLATE utf8mb4_unicode_ci COMMENT '解析',
  `title_text` longtext COLLATE utf8mb4_unicode_ci COMMENT '题干纯文本',
  `analysis_text` longtext COLLATE utf8mb4_unicode_ci COMMENT '解析纯文本',
  `content_format` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'html',
  `has_image` bit(1) NOT NULL DEFAULT b'0',
  `has_code` bit(1) NOT NULL DEFAULT b'0',
  `legacy_text_content_id` int DEFAULT NULL COMMENT '兼容旧 t_text_content.id',
  `source_hash` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '内容指纹，用于幂等回填',
  `is_current` bit(1) NOT NULL DEFAULT b'1',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_question_content_version` (`question_id`,`version`),
  KEY `idx_question_content_current` (`question_id`,`is_current`),
  KEY `idx_question_content_legacy` (`legacy_text_content_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7731 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='规范题目内容表';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `question_knowledge_point`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `question_knowledge_point` (
  `id` int NOT NULL AUTO_INCREMENT,
  `question_id` int NOT NULL,
  `knowledge_point_id` int NOT NULL,
  `relevance` decimal(3,2) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_question_id` (`question_id`),
  KEY `idx_knowledge_point_id` (`knowledge_point_id`)
) ENGINE=InnoDB AUTO_INCREMENT=8716 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `question_source`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `question_source` (
  `id` int NOT NULL AUTO_INCREMENT,
  `question_id` int NOT NULL,
  `source_type` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'exam' COMMENT 'exam/crawler/ocr/manual/import',
  `source_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `source_year` int DEFAULT NULL,
  `source_question_no` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `paper_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `page_no` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `raw_ref` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `crawler_batch` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ocr_batch` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `metadata` longtext COLLATE utf8mb4_unicode_ci COMMENT 'JSON',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_question_source_question` (`question_id`),
  KEY `idx_question_source_exam` (`source_year`,`source_question_no`)
) ENGINE=InnoDB AUTO_INCREMENT=7731 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='题目来源与溯源';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `rag_answer_citation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rag_answer_citation` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `retrieval_log_id` bigint DEFAULT NULL,
  `agent_run_id` bigint DEFAULT NULL,
  `chunk_id` bigint NOT NULL,
  `rank_no` int DEFAULT NULL,
  `score` decimal(10,6) DEFAULT NULL,
  `used_in_answer` bit(1) NOT NULL DEFAULT b'0',
  `citation_text` varchar(1000) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_rag_citation_retrieval` (`retrieval_log_id`,`rank_no`),
  KEY `idx_rag_citation_run` (`agent_run_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='AI回答引用资料';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `rag_chunk`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rag_chunk` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `document_id` bigint NOT NULL,
  `chunk_index` int NOT NULL DEFAULT '0',
  `content` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `content_text` longtext COLLATE utf8mb4_unicode_ci,
  `token_count` int DEFAULT NULL,
  `subject_id` int DEFAULT NULL,
  `knowledge_point_id` int DEFAULT NULL,
  `citation_label` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `source_position` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `content_hash` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `enabled` bit(1) NOT NULL DEFAULT b'1',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_rag_chunk_document_index` (`document_id`,`chunk_index`),
  KEY `idx_rag_chunk_kp` (`knowledge_point_id`,`enabled`),
  KEY `idx_rag_chunk_hash` (`content_hash`)
) ENGINE=InnoDB AUTO_INCREMENT=120 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='RAG切片';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `rag_document`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rag_document` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `document_type` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'knowledge_base' COMMENT 'knowledge_base/question/exam/method/raw_import',
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `summary` text COLLATE utf8mb4_unicode_ci,
  `subject_id` int DEFAULT NULL,
  `knowledge_point_id` int DEFAULT NULL,
  `source_type` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `source_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `source_ref` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `permission_scope` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'public',
  `version` int NOT NULL DEFAULT '1',
  `content_hash` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ready' COMMENT 'draft/ready/disabled',
  `legacy_knowledge_base_id` int DEFAULT NULL,
  `create_user` int DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_rag_document_source` (`source_type`,`source_name`),
  KEY `idx_rag_document_kp` (`knowledge_point_id`,`status`),
  KEY `idx_rag_document_hash` (`content_hash`)
) ENGINE=InnoDB AUTO_INCREMENT=120 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='RAG文档主表';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `rag_embedding`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rag_embedding` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `chunk_id` bigint NOT NULL,
  `embedding_model` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `embedding_dimension` int NOT NULL,
  `vector_store` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'qdrant',
  `collection_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `vector_id` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload_hash` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `indexed_at` datetime DEFAULT NULL,
  `status` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending' COMMENT 'pending/indexed/failed',
  `error_message` varchar(1000) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_rag_embedding_chunk_model` (`chunk_id`,`embedding_model`,`collection_name`),
  UNIQUE KEY `uk_rag_embedding_vector` (`collection_name`,`vector_id`),
  KEY `idx_rag_embedding_status` (`status`,`update_time`)
) ENGINE=InnoDB AUTO_INCREMENT=366 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='RAG向量库索引元数据';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `rag_retrieval_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rag_retrieval_log` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `query_text` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `query_hash` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `agent_run_id` bigint DEFAULT NULL,
  `top_k` int NOT NULL DEFAULT '5',
  `result_count` int NOT NULL DEFAULT '0',
  `latency_ms` int DEFAULT NULL,
  `metadata` longtext COLLATE utf8mb4_unicode_ci COMMENT 'JSON',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_rag_retrieval_user_time` (`user_id`,`create_time`),
  KEY `idx_rag_retrieval_run` (`agent_run_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='RAG检索日志';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `student_knowledge_state`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `student_knowledge_state` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `knowledge_point_id` int NOT NULL,
  `mastery` decimal(6,4) NOT NULL DEFAULT '0.0000' COMMENT '0-1 掌握度',
  `confidence` decimal(6,4) NOT NULL DEFAULT '0.0000' COMMENT '0-1 置信度',
  `attempt_count` int NOT NULL DEFAULT '0',
  `correct_count` int NOT NULL DEFAULT '0',
  `wrong_count` int NOT NULL DEFAULT '0',
  `review_count` int NOT NULL DEFAULT '0',
  `last_event_time` datetime DEFAULT NULL,
  `next_review_time` datetime DEFAULT NULL,
  `error_pattern` text COLLATE utf8mb4_unicode_ci,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_student_kp_state` (`user_id`,`knowledge_point_id`),
  KEY `idx_student_state_review` (`user_id`,`next_review_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='学生知识点掌握状态';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `student_learning_event`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `student_learning_event` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `event_type` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'answer/view_analysis/ai_question/correct/review/favorite',
  `target_type` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'question/knowledge_point/rag_chunk/agent_run',
  `target_id` int DEFAULT NULL,
  `question_id` int DEFAULT NULL,
  `knowledge_point_id` int DEFAULT NULL,
  `exam_paper_answer_id` int DEFAULT NULL,
  `customer_answer_id` int DEFAULT NULL,
  `is_correct` bit(1) DEFAULT NULL,
  `score_rate` decimal(6,4) DEFAULT NULL,
  `duration_seconds` int DEFAULT NULL,
  `summary` text COLLATE utf8mb4_unicode_ci,
  `metadata` longtext COLLATE utf8mb4_unicode_ci COMMENT 'JSON',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_student_event_user_time` (`user_id`,`create_time`),
  KEY `idx_student_event_question` (`question_id`,`user_id`),
  KEY `idx_student_event_kp` (`knowledge_point_id`,`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='学生学习事件流水';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `student_mistake_book`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `student_mistake_book` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `question_id` int NOT NULL,
  `knowledge_point_id` int DEFAULT NULL,
  `first_wrong_answer_id` int DEFAULT NULL,
  `last_answer_id` int DEFAULT NULL,
  `mistake_reason` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `correction_note` text COLLATE utf8mb4_unicode_ci,
  `status` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'open' COMMENT 'open/corrected/mastered/ignored',
  `wrong_count` int NOT NULL DEFAULT '1',
  `review_count` int NOT NULL DEFAULT '0',
  `last_wrong_time` datetime DEFAULT NULL,
  `last_review_time` datetime DEFAULT NULL,
  `next_review_time` datetime DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_student_mistake_question` (`user_id`,`question_id`),
  KEY `idx_student_mistake_status` (`user_id`,`status`,`next_review_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='独立错题本';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `t_ai_adjustment_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_ai_adjustment_log` (
  `id` int NOT NULL AUTO_INCREMENT,
  `template_id` int DEFAULT NULL,
  `style` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `adjustment_type` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `before_content` text COLLATE utf8mb4_unicode_ci,
  `after_content` text COLLATE utf8mb4_unicode_ci,
  `adjustment_reason` text COLLATE utf8mb4_unicode_ci,
  `adjustment_details` text COLLATE utf8mb4_unicode_ci,
  `test_result` text COLLATE utf8mb4_unicode_ci,
  `test_question` text COLLATE utf8mb4_unicode_ci,
  `test_feedback` text COLLATE utf8mb4_unicode_ci,
  `rating` int DEFAULT NULL,
  `status` int DEFAULT NULL,
  `approver_id` int DEFAULT NULL,
  `approve_time` datetime DEFAULT NULL,
  `approve_comment` text COLLATE utf8mb4_unicode_ci,
  `create_user` int DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `ip_address` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_template_id` (`template_id`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `t_ai_knowledge_base`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_ai_knowledge_base` (
  `id` int NOT NULL AUTO_INCREMENT,
  `category` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `domain` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `sub_domain` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `title` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `keywords` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `content` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `embedding` longtext COLLATE utf8mb4_unicode_ci COMMENT 'RAGå‘é‡(JSON float[] æ ¼å¼)',
  `embedding_model` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'å‘é‡æ¨¡åž‹',
  `embedding_dimension` int DEFAULT NULL COMMENT 'å‘é‡ç»´åº¦',
  `chunk_index` int DEFAULT '0' COMMENT 'åŒä¸€æ¥æºåˆ†å—åºå·',
  `content_hash` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'å†…å®¹SHA256',
  `source_type` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `source_name` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `source_author` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `core_concepts` text COLLATE utf8mb4_unicode_ci,
  `application_scenarios` text COLLATE utf8mb4_unicode_ci,
  `examples` text COLLATE utf8mb4_unicode_ci,
  `enabled` tinyint(1) DEFAULT '1',
  `priority` int DEFAULT '0',
  `usage_count` int DEFAULT '0',
  `create_user` int DEFAULT '1',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) DEFAULT b'0',
  PRIMARY KEY (`id`),
  KEY `idx_category` (`category`),
  KEY `idx_domain` (`domain`),
  KEY `idx_enabled` (`enabled`),
  KEY `idx_kb_rag_source` (`source_type`,`domain`,`enabled`,`deleted`)
) ENGINE=InnoDB AUTO_INCREMENT=349 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `t_ai_prompt_template`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_ai_prompt_template` (
  `id` int NOT NULL AUTO_INCREMENT,
  `style` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `icon` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `system_prompt` text COLLATE utf8mb4_unicode_ci,
  `user_prompt_template` text COLLATE utf8mb4_unicode_ci,
  `knowledge_base_ids` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `reference_materials` text COLLATE utf8mb4_unicode_ci,
  `variables` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `output_format` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `temperature` decimal(3,2) DEFAULT '0.70',
  `max_tokens` int DEFAULT '2000',
  `enabled` tinyint(1) DEFAULT '1',
  `is_default` tinyint(1) DEFAULT '0',
  `usage_count` int DEFAULT '0',
  `rating_sum` int DEFAULT '0',
  `rating_count` int DEFAULT '0',
  `create_user` int DEFAULT '1',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) DEFAULT b'0',
  PRIMARY KEY (`id`),
  KEY `idx_style` (`style`),
  KEY `idx_enabled` (`enabled`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `t_ai_usage_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_ai_usage_log` (
  `id` int NOT NULL AUTO_INCREMENT,
  `template_id` int DEFAULT NULL,
  `style` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `ai_type` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `model` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `question` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `knowledge_points` text COLLATE utf8mb4_unicode_ci,
  `knowledge_base_ids` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `prompt` text COLLATE utf8mb4_unicode_ci,
  `response` text COLLATE utf8mb4_unicode_ci,
  `response_length` int DEFAULT '0',
  `tokens_used` int DEFAULT '0',
  `cost` decimal(10,4) DEFAULT '0.0000',
  `duration_ms` int DEFAULT '0',
  `success` tinyint(1) DEFAULT '1',
  `error_message` text COLLATE utf8mb4_unicode_ci,
  `user_rating` int DEFAULT '0',
  `user_feedback` text COLLATE utf8mb4_unicode_ci,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_template_id` (`template_id`),
  KEY `idx_style` (`style`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `t_essay_question`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_essay_question` (
  `id` int NOT NULL AUTO_INCREMENT,
  `subject_id` int NOT NULL,
  `year` int NOT NULL,
  `question_no` int NOT NULL COMMENT 'é¢˜å· 41-47',
  `title` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `sub_questions` text COLLATE utf8mb4_unicode_ci COMMENT 'å­é—®é¢˜ JSON',
  `total_score` int DEFAULT '10',
  `answer` text COLLATE utf8mb4_unicode_ci,
  `analysis` text COLLATE utf8mb4_unicode_ci,
  `images` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`),
  KEY `idx_subject_year` (`subject_id`,`year`)
) ENGINE=InnoDB AUTO_INCREMENT=99 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `t_exam_paper`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_exam_paper` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `subject_id` int DEFAULT NULL,
  `paper_type` int NOT NULL DEFAULT '1',
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
  `source_year` int DEFAULT NULL COMMENT 'æ¥æºå¹´ä»½',
  `description` text COLLATE utf8mb4_unicode_ci COMMENT 'è¯•å·æè¿°',
  PRIMARY KEY (`id`),
  KEY `idx_subject_id` (`subject_id`),
  KEY `idx_paper_type` (`paper_type`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB AUTO_INCREMENT=272 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `t_exam_paper_answer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_exam_paper_answer` (
  `id` int NOT NULL AUTO_INCREMENT,
  `exam_paper_id` int DEFAULT NULL,
  `paper_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
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
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `t_exam_paper_question_customer_answer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
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
  `answer` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `text_content_id` int DEFAULT NULL,
  `do_right` bit(1) DEFAULT NULL,
  `create_user` int DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `item_order` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_exam_paper_answer_id` (`exam_paper_answer_id`)
) ENGINE=InnoDB AUTO_INCREMENT=131 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `t_message`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_message` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `content` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `send_user_id` int DEFAULT NULL,
  `send_user_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `send_real_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `receive_user_count` int DEFAULT NULL,
  `read_count` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `t_message_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_message_user` (
  `id` int NOT NULL AUTO_INCREMENT,
  `message_id` int DEFAULT NULL,
  `receive_user_id` int DEFAULT NULL,
  `receive_user_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `receive_real_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `readed` bit(1) DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `read_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_message_id` (`message_id`),
  KEY `idx_receive_user_id` (`receive_user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `t_question`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_question` (
  `id` int NOT NULL AUTO_INCREMENT,
  `question_type` int NOT NULL DEFAULT '1',
  `subject_id` int NOT NULL,
  `title` text COLLATE utf8mb4_unicode_ci COMMENT 'é¢˜ç›®å†…å®¹ï¼ˆHTMLï¼‰',
  `options` text COLLATE utf8mb4_unicode_ci COMMENT 'é€‰é¡¹ JSON',
  `correct_answer` text COLLATE utf8mb4_unicode_ci COMMENT 'æ­£ç¡®ç­”æ¡ˆ',
  `analysis` text COLLATE utf8mb4_unicode_ci COMMENT 'è§£æžï¼ˆHTMLï¼‰',
  `difficulty` int DEFAULT '2' COMMENT 'éš¾åº¦ 1=ç®€å• 2=ä¸­ç­‰ 3=å›°éš¾',
  `knowledge_point` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'çŸ¥è¯†ç‚¹',
  `source` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'æ¥æº å¦‚ 2024å¹´408çœŸé¢˜',
  `source_year` int DEFAULT NULL COMMENT 'æ¥æºå¹´ä»½',
  `source_question_no` int DEFAULT NULL COMMENT 'åŽŸå§‹é¢˜å· 1-47',
  `tags` text COLLATE utf8mb4_unicode_ci COMMENT 'çŸ¥è¯†æ ‡ç­¾ é€—å·åˆ†éš”',
  `images` text COLLATE utf8mb4_unicode_ci COMMENT 'å›¾ç‰‡è·¯å¾„',
  `title_text` text COLLATE utf8mb4_unicode_ci COMMENT 'é¢˜ç›®çº¯æ–‡æœ¬',
  `analysis_text` text COLLATE utf8mb4_unicode_ci COMMENT 'è§£æžçº¯æ–‡æœ¬',
  `content_format` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT 'html' COMMENT 'å†…å®¹æ ¼å¼ html/markdown/plain',
  `has_image` bit(1) DEFAULT b'0' COMMENT 'æ˜¯å¦åŒ…å«å›¾ç‰‡',
  `has_code` bit(1) DEFAULT b'0' COMMENT 'æ˜¯å¦åŒ…å«ä»£ç ',
  `score` int DEFAULT NULL,
  `grade_level` int DEFAULT NULL,
  `difficult` int DEFAULT NULL,
  `correct` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `info_text_content_id` int DEFAULT NULL,
  `create_user` int DEFAULT NULL,
  `status` int NOT NULL DEFAULT '1',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `deleted` bit(1) DEFAULT b'0',
  PRIMARY KEY (`id`),
  KEY `idx_subject_id` (`subject_id`),
  KEY `idx_question_type` (`question_type`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=7366 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `t_subject`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_subject` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `level` int DEFAULT NULL,
  `level_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `item_order` int DEFAULT NULL,
  `deleted` bit(1) DEFAULT b'0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `t_task_exam`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_task_exam` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `grade_level` int DEFAULT NULL,
  `frame_text_content_id` int DEFAULT NULL,
  `create_user` int DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `deleted` bit(1) DEFAULT b'0',
  `create_user_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `t_task_exam_customer_answer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_task_exam_customer_answer` (
  `id` int NOT NULL AUTO_INCREMENT,
  `task_exam_id` int DEFAULT NULL,
  `create_user` int DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `text_content_id` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `t_text_content`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_text_content` (
  `id` int NOT NULL AUTO_INCREMENT,
  `content` text COLLATE utf8mb4_unicode_ci,
  `create_time` datetime DEFAULT NULL,
  `embedding` longtext COLLATE utf8mb4_unicode_ci COMMENT 'é¢˜ç›®è§£æžçš„å‘é‡åµŒå…¥(JSON float[] æ ¼å¼)',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7654 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `t_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_user` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_uuid` varchar(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `real_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `age` int DEFAULT NULL,
  `sex` int DEFAULT NULL,
  `birth_day` datetime DEFAULT NULL,
  `user_level` int DEFAULT NULL,
  `phone` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `role` int NOT NULL DEFAULT '1',
  `status` int NOT NULL DEFAULT '1',
  `image_path` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `modify_time` datetime DEFAULT NULL,
  `last_active_time` datetime DEFAULT NULL,
  `deleted` bit(1) DEFAULT b'0',
  `wx_open_id` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_name` (`user_name`),
  KEY `idx_role` (`role`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `t_user_event_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_user_event_log` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `user_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `real_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `content` text COLLATE utf8mb4_unicode_ci,
  `create_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=56 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `t_user_learning_event`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_user_learning_event` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `event_type` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'ai_analyze/ai_feedback/practiceç­‰',
  `style` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `target_type` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `target_id` int DEFAULT NULL,
  `summary` text COLLATE utf8mb4_unicode_ci,
  `metadata` text COLLATE utf8mb4_unicode_ci COMMENT 'JSONå­—ç¬¦ä¸²',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_event_time` (`user_id`,`create_time`),
  KEY `idx_event_type` (`event_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='å­¦ç”Ÿå­¦ä¹ äº‹ä»¶æµæ°´';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `t_user_learning_profile`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_user_learning_profile` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `profile_summary` text COLLATE utf8mb4_unicode_ci COMMENT 'Agentå¯è¯»çš„å­¦ç”Ÿç”»åƒæ‘˜è¦',
  `strengths` text COLLATE utf8mb4_unicode_ci COMMENT 'ä¼˜åŠ¿çŸ¥è¯†ç‚¹/ç§‘ç›®æ‘˜è¦',
  `weaknesses` text COLLATE utf8mb4_unicode_ci COMMENT 'è–„å¼±çŸ¥è¯†ç‚¹/ç§‘ç›®æ‘˜è¦',
  `preferred_style` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'åå¥½çš„è§£æžé£Žæ ¼',
  `total_ai_requests` int DEFAULT '0',
  `last_event_time` datetime DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_learning_profile` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='å­¦ç”Ÿå­¦ä¹ æ¡£æ¡ˆ';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `t_user_skill_feedback`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_user_skill_feedback` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `usage_log_id` int DEFAULT NULL,
  `style` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `rating` int DEFAULT '0',
  `feedback` text COLLATE utf8mb4_unicode_ci,
  `adjustment_note` text COLLATE utf8mb4_unicode_ci COMMENT 'ä¾›ä¸ªäººåŒ–promptæ³¨å…¥çš„æ”¹è¿›è¯´æ˜Ž',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_style_time` (`user_id`,`style`,`create_time`),
  KEY `idx_usage_log` (`usage_log_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='ç”¨æˆ·å¯¹skillè§£æžé£Žæ ¼çš„åé¦ˆ';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `t_user_token`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_user_token` (
  `id` int NOT NULL AUTO_INCREMENT,
  `token` varchar(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `wx_open_id` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `end_time` datetime DEFAULT NULL,
  `user_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_token` (`token`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
-- Dump completed on 2026-05-30
