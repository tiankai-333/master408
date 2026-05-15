-- ============================================
-- 试卷SQL (3) - 2011-2024年408真题试卷
-- 包含题目分数配置（选择题每题2分，总分100分）
-- ============================================

USE xzs;

-- 开始插入试卷数据
START TRANSACTION;

-- ============================================
-- 2011年真题试卷
-- ============================================
INSERT INTO `t_exam_paper` (`name`, `subject_id`, `paper_type`, `source_year`, `total_score`, `pass_score`, `duration`, `question_count`, `description`, `difficulty`, `status`) VALUES
('2011年全国硕士研究生招生考试计算机学科专业基础联考真题', 1, 'year_paper', 2011, 100, 60, 120, 44, '2011年计算机学科专业基础综合考试真题，包含选择题44道。', 2, 1);

-- 数据结构 (1-11题)
INSERT INTO `t_exam_paper_question` (`exam_paper_id`, `question_id`, `question_no`, `score`) 
SELECT 1, id, source_question_no, 2 FROM `t_question` WHERE source = '2011年数据结构真题' AND source_question_no BETWEEN 1 AND 11;

-- 计算机组成原理 (12-22题)
INSERT INTO `t_exam_paper_question` (`exam_paper_id`, `question_id`, `question_no`, `score`) 
SELECT 1, id, source_question_no, 2 FROM `t_question` WHERE source = '2011年计算机组成原理真题' AND source_question_no BETWEEN 12 AND 22;

-- 操作系统 (23-32题)
INSERT INTO `t_exam_paper_question` (`exam_paper_id`, `question_id`, `question_no`, `score`) 
SELECT 1, id, source_question_no, 2 FROM `t_question` WHERE source = '2011年操作系统真题' AND source_question_no BETWEEN 23 AND 32;

-- 计算机网络 (33-40题)
INSERT INTO `t_exam_paper_question` (`exam_paper_id`, `question_id`, `question_no`, `score`) 
SELECT 1, id, source_question_no, 2 FROM `t_question` WHERE source = '2011年计算机网络真题' AND source_question_no BETWEEN 33 AND 40;

-- ============================================
-- 2012年真题试卷
-- ============================================
INSERT INTO `t_exam_paper` (`name`, `subject_id`, `paper_type`, `source_year`, `total_score`, `pass_score`, `duration`, `question_count`, `description`, `difficulty`, `status`) VALUES
('2012年全国硕士研究生招生考试计算机学科专业基础联考真题', 1, 'year_paper', 2012, 100, 60, 120, 40, '2012年计算机学科专业基础综合考试真题，包含选择题40道。', 2, 1);

INSERT INTO `t_exam_paper_question` (`exam_paper_id`, `question_id`, `question_no`, `score`) 
SELECT 2, id, source_question_no, 2 FROM `t_question` WHERE source_year = 2012;

-- ============================================
-- 2013年真题试卷
-- ============================================
INSERT INTO `t_exam_paper` (`name`, `subject_id`, `paper_type`, `source_year`, `total_score`, `pass_score`, `duration`, `question_count`, `description`, `difficulty`, `status`) VALUES
('2013年全国硕士研究生招生考试计算机学科专业基础联考真题', 1, 'year_paper', 2013, 100, 60, 120, 40, '2013年计算机学科专业基础综合考试真题，包含选择题40道。', 2, 1);

INSERT INTO `t_exam_paper_question` (`exam_paper_id`, `question_id`, `question_no`, `score`) 
SELECT 3, id, source_question_no, 2 FROM `t_question` WHERE source_year = 2013;

-- ============================================
-- 2014年真题试卷
-- ============================================
INSERT INTO `t_exam_paper` (`name`, `subject_id`, `paper_type`, `source_year`, `total_score`, `pass_score`, `duration`, `question_count`, `description`, `difficulty`, `status`) VALUES
('2014年全国硕士研究生招生考试计算机学科专业基础联考真题', 1, 'year_paper', 2014, 100, 60, 120, 40, '2014年计算机学科专业基础综合考试真题，包含选择题40道。', 2, 1);

