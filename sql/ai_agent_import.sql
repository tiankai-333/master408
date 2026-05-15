-- ============================================
-- AI Agent 管理系统 - 数据库导入脚本
-- ============================================

-- 使用说明：
-- 1. 确保已创建 xzs 数据库
-- 2. 执行本脚本导入所有表和数据

USE xzs;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================
-- 1. 创建 AI 提示词模板表
-- ============================================
DROP TABLE IF EXISTS `t_ai_prompt_template`;
CREATE TABLE `t_ai_prompt_template` (
    `id` INT(11) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `style` VARCHAR(50) NOT NULL COMMENT '风格标识',
    `name` VARCHAR(100) NOT NULL COMMENT '风格名称',
    `description` VARCHAR(500) DEFAULT '' COMMENT '风格描述',
    `icon` VARCHAR(50) DEFAULT '' COMMENT '图标',
    `system_prompt` TEXT NOT NULL COMMENT '系统提示词',
    `user_prompt_template` TEXT NOT NULL COMMENT '用户提示词模板',
    `knowledge_base_ids` VARCHAR(255) DEFAULT '' COMMENT '关联知识库ID',
    `reference_materials` TEXT COMMENT '参考材料',
    `variables` VARCHAR(255) DEFAULT '' COMMENT '变量列表',
    `output_format` VARCHAR(50) DEFAULT 'markdown' COMMENT '输出格式',
    `temperature` DECIMAL(3,2) DEFAULT 0.70 COMMENT '温度参数',
    `max_tokens` INT(11) DEFAULT 4096 COMMENT '最大token数',
    `enabled` TINYINT(1) DEFAULT 1 COMMENT '是否启用',
    `is_default` TINYINT(1) DEFAULT 0 COMMENT '是否默认',
    `usage_count` INT(11) DEFAULT 0 COMMENT '使用次数',
    `rating_sum` INT(11) DEFAULT 0 COMMENT '评分总和',
    `rating_count` INT(11) DEFAULT 0 COMMENT '评分次数',
    `create_user` INT(11) DEFAULT 1 COMMENT '创建用户',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted` BIT(1) DEFAULT b'0' COMMENT '是否删除',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_style` (`style`),
    KEY `idx_enabled` (`enabled`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='AI提示词模板表';

-- ============================================
-- 2. 创建 AI 知识库表
-- ============================================
DROP TABLE IF EXISTS `t_ai_knowledge_base`;
CREATE TABLE `t_ai_knowledge_base` (
    `id` INT(11) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `category` VARCHAR(50) NOT NULL COMMENT '分类',
    `domain` VARCHAR(50) NOT NULL COMMENT '领域',
    `sub_domain` VARCHAR(50) DEFAULT '' COMMENT '子领域',
    `title` VARCHAR(200) NOT NULL COMMENT '标题',
    `keywords` VARCHAR(255) DEFAULT '' COMMENT '关键词',
    `content` TEXT NOT NULL COMMENT '知识内容',
    `source_type` VARCHAR(50) DEFAULT '' COMMENT '来源类型',
    `source_name` VARCHAR(200) DEFAULT '' COMMENT '来源名称',
    `source_author` VARCHAR(100) DEFAULT '' COMMENT '作者',
    `core_concepts` TEXT COMMENT '核心概念',
    `application_scenarios` TEXT COMMENT '应用场景',
    `examples` TEXT COMMENT '示例',
    `enabled` TINYINT(1) DEFAULT 1 COMMENT '是否启用',
    `priority` INT(11) DEFAULT 0 COMMENT '优先级',
    `usage_count` INT(11) DEFAULT 0 COMMENT '使用次数',
    `create_user` INT(11) DEFAULT 1 COMMENT '创建用户',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted` BIT(1) DEFAULT b'0' COMMENT '是否删除',
    PRIMARY KEY (`id`),
    KEY `idx_category` (`category`),
    KEY `idx_domain` (`domain`),
    KEY `idx_priority` (`priority`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='AI知识库表';

-- ============================================
-- 3. 创建 AI 调整日志表
-- ============================================
DROP TABLE IF EXISTS `t_ai_adjustment_log`;
CREATE TABLE `t_ai_adjustment_log` (
    `id` INT(11) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `template_id` INT(11) DEFAULT NULL COMMENT '模板ID',
    `style` VARCHAR(50) NOT NULL COMMENT '风格标识',
    `adjustment_type` VARCHAR(50) NOT NULL COMMENT '调整类型',
    `before_content` TEXT COMMENT '调整前内容',
    `after_content` TEXT COMMENT '调整后内容',
    `adjustment_reason` VARCHAR(500) DEFAULT '' COMMENT '调整原因',
    `adjustment_details` TEXT COMMENT '调整详情',
    `test_result` TEXT COMMENT '测试结果',
    `test_question` TEXT COMMENT '测试题目',
    `test_feedback` VARCHAR(500) DEFAULT '' COMMENT '测试反馈',
    `rating` INT(11) DEFAULT 0 COMMENT '评分',
    `status` VARCHAR(20) DEFAULT 'pending' COMMENT '状态',
    `approver_id` INT(11) DEFAULT NULL COMMENT '审批人',
    `approve_time` DATETIME DEFAULT NULL COMMENT '审批时间',
    `approve_comment` VARCHAR(500) DEFAULT '' COMMENT '审批意见',
    `create_user` INT(11) DEFAULT 1 COMMENT '操作用户',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
    `ip_address` VARCHAR(50) DEFAULT '' COMMENT 'IP地址',
    PRIMARY KEY (`id`),
    KEY `idx_template_id` (`template_id`),
    KEY `idx_style` (`style`),
    KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='AI调整日志表';

-- ============================================
-- 4. 创建 AI 使用记录表
-- ============================================
DROP TABLE IF EXISTS `t_ai_usage_log`;
CREATE TABLE `t_ai_usage_log` (
    `id` INT(11) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `template_id` INT(11) DEFAULT NULL COMMENT '模板ID',
    `style` VARCHAR(50) NOT NULL COMMENT '风格标识',
    `ai_type` VARCHAR(20) DEFAULT '' COMMENT 'AI类型',
    `model` VARCHAR(50) DEFAULT '' COMMENT '模型',
    `question` TEXT NOT NULL COMMENT '用户问题',
    `knowledge_points` TEXT COMMENT '知识点',
    `knowledge_base_ids` VARCHAR(255) DEFAULT '' COMMENT '使用知识库ID',
    `prompt` TEXT COMMENT '发送提示词',
    `response` TEXT COMMENT 'AI响应',
    `response_length` INT(11) DEFAULT 0 COMMENT '响应长度',
    `tokens_used` INT(11) DEFAULT 0 COMMENT '使用token数',
    `cost` DECIMAL(10,4) DEFAULT 0 COMMENT '费用',
    `duration_ms` INT(11) DEFAULT 0 COMMENT '耗时',
    `success` TINYINT(1) DEFAULT 1 COMMENT '是否成功',
    `error_message` TEXT COMMENT '错误信息',
    `user_rating` INT(11) DEFAULT 0 COMMENT '用户评分',
    `user_feedback` TEXT COMMENT '用户反馈',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    KEY `idx_template_id` (`template_id`),
    KEY `idx_style` (`style`),
    KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='AI使用记录表';

SET FOREIGN_KEY_CHECKS = 1;

-- ============================================
-- 5. 插入默认数据
-- ============================================
-- 请运行 sql/ai_agent_tables.sql 中的 INSERT 语句
