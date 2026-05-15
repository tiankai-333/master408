-- ============================================
-- 学生模拟做题数据SQL (4)
-- 学生: 231310423, 密码: 123456
-- 生成模拟考试记录和答题数据
-- ============================================

USE xzs;

START TRANSACTION;

-- ============================================
-- 1. 创建学生用户
-- ============================================
INSERT INTO `t_user` (`username`, `password`, `real_name`, `phone`, `email`, `school`, `major`, `grade`, `class_name`, `gender`, `status`, `role`) VALUES
('231310423', '123456', '学生用户', '13812310423', '231310423@example.com', '某某大学', '计算机科学与技术', '2023级', '计算机1班', '男', 1, 'student');

-- 获取学生用户ID
SET @student_id = LAST_INSERT_ID();

-- ============================================
-- 2. 插入模拟考试记录
-- ============================================

-- 考试记录1: 2011年真题
INSERT INTO `t_exam_record` (`exam_paper_id`, `user_id`, `score`, `total_score`, `correct_count`, `total_count`, `duration`, `score_rate`, `status`, `start_time`, `submit_time`) VALUES
(1, @student_id, 72, 100, 36, 44, 95, 72.00, 'completed', DATE_SUB(NOW(), INTERVAL 30 DAY), DATE_SUB(NOW(), INTERVAL 29 DAY));

SET @record_id_2011 = LAST_INSERT_ID();

-- 考试记录2: 2012年真题
INSERT INTO `t_exam_record` (`exam_paper_id`, `user_id`, `score`, `total_score`, `correct_count`, `total_count`, `duration`, `score_rate`, `status`, `start_time`, `submit_time`) VALUES
(2, @student_id, 80, 100, 40, 40, 85, 80.00, 'completed', DATE_SUB(NOW(), INTERVAL 25 DAY), DATE_SUB(NOW(), INTERVAL 24 DAY));

SET @record_id_2012 = LAST_INSERT_ID();

-- 考试记录3: 2013年真题
INSERT INTO `t_exam_record` (`exam_paper_id`, `user_id`, `score`, `total_score`, `correct_count`, `total_count`, `duration`, `score_rate`, `status`, `start_time`, `submit_time`) VALUES
(3, @student_id, 66, 100, 33, 40, 100, 66.00, 'completed', DATE_SUB(NOW(), INTERVAL 20 DAY), DATE_SUB(NOW(), INTERVAL 19 DAY));

SET @record_id_2013 = LAST_INSERT_ID();

-- 考试记录4: 2014年真题
INSERT INTO `t_exam_record` (`exam_paper_id`, `user_id`, `score`, `total_score`, `correct_count`, `total_count`, `duration`, `score_rate`, `status`, `start_time`, `submit_time`) VALUES
(4, @student_id, 78, 100, 39, 40, 88, 78.00, 'completed', DATE_SUB(NOW(), INTERVAL 15 DAY), DATE_SUB(NOW(), INTERVAL 14 DAY));

SET @record_id_2014 = LAST_INSERT_ID();

-- 考试记录5: 2015年真题
INSERT INTO `t_exam_record` (`exam_paper_id`, `user_id`, `score`, `total_score`, `correct_count`, `total_count`, `duration`, `score_rate`, `status`, `start_time`, `submit_time`) VALUES
(5, @student_id, 84, 100, 42, 40, 90, 84.00, 'completed', DATE_SUB(NOW(), INTERVAL 10 DAY), DATE_SUB(NOW(), INTERVAL 9 DAY));

SET @record_id_2015 = LAST_INSERT_ID();

-- ============================================
-- 3. 生成答题记录
-- 为每次考试生成随机但合理的答题记录
-- ============================================

-- 2011年真题答题记录 (36/44正确 = 72分)
INSERT INTO `t_student_answer` (`exam_paper_id`, `question_id`, `user_id`, `answer`, `correct_answer`, `is_correct`, `score`, `answer_time`, `create_time`)
SELECT 
    1 AS exam_paper_id,
    q.id AS question_id,
    @student_id AS user_id,
    CASE 
        WHEN RAND() < 0.82 THEN q.correct_answer  -- 82%正确率
        ELSE ELT(FLOOR(1 + RAND() * 4), 'A', 'B', 'C', 'D')
    END AS answer,
    q.correct_answer,
    CASE WHEN RAND() < 0.82 THEN 1 ELSE 0 END AS is_correct,
    CASE WHEN RAND() < 0.82 THEN 2 ELSE 0 END AS score,
    FLOOR(30 + RAND() * 60) AS answer_time,  -- 每题30-90秒
    DATE_SUB(NOW(), INTERVAL 30 DAY) AS create_time
FROM `t_question` q
WHERE q.source_year = 2011;

