
-- ============================================================
-- NPE 测试数据构造脚本
-- 用途：覆盖 QuestionAnswerController、ExamPaperAnswerController、
--       ExamUtil 中共 10 处 NPE 风险点
-- 用户：user_id=4 (231310423)
-- 
-- 执行前请确认后端在 debug 模式运行以观察日志
-- 执行后访问：
--   http://localhost:8001/question-error/index  (错题本)
--   http://localhost:8001/record/index           (考试记录)
-- 
-- 恢复：执行脚本末尾的 DELETE 语句即可清理测试数据
-- ============================================================

-- ============================================================
-- 场景 ①：subject_id = NULL  →  subject.getName() NPE
-- 影响文件：QuestionAnswerController.java L48→L55
--           ExamPaperAnswerController.java(student) L52→L57
--           ExamPaperAnswerController.java(admin) L39→L44
-- 状态：★ 已有数据（所有 51 条 customer_answer + 1 条 exam_paper_answer
--        的 subject_id 均为 NULL）
-- 说明：现有数据即可复现，无需新增。以下为确认查询。
-- ============================================================
SELECT '--- 场景①: subject_id=NULL 的已有记录 ---' AS '';
SELECT COUNT(*) AS 'subject_id为NULL的答题记录'
FROM t_exam_paper_question_customer_answer
WHERE subject_id IS NULL;

SELECT COUNT(*) AS 'subject_id为NULL的考试记录'
FROM t_exam_paper_answer
WHERE subject_id IS NULL;

-- ============================================================
-- 场景 ②：question_text_content_id 指向不存在的 TextContent
-- 影响文件：QuestionAnswerController.java L51→L52
-- 触发条件：textContent = textContentService.selectById(99999) → null
--           → textContent.getContent() NPE
-- ============================================================
INSERT INTO t_exam_paper_question_customer_answer (
    question_id, exam_paper_id, exam_paper_answer_id,
    question_type, subject_id, customer_score, question_score,
    question_text_content_id, answer, text_content_id,
    do_right, create_user, create_time, item_order
) VALUES (
    1, 1, 1,
    1, 1, 5, 10,
    99999, 'A', NULL,
    0, 4, NOW(), 100
);
SELECT '--- 场景②: 已插入 TextContent 悬空记录 (id=' AS '', LAST_INSERT_ID() AS '';

-- ============================================================
-- 场景 ③：TextContent 内容为非法 JSON → JSON 解析失败
-- 影响文件：QuestionAnswerController.java L52→L53
-- 触发条件：JsonUtil.toJsonObject("这不是JSON", QuestionObject.class)
--           → questionObject 为 null/异常 → getTitleContent() NPE
-- ============================================================
INSERT INTO t_text_content (id, content, create_time)
VALUES (99001, '这是一段非法的JSON内容，无法被解析为QuestionObject', NOW());

INSERT INTO t_exam_paper_question_customer_answer (
    question_id, exam_paper_id, exam_paper_answer_id,
    question_type, subject_id, customer_score, question_score,
    question_text_content_id, answer, text_content_id,
    do_right, create_user, create_time, item_order
) VALUES (
    1, 1, 1,
    1, 1, 5, 10,
    99001, 'A', NULL,
    0, 4, NOW(), 101
);
SELECT '--- 场景③: 已插入非法JSON记录 (id=' AS '', LAST_INSERT_ID() AS '';

-- ============================================================
-- 场景 ④：question_id 指向已删除/不存在的题目
-- 影响文件：QuestionAnswerController.java L67 select 方法
-- 触发条件：questionService.getQuestionEditRequestVM(99999)
--           → questionMapper.selectByPrimaryKey(99999) → null → NPE
-- ============================================================
INSERT INTO t_exam_paper_question_customer_answer (
    question_id, exam_paper_id, exam_paper_answer_id,
    question_type, subject_id, customer_score, question_score,
    question_text_content_id, answer, text_content_id,
    do_right, create_user, create_time, item_order
) VALUES (
    99999, 1, 1,
    1, 1, 5, 10,
    573, 'A', NULL,
    0, 4, NOW(), 102
);
SELECT '--- 场景④: 已插入题目悬空记录 (id=' AS '', LAST_INSERT_ID() AS '';

-- ============================================================
-- 场景 ⑤：exam_paper_answer 的 subject_id = NULL
-- 影响文件：ExamPaperAnswerController.java(student) L52→L57
-- 状态：★ 已有数据（id=1 的 subject_id 为 NULL）
-- ============================================================
SELECT '--- 场景⑤: 考试记录 subject_id=NULL 确认 ---' AS '';
SELECT id, subject_id, paper_name FROM t_exam_paper_answer WHERE id=1;

-- ============================================================
-- 场景 ⑥⑦：scores/do_time 为 NULL
-- 影响文件：ExamUtil.java L23 scoreToVM(null) → score % 10 NPE
--           ExamUtil.java L52 secondToVM(null) → second / (60*60*24) NPE
-- 调用方：  ExamPaperAnswerController(student) L53-56
-- ============================================================
INSERT INTO t_exam_paper_answer (
    exam_paper_id, paper_name, paper_type,
    subject_id, system_score, user_score, paper_score,
    question_correct, question_count, do_time,
    status, create_user, create_time, task_exam_id
) VALUES (
    1, 'NPE测试-分数为空-试卷', 1,
    NULL, NULL, NULL, NULL,
    0, 10, NULL,
    2, 4, NOW(), NULL
);
SELECT '--- 场景⑥⑦: 已插入分数/time为空的考试记录 (id=' AS '', LAST_INSERT_ID() AS '';

