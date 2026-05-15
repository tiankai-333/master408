-- ============================================
-- 修改表结构以支持简答题
-- ============================================

USE xzs;

-- 1. 修改 correct_answer 字段类型为 TEXT
ALTER TABLE `t_question` 
MODIFY COLUMN `correct_answer` TEXT NOT NULL COMMENT '正确答案（支持简答题）';

-- 2. 添加简答题相关字段（注意：TEXT字段不能有默认值）
ALTER TABLE `t_question` 
ADD COLUMN `answer_template` TEXT COMMENT '答题模板（用于简答题）',
ADD COLUMN `grading_criteria` TEXT COMMENT '评分标准';

-- 3. 更新字段注释
ALTER TABLE `t_question` 
MODIFY COLUMN `question_type` varchar(20) NOT NULL DEFAULT 'choice' COMMENT '题目类型 choice-选择题 multi_choice-多选题 essay-简答题 judge-判断题';

-- 4. 创建大题表（用于存储综合应用题）
CREATE TABLE IF NOT EXISTS `t_essay_question` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '大题ID',
  `subject_id` int NOT NULL COMMENT '学科ID',
  `year` int NOT NULL COMMENT '年份',
  `question_no` int NOT NULL COMMENT '大题号',
  `title` text NOT NULL COMMENT '题目内容',
  `sub_questions` text COMMENT '子问题 JSON格式',
  `total_score` int DEFAULT '10' COMMENT '总分',
  `answer` text COMMENT '参考答案',
  `analysis` text COMMENT '答案解析',
  `images` text COMMENT '图片路径',
  `status` int DEFAULT '1' COMMENT '状态',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_year` (`year`),
  KEY `idx_subject_id` (`subject_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='综合应用题表';

SELECT '表结构修改完成' AS message;