INSERT INTO `t_exam_paper_question` (`exam_paper_id`, `question_id`, `question_no`, `score`) 
SELECT 4, id, source_question_no, 2 FROM `t_question` WHERE source_year = 2014;

-- ============================================
-- 2015年真题试卷
-- ============================================
INSERT INTO `t_exam_paper` (`name`, `subject_id`, `paper_type`, `source_year`, `total_score`, `pass_score`, `duration`, `question_count`, `description`, `difficulty`, `status`) VALUES
('2015年全国硕士研究生招生考试计算机学科专业基础联考真题', 1, 'year_paper', 2015, 100, 60, 120, 40, '2015年计算机学科专业基础综合考试真题，包含选择题40道。', 2, 1);

INSERT INTO `t_exam_paper_question` (`exam_paper_id`, `question_id`, `question_no`, `score`) 
SELECT 5, id, source_question_no, 2 FROM `t_question` WHERE source_year = 2015;

-- ============================================
-- 2016年真题试卷
-- ============================================
INSERT INTO `t_exam_paper` (`name`, `subject_id`, `paper_type`, `source_year`, `total_score`, `pass_score`, `duration`, `question_count`, `description`, `difficulty`, `status`) VALUES
('2016年全国硕士研究生招生考试计算机学科专业基础联考真题', 1, 'year_paper', 2016, 100, 60, 120, 40, '2016年计算机学科专业基础综合考试真题，包含选择题40道。', 2, 1);

INSERT INTO `t_exam_paper_question` (`exam_paper_id`, `question_id`, `question_no`, `score`) 
SELECT 6, id, source_question_no, 2 FROM `t_question` WHERE source_year = 2016;

-- ============================================
-- 2017年真题试卷
-- ============================================
INSERT INTO `t_exam_paper` (`name`, `subject_id`, `paper_type`, `source_year`, `total_score`, `pass_score`, `duration`, `question_count`, `description`, `difficulty`, `status`) VALUES
('2017年全国硕士研究生招生考试计算机学科专业基础联考真题', 1, 'year_paper', 2017, 100, 60, 120, 40, '2017年计算机学科专业基础综合考试真题，包含选择题40道。', 2, 1);

INSERT INTO `t_exam_paper_question` (`exam_paper_id`, `question_id`, `question_no`, `score`) 
SELECT 7, id, source_question_no, 2 FROM `t_question` WHERE source_year = 2017;

-- ============================================
-- 2018年真题试卷
-- ============================================
INSERT INTO `t_exam_paper` (`name`, `subject_id`, `paper_type`, `source_year`, `total_score`, `pass_score`, `duration`, `question_count`, `description`, `difficulty`, `status`) VALUES
('2018年全国硕士研究生招生考试计算机学科专业基础联考真题', 1, 'year_paper', 2018, 100, 60, 120, 40, '2018年计算机学科专业基础综合考试真题，包含选择题40道。', 2, 1);

INSERT INTO `t_exam_paper_question` (`exam_paper_id`, `question_id`, `question_no`, `score`) 
SELECT 8, id, source_question_no, 2 FROM `t_question` WHERE source_year = 2018;

-- ============================================
-- 2019年真题试卷
-- ============================================
INSERT INTO `t_exam_paper` (`name`, `subject_id`, `paper_type`, `source_year`, `total_score`, `pass_score`, `duration`, `question_count`, `description`, `difficulty`, `status`) VALUES
('2019年全国硕士研究生招生考试计算机学科专业基础联考真题', 1, 'year_paper', 2019, 100, 60, 120, 40, '2019年计算机学科专业基础综合考试真题，包含选择题40道。', 2, 1);

INSERT INTO `t_exam_paper_question` (`exam_paper_id`, `question_id`, `question_no`, `score`) 
SELECT 9, id, source_question_no, 2 FROM `t_question` WHERE source_year = 2019;

