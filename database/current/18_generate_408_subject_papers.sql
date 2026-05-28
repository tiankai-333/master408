-- Generate fixed 408 single-subject practice papers from existing 408 real questions.
-- Re-runnable: only papers with these generated names are replaced.

SET SESSION group_concat_max_len = 1048576;
SET @import_408_subject_papers_started_at = NOW();

DROP TEMPORARY TABLE IF EXISTS tmp_408_subject_paper_def;
CREATE TEMPORARY TABLE tmp_408_subject_paper_def (
  def_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  subject_id INT NOT NULL,
  seq_no INT NOT NULL,
  target_year INT NOT NULL,
  paper_name VARCHAR(255) NOT NULL
);

INSERT INTO tmp_408_subject_paper_def (subject_id, seq_no, target_year, paper_name) VALUES
  (1, 1, 2024, '近年408数据结构专项卷 01'),
  (1, 2, 2023, '近年408数据结构专项卷 02'),
  (1, 3, 2022, '近年408数据结构专项卷 03'),
  (2, 1, 2024, '近年408计算机组成原理专项卷 01'),
  (2, 2, 2023, '近年408计算机组成原理专项卷 02'),
  (2, 3, 2022, '近年408计算机组成原理专项卷 03'),
  (3, 1, 2024, '近年408操作系统专项卷 01'),
  (3, 2, 2023, '近年408操作系统专项卷 02'),
  (3, 3, 2022, '近年408操作系统专项卷 03'),
  (4, 1, 2024, '近年408计算机网络专项卷 01'),
  (4, 2, 2023, '近年408计算机网络专项卷 02'),
  (4, 3, 2022, '近年408计算机网络专项卷 03');

DROP TEMPORARY TABLE IF EXISTS tmp_408_subject_old_papers;
CREATE TEMPORARY TABLE tmp_408_subject_old_papers AS
  SELECT ep.id, ep.frame_text_content_id
  FROM t_exam_paper ep
  JOIN tmp_408_subject_paper_def d ON d.paper_name = ep.name
  WHERE ep.subject_id IN (1, 2, 3, 4);

DELETE FROM t_exam_paper
WHERE id IN (SELECT id FROM tmp_408_subject_old_papers);

DELETE FROM t_text_content
WHERE id IN (
  SELECT frame_text_content_id
  FROM tmp_408_subject_old_papers
  WHERE frame_text_content_id IS NOT NULL
);

DROP TEMPORARY TABLE IF EXISTS tmp_408_subject_paper_questions;
CREATE TEMPORARY TABLE tmp_408_subject_paper_questions AS
  SELECT *
  FROM (
    SELECT
      d.def_id,
      q.id AS question_id,
      q.score,
      ROW_NUMBER() OVER (
        PARTITION BY d.def_id
        ORDER BY
          CASE WHEN q.source_year = d.target_year THEN 0 ELSE 1 END,
          q.source_year DESC,
          q.source_question_no ASC,
          q.id ASC
      ) AS item_order
    FROM tmp_408_subject_paper_def d
    JOIN t_question q ON q.subject_id = d.subject_id
    WHERE q.deleted = 0
      AND q.source_year IS NOT NULL
      AND q.source_year <= d.target_year
      AND q.source_year >= 2011
      AND (q.source LIKE '%408%' OR q.source IS NULL)
  ) ranked
  WHERE item_order <= 18;

DROP TEMPORARY TABLE IF EXISTS tmp_408_subject_paper_frame;
CREATE TEMPORARY TABLE tmp_408_subject_paper_frame AS
  SELECT
    d.def_id,
    d.subject_id,
    d.target_year,
    d.paper_name,
    COUNT(q.question_id) AS question_count,
    COALESCE(SUM(q.score), 0) AS score,
    CONCAT(
      '[{"name":',
      JSON_QUOTE(d.paper_name),
      ',"questionItems":[',
      GROUP_CONCAT(
        CONCAT('{"id":', q.question_id, ',"itemOrder":', q.item_order, '}')
        ORDER BY q.item_order
        SEPARATOR ','
      ),
      ']}]'
    ) AS frame_content
  FROM tmp_408_subject_paper_def d
  JOIN tmp_408_subject_paper_questions q ON q.def_id = d.def_id
  GROUP BY d.def_id, d.subject_id, d.target_year, d.paper_name;

INSERT INTO t_text_content (content, create_time)
SELECT frame_content, @import_408_subject_papers_started_at
FROM tmp_408_subject_paper_frame
WHERE question_count > 0;

INSERT INTO t_exam_paper (
  name, subject_id, paper_type, grade_level, score, question_count,
  suggest_time, frame_text_content_id, create_user, create_time,
  deleted, source_year, description
)
SELECT
  f.paper_name,
  f.subject_id,
  1,
  1,
  f.score,
  f.question_count,
  60,
  tc.id,
  1,
  @import_408_subject_papers_started_at,
  b'0',
  f.target_year,
  '由近年408真题按精确单科自动生成的专项练习卷'
FROM tmp_408_subject_paper_frame f
JOIN t_text_content tc
  ON tc.content = f.frame_content
  AND tc.create_time = @import_408_subject_papers_started_at
WHERE f.question_count > 0;

SELECT
  f.subject_id,
  COUNT(*) AS generated_papers,
  MIN(f.question_count) AS min_questions,
  MAX(f.question_count) AS max_questions
FROM tmp_408_subject_paper_frame f
GROUP BY f.subject_id
ORDER BY f.subject_id;
