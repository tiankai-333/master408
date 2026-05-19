-- ============================================================
-- 13_backfill_canonical_ai_data.sql
-- Idempotent backfill from legacy tables into the canonical layer.
-- Safe to run repeatedly after 12_canonical_ai_architecture.sql.
-- ============================================================

-- ------------------------------------------------------------
-- 1. Question content from t_question and t_text_content.
-- Prefer structured 408 extension fields when present; keep old text content id.
-- ------------------------------------------------------------
INSERT INTO `question_content`
  (`question_id`, `version`, `title`, `options`, `correct_answer`, `analysis`,
   `title_text`, `analysis_text`, `content_format`, `has_image`, `has_code`,
   `legacy_text_content_id`, `source_hash`, `is_current`)
SELECT
  q.id,
  1,
  COALESCE(q.title, IF(JSON_VALID(tc.content), JSON_UNQUOTE(JSON_EXTRACT(tc.content, '$.titleContent')), NULL), tc.content),
  q.options,
  COALESCE(q.correct_answer, q.correct),
  COALESCE(q.analysis, IF(JSON_VALID(tc.content), JSON_UNQUOTE(JSON_EXTRACT(tc.content, '$.analyze')), NULL)),
  q.title_text,
  q.analysis_text,
  COALESCE(q.content_format, 'html'),
  COALESCE(q.has_image, b'0'),
  COALESCE(q.has_code, b'0'),
  q.info_text_content_id,
  SHA2(CONCAT_WS('|',
    q.id,
    COALESCE(q.title, ''),
    COALESCE(q.options, ''),
    COALESCE(q.correct_answer, q.correct, ''),
    COALESCE(q.analysis, ''),
    COALESCE(tc.content, '')
  ), 256),
  b'1'
FROM `t_question` q
LEFT JOIN `t_text_content` tc ON tc.id = q.info_text_content_id
WHERE q.deleted = b'0'
  AND NOT EXISTS (
    SELECT 1 FROM `question_content` qc
    WHERE qc.question_id = q.id AND qc.version = 1
  );

-- ------------------------------------------------------------
-- 2. Question source from current 408 extension fields.
-- ------------------------------------------------------------
INSERT INTO `question_source`
  (`question_id`, `source_type`, `source_name`, `source_year`, `source_question_no`,
   `paper_name`, `metadata`)
SELECT
  q.id,
  'exam',
  q.source,
  q.source_year,
  CAST(q.source_question_no AS CHAR),
  q.source,
  JSON_OBJECT('legacy_tags', q.tags, 'legacy_knowledge_point', q.knowledge_point)
FROM `t_question` q
WHERE q.deleted = b'0'
  AND (q.source IS NOT NULL OR q.source_year IS NOT NULL OR q.source_question_no IS NOT NULL)
  AND NOT EXISTS (
    SELECT 1 FROM `question_source` qs
    WHERE qs.question_id = q.id
      AND qs.source_type COLLATE utf8mb4_unicode_ci = 'exam' COLLATE utf8mb4_unicode_ci
      AND IFNULL(qs.source_year, 0) = IFNULL(q.source_year, 0)
      AND IFNULL(qs.source_question_no, '') COLLATE utf8mb4_unicode_ci = IFNULL(CAST(q.source_question_no AS CHAR), '') COLLATE utf8mb4_unicode_ci
  );

-- ------------------------------------------------------------
-- 3. Initial structured question -> knowledge point relation.
-- Exact matching only; fuzzy matching stays in application fallback until reviewed.
-- ------------------------------------------------------------
INSERT INTO `question_knowledge_point` (`question_id`, `knowledge_point_id`, `relevance`)
SELECT DISTINCT q.id, kp.id, 1.0000
FROM `t_question` q
JOIN `knowledge_point` kp
  ON q.knowledge_point COLLATE utf8mb4_unicode_ci = kp.name COLLATE utf8mb4_unicode_ci
  OR FIND_IN_SET(kp.name COLLATE utf8mb4_unicode_ci, REPLACE(REPLACE(IFNULL(q.tags, ''), '，', ','), ';', ',') COLLATE utf8mb4_unicode_ci) > 0
WHERE q.deleted = b'0'
  AND NOT EXISTS (
    SELECT 1 FROM `question_knowledge_point` qkp
    WHERE qkp.question_id = q.id AND qkp.knowledge_point_id = kp.id
  );