-- ============================================
-- 2020年真题试卷
-- ============================================
INSERT INTO `t_exam_paper` (`name`, `subject_id`, `paper_type`, `source_year`, `total_score`, `pass_score`, `duration`, `question_count`, `description`, `difficulty`, `status`) VALUES
('2020年全国硕士研究生招生考试计算机学科专业基础联考真题', 1, 'year_paper', 2020, 100, 60, 120, 40, '2020年计算机学科专业基础综合考试真题，包含选择题40道。', 2, 1);

INSERT INTO `t_exam_paper_question` (`exam_paper_id`, `question_id`, `question_no`, `score`) 
SELECT 10, id, source_question_no, 2 FROM `t_question` WHERE source_year = 2020;

-- ============================================
-- 2021年真题试卷
-- ============================================
INSERT INTO `t_exam_paper` (`name`, `subject_id`, `paper_type`, `source_year`, `total_score`, `pass_score`, `duration`, `question_count`, `description`, `difficulty`, `status`) VALUES
('2021年全国硕士研究生招生考试计算机学科专业基础联考真题', 1, 'year_paper', 2021, 100, 60, 120, 40, '2021年计算机学科专业基础综合考试真题，包含选择题40道。', 2, 1);

INSERT INTO `t_exam_paper_question` (`exam_paper_id`, `question_id`, `question_no`, `score`) 
SELECT 11, id, source_question_no, 2 FROM `t_question` WHERE source_year = 2021;

-- ============================================
-- 2022年真题试卷
-- ============================================
INSERT INTO `t_exam_paper` (`name`, `subject_id`, `paper_type`, `source_year`, `total_score`, `pass_score`, `duration`, `question_count`, `description`, `difficulty`, `status`) VALUES
('2022年全国硕士研究生招生考试计算机学科专业基础联考真题', 1, 'year_paper', 2022, 100, 60, 120, 40, '2022年计算机学科专业基础综合考试真题，包含选择题40道。', 2, 1);

INSERT INTO `t_exam_paper_question` (`exam_paper_id`, `question_id`, `question_no`, `score`) 
SELECT 12, id, source_question_no, 2 FROM `t_question` WHERE source_year = 2022;

-- ============================================
-- 2023年真题试卷
-- ============================================
INSERT INTO `t_exam_paper` (`name`, `subject_id`, `paper_type`, `source_year`, `total_score`, `pass_score`, `duration`, `question_count`, `description`, `difficulty`, `status`) VALUES
('2023年全国硕士研究生招生考试计算机学科专业基础联考真题', 1, 'year_paper', 2023, 100, 60, 120, 40, '2023年计算机学科专业基础综合考试真题，包含选择题40道。', 2, 1);

INSERT INTO `t_exam_paper_question` (`exam_paper_id`, `question_id`, `question_no`, `score`) 
SELECT 13, id, source_question_no, 2 FROM `t_question` WHERE source_year = 2023;

-- ============================================
-- 2024年真题试卷
-- ============================================
INSERT INTO `t_exam_paper` (`name`, `subject_id`, `paper_type`, `source_year`, `total_score`, `pass_score`, `duration`, `question_count`, `description`, `difficulty`, `status`) VALUES
('2024年全国硕士研究生招生考试计算机学科专业基础联考真题', 1, 'year_paper', 2024, 100, 60, 120, 44, '2024年计算机学科专业基础综合考试真题，包含选择题44道。', 2, 1);

INSERT INTO `t_exam_paper_question` (`exam_paper_id`, `question_id`, `question_no`, `score`) 
SELECT 14, id, source_question_no, 2 FROM `t_question` WHERE source_year = 2024;

COMMIT;

-- 更新试卷题目数量
UPDATE `t_exam_paper` ep SET question_count = (
    SELECT COUNT(*) FROM `t_exam_paper_question` epq WHERE epq.exam_paper_id = ep.id
);
