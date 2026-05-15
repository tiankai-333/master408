-- ============================================
-- 优化题目表结构，支持HTML内容
-- ============================================

USE xzs;

-- 1. 添加纯文本版本字段（用于搜索、统计等）
ALTER TABLE `t_question` 
ADD COLUMN `title_text` TEXT COMMENT '题目纯文本版本（用于搜索）',
ADD COLUMN `analysis_text` TEXT COMMENT '解析纯文本版本（用于搜索）';

-- 2. 添加内容格式标识
ALTER TABLE `t_question` 
ADD COLUMN `content_format` varchar(20) DEFAULT 'html' COMMENT '内容格式 html/markdown/plain';

-- 3. 添加选项格式标识
ALTER TABLE `t_question` 
MODIFY COLUMN `options` text COMMENT '选项（JSON格式，支持HTML: [{"key":"A","value":"<b>选项A</b>","image":""}]）';

-- 4. 添加元数据字段
ALTER TABLE `t_question` 
ADD COLUMN `html_content` text COMMENT '原始HTML内容（完整保留）',
ADD COLUMN `word_count` int DEFAULT '0' COMMENT '字数统计',
ADD COLUMN `has_code` bit(1) DEFAULT b'0' COMMENT '是否包含代码',
ADD COLUMN `has_image` bit(1) DEFAULT b'0' COMMENT '是否包含图片';

SELECT '题目表结构优化完成' AS message;

-- 查看优化后的表结构
DESCRIBE t_question;