-- ------------------------------------------------------------
-- 4. RAG documents/chunks from t_ai_knowledge_base.
-- One legacy knowledge base row becomes one document and one initial chunk.
-- ------------------------------------------------------------
INSERT INTO `rag_document`
  (`document_type`, `title`, `summary`, `subject_id`, `knowledge_point_id`,
   `source_type`, `source_name`, `source_ref`, `permission_scope`, `version`,
   `content_hash`, `status`, `legacy_knowledge_base_id`, `create_user`)
SELECT
  'knowledge_base',
  kb.title,
  kb.core_concepts,
  NULL,
  COALESCE(kp_title.id, kp_sub.id),
  kb.source_type,
  kb.source_name,
  CONCAT('t_ai_knowledge_base:', kb.id),
  'public',
  1,
  COALESCE(kb.content_hash, SHA2(CONCAT_WS('|', kb.id, kb.title, kb.content), 256)),
  IF(kb.enabled = b'1', 'ready', 'disabled'),
  kb.id,
  kb.create_user
FROM `t_ai_knowledge_base` kb
LEFT JOIN (
  SELECT name COLLATE utf8mb4_unicode_ci AS name_key, MIN(id) AS id
  FROM `knowledge_point`
  GROUP BY name COLLATE utf8mb4_unicode_ci
) kp_title ON kp_title.name_key = kb.title COLLATE utf8mb4_unicode_ci
LEFT JOIN (
  SELECT name COLLATE utf8mb4_unicode_ci AS name_key, MIN(id) AS id
  FROM `knowledge_point`
  GROUP BY name COLLATE utf8mb4_unicode_ci
) kp_sub ON kp_sub.name_key = kb.sub_domain COLLATE utf8mb4_unicode_ci
WHERE kb.deleted = b'0'
  AND NOT EXISTS (
    SELECT 1 FROM `rag_document` rd WHERE rd.legacy_knowledge_base_id = kb.id
  );

INSERT INTO `rag_chunk`
  (`document_id`, `chunk_index`, `content`, `content_text`, `token_count`,
   `subject_id`, `knowledge_point_id`, `citation_label`, `source_position`,
   `content_hash`, `enabled`)
SELECT
  rd.id,
  COALESCE(kb.chunk_index, 0),
  kb.content,
  kb.content,
  CHAR_LENGTH(kb.content),
  rd.subject_id,
  rd.knowledge_point_id,
  kb.title,
  rd.source_ref,
  COALESCE(kb.content_hash, SHA2(CONCAT_WS('|', kb.id, kb.title, kb.content), 256)),
  kb.enabled
FROM `rag_document` rd
JOIN `t_ai_knowledge_base` kb ON kb.id = rd.legacy_knowledge_base_id
WHERE kb.deleted = b'0'
  AND kb.content IS NOT NULL
  AND NOT EXISTS (
    SELECT 1 FROM `rag_chunk` rc
    WHERE rc.document_id = rd.id AND rc.chunk_index = COALESCE(kb.chunk_index, 0)
  );

-- Carry existing legacy embedding metadata forward as already-indexed compatibility records.
INSERT INTO `rag_embedding`
  (`chunk_id`, `embedding_model`, `embedding_dimension`, `vector_store`,
   `collection_name`, `vector_id`, `payload_hash`, `indexed_at`, `status`)
SELECT
  rc.id,
  COALESCE(kb.embedding_model, 'legacy-json'),
  COALESCE(kb.embedding_dimension, 0),
  'mysql-legacy',
  't_ai_knowledge_base',
  CONCAT('kb-', kb.id, '-chunk-', rc.chunk_index),
  SHA2(CONCAT_WS('|', rc.id, kb.embedding_model, kb.embedding_dimension), 256),
  NOW(),
  IF(kb.embedding IS NULL OR kb.embedding = '', 'pending', 'indexed')
FROM `rag_chunk` rc
JOIN `rag_document` rd ON rd.id = rc.document_id
JOIN `t_ai_knowledge_base` kb ON kb.id = rd.legacy_knowledge_base_id
WHERE NOT EXISTS (
  SELECT 1 FROM `rag_embedding` re
  WHERE re.chunk_id = rc.id
    AND re.embedding_model = COALESCE(kb.embedding_model, 'legacy-json')
    AND re.collection_name = 't_ai_knowledge_base'
);

SELECT
  (SELECT COUNT(*) FROM `question_content`) AS question_content_count,
  (SELECT COUNT(*) FROM `question_knowledge_point`) AS question_knowledge_point_count,
  (SELECT COUNT(*) FROM `rag_document`) AS rag_document_count,
  (SELECT COUNT(*) FROM `rag_chunk`) AS rag_chunk_count;