-- 2012年真题答题记录 (40/40正确 = 80分，满分)
INSERT INTO `t_student_answer` (`exam_paper_id`, `question_id`, `user_id`, `answer`, `correct_answer`, `is_correct`, `score`, `answer_time`, `create_time`)
SELECT 
    2 AS exam_paper_id,
    q.id AS question_id,
    @student_id AS user_id,
    q.correct_answer,  -- 全部正确
    q.correct_answer,
    1 AS is_correct,
    2 AS score,
    FLOOR(25 + RAND() * 50) AS answer_time,
    DATE_SUB(NOW(), INTERVAL 25 DAY)
FROM `t_question` q
WHERE q.source_year = 2012;

-- 2013年真题答题记录 (33/40正确 = 66分)
INSERT INTO `t_student_answer` (`exam_paper_id`, `question_id`, `user_id`, `answer`, `correct_answer`, `is_correct`, `score`, `answer_time`, `create_time`)
SELECT 
    3 AS exam_paper_id,
    q.id AS question_id,
    @student_id AS user_id,
    CASE 
        WHEN RAND() < 0.825 THEN q.correct_answer  -- 82.5%正确率
        ELSE ELT(FLOOR(1 + RAND() * 4), 'A', 'B', 'C', 'D')
    END AS answer,
    q.correct_answer,
    CASE WHEN RAND() < 0.825 THEN 1 ELSE 0 END AS is_correct,
    CASE WHEN RAND() < 0.825 THEN 2 ELSE 0 END AS score,
    FLOOR(35 + RAND() * 55) AS answer_time,
    DATE_SUB(NOW(), INTERVAL 20 DAY)
FROM `t_question` q
WHERE q.source_year = 2013;

-- 2014年真题答题记录 (39/40正确 = 78分)
INSERT INTO `t_student_answer` (`exam_paper_id`, `question_id`, `user_id`, `answer`, `correct_answer`, `is_correct`, `score`, `answer_time`, `create_time`)
SELECT 
    4 AS exam_paper_id,
    q.id AS question_id,
    @student_id AS user_id,
    CASE 
        WHEN RAND() < 0.975 THEN q.correct_answer  -- 97.5%正确率
        ELSE ELT(FLOOR(1 + RAND() * 4), 'A', 'B', 'C', 'D')
    END AS answer,
    q.correct_answer,
    CASE WHEN RAND() < 0.975 THEN 1 ELSE 0 END AS is_correct,
    CASE WHEN RAND() < 0.975 THEN 2 ELSE 0 END AS score,
    FLOOR(28 + RAND() * 52) AS answer_time,
    DATE_SUB(NOW(), INTERVAL 15 DAY)
FROM `t_question` q
WHERE q.source_year = 2014;

-- 2015年真题答题记录 (42/40正确 = 84分，满分)
INSERT INTO `t_student_answer` (`exam_paper_id`, `question_id`, `user_id`, `answer`, `correct_answer`, `is_correct`, `score`, `answer_time`, `create_time`)
SELECT 
    5 AS exam_paper_id,
    q.id AS question_id,
    @student_id AS user_id,
    q.correct_answer,  -- 全部正确
    q.correct_answer,
    1 AS is_correct,
    2 AS score,
    FLOOR(22 + RAND() * 48) AS answer_time,
    DATE_SUB(NOW(), INTERVAL 10 DAY)
FROM `t_question` q
WHERE q.source_year = 2015;

-- ============================================
-- 4. 更新题目统计数据
-- ============================================
UPDATE `t_question` q 
SET 
    q.total_count = q.total_count + (
        SELECT COUNT(*) FROM `t_student_answer` sa WHERE sa.question_id = q.id
    ),
    q.correct_count = q.correct_count + (
        SELECT COUNT(*) FROM `t_student_answer` sa WHERE sa.question_id = q.id AND sa.is_correct = 1
    ),
    q.error_count = q.error_count + (
        SELECT COUNT(*) FROM `t_student_answer` sa WHERE sa.question_id = q.id AND sa.is_correct = 0
    ),
    q.avg_score = IFNULL(
        (SELECT AVG(sa.score * 1.0) FROM `t_student_answer` sa WHERE sa.question_id = q.id),
        0
    );

-- ============================================
-- 5. 更新试卷统计信息
-- ============================================
UPDATE `t_exam_paper` ep
SET 
    ep.total_count = ep.total_count + 1,
    ep.avg_score = (
        SELECT AVG(er.score) FROM `t_exam_record` er WHERE er.exam_paper_id = ep.id
    ),
    ep.max_score = GREATEST(ep.max_score, (
        SELECT MAX(er.score) FROM `t_exam_record` er WHERE er.exam_paper_id = ep.id
    )),
    ep.min_score = LEAST(IF(ep.min_score = 0, 100, ep.min_score), (
        SELECT MIN(er.score) FROM `t_exam_record` er WHERE er.exam_paper_id = ep.id
    ))
WHERE ep.id IN (1, 2, 3, 4, 5);

COMMIT;

-- ============================================
-- 数据生成完成
-- ============================================
SELECT '学生用户创建完成' AS message;
SELECT @student_id AS student_id;
SELECT '考试记录生成完成' AS message;
SELECT '答题记录生成完成' AS message;
