-- ============================================================
-- 07_demo_student_learning_data.sql
-- 231310423 测试账号默认学习记录
--
-- 目的：
-- 1. 新部署后，学生端首页 / AI 工作台能看到真实做题统计。
-- 2. 做题记录、错题本、学习状态不再是空数据。
-- 3. 数据只作用于测试账号 231310423，可重复执行。
-- ============================================================

SET NAMES utf8mb4;

SET @demo_user_id := (
  SELECT id FROM t_user WHERE user_name = '231310423' AND deleted = b'0' LIMIT 1
);

DELETE FROM t_exam_paper_question_customer_answer
WHERE create_user = @demo_user_id
  AND exam_paper_answer_id IN (
    SELECT id FROM t_exam_paper_answer
    WHERE create_user = @demo_user_id
      AND paper_name = '408Master 默认学习画像演示记录'
  );

DELETE FROM t_exam_paper_answer
WHERE create_user = @demo_user_id
  AND paper_name = '408Master 默认学习画像演示记录';

INSERT INTO t_exam_paper_answer
  (exam_paper_id, paper_name, paper_type, subject_id, system_score, user_score,
   paper_score, question_correct, question_count, do_time, status, create_user, create_time)
SELECT
  (SELECT id FROM t_exam_paper WHERE source_year = 2024 ORDER BY id DESC LIMIT 1),
  '408Master 默认学习画像演示记录',
  1,
  5,
  1200,
  1200,
  1500,
  16,
  20,
  4200,
  2,
  @demo_user_id,
  NOW()
WHERE @demo_user_id IS NOT NULL;

SET @demo_answer_id := LAST_INSERT_ID();

INSERT INTO t_exam_paper_question_customer_answer
  (question_id, exam_paper_id, exam_paper_answer_id, question_type, subject_id,
   customer_score, question_score, question_text_content_id, answer, text_content_id,
   do_right, create_user, create_time, item_order)
SELECT q.id,
       (SELECT id FROM t_exam_paper WHERE source_year = 2024 ORDER BY id DESC LIMIT 1),
       @demo_answer_id,
       q.question_type,
       q.subject_id,
       IF(MOD(q.id, 5) = 0, 0, q.score),
       q.score,
       q.info_text_content_id,
       IF(MOD(q.id, 5) = 0, 'A', q.correct),
       NULL,
       IF(MOD(q.id, 5) = 0, b'0', b'1'),
       @demo_user_id,
       NOW(),
       q.id
FROM (
  SELECT * FROM t_question WHERE deleted = b'0' AND subject_id = 1 ORDER BY id LIMIT 5
) q
WHERE @demo_user_id IS NOT NULL AND @demo_answer_id > 0;

INSERT INTO t_exam_paper_question_customer_answer
  (question_id, exam_paper_id, exam_paper_answer_id, question_type, subject_id,
   customer_score, question_score, question_text_content_id, answer, text_content_id,
   do_right, create_user, create_time, item_order)
SELECT q.id,
       (SELECT id FROM t_exam_paper WHERE source_year = 2024 ORDER BY id DESC LIMIT 1),
       @demo_answer_id,
       q.question_type,
       q.subject_id,
       IF(MOD(q.id, 7) = 0, 0, q.score),
       q.score,
       q.info_text_content_id,
       IF(MOD(q.id, 7) = 0, 'A', q.correct),
       NULL,
       IF(MOD(q.id, 7) = 0, b'0', b'1'),
       @demo_user_id,
       NOW(),
       q.id
FROM (
  SELECT * FROM t_question WHERE deleted = b'0' AND subject_id = 2 ORDER BY id LIMIT 5
) q
WHERE @demo_user_id IS NOT NULL AND @demo_answer_id > 0;

INSERT INTO t_exam_paper_question_customer_answer
  (question_id, exam_paper_id, exam_paper_answer_id, question_type, subject_id,
   customer_score, question_score, question_text_content_id, answer, text_content_id,
   do_right, create_user, create_time, item_order)
SELECT q.id,
       (SELECT id FROM t_exam_paper WHERE source_year = 2024 ORDER BY id DESC LIMIT 1),
       @demo_answer_id,
       q.question_type,
       q.subject_id,
       IF(MOD(q.id, 6) = 0, 0, q.score),
       q.score,
       q.info_text_content_id,
       IF(MOD(q.id, 6) = 0, 'A', q.correct),
       NULL,
       IF(MOD(q.id, 6) = 0, b'0', b'1'),
       @demo_user_id,
       NOW(),
       q.id
FROM (
  SELECT * FROM t_question WHERE deleted = b'0' AND subject_id = 3 ORDER BY id LIMIT 5
) q
WHERE @demo_user_id IS NOT NULL AND @demo_answer_id > 0;

INSERT INTO t_exam_paper_question_customer_answer
  (question_id, exam_paper_id, exam_paper_answer_id, question_type, subject_id,
   customer_score, question_score, question_text_content_id, answer, text_content_id,
   do_right, create_user, create_time, item_order)
SELECT q.id,
       (SELECT id FROM t_exam_paper WHERE source_year = 2024 ORDER BY id DESC LIMIT 1),
       @demo_answer_id,
       q.question_type,
       q.subject_id,
       IF(MOD(q.id, 8) = 0, 0, q.score),
       q.score,
       q.info_text_content_id,
       IF(MOD(q.id, 8) = 0, 'A', q.correct),
       NULL,
       IF(MOD(q.id, 8) = 0, b'0', b'1'),
       @demo_user_id,
       NOW(),
       q.id
FROM (
  SELECT * FROM t_question WHERE deleted = b'0' AND subject_id = 4 ORDER BY id LIMIT 5
) q
WHERE @demo_user_id IS NOT NULL AND @demo_answer_id > 0;

SELECT 'demo learning data ready for 231310423' AS status;
