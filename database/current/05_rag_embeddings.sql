-- ============================================================
-- RAG Embedding 向量存储
-- 用途：在 t_text_content 增加 embedding 列存储题目解析向量
-- 向量模型：GLM Embedding-2 (1024维)
-- 
-- 使用方法：先执行此SQL，再运行 ai/embed_questions.py
-- ============================================================

-- 安全添加列（检查列是否已存在）
SET @col_exists = 0;
SELECT COUNT(*) INTO @col_exists 
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = 'xzas' AND TABLE_NAME = 't_text_content' AND COLUMN_NAME = 'embedding';

SET @sql = IF(@col_exists = 0, 
    'ALTER TABLE t_text_content ADD COLUMN embedding LONGTEXT NULL COMMENT ''题目解析的向量嵌入(JSON float[] 格式)''',
    'SELECT ''embedding column already exists'' AS status');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SELECT 'RAG embedding column ready' AS status;