-- ============================================================
-- 场景 ⑧：admin 端 exam_paper_answer subject_id=NULL
-- 影响文件：ExamPaperAnswerController.java(admin) L39→L44
-- 状态：★ 与场景⑤共享数据，admin 端访问同样会 NPE
-- ============================================================

-- ============================================================
-- 场景 ⑨：create_user 指向已删除/不存在的用户
-- 影响文件：ExamPaperAnswerController.java(admin) L46→L47
-- 触发条件：userService.selectById(99999) → null → user.getUserName() NPE
-- ============================================================
INSERT INTO t_exam_paper_answer (
    exam_paper_id, paper_name, paper_type,
    subject_id, system_score, user_score, paper_score,
    question_correct, question_count, do_time,
    status, create_user, create_time, task_exam_id
) VALUES (
    1, 'NPE测试-用户悬空-试卷', 1,
    NULL, 60, 60, 100,
    5, 10, 3600,
    2, 99999, NOW(), NULL
);
SELECT '--- 场景⑨: 已插入用户悬空考试记录 (id=' AS '', LAST_INSERT_ID() AS '';

-- ============================================================
-- 场景 ⑩：select 方法 examPaperQuestionCustomerAnswer 为 null
-- 影响文件：QuestionAnswerController.java L65
-- 触发条件：调用 /select/99999 (不存在的答题记录 ID)
-- 说明：无需插入数据，直接请求不存在的 ID 即可验证
-- ============================================================

-- ============================================================
-- 汇总查询
-- ============================================================
SELECT '============= 测试数据汇总 =============' AS '';

SELECT '场景①' AS '场景', '已有数据' AS '来源', COUNT(*) AS '记录数',
    'subject_id=NULL → subject.getName() NPE' AS '预期错误'
FROM t_exam_paper_question_customer_answer WHERE subject_id IS NULL;

SELECT '场景②' AS '场景', '新增' AS '来源', COUNT(*) AS '记录数',
    'question_text_content_id=99999 → textContent.getContent() NPE' AS '预期错误'
FROM t_exam_paper_question_customer_answer WHERE question_text_content_id=99999;

SELECT '场景③' AS '场景', '新增' AS '来源', COUNT(*) AS '记录数',
    'text_content=非法JSON → questionObject.getTitleContent() NPE' AS '预期错误'
FROM t_exam_paper_question_customer_answer WHERE question_text_content_id=99001;

SELECT '场景④' AS '场景', '新增' AS '来源', COUNT(*) AS '记录数',
    'question_id=99999 → questionService返回null → NPE' AS '预期错误'
FROM t_exam_paper_question_customer_answer WHERE question_id=99999;

SELECT '场景⑤' AS '场景', '已有数据' AS '来源', COUNT(*) AS '记录数',
    '考试记录subject_id=NULL → subject.getName() NPE' AS '预期错误'
FROM t_exam_paper_answer WHERE subject_id IS NULL;

SELECT '场景⑥⑦' AS '场景', '新增' AS '来源', COUNT(*) AS '记录数',
    'scores/time=NULL → ExamUtil NPE' AS '预期错误'
FROM t_exam_paper_answer WHERE system_score IS NULL AND user_score IS NULL AND paper_score IS NULL AND do_time IS NULL;

SELECT '场景⑨' AS '场景', '新增' AS '来源', COUNT(*) AS '记录数',
    'create_user=99999 → user.getUserName() NPE (admin)' AS '预期错误'
FROM t_exam_paper_answer WHERE create_user=99999;

SELECT '========== 验证提示 ==========' AS '';
SELECT '1. 用 231310423 / 123456 登录学生端' AS '';
SELECT '2. 访问 http://localhost:8001/question-error/index  → 应报错（场景①②③触发）' AS '';
SELECT '3. 访问 http://localhost:8001/record/index           → 应报错（场景⑤⑥⑦触发）' AS '';
SELECT '4. 用 admin / 123456 登录管理端 → 考试记录           → 应报错（场景⑧⑨触发）' AS '';
SELECT '5. API: POST /api/student/question/answer/select/{场景④的id} → 应报错' AS '';
SELECT '6. API: POST /api/student/question/answer/select/99999       → 应报错（场景⑩）' AS '';

-- ============================================================
-- 清理脚本（修复 NPE 后执行以下命令清理测试数据）
-- ============================================================
/*
DELETE FROM t_exam_paper_question_customer_answer WHERE question_text_content_id IN (99999, 99001) AND item_order >= 100;
DELETE FROM t_exam_paper_question_customer_answer WHERE question_id = 99999 AND item_order = 102;
DELETE FROM t_text_content WHERE id = 99001;
DELETE FROM t_exam_paper_answer WHERE paper_name LIKE 'NPE测试%';
*/
