-- Create a virtual top-level knowledge point for each non-408 subject
-- and associate all questions of that subject with its virtual knowledge point.

SET NAMES utf8mb4;
START TRANSACTION;

-- 1. Insert virtual knowledge points (parent_id = NULL, level = 1)
INSERT INTO knowledge_point (name, subject_id, parent_id, description, level, sort_order)
VALUES
  ('数学一', 6, NULL, '数学一全科', 1, 1),
  ('数学二', 7, NULL, '数学二全科', 1, 1),
  ('数学三', 8, NULL, '数学三全科', 1, 1),
  ('英语一', 9, NULL, '英语一全科', 1, 1),
  ('英语二', 10, NULL, '英语二全科', 1, 1),
  ('思想政治理论', 11, NULL, '思想政治理论全科', 1, 1);

-- 2. Associate all questions with their subject's virtual knowledge point
-- Using INSERT IGNORE to skip duplicates
INSERT IGNORE INTO question_knowledge_point (question_id, knowledge_point_id, relevance)
SELECT q.id, kp.id, 1.00
FROM t_question q
JOIN knowledge_point kp ON kp.subject_id = q.subject_id
WHERE q.subject_id IN (6, 7, 8, 9, 10, 11)
  AND kp.parent_id IS NULL
  AND kp.level = 1;

-- 3. Create knowledge_content entries so the detail view works
INSERT INTO knowledge_content (knowledge_point_id, html_ref, summary_text, source_url)
SELECT kp.id,
  CONCAT('knowledge-html/subject/', LOWER(REPLACE(kp.name, ' ', '-')), '/index.html'),
  CONCAT(kp.name, ' 全科知识点概览。'),
  NULL
FROM knowledge_point kp
WHERE kp.subject_id IN (6, 7, 8, 9, 10, 11)
  AND kp.parent_id IS NULL
  AND kp.level = 1
  AND NOT EXISTS (
    SELECT 1 FROM knowledge_content kc WHERE kc.knowledge_point_id = kp.id
  );
