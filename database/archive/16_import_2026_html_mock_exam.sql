-- 16: 2026 HTML mock exam import
-- Generated from csgraduates HTML. This migration only touches source_year = 2026.
-- The database stores lightweight HTML references; full HTML fragments live in student static assets.
SET NAMES utf8mb4;

START TRANSACTION;

CREATE TEMPORARY TABLE IF NOT EXISTS tmp_2026_question_ids (id INT PRIMARY KEY, info_text_content_id INT);
TRUNCATE TABLE tmp_2026_question_ids;
INSERT INTO tmp_2026_question_ids SELECT id, info_text_content_id FROM t_question WHERE source_year = 2026;
DELETE qs FROM question_source qs JOIN tmp_2026_question_ids t ON qs.question_id = t.id;
DELETE qc FROM question_content qc JOIN tmp_2026_question_ids t ON qc.question_id = t.id;
DELETE FROM t_exam_paper WHERE source_year = 2026;
DELETE FROM t_question WHERE source_year = 2026;
DELETE tc FROM t_text_content tc JOIN tmp_2026_question_ids t ON tc.id = t.info_text_content_id;
DROP TEMPORARY TABLE tmp_2026_question_ids;

SET @frame_content_id = NULL;
-- Q1
INSERT INTO t_text_content (content, create_time)
VALUES ('{"titleContent": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q1-title.html\\" data-fallback=\\"当存储空间有足够的空闲空间时，在保持表内元素顺序相对不变的情况下，下列哪些操作会必然导致产生移动次数（ ）。 I. 表头插入一个元素 II. 表头删除一个元素 III. 表尾插入一个元素 IV. 表尾删除一个元素\\"></div>", "analyze": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q1-analysis.html\\" data-fallback=\\"正确答案： A 在顺序存储结构中，元素连续存放以保持逻辑顺序。 表头插入元素时，需将所有现有元素后移一位为新元素腾出空间； 表头删除元素时，需将所有剩余元素前移一位以填补空位，这两种操作均必然导致元素移动。 而表尾插入或删除元素时，仅需在末尾进行操作，不影响其他元素的位置，因此不会产生移动次数。 故必然导致移动次数的操\\"></div>", "questionItemObjects": [{"prefix": "A", "content": "I、II", "itemUuid": "3513fb0a"}, {"prefix": "B", "content": "I、III", "itemUuid": "83563394"}, {"prefix": "C", "content": "II、IV", "itemUuid": "3612218b"}, {"prefix": "D", "content": "III、IV", "itemUuid": "73fbed5c"}]}', NOW());
SET @tc1 = LAST_INSERT_ID();
INSERT INTO t_question
  (question_type, subject_id, score, grade_level, difficult, correct, info_text_content_id, create_user, status, deleted,
   title, options, correct_answer, analysis, difficulty, knowledge_point, source, source_year, source_question_no, tags, images,
   title_text, analysis_text, content_format, has_image, has_code)
VALUES
  (1, 1, 20, NULL, 2, 'A', @tc1, 1, 1, b'0',
   '<div class="question-html-ref" data-src="question-html/2026/q1-title.html" data-fallback="当存储空间有足够的空闲空间时，在保持表内元素顺序相对不变的情况下，下列哪些操作会必然导致产生移动次数（ ）。 I. 表头插入一个元素 II. 表头删除一个元素 III. 表尾插入一个元素 IV. 表尾删除一个元素"></div>', '[{"prefix": "A", "content": "I、II", "itemUuid": "3513fb0a"}, {"prefix": "B", "content": "I、III", "itemUuid": "83563394"}, {"prefix": "C", "content": "II、IV", "itemUuid": "3612218b"}, {"prefix": "D", "content": "III、IV", "itemUuid": "73fbed5c"}]', 'A', '<div class="question-html-ref" data-src="question-html/2026/q1-analysis.html" data-fallback="正确答案： A 在顺序存储结构中，元素连续存放以保持逻辑顺序。 表头插入元素时，需将所有现有元素后移一位为新元素腾出空间； 表头删除元素时，需将所有剩余元素前移一位以填补空位，这两种操作均必然导致元素移动。 而表尾插入或删除元素时，仅需在末尾进行操作，不影响其他元素的位置，因此不会产生移动次数。 故必然导致移动次数的操"></div>',
   2, NULL, '2026年408模拟题', 2026, 1, 'html,external_html', '',
   '当存储空间有足够的空闲空间时，在保持表内元素顺序相对不变的情况下，下列哪些操作会必然导致产生移动次数（ ）。 I. 表头插入一个元素 II. 表头删除一个元素 III. 表尾插入一个元素 IV. 表尾删除一个元素', '正确答案： A 在顺序存储结构中，元素连续存放以保持逻辑顺序。 表头插入元素时，需将所有现有元素后移一位为新元素腾出空间； 表头删除元素时，需将所有剩余元素前移一位以填补空位，这两种操作均必然导致元素移动。 而表尾插入或删除元素时，仅需在末尾进行操作，不影响其他元素的位置，因此不会产生移动次数。 故必然导致移动次数的操作是Ⅰ和Ⅱ。', 'html', b'0', b'0');
SET @q1 = LAST_INSERT_ID();
INSERT INTO question_content
  (question_id, version, title, options, correct_answer, analysis, title_text, analysis_text, content_format, has_image, has_code, legacy_text_content_id, source_hash, is_current)
VALUES
  (@q1, 1, '<div class="question-html-ref" data-src="question-html/2026/q1-title.html" data-fallback="当存储空间有足够的空闲空间时，在保持表内元素顺序相对不变的情况下，下列哪些操作会必然导致产生移动次数（ ）。 I. 表头插入一个元素 II. 表头删除一个元素 III. 表尾插入一个元素 IV. 表尾删除一个元素"></div>', '[{"prefix": "A", "content": "I、II", "itemUuid": "3513fb0a"}, {"prefix": "B", "content": "I、III", "itemUuid": "83563394"}, {"prefix": "C", "content": "II、IV", "itemUuid": "3612218b"}, {"prefix": "D", "content": "III、IV", "itemUuid": "73fbed5c"}]', 'A', '<div class="question-html-ref" data-src="question-html/2026/q1-analysis.html" data-fallback="正确答案： A 在顺序存储结构中，元素连续存放以保持逻辑顺序。 表头插入元素时，需将所有现有元素后移一位为新元素腾出空间； 表头删除元素时，需将所有剩余元素前移一位以填补空位，这两种操作均必然导致元素移动。 而表尾插入或删除元素时，仅需在末尾进行操作，不影响其他元素的位置，因此不会产生移动次数。 故必然导致移动次数的操"></div>',
   '当存储空间有足够的空闲空间时，在保持表内元素顺序相对不变的情况下，下列哪些操作会必然导致产生移动次数（ ）。 I. 表头插入一个元素 II. 表头删除一个元素 III. 表尾插入一个元素 IV. 表尾删除一个元素', '正确答案： A 在顺序存储结构中，元素连续存放以保持逻辑顺序。 表头插入元素时，需将所有现有元素后移一位为新元素腾出空间； 表头删除元素时，需将所有剩余元素前移一位以填补空位，这两种操作均必然导致元素移动。 而表尾插入或删除元素时，仅需在末尾进行操作，不影响其他元素的位置，因此不会产生移动次数。 故必然导致移动次数的操作是Ⅰ和Ⅱ。', 'html', b'0', b'0', @tc1, 'd2b3af8123a3c766d1ad78e076c23cb7754096229cf05b4b1de28011703ae442', b'1');
INSERT INTO question_source
  (question_id, source_type, source_name, source_year, source_question_no, paper_name, raw_ref, metadata)
VALUES
  (@q1, 'crawler_html', '计算机考研杂货铺', 2026, '1', '2026年408计算机学科专业基础综合模拟试题',
   'C:/Users/wutia/Downloads/csgraduates2026.html', '{"subject": "数据结构", "html": true}');

-- Q2
INSERT INTO t_text_content (content, create_time)
VALUES ('{"titleContent": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q2-title.html\\" data-fallback=\\"设有一个双向链表 L ，结构为 [p2, p1] ，头结点为 head 。初始时 head = cu 。现要将每个结点的 p2 指向 p1 指向结点的直接后继，应该进行的操作是（ ）。\\"></div>", "analyze": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q2-analysis.html\\" data-fallback=\\"正确答案： D 【解析】 题意澄清 双向链表结点结构为 [p2, p1] p1 ：后继指针（next） p2 ：需要被 重新设置 目标： 让每个结点的 p2 指向“ p1 所指结点的直接后继” 即： [ cu-&gt;p2 = cu-&gt;p1-&gt;p1 ] 若 cu-&gt;p1 == NULL （尾结点），则： [ cu-&gt;p2 =\\"></div>", "questionItemObjects": [{"prefix": "A", "content": "<code>while(cu!=NULL) {cu-&gt;p2=cu-&gt;p1-&gt;p1; cu=cu-&gt;p1;}</code>", "itemUuid": "79c11f59"}, {"prefix": "B", "content": "<code>while(cu!=NULL &amp;&amp; cu-&gt;p2!=NULL) {cu-&gt;p2 = cu-&gt;p1-&gt;p1; cu = cu-&gt;p1;}</code>", "itemUuid": "2896fb16"}, {"prefix": "C", "content": "<code>while(cu!=NULL) {if(cu-&gt;p1!=NULL) {cu-&gt;p2=cu-&gt;p1-&gt;p1; cu=cu-&gt;p1;}}</code>", "itemUuid": "2c553538"}, {"prefix": "D", "content": "<code>while(cu!=NULL) {if(cu-&gt;p1!=NULL) {cu-&gt;p2=cu-&gt;p1-&gt;p1;} else {cu-&gt;p2=NULL; cu=cu-&gt;p1;}}</code>", "itemUuid": "b7937524"}]}', NOW());
SET @tc2 = LAST_INSERT_ID();
INSERT INTO t_question
  (question_type, subject_id, score, grade_level, difficult, correct, info_text_content_id, create_user, status, deleted,
   title, options, correct_answer, analysis, difficulty, knowledge_point, source, source_year, source_question_no, tags, images,
   title_text, analysis_text, content_format, has_image, has_code)
VALUES
  (1, 1, 20, NULL, 2, 'D', @tc2, 1, 1, b'0',
   '<div class="question-html-ref" data-src="question-html/2026/q2-title.html" data-fallback="设有一个双向链表 L ，结构为 [p2, p1] ，头结点为 head 。初始时 head = cu 。现要将每个结点的 p2 指向 p1 指向结点的直接后继，应该进行的操作是（ ）。"></div>', '[{"prefix": "A", "content": "<code>while(cu!=NULL) {cu-&gt;p2=cu-&gt;p1-&gt;p1; cu=cu-&gt;p1;}</code>", "itemUuid": "79c11f59"}, {"prefix": "B", "content": "<code>while(cu!=NULL &amp;&amp; cu-&gt;p2!=NULL) {cu-&gt;p2 = cu-&gt;p1-&gt;p1; cu = cu-&gt;p1;}</code>", "itemUuid": "2896fb16"}, {"prefix": "C", "content": "<code>while(cu!=NULL) {if(cu-&gt;p1!=NULL) {cu-&gt;p2=cu-&gt;p1-&gt;p1; cu=cu-&gt;p1;}}</code>", "itemUuid": "2c553538"}, {"prefix": "D", "content": "<code>while(cu!=NULL) {if(cu-&gt;p1!=NULL) {cu-&gt;p2=cu-&gt;p1-&gt;p1;} else {cu-&gt;p2=NULL; cu=cu-&gt;p1;}}</code>", "itemUuid": "b7937524"}]', 'D', '<div class="question-html-ref" data-src="question-html/2026/q2-analysis.html" data-fallback="正确答案： D 【解析】 题意澄清 双向链表结点结构为 [p2, p1] p1 ：后继指针（next） p2 ：需要被 重新设置 目标： 让每个结点的 p2 指向“ p1 所指结点的直接后继” 即： [ cu-&gt;p2 = cu-&gt;p1-&gt;p1 ] 若 cu-&gt;p1 == NULL （尾结点），则： [ cu-&gt;p2 ="></div>',
   2, NULL, '2026年408模拟题', 2026, 2, 'html,external_html,code', '',
   '设有一个双向链表 L ，结构为 [p2, p1] ，头结点为 head 。初始时 head = cu 。现要将每个结点的 p2 指向 p1 指向结点的直接后继，应该进行的操作是（ ）。', '正确答案： D 【解析】 题意澄清 双向链表结点结构为 [p2, p1] p1 ：后继指针（next） p2 ：需要被 重新设置 目标： 让每个结点的 p2 指向“ p1 所指结点的直接后继” 即： [ cu->p2 = cu->p1->p1 ] 若 cu->p1 == NULL （尾结点），则： [ cu->p2 = NULL ] 同时， 遍历过程中必须始终推进 cu ，否则死循环 逐项分析 ❌ A while ( cu != NULL ) { cu -> p2 = cu -> p1 -> p1 ; cu = cu -> p1 ; } 问题 ： 当 cu 是尾结点时， cu->p1 == NULL → cu->p1->p1 非法访问 ❌ B while ( cu != NULL && cu -> p2 != NULL ) { cu -> p2 = cu -> p1 -> p1 ; cu = cu -> p1 ; } 问题 1 ： cu->p2 作为循环条件毫无意义（它正是要被修改的） 问题 2 ：仍然没有防止 cu->p1 == NULL ❌ C while ( cu != NULL ) { if ( cu -> p1 != NULL ) { cu -> p2 = cu -> p1 -> p1 ; cu = cu -> p1 ; } } 致命问题 ： 当 cu->p1 == NULL （尾结点） cu 不会更新 → 死循环 ✅ D（唯一正确） while ( cu != NULL ) { if ( cu -> p1 != NULL ) { cu -> p2 = cu -> p1 -> p1 ; } else { cu -> p2 = NULL ; } cu = cu -> p1 ; } ✔ 正确处理尾结点（ p2 = NULL ） ✔ 每一轮都推进 cu ✔ 无非法指针访问 ✔ 完全符合题意 虽然选项排版里 cu=cu->p1 写在 else 后，但 按标准理解应在 if-else 之后统一执行 ，这是此类考题的常见写法。', 'html', b'0', b'1');
SET @q2 = LAST_INSERT_ID();
INSERT INTO question_content
  (question_id, version, title, options, correct_answer, analysis, title_text, analysis_text, content_format, has_image, has_code, legacy_text_content_id, source_hash, is_current)
VALUES
  (@q2, 1, '<div class="question-html-ref" data-src="question-html/2026/q2-title.html" data-fallback="设有一个双向链表 L ，结构为 [p2, p1] ，头结点为 head 。初始时 head = cu 。现要将每个结点的 p2 指向 p1 指向结点的直接后继，应该进行的操作是（ ）。"></div>', '[{"prefix": "A", "content": "<code>while(cu!=NULL) {cu-&gt;p2=cu-&gt;p1-&gt;p1; cu=cu-&gt;p1;}</code>", "itemUuid": "79c11f59"}, {"prefix": "B", "content": "<code>while(cu!=NULL &amp;&amp; cu-&gt;p2!=NULL) {cu-&gt;p2 = cu-&gt;p1-&gt;p1; cu = cu-&gt;p1;}</code>", "itemUuid": "2896fb16"}, {"prefix": "C", "content": "<code>while(cu!=NULL) {if(cu-&gt;p1!=NULL) {cu-&gt;p2=cu-&gt;p1-&gt;p1; cu=cu-&gt;p1;}}</code>", "itemUuid": "2c553538"}, {"prefix": "D", "content": "<code>while(cu!=NULL) {if(cu-&gt;p1!=NULL) {cu-&gt;p2=cu-&gt;p1-&gt;p1;} else {cu-&gt;p2=NULL; cu=cu-&gt;p1;}}</code>", "itemUuid": "b7937524"}]', 'D', '<div class="question-html-ref" data-src="question-html/2026/q2-analysis.html" data-fallback="正确答案： D 【解析】 题意澄清 双向链表结点结构为 [p2, p1] p1 ：后继指针（next） p2 ：需要被 重新设置 目标： 让每个结点的 p2 指向“ p1 所指结点的直接后继” 即： [ cu-&gt;p2 = cu-&gt;p1-&gt;p1 ] 若 cu-&gt;p1 == NULL （尾结点），则： [ cu-&gt;p2 ="></div>',
   '设有一个双向链表 L ，结构为 [p2, p1] ，头结点为 head 。初始时 head = cu 。现要将每个结点的 p2 指向 p1 指向结点的直接后继，应该进行的操作是（ ）。', '正确答案： D 【解析】 题意澄清 双向链表结点结构为 [p2, p1] p1 ：后继指针（next） p2 ：需要被 重新设置 目标： 让每个结点的 p2 指向“ p1 所指结点的直接后继” 即： [ cu->p2 = cu->p1->p1 ] 若 cu->p1 == NULL （尾结点），则： [ cu->p2 = NULL ] 同时， 遍历过程中必须始终推进 cu ，否则死循环 逐项分析 ❌ A while ( cu != NULL ) { cu -> p2 = cu -> p1 -> p1 ; cu = cu -> p1 ; } 问题 ： 当 cu 是尾结点时， cu->p1 == NULL → cu->p1->p1 非法访问 ❌ B while ( cu != NULL && cu -> p2 != NULL ) { cu -> p2 = cu -> p1 -> p1 ; cu = cu -> p1 ; } 问题 1 ： cu->p2 作为循环条件毫无意义（它正是要被修改的） 问题 2 ：仍然没有防止 cu->p1 == NULL ❌ C while ( cu != NULL ) { if ( cu -> p1 != NULL ) { cu -> p2 = cu -> p1 -> p1 ; cu = cu -> p1 ; } } 致命问题 ： 当 cu->p1 == NULL （尾结点） cu 不会更新 → 死循环 ✅ D（唯一正确） while ( cu != NULL ) { if ( cu -> p1 != NULL ) { cu -> p2 = cu -> p1 -> p1 ; } else { cu -> p2 = NULL ; } cu = cu -> p1 ; } ✔ 正确处理尾结点（ p2 = NULL ） ✔ 每一轮都推进 cu ✔ 无非法指针访问 ✔ 完全符合题意 虽然选项排版里 cu=cu->p1 写在 else 后，但 按标准理解应在 if-else 之后统一执行 ，这是此类考题的常见写法。', 'html', b'0', b'1', @tc2, '54865e2caf3aa9577fef8d70ada3486eaaf24756aba58f41cf7fe0abcd445d62', b'1');
INSERT INTO question_source
  (question_id, source_type, source_name, source_year, source_question_no, paper_name, raw_ref, metadata)
VALUES
  (@q2, 'crawler_html', '计算机考研杂货铺', 2026, '2', '2026年408计算机学科专业基础综合模拟试题',
   'C:/Users/wutia/Downloads/csgraduates2026.html', '{"subject": "数据结构", "html": true}');

-- Q3
INSERT INTO t_text_content (content, create_time)
VALUES ('{"titleContent": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q3-title.html\\" data-fallback=\\"已知二叉树 T 的中序遍历为 b, e, d, f, c, a, g。层序遍历为 a, b, g, c, d, e, f。则其后序遍历序列为多少？\\"></div>", "analyze": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q3-analysis.html\\" data-fallback=\\"正确答案： C 【解析】 首先，根据层序遍历序列 a , b , g , c , d , e , f 可知根节点为 a 。结合中序遍历 b , e , d , f , c , a , g ，确定左子树包含节点 b , e , d , f , c ，右子树仅包含 g 。 左子树的层序序列为 b , c , d , e ,\\"></div>", "questionItemObjects": [{"prefix": "A", "content": "c, e, d, f, b, g, a", "itemUuid": "728e05b4"}, {"prefix": "B", "content": "c, e, f, d, b, g, a", "itemUuid": "1d530777"}, {"prefix": "C", "content": "e, f, d, c, b, g, a", "itemUuid": "6757420e"}, {"prefix": "D", "content": "e, g, f, d, b, c, a", "itemUuid": "59e57ad1"}]}', NOW());
SET @tc3 = LAST_INSERT_ID();
INSERT INTO t_question
  (question_type, subject_id, score, grade_level, difficult, correct, info_text_content_id, create_user, status, deleted,
   title, options, correct_answer, analysis, difficulty, knowledge_point, source, source_year, source_question_no, tags, images,
   title_text, analysis_text, content_format, has_image, has_code)
VALUES
  (1, 1, 20, NULL, 2, 'C', @tc3, 1, 1, b'0',
   '<div class="question-html-ref" data-src="question-html/2026/q3-title.html" data-fallback="已知二叉树 T 的中序遍历为 b, e, d, f, c, a, g。层序遍历为 a, b, g, c, d, e, f。则其后序遍历序列为多少？"></div>', '[{"prefix": "A", "content": "c, e, d, f, b, g, a", "itemUuid": "728e05b4"}, {"prefix": "B", "content": "c, e, f, d, b, g, a", "itemUuid": "1d530777"}, {"prefix": "C", "content": "e, f, d, c, b, g, a", "itemUuid": "6757420e"}, {"prefix": "D", "content": "e, g, f, d, b, c, a", "itemUuid": "59e57ad1"}]', 'C', '<div class="question-html-ref" data-src="question-html/2026/q3-analysis.html" data-fallback="正确答案： C 【解析】 首先，根据层序遍历序列 a , b , g , c , d , e , f 可知根节点为 a 。结合中序遍历 b , e , d , f , c , a , g ，确定左子树包含节点 b , e , d , f , c ，右子树仅包含 g 。 左子树的层序序列为 b , c , d , e ,"></div>',
   2, NULL, '2026年408模拟题', 2026, 3, 'html,external_html,katex', '',
   '已知二叉树 T 的中序遍历为 b, e, d, f, c, a, g。层序遍历为 a, b, g, c, d, e, f。则其后序遍历序列为多少？', '正确答案： C 【解析】 首先，根据层序遍历序列 a , b , g , c , d , e , f 可知根节点为 a 。结合中序遍历 b , e , d , f , c , a , g ，确定左子树包含节点 b , e , d , f , c ，右子树仅包含 g 。 左子树的层序序列为 b , c , d , e , f ，中序序列为 b , e , d , f , c ，因此左子树的根为 b 。由于 b 在中序中为首，故无左子树，其右子树的根为层序中下一个节点 c 。 对于以 c 为根的子树，中序为 e , d , f , c ，故 c 无右子树，其左子树的根为层序中的 d 。对于以 d 为根的子树，中序为 e , d , f ，故 d 的左子节点为 e ，右子节点为 f 。 因此树的结构为： a 的左子节点为 b ，右子节点为 g ； b 的左子节点为空，右子节点为 c ； c 的左子节点为 d ，右子节点为空； d 的左子节点为 e ，右子节点为 f 。 后序遍历顺序为：左子树的后序、右子树的后序、根节点。左子树的后序依次为 e , f , d , c , b ，右子树的后序为 g ，根为 a ，故后序遍历序列为 e , f , d , c , b , g , a ，对应选项 C。', 'html', b'0', b'0');
SET @q3 = LAST_INSERT_ID();
INSERT INTO question_content
  (question_id, version, title, options, correct_answer, analysis, title_text, analysis_text, content_format, has_image, has_code, legacy_text_content_id, source_hash, is_current)
VALUES
  (@q3, 1, '<div class="question-html-ref" data-src="question-html/2026/q3-title.html" data-fallback="已知二叉树 T 的中序遍历为 b, e, d, f, c, a, g。层序遍历为 a, b, g, c, d, e, f。则其后序遍历序列为多少？"></div>', '[{"prefix": "A", "content": "c, e, d, f, b, g, a", "itemUuid": "728e05b4"}, {"prefix": "B", "content": "c, e, f, d, b, g, a", "itemUuid": "1d530777"}, {"prefix": "C", "content": "e, f, d, c, b, g, a", "itemUuid": "6757420e"}, {"prefix": "D", "content": "e, g, f, d, b, c, a", "itemUuid": "59e57ad1"}]', 'C', '<div class="question-html-ref" data-src="question-html/2026/q3-analysis.html" data-fallback="正确答案： C 【解析】 首先，根据层序遍历序列 a , b , g , c , d , e , f 可知根节点为 a 。结合中序遍历 b , e , d , f , c , a , g ，确定左子树包含节点 b , e , d , f , c ，右子树仅包含 g 。 左子树的层序序列为 b , c , d , e ,"></div>',
   '已知二叉树 T 的中序遍历为 b, e, d, f, c, a, g。层序遍历为 a, b, g, c, d, e, f。则其后序遍历序列为多少？', '正确答案： C 【解析】 首先，根据层序遍历序列 a , b , g , c , d , e , f 可知根节点为 a 。结合中序遍历 b , e , d , f , c , a , g ，确定左子树包含节点 b , e , d , f , c ，右子树仅包含 g 。 左子树的层序序列为 b , c , d , e , f ，中序序列为 b , e , d , f , c ，因此左子树的根为 b 。由于 b 在中序中为首，故无左子树，其右子树的根为层序中下一个节点 c 。 对于以 c 为根的子树，中序为 e , d , f , c ，故 c 无右子树，其左子树的根为层序中的 d 。对于以 d 为根的子树，中序为 e , d , f ，故 d 的左子节点为 e ，右子节点为 f 。 因此树的结构为： a 的左子节点为 b ，右子节点为 g ； b 的左子节点为空，右子节点为 c ； c 的左子节点为 d ，右子节点为空； d 的左子节点为 e ，右子节点为 f 。 后序遍历顺序为：左子树的后序、右子树的后序、根节点。左子树的后序依次为 e , f , d , c , b ，右子树的后序为 g ，根为 a ，故后序遍历序列为 e , f , d , c , b , g , a ，对应选项 C。', 'html', b'0', b'0', @tc3, '9b387c1de914640ed7edd90b80b699a7b610a0cb83bbfc69b2d344481af8f9b6', b'1');
INSERT INTO question_source
  (question_id, source_type, source_name, source_year, source_question_no, paper_name, raw_ref, metadata)
VALUES
  (@q3, 'crawler_html', '计算机考研杂货铺', 2026, '3', '2026年408计算机学科专业基础综合模拟试题',
   'C:/Users/wutia/Downloads/csgraduates2026.html', '{"subject": "数据结构", "html": true}');

-- Q4
INSERT INTO t_text_content (content, create_time)
VALUES ('{"titleContent": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q4-title.html\\" data-fallback=\\"森林 F 中有 5 颗树，其节点个数分别为 2、3、4、5、7，森林中树的次序可以任意，问 F 对应的二叉树最小高度为多少？\\"></div>", "analyze": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q4-analysis.html\\" data-fallback=\\"正确答案： B 【解析】 这是一道 森林 → 二叉树（左孩子 - 右兄弟表示法） 的经典题。 关键结论（必须掌握） 把森林转换为二叉树（ 左孩子 - 右兄弟 ）后： 二叉树的高度 = max( 第 i 棵树的高度 + (i − 1) ) 其中 第 i 棵树是森林中从左到右的顺序； ( i − 1 ) 来自“右兄弟”链；\\"></div>", "questionItemObjects": [{"prefix": "A", "content": "5", "itemUuid": "8686c4da"}, {"prefix": "B", "content": "6", "itemUuid": "d2685918"}, {"prefix": "C", "content": "8", "itemUuid": "aba4a312"}, {"prefix": "D", "content": "10", "itemUuid": "ddfce55f"}]}', NOW());
SET @tc4 = LAST_INSERT_ID();
INSERT INTO t_question
  (question_type, subject_id, score, grade_level, difficult, correct, info_text_content_id, create_user, status, deleted,
   title, options, correct_answer, analysis, difficulty, knowledge_point, source, source_year, source_question_no, tags, images,
   title_text, analysis_text, content_format, has_image, has_code)
VALUES
  (1, 1, 20, NULL, 2, 'B', @tc4, 1, 1, b'0',
   '<div class="question-html-ref" data-src="question-html/2026/q4-title.html" data-fallback="森林 F 中有 5 颗树，其节点个数分别为 2、3、4、5、7，森林中树的次序可以任意，问 F 对应的二叉树最小高度为多少？"></div>', '[{"prefix": "A", "content": "5", "itemUuid": "8686c4da"}, {"prefix": "B", "content": "6", "itemUuid": "d2685918"}, {"prefix": "C", "content": "8", "itemUuid": "aba4a312"}, {"prefix": "D", "content": "10", "itemUuid": "ddfce55f"}]', 'B', '<div class="question-html-ref" data-src="question-html/2026/q4-analysis.html" data-fallback="正确答案： B 【解析】 这是一道 森林 → 二叉树（左孩子 - 右兄弟表示法） 的经典题。 关键结论（必须掌握） 把森林转换为二叉树（ 左孩子 - 右兄弟 ）后： 二叉树的高度 = max( 第 i 棵树的高度 + (i − 1) ) 其中 第 i 棵树是森林中从左到右的顺序； ( i − 1 ) 来自“右兄弟”链；"></div>',
   2, NULL, '2026年408模拟题', 2026, 4, 'html,external_html,table,katex', '',
   '森林 F 中有 5 颗树，其节点个数分别为 2、3、4、5、7，森林中树的次序可以任意，问 F 对应的二叉树最小高度为多少？', '正确答案： B 【解析】 这是一道 森林 → 二叉树（左孩子 - 右兄弟表示法） 的经典题。 关键结论（必须掌握） 把森林转换为二叉树（ 左孩子 - 右兄弟 ）后： 二叉树的高度 = max( 第 i 棵树的高度 + (i − 1) ) 其中 第 i 棵树是森林中从左到右的顺序； ( i − 1 ) 来自“右兄弟”链； 为了 最小高度 ，应当把 高度最大的树放在最前面 。 先算每棵树的最小可能高度 一棵有 n 个结点的普通树，其 最小高度 为： h m i n ​ = ⌈ lo g 2 ​ ( n + 1 )⌉ 结点数 最小高度 7 ⌈ lo g 2 ​ 8 ⌉ = 3 5 ⌈ lo g 2 ​ 6 ⌉ = 3 4 ⌈ lo g 2 ​ 5 ⌉ = 3 3 ⌈ lo g 2 ​ 4 ⌉ = 2 2 ⌈ lo g 2 ​ 3 ⌉ = 2 排序（从大到小）： 3 , 3 , 3 , 2 , 2 计算二叉树最小高度 按最优顺序依次计算： i 树高 h i ​ h i ​ + ( i − 1 ) 1 3 3 2 3 4 3 3 5 4 2 5 5 2 6 最大值 = 6', 'html', b'0', b'0');
SET @q4 = LAST_INSERT_ID();
INSERT INTO question_content
  (question_id, version, title, options, correct_answer, analysis, title_text, analysis_text, content_format, has_image, has_code, legacy_text_content_id, source_hash, is_current)
VALUES
  (@q4, 1, '<div class="question-html-ref" data-src="question-html/2026/q4-title.html" data-fallback="森林 F 中有 5 颗树，其节点个数分别为 2、3、4、5、7，森林中树的次序可以任意，问 F 对应的二叉树最小高度为多少？"></div>', '[{"prefix": "A", "content": "5", "itemUuid": "8686c4da"}, {"prefix": "B", "content": "6", "itemUuid": "d2685918"}, {"prefix": "C", "content": "8", "itemUuid": "aba4a312"}, {"prefix": "D", "content": "10", "itemUuid": "ddfce55f"}]', 'B', '<div class="question-html-ref" data-src="question-html/2026/q4-analysis.html" data-fallback="正确答案： B 【解析】 这是一道 森林 → 二叉树（左孩子 - 右兄弟表示法） 的经典题。 关键结论（必须掌握） 把森林转换为二叉树（ 左孩子 - 右兄弟 ）后： 二叉树的高度 = max( 第 i 棵树的高度 + (i − 1) ) 其中 第 i 棵树是森林中从左到右的顺序； ( i − 1 ) 来自“右兄弟”链；"></div>',
   '森林 F 中有 5 颗树，其节点个数分别为 2、3、4、5、7，森林中树的次序可以任意，问 F 对应的二叉树最小高度为多少？', '正确答案： B 【解析】 这是一道 森林 → 二叉树（左孩子 - 右兄弟表示法） 的经典题。 关键结论（必须掌握） 把森林转换为二叉树（ 左孩子 - 右兄弟 ）后： 二叉树的高度 = max( 第 i 棵树的高度 + (i − 1) ) 其中 第 i 棵树是森林中从左到右的顺序； ( i − 1 ) 来自“右兄弟”链； 为了 最小高度 ，应当把 高度最大的树放在最前面 。 先算每棵树的最小可能高度 一棵有 n 个结点的普通树，其 最小高度 为： h m i n ​ = ⌈ lo g 2 ​ ( n + 1 )⌉ 结点数 最小高度 7 ⌈ lo g 2 ​ 8 ⌉ = 3 5 ⌈ lo g 2 ​ 6 ⌉ = 3 4 ⌈ lo g 2 ​ 5 ⌉ = 3 3 ⌈ lo g 2 ​ 4 ⌉ = 2 2 ⌈ lo g 2 ​ 3 ⌉ = 2 排序（从大到小）： 3 , 3 , 3 , 2 , 2 计算二叉树最小高度 按最优顺序依次计算： i 树高 h i ​ h i ​ + ( i − 1 ) 1 3 3 2 3 4 3 3 5 4 2 5 5 2 6 最大值 = 6', 'html', b'0', b'0', @tc4, 'd4513617ed5361f8e326cf5518d39627c7fa97b57440b785646ddca1970e10b4', b'1');
INSERT INTO question_source
  (question_id, source_type, source_name, source_year, source_question_no, paper_name, raw_ref, metadata)
VALUES
  (@q4, 'crawler_html', '计算机考研杂货铺', 2026, '4', '2026年408计算机学科专业基础综合模拟试题',
   'C:/Users/wutia/Downloads/csgraduates2026.html', '{"subject": "数据结构", "html": true}');

-- Q5
INSERT INTO t_text_content (content, create_time)
VALUES ('{"titleContent": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q5-title.html\\" data-fallback=\\"假设二叉树中节点权值为 a = 1 , b = 2 , c = 4 , d = 5 , e = 8 , f = 10 , g = 12 。当带权路径长度（WPL）最小时，与节点 e （权值 8）处于相同深度的节点是哪些？\\"></div>", "analyze": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q5-analysis.html\\" data-fallback=\\"正确答案： D 【解析】 为了最小化带权路径长度（WPL），需构建哈夫曼树。节点权值依次为 1, 2, 4, 5, 8, 10, 12。 构建过程如下： 合并权值 1 和 2，得到新节点 3； 合并 3 和 4，得到新节点 7； 合并 5 和 7，得到新节点 12； 合并 8 和 10，得到新节点 18； 合并原始权值\\"></div>", "questionItemObjects": [{"prefix": "A", "content": "d", "itemUuid": "63d5be4e"}, {"prefix": "B", "content": "g", "itemUuid": "5e2999a9"}, {"prefix": "C", "content": "d,f", "itemUuid": "90ec527b"}, {"prefix": "D", "content": "f,g", "itemUuid": "3bf3aff1"}]}', NOW());
SET @tc5 = LAST_INSERT_ID();
INSERT INTO t_question
  (question_type, subject_id, score, grade_level, difficult, correct, info_text_content_id, create_user, status, deleted,
   title, options, correct_answer, analysis, difficulty, knowledge_point, source, source_year, source_question_no, tags, images,
   title_text, analysis_text, content_format, has_image, has_code)
VALUES
  (1, 1, 20, NULL, 2, 'D', @tc5, 1, 1, b'0',
   '<div class="question-html-ref" data-src="question-html/2026/q5-title.html" data-fallback="假设二叉树中节点权值为 a = 1 , b = 2 , c = 4 , d = 5 , e = 8 , f = 10 , g = 12 。当带权路径长度（WPL）最小时，与节点 e （权值 8）处于相同深度的节点是哪些？"></div>', '[{"prefix": "A", "content": "d", "itemUuid": "63d5be4e"}, {"prefix": "B", "content": "g", "itemUuid": "5e2999a9"}, {"prefix": "C", "content": "d,f", "itemUuid": "90ec527b"}, {"prefix": "D", "content": "f,g", "itemUuid": "3bf3aff1"}]', 'D', '<div class="question-html-ref" data-src="question-html/2026/q5-analysis.html" data-fallback="正确答案： D 【解析】 为了最小化带权路径长度（WPL），需构建哈夫曼树。节点权值依次为 1, 2, 4, 5, 8, 10, 12。 构建过程如下： 合并权值 1 和 2，得到新节点 3； 合并 3 和 4，得到新节点 7； 合并 5 和 7，得到新节点 12； 合并 8 和 10，得到新节点 18； 合并原始权值"></div>',
   2, NULL, '2026年408模拟题', 2026, 5, 'html,external_html,katex', '',
   '假设二叉树中节点权值为 a = 1 , b = 2 , c = 4 , d = 5 , e = 8 , f = 10 , g = 12 。当带权路径长度（WPL）最小时，与节点 e （权值 8）处于相同深度的节点是哪些？', '正确答案： D 【解析】 为了最小化带权路径长度（WPL），需构建哈夫曼树。节点权值依次为 1, 2, 4, 5, 8, 10, 12。 构建过程如下： 合并权值 1 和 2，得到新节点 3； 合并 3 和 4，得到新节点 7； 合并 5 和 7，得到新节点 12； 合并 8 和 10，得到新节点 18； 合并原始权值 12（节点 g）与内部节点 12，得到新节点 24； 最后合并 18 和 24，得到根节点 42。 由此树结构可知，节点 e（权值 8）深度为 2（路径长度），同时节点 f（权值 10）和 g（权值 12）深度也为 2，而其他节点深度均不同（d 深度为 3，c 深度为 4，a、b 深度为 5）。 因此，与节点 e 处于相同深度的节点是 f 和 g。', 'html', b'0', b'0');
SET @q5 = LAST_INSERT_ID();
INSERT INTO question_content
  (question_id, version, title, options, correct_answer, analysis, title_text, analysis_text, content_format, has_image, has_code, legacy_text_content_id, source_hash, is_current)
VALUES
  (@q5, 1, '<div class="question-html-ref" data-src="question-html/2026/q5-title.html" data-fallback="假设二叉树中节点权值为 a = 1 , b = 2 , c = 4 , d = 5 , e = 8 , f = 10 , g = 12 。当带权路径长度（WPL）最小时，与节点 e （权值 8）处于相同深度的节点是哪些？"></div>', '[{"prefix": "A", "content": "d", "itemUuid": "63d5be4e"}, {"prefix": "B", "content": "g", "itemUuid": "5e2999a9"}, {"prefix": "C", "content": "d,f", "itemUuid": "90ec527b"}, {"prefix": "D", "content": "f,g", "itemUuid": "3bf3aff1"}]', 'D', '<div class="question-html-ref" data-src="question-html/2026/q5-analysis.html" data-fallback="正确答案： D 【解析】 为了最小化带权路径长度（WPL），需构建哈夫曼树。节点权值依次为 1, 2, 4, 5, 8, 10, 12。 构建过程如下： 合并权值 1 和 2，得到新节点 3； 合并 3 和 4，得到新节点 7； 合并 5 和 7，得到新节点 12； 合并 8 和 10，得到新节点 18； 合并原始权值"></div>',
   '假设二叉树中节点权值为 a = 1 , b = 2 , c = 4 , d = 5 , e = 8 , f = 10 , g = 12 。当带权路径长度（WPL）最小时，与节点 e （权值 8）处于相同深度的节点是哪些？', '正确答案： D 【解析】 为了最小化带权路径长度（WPL），需构建哈夫曼树。节点权值依次为 1, 2, 4, 5, 8, 10, 12。 构建过程如下： 合并权值 1 和 2，得到新节点 3； 合并 3 和 4，得到新节点 7； 合并 5 和 7，得到新节点 12； 合并 8 和 10，得到新节点 18； 合并原始权值 12（节点 g）与内部节点 12，得到新节点 24； 最后合并 18 和 24，得到根节点 42。 由此树结构可知，节点 e（权值 8）深度为 2（路径长度），同时节点 f（权值 10）和 g（权值 12）深度也为 2，而其他节点深度均不同（d 深度为 3，c 深度为 4，a、b 深度为 5）。 因此，与节点 e 处于相同深度的节点是 f 和 g。', 'html', b'0', b'0', @tc5, '6c13c2ae8ef6498ce62e3791ffda52c49e207a252376368a4200c52684595e92', b'1');
INSERT INTO question_source
  (question_id, source_type, source_name, source_year, source_question_no, paper_name, raw_ref, metadata)
VALUES
  (@q5, 'crawler_html', '计算机考研杂货铺', 2026, '5', '2026年408计算机学科专业基础综合模拟试题',
   'C:/Users/wutia/Downloads/csgraduates2026.html', '{"subject": "数据结构", "html": true}');

-- Q6
INSERT INTO t_text_content (content, create_time)
VALUES ('{"titleContent": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q6-title.html\\" data-fallback=\\"有向图 G = ( V , E ) 采用邻接表存储，求某点入度的时间复杂度为？\\"></div>", "analyze": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q6-analysis.html\\" data-fallback=\\"正确答案： D 【解析】 在邻接表存储中，求某点的入度需要检查所有顶点的出边链表，统计指向该点的边数。这需要访问所有 ∣ V ∣ 个顶点以及所有 ∣ E ∣ 条边，因此时间复杂度为 O ( ∣ V ∣ + ∣ E ∣ ) 。由于 O ( ∣ V ∣ + ∣ E ∣ ) 与 O ( max ( ∣ V ∣ , ∣ E ∣\\"></div>", "questionItemObjects": [{"prefix": "A", "content": "<span class=\\"katex\\"><span aria-hidden=\\"true\\" class=\\"katex-html\\"><span class=\\"base\\"><span class=\\"strut\\" style=\\"height:1em;vertical-align:-.25em\\"></span><span class=\\"mord mathnormal\\" style=\\"margin-right:.02778em\\">O</span><span class=\\"mopen\\">(</span><span class=\\"mord\\">∣</span><span class=\\"mord mathnormal\\" style=\\"margin-right:.22222em\\">V</span><span class=\\"mord\\">∣</span><span class=\\"mclose\\">)</span></span></span></span>", "itemUuid": "133b8e40"}, {"prefix": "B", "content": "<span class=\\"katex\\"><span aria-hidden=\\"true\\" class=\\"katex-html\\"><span class=\\"base\\"><span class=\\"strut\\" style=\\"height:1em;vertical-align:-.25em\\"></span><span class=\\"mord mathnormal\\" style=\\"margin-right:.02778em\\">O</span><span class=\\"mopen\\">(</span><span class=\\"mop\\">min</span><span class=\\"mopen\\">(</span><span class=\\"mord\\">∣</span><span class=\\"mord mathnormal\\" style=\\"margin-right:.22222em\\">V</span><span class=\\"mord\\">∣</span><span class=\\"mpunct\\">,</span><span class=\\"mspace\\" style=\\"margin-right:.1667em\\"></span><span class=\\"mord\\">∣</span><span class=\\"mord mathnormal\\" style=\\"margin-right:.05764em\\">E</span><span class=\\"mord\\">∣</span><span class=\\"mclose\\">))</span></span></span></span>", "itemUuid": "a074e0bb"}, {"prefix": "C", "content": "<span class=\\"katex\\"><span aria-hidden=\\"true\\" class=\\"katex-html\\"><span class=\\"base\\"><span class=\\"strut\\" style=\\"height:1em;vertical-align:-.25em\\"></span><span class=\\"mord mathnormal\\" style=\\"margin-right:.02778em\\">O</span><span class=\\"mopen\\">(</span><span class=\\"mord\\">∣</span><span class=\\"mord mathnormal\\" style=\\"margin-right:.05764em\\">E</span><span class=\\"mord\\">∣</span><span class=\\"mclose\\">)</span></span></span></span>", "itemUuid": "af7400f5"}, {"prefix": "D", "content": "<span class=\\"katex\\"><span aria-hidden=\\"true\\" class=\\"katex-html\\"><span class=\\"base\\"><span class=\\"strut\\" style=\\"height:1em;vertical-align:-.25em\\"></span><span class=\\"mord mathnormal\\" style=\\"margin-right:.02778em\\">O</span><span class=\\"mopen\\">(</span><span class=\\"mop\\">max</span><span class=\\"mopen\\">(</span><span class=\\"mord\\">∣</span><span class=\\"mord mathnormal\\" style=\\"margin-right:.22222em\\">V</span><span class=\\"mord\\">∣</span><span class=\\"mpunct\\">,</span><span class=\\"mspace\\" style=\\"margin-right:.1667em\\"></span><span class=\\"mord\\">∣</span><span class=\\"mord mathnormal\\" style=\\"margin-right:.05764em\\">E</span><span class=\\"mord\\">∣</span><span class=\\"mclose\\">))</span></span></span></span>", "itemUuid": "119643e1"}]}', NOW());
SET @tc6 = LAST_INSERT_ID();
INSERT INTO t_question
  (question_type, subject_id, score, grade_level, difficult, correct, info_text_content_id, create_user, status, deleted,
   title, options, correct_answer, analysis, difficulty, knowledge_point, source, source_year, source_question_no, tags, images,
   title_text, analysis_text, content_format, has_image, has_code)
VALUES
  (1, 1, 20, NULL, 2, 'D', @tc6, 1, 1, b'0',
   '<div class="question-html-ref" data-src="question-html/2026/q6-title.html" data-fallback="有向图 G = ( V , E ) 采用邻接表存储，求某点入度的时间复杂度为？"></div>', '[{"prefix": "A", "content": "<span class=\\"katex\\"><span aria-hidden=\\"true\\" class=\\"katex-html\\"><span class=\\"base\\"><span class=\\"strut\\" style=\\"height:1em;vertical-align:-.25em\\"></span><span class=\\"mord mathnormal\\" style=\\"margin-right:.02778em\\">O</span><span class=\\"mopen\\">(</span><span class=\\"mord\\">∣</span><span class=\\"mord mathnormal\\" style=\\"margin-right:.22222em\\">V</span><span class=\\"mord\\">∣</span><span class=\\"mclose\\">)</span></span></span></span>", "itemUuid": "133b8e40"}, {"prefix": "B", "content": "<span class=\\"katex\\"><span aria-hidden=\\"true\\" class=\\"katex-html\\"><span class=\\"base\\"><span class=\\"strut\\" style=\\"height:1em;vertical-align:-.25em\\"></span><span class=\\"mord mathnormal\\" style=\\"margin-right:.02778em\\">O</span><span class=\\"mopen\\">(</span><span class=\\"mop\\">min</span><span class=\\"mopen\\">(</span><span class=\\"mord\\">∣</span><span class=\\"mord mathnormal\\" style=\\"margin-right:.22222em\\">V</span><span class=\\"mord\\">∣</span><span class=\\"mpunct\\">,</span><span class=\\"mspace\\" style=\\"margin-right:.1667em\\"></span><span class=\\"mord\\">∣</span><span class=\\"mord mathnormal\\" style=\\"margin-right:.05764em\\">E</span><span class=\\"mord\\">∣</span><span class=\\"mclose\\">))</span></span></span></span>", "itemUuid": "a074e0bb"}, {"prefix": "C", "content": "<span class=\\"katex\\"><span aria-hidden=\\"true\\" class=\\"katex-html\\"><span class=\\"base\\"><span class=\\"strut\\" style=\\"height:1em;vertical-align:-.25em\\"></span><span class=\\"mord mathnormal\\" style=\\"margin-right:.02778em\\">O</span><span class=\\"mopen\\">(</span><span class=\\"mord\\">∣</span><span class=\\"mord mathnormal\\" style=\\"margin-right:.05764em\\">E</span><span class=\\"mord\\">∣</span><span class=\\"mclose\\">)</span></span></span></span>", "itemUuid": "af7400f5"}, {"prefix": "D", "content": "<span class=\\"katex\\"><span aria-hidden=\\"true\\" class=\\"katex-html\\"><span class=\\"base\\"><span class=\\"strut\\" style=\\"height:1em;vertical-align:-.25em\\"></span><span class=\\"mord mathnormal\\" style=\\"margin-right:.02778em\\">O</span><span class=\\"mopen\\">(</span><span class=\\"mop\\">max</span><span class=\\"mopen\\">(</span><span class=\\"mord\\">∣</span><span class=\\"mord mathnormal\\" style=\\"margin-right:.22222em\\">V</span><span class=\\"mord\\">∣</span><span class=\\"mpunct\\">,</span><span class=\\"mspace\\" style=\\"margin-right:.1667em\\"></span><span class=\\"mord\\">∣</span><span class=\\"mord mathnormal\\" style=\\"margin-right:.05764em\\">E</span><span class=\\"mord\\">∣</span><span class=\\"mclose\\">))</span></span></span></span>", "itemUuid": "119643e1"}]', 'D', '<div class="question-html-ref" data-src="question-html/2026/q6-analysis.html" data-fallback="正确答案： D 【解析】 在邻接表存储中，求某点的入度需要检查所有顶点的出边链表，统计指向该点的边数。这需要访问所有 ∣ V ∣ 个顶点以及所有 ∣ E ∣ 条边，因此时间复杂度为 O ( ∣ V ∣ + ∣ E ∣ ) 。由于 O ( ∣ V ∣ + ∣ E ∣ ) 与 O ( max ( ∣ V ∣ , ∣ E ∣"></div>',
   2, NULL, '2026年408模拟题', 2026, 6, 'html,external_html,katex', '',
   '有向图 G = ( V , E ) 采用邻接表存储，求某点入度的时间复杂度为？', '正确答案： D 【解析】 在邻接表存储中，求某点的入度需要检查所有顶点的出边链表，统计指向该点的边数。这需要访问所有 ∣ V ∣ 个顶点以及所有 ∣ E ∣ 条边，因此时间复杂度为 O ( ∣ V ∣ + ∣ E ∣ ) 。由于 O ( ∣ V ∣ + ∣ E ∣ ) 与 O ( max ( ∣ V ∣ , ∣ E ∣ )) 等价，故选项 D 正确。其他选项均不能完整描述该时间复杂度。', 'html', b'0', b'0');
SET @q6 = LAST_INSERT_ID();
INSERT INTO question_content
  (question_id, version, title, options, correct_answer, analysis, title_text, analysis_text, content_format, has_image, has_code, legacy_text_content_id, source_hash, is_current)
VALUES
  (@q6, 1, '<div class="question-html-ref" data-src="question-html/2026/q6-title.html" data-fallback="有向图 G = ( V , E ) 采用邻接表存储，求某点入度的时间复杂度为？"></div>', '[{"prefix": "A", "content": "<span class=\\"katex\\"><span aria-hidden=\\"true\\" class=\\"katex-html\\"><span class=\\"base\\"><span class=\\"strut\\" style=\\"height:1em;vertical-align:-.25em\\"></span><span class=\\"mord mathnormal\\" style=\\"margin-right:.02778em\\">O</span><span class=\\"mopen\\">(</span><span class=\\"mord\\">∣</span><span class=\\"mord mathnormal\\" style=\\"margin-right:.22222em\\">V</span><span class=\\"mord\\">∣</span><span class=\\"mclose\\">)</span></span></span></span>", "itemUuid": "133b8e40"}, {"prefix": "B", "content": "<span class=\\"katex\\"><span aria-hidden=\\"true\\" class=\\"katex-html\\"><span class=\\"base\\"><span class=\\"strut\\" style=\\"height:1em;vertical-align:-.25em\\"></span><span class=\\"mord mathnormal\\" style=\\"margin-right:.02778em\\">O</span><span class=\\"mopen\\">(</span><span class=\\"mop\\">min</span><span class=\\"mopen\\">(</span><span class=\\"mord\\">∣</span><span class=\\"mord mathnormal\\" style=\\"margin-right:.22222em\\">V</span><span class=\\"mord\\">∣</span><span class=\\"mpunct\\">,</span><span class=\\"mspace\\" style=\\"margin-right:.1667em\\"></span><span class=\\"mord\\">∣</span><span class=\\"mord mathnormal\\" style=\\"margin-right:.05764em\\">E</span><span class=\\"mord\\">∣</span><span class=\\"mclose\\">))</span></span></span></span>", "itemUuid": "a074e0bb"}, {"prefix": "C", "content": "<span class=\\"katex\\"><span aria-hidden=\\"true\\" class=\\"katex-html\\"><span class=\\"base\\"><span class=\\"strut\\" style=\\"height:1em;vertical-align:-.25em\\"></span><span class=\\"mord mathnormal\\" style=\\"margin-right:.02778em\\">O</span><span class=\\"mopen\\">(</span><span class=\\"mord\\">∣</span><span class=\\"mord mathnormal\\" style=\\"margin-right:.05764em\\">E</span><span class=\\"mord\\">∣</span><span class=\\"mclose\\">)</span></span></span></span>", "itemUuid": "af7400f5"}, {"prefix": "D", "content": "<span class=\\"katex\\"><span aria-hidden=\\"true\\" class=\\"katex-html\\"><span class=\\"base\\"><span class=\\"strut\\" style=\\"height:1em;vertical-align:-.25em\\"></span><span class=\\"mord mathnormal\\" style=\\"margin-right:.02778em\\">O</span><span class=\\"mopen\\">(</span><span class=\\"mop\\">max</span><span class=\\"mopen\\">(</span><span class=\\"mord\\">∣</span><span class=\\"mord mathnormal\\" style=\\"margin-right:.22222em\\">V</span><span class=\\"mord\\">∣</span><span class=\\"mpunct\\">,</span><span class=\\"mspace\\" style=\\"margin-right:.1667em\\"></span><span class=\\"mord\\">∣</span><span class=\\"mord mathnormal\\" style=\\"margin-right:.05764em\\">E</span><span class=\\"mord\\">∣</span><span class=\\"mclose\\">))</span></span></span></span>", "itemUuid": "119643e1"}]', 'D', '<div class="question-html-ref" data-src="question-html/2026/q6-analysis.html" data-fallback="正确答案： D 【解析】 在邻接表存储中，求某点的入度需要检查所有顶点的出边链表，统计指向该点的边数。这需要访问所有 ∣ V ∣ 个顶点以及所有 ∣ E ∣ 条边，因此时间复杂度为 O ( ∣ V ∣ + ∣ E ∣ ) 。由于 O ( ∣ V ∣ + ∣ E ∣ ) 与 O ( max ( ∣ V ∣ , ∣ E ∣"></div>',
   '有向图 G = ( V , E ) 采用邻接表存储，求某点入度的时间复杂度为？', '正确答案： D 【解析】 在邻接表存储中，求某点的入度需要检查所有顶点的出边链表，统计指向该点的边数。这需要访问所有 ∣ V ∣ 个顶点以及所有 ∣ E ∣ 条边，因此时间复杂度为 O ( ∣ V ∣ + ∣ E ∣ ) 。由于 O ( ∣ V ∣ + ∣ E ∣ ) 与 O ( max ( ∣ V ∣ , ∣ E ∣ )) 等价，故选项 D 正确。其他选项均不能完整描述该时间复杂度。', 'html', b'0', b'0', @tc6, '848959fca8b887a9ac98afdd8fe001d8e7a694d265990b359d998011e9344c2b', b'1');
INSERT INTO question_source
  (question_id, source_type, source_name, source_year, source_question_no, paper_name, raw_ref, metadata)
VALUES
  (@q6, 'crawler_html', '计算机考研杂货铺', 2026, '6', '2026年408计算机学科专业基础综合模拟试题',
   'C:/Users/wutia/Downloads/csgraduates2026.html', '{"subject": "数据结构", "html": true}');

-- Q7
INSERT INTO t_text_content (content, create_time)
VALUES ('{"titleContent": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q7-title.html\\" data-fallback=\\"设有序向图 G = ( V , E ) ，其中顶点集 V 的大小为 n = ∣ V ∣ ，每条边 e ∈ E 都标记有一个唯一的字符（不同边可标记相同字符）。定义字符串集 S 为：所有由 G 中任意一条路径（路径可包含单个顶点，对应空字符串）上的边标记按顺序拼接而成的字符串的集合。以下说法错误的是（ ）\\"></div>", "analyze": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q7-analysis.html\\" data-fallback=\\"正确答案： B 【解析】 对于选项 A：若图 G 无环，则任意路径不能重复经过顶点，否则会形成环，因此最长路径的边数不超过 n − 1 。由于图是有限的，所有可能的路径数量有限，每条路径对应一个字符串（可能重复），但字符串集合 S 由有限个字符串组成，故 S 是有限集。A 正确。 对于选项 B：若图 G 无环，则任意路\\"></div>", "questionItemObjects": [{"prefix": "A", "content": "若\\n<span class=\\"katex\\"><span aria-hidden=\\"true\\" class=\\"katex-html\\"><span class=\\"base\\"><span class=\\"strut\\" style=\\"height:.6833em\\"></span><span class=\\"mord mathnormal\\">G</span></span></span></span>\\n无环，则\\n<span class=\\"katex\\"><span aria-hidden=\\"true\\" class=\\"katex-html\\"><span class=\\"base\\"><span class=\\"strut\\" style=\\"height:.6833em\\"></span><span class=\\"mord mathnormal\\" style=\\"margin-right:.05764em\\">S</span></span></span></span>\\n是有限集", "itemUuid": "371f1f00"}, {"prefix": "B", "content": "若\\n<span class=\\"katex\\"><span aria-hidden=\\"true\\" class=\\"katex-html\\"><span class=\\"base\\"><span class=\\"strut\\" style=\\"height:.6833em\\"></span><span class=\\"mord mathnormal\\">G</span></span></span></span>\\n无环，则\\n<span class=\\"katex\\"><span aria-hidden=\\"true\\" class=\\"katex-html\\"><span class=\\"base\\"><span class=\\"strut\\" style=\\"height:.6833em\\"></span><span class=\\"mord mathnormal\\" style=\\"margin-right:.05764em\\">S</span></span></span></span>\\n中存在长度为\\n<span class=\\"katex\\"><span aria-hidden=\\"true\\" class=\\"katex-html\\"><span class=\\"base\\"><span class=\\"strut\\" style=\\"height:.4306em\\"></span><span class=\\"mord mathnormal\\">n</span></span></span></span>\\n的字符串", "itemUuid": "b87e8ddc"}, {"prefix": "C", "content": "若\\n<span class=\\"katex\\"><span aria-hidden=\\"true\\" class=\\"katex-html\\"><span class=\\"base\\"><span class=\\"strut\\" style=\\"height:.6833em\\"></span><span class=\\"mord mathnormal\\">G</span></span></span></span>\\n有环，则\\n<span class=\\"katex\\"><span aria-hidden=\\"true\\" class=\\"katex-html\\"><span class=\\"base\\"><span class=\\"strut\\" style=\\"height:.6833em\\"></span><span class=\\"mord mathnormal\\" style=\\"margin-right:.05764em\\">S</span></span></span></span>\\n中存在长度大于\\n<span class=\\"katex\\"><span aria-hidden=\\"true\\" class=\\"katex-html\\"><span class=\\"base\\"><span class=\\"strut\\" style=\\"height:.4306em\\"></span><span class=\\"mord mathnormal\\">n</span></span></span></span>\\n的字符串", "itemUuid": "03ab12ce"}, {"prefix": "D", "content": "若\\n<span class=\\"katex\\"><span aria-hidden=\\"true\\" class=\\"katex-html\\"><span class=\\"base\\"><span class=\\"strut\\" style=\\"height:.6833em\\"></span><span class=\\"mord mathnormal\\">G</span></span></span></span>\\n有环，则\\n<span class=\\"katex\\"><span aria-hidden=\\"true\\" class=\\"katex-html\\"><span class=\\"base\\"><span class=\\"strut\\" style=\\"height:.6833em\\"></span><span class=\\"mord mathnormal\\" style=\\"margin-right:.05764em\\">S</span></span></span></span>\\n中存在长度小于\\n<span class=\\"katex\\"><span aria-hidden=\\"true\\" class=\\"katex-html\\"><span class=\\"base\\"><span class=\\"strut\\" style=\\"height:.6444em\\"></span><span class=\\"mord\\">2</span><span class=\\"mord mathnormal\\">n</span></span></span></span>\\n的字符串", "itemUuid": "0d54e763"}]}', NOW());
SET @tc7 = LAST_INSERT_ID();
INSERT INTO t_question
  (question_type, subject_id, score, grade_level, difficult, correct, info_text_content_id, create_user, status, deleted,
   title, options, correct_answer, analysis, difficulty, knowledge_point, source, source_year, source_question_no, tags, images,
   title_text, analysis_text, content_format, has_image, has_code)
VALUES
  (1, 1, 20, NULL, 2, 'B', @tc7, 1, 1, b'0',
   '<div class="question-html-ref" data-src="question-html/2026/q7-title.html" data-fallback="设有序向图 G = ( V , E ) ，其中顶点集 V 的大小为 n = ∣ V ∣ ，每条边 e ∈ E 都标记有一个唯一的字符（不同边可标记相同字符）。定义字符串集 S 为：所有由 G 中任意一条路径（路径可包含单个顶点，对应空字符串）上的边标记按顺序拼接而成的字符串的集合。以下说法错误的是（ ）"></div>', '[{"prefix": "A", "content": "若\\n<span class=\\"katex\\"><span aria-hidden=\\"true\\" class=\\"katex-html\\"><span class=\\"base\\"><span class=\\"strut\\" style=\\"height:.6833em\\"></span><span class=\\"mord mathnormal\\">G</span></span></span></span>\\n无环，则\\n<span class=\\"katex\\"><span aria-hidden=\\"true\\" class=\\"katex-html\\"><span class=\\"base\\"><span class=\\"strut\\" style=\\"height:.6833em\\"></span><span class=\\"mord mathnormal\\" style=\\"margin-right:.05764em\\">S</span></span></span></span>\\n是有限集", "itemUuid": "371f1f00"}, {"prefix": "B", "content": "若\\n<span class=\\"katex\\"><span aria-hidden=\\"true\\" class=\\"katex-html\\"><span class=\\"base\\"><span class=\\"strut\\" style=\\"height:.6833em\\"></span><span class=\\"mord mathnormal\\">G</span></span></span></span>\\n无环，则\\n<span class=\\"katex\\"><span aria-hidden=\\"true\\" class=\\"katex-html\\"><span class=\\"base\\"><span class=\\"strut\\" style=\\"height:.6833em\\"></span><span class=\\"mord mathnormal\\" style=\\"margin-right:.05764em\\">S</span></span></span></span>\\n中存在长度为\\n<span class=\\"katex\\"><span aria-hidden=\\"true\\" class=\\"katex-html\\"><span class=\\"base\\"><span class=\\"strut\\" style=\\"height:.4306em\\"></span><span class=\\"mord mathnormal\\">n</span></span></span></span>\\n的字符串", "itemUuid": "b87e8ddc"}, {"prefix": "C", "content": "若\\n<span class=\\"katex\\"><span aria-hidden=\\"true\\" class=\\"katex-html\\"><span class=\\"base\\"><span class=\\"strut\\" style=\\"height:.6833em\\"></span><span class=\\"mord mathnormal\\">G</span></span></span></span>\\n有环，则\\n<span class=\\"katex\\"><span aria-hidden=\\"true\\" class=\\"katex-html\\"><span class=\\"base\\"><span class=\\"strut\\" style=\\"height:.6833em\\"></span><span class=\\"mord mathnormal\\" style=\\"margin-right:.05764em\\">S</span></span></span></span>\\n中存在长度大于\\n<span class=\\"katex\\"><span aria-hidden=\\"true\\" class=\\"katex-html\\"><span class=\\"base\\"><span class=\\"strut\\" style=\\"height:.4306em\\"></span><span class=\\"mord mathnormal\\">n</span></span></span></span>\\n的字符串", "itemUuid": "03ab12ce"}, {"prefix": "D", "content": "若\\n<span class=\\"katex\\"><span aria-hidden=\\"true\\" class=\\"katex-html\\"><span class=\\"base\\"><span class=\\"strut\\" style=\\"height:.6833em\\"></span><span class=\\"mord mathnormal\\">G</span></span></span></span>\\n有环，则\\n<span class=\\"katex\\"><span aria-hidden=\\"true\\" class=\\"katex-html\\"><span class=\\"base\\"><span class=\\"strut\\" style=\\"height:.6833em\\"></span><span class=\\"mord mathnormal\\" style=\\"margin-right:.05764em\\">S</span></span></span></span>\\n中存在长度小于\\n<span class=\\"katex\\"><span aria-hidden=\\"true\\" class=\\"katex-html\\"><span class=\\"base\\"><span class=\\"strut\\" style=\\"height:.6444em\\"></span><span class=\\"mord\\">2</span><span class=\\"mord mathnormal\\">n</span></span></span></span>\\n的字符串", "itemUuid": "0d54e763"}]', 'B', '<div class="question-html-ref" data-src="question-html/2026/q7-analysis.html" data-fallback="正确答案： B 【解析】 对于选项 A：若图 G 无环，则任意路径不能重复经过顶点，否则会形成环，因此最长路径的边数不超过 n − 1 。由于图是有限的，所有可能的路径数量有限，每条路径对应一个字符串（可能重复），但字符串集合 S 由有限个字符串组成，故 S 是有限集。A 正确。 对于选项 B：若图 G 无环，则任意路"></div>',
   2, NULL, '2026年408模拟题', 2026, 7, 'html,external_html,katex', '',
   '设有序向图 G = ( V , E ) ，其中顶点集 V 的大小为 n = ∣ V ∣ ，每条边 e ∈ E 都标记有一个唯一的字符（不同边可标记相同字符）。定义字符串集 S 为：所有由 G 中任意一条路径（路径可包含单个顶点，对应空字符串）上的边标记按顺序拼接而成的字符串的集合。以下说法错误的是（ ）', '正确答案： B 【解析】 对于选项 A：若图 G 无环，则任意路径不能重复经过顶点，否则会形成环，因此最长路径的边数不超过 n − 1 。由于图是有限的，所有可能的路径数量有限，每条路径对应一个字符串（可能重复），但字符串集合 S 由有限个字符串组成，故 S 是有限集。A 正确。 对于选项 B：若图 G 无环，则任意路径最多经过 n 个不同的顶点，因此边数最多为 n − 1 ，对应的字符串长度最多为 n − 1 。所以 S 中不可能存在长度为 n 的字符串。B 错误。 对于选项 C：若图 G 有环，则存在一个环，可以从环上某点出发沿环行走任意多圈，得到任意长的路径，从而产生长度大于 n 的字符串。C 正确。 对于选项 D：若图 G 有环，S 中至少包含空字符串（长度为 0 ），而 0 < 2 n （ n ≥ 1 ），因此存在长度小于 2 n 的字符串。D 正确。 综上，说法错误的是 B。', 'html', b'0', b'0');
SET @q7 = LAST_INSERT_ID();
INSERT INTO question_content
  (question_id, version, title, options, correct_answer, analysis, title_text, analysis_text, content_format, has_image, has_code, legacy_text_content_id, source_hash, is_current)
VALUES
  (@q7, 1, '<div class="question-html-ref" data-src="question-html/2026/q7-title.html" data-fallback="设有序向图 G = ( V , E ) ，其中顶点集 V 的大小为 n = ∣ V ∣ ，每条边 e ∈ E 都标记有一个唯一的字符（不同边可标记相同字符）。定义字符串集 S 为：所有由 G 中任意一条路径（路径可包含单个顶点，对应空字符串）上的边标记按顺序拼接而成的字符串的集合。以下说法错误的是（ ）"></div>', '[{"prefix": "A", "content": "若\\n<span class=\\"katex\\"><span aria-hidden=\\"true\\" class=\\"katex-html\\"><span class=\\"base\\"><span class=\\"strut\\" style=\\"height:.6833em\\"></span><span class=\\"mord mathnormal\\">G</span></span></span></span>\\n无环，则\\n<span class=\\"katex\\"><span aria-hidden=\\"true\\" class=\\"katex-html\\"><span class=\\"base\\"><span class=\\"strut\\" style=\\"height:.6833em\\"></span><span class=\\"mord mathnormal\\" style=\\"margin-right:.05764em\\">S</span></span></span></span>\\n是有限集", "itemUuid": "371f1f00"}, {"prefix": "B", "content": "若\\n<span class=\\"katex\\"><span aria-hidden=\\"true\\" class=\\"katex-html\\"><span class=\\"base\\"><span class=\\"strut\\" style=\\"height:.6833em\\"></span><span class=\\"mord mathnormal\\">G</span></span></span></span>\\n无环，则\\n<span class=\\"katex\\"><span aria-hidden=\\"true\\" class=\\"katex-html\\"><span class=\\"base\\"><span class=\\"strut\\" style=\\"height:.6833em\\"></span><span class=\\"mord mathnormal\\" style=\\"margin-right:.05764em\\">S</span></span></span></span>\\n中存在长度为\\n<span class=\\"katex\\"><span aria-hidden=\\"true\\" class=\\"katex-html\\"><span class=\\"base\\"><span class=\\"strut\\" style=\\"height:.4306em\\"></span><span class=\\"mord mathnormal\\">n</span></span></span></span>\\n的字符串", "itemUuid": "b87e8ddc"}, {"prefix": "C", "content": "若\\n<span class=\\"katex\\"><span aria-hidden=\\"true\\" class=\\"katex-html\\"><span class=\\"base\\"><span class=\\"strut\\" style=\\"height:.6833em\\"></span><span class=\\"mord mathnormal\\">G</span></span></span></span>\\n有环，则\\n<span class=\\"katex\\"><span aria-hidden=\\"true\\" class=\\"katex-html\\"><span class=\\"base\\"><span class=\\"strut\\" style=\\"height:.6833em\\"></span><span class=\\"mord mathnormal\\" style=\\"margin-right:.05764em\\">S</span></span></span></span>\\n中存在长度大于\\n<span class=\\"katex\\"><span aria-hidden=\\"true\\" class=\\"katex-html\\"><span class=\\"base\\"><span class=\\"strut\\" style=\\"height:.4306em\\"></span><span class=\\"mord mathnormal\\">n</span></span></span></span>\\n的字符串", "itemUuid": "03ab12ce"}, {"prefix": "D", "content": "若\\n<span class=\\"katex\\"><span aria-hidden=\\"true\\" class=\\"katex-html\\"><span class=\\"base\\"><span class=\\"strut\\" style=\\"height:.6833em\\"></span><span class=\\"mord mathnormal\\">G</span></span></span></span>\\n有环，则\\n<span class=\\"katex\\"><span aria-hidden=\\"true\\" class=\\"katex-html\\"><span class=\\"base\\"><span class=\\"strut\\" style=\\"height:.6833em\\"></span><span class=\\"mord mathnormal\\" style=\\"margin-right:.05764em\\">S</span></span></span></span>\\n中存在长度小于\\n<span class=\\"katex\\"><span aria-hidden=\\"true\\" class=\\"katex-html\\"><span class=\\"base\\"><span class=\\"strut\\" style=\\"height:.6444em\\"></span><span class=\\"mord\\">2</span><span class=\\"mord mathnormal\\">n</span></span></span></span>\\n的字符串", "itemUuid": "0d54e763"}]', 'B', '<div class="question-html-ref" data-src="question-html/2026/q7-analysis.html" data-fallback="正确答案： B 【解析】 对于选项 A：若图 G 无环，则任意路径不能重复经过顶点，否则会形成环，因此最长路径的边数不超过 n − 1 。由于图是有限的，所有可能的路径数量有限，每条路径对应一个字符串（可能重复），但字符串集合 S 由有限个字符串组成，故 S 是有限集。A 正确。 对于选项 B：若图 G 无环，则任意路"></div>',
   '设有序向图 G = ( V , E ) ，其中顶点集 V 的大小为 n = ∣ V ∣ ，每条边 e ∈ E 都标记有一个唯一的字符（不同边可标记相同字符）。定义字符串集 S 为：所有由 G 中任意一条路径（路径可包含单个顶点，对应空字符串）上的边标记按顺序拼接而成的字符串的集合。以下说法错误的是（ ）', '正确答案： B 【解析】 对于选项 A：若图 G 无环，则任意路径不能重复经过顶点，否则会形成环，因此最长路径的边数不超过 n − 1 。由于图是有限的，所有可能的路径数量有限，每条路径对应一个字符串（可能重复），但字符串集合 S 由有限个字符串组成，故 S 是有限集。A 正确。 对于选项 B：若图 G 无环，则任意路径最多经过 n 个不同的顶点，因此边数最多为 n − 1 ，对应的字符串长度最多为 n − 1 。所以 S 中不可能存在长度为 n 的字符串。B 错误。 对于选项 C：若图 G 有环，则存在一个环，可以从环上某点出发沿环行走任意多圈，得到任意长的路径，从而产生长度大于 n 的字符串。C 正确。 对于选项 D：若图 G 有环，S 中至少包含空字符串（长度为 0 ），而 0 < 2 n （ n ≥ 1 ），因此存在长度小于 2 n 的字符串。D 正确。 综上，说法错误的是 B。', 'html', b'0', b'0', @tc7, 'cff19113923059b8e4a766622ceafdbe1987888f952a7e04d449ad8acf553c27', b'1');
INSERT INTO question_source
  (question_id, source_type, source_name, source_year, source_question_no, paper_name, raw_ref, metadata)
VALUES
  (@q7, 'crawler_html', '计算机考研杂货铺', 2026, '7', '2026年408计算机学科专业基础综合模拟试题',
   'C:/Users/wutia/Downloads/csgraduates2026.html', '{"subject": "数据结构", "html": true}');

-- Q8
INSERT INTO t_text_content (content, create_time)
VALUES ('{"titleContent": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q8-title.html\\" data-fallback=\\"已知平衡二叉树（AVL 树）的定义为：树中任意一个节点的左右子树的高度差的绝对值不超过 1，且左右子树均为平衡二叉树。若某平衡二叉树的高度为 4（根节点的高度记为 1），则其根节点的左右子树的节点数之差最多为（ ）\\"></div>", "analyze": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q8-analysis.html\\" data-fallback=\\"正确答案： D 【解析】 平衡二叉树高度为 4（根节点高度为 1），因此左右子树的高度组合为： 两者均为 3，或 一个为 3、另一个为 2。 为最大化节点数之差，应使较高子树取最大节点数，较低子树取最小节点数。 高度 3 的平衡二叉树最大节点数为 7（满二叉树）， 高度 2 的最小节点数为 2（根节点加一个子节点）， \\"></div>", "questionItemObjects": [{"prefix": "A", "content": "1", "itemUuid": "4db5d8ba"}, {"prefix": "B", "content": "2", "itemUuid": "032ca6fd"}, {"prefix": "C", "content": "3", "itemUuid": "9ce14fb4"}, {"prefix": "D", "content": "5", "itemUuid": "e6486c22"}]}', NOW());
SET @tc8 = LAST_INSERT_ID();
INSERT INTO t_question
  (question_type, subject_id, score, grade_level, difficult, correct, info_text_content_id, create_user, status, deleted,
   title, options, correct_answer, analysis, difficulty, knowledge_point, source, source_year, source_question_no, tags, images,
   title_text, analysis_text, content_format, has_image, has_code)
VALUES
  (1, 1, 20, NULL, 2, 'D', @tc8, 1, 1, b'0',
   '<div class="question-html-ref" data-src="question-html/2026/q8-title.html" data-fallback="已知平衡二叉树（AVL 树）的定义为：树中任意一个节点的左右子树的高度差的绝对值不超过 1，且左右子树均为平衡二叉树。若某平衡二叉树的高度为 4（根节点的高度记为 1），则其根节点的左右子树的节点数之差最多为（ ）"></div>', '[{"prefix": "A", "content": "1", "itemUuid": "4db5d8ba"}, {"prefix": "B", "content": "2", "itemUuid": "032ca6fd"}, {"prefix": "C", "content": "3", "itemUuid": "9ce14fb4"}, {"prefix": "D", "content": "5", "itemUuid": "e6486c22"}]', 'D', '<div class="question-html-ref" data-src="question-html/2026/q8-analysis.html" data-fallback="正确答案： D 【解析】 平衡二叉树高度为 4（根节点高度为 1），因此左右子树的高度组合为： 两者均为 3，或 一个为 3、另一个为 2。 为最大化节点数之差，应使较高子树取最大节点数，较低子树取最小节点数。 高度 3 的平衡二叉树最大节点数为 7（满二叉树）， 高度 2 的最小节点数为 2（根节点加一个子节点）， "></div>',
   2, NULL, '2026年408模拟题', 2026, 8, 'html,external_html,katex', '',
   '已知平衡二叉树（AVL 树）的定义为：树中任意一个节点的左右子树的高度差的绝对值不超过 1，且左右子树均为平衡二叉树。若某平衡二叉树的高度为 4（根节点的高度记为 1），则其根节点的左右子树的节点数之差最多为（ ）', '正确答案： D 【解析】 平衡二叉树高度为 4（根节点高度为 1），因此左右子树的高度组合为： 两者均为 3，或 一个为 3、另一个为 2。 为最大化节点数之差，应使较高子树取最大节点数，较低子树取最小节点数。 高度 3 的平衡二叉树最大节点数为 7（满二叉树）， 高度 2 的最小节点数为 2（根节点加一个子节点）， 此时节点数之差为 7 − 2 = 5 。 若左右子树高度均为 3，节点数之差最大为 7 − 4 = 3 。 因此，根节点的左右子树节点数之差最多为 5。', 'html', b'0', b'0');
SET @q8 = LAST_INSERT_ID();
INSERT INTO question_content
  (question_id, version, title, options, correct_answer, analysis, title_text, analysis_text, content_format, has_image, has_code, legacy_text_content_id, source_hash, is_current)
VALUES
  (@q8, 1, '<div class="question-html-ref" data-src="question-html/2026/q8-title.html" data-fallback="已知平衡二叉树（AVL 树）的定义为：树中任意一个节点的左右子树的高度差的绝对值不超过 1，且左右子树均为平衡二叉树。若某平衡二叉树的高度为 4（根节点的高度记为 1），则其根节点的左右子树的节点数之差最多为（ ）"></div>', '[{"prefix": "A", "content": "1", "itemUuid": "4db5d8ba"}, {"prefix": "B", "content": "2", "itemUuid": "032ca6fd"}, {"prefix": "C", "content": "3", "itemUuid": "9ce14fb4"}, {"prefix": "D", "content": "5", "itemUuid": "e6486c22"}]', 'D', '<div class="question-html-ref" data-src="question-html/2026/q8-analysis.html" data-fallback="正确答案： D 【解析】 平衡二叉树高度为 4（根节点高度为 1），因此左右子树的高度组合为： 两者均为 3，或 一个为 3、另一个为 2。 为最大化节点数之差，应使较高子树取最大节点数，较低子树取最小节点数。 高度 3 的平衡二叉树最大节点数为 7（满二叉树）， 高度 2 的最小节点数为 2（根节点加一个子节点）， "></div>',
   '已知平衡二叉树（AVL 树）的定义为：树中任意一个节点的左右子树的高度差的绝对值不超过 1，且左右子树均为平衡二叉树。若某平衡二叉树的高度为 4（根节点的高度记为 1），则其根节点的左右子树的节点数之差最多为（ ）', '正确答案： D 【解析】 平衡二叉树高度为 4（根节点高度为 1），因此左右子树的高度组合为： 两者均为 3，或 一个为 3、另一个为 2。 为最大化节点数之差，应使较高子树取最大节点数，较低子树取最小节点数。 高度 3 的平衡二叉树最大节点数为 7（满二叉树）， 高度 2 的最小节点数为 2（根节点加一个子节点）， 此时节点数之差为 7 − 2 = 5 。 若左右子树高度均为 3，节点数之差最大为 7 − 4 = 3 。 因此，根节点的左右子树节点数之差最多为 5。', 'html', b'0', b'0', @tc8, 'fb9f07c9c12bdf4d8a95e370dd3c9879e6e62275b12b45112125b735520ea801', b'1');
INSERT INTO question_source
  (question_id, source_type, source_name, source_year, source_question_no, paper_name, raw_ref, metadata)
VALUES
  (@q8, 'crawler_html', '计算机考研杂货铺', 2026, '8', '2026年408计算机学科专业基础综合模拟试题',
   'C:/Users/wutia/Downloads/csgraduates2026.html', '{"subject": "数据结构", "html": true}');

-- Q9
INSERT INTO t_text_content (content, create_time)
VALUES ('{"titleContent": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q9-title.html\\" data-fallback=\\"使用直接插入排序对序列进行升序排序，以下比较次数最少的是（ ）\\"></div>", "analyze": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q9-analysis.html\\" data-fallback=\\"正确答案： B 【解析】 直接插入排序的比较次数取决于序列的初始有序程度。对于每个序列，从第二个元素开始，将其与前面已排序的元素从后往前比较，直到找到正确位置，记录比较次数。 选项 A ：序列 30, 27, 56, 41, 80, 95, 69 的总比较次数为 1 + 1 + 2 + 1 + 1 + 3 = 9 次。\\"></div>", "questionItemObjects": [{"prefix": "A", "content": "30,27,56,41,80,95,69", "itemUuid": "39a47916"}, {"prefix": "B", "content": "31,43,26,55,63,99,77", "itemUuid": "660dabd0"}, {"prefix": "C", "content": "61,84,51,23,34,91,40", "itemUuid": "af04e2d4"}, {"prefix": "D", "content": "93,32,48,81,50,21,72", "itemUuid": "c9398011"}]}', NOW());
SET @tc9 = LAST_INSERT_ID();
INSERT INTO t_question
  (question_type, subject_id, score, grade_level, difficult, correct, info_text_content_id, create_user, status, deleted,
   title, options, correct_answer, analysis, difficulty, knowledge_point, source, source_year, source_question_no, tags, images,
   title_text, analysis_text, content_format, has_image, has_code)
VALUES
  (1, 1, 20, NULL, 2, 'B', @tc9, 1, 1, b'0',
   '<div class="question-html-ref" data-src="question-html/2026/q9-title.html" data-fallback="使用直接插入排序对序列进行升序排序，以下比较次数最少的是（ ）"></div>', '[{"prefix": "A", "content": "30,27,56,41,80,95,69", "itemUuid": "39a47916"}, {"prefix": "B", "content": "31,43,26,55,63,99,77", "itemUuid": "660dabd0"}, {"prefix": "C", "content": "61,84,51,23,34,91,40", "itemUuid": "af04e2d4"}, {"prefix": "D", "content": "93,32,48,81,50,21,72", "itemUuid": "c9398011"}]', 'B', '<div class="question-html-ref" data-src="question-html/2026/q9-analysis.html" data-fallback="正确答案： B 【解析】 直接插入排序的比较次数取决于序列的初始有序程度。对于每个序列，从第二个元素开始，将其与前面已排序的元素从后往前比较，直到找到正确位置，记录比较次数。 选项 A ：序列 30, 27, 56, 41, 80, 95, 69 的总比较次数为 1 + 1 + 2 + 1 + 1 + 3 = 9 次。"></div>',
   2, NULL, '2026年408模拟题', 2026, 9, 'html,external_html,katex', '',
   '使用直接插入排序对序列进行升序排序，以下比较次数最少的是（ ）', '正确答案： B 【解析】 直接插入排序的比较次数取决于序列的初始有序程度。对于每个序列，从第二个元素开始，将其与前面已排序的元素从后往前比较，直到找到正确位置，记录比较次数。 选项 A ：序列 30, 27, 56, 41, 80, 95, 69 的总比较次数为 1 + 1 + 2 + 1 + 1 + 3 = 9 次。 选项 B ：序列 31, 43, 26, 55, 63, 99, 77 的总比较次数为 1 + 2 + 1 + 1 + 1 + 2 = 8 次。 选项 C ：序列 61, 84, 51, 23, 34, 91, 40 的总比较次数为 1 + 2 + 3 + 4 + 1 + 5 = 16 次。 选项 D ：序列 93, 32, 48, 81, 50, 21, 72 的总比较次数为 1 + 2 + 2 + 3 + 5 + 3 = 16 次。 比较次数最少的是选项 B，共 8 次。', 'html', b'0', b'0');
SET @q9 = LAST_INSERT_ID();
INSERT INTO question_content
  (question_id, version, title, options, correct_answer, analysis, title_text, analysis_text, content_format, has_image, has_code, legacy_text_content_id, source_hash, is_current)
VALUES
  (@q9, 1, '<div class="question-html-ref" data-src="question-html/2026/q9-title.html" data-fallback="使用直接插入排序对序列进行升序排序，以下比较次数最少的是（ ）"></div>', '[{"prefix": "A", "content": "30,27,56,41,80,95,69", "itemUuid": "39a47916"}, {"prefix": "B", "content": "31,43,26,55,63,99,77", "itemUuid": "660dabd0"}, {"prefix": "C", "content": "61,84,51,23,34,91,40", "itemUuid": "af04e2d4"}, {"prefix": "D", "content": "93,32,48,81,50,21,72", "itemUuid": "c9398011"}]', 'B', '<div class="question-html-ref" data-src="question-html/2026/q9-analysis.html" data-fallback="正确答案： B 【解析】 直接插入排序的比较次数取决于序列的初始有序程度。对于每个序列，从第二个元素开始，将其与前面已排序的元素从后往前比较，直到找到正确位置，记录比较次数。 选项 A ：序列 30, 27, 56, 41, 80, 95, 69 的总比较次数为 1 + 1 + 2 + 1 + 1 + 3 = 9 次。"></div>',
   '使用直接插入排序对序列进行升序排序，以下比较次数最少的是（ ）', '正确答案： B 【解析】 直接插入排序的比较次数取决于序列的初始有序程度。对于每个序列，从第二个元素开始，将其与前面已排序的元素从后往前比较，直到找到正确位置，记录比较次数。 选项 A ：序列 30, 27, 56, 41, 80, 95, 69 的总比较次数为 1 + 1 + 2 + 1 + 1 + 3 = 9 次。 选项 B ：序列 31, 43, 26, 55, 63, 99, 77 的总比较次数为 1 + 2 + 1 + 1 + 1 + 2 = 8 次。 选项 C ：序列 61, 84, 51, 23, 34, 91, 40 的总比较次数为 1 + 2 + 3 + 4 + 1 + 5 = 16 次。 选项 D ：序列 93, 32, 48, 81, 50, 21, 72 的总比较次数为 1 + 2 + 2 + 3 + 5 + 3 = 16 次。 比较次数最少的是选项 B，共 8 次。', 'html', b'0', b'0', @tc9, 'd9c1dbd00b426a4b0d5a45077e1056fdef29bb589259e271678f1276d8f146e1', b'1');
INSERT INTO question_source
  (question_id, source_type, source_name, source_year, source_question_no, paper_name, raw_ref, metadata)
VALUES
  (@q9, 'crawler_html', '计算机考研杂货铺', 2026, '9', '2026年408计算机学科专业基础综合模拟试题',
   'C:/Users/wutia/Downloads/csgraduates2026.html', '{"subject": "数据结构", "html": true}');

-- Q10
INSERT INTO t_text_content (content, create_time)
VALUES ('{"titleContent": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q10-title.html\\" data-fallback=\\"现有 n 名学生的成绩记录，每位学生的记录包含两门课程的成绩： 课程 1 （记为 C 1 ​ ）和 课程 2 （记为 C 2 ​ ）。 排序规则如下： 首先，依据 C 1 ​ 成绩升序排列； 若两名学生的 C 1 ​ 成绩相同，则依据其总分（即 C 1 ​ + C 2 ​ ）升序排列。 请从下列排序算法中，选择最适合实\\"></div>", "analyze": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q10-analysis.html\\" data-fallback=\\"正确答案： A 【解析】排序规则要求先按 C1 成绩升序，再按总分升序，这属于多键排序问题。基数排序是一种稳定的排序算法，特别适合多键排序，因为它可以对每个键位进行独立排序，且稳定性保证了当主键（C1）相同时，次键（总分）的顺序得以保持。具体实现时，可以先按总分（低优先级键）进行稳定排序，再按 C1（高优先级键）进行稳\\"></div>", "questionItemObjects": [{"prefix": "A", "content": "基数排序", "itemUuid": "04fd5c8b"}, {"prefix": "B", "content": "快速排序", "itemUuid": "551358d9"}, {"prefix": "C", "content": "希尔排序", "itemUuid": "7b81dbff"}, {"prefix": "D", "content": "选择排序", "itemUuid": "ff12c41c"}]}', NOW());
SET @tc10 = LAST_INSERT_ID();
INSERT INTO t_question
  (question_type, subject_id, score, grade_level, difficult, correct, info_text_content_id, create_user, status, deleted,
   title, options, correct_answer, analysis, difficulty, knowledge_point, source, source_year, source_question_no, tags, images,
   title_text, analysis_text, content_format, has_image, has_code)
VALUES
  (1, 1, 20, NULL, 2, 'A', @tc10, 1, 1, b'0',
   '<div class="question-html-ref" data-src="question-html/2026/q10-title.html" data-fallback="现有 n 名学生的成绩记录，每位学生的记录包含两门课程的成绩： 课程 1 （记为 C 1 ​ ）和 课程 2 （记为 C 2 ​ ）。 排序规则如下： 首先，依据 C 1 ​ 成绩升序排列； 若两名学生的 C 1 ​ 成绩相同，则依据其总分（即 C 1 ​ + C 2 ​ ）升序排列。 请从下列排序算法中，选择最适合实"></div>', '[{"prefix": "A", "content": "基数排序", "itemUuid": "04fd5c8b"}, {"prefix": "B", "content": "快速排序", "itemUuid": "551358d9"}, {"prefix": "C", "content": "希尔排序", "itemUuid": "7b81dbff"}, {"prefix": "D", "content": "选择排序", "itemUuid": "ff12c41c"}]', 'A', '<div class="question-html-ref" data-src="question-html/2026/q10-analysis.html" data-fallback="正确答案： A 【解析】排序规则要求先按 C1 成绩升序，再按总分升序，这属于多键排序问题。基数排序是一种稳定的排序算法，特别适合多键排序，因为它可以对每个键位进行独立排序，且稳定性保证了当主键（C1）相同时，次键（总分）的顺序得以保持。具体实现时，可以先按总分（低优先级键）进行稳定排序，再按 C1（高优先级键）进行稳"></div>',
   2, NULL, '2026年408模拟题', 2026, 10, 'html,external_html,katex', '',
   '现有 n 名学生的成绩记录，每位学生的记录包含两门课程的成绩： 课程 1 （记为 C 1 ​ ）和 课程 2 （记为 C 2 ​ ）。 排序规则如下： 首先，依据 C 1 ​ 成绩升序排列； 若两名学生的 C 1 ​ 成绩相同，则依据其总分（即 C 1 ​ + C 2 ​ ）升序排列。 请从下列排序算法中，选择最适合实现上述需求的算法（ ）', '正确答案： A 【解析】排序规则要求先按 C1 成绩升序，再按总分升序，这属于多键排序问题。基数排序是一种稳定的排序算法，特别适合多键排序，因为它可以对每个键位进行独立排序，且稳定性保证了当主键（C1）相同时，次键（总分）的顺序得以保持。具体实现时，可以先按总分（低优先级键）进行稳定排序，再按 C1（高优先级键）进行稳定排序，从而满足规则。其他算法中，快速排序、希尔排序和选择排序都不是稳定的，虽然可以通过自定义比较函数在一次排序中处理多键，但稳定性和效率不如基数排序。此外，学生成绩通常为整数，基数排序对整数排序效率较高。因此，基数排序是最适合的算法。', 'html', b'0', b'0');
SET @q10 = LAST_INSERT_ID();
INSERT INTO question_content
  (question_id, version, title, options, correct_answer, analysis, title_text, analysis_text, content_format, has_image, has_code, legacy_text_content_id, source_hash, is_current)
VALUES
  (@q10, 1, '<div class="question-html-ref" data-src="question-html/2026/q10-title.html" data-fallback="现有 n 名学生的成绩记录，每位学生的记录包含两门课程的成绩： 课程 1 （记为 C 1 ​ ）和 课程 2 （记为 C 2 ​ ）。 排序规则如下： 首先，依据 C 1 ​ 成绩升序排列； 若两名学生的 C 1 ​ 成绩相同，则依据其总分（即 C 1 ​ + C 2 ​ ）升序排列。 请从下列排序算法中，选择最适合实"></div>', '[{"prefix": "A", "content": "基数排序", "itemUuid": "04fd5c8b"}, {"prefix": "B", "content": "快速排序", "itemUuid": "551358d9"}, {"prefix": "C", "content": "希尔排序", "itemUuid": "7b81dbff"}, {"prefix": "D", "content": "选择排序", "itemUuid": "ff12c41c"}]', 'A', '<div class="question-html-ref" data-src="question-html/2026/q10-analysis.html" data-fallback="正确答案： A 【解析】排序规则要求先按 C1 成绩升序，再按总分升序，这属于多键排序问题。基数排序是一种稳定的排序算法，特别适合多键排序，因为它可以对每个键位进行独立排序，且稳定性保证了当主键（C1）相同时，次键（总分）的顺序得以保持。具体实现时，可以先按总分（低优先级键）进行稳定排序，再按 C1（高优先级键）进行稳"></div>',
   '现有 n 名学生的成绩记录，每位学生的记录包含两门课程的成绩： 课程 1 （记为 C 1 ​ ）和 课程 2 （记为 C 2 ​ ）。 排序规则如下： 首先，依据 C 1 ​ 成绩升序排列； 若两名学生的 C 1 ​ 成绩相同，则依据其总分（即 C 1 ​ + C 2 ​ ）升序排列。 请从下列排序算法中，选择最适合实现上述需求的算法（ ）', '正确答案： A 【解析】排序规则要求先按 C1 成绩升序，再按总分升序，这属于多键排序问题。基数排序是一种稳定的排序算法，特别适合多键排序，因为它可以对每个键位进行独立排序，且稳定性保证了当主键（C1）相同时，次键（总分）的顺序得以保持。具体实现时，可以先按总分（低优先级键）进行稳定排序，再按 C1（高优先级键）进行稳定排序，从而满足规则。其他算法中，快速排序、希尔排序和选择排序都不是稳定的，虽然可以通过自定义比较函数在一次排序中处理多键，但稳定性和效率不如基数排序。此外，学生成绩通常为整数，基数排序对整数排序效率较高。因此，基数排序是最适合的算法。', 'html', b'0', b'0', @tc10, '75c7e2105656892ecbda06e4ec67e801b4d7e30c33a4b3438459155f1198ac3d', b'1');
INSERT INTO question_source
  (question_id, source_type, source_name, source_year, source_question_no, paper_name, raw_ref, metadata)
VALUES
  (@q10, 'crawler_html', '计算机考研杂货铺', 2026, '10', '2026年408计算机学科专业基础综合模拟试题',
   'C:/Users/wutia/Downloads/csgraduates2026.html', '{"subject": "数据结构", "html": true}');

-- Q11
INSERT INTO t_text_content (content, create_time)
VALUES ('{"titleContent": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q11-title.html\\" data-fallback=\\"在外部排序的 k 路归并过程中，归并趟数为 d 。下列关于 k 、 d 、初始归并段及内存大小的说法中，正确的是（ ） Ⅰ. k 越大， d 越小 Ⅱ. 初始归并段数不影响 d Ⅲ. 内存大小限制初始归并段的最大长度\\"></div>", "analyze": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q11-analysis.html\\" data-fallback=\\"正确答案： C 【解析】 在外部排序的 k 路归并过程中，归并趟数 d 与初始归并段数 m 满足关系 d = ⌈ lo g k ​ m ⌉ 。 对于说法Ⅰ： k 越大， lo g k ​ m 越小，因此 d 越小，正确。 对于说法Ⅱ： d 直接依赖于 m ，初始归并段数变化会影响 d ，错误。 对于说法Ⅲ：生成初始归并\\"></div>", "questionItemObjects": [{"prefix": "A", "content": "Ⅰ", "itemUuid": "0d7f8b12"}, {"prefix": "B", "content": "Ⅰ、Ⅱ", "itemUuid": "de3f3da8"}, {"prefix": "C", "content": "Ⅰ、Ⅲ", "itemUuid": "997aaa51"}, {"prefix": "D", "content": "Ⅱ、Ⅲ", "itemUuid": "c748a514"}]}', NOW());
SET @tc11 = LAST_INSERT_ID();
INSERT INTO t_question
  (question_type, subject_id, score, grade_level, difficult, correct, info_text_content_id, create_user, status, deleted,
   title, options, correct_answer, analysis, difficulty, knowledge_point, source, source_year, source_question_no, tags, images,
   title_text, analysis_text, content_format, has_image, has_code)
VALUES
  (1, 1, 20, NULL, 2, 'C', @tc11, 1, 1, b'0',
   '<div class="question-html-ref" data-src="question-html/2026/q11-title.html" data-fallback="在外部排序的 k 路归并过程中，归并趟数为 d 。下列关于 k 、 d 、初始归并段及内存大小的说法中，正确的是（ ） Ⅰ. k 越大， d 越小 Ⅱ. 初始归并段数不影响 d Ⅲ. 内存大小限制初始归并段的最大长度"></div>', '[{"prefix": "A", "content": "Ⅰ", "itemUuid": "0d7f8b12"}, {"prefix": "B", "content": "Ⅰ、Ⅱ", "itemUuid": "de3f3da8"}, {"prefix": "C", "content": "Ⅰ、Ⅲ", "itemUuid": "997aaa51"}, {"prefix": "D", "content": "Ⅱ、Ⅲ", "itemUuid": "c748a514"}]', 'C', '<div class="question-html-ref" data-src="question-html/2026/q11-analysis.html" data-fallback="正确答案： C 【解析】 在外部排序的 k 路归并过程中，归并趟数 d 与初始归并段数 m 满足关系 d = ⌈ lo g k ​ m ⌉ 。 对于说法Ⅰ： k 越大， lo g k ​ m 越小，因此 d 越小，正确。 对于说法Ⅱ： d 直接依赖于 m ，初始归并段数变化会影响 d ，错误。 对于说法Ⅲ：生成初始归并"></div>',
   2, NULL, '2026年408模拟题', 2026, 11, 'html,external_html,katex', '',
   '在外部排序的 k 路归并过程中，归并趟数为 d 。下列关于 k 、 d 、初始归并段及内存大小的说法中，正确的是（ ） Ⅰ. k 越大， d 越小 Ⅱ. 初始归并段数不影响 d Ⅲ. 内存大小限制初始归并段的最大长度', '正确答案： C 【解析】 在外部排序的 k 路归并过程中，归并趟数 d 与初始归并段数 m 满足关系 d = ⌈ lo g k ​ m ⌉ 。 对于说法Ⅰ： k 越大， lo g k ​ m 越小，因此 d 越小，正确。 对于说法Ⅱ： d 直接依赖于 m ，初始归并段数变化会影响 d ，错误。 对于说法Ⅲ：生成初始归并段时，数据需读入内存进行内部排序，因此初始归并段的最大长度受内存大小限制，正确。 综上，Ⅰ和Ⅲ正确，对应选项 C。', 'html', b'0', b'0');
SET @q11 = LAST_INSERT_ID();
INSERT INTO question_content
  (question_id, version, title, options, correct_answer, analysis, title_text, analysis_text, content_format, has_image, has_code, legacy_text_content_id, source_hash, is_current)
VALUES
  (@q11, 1, '<div class="question-html-ref" data-src="question-html/2026/q11-title.html" data-fallback="在外部排序的 k 路归并过程中，归并趟数为 d 。下列关于 k 、 d 、初始归并段及内存大小的说法中，正确的是（ ） Ⅰ. k 越大， d 越小 Ⅱ. 初始归并段数不影响 d Ⅲ. 内存大小限制初始归并段的最大长度"></div>', '[{"prefix": "A", "content": "Ⅰ", "itemUuid": "0d7f8b12"}, {"prefix": "B", "content": "Ⅰ、Ⅱ", "itemUuid": "de3f3da8"}, {"prefix": "C", "content": "Ⅰ、Ⅲ", "itemUuid": "997aaa51"}, {"prefix": "D", "content": "Ⅱ、Ⅲ", "itemUuid": "c748a514"}]', 'C', '<div class="question-html-ref" data-src="question-html/2026/q11-analysis.html" data-fallback="正确答案： C 【解析】 在外部排序的 k 路归并过程中，归并趟数 d 与初始归并段数 m 满足关系 d = ⌈ lo g k ​ m ⌉ 。 对于说法Ⅰ： k 越大， lo g k ​ m 越小，因此 d 越小，正确。 对于说法Ⅱ： d 直接依赖于 m ，初始归并段数变化会影响 d ，错误。 对于说法Ⅲ：生成初始归并"></div>',
   '在外部排序的 k 路归并过程中，归并趟数为 d 。下列关于 k 、 d 、初始归并段及内存大小的说法中，正确的是（ ） Ⅰ. k 越大， d 越小 Ⅱ. 初始归并段数不影响 d Ⅲ. 内存大小限制初始归并段的最大长度', '正确答案： C 【解析】 在外部排序的 k 路归并过程中，归并趟数 d 与初始归并段数 m 满足关系 d = ⌈ lo g k ​ m ⌉ 。 对于说法Ⅰ： k 越大， lo g k ​ m 越小，因此 d 越小，正确。 对于说法Ⅱ： d 直接依赖于 m ，初始归并段数变化会影响 d ，错误。 对于说法Ⅲ：生成初始归并段时，数据需读入内存进行内部排序，因此初始归并段的最大长度受内存大小限制，正确。 综上，Ⅰ和Ⅲ正确，对应选项 C。', 'html', b'0', b'0', @tc11, '0c2a9111cf8736347a97373c05c2a6c6a484f9fafb237e103c41db5bf73d4bc6', b'1');
INSERT INTO question_source
  (question_id, source_type, source_name, source_year, source_question_no, paper_name, raw_ref, metadata)
VALUES
  (@q11, 'crawler_html', '计算机考研杂货铺', 2026, '11', '2026年408计算机学科专业基础综合模拟试题',
   'C:/Users/wutia/Downloads/csgraduates2026.html', '{"subject": "数据结构", "html": true}');

-- Q12
INSERT INTO t_text_content (content, create_time)
VALUES ('{"titleContent": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q12-title.html\\" data-fallback=\\"下列关于计算机的系统层次的叙述，错误的是\\"></div>", "analyze": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q12-analysis.html\\" data-fallback=\\"正确答案： C 【解析】 选项 A 正确，计算机系统层次的最上层是应用软件层； 选项 B 正确，指令集体系结构（ISA）定义了软件与硬件之间的交互规范，是两者的接口； 选项 C 错误，计算机组成（微架构）是 ISA 的逻辑实现层，而非物理实现层，物理实现涉及更底层的电路设计； 选项 D 正确，操作系统通过 ISA 对硬\\"></div>", "questionItemObjects": [{"prefix": "A", "content": "最上层是应用软件层", "itemUuid": "bdcb2acf"}, {"prefix": "B", "content": "指令集体系结构是软件和硬件的接口", "itemUuid": "94b14283"}, {"prefix": "C", "content": "计算机组成 (即微架构) 属于指令集体系结构的物理实现层", "itemUuid": "d60607f2"}, {"prefix": "D", "content": "操作系统可通过 ISA 进行抽象，向上层软件提供服务", "itemUuid": "4b92cd84"}]}', NOW());
SET @tc12 = LAST_INSERT_ID();
INSERT INTO t_question
  (question_type, subject_id, score, grade_level, difficult, correct, info_text_content_id, create_user, status, deleted,
   title, options, correct_answer, analysis, difficulty, knowledge_point, source, source_year, source_question_no, tags, images,
   title_text, analysis_text, content_format, has_image, has_code)
VALUES
  (1, 2, 20, NULL, 2, 'C', @tc12, 1, 1, b'0',
   '<div class="question-html-ref" data-src="question-html/2026/q12-title.html" data-fallback="下列关于计算机的系统层次的叙述，错误的是"></div>', '[{"prefix": "A", "content": "最上层是应用软件层", "itemUuid": "bdcb2acf"}, {"prefix": "B", "content": "指令集体系结构是软件和硬件的接口", "itemUuid": "94b14283"}, {"prefix": "C", "content": "计算机组成 (即微架构) 属于指令集体系结构的物理实现层", "itemUuid": "d60607f2"}, {"prefix": "D", "content": "操作系统可通过 ISA 进行抽象，向上层软件提供服务", "itemUuid": "4b92cd84"}]', 'C', '<div class="question-html-ref" data-src="question-html/2026/q12-analysis.html" data-fallback="正确答案： C 【解析】 选项 A 正确，计算机系统层次的最上层是应用软件层； 选项 B 正确，指令集体系结构（ISA）定义了软件与硬件之间的交互规范，是两者的接口； 选项 C 错误，计算机组成（微架构）是 ISA 的逻辑实现层，而非物理实现层，物理实现涉及更底层的电路设计； 选项 D 正确，操作系统通过 ISA 对硬"></div>',
   2, NULL, '2026年408模拟题', 2026, 12, 'html,external_html', '',
   '下列关于计算机的系统层次的叙述，错误的是', '正确答案： C 【解析】 选项 A 正确，计算机系统层次的最上层是应用软件层； 选项 B 正确，指令集体系结构（ISA）定义了软件与硬件之间的交互规范，是两者的接口； 选项 C 错误，计算机组成（微架构）是 ISA 的逻辑实现层，而非物理实现层，物理实现涉及更底层的电路设计； 选项 D 正确，操作系统通过 ISA 对硬件进行抽象，向上层软件提供统一的服务接口。', 'html', b'0', b'0');
SET @q12 = LAST_INSERT_ID();
INSERT INTO question_content
  (question_id, version, title, options, correct_answer, analysis, title_text, analysis_text, content_format, has_image, has_code, legacy_text_content_id, source_hash, is_current)
VALUES
  (@q12, 1, '<div class="question-html-ref" data-src="question-html/2026/q12-title.html" data-fallback="下列关于计算机的系统层次的叙述，错误的是"></div>', '[{"prefix": "A", "content": "最上层是应用软件层", "itemUuid": "bdcb2acf"}, {"prefix": "B", "content": "指令集体系结构是软件和硬件的接口", "itemUuid": "94b14283"}, {"prefix": "C", "content": "计算机组成 (即微架构) 属于指令集体系结构的物理实现层", "itemUuid": "d60607f2"}, {"prefix": "D", "content": "操作系统可通过 ISA 进行抽象，向上层软件提供服务", "itemUuid": "4b92cd84"}]', 'C', '<div class="question-html-ref" data-src="question-html/2026/q12-analysis.html" data-fallback="正确答案： C 【解析】 选项 A 正确，计算机系统层次的最上层是应用软件层； 选项 B 正确，指令集体系结构（ISA）定义了软件与硬件之间的交互规范，是两者的接口； 选项 C 错误，计算机组成（微架构）是 ISA 的逻辑实现层，而非物理实现层，物理实现涉及更底层的电路设计； 选项 D 正确，操作系统通过 ISA 对硬"></div>',
   '下列关于计算机的系统层次的叙述，错误的是', '正确答案： C 【解析】 选项 A 正确，计算机系统层次的最上层是应用软件层； 选项 B 正确，指令集体系结构（ISA）定义了软件与硬件之间的交互规范，是两者的接口； 选项 C 错误，计算机组成（微架构）是 ISA 的逻辑实现层，而非物理实现层，物理实现涉及更底层的电路设计； 选项 D 正确，操作系统通过 ISA 对硬件进行抽象，向上层软件提供统一的服务接口。', 'html', b'0', b'0', @tc12, '89c31e56bc00437ea4befb2ee59ee6e0da3b94ec3fb61920889d4f6ea3e0190a', b'1');
INSERT INTO question_source
  (question_id, source_type, source_name, source_year, source_question_no, paper_name, raw_ref, metadata)
VALUES
  (@q12, 'crawler_html', '计算机考研杂货铺', 2026, '12', '2026年408计算机学科专业基础综合模拟试题',
   'C:/Users/wutia/Downloads/csgraduates2026.html', '{"subject": "组成原理", "html": true}');

-- Q13
INSERT INTO t_text_content (content, create_time)
VALUES ('{"titleContent": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q13-title.html\\" data-fallback=\\"对机器数 1010 0110B 先执行算术右移 3 位，再执行算术左移 2 位，最终结果是（ ）。\\"></div>", "analyze": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q13-analysis.html\\" data-fallback=\\"正确答案： A 【解析】 机器数 1010 0110B 是一个 8 位有符号数（二进制补码表示）。先执行算术右移 3 位，再执行算术左移 2 位。 算术右移 3 位 ：符号位（最高位为 1）被保留并向左扩展。 原始位从高位到低位记为 A 0 ​ 到 A 7 ​ （ A 0 ​ 为符号位），右移后得到 B 0 ​ 到 B\\"></div>", "questionItemObjects": [{"prefix": "A", "content": "<code>1101 0000B</code>", "itemUuid": "adfcd2cc"}, {"prefix": "B", "content": "<code>1101 0011B</code>", "itemUuid": "f547cf7a"}, {"prefix": "C", "content": "<code>0101 0000B</code>", "itemUuid": "26af555c"}, {"prefix": "D", "content": "<code>0101 0011B</code>", "itemUuid": "445ebf1e"}]}', NOW());
SET @tc13 = LAST_INSERT_ID();
INSERT INTO t_question
  (question_type, subject_id, score, grade_level, difficult, correct, info_text_content_id, create_user, status, deleted,
   title, options, correct_answer, analysis, difficulty, knowledge_point, source, source_year, source_question_no, tags, images,
   title_text, analysis_text, content_format, has_image, has_code)
VALUES
  (1, 2, 20, NULL, 2, 'A', @tc13, 1, 1, b'0',
   '<div class="question-html-ref" data-src="question-html/2026/q13-title.html" data-fallback="对机器数 1010 0110B 先执行算术右移 3 位，再执行算术左移 2 位，最终结果是（ ）。"></div>', '[{"prefix": "A", "content": "<code>1101 0000B</code>", "itemUuid": "adfcd2cc"}, {"prefix": "B", "content": "<code>1101 0011B</code>", "itemUuid": "f547cf7a"}, {"prefix": "C", "content": "<code>0101 0000B</code>", "itemUuid": "26af555c"}, {"prefix": "D", "content": "<code>0101 0011B</code>", "itemUuid": "445ebf1e"}]', 'A', '<div class="question-html-ref" data-src="question-html/2026/q13-analysis.html" data-fallback="正确答案： A 【解析】 机器数 1010 0110B 是一个 8 位有符号数（二进制补码表示）。先执行算术右移 3 位，再执行算术左移 2 位。 算术右移 3 位 ：符号位（最高位为 1）被保留并向左扩展。 原始位从高位到低位记为 A 0 ​ 到 A 7 ​ （ A 0 ​ 为符号位），右移后得到 B 0 ​ 到 B"></div>',
   2, NULL, '2026年408模拟题', 2026, 13, 'html,external_html,code,katex', '',
   '对机器数 1010 0110B 先执行算术右移 3 位，再执行算术左移 2 位，最终结果是（ ）。', '正确答案： A 【解析】 机器数 1010 0110B 是一个 8 位有符号数（二进制补码表示）。先执行算术右移 3 位，再执行算术左移 2 位。 算术右移 3 位 ：符号位（最高位为 1）被保留并向左扩展。 原始位从高位到低位记为 A 0 ​ 到 A 7 ​ （ A 0 ​ 为符号位），右移后得到 B 0 ​ 到 B 7 ​ ，其中 B 0 ​ 到 B 3 ​ 均填充为 A 0 ​ （1）， B 4 ​ 到 B 7 ​ 依次为 A 1 ​ （0）、 A 2 ​ （1）、 A 3 ​ （0）、 A 4 ​ （0），结果为 1111 0100B （即 -12 的二进制补码）。 算术左移 2 位 ：将 1111 0100B 左移 2 位，高位丢弃，低位补 0，得到 1101 0000B （即 -48 的二进制补码）。 最终结果为 1101 0000B ，对应选项 A。', 'html', b'0', b'1');
SET @q13 = LAST_INSERT_ID();
INSERT INTO question_content
  (question_id, version, title, options, correct_answer, analysis, title_text, analysis_text, content_format, has_image, has_code, legacy_text_content_id, source_hash, is_current)
VALUES
  (@q13, 1, '<div class="question-html-ref" data-src="question-html/2026/q13-title.html" data-fallback="对机器数 1010 0110B 先执行算术右移 3 位，再执行算术左移 2 位，最终结果是（ ）。"></div>', '[{"prefix": "A", "content": "<code>1101 0000B</code>", "itemUuid": "adfcd2cc"}, {"prefix": "B", "content": "<code>1101 0011B</code>", "itemUuid": "f547cf7a"}, {"prefix": "C", "content": "<code>0101 0000B</code>", "itemUuid": "26af555c"}, {"prefix": "D", "content": "<code>0101 0011B</code>", "itemUuid": "445ebf1e"}]', 'A', '<div class="question-html-ref" data-src="question-html/2026/q13-analysis.html" data-fallback="正确答案： A 【解析】 机器数 1010 0110B 是一个 8 位有符号数（二进制补码表示）。先执行算术右移 3 位，再执行算术左移 2 位。 算术右移 3 位 ：符号位（最高位为 1）被保留并向左扩展。 原始位从高位到低位记为 A 0 ​ 到 A 7 ​ （ A 0 ​ 为符号位），右移后得到 B 0 ​ 到 B"></div>',
   '对机器数 1010 0110B 先执行算术右移 3 位，再执行算术左移 2 位，最终结果是（ ）。', '正确答案： A 【解析】 机器数 1010 0110B 是一个 8 位有符号数（二进制补码表示）。先执行算术右移 3 位，再执行算术左移 2 位。 算术右移 3 位 ：符号位（最高位为 1）被保留并向左扩展。 原始位从高位到低位记为 A 0 ​ 到 A 7 ​ （ A 0 ​ 为符号位），右移后得到 B 0 ​ 到 B 7 ​ ，其中 B 0 ​ 到 B 3 ​ 均填充为 A 0 ​ （1）， B 4 ​ 到 B 7 ​ 依次为 A 1 ​ （0）、 A 2 ​ （1）、 A 3 ​ （0）、 A 4 ​ （0），结果为 1111 0100B （即 -12 的二进制补码）。 算术左移 2 位 ：将 1111 0100B 左移 2 位，高位丢弃，低位补 0，得到 1101 0000B （即 -48 的二进制补码）。 最终结果为 1101 0000B ，对应选项 A。', 'html', b'0', b'1', @tc13, '9f23841e52154cd5faa86c411422cac144b9dbf740e17ee3729eb15f7aad4ce5', b'1');
INSERT INTO question_source
  (question_id, source_type, source_name, source_year, source_question_no, paper_name, raw_ref, metadata)
VALUES
  (@q13, 'crawler_html', '计算机考研杂货铺', 2026, '13', '2026年408计算机学科专业基础综合模拟试题',
   'C:/Users/wutia/Downloads/csgraduates2026.html', '{"subject": "组成原理", "html": true}');

-- Q14
INSERT INTO t_text_content (content, create_time)
VALUES ('{"titleContent": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q14-title.html\\" data-fallback=\\"已知用 IEEE 754 单精度浮点数表示浮点型变量，采用就近舍入（中间值取偶数）。若浮点型变量 x 为 12.1 ，则 x 的机器数是（ ）\\"></div>", "analyze": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q14-analysis.html\\" data-fallback=\\"正确答案： B 【解析】 1. 确定数量级（指数部分） 12. 1 10 ​ ∈ [ 8 , 16 ) ⇒ 12.1 = 1.5125 × 2 3 符号位：0 指数：(3 + 127 = 130 = 1000,0010_2) 2. 计算尾数 把 1.5125 转成二进制小数： 1.5125 = 1 + 0.5125 对\\"></div>", "questionItemObjects": [{"prefix": "A", "content": "<code>4141 9999H</code>", "itemUuid": "4c7b8073"}, {"prefix": "B", "content": "<code>4141 999AH</code>", "itemUuid": "ff0e3200"}, {"prefix": "C", "content": "<code>41E0 CCCCH</code>", "itemUuid": "528f4ac6"}, {"prefix": "D", "content": "<code>41E0 CCCDH</code>", "itemUuid": "9946c42b"}]}', NOW());
SET @tc14 = LAST_INSERT_ID();
INSERT INTO t_question
  (question_type, subject_id, score, grade_level, difficult, correct, info_text_content_id, create_user, status, deleted,
   title, options, correct_answer, analysis, difficulty, knowledge_point, source, source_year, source_question_no, tags, images,
   title_text, analysis_text, content_format, has_image, has_code)
VALUES
  (1, 2, 20, NULL, 2, 'B', @tc14, 1, 1, b'0',
   '<div class="question-html-ref" data-src="question-html/2026/q14-title.html" data-fallback="已知用 IEEE 754 单精度浮点数表示浮点型变量，采用就近舍入（中间值取偶数）。若浮点型变量 x 为 12.1 ，则 x 的机器数是（ ）"></div>', '[{"prefix": "A", "content": "<code>4141 9999H</code>", "itemUuid": "4c7b8073"}, {"prefix": "B", "content": "<code>4141 999AH</code>", "itemUuid": "ff0e3200"}, {"prefix": "C", "content": "<code>41E0 CCCCH</code>", "itemUuid": "528f4ac6"}, {"prefix": "D", "content": "<code>41E0 CCCDH</code>", "itemUuid": "9946c42b"}]', 'B', '<div class="question-html-ref" data-src="question-html/2026/q14-analysis.html" data-fallback="正确答案： B 【解析】 1. 确定数量级（指数部分） 12. 1 10 ​ ∈ [ 8 , 16 ) ⇒ 12.1 = 1.5125 × 2 3 符号位：0 指数：(3 + 127 = 130 = 1000,0010_2) 2. 计算尾数 把 1.5125 转成二进制小数： 1.5125 = 1 + 0.5125 对"></div>',
   2, NULL, '2026年408模拟题', 2026, 14, 'html,external_html,code,table,katex', '',
   '已知用 IEEE 754 单精度浮点数表示浮点型变量，采用就近舍入（中间值取偶数）。若浮点型变量 x 为 12.1 ，则 x 的机器数是（ ）', '正确答案： B 【解析】 1. 确定数量级（指数部分） 12. 1 10 ​ ∈ [ 8 , 16 ) ⇒ 12.1 = 1.5125 × 2 3 符号位：0 指数：(3 + 127 = 130 = 1000,0010_2) 2. 计算尾数 把 1.5125 转成二进制小数： 1.5125 = 1 + 0.5125 对小数部分反复乘 2： 步骤 值 0.5125 × 2 = 1.025 1 0.025 × 2 = 0.05 0 0.05 × 2 = 0.1 0 0.1 × 2 = 0.2 0 0.2 × 2 = 0.4 0 0.4 × 2 = 0.8 0 0.8 × 2 = 1.6 1 0.6 × 2 = 1.2 1 … … 得到二进制近似： 1.10000001100110011001100…₂ 3. 就近舍入（中间值取偶） IEEE 754 单精度尾数 23 位 ，截断时： …10011001100110011001100 1100… 被舍弃部分 > 0.5 ULP 或者正好在中间且最低位为奇数 👉 需要进 1 因此尾数末位变为 …10011010 4. 拼装 IEEE 754 单精度 部分 内容 符号 0 指数 10000010 尾数 10000011001100110011010 转换为十六进制： 0 | 10000010 | 10000011001100110011010 ↓ 4141999A₁₆ 最终答案 B 4141 999AH', 'html', b'0', b'1');
SET @q14 = LAST_INSERT_ID();
INSERT INTO question_content
  (question_id, version, title, options, correct_answer, analysis, title_text, analysis_text, content_format, has_image, has_code, legacy_text_content_id, source_hash, is_current)
VALUES
  (@q14, 1, '<div class="question-html-ref" data-src="question-html/2026/q14-title.html" data-fallback="已知用 IEEE 754 单精度浮点数表示浮点型变量，采用就近舍入（中间值取偶数）。若浮点型变量 x 为 12.1 ，则 x 的机器数是（ ）"></div>', '[{"prefix": "A", "content": "<code>4141 9999H</code>", "itemUuid": "4c7b8073"}, {"prefix": "B", "content": "<code>4141 999AH</code>", "itemUuid": "ff0e3200"}, {"prefix": "C", "content": "<code>41E0 CCCCH</code>", "itemUuid": "528f4ac6"}, {"prefix": "D", "content": "<code>41E0 CCCDH</code>", "itemUuid": "9946c42b"}]', 'B', '<div class="question-html-ref" data-src="question-html/2026/q14-analysis.html" data-fallback="正确答案： B 【解析】 1. 确定数量级（指数部分） 12. 1 10 ​ ∈ [ 8 , 16 ) ⇒ 12.1 = 1.5125 × 2 3 符号位：0 指数：(3 + 127 = 130 = 1000,0010_2) 2. 计算尾数 把 1.5125 转成二进制小数： 1.5125 = 1 + 0.5125 对"></div>',
   '已知用 IEEE 754 单精度浮点数表示浮点型变量，采用就近舍入（中间值取偶数）。若浮点型变量 x 为 12.1 ，则 x 的机器数是（ ）', '正确答案： B 【解析】 1. 确定数量级（指数部分） 12. 1 10 ​ ∈ [ 8 , 16 ) ⇒ 12.1 = 1.5125 × 2 3 符号位：0 指数：(3 + 127 = 130 = 1000,0010_2) 2. 计算尾数 把 1.5125 转成二进制小数： 1.5125 = 1 + 0.5125 对小数部分反复乘 2： 步骤 值 0.5125 × 2 = 1.025 1 0.025 × 2 = 0.05 0 0.05 × 2 = 0.1 0 0.1 × 2 = 0.2 0 0.2 × 2 = 0.4 0 0.4 × 2 = 0.8 0 0.8 × 2 = 1.6 1 0.6 × 2 = 1.2 1 … … 得到二进制近似： 1.10000001100110011001100…₂ 3. 就近舍入（中间值取偶） IEEE 754 单精度尾数 23 位 ，截断时： …10011001100110011001100 1100… 被舍弃部分 > 0.5 ULP 或者正好在中间且最低位为奇数 👉 需要进 1 因此尾数末位变为 …10011010 4. 拼装 IEEE 754 单精度 部分 内容 符号 0 指数 10000010 尾数 10000011001100110011010 转换为十六进制： 0 | 10000010 | 10000011001100110011010 ↓ 4141999A₁₆ 最终答案 B 4141 999AH', 'html', b'0', b'1', @tc14, '315707c5688ebb4fc04bd6e5c32d1291f511a0b315d1feb61ca35871534f6215', b'1');
INSERT INTO question_source
  (question_id, source_type, source_name, source_year, source_question_no, paper_name, raw_ref, metadata)
VALUES
  (@q14, 'crawler_html', '计算机考研杂货铺', 2026, '14', '2026年408计算机学科专业基础综合模拟试题',
   'C:/Users/wutia/Downloads/csgraduates2026.html', '{"subject": "组成原理", "html": true}');

-- Q15
INSERT INTO t_text_content (content, create_time)
VALUES ('{"titleContent": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q15-title.html\\" data-fallback=\\"用 8 个 64 M×8 bit 的 DRAM 芯片按交叉编址方式构成主存储器，并与一个宽度为 64 bit 的存储器总线相连。主存每次最多读写 64 bit，且按字节编址。则下列地址中，与主存地址 0018 001DH 位于同一芯片中的是（ ）\\"></div>", "analyze": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q15-analysis.html\\" data-fallback=\\"正确答案： A 【解析】 由 8 个 64M×8bit 的 DRAM 芯片按交叉编址方式构成主存储器，每个芯片容量为 64MB，总容量为 512MB。按字节编址，地址线共 29 位。交叉编址时，地址的低位用于选择芯片，高位用于芯片内地址。由于有 8 个芯片，地址的低 3 位（模 8）决定芯片编号。 给定地址 0018 \\"></div>", "questionItemObjects": [{"prefix": "A", "content": "<code>0000 01D5H</code>", "itemUuid": "1dda29ae"}, {"prefix": "B", "content": "<code>000F A020H</code>", "itemUuid": "9cd9c2ef"}, {"prefix": "C", "content": "<code>0018 001EH</code>", "itemUuid": "5cc43e89"}, {"prefix": "D", "content": "<code>0101 0011B</code>", "itemUuid": "6eefc946"}]}', NOW());
SET @tc15 = LAST_INSERT_ID();
INSERT INTO t_question
  (question_type, subject_id, score, grade_level, difficult, correct, info_text_content_id, create_user, status, deleted,
   title, options, correct_answer, analysis, difficulty, knowledge_point, source, source_year, source_question_no, tags, images,
   title_text, analysis_text, content_format, has_image, has_code)
VALUES
  (1, 2, 20, NULL, 2, 'A', @tc15, 1, 1, b'0',
   '<div class="question-html-ref" data-src="question-html/2026/q15-title.html" data-fallback="用 8 个 64 M×8 bit 的 DRAM 芯片按交叉编址方式构成主存储器，并与一个宽度为 64 bit 的存储器总线相连。主存每次最多读写 64 bit，且按字节编址。则下列地址中，与主存地址 0018 001DH 位于同一芯片中的是（ ）"></div>', '[{"prefix": "A", "content": "<code>0000 01D5H</code>", "itemUuid": "1dda29ae"}, {"prefix": "B", "content": "<code>000F A020H</code>", "itemUuid": "9cd9c2ef"}, {"prefix": "C", "content": "<code>0018 001EH</code>", "itemUuid": "5cc43e89"}, {"prefix": "D", "content": "<code>0101 0011B</code>", "itemUuid": "6eefc946"}]', 'A', '<div class="question-html-ref" data-src="question-html/2026/q15-analysis.html" data-fallback="正确答案： A 【解析】 由 8 个 64M×8bit 的 DRAM 芯片按交叉编址方式构成主存储器，每个芯片容量为 64MB，总容量为 512MB。按字节编址，地址线共 29 位。交叉编址时，地址的低位用于选择芯片，高位用于芯片内地址。由于有 8 个芯片，地址的低 3 位（模 8）决定芯片编号。 给定地址 0018 "></div>',
   2, NULL, '2026年408模拟题', 2026, 15, 'html,external_html,code', '',
   '用 8 个 64 M×8 bit 的 DRAM 芯片按交叉编址方式构成主存储器，并与一个宽度为 64 bit 的存储器总线相连。主存每次最多读写 64 bit，且按字节编址。则下列地址中，与主存地址 0018 001DH 位于同一芯片中的是（ ）', '正确答案： A 【解析】 由 8 个 64M×8bit 的 DRAM 芯片按交叉编址方式构成主存储器，每个芯片容量为 64MB，总容量为 512MB。按字节编址，地址线共 29 位。交叉编址时，地址的低位用于选择芯片，高位用于芯片内地址。由于有 8 个芯片，地址的低 3 位（模 8）决定芯片编号。 给定地址 0018 001DH 的十六进制值为 0x0018001D，低 3 位二进制为 101（因为 0x1D 的低 3 位为 101），即模 8 余 5。因此，与它位于同一芯片的地址必须模 8 余 5。 选项 A： 0000 01D5H ，低 3 位为 101（0xD5 的低 3 位为 101），余 5，符合。 选项 B： 000F A020H ，低 3 位为 000，余 0，不符合。 选项 C： 0018 001EH ，低 3 位为 110（0x1E 的低 3 位为 110），余 6，不符合。 选项 D： 0101 0011B 为二进制数，低 3 位为 011，余 3，不符合。 故只有选项 A 与给定地址位于同一芯片。', 'html', b'0', b'1');
SET @q15 = LAST_INSERT_ID();
INSERT INTO question_content
  (question_id, version, title, options, correct_answer, analysis, title_text, analysis_text, content_format, has_image, has_code, legacy_text_content_id, source_hash, is_current)
VALUES
  (@q15, 1, '<div class="question-html-ref" data-src="question-html/2026/q15-title.html" data-fallback="用 8 个 64 M×8 bit 的 DRAM 芯片按交叉编址方式构成主存储器，并与一个宽度为 64 bit 的存储器总线相连。主存每次最多读写 64 bit，且按字节编址。则下列地址中，与主存地址 0018 001DH 位于同一芯片中的是（ ）"></div>', '[{"prefix": "A", "content": "<code>0000 01D5H</code>", "itemUuid": "1dda29ae"}, {"prefix": "B", "content": "<code>000F A020H</code>", "itemUuid": "9cd9c2ef"}, {"prefix": "C", "content": "<code>0018 001EH</code>", "itemUuid": "5cc43e89"}, {"prefix": "D", "content": "<code>0101 0011B</code>", "itemUuid": "6eefc946"}]', 'A', '<div class="question-html-ref" data-src="question-html/2026/q15-analysis.html" data-fallback="正确答案： A 【解析】 由 8 个 64M×8bit 的 DRAM 芯片按交叉编址方式构成主存储器，每个芯片容量为 64MB，总容量为 512MB。按字节编址，地址线共 29 位。交叉编址时，地址的低位用于选择芯片，高位用于芯片内地址。由于有 8 个芯片，地址的低 3 位（模 8）决定芯片编号。 给定地址 0018 "></div>',
   '用 8 个 64 M×8 bit 的 DRAM 芯片按交叉编址方式构成主存储器，并与一个宽度为 64 bit 的存储器总线相连。主存每次最多读写 64 bit，且按字节编址。则下列地址中，与主存地址 0018 001DH 位于同一芯片中的是（ ）', '正确答案： A 【解析】 由 8 个 64M×8bit 的 DRAM 芯片按交叉编址方式构成主存储器，每个芯片容量为 64MB，总容量为 512MB。按字节编址，地址线共 29 位。交叉编址时，地址的低位用于选择芯片，高位用于芯片内地址。由于有 8 个芯片，地址的低 3 位（模 8）决定芯片编号。 给定地址 0018 001DH 的十六进制值为 0x0018001D，低 3 位二进制为 101（因为 0x1D 的低 3 位为 101），即模 8 余 5。因此，与它位于同一芯片的地址必须模 8 余 5。 选项 A： 0000 01D5H ，低 3 位为 101（0xD5 的低 3 位为 101），余 5，符合。 选项 B： 000F A020H ，低 3 位为 000，余 0，不符合。 选项 C： 0018 001EH ，低 3 位为 110（0x1E 的低 3 位为 110），余 6，不符合。 选项 D： 0101 0011B 为二进制数，低 3 位为 011，余 3，不符合。 故只有选项 A 与给定地址位于同一芯片。', 'html', b'0', b'1', @tc15, '32f143810289705b2b60d5933f93485af8391660e654d5d7c6c7bfc156de0154', b'1');
INSERT INTO question_source
  (question_id, source_type, source_name, source_year, source_question_no, paper_name, raw_ref, metadata)
VALUES
  (@q15, 'crawler_html', '计算机考研杂货铺', 2026, '15', '2026年408计算机学科专业基础综合模拟试题',
   'C:/Users/wutia/Downloads/csgraduates2026.html', '{"subject": "组成原理", "html": true}');

-- Q16
INSERT INTO t_text_content (content, create_time)
VALUES ('{"titleContent": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q16-title.html\\" data-fallback=\\"下列不是由指令集体系结构规定的是（）\\"></div>", "analyze": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q16-analysis.html\\" data-fallback=\\"正确答案： D 【解析】指令集体系结构（ISA）定义了软件与硬件之间的接口规范，包括指令集、寄存器、内存模型、中断机制等，但不涉及硬件实现细节。 选项 A 的输入输出指令是 ISA 的一部分，用于控制 I/O 设备； 选项 B 的向量中断属于中断处理机制，通常由 ISA 规定中断向量表和处理流程； 选项 C 的虚拟存储\\"></div>", "questionItemObjects": [{"prefix": "A", "content": "输入输出指令", "itemUuid": "f9380738"}, {"prefix": "B", "content": "采用向量中断", "itemUuid": "1093055c"}, {"prefix": "C", "content": "虚拟存储管理方式", "itemUuid": "2cb2de9c"}, {"prefix": "D", "content": "指令流水线是否使用超级流水线技术", "itemUuid": "35df70c9"}]}', NOW());
SET @tc16 = LAST_INSERT_ID();
INSERT INTO t_question
  (question_type, subject_id, score, grade_level, difficult, correct, info_text_content_id, create_user, status, deleted,
   title, options, correct_answer, analysis, difficulty, knowledge_point, source, source_year, source_question_no, tags, images,
   title_text, analysis_text, content_format, has_image, has_code)
VALUES
  (1, 2, 20, NULL, 2, 'D', @tc16, 1, 1, b'0',
   '<div class="question-html-ref" data-src="question-html/2026/q16-title.html" data-fallback="下列不是由指令集体系结构规定的是（）"></div>', '[{"prefix": "A", "content": "输入输出指令", "itemUuid": "f9380738"}, {"prefix": "B", "content": "采用向量中断", "itemUuid": "1093055c"}, {"prefix": "C", "content": "虚拟存储管理方式", "itemUuid": "2cb2de9c"}, {"prefix": "D", "content": "指令流水线是否使用超级流水线技术", "itemUuid": "35df70c9"}]', 'D', '<div class="question-html-ref" data-src="question-html/2026/q16-analysis.html" data-fallback="正确答案： D 【解析】指令集体系结构（ISA）定义了软件与硬件之间的接口规范，包括指令集、寄存器、内存模型、中断机制等，但不涉及硬件实现细节。 选项 A 的输入输出指令是 ISA 的一部分，用于控制 I/O 设备； 选项 B 的向量中断属于中断处理机制，通常由 ISA 规定中断向量表和处理流程； 选项 C 的虚拟存储"></div>',
   2, NULL, '2026年408模拟题', 2026, 16, 'html,external_html', '',
   '下列不是由指令集体系结构规定的是（）', '正确答案： D 【解析】指令集体系结构（ISA）定义了软件与硬件之间的接口规范，包括指令集、寄存器、内存模型、中断机制等，但不涉及硬件实现细节。 选项 A 的输入输出指令是 ISA 的一部分，用于控制 I/O 设备； 选项 B 的向量中断属于中断处理机制，通常由 ISA 规定中断向量表和处理流程； 选项 C 的虚拟存储管理方式与 ISA 相关，ISA 可能规定虚拟内存的基本支持（如地址转换机制），但具体管理方式部分由硬件和操作系统实现； 选项 D 的指令流水线是否使用超级流水线技术是微架构（microarchitecture）的实现选择，属于处理器内部设计优化，不属于 ISA 的规定范畴，因此 D 不是由指令集体系结构规定的。', 'html', b'0', b'0');
SET @q16 = LAST_INSERT_ID();
INSERT INTO question_content
  (question_id, version, title, options, correct_answer, analysis, title_text, analysis_text, content_format, has_image, has_code, legacy_text_content_id, source_hash, is_current)
VALUES
  (@q16, 1, '<div class="question-html-ref" data-src="question-html/2026/q16-title.html" data-fallback="下列不是由指令集体系结构规定的是（）"></div>', '[{"prefix": "A", "content": "输入输出指令", "itemUuid": "f9380738"}, {"prefix": "B", "content": "采用向量中断", "itemUuid": "1093055c"}, {"prefix": "C", "content": "虚拟存储管理方式", "itemUuid": "2cb2de9c"}, {"prefix": "D", "content": "指令流水线是否使用超级流水线技术", "itemUuid": "35df70c9"}]', 'D', '<div class="question-html-ref" data-src="question-html/2026/q16-analysis.html" data-fallback="正确答案： D 【解析】指令集体系结构（ISA）定义了软件与硬件之间的接口规范，包括指令集、寄存器、内存模型、中断机制等，但不涉及硬件实现细节。 选项 A 的输入输出指令是 ISA 的一部分，用于控制 I/O 设备； 选项 B 的向量中断属于中断处理机制，通常由 ISA 规定中断向量表和处理流程； 选项 C 的虚拟存储"></div>',
   '下列不是由指令集体系结构规定的是（）', '正确答案： D 【解析】指令集体系结构（ISA）定义了软件与硬件之间的接口规范，包括指令集、寄存器、内存模型、中断机制等，但不涉及硬件实现细节。 选项 A 的输入输出指令是 ISA 的一部分，用于控制 I/O 设备； 选项 B 的向量中断属于中断处理机制，通常由 ISA 规定中断向量表和处理流程； 选项 C 的虚拟存储管理方式与 ISA 相关，ISA 可能规定虚拟内存的基本支持（如地址转换机制），但具体管理方式部分由硬件和操作系统实现； 选项 D 的指令流水线是否使用超级流水线技术是微架构（microarchitecture）的实现选择，属于处理器内部设计优化，不属于 ISA 的规定范畴，因此 D 不是由指令集体系结构规定的。', 'html', b'0', b'0', @tc16, 'c0677a46cd18e4eade8fc8f1de3318e6ede572a5f3f0cbf5d8487beee66fb424', b'1');
INSERT INTO question_source
  (question_id, source_type, source_name, source_year, source_question_no, paper_name, raw_ref, metadata)
VALUES
  (@q16, 'crawler_html', '计算机考研杂货铺', 2026, '16', '2026年408计算机学科专业基础综合模拟试题',
   'C:/Users/wutia/Downloads/csgraduates2026.html', '{"subject": "组成原理", "html": true}');

-- Q17
INSERT INTO t_text_content (content, create_time)
VALUES ('{"titleContent": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q17-title.html\\" data-fallback=\\"哪些指令可能不改变程序下一条指令的地址？ Ⅰ. 条件转移 Ⅱ. 过程调用 Ⅲ. 陷入指令 Ⅳ. 返回\\"></div>", "analyze": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q17-analysis.html\\" data-fallback=\\"正确答案： B 【解析】 条件转移指令（Ⅰ）根据条件决定是否跳转：当条件不满足时，程序继续顺序执行，下一条指令地址不变，因此可能不改变地址。 返回指令（Ⅳ）通常改变地址，但理论上若返回地址恰好是当前指令地址，则可能不改变地址。 过程调用指令（Ⅱ）和陷入指令（Ⅲ）总是跳转到目标地址，一定会改变下一条指令地址，不可能不改变\\"></div>", "questionItemObjects": [{"prefix": "A", "content": "Ⅰ、Ⅱ", "itemUuid": "6da8e6ac"}, {"prefix": "B", "content": "Ⅰ、Ⅳ", "itemUuid": "f938585c"}, {"prefix": "C", "content": "Ⅱ、Ⅲ", "itemUuid": "4e8b0944"}, {"prefix": "D", "content": "Ⅱ、Ⅳ", "itemUuid": "7e4fa95f"}]}', NOW());
SET @tc17 = LAST_INSERT_ID();
INSERT INTO t_question
  (question_type, subject_id, score, grade_level, difficult, correct, info_text_content_id, create_user, status, deleted,
   title, options, correct_answer, analysis, difficulty, knowledge_point, source, source_year, source_question_no, tags, images,
   title_text, analysis_text, content_format, has_image, has_code)
VALUES
  (1, 2, 20, NULL, 2, 'B', @tc17, 1, 1, b'0',
   '<div class="question-html-ref" data-src="question-html/2026/q17-title.html" data-fallback="哪些指令可能不改变程序下一条指令的地址？ Ⅰ. 条件转移 Ⅱ. 过程调用 Ⅲ. 陷入指令 Ⅳ. 返回"></div>', '[{"prefix": "A", "content": "Ⅰ、Ⅱ", "itemUuid": "6da8e6ac"}, {"prefix": "B", "content": "Ⅰ、Ⅳ", "itemUuid": "f938585c"}, {"prefix": "C", "content": "Ⅱ、Ⅲ", "itemUuid": "4e8b0944"}, {"prefix": "D", "content": "Ⅱ、Ⅳ", "itemUuid": "7e4fa95f"}]', 'B', '<div class="question-html-ref" data-src="question-html/2026/q17-analysis.html" data-fallback="正确答案： B 【解析】 条件转移指令（Ⅰ）根据条件决定是否跳转：当条件不满足时，程序继续顺序执行，下一条指令地址不变，因此可能不改变地址。 返回指令（Ⅳ）通常改变地址，但理论上若返回地址恰好是当前指令地址，则可能不改变地址。 过程调用指令（Ⅱ）和陷入指令（Ⅲ）总是跳转到目标地址，一定会改变下一条指令地址，不可能不改变"></div>',
   2, NULL, '2026年408模拟题', 2026, 17, 'html,external_html', '',
   '哪些指令可能不改变程序下一条指令的地址？ Ⅰ. 条件转移 Ⅱ. 过程调用 Ⅲ. 陷入指令 Ⅳ. 返回', '正确答案： B 【解析】 条件转移指令（Ⅰ）根据条件决定是否跳转：当条件不满足时，程序继续顺序执行，下一条指令地址不变，因此可能不改变地址。 返回指令（Ⅳ）通常改变地址，但理论上若返回地址恰好是当前指令地址，则可能不改变地址。 过程调用指令（Ⅱ）和陷入指令（Ⅲ）总是跳转到目标地址，一定会改变下一条指令地址，不可能不改变。 因此，可能不改变下一条指令地址的指令是Ⅰ和Ⅳ。', 'html', b'0', b'0');
SET @q17 = LAST_INSERT_ID();
INSERT INTO question_content
  (question_id, version, title, options, correct_answer, analysis, title_text, analysis_text, content_format, has_image, has_code, legacy_text_content_id, source_hash, is_current)
VALUES
  (@q17, 1, '<div class="question-html-ref" data-src="question-html/2026/q17-title.html" data-fallback="哪些指令可能不改变程序下一条指令的地址？ Ⅰ. 条件转移 Ⅱ. 过程调用 Ⅲ. 陷入指令 Ⅳ. 返回"></div>', '[{"prefix": "A", "content": "Ⅰ、Ⅱ", "itemUuid": "6da8e6ac"}, {"prefix": "B", "content": "Ⅰ、Ⅳ", "itemUuid": "f938585c"}, {"prefix": "C", "content": "Ⅱ、Ⅲ", "itemUuid": "4e8b0944"}, {"prefix": "D", "content": "Ⅱ、Ⅳ", "itemUuid": "7e4fa95f"}]', 'B', '<div class="question-html-ref" data-src="question-html/2026/q17-analysis.html" data-fallback="正确答案： B 【解析】 条件转移指令（Ⅰ）根据条件决定是否跳转：当条件不满足时，程序继续顺序执行，下一条指令地址不变，因此可能不改变地址。 返回指令（Ⅳ）通常改变地址，但理论上若返回地址恰好是当前指令地址，则可能不改变地址。 过程调用指令（Ⅱ）和陷入指令（Ⅲ）总是跳转到目标地址，一定会改变下一条指令地址，不可能不改变"></div>',
   '哪些指令可能不改变程序下一条指令的地址？ Ⅰ. 条件转移 Ⅱ. 过程调用 Ⅲ. 陷入指令 Ⅳ. 返回', '正确答案： B 【解析】 条件转移指令（Ⅰ）根据条件决定是否跳转：当条件不满足时，程序继续顺序执行，下一条指令地址不变，因此可能不改变地址。 返回指令（Ⅳ）通常改变地址，但理论上若返回地址恰好是当前指令地址，则可能不改变地址。 过程调用指令（Ⅱ）和陷入指令（Ⅲ）总是跳转到目标地址，一定会改变下一条指令地址，不可能不改变。 因此，可能不改变下一条指令地址的指令是Ⅰ和Ⅳ。', 'html', b'0', b'0', @tc17, 'd9f67173d60f7ed08417ea0308b5168c4578f18b05a599bf19c3891901c3f9cb', b'1');
INSERT INTO question_source
  (question_id, source_type, source_name, source_year, source_question_no, paper_name, raw_ref, metadata)
VALUES
  (@q17, 'crawler_html', '计算机考研杂货铺', 2026, '17', '2026年408计算机学科专业基础综合模拟试题',
   'C:/Users/wutia/Downloads/csgraduates2026.html', '{"subject": "组成原理", "html": true}');

-- Q18
INSERT INTO t_text_content (content, create_time)
VALUES ('{"titleContent": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q18-title.html\\" data-fallback=\\"某计算机按字节编址，数据 Cache 共有 1024 行，采用 4 路组相联映射，主存块大小为 32 B，若访问主存地址为 1028 的 4 字节数据，则该数据所在主存块对应的组号为（ ）\\"></div>", "analyze": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q18-analysis.html\\" data-fallback=\\"正确答案： C 【解析】 Cache 共有 1024 行，采用 4 路组相联映射，因此组数为 1024/4 = 256 组。 主存块大小为 32 B，块内偏移地址占 5 位（ 2 5 = 32 ）。 访问主存地址为 1028（十进制），按字节编址。 组号由块地址对组数取模得到：块地址为地址除以块大小的整数部分，即 10\\"></div>", "questionItemObjects": [{"prefix": "A", "content": "4", "itemUuid": "dead68e4"}, {"prefix": "B", "content": "16", "itemUuid": "1b9886b6"}, {"prefix": "C", "content": "32", "itemUuid": "69a9c0db"}, {"prefix": "D", "content": "64", "itemUuid": "cb9a54a6"}]}', NOW());
SET @tc18 = LAST_INSERT_ID();
INSERT INTO t_question
  (question_type, subject_id, score, grade_level, difficult, correct, info_text_content_id, create_user, status, deleted,
   title, options, correct_answer, analysis, difficulty, knowledge_point, source, source_year, source_question_no, tags, images,
   title_text, analysis_text, content_format, has_image, has_code)
VALUES
  (1, 2, 20, NULL, 2, 'C', @tc18, 1, 1, b'0',
   '<div class="question-html-ref" data-src="question-html/2026/q18-title.html" data-fallback="某计算机按字节编址，数据 Cache 共有 1024 行，采用 4 路组相联映射，主存块大小为 32 B，若访问主存地址为 1028 的 4 字节数据，则该数据所在主存块对应的组号为（ ）"></div>', '[{"prefix": "A", "content": "4", "itemUuid": "dead68e4"}, {"prefix": "B", "content": "16", "itemUuid": "1b9886b6"}, {"prefix": "C", "content": "32", "itemUuid": "69a9c0db"}, {"prefix": "D", "content": "64", "itemUuid": "cb9a54a6"}]', 'C', '<div class="question-html-ref" data-src="question-html/2026/q18-analysis.html" data-fallback="正确答案： C 【解析】 Cache 共有 1024 行，采用 4 路组相联映射，因此组数为 1024/4 = 256 组。 主存块大小为 32 B，块内偏移地址占 5 位（ 2 5 = 32 ）。 访问主存地址为 1028（十进制），按字节编址。 组号由块地址对组数取模得到：块地址为地址除以块大小的整数部分，即 10"></div>',
   2, NULL, '2026年408模拟题', 2026, 18, 'html,external_html,katex', '',
   '某计算机按字节编址，数据 Cache 共有 1024 行，采用 4 路组相联映射，主存块大小为 32 B，若访问主存地址为 1028 的 4 字节数据，则该数据所在主存块对应的组号为（ ）', '正确答案： C 【解析】 Cache 共有 1024 行，采用 4 路组相联映射，因此组数为 1024/4 = 256 组。 主存块大小为 32 B，块内偏移地址占 5 位（ 2 5 = 32 ）。 访问主存地址为 1028（十进制），按字节编址。 组号由块地址对组数取模得到：块地址为地址除以块大小的整数部分，即 1028/32 = 32 ( 整数除法 ) 组索引 = 32 mod 256 = 32 因此，该数据所在主存块对应的组号为 32。', 'html', b'0', b'0');
SET @q18 = LAST_INSERT_ID();
INSERT INTO question_content
  (question_id, version, title, options, correct_answer, analysis, title_text, analysis_text, content_format, has_image, has_code, legacy_text_content_id, source_hash, is_current)
VALUES
  (@q18, 1, '<div class="question-html-ref" data-src="question-html/2026/q18-title.html" data-fallback="某计算机按字节编址，数据 Cache 共有 1024 行，采用 4 路组相联映射，主存块大小为 32 B，若访问主存地址为 1028 的 4 字节数据，则该数据所在主存块对应的组号为（ ）"></div>', '[{"prefix": "A", "content": "4", "itemUuid": "dead68e4"}, {"prefix": "B", "content": "16", "itemUuid": "1b9886b6"}, {"prefix": "C", "content": "32", "itemUuid": "69a9c0db"}, {"prefix": "D", "content": "64", "itemUuid": "cb9a54a6"}]', 'C', '<div class="question-html-ref" data-src="question-html/2026/q18-analysis.html" data-fallback="正确答案： C 【解析】 Cache 共有 1024 行，采用 4 路组相联映射，因此组数为 1024/4 = 256 组。 主存块大小为 32 B，块内偏移地址占 5 位（ 2 5 = 32 ）。 访问主存地址为 1028（十进制），按字节编址。 组号由块地址对组数取模得到：块地址为地址除以块大小的整数部分，即 10"></div>',
   '某计算机按字节编址，数据 Cache 共有 1024 行，采用 4 路组相联映射，主存块大小为 32 B，若访问主存地址为 1028 的 4 字节数据，则该数据所在主存块对应的组号为（ ）', '正确答案： C 【解析】 Cache 共有 1024 行，采用 4 路组相联映射，因此组数为 1024/4 = 256 组。 主存块大小为 32 B，块内偏移地址占 5 位（ 2 5 = 32 ）。 访问主存地址为 1028（十进制），按字节编址。 组号由块地址对组数取模得到：块地址为地址除以块大小的整数部分，即 1028/32 = 32 ( 整数除法 ) 组索引 = 32 mod 256 = 32 因此，该数据所在主存块对应的组号为 32。', 'html', b'0', b'0', @tc18, '3c3c58032247a06e2ae91ca8cebc3548a5e2d83d56cc7551d510c25cb72baf93', b'1');
INSERT INTO question_source
  (question_id, source_type, source_name, source_year, source_question_no, paper_name, raw_ref, metadata)
VALUES
  (@q18, 'crawler_html', '计算机考研杂货铺', 2026, '18', '2026年408计算机学科专业基础综合模拟试题',
   'C:/Users/wutia/Downloads/csgraduates2026.html', '{"subject": "组成原理", "html": true}');

-- Q19
INSERT INTO t_text_content (content, create_time)
VALUES ('{"titleContent": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q19-title.html\\" data-fallback=\\"某计算机按字节编址，虚拟地址为 16 位，页大小为 256B，页表项中包含装入位（P）、页框号（PPN）等字段。TLB 采用 4 路组相联映射，共有 16 个页表项，TLB 表项中包含标记（Tag）、有效位（V）等字段。在主存页表与 TLB 表项同步后，若主存页表中页号 22 对应的页表项中 P = 0 ， PPN =\\"></div>", "analyze": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q19-analysis.html\\" data-fallback=\\"正确答案： A 【解析】 虚拟地址为 16 位，页大小为 256 B，因此页内偏移占 8 位，页号占 8 位。 TLB 为 4 路组相联，共 16 个表项，故分为 4 组，组索引占 2 位，标记占 6 位。 页号 22 的二进制为 00010110，高 6 位标记为 05H，低 2 位组索引为 10（即 2），因此页号\\"></div>", "questionItemObjects": [{"prefix": "A", "content": "Tag-05H, V-1, PPN=1CH", "itemUuid": "09d67fd3"}, {"prefix": "B", "content": "Tag=06H，V=1，PPN=2AH", "itemUuid": "81e8fe0c"}, {"prefix": "C", "content": "Tag=16H，V=0，PPN=2AH", "itemUuid": "ad294dcf"}, {"prefix": "D", "content": "Tag-1AH，V=0，PPN-1CH", "itemUuid": "8ee8dcca"}]}', NOW());
SET @tc19 = LAST_INSERT_ID();
INSERT INTO t_question
  (question_type, subject_id, score, grade_level, difficult, correct, info_text_content_id, create_user, status, deleted,
   title, options, correct_answer, analysis, difficulty, knowledge_point, source, source_year, source_question_no, tags, images,
   title_text, analysis_text, content_format, has_image, has_code)
VALUES
  (1, 2, 20, NULL, 2, 'A', @tc19, 1, 1, b'0',
   '<div class="question-html-ref" data-src="question-html/2026/q19-title.html" data-fallback="某计算机按字节编址，虚拟地址为 16 位，页大小为 256B，页表项中包含装入位（P）、页框号（PPN）等字段。TLB 采用 4 路组相联映射，共有 16 个页表项，TLB 表项中包含标记（Tag）、有效位（V）等字段。在主存页表与 TLB 表项同步后，若主存页表中页号 22 对应的页表项中 P = 0 ， PPN ="></div>', '[{"prefix": "A", "content": "Tag-05H, V-1, PPN=1CH", "itemUuid": "09d67fd3"}, {"prefix": "B", "content": "Tag=06H，V=1，PPN=2AH", "itemUuid": "81e8fe0c"}, {"prefix": "C", "content": "Tag=16H，V=0，PPN=2AH", "itemUuid": "ad294dcf"}, {"prefix": "D", "content": "Tag-1AH，V=0，PPN-1CH", "itemUuid": "8ee8dcca"}]', 'A', '<div class="question-html-ref" data-src="question-html/2026/q19-analysis.html" data-fallback="正确答案： A 【解析】 虚拟地址为 16 位，页大小为 256 B，因此页内偏移占 8 位，页号占 8 位。 TLB 为 4 路组相联，共 16 个表项，故分为 4 组，组索引占 2 位，标记占 6 位。 页号 22 的二进制为 00010110，高 6 位标记为 05H，低 2 位组索引为 10（即 2），因此页号"></div>',
   2, NULL, '2026年408模拟题', 2026, 19, 'html,external_html,katex', '',
   '某计算机按字节编址，虚拟地址为 16 位，页大小为 256B，页表项中包含装入位（P）、页框号（PPN）等字段。TLB 采用 4 路组相联映射，共有 16 个页表项，TLB 表项中包含标记（Tag）、有效位（V）等字段。在主存页表与 TLB 表项同步后，若主存页表中页号 22 对应的页表项中 P = 0 ， PPN = 2 A H ，则下列不可能出现在组号为 2 的 TLB 表项中的是（ ）', '正确答案： A 【解析】 虚拟地址为 16 位，页大小为 256 B，因此页内偏移占 8 位，页号占 8 位。 TLB 为 4 路组相联，共 16 个表项，故分为 4 组，组索引占 2 位，标记占 6 位。 页号 22 的二进制为 00010110，高 6 位标记为 05H，低 2 位组索引为 10（即 2），因此页号 22 属于组 2。 已知主存页表中页号 22 对应的表项 P=0、PPN=2AH，同步后 TLB 中若存在该页表项，则有效位 V 应与 P 一致（即 V=0），且 PPN 应为 2AH。 选项 A 的标记为 05H，对应页号 22，但 V=1、PPN=1CH，与页表项冲突，不可能出现在组 2 的 TLB 中。 其他选项对应不同页号（如 B 对应页号 26，C 对应页号 90，D 对应页号 106），其页表项未知，故可能出现在 TLB 中。', 'html', b'0', b'0');
SET @q19 = LAST_INSERT_ID();
INSERT INTO question_content
  (question_id, version, title, options, correct_answer, analysis, title_text, analysis_text, content_format, has_image, has_code, legacy_text_content_id, source_hash, is_current)
VALUES
  (@q19, 1, '<div class="question-html-ref" data-src="question-html/2026/q19-title.html" data-fallback="某计算机按字节编址，虚拟地址为 16 位，页大小为 256B，页表项中包含装入位（P）、页框号（PPN）等字段。TLB 采用 4 路组相联映射，共有 16 个页表项，TLB 表项中包含标记（Tag）、有效位（V）等字段。在主存页表与 TLB 表项同步后，若主存页表中页号 22 对应的页表项中 P = 0 ， PPN ="></div>', '[{"prefix": "A", "content": "Tag-05H, V-1, PPN=1CH", "itemUuid": "09d67fd3"}, {"prefix": "B", "content": "Tag=06H，V=1，PPN=2AH", "itemUuid": "81e8fe0c"}, {"prefix": "C", "content": "Tag=16H，V=0，PPN=2AH", "itemUuid": "ad294dcf"}, {"prefix": "D", "content": "Tag-1AH，V=0，PPN-1CH", "itemUuid": "8ee8dcca"}]', 'A', '<div class="question-html-ref" data-src="question-html/2026/q19-analysis.html" data-fallback="正确答案： A 【解析】 虚拟地址为 16 位，页大小为 256 B，因此页内偏移占 8 位，页号占 8 位。 TLB 为 4 路组相联，共 16 个表项，故分为 4 组，组索引占 2 位，标记占 6 位。 页号 22 的二进制为 00010110，高 6 位标记为 05H，低 2 位组索引为 10（即 2），因此页号"></div>',
   '某计算机按字节编址，虚拟地址为 16 位，页大小为 256B，页表项中包含装入位（P）、页框号（PPN）等字段。TLB 采用 4 路组相联映射，共有 16 个页表项，TLB 表项中包含标记（Tag）、有效位（V）等字段。在主存页表与 TLB 表项同步后，若主存页表中页号 22 对应的页表项中 P = 0 ， PPN = 2 A H ，则下列不可能出现在组号为 2 的 TLB 表项中的是（ ）', '正确答案： A 【解析】 虚拟地址为 16 位，页大小为 256 B，因此页内偏移占 8 位，页号占 8 位。 TLB 为 4 路组相联，共 16 个表项，故分为 4 组，组索引占 2 位，标记占 6 位。 页号 22 的二进制为 00010110，高 6 位标记为 05H，低 2 位组索引为 10（即 2），因此页号 22 属于组 2。 已知主存页表中页号 22 对应的表项 P=0、PPN=2AH，同步后 TLB 中若存在该页表项，则有效位 V 应与 P 一致（即 V=0），且 PPN 应为 2AH。 选项 A 的标记为 05H，对应页号 22，但 V=1、PPN=1CH，与页表项冲突，不可能出现在组 2 的 TLB 中。 其他选项对应不同页号（如 B 对应页号 26，C 对应页号 90，D 对应页号 106），其页表项未知，故可能出现在 TLB 中。', 'html', b'0', b'0', @tc19, '9fc43149dab6ea4cd357f5c0f96ae16900859a36ef13869fd42b9818af8294e3', b'1');
INSERT INTO question_source
  (question_id, source_type, source_name, source_year, source_question_no, paper_name, raw_ref, metadata)
VALUES
  (@q19, 'crawler_html', '计算机考研杂货铺', 2026, '19', '2026年408计算机学科专业基础综合模拟试题',
   'C:/Users/wutia/Downloads/csgraduates2026.html', '{"subject": "组成原理", "html": true}');

-- Q20
INSERT INTO t_text_content (content, create_time)
VALUES ('{"titleContent": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q20-title.html\\" data-fallback=\\"在不考虑异常中断处理和访存的额外开销下，下列关于数据通路结构与 CPI 之间的关系正确的为（） I. 单周期数据通路计算机的 CPI 等于 1 II. 多周期数据通路计算机的 CPI 大于 1 III. 流水线数据通路计算机的 CPI 等于 1\\"></div>", "analyze": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q20-analysis.html\\" data-fallback=\\"正确答案： D 【解析】 在不考虑异常中断处理和访存的额外开销下，单周期数据通路中每条指令在一个时钟周期内完成，因此 CPI 等于 1。 多周期数据通路中每条指令需要多个时钟周期执行，因此 CPI 大于 1。 流水线数据通路在理想情况下（无冒险和停顿）可以实现每个时钟周期完成一条指令，因此 CPI 等于 1。 故 I、\\"></div>", "questionItemObjects": [{"prefix": "A", "content": "仅 I、II", "itemUuid": "6b7a32b1"}, {"prefix": "B", "content": "仅 I、III", "itemUuid": "e8a7fcee"}, {"prefix": "C", "content": "仅 II、III", "itemUuid": "af777be9"}, {"prefix": "D", "content": "I、II、III", "itemUuid": "76da3f6c"}]}', NOW());
SET @tc20 = LAST_INSERT_ID();
INSERT INTO t_question
  (question_type, subject_id, score, grade_level, difficult, correct, info_text_content_id, create_user, status, deleted,
   title, options, correct_answer, analysis, difficulty, knowledge_point, source, source_year, source_question_no, tags, images,
   title_text, analysis_text, content_format, has_image, has_code)
VALUES
  (1, 2, 20, NULL, 2, 'D', @tc20, 1, 1, b'0',
   '<div class="question-html-ref" data-src="question-html/2026/q20-title.html" data-fallback="在不考虑异常中断处理和访存的额外开销下，下列关于数据通路结构与 CPI 之间的关系正确的为（） I. 单周期数据通路计算机的 CPI 等于 1 II. 多周期数据通路计算机的 CPI 大于 1 III. 流水线数据通路计算机的 CPI 等于 1"></div>', '[{"prefix": "A", "content": "仅 I、II", "itemUuid": "6b7a32b1"}, {"prefix": "B", "content": "仅 I、III", "itemUuid": "e8a7fcee"}, {"prefix": "C", "content": "仅 II、III", "itemUuid": "af777be9"}, {"prefix": "D", "content": "I、II、III", "itemUuid": "76da3f6c"}]', 'D', '<div class="question-html-ref" data-src="question-html/2026/q20-analysis.html" data-fallback="正确答案： D 【解析】 在不考虑异常中断处理和访存的额外开销下，单周期数据通路中每条指令在一个时钟周期内完成，因此 CPI 等于 1。 多周期数据通路中每条指令需要多个时钟周期执行，因此 CPI 大于 1。 流水线数据通路在理想情况下（无冒险和停顿）可以实现每个时钟周期完成一条指令，因此 CPI 等于 1。 故 I、"></div>',
   2, NULL, '2026年408模拟题', 2026, 20, 'html,external_html', '',
   '在不考虑异常中断处理和访存的额外开销下，下列关于数据通路结构与 CPI 之间的关系正确的为（） I. 单周期数据通路计算机的 CPI 等于 1 II. 多周期数据通路计算机的 CPI 大于 1 III. 流水线数据通路计算机的 CPI 等于 1', '正确答案： D 【解析】 在不考虑异常中断处理和访存的额外开销下，单周期数据通路中每条指令在一个时钟周期内完成，因此 CPI 等于 1。 多周期数据通路中每条指令需要多个时钟周期执行，因此 CPI 大于 1。 流水线数据通路在理想情况下（无冒险和停顿）可以实现每个时钟周期完成一条指令，因此 CPI 等于 1。 故 I、II、III 均正确。 注意：II 在理想情况下（完美的 overlap，运行的时间无限长)，CPI 是趋向于 1 的，但是这一题显然不是考察的理想情况，所以 II 是正确的。', 'html', b'0', b'0');
SET @q20 = LAST_INSERT_ID();
INSERT INTO question_content
  (question_id, version, title, options, correct_answer, analysis, title_text, analysis_text, content_format, has_image, has_code, legacy_text_content_id, source_hash, is_current)
VALUES
  (@q20, 1, '<div class="question-html-ref" data-src="question-html/2026/q20-title.html" data-fallback="在不考虑异常中断处理和访存的额外开销下，下列关于数据通路结构与 CPI 之间的关系正确的为（） I. 单周期数据通路计算机的 CPI 等于 1 II. 多周期数据通路计算机的 CPI 大于 1 III. 流水线数据通路计算机的 CPI 等于 1"></div>', '[{"prefix": "A", "content": "仅 I、II", "itemUuid": "6b7a32b1"}, {"prefix": "B", "content": "仅 I、III", "itemUuid": "e8a7fcee"}, {"prefix": "C", "content": "仅 II、III", "itemUuid": "af777be9"}, {"prefix": "D", "content": "I、II、III", "itemUuid": "76da3f6c"}]', 'D', '<div class="question-html-ref" data-src="question-html/2026/q20-analysis.html" data-fallback="正确答案： D 【解析】 在不考虑异常中断处理和访存的额外开销下，单周期数据通路中每条指令在一个时钟周期内完成，因此 CPI 等于 1。 多周期数据通路中每条指令需要多个时钟周期执行，因此 CPI 大于 1。 流水线数据通路在理想情况下（无冒险和停顿）可以实现每个时钟周期完成一条指令，因此 CPI 等于 1。 故 I、"></div>',
   '在不考虑异常中断处理和访存的额外开销下，下列关于数据通路结构与 CPI 之间的关系正确的为（） I. 单周期数据通路计算机的 CPI 等于 1 II. 多周期数据通路计算机的 CPI 大于 1 III. 流水线数据通路计算机的 CPI 等于 1', '正确答案： D 【解析】 在不考虑异常中断处理和访存的额外开销下，单周期数据通路中每条指令在一个时钟周期内完成，因此 CPI 等于 1。 多周期数据通路中每条指令需要多个时钟周期执行，因此 CPI 大于 1。 流水线数据通路在理想情况下（无冒险和停顿）可以实现每个时钟周期完成一条指令，因此 CPI 等于 1。 故 I、II、III 均正确。 注意：II 在理想情况下（完美的 overlap，运行的时间无限长)，CPI 是趋向于 1 的，但是这一题显然不是考察的理想情况，所以 II 是正确的。', 'html', b'0', b'0', @tc20, '75bdbe41589588238390dafeea0f201c30bff383d058350d8bccff12881c6396', b'1');
INSERT INTO question_source
  (question_id, source_type, source_name, source_year, source_question_no, paper_name, raw_ref, metadata)
VALUES
  (@q20, 'crawler_html', '计算机考研杂货铺', 2026, '20', '2026年408计算机学科专业基础综合模拟试题',
   'C:/Users/wutia/Downloads/csgraduates2026.html', '{"subject": "组成原理", "html": true}');

-- Q21
INSERT INTO t_text_content (content, create_time)
VALUES ('{"titleContent": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q21-title.html\\" data-fallback=\\"在 I/O 子系统中，驱动程序和中断服务程序直接控制外设与主机之间的输入/输出操作，这一过程需要使用一些特权指令。下列指令中，不属于特权指令的是（）\\"></div>", "analyze": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q21-analysis.html\\" data-fallback=\\"正确答案： D 【解析】 在计算机系统中，特权指令是指只能在操作系统内核态下执行的指令，用于保护系统资源和稳定性。 A 项 I/O 指令直接控制外设操作，若用户程序随意执行可能干扰系统，因此属于特权指令； B 项关中断指令用于禁用中断，防止关键代码被中断打断，若用户程序可随意关闭中断会导致系统无法响应关键事件，故为特权\\"></div>", "questionItemObjects": [{"prefix": "A", "content": "I/O 指令", "itemUuid": "8eaa0c1d"}, {"prefix": "B", "content": "关中断指令", "itemUuid": "9f2453ed"}, {"prefix": "C", "content": "中断返回指令", "itemUuid": "b2f86ba9"}, {"prefix": "D", "content": "系统调用指令", "itemUuid": "81697bee"}]}', NOW());
SET @tc21 = LAST_INSERT_ID();
INSERT INTO t_question
  (question_type, subject_id, score, grade_level, difficult, correct, info_text_content_id, create_user, status, deleted,
   title, options, correct_answer, analysis, difficulty, knowledge_point, source, source_year, source_question_no, tags, images,
   title_text, analysis_text, content_format, has_image, has_code)
VALUES
  (1, 2, 20, NULL, 2, 'D', @tc21, 1, 1, b'0',
   '<div class="question-html-ref" data-src="question-html/2026/q21-title.html" data-fallback="在 I/O 子系统中，驱动程序和中断服务程序直接控制外设与主机之间的输入/输出操作，这一过程需要使用一些特权指令。下列指令中，不属于特权指令的是（）"></div>', '[{"prefix": "A", "content": "I/O 指令", "itemUuid": "8eaa0c1d"}, {"prefix": "B", "content": "关中断指令", "itemUuid": "9f2453ed"}, {"prefix": "C", "content": "中断返回指令", "itemUuid": "b2f86ba9"}, {"prefix": "D", "content": "系统调用指令", "itemUuid": "81697bee"}]', 'D', '<div class="question-html-ref" data-src="question-html/2026/q21-analysis.html" data-fallback="正确答案： D 【解析】 在计算机系统中，特权指令是指只能在操作系统内核态下执行的指令，用于保护系统资源和稳定性。 A 项 I/O 指令直接控制外设操作，若用户程序随意执行可能干扰系统，因此属于特权指令； B 项关中断指令用于禁用中断，防止关键代码被中断打断，若用户程序可随意关闭中断会导致系统无法响应关键事件，故为特权"></div>',
   2, NULL, '2026年408模拟题', 2026, 21, 'html,external_html', '',
   '在 I/O 子系统中，驱动程序和中断服务程序直接控制外设与主机之间的输入/输出操作，这一过程需要使用一些特权指令。下列指令中，不属于特权指令的是（）', '正确答案： D 【解析】 在计算机系统中，特权指令是指只能在操作系统内核态下执行的指令，用于保护系统资源和稳定性。 A 项 I/O 指令直接控制外设操作，若用户程序随意执行可能干扰系统，因此属于特权指令； B 项关中断指令用于禁用中断，防止关键代码被中断打断，若用户程序可随意关闭中断会导致系统无法响应关键事件，故为特权指令； C 项中断返回指令用于从中断处理程序返回，涉及处理器状态恢复和权限切换，通常需在内核态执行，也属于特权指令。 D 项系统调用指令（如 syscall 或 int 指令）是用户程序请求操作系统服务的接口，该指令本身可在用户态执行，通过触发陷入机制切换到内核态，由操作系统内核处理具体操作，因此不属于特权指令。', 'html', b'0', b'0');
SET @q21 = LAST_INSERT_ID();
INSERT INTO question_content
  (question_id, version, title, options, correct_answer, analysis, title_text, analysis_text, content_format, has_image, has_code, legacy_text_content_id, source_hash, is_current)
VALUES
  (@q21, 1, '<div class="question-html-ref" data-src="question-html/2026/q21-title.html" data-fallback="在 I/O 子系统中，驱动程序和中断服务程序直接控制外设与主机之间的输入/输出操作，这一过程需要使用一些特权指令。下列指令中，不属于特权指令的是（）"></div>', '[{"prefix": "A", "content": "I/O 指令", "itemUuid": "8eaa0c1d"}, {"prefix": "B", "content": "关中断指令", "itemUuid": "9f2453ed"}, {"prefix": "C", "content": "中断返回指令", "itemUuid": "b2f86ba9"}, {"prefix": "D", "content": "系统调用指令", "itemUuid": "81697bee"}]', 'D', '<div class="question-html-ref" data-src="question-html/2026/q21-analysis.html" data-fallback="正确答案： D 【解析】 在计算机系统中，特权指令是指只能在操作系统内核态下执行的指令，用于保护系统资源和稳定性。 A 项 I/O 指令直接控制外设操作，若用户程序随意执行可能干扰系统，因此属于特权指令； B 项关中断指令用于禁用中断，防止关键代码被中断打断，若用户程序可随意关闭中断会导致系统无法响应关键事件，故为特权"></div>',
   '在 I/O 子系统中，驱动程序和中断服务程序直接控制外设与主机之间的输入/输出操作，这一过程需要使用一些特权指令。下列指令中，不属于特权指令的是（）', '正确答案： D 【解析】 在计算机系统中，特权指令是指只能在操作系统内核态下执行的指令，用于保护系统资源和稳定性。 A 项 I/O 指令直接控制外设操作，若用户程序随意执行可能干扰系统，因此属于特权指令； B 项关中断指令用于禁用中断，防止关键代码被中断打断，若用户程序可随意关闭中断会导致系统无法响应关键事件，故为特权指令； C 项中断返回指令用于从中断处理程序返回，涉及处理器状态恢复和权限切换，通常需在内核态执行，也属于特权指令。 D 项系统调用指令（如 syscall 或 int 指令）是用户程序请求操作系统服务的接口，该指令本身可在用户态执行，通过触发陷入机制切换到内核态，由操作系统内核处理具体操作，因此不属于特权指令。', 'html', b'0', b'0', @tc21, '57b42f4533dd777d72425361819a1ce125f1b9bc0d40d6d8b80d646cb0e944e8', b'1');
INSERT INTO question_source
  (question_id, source_type, source_name, source_year, source_question_no, paper_name, raw_ref, metadata)
VALUES
  (@q21, 'crawler_html', '计算机考研杂货铺', 2026, '21', '2026年408计算机学科专业基础综合模拟试题',
   'C:/Users/wutia/Downloads/csgraduates2026.html', '{"subject": "组成原理", "html": true}');

-- Q22
INSERT INTO t_text_content (content, create_time)
VALUES ('{"titleContent": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q22-title.html\\" data-fallback=\\"中断控制 I/O 方式下，实现 I/O 需要硬件和软件协同完成，中断响应和处理过程中所包含的下列工作中，必须由硬件完成的是（）\\"></div>", "analyze": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q22-analysis.html\\" data-fallback=\\"正确答案： C 【解析】 在中断控制 I/O 方式下，中断响应和处理需要硬件和软件协同工作。 保存断点 （即程序计数器的值）必须由硬件自动完成。因为中断发生时需立即保存返回地址，以确保后续能正确恢复执行。 开中断 是通过软件指令实现的，用于允许或禁止中断嵌套。 中断请求 由硬件设备产生，但响应和处理过程涉及软硬件配合。\\"></div>", "questionItemObjects": [{"prefix": "A", "content": "开中断", "itemUuid": "c84f81f7"}, {"prefix": "B", "content": "中断", "itemUuid": "ad03ccd2"}, {"prefix": "C", "content": "保存断点", "itemUuid": "7cf3baf2"}, {"prefix": "D", "content": "保存通用寄存器", "itemUuid": "9c398c42"}]}', NOW());
SET @tc22 = LAST_INSERT_ID();
INSERT INTO t_question
  (question_type, subject_id, score, grade_level, difficult, correct, info_text_content_id, create_user, status, deleted,
   title, options, correct_answer, analysis, difficulty, knowledge_point, source, source_year, source_question_no, tags, images,
   title_text, analysis_text, content_format, has_image, has_code)
VALUES
  (1, 2, 20, NULL, 2, 'C', @tc22, 1, 1, b'0',
   '<div class="question-html-ref" data-src="question-html/2026/q22-title.html" data-fallback="中断控制 I/O 方式下，实现 I/O 需要硬件和软件协同完成，中断响应和处理过程中所包含的下列工作中，必须由硬件完成的是（）"></div>', '[{"prefix": "A", "content": "开中断", "itemUuid": "c84f81f7"}, {"prefix": "B", "content": "中断", "itemUuid": "ad03ccd2"}, {"prefix": "C", "content": "保存断点", "itemUuid": "7cf3baf2"}, {"prefix": "D", "content": "保存通用寄存器", "itemUuid": "9c398c42"}]', 'C', '<div class="question-html-ref" data-src="question-html/2026/q22-analysis.html" data-fallback="正确答案： C 【解析】 在中断控制 I/O 方式下，中断响应和处理需要硬件和软件协同工作。 保存断点 （即程序计数器的值）必须由硬件自动完成。因为中断发生时需立即保存返回地址，以确保后续能正确恢复执行。 开中断 是通过软件指令实现的，用于允许或禁止中断嵌套。 中断请求 由硬件设备产生，但响应和处理过程涉及软硬件配合。"></div>',
   2, NULL, '2026年408模拟题', 2026, 22, 'html,external_html', '',
   '中断控制 I/O 方式下，实现 I/O 需要硬件和软件协同完成，中断响应和处理过程中所包含的下列工作中，必须由硬件完成的是（）', '正确答案： C 【解析】 在中断控制 I/O 方式下，中断响应和处理需要硬件和软件协同工作。 保存断点 （即程序计数器的值）必须由硬件自动完成。因为中断发生时需立即保存返回地址，以确保后续能正确恢复执行。 开中断 是通过软件指令实现的，用于允许或禁止中断嵌套。 中断请求 由硬件设备产生，但响应和处理过程涉及软硬件配合。 保存通用寄存器 通常由中断服务程序（软件）完成，以保护原程序的上下文。 因此，只有保存断点必须由硬件完成。', 'html', b'0', b'0');
SET @q22 = LAST_INSERT_ID();
INSERT INTO question_content
  (question_id, version, title, options, correct_answer, analysis, title_text, analysis_text, content_format, has_image, has_code, legacy_text_content_id, source_hash, is_current)
VALUES
  (@q22, 1, '<div class="question-html-ref" data-src="question-html/2026/q22-title.html" data-fallback="中断控制 I/O 方式下，实现 I/O 需要硬件和软件协同完成，中断响应和处理过程中所包含的下列工作中，必须由硬件完成的是（）"></div>', '[{"prefix": "A", "content": "开中断", "itemUuid": "c84f81f7"}, {"prefix": "B", "content": "中断", "itemUuid": "ad03ccd2"}, {"prefix": "C", "content": "保存断点", "itemUuid": "7cf3baf2"}, {"prefix": "D", "content": "保存通用寄存器", "itemUuid": "9c398c42"}]', 'C', '<div class="question-html-ref" data-src="question-html/2026/q22-analysis.html" data-fallback="正确答案： C 【解析】 在中断控制 I/O 方式下，中断响应和处理需要硬件和软件协同工作。 保存断点 （即程序计数器的值）必须由硬件自动完成。因为中断发生时需立即保存返回地址，以确保后续能正确恢复执行。 开中断 是通过软件指令实现的，用于允许或禁止中断嵌套。 中断请求 由硬件设备产生，但响应和处理过程涉及软硬件配合。"></div>',
   '中断控制 I/O 方式下，实现 I/O 需要硬件和软件协同完成，中断响应和处理过程中所包含的下列工作中，必须由硬件完成的是（）', '正确答案： C 【解析】 在中断控制 I/O 方式下，中断响应和处理需要硬件和软件协同工作。 保存断点 （即程序计数器的值）必须由硬件自动完成。因为中断发生时需立即保存返回地址，以确保后续能正确恢复执行。 开中断 是通过软件指令实现的，用于允许或禁止中断嵌套。 中断请求 由硬件设备产生，但响应和处理过程涉及软硬件配合。 保存通用寄存器 通常由中断服务程序（软件）完成，以保护原程序的上下文。 因此，只有保存断点必须由硬件完成。', 'html', b'0', b'0', @tc22, 'c06e37a48e6fd8a15957244f2a70021cbcc8aa44f05bfa98df3f8ec8cd6add57', b'1');
INSERT INTO question_source
  (question_id, source_type, source_name, source_year, source_question_no, paper_name, raw_ref, metadata)
VALUES
  (@q22, 'crawler_html', '计算机考研杂货铺', 2026, '22', '2026年408计算机学科专业基础综合模拟试题',
   'C:/Users/wutia/Downloads/csgraduates2026.html', '{"subject": "组成原理", "html": true}');

-- Q23
INSERT INTO t_text_content (content, create_time)
VALUES ('{"titleContent": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q23-title.html\\" data-fallback=\\"下列操作中，在内核模式执行的是（）\\"></div>", "analyze": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q23-analysis.html\\" data-fallback=\\"正确答案： C 【解析】 在操作系统中，内核模式用于执行特权指令和访问核心资源，如硬件管理和进程控制。编译程序、链接程序和命令解释程序通常作为用户空间的应用程序运行，在用户模式下执行；而装入程序负责将可执行文件加载到内存并启动进程，这一过程涉及内存分配和进程创建等特权操作，因此由操作系统内核在内核模式下执行。\\"></div>", "questionItemObjects": [{"prefix": "A", "content": "编译程序", "itemUuid": "ec5bbff3"}, {"prefix": "B", "content": "链接程序", "itemUuid": "a4ab9c5e"}, {"prefix": "C", "content": "装入程序", "itemUuid": "6cb5b47a"}, {"prefix": "D", "content": "命令解释程序", "itemUuid": "d3f67a09"}]}', NOW());
SET @tc23 = LAST_INSERT_ID();
INSERT INTO t_question
  (question_type, subject_id, score, grade_level, difficult, correct, info_text_content_id, create_user, status, deleted,
   title, options, correct_answer, analysis, difficulty, knowledge_point, source, source_year, source_question_no, tags, images,
   title_text, analysis_text, content_format, has_image, has_code)
VALUES
  (1, 3, 20, NULL, 2, 'C', @tc23, 1, 1, b'0',
   '<div class="question-html-ref" data-src="question-html/2026/q23-title.html" data-fallback="下列操作中，在内核模式执行的是（）"></div>', '[{"prefix": "A", "content": "编译程序", "itemUuid": "ec5bbff3"}, {"prefix": "B", "content": "链接程序", "itemUuid": "a4ab9c5e"}, {"prefix": "C", "content": "装入程序", "itemUuid": "6cb5b47a"}, {"prefix": "D", "content": "命令解释程序", "itemUuid": "d3f67a09"}]', 'C', '<div class="question-html-ref" data-src="question-html/2026/q23-analysis.html" data-fallback="正确答案： C 【解析】 在操作系统中，内核模式用于执行特权指令和访问核心资源，如硬件管理和进程控制。编译程序、链接程序和命令解释程序通常作为用户空间的应用程序运行，在用户模式下执行；而装入程序负责将可执行文件加载到内存并启动进程，这一过程涉及内存分配和进程创建等特权操作，因此由操作系统内核在内核模式下执行。"></div>',
   2, NULL, '2026年408模拟题', 2026, 23, 'html,external_html', '',
   '下列操作中，在内核模式执行的是（）', '正确答案： C 【解析】 在操作系统中，内核模式用于执行特权指令和访问核心资源，如硬件管理和进程控制。编译程序、链接程序和命令解释程序通常作为用户空间的应用程序运行，在用户模式下执行；而装入程序负责将可执行文件加载到内存并启动进程，这一过程涉及内存分配和进程创建等特权操作，因此由操作系统内核在内核模式下执行。', 'html', b'0', b'0');
SET @q23 = LAST_INSERT_ID();
INSERT INTO question_content
  (question_id, version, title, options, correct_answer, analysis, title_text, analysis_text, content_format, has_image, has_code, legacy_text_content_id, source_hash, is_current)
VALUES
  (@q23, 1, '<div class="question-html-ref" data-src="question-html/2026/q23-title.html" data-fallback="下列操作中，在内核模式执行的是（）"></div>', '[{"prefix": "A", "content": "编译程序", "itemUuid": "ec5bbff3"}, {"prefix": "B", "content": "链接程序", "itemUuid": "a4ab9c5e"}, {"prefix": "C", "content": "装入程序", "itemUuid": "6cb5b47a"}, {"prefix": "D", "content": "命令解释程序", "itemUuid": "d3f67a09"}]', 'C', '<div class="question-html-ref" data-src="question-html/2026/q23-analysis.html" data-fallback="正确答案： C 【解析】 在操作系统中，内核模式用于执行特权指令和访问核心资源，如硬件管理和进程控制。编译程序、链接程序和命令解释程序通常作为用户空间的应用程序运行，在用户模式下执行；而装入程序负责将可执行文件加载到内存并启动进程，这一过程涉及内存分配和进程创建等特权操作，因此由操作系统内核在内核模式下执行。"></div>',
   '下列操作中，在内核模式执行的是（）', '正确答案： C 【解析】 在操作系统中，内核模式用于执行特权指令和访问核心资源，如硬件管理和进程控制。编译程序、链接程序和命令解释程序通常作为用户空间的应用程序运行，在用户模式下执行；而装入程序负责将可执行文件加载到内存并启动进程，这一过程涉及内存分配和进程创建等特权操作，因此由操作系统内核在内核模式下执行。', 'html', b'0', b'0', @tc23, '94d134d9407666ba479536250da91877624e8f6f157f297ceb06a6ff2810f234', b'1');
INSERT INTO question_source
  (question_id, source_type, source_name, source_year, source_question_no, paper_name, raw_ref, metadata)
VALUES
  (@q23, 'crawler_html', '计算机考研杂货铺', 2026, '23', '2026年408计算机学科专业基础综合模拟试题',
   'C:/Users/wutia/Downloads/csgraduates2026.html', '{"subject": "操作系统", "html": true}');

-- Q24
INSERT INTO t_text_content (content, create_time)
VALUES ('{"titleContent": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q24-title.html\\" data-fallback=\\"在支持虚拟存储器系统下的指令执行过程中，正确的是（）\\"></div>", "analyze": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q24-analysis.html\\" data-fallback=\\"正确答案： D 【解析】 在支持虚拟存储器的系统中，地址转换由硬件（如内存管理单元 MMU）完成，操作系统仅负责管理页表；页表项的内容由操作系统在运行时动态设置，而非编译器；缺页中断由硬件触发，但实际处理（如加载页面）由操作系统完成；异常（包括缺页异常、非法指令等）在触发后统一由操作系统处理。因此，选项 D 正确。\\"></div>", "questionItemObjects": [{"prefix": "A", "content": "地址转换由操作系统完成", "itemUuid": "ff60d6eb"}, {"prefix": "B", "content": "页表项的内容由编译器确定", "itemUuid": "058fc02d"}, {"prefix": "C", "content": "缺页中断由硬件直接处理", "itemUuid": "8e07410a"}, {"prefix": "D", "content": "异常由操作系统处理", "itemUuid": "2e36efca"}]}', NOW());
SET @tc24 = LAST_INSERT_ID();
INSERT INTO t_question
  (question_type, subject_id, score, grade_level, difficult, correct, info_text_content_id, create_user, status, deleted,
   title, options, correct_answer, analysis, difficulty, knowledge_point, source, source_year, source_question_no, tags, images,
   title_text, analysis_text, content_format, has_image, has_code)
VALUES
  (1, 3, 20, NULL, 2, 'D', @tc24, 1, 1, b'0',
   '<div class="question-html-ref" data-src="question-html/2026/q24-title.html" data-fallback="在支持虚拟存储器系统下的指令执行过程中，正确的是（）"></div>', '[{"prefix": "A", "content": "地址转换由操作系统完成", "itemUuid": "ff60d6eb"}, {"prefix": "B", "content": "页表项的内容由编译器确定", "itemUuid": "058fc02d"}, {"prefix": "C", "content": "缺页中断由硬件直接处理", "itemUuid": "8e07410a"}, {"prefix": "D", "content": "异常由操作系统处理", "itemUuid": "2e36efca"}]', 'D', '<div class="question-html-ref" data-src="question-html/2026/q24-analysis.html" data-fallback="正确答案： D 【解析】 在支持虚拟存储器的系统中，地址转换由硬件（如内存管理单元 MMU）完成，操作系统仅负责管理页表；页表项的内容由操作系统在运行时动态设置，而非编译器；缺页中断由硬件触发，但实际处理（如加载页面）由操作系统完成；异常（包括缺页异常、非法指令等）在触发后统一由操作系统处理。因此，选项 D 正确。"></div>',
   2, NULL, '2026年408模拟题', 2026, 24, 'html,external_html', '',
   '在支持虚拟存储器系统下的指令执行过程中，正确的是（）', '正确答案： D 【解析】 在支持虚拟存储器的系统中，地址转换由硬件（如内存管理单元 MMU）完成，操作系统仅负责管理页表；页表项的内容由操作系统在运行时动态设置，而非编译器；缺页中断由硬件触发，但实际处理（如加载页面）由操作系统完成；异常（包括缺页异常、非法指令等）在触发后统一由操作系统处理。因此，选项 D 正确。', 'html', b'0', b'0');
SET @q24 = LAST_INSERT_ID();
INSERT INTO question_content
  (question_id, version, title, options, correct_answer, analysis, title_text, analysis_text, content_format, has_image, has_code, legacy_text_content_id, source_hash, is_current)
VALUES
  (@q24, 1, '<div class="question-html-ref" data-src="question-html/2026/q24-title.html" data-fallback="在支持虚拟存储器系统下的指令执行过程中，正确的是（）"></div>', '[{"prefix": "A", "content": "地址转换由操作系统完成", "itemUuid": "ff60d6eb"}, {"prefix": "B", "content": "页表项的内容由编译器确定", "itemUuid": "058fc02d"}, {"prefix": "C", "content": "缺页中断由硬件直接处理", "itemUuid": "8e07410a"}, {"prefix": "D", "content": "异常由操作系统处理", "itemUuid": "2e36efca"}]', 'D', '<div class="question-html-ref" data-src="question-html/2026/q24-analysis.html" data-fallback="正确答案： D 【解析】 在支持虚拟存储器的系统中，地址转换由硬件（如内存管理单元 MMU）完成，操作系统仅负责管理页表；页表项的内容由操作系统在运行时动态设置，而非编译器；缺页中断由硬件触发，但实际处理（如加载页面）由操作系统完成；异常（包括缺页异常、非法指令等）在触发后统一由操作系统处理。因此，选项 D 正确。"></div>',
   '在支持虚拟存储器系统下的指令执行过程中，正确的是（）', '正确答案： D 【解析】 在支持虚拟存储器的系统中，地址转换由硬件（如内存管理单元 MMU）完成，操作系统仅负责管理页表；页表项的内容由操作系统在运行时动态设置，而非编译器；缺页中断由硬件触发，但实际处理（如加载页面）由操作系统完成；异常（包括缺页异常、非法指令等）在触发后统一由操作系统处理。因此，选项 D 正确。', 'html', b'0', b'0', @tc24, 'cefd736b1ef646aae2c90b5d87b8d8baf0bc5d8ae11ee69b9b15aabd7f5a538c', b'1');
INSERT INTO question_source
  (question_id, source_type, source_name, source_year, source_question_no, paper_name, raw_ref, metadata)
VALUES
  (@q24, 'crawler_html', '计算机考研杂货铺', 2026, '24', '2026年408计算机学科专业基础综合模拟试题',
   'C:/Users/wutia/Downloads/csgraduates2026.html', '{"subject": "操作系统", "html": true}');

-- Q25
INSERT INTO t_text_content (content, create_time)
VALUES ('{"titleContent": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q25-title.html\\" data-fallback=\\"下列关于的线程描述中，正确的是（）\\"></div>", "analyze": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q25-analysis.html\\" data-fallback=\\"正确答案： D 【解析】 用户级线程由用户空间的线程库创建和管理，操作系统内核不参与其创建，因此 A 错误。 在线程映射模型中，常见的是多个用户级线程映射到一个内核级线程（多对一模型），或多个用户级线程映射到多个内核级线程（多对多模型），但多个内核级线程映射到一个用户级线程并不符合典型模型，故 B 错误。 栈是线程私有\\"></div>", "questionItemObjects": [{"prefix": "A", "content": "内核级线程和用户级线程都由操作系统创建", "itemUuid": "dd13b9d6"}, {"prefix": "B", "content": "多个内核级线程可以映射到一个用户级线程", "itemUuid": "231a2543"}, {"prefix": "C", "content": "同一个进程下的多个内核级线程共享进程栈", "itemUuid": "e4612568"}, {"prefix": "D", "content": "同一个进程下的多个线程共享进程堆", "itemUuid": "27ad0db9"}]}', NOW());
SET @tc25 = LAST_INSERT_ID();
INSERT INTO t_question
  (question_type, subject_id, score, grade_level, difficult, correct, info_text_content_id, create_user, status, deleted,
   title, options, correct_answer, analysis, difficulty, knowledge_point, source, source_year, source_question_no, tags, images,
   title_text, analysis_text, content_format, has_image, has_code)
VALUES
  (1, 3, 20, NULL, 2, 'D', @tc25, 1, 1, b'0',
   '<div class="question-html-ref" data-src="question-html/2026/q25-title.html" data-fallback="下列关于的线程描述中，正确的是（）"></div>', '[{"prefix": "A", "content": "内核级线程和用户级线程都由操作系统创建", "itemUuid": "dd13b9d6"}, {"prefix": "B", "content": "多个内核级线程可以映射到一个用户级线程", "itemUuid": "231a2543"}, {"prefix": "C", "content": "同一个进程下的多个内核级线程共享进程栈", "itemUuid": "e4612568"}, {"prefix": "D", "content": "同一个进程下的多个线程共享进程堆", "itemUuid": "27ad0db9"}]', 'D', '<div class="question-html-ref" data-src="question-html/2026/q25-analysis.html" data-fallback="正确答案： D 【解析】 用户级线程由用户空间的线程库创建和管理，操作系统内核不参与其创建，因此 A 错误。 在线程映射模型中，常见的是多个用户级线程映射到一个内核级线程（多对一模型），或多个用户级线程映射到多个内核级线程（多对多模型），但多个内核级线程映射到一个用户级线程并不符合典型模型，故 B 错误。 栈是线程私有"></div>',
   2, NULL, '2026年408模拟题', 2026, 25, 'html,external_html', '',
   '下列关于的线程描述中，正确的是（）', '正确答案： D 【解析】 用户级线程由用户空间的线程库创建和管理，操作系统内核不参与其创建，因此 A 错误。 在线程映射模型中，常见的是多个用户级线程映射到一个内核级线程（多对一模型），或多个用户级线程映射到多个内核级线程（多对多模型），但多个内核级线程映射到一个用户级线程并不符合典型模型，故 B 错误。 栈是线程私有的，每个线程（包括内核级线程）都有自己的栈，因此同一进程下的多个内核级线程不共享进程栈，C 错误。 堆是进程级别的资源，同一进程下的所有线程（包括用户级和内核级线程）共享进程堆，因此 D 正确。', 'html', b'0', b'0');
SET @q25 = LAST_INSERT_ID();
INSERT INTO question_content
  (question_id, version, title, options, correct_answer, analysis, title_text, analysis_text, content_format, has_image, has_code, legacy_text_content_id, source_hash, is_current)
VALUES
  (@q25, 1, '<div class="question-html-ref" data-src="question-html/2026/q25-title.html" data-fallback="下列关于的线程描述中，正确的是（）"></div>', '[{"prefix": "A", "content": "内核级线程和用户级线程都由操作系统创建", "itemUuid": "dd13b9d6"}, {"prefix": "B", "content": "多个内核级线程可以映射到一个用户级线程", "itemUuid": "231a2543"}, {"prefix": "C", "content": "同一个进程下的多个内核级线程共享进程栈", "itemUuid": "e4612568"}, {"prefix": "D", "content": "同一个进程下的多个线程共享进程堆", "itemUuid": "27ad0db9"}]', 'D', '<div class="question-html-ref" data-src="question-html/2026/q25-analysis.html" data-fallback="正确答案： D 【解析】 用户级线程由用户空间的线程库创建和管理，操作系统内核不参与其创建，因此 A 错误。 在线程映射模型中，常见的是多个用户级线程映射到一个内核级线程（多对一模型），或多个用户级线程映射到多个内核级线程（多对多模型），但多个内核级线程映射到一个用户级线程并不符合典型模型，故 B 错误。 栈是线程私有"></div>',
   '下列关于的线程描述中，正确的是（）', '正确答案： D 【解析】 用户级线程由用户空间的线程库创建和管理，操作系统内核不参与其创建，因此 A 错误。 在线程映射模型中，常见的是多个用户级线程映射到一个内核级线程（多对一模型），或多个用户级线程映射到多个内核级线程（多对多模型），但多个内核级线程映射到一个用户级线程并不符合典型模型，故 B 错误。 栈是线程私有的，每个线程（包括内核级线程）都有自己的栈，因此同一进程下的多个内核级线程不共享进程栈，C 错误。 堆是进程级别的资源，同一进程下的所有线程（包括用户级和内核级线程）共享进程堆，因此 D 正确。', 'html', b'0', b'0', @tc25, 'f69f3f2000c6a064656012a33dd0e7e14576347e2ccbdf31b83426cffe6689d5', b'1');
INSERT INTO question_source
  (question_id, source_type, source_name, source_year, source_question_no, paper_name, raw_ref, metadata)
VALUES
  (@q25, 'crawler_html', '计算机考研杂货铺', 2026, '25', '2026年408计算机学科专业基础综合模拟试题',
   'C:/Users/wutia/Downloads/csgraduates2026.html', '{"subject": "操作系统", "html": true}');

-- Q26
INSERT INTO t_text_content (content, create_time)
VALUES ('{"titleContent": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q26-title.html\\" data-fallback=\\"系统中有 8 个进程，执行下图的操作，资源 S 的初始值为 5。若此时 S 的值为 -2，其中 m 表示执行到访问资源的进程个数，n 表示阻塞的进程个数，则 m 和 n 的值分别是（ ） 计算机考研杂货铺 操作 wait(S) 访问资源 signal(S)\\"></div>", "analyze": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q26-analysis.html\\" data-fallback=\\"正确答案： A 【解析】 资源 S 是一个计数信号量，初始值为 5，表示最多允许 5 个进程同时访问资源。 当信号量值 S 为负数时，其绝对值表示阻塞的进程数。当前 S = -2，因此阻塞进程数 n = 2。 同时，当 S &lt; 0 时，所有初始资源均被占用，即有 5 个进程正在访问资源（处于临界区）。 m 表示执行到访\\"></div>", "questionItemObjects": [{"prefix": "A", "content": "5, 2", "itemUuid": "28869dd5"}, {"prefix": "B", "content": "5, 1", "itemUuid": "6520a3e9"}, {"prefix": "C", "content": "6, 2", "itemUuid": "e1911e04"}, {"prefix": "D", "content": "7, 1", "itemUuid": "c9244356"}]}', NOW());
SET @tc26 = LAST_INSERT_ID();
INSERT INTO t_question
  (question_type, subject_id, score, grade_level, difficult, correct, info_text_content_id, create_user, status, deleted,
   title, options, correct_answer, analysis, difficulty, knowledge_point, source, source_year, source_question_no, tags, images,
   title_text, analysis_text, content_format, has_image, has_code)
VALUES
  (1, 3, 20, NULL, 2, 'A', @tc26, 1, 1, b'0',
   '<div class="question-html-ref" data-src="question-html/2026/q26-title.html" data-fallback="系统中有 8 个进程，执行下图的操作，资源 S 的初始值为 5。若此时 S 的值为 -2，其中 m 表示执行到访问资源的进程个数，n 表示阻塞的进程个数，则 m 和 n 的值分别是（ ） 计算机考研杂货铺 操作 wait(S) 访问资源 signal(S)"></div>', '[{"prefix": "A", "content": "5, 2", "itemUuid": "28869dd5"}, {"prefix": "B", "content": "5, 1", "itemUuid": "6520a3e9"}, {"prefix": "C", "content": "6, 2", "itemUuid": "e1911e04"}, {"prefix": "D", "content": "7, 1", "itemUuid": "c9244356"}]', 'A', '<div class="question-html-ref" data-src="question-html/2026/q26-analysis.html" data-fallback="正确答案： A 【解析】 资源 S 是一个计数信号量，初始值为 5，表示最多允许 5 个进程同时访问资源。 当信号量值 S 为负数时，其绝对值表示阻塞的进程数。当前 S = -2，因此阻塞进程数 n = 2。 同时，当 S &lt; 0 时，所有初始资源均被占用，即有 5 个进程正在访问资源（处于临界区）。 m 表示执行到访"></div>',
   2, NULL, '2026年408模拟题', 2026, 26, 'html,external_html', '',
   '系统中有 8 个进程，执行下图的操作，资源 S 的初始值为 5。若此时 S 的值为 -2，其中 m 表示执行到访问资源的进程个数，n 表示阻塞的进程个数，则 m 和 n 的值分别是（ ） 计算机考研杂货铺 操作 wait(S) 访问资源 signal(S)', '正确答案： A 【解析】 资源 S 是一个计数信号量，初始值为 5，表示最多允许 5 个进程同时访问资源。 当信号量值 S 为负数时，其绝对值表示阻塞的进程数。当前 S = -2，因此阻塞进程数 n = 2。 同时，当 S < 0 时，所有初始资源均被占用，即有 5 个进程正在访问资源（处于临界区）。 m 表示执行到访问资源的进程个数，在此情境下理解为正在访问资源的进程数，故 m = 5。 因此，m 和 n 的值分别为 5 和 2。', 'html', b'0', b'0');
SET @q26 = LAST_INSERT_ID();
INSERT INTO question_content
  (question_id, version, title, options, correct_answer, analysis, title_text, analysis_text, content_format, has_image, has_code, legacy_text_content_id, source_hash, is_current)
VALUES
  (@q26, 1, '<div class="question-html-ref" data-src="question-html/2026/q26-title.html" data-fallback="系统中有 8 个进程，执行下图的操作，资源 S 的初始值为 5。若此时 S 的值为 -2，其中 m 表示执行到访问资源的进程个数，n 表示阻塞的进程个数，则 m 和 n 的值分别是（ ） 计算机考研杂货铺 操作 wait(S) 访问资源 signal(S)"></div>', '[{"prefix": "A", "content": "5, 2", "itemUuid": "28869dd5"}, {"prefix": "B", "content": "5, 1", "itemUuid": "6520a3e9"}, {"prefix": "C", "content": "6, 2", "itemUuid": "e1911e04"}, {"prefix": "D", "content": "7, 1", "itemUuid": "c9244356"}]', 'A', '<div class="question-html-ref" data-src="question-html/2026/q26-analysis.html" data-fallback="正确答案： A 【解析】 资源 S 是一个计数信号量，初始值为 5，表示最多允许 5 个进程同时访问资源。 当信号量值 S 为负数时，其绝对值表示阻塞的进程数。当前 S = -2，因此阻塞进程数 n = 2。 同时，当 S &lt; 0 时，所有初始资源均被占用，即有 5 个进程正在访问资源（处于临界区）。 m 表示执行到访"></div>',
   '系统中有 8 个进程，执行下图的操作，资源 S 的初始值为 5。若此时 S 的值为 -2，其中 m 表示执行到访问资源的进程个数，n 表示阻塞的进程个数，则 m 和 n 的值分别是（ ） 计算机考研杂货铺 操作 wait(S) 访问资源 signal(S)', '正确答案： A 【解析】 资源 S 是一个计数信号量，初始值为 5，表示最多允许 5 个进程同时访问资源。 当信号量值 S 为负数时，其绝对值表示阻塞的进程数。当前 S = -2，因此阻塞进程数 n = 2。 同时，当 S < 0 时，所有初始资源均被占用，即有 5 个进程正在访问资源（处于临界区）。 m 表示执行到访问资源的进程个数，在此情境下理解为正在访问资源的进程数，故 m = 5。 因此，m 和 n 的值分别为 5 和 2。', 'html', b'0', b'0', @tc26, '55dd03356117f71d1b6c231d28b1e9b9deef276e6aea1a45fbe9a76b968aae57', b'1');
INSERT INTO question_source
  (question_id, source_type, source_name, source_year, source_question_no, paper_name, raw_ref, metadata)
VALUES
  (@q26, 'crawler_html', '计算机考研杂货铺', 2026, '26', '2026年408计算机学科专业基础综合模拟试题',
   'C:/Users/wutia/Downloads/csgraduates2026.html', '{"subject": "操作系统", "html": true}');

-- Q27
INSERT INTO t_text_content (content, create_time)
VALUES ('{"titleContent": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q27-title.html\\" data-fallback=\\"假设进程 P 的读、写进程集合分别是 R ( P ) 和 W ( P ) ，进程 Q 的读、写进程集合分别为 R ( Q ) 和 W ( Q ) ，则进程 P 和 Q 并发执行中，不会发生错误的并发执行充要条件是（ ） I. R ( Q ) ∩ W ( P ) = ∅ II. R ( P ) ∩ R ( Q ) = ∅\\"></div>", "analyze": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q27-analysis.html\\" data-fallback=\\"正确答案： C 【解析】 在进程并发执行中，不发生错误（即避免数据竞争和冲突）的充要条件基于 Bernstein 条件。Bernstein 条件指出，两个进程 P 和 Q 可安全并发执行当且仅当满足以下三个条件： W ( P ) ∩ R ( Q ) = ∅ （避免写后读冲突）； R ( P ) ∩ W ( Q ) = \\"></div>", "questionItemObjects": [{"prefix": "A", "content": "I、II", "itemUuid": "0b5a7ad8"}, {"prefix": "B", "content": "I、II、III", "itemUuid": "1ad83443"}, {"prefix": "C", "content": "I、III、IV", "itemUuid": "f375a821"}, {"prefix": "D", "content": "II、III", "itemUuid": "82a55127"}]}', NOW());
SET @tc27 = LAST_INSERT_ID();
INSERT INTO t_question
  (question_type, subject_id, score, grade_level, difficult, correct, info_text_content_id, create_user, status, deleted,
   title, options, correct_answer, analysis, difficulty, knowledge_point, source, source_year, source_question_no, tags, images,
   title_text, analysis_text, content_format, has_image, has_code)
VALUES
  (1, 3, 20, NULL, 2, 'C', @tc27, 1, 1, b'0',
   '<div class="question-html-ref" data-src="question-html/2026/q27-title.html" data-fallback="假设进程 P 的读、写进程集合分别是 R ( P ) 和 W ( P ) ，进程 Q 的读、写进程集合分别为 R ( Q ) 和 W ( Q ) ，则进程 P 和 Q 并发执行中，不会发生错误的并发执行充要条件是（ ） I. R ( Q ) ∩ W ( P ) = ∅ II. R ( P ) ∩ R ( Q ) = ∅"></div>', '[{"prefix": "A", "content": "I、II", "itemUuid": "0b5a7ad8"}, {"prefix": "B", "content": "I、II、III", "itemUuid": "1ad83443"}, {"prefix": "C", "content": "I、III、IV", "itemUuid": "f375a821"}, {"prefix": "D", "content": "II、III", "itemUuid": "82a55127"}]', 'C', '<div class="question-html-ref" data-src="question-html/2026/q27-analysis.html" data-fallback="正确答案： C 【解析】 在进程并发执行中，不发生错误（即避免数据竞争和冲突）的充要条件基于 Bernstein 条件。Bernstein 条件指出，两个进程 P 和 Q 可安全并发执行当且仅当满足以下三个条件： W ( P ) ∩ R ( Q ) = ∅ （避免写后读冲突）； R ( P ) ∩ W ( Q ) = "></div>',
   2, NULL, '2026年408模拟题', 2026, 27, 'html,external_html,katex', '',
   '假设进程 P 的读、写进程集合分别是 R ( P ) 和 W ( P ) ，进程 Q 的读、写进程集合分别为 R ( Q ) 和 W ( Q ) ，则进程 P 和 Q 并发执行中，不会发生错误的并发执行充要条件是（ ） I. R ( Q ) ∩ W ( P ) = ∅ II. R ( P ) ∩ R ( Q ) = ∅ III. W ( P ) ∩ W ( Q ) = ∅ IV. R ( P ) ∩ W ( Q ) = ∅', '正确答案： C 【解析】 在进程并发执行中，不发生错误（即避免数据竞争和冲突）的充要条件基于 Bernstein 条件。Bernstein 条件指出，两个进程 P 和 Q 可安全并发执行当且仅当满足以下三个条件： W ( P ) ∩ R ( Q ) = ∅ （避免写后读冲突）； R ( P ) ∩ W ( Q ) = ∅ （避免读后写冲突）； W ( P ) ∩ W ( Q ) = ∅ （避免写后写冲突）。 读 - 读冲突（即 R ( P ) ∩ R ( Q ) ）不会导致数据不一致，因此不是必要条件。 对比题目中的条件： I 对应 W ( P ) ∩ R ( Q ) = ∅ ， III 对应 W ( P ) ∩ W ( Q ) = ∅ ， IV 对应 R ( P ) ∩ W ( Q ) = ∅ ， 而 II 是 R ( P ) ∩ R ( Q ) = ∅ ，无需满足。 因此，充要条件是 I、III 和 IV，对应选项 C。', 'html', b'0', b'0');
SET @q27 = LAST_INSERT_ID();
INSERT INTO question_content
  (question_id, version, title, options, correct_answer, analysis, title_text, analysis_text, content_format, has_image, has_code, legacy_text_content_id, source_hash, is_current)
VALUES
  (@q27, 1, '<div class="question-html-ref" data-src="question-html/2026/q27-title.html" data-fallback="假设进程 P 的读、写进程集合分别是 R ( P ) 和 W ( P ) ，进程 Q 的读、写进程集合分别为 R ( Q ) 和 W ( Q ) ，则进程 P 和 Q 并发执行中，不会发生错误的并发执行充要条件是（ ） I. R ( Q ) ∩ W ( P ) = ∅ II. R ( P ) ∩ R ( Q ) = ∅"></div>', '[{"prefix": "A", "content": "I、II", "itemUuid": "0b5a7ad8"}, {"prefix": "B", "content": "I、II、III", "itemUuid": "1ad83443"}, {"prefix": "C", "content": "I、III、IV", "itemUuid": "f375a821"}, {"prefix": "D", "content": "II、III", "itemUuid": "82a55127"}]', 'C', '<div class="question-html-ref" data-src="question-html/2026/q27-analysis.html" data-fallback="正确答案： C 【解析】 在进程并发执行中，不发生错误（即避免数据竞争和冲突）的充要条件基于 Bernstein 条件。Bernstein 条件指出，两个进程 P 和 Q 可安全并发执行当且仅当满足以下三个条件： W ( P ) ∩ R ( Q ) = ∅ （避免写后读冲突）； R ( P ) ∩ W ( Q ) = "></div>',
   '假设进程 P 的读、写进程集合分别是 R ( P ) 和 W ( P ) ，进程 Q 的读、写进程集合分别为 R ( Q ) 和 W ( Q ) ，则进程 P 和 Q 并发执行中，不会发生错误的并发执行充要条件是（ ） I. R ( Q ) ∩ W ( P ) = ∅ II. R ( P ) ∩ R ( Q ) = ∅ III. W ( P ) ∩ W ( Q ) = ∅ IV. R ( P ) ∩ W ( Q ) = ∅', '正确答案： C 【解析】 在进程并发执行中，不发生错误（即避免数据竞争和冲突）的充要条件基于 Bernstein 条件。Bernstein 条件指出，两个进程 P 和 Q 可安全并发执行当且仅当满足以下三个条件： W ( P ) ∩ R ( Q ) = ∅ （避免写后读冲突）； R ( P ) ∩ W ( Q ) = ∅ （避免读后写冲突）； W ( P ) ∩ W ( Q ) = ∅ （避免写后写冲突）。 读 - 读冲突（即 R ( P ) ∩ R ( Q ) ）不会导致数据不一致，因此不是必要条件。 对比题目中的条件： I 对应 W ( P ) ∩ R ( Q ) = ∅ ， III 对应 W ( P ) ∩ W ( Q ) = ∅ ， IV 对应 R ( P ) ∩ W ( Q ) = ∅ ， 而 II 是 R ( P ) ∩ R ( Q ) = ∅ ，无需满足。 因此，充要条件是 I、III 和 IV，对应选项 C。', 'html', b'0', b'0', @tc27, '34f0ffdd7a976df7f52a9e147b0193cd82e9c49a0ca722edcee6dd7d4aa20b60', b'1');
INSERT INTO question_source
  (question_id, source_type, source_name, source_year, source_question_no, paper_name, raw_ref, metadata)
VALUES
  (@q27, 'crawler_html', '计算机考研杂货铺', 2026, '27', '2026年408计算机学科专业基础综合模拟试题',
   'C:/Users/wutia/Downloads/csgraduates2026.html', '{"subject": "操作系统", "html": true}');

-- Q28
INSERT INTO t_text_content (content, create_time)
VALUES ('{"titleContent": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q28-title.html\\" data-fallback=\\"若 64 位的系统采用三级虚拟分页存储管理方式，其结构如下图所示，第三级页表所占用的页框数是（ ） | 补充位（25） | 一级页表（9） | 二级页表（9） | 三级页表（9） | 页内偏移（12） |\\"></div>", "analyze": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q28-analysis.html\\" data-fallback=\\"正确答案： C 在三级虚拟分页存储管理方式中，虚拟地址结构包括一级页表索引（9 位）、二级页表索引（9 位）、三级页表索引（9 位）和页内偏移（12 位）。 页内偏移 12 位对应页面大小为 4 KB（ 2 12 字节）。 每个页表索引为 9 位，因此每个页表有 2 9 = 512 个页表项。 假设每个页表项大小为 8\\"></div>", "questionItemObjects": [{"prefix": "A", "content": "1", "itemUuid": "ed732653"}, {"prefix": "B", "content": "256", "itemUuid": "1fabc19c"}, {"prefix": "C", "content": "256K", "itemUuid": "e01bc849"}, {"prefix": "D", "content": "256M", "itemUuid": "e9a909b0"}]}', NOW());
SET @tc28 = LAST_INSERT_ID();
INSERT INTO t_question
  (question_type, subject_id, score, grade_level, difficult, correct, info_text_content_id, create_user, status, deleted,
   title, options, correct_answer, analysis, difficulty, knowledge_point, source, source_year, source_question_no, tags, images,
   title_text, analysis_text, content_format, has_image, has_code)
VALUES
  (1, 3, 20, NULL, 2, 'C', @tc28, 1, 1, b'0',
   '<div class="question-html-ref" data-src="question-html/2026/q28-title.html" data-fallback="若 64 位的系统采用三级虚拟分页存储管理方式，其结构如下图所示，第三级页表所占用的页框数是（ ） | 补充位（25） | 一级页表（9） | 二级页表（9） | 三级页表（9） | 页内偏移（12） |"></div>', '[{"prefix": "A", "content": "1", "itemUuid": "ed732653"}, {"prefix": "B", "content": "256", "itemUuid": "1fabc19c"}, {"prefix": "C", "content": "256K", "itemUuid": "e01bc849"}, {"prefix": "D", "content": "256M", "itemUuid": "e9a909b0"}]', 'C', '<div class="question-html-ref" data-src="question-html/2026/q28-analysis.html" data-fallback="正确答案： C 在三级虚拟分页存储管理方式中，虚拟地址结构包括一级页表索引（9 位）、二级页表索引（9 位）、三级页表索引（9 位）和页内偏移（12 位）。 页内偏移 12 位对应页面大小为 4 KB（ 2 12 字节）。 每个页表索引为 9 位，因此每个页表有 2 9 = 512 个页表项。 假设每个页表项大小为 8"></div>',
   2, NULL, '2026年408模拟题', 2026, 28, 'html,external_html,code,katex', '',
   '若 64 位的系统采用三级虚拟分页存储管理方式，其结构如下图所示，第三级页表所占用的页框数是（ ） | 补充位（25） | 一级页表（9） | 二级页表（9） | 三级页表（9） | 页内偏移（12） |', '正确答案： C 在三级虚拟分页存储管理方式中，虚拟地址结构包括一级页表索引（9 位）、二级页表索引（9 位）、三级页表索引（9 位）和页内偏移（12 位）。 页内偏移 12 位对应页面大小为 4 KB（ 2 12 字节）。 每个页表索引为 9 位，因此每个页表有 2 9 = 512 个页表项。 假设每个页表项大小为 8 字节（典型 64 位系统），则每个页表大小为 512 × 8 = 4096 字节，恰好占用一个页框。 三级页表的数量由一级和二级页表决定： 一级页表有 512 个条目，每个条目指向一个二级页表，因此最多有 512 个二级页表； 每个二级页表有 512 个条目，每个条目指向一个三级页表，因此三级页表的最大数量为 512 × 512 = 262144 个。 每个三级页表占用一个页框，所以三级页表总共占用的页框数为 262144，即 256 K（因为 256 × 1024 = 262144 ）。 因此，正确答案为 C。', 'html', b'0', b'1');
SET @q28 = LAST_INSERT_ID();
INSERT INTO question_content
  (question_id, version, title, options, correct_answer, analysis, title_text, analysis_text, content_format, has_image, has_code, legacy_text_content_id, source_hash, is_current)
VALUES
  (@q28, 1, '<div class="question-html-ref" data-src="question-html/2026/q28-title.html" data-fallback="若 64 位的系统采用三级虚拟分页存储管理方式，其结构如下图所示，第三级页表所占用的页框数是（ ） | 补充位（25） | 一级页表（9） | 二级页表（9） | 三级页表（9） | 页内偏移（12） |"></div>', '[{"prefix": "A", "content": "1", "itemUuid": "ed732653"}, {"prefix": "B", "content": "256", "itemUuid": "1fabc19c"}, {"prefix": "C", "content": "256K", "itemUuid": "e01bc849"}, {"prefix": "D", "content": "256M", "itemUuid": "e9a909b0"}]', 'C', '<div class="question-html-ref" data-src="question-html/2026/q28-analysis.html" data-fallback="正确答案： C 在三级虚拟分页存储管理方式中，虚拟地址结构包括一级页表索引（9 位）、二级页表索引（9 位）、三级页表索引（9 位）和页内偏移（12 位）。 页内偏移 12 位对应页面大小为 4 KB（ 2 12 字节）。 每个页表索引为 9 位，因此每个页表有 2 9 = 512 个页表项。 假设每个页表项大小为 8"></div>',
   '若 64 位的系统采用三级虚拟分页存储管理方式，其结构如下图所示，第三级页表所占用的页框数是（ ） | 补充位（25） | 一级页表（9） | 二级页表（9） | 三级页表（9） | 页内偏移（12） |', '正确答案： C 在三级虚拟分页存储管理方式中，虚拟地址结构包括一级页表索引（9 位）、二级页表索引（9 位）、三级页表索引（9 位）和页内偏移（12 位）。 页内偏移 12 位对应页面大小为 4 KB（ 2 12 字节）。 每个页表索引为 9 位，因此每个页表有 2 9 = 512 个页表项。 假设每个页表项大小为 8 字节（典型 64 位系统），则每个页表大小为 512 × 8 = 4096 字节，恰好占用一个页框。 三级页表的数量由一级和二级页表决定： 一级页表有 512 个条目，每个条目指向一个二级页表，因此最多有 512 个二级页表； 每个二级页表有 512 个条目，每个条目指向一个三级页表，因此三级页表的最大数量为 512 × 512 = 262144 个。 每个三级页表占用一个页框，所以三级页表总共占用的页框数为 262144，即 256 K（因为 256 × 1024 = 262144 ）。 因此，正确答案为 C。', 'html', b'0', b'1', @tc28, 'ad4d354f85ed0b413cdd66d6ba99b0b2714892561aa51ee22204c876aa4100c6', b'1');
INSERT INTO question_source
  (question_id, source_type, source_name, source_year, source_question_no, paper_name, raw_ref, metadata)
VALUES
  (@q28, 'crawler_html', '计算机考研杂货铺', 2026, '28', '2026年408计算机学科专业基础综合模拟试题',
   'C:/Users/wutia/Downloads/csgraduates2026.html', '{"subject": "操作系统", "html": true}');

-- Q29
INSERT INTO t_text_content (content, create_time)
VALUES ('{"titleContent": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q29-title.html\\" data-fallback=\\"下列方法中能够有效降低系统平均访存时间的是（） I. TLB II. 多级页表 III. 工作集概念 IV. 页表缓冲队列\\"></div>", "analyze": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q29-analysis.html\\" data-fallback=\\"正确答案： C 【解析】 TLB（快表）能够缓存虚拟地址到物理地址的转换结果，在 TLB 命中时直接获取物理地址，避免访问内存中的页表，从而有效降低访存延迟。工作集概念用于指导页面置换算法，通过维持进程最近访问的页面集合在内存中，减少缺页中断的发生，降低缺页率，进而减少平均访存时间。页表缓冲队列可以缓存页表项，减少访问\\"></div>", "questionItemObjects": [{"prefix": "A", "content": "I、III", "itemUuid": "c47ebbe7"}, {"prefix": "B", "content": "II、III", "itemUuid": "1a6acff4"}, {"prefix": "C", "content": "I、III、IV", "itemUuid": "2c6bf040"}, {"prefix": "D", "content": "I、II、IV", "itemUuid": "7212447f"}]}', NOW());
SET @tc29 = LAST_INSERT_ID();
INSERT INTO t_question
  (question_type, subject_id, score, grade_level, difficult, correct, info_text_content_id, create_user, status, deleted,
   title, options, correct_answer, analysis, difficulty, knowledge_point, source, source_year, source_question_no, tags, images,
   title_text, analysis_text, content_format, has_image, has_code)
VALUES
  (1, 3, 20, NULL, 2, 'C', @tc29, 1, 1, b'0',
   '<div class="question-html-ref" data-src="question-html/2026/q29-title.html" data-fallback="下列方法中能够有效降低系统平均访存时间的是（） I. TLB II. 多级页表 III. 工作集概念 IV. 页表缓冲队列"></div>', '[{"prefix": "A", "content": "I、III", "itemUuid": "c47ebbe7"}, {"prefix": "B", "content": "II、III", "itemUuid": "1a6acff4"}, {"prefix": "C", "content": "I、III、IV", "itemUuid": "2c6bf040"}, {"prefix": "D", "content": "I、II、IV", "itemUuid": "7212447f"}]', 'C', '<div class="question-html-ref" data-src="question-html/2026/q29-analysis.html" data-fallback="正确答案： C 【解析】 TLB（快表）能够缓存虚拟地址到物理地址的转换结果，在 TLB 命中时直接获取物理地址，避免访问内存中的页表，从而有效降低访存延迟。工作集概念用于指导页面置换算法，通过维持进程最近访问的页面集合在内存中，减少缺页中断的发生，降低缺页率，进而减少平均访存时间。页表缓冲队列可以缓存页表项，减少访问"></div>',
   2, NULL, '2026年408模拟题', 2026, 29, 'html,external_html', '',
   '下列方法中能够有效降低系统平均访存时间的是（） I. TLB II. 多级页表 III. 工作集概念 IV. 页表缓冲队列', '正确答案： C 【解析】 TLB（快表）能够缓存虚拟地址到物理地址的转换结果，在 TLB 命中时直接获取物理地址，避免访问内存中的页表，从而有效降低访存延迟。工作集概念用于指导页面置换算法，通过维持进程最近访问的页面集合在内存中，减少缺页中断的发生，降低缺页率，进而减少平均访存时间。页表缓冲队列可以缓存页表项，减少访问主存页表的次数，加速地址转换过程，也有助于降低平均访存时间。多级页表的主要目的是节省页表占用的内存空间，但可能增加地址转换的步数，导致访存延迟增加，因此不能有效降低平均访存时间。故正确选项为 I、III、IV，即 C。', 'html', b'0', b'0');
SET @q29 = LAST_INSERT_ID();
INSERT INTO question_content
  (question_id, version, title, options, correct_answer, analysis, title_text, analysis_text, content_format, has_image, has_code, legacy_text_content_id, source_hash, is_current)
VALUES
  (@q29, 1, '<div class="question-html-ref" data-src="question-html/2026/q29-title.html" data-fallback="下列方法中能够有效降低系统平均访存时间的是（） I. TLB II. 多级页表 III. 工作集概念 IV. 页表缓冲队列"></div>', '[{"prefix": "A", "content": "I、III", "itemUuid": "c47ebbe7"}, {"prefix": "B", "content": "II、III", "itemUuid": "1a6acff4"}, {"prefix": "C", "content": "I、III、IV", "itemUuid": "2c6bf040"}, {"prefix": "D", "content": "I、II、IV", "itemUuid": "7212447f"}]', 'C', '<div class="question-html-ref" data-src="question-html/2026/q29-analysis.html" data-fallback="正确答案： C 【解析】 TLB（快表）能够缓存虚拟地址到物理地址的转换结果，在 TLB 命中时直接获取物理地址，避免访问内存中的页表，从而有效降低访存延迟。工作集概念用于指导页面置换算法，通过维持进程最近访问的页面集合在内存中，减少缺页中断的发生，降低缺页率，进而减少平均访存时间。页表缓冲队列可以缓存页表项，减少访问"></div>',
   '下列方法中能够有效降低系统平均访存时间的是（） I. TLB II. 多级页表 III. 工作集概念 IV. 页表缓冲队列', '正确答案： C 【解析】 TLB（快表）能够缓存虚拟地址到物理地址的转换结果，在 TLB 命中时直接获取物理地址，避免访问内存中的页表，从而有效降低访存延迟。工作集概念用于指导页面置换算法，通过维持进程最近访问的页面集合在内存中，减少缺页中断的发生，降低缺页率，进而减少平均访存时间。页表缓冲队列可以缓存页表项，减少访问主存页表的次数，加速地址转换过程，也有助于降低平均访存时间。多级页表的主要目的是节省页表占用的内存空间，但可能增加地址转换的步数，导致访存延迟增加，因此不能有效降低平均访存时间。故正确选项为 I、III、IV，即 C。', 'html', b'0', b'0', @tc29, '9c6714a5907d1afb2cb23d936a87e86c19b67c3a103d3ad6d224d70400befae7', b'1');
INSERT INTO question_source
  (question_id, source_type, source_name, source_year, source_question_no, paper_name, raw_ref, metadata)
VALUES
  (@q29, 'crawler_html', '计算机考研杂货铺', 2026, '29', '2026年408计算机学科专业基础综合模拟试题',
   'C:/Users/wutia/Downloads/csgraduates2026.html', '{"subject": "操作系统", "html": true}');

-- Q30
INSERT INTO t_text_content (content, create_time)
VALUES ('{"titleContent": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q30-title.html\\" data-fallback=\\"进程 P1 和 P2 共享一个文件 R，该文件的页表项分别是 R1 和 R2，其在 2 个进程中的虚拟地址分别是 W1 和 W2，则下列说法中正确的是（ ）\\"></div>", "analyze": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q30-analysis.html\\" data-fallback=\\"正确答案： B 【解析】 进程 P1 和 P2 共享文件 R，这意味着它们通过各自的页表项 R1 和 R2 将虚拟地址 W1 和 W2 映射到相同的物理内存区域，因此 W1 和 W2 映射的物理地址相同。 选项 A 错误，因为页表项 R1 和 R2 至少物理地址部分相同，内容并非完全不同； 选项 C 错误，由于共享物理\\"></div>", "questionItemObjects": [{"prefix": "A", "content": "页表项 R1 和 R2 的内容完全不同", "itemUuid": "cafed16e"}, {"prefix": "B", "content": "W1 和 W2 映射的物理地址相同", "itemUuid": "f559462a"}, {"prefix": "C", "content": "进程 P1 对 W1 的修改不会影响 P2 对 W2 的访问", "itemUuid": "709090e6"}, {"prefix": "D", "content": "W1 和 W2 虚拟地址相同", "itemUuid": "ee9756ec"}]}', NOW());
SET @tc30 = LAST_INSERT_ID();
INSERT INTO t_question
  (question_type, subject_id, score, grade_level, difficult, correct, info_text_content_id, create_user, status, deleted,
   title, options, correct_answer, analysis, difficulty, knowledge_point, source, source_year, source_question_no, tags, images,
   title_text, analysis_text, content_format, has_image, has_code)
VALUES
  (1, 3, 20, NULL, 2, 'B', @tc30, 1, 1, b'0',
   '<div class="question-html-ref" data-src="question-html/2026/q30-title.html" data-fallback="进程 P1 和 P2 共享一个文件 R，该文件的页表项分别是 R1 和 R2，其在 2 个进程中的虚拟地址分别是 W1 和 W2，则下列说法中正确的是（ ）"></div>', '[{"prefix": "A", "content": "页表项 R1 和 R2 的内容完全不同", "itemUuid": "cafed16e"}, {"prefix": "B", "content": "W1 和 W2 映射的物理地址相同", "itemUuid": "f559462a"}, {"prefix": "C", "content": "进程 P1 对 W1 的修改不会影响 P2 对 W2 的访问", "itemUuid": "709090e6"}, {"prefix": "D", "content": "W1 和 W2 虚拟地址相同", "itemUuid": "ee9756ec"}]', 'B', '<div class="question-html-ref" data-src="question-html/2026/q30-analysis.html" data-fallback="正确答案： B 【解析】 进程 P1 和 P2 共享文件 R，这意味着它们通过各自的页表项 R1 和 R2 将虚拟地址 W1 和 W2 映射到相同的物理内存区域，因此 W1 和 W2 映射的物理地址相同。 选项 A 错误，因为页表项 R1 和 R2 至少物理地址部分相同，内容并非完全不同； 选项 C 错误，由于共享物理"></div>',
   2, NULL, '2026年408模拟题', 2026, 30, 'html,external_html', '',
   '进程 P1 和 P2 共享一个文件 R，该文件的页表项分别是 R1 和 R2，其在 2 个进程中的虚拟地址分别是 W1 和 W2，则下列说法中正确的是（ ）', '正确答案： B 【解析】 进程 P1 和 P2 共享文件 R，这意味着它们通过各自的页表项 R1 和 R2 将虚拟地址 W1 和 W2 映射到相同的物理内存区域，因此 W1 和 W2 映射的物理地址相同。 选项 A 错误，因为页表项 R1 和 R2 至少物理地址部分相同，内容并非完全不同； 选项 C 错误，由于共享物理内存，P1 对 W1 的修改会影响 P2 对 W2 的访问； 选项 D 错误，虚拟地址是进程独立的，W1 和 W2 不一定相同。', 'html', b'0', b'0');
SET @q30 = LAST_INSERT_ID();
INSERT INTO question_content
  (question_id, version, title, options, correct_answer, analysis, title_text, analysis_text, content_format, has_image, has_code, legacy_text_content_id, source_hash, is_current)
VALUES
  (@q30, 1, '<div class="question-html-ref" data-src="question-html/2026/q30-title.html" data-fallback="进程 P1 和 P2 共享一个文件 R，该文件的页表项分别是 R1 和 R2，其在 2 个进程中的虚拟地址分别是 W1 和 W2，则下列说法中正确的是（ ）"></div>', '[{"prefix": "A", "content": "页表项 R1 和 R2 的内容完全不同", "itemUuid": "cafed16e"}, {"prefix": "B", "content": "W1 和 W2 映射的物理地址相同", "itemUuid": "f559462a"}, {"prefix": "C", "content": "进程 P1 对 W1 的修改不会影响 P2 对 W2 的访问", "itemUuid": "709090e6"}, {"prefix": "D", "content": "W1 和 W2 虚拟地址相同", "itemUuid": "ee9756ec"}]', 'B', '<div class="question-html-ref" data-src="question-html/2026/q30-analysis.html" data-fallback="正确答案： B 【解析】 进程 P1 和 P2 共享文件 R，这意味着它们通过各自的页表项 R1 和 R2 将虚拟地址 W1 和 W2 映射到相同的物理内存区域，因此 W1 和 W2 映射的物理地址相同。 选项 A 错误，因为页表项 R1 和 R2 至少物理地址部分相同，内容并非完全不同； 选项 C 错误，由于共享物理"></div>',
   '进程 P1 和 P2 共享一个文件 R，该文件的页表项分别是 R1 和 R2，其在 2 个进程中的虚拟地址分别是 W1 和 W2，则下列说法中正确的是（ ）', '正确答案： B 【解析】 进程 P1 和 P2 共享文件 R，这意味着它们通过各自的页表项 R1 和 R2 将虚拟地址 W1 和 W2 映射到相同的物理内存区域，因此 W1 和 W2 映射的物理地址相同。 选项 A 错误，因为页表项 R1 和 R2 至少物理地址部分相同，内容并非完全不同； 选项 C 错误，由于共享物理内存，P1 对 W1 的修改会影响 P2 对 W2 的访问； 选项 D 错误，虚拟地址是进程独立的，W1 和 W2 不一定相同。', 'html', b'0', b'0', @tc30, '5ed9e68b9c74af2f4228d63e5405abfd7ec27326d3f66a1490b997202637260c', b'1');
INSERT INTO question_source
  (question_id, source_type, source_name, source_year, source_question_no, paper_name, raw_ref, metadata)
VALUES
  (@q30, 'crawler_html', '计算机考研杂货铺', 2026, '30', '2026年408计算机学科专业基础综合模拟试题',
   'C:/Users/wutia/Downloads/csgraduates2026.html', '{"subject": "操作系统", "html": true}');

-- Q31
INSERT INTO t_text_content (content, create_time)
VALUES ('{"titleContent": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q31-title.html\\" data-fallback=\\"下列关于驱动程序的描述中，错误的是（）\\"></div>", "analyze": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q31-analysis.html\\" data-fallback=\\"正确答案： D 【解析】 驱动程序是硬件与操作系统之间的接口程序，使操作系统能够控制和管理硬件，因此 A 正确； 由于不同硬件具有不同的特性和操作方式，驱动程序需要针对具体硬件进行定制开发，因此 B 正确； 为了便于操作系统统一管理和调用，驱动程序需要遵循操作系统提供的统一接口规范，因此 C 正确； 字符设备和块设备是\\"></div>", "questionItemObjects": [{"prefix": "A", "content": "驱动程序是硬件与操作系统之间的接口程序", "itemUuid": "6a968b98"}, {"prefix": "B", "content": "驱动程序需根据硬件特性定制开发", "itemUuid": "49e9889b"}, {"prefix": "C", "content": "驱动程序需要设置统一的接口", "itemUuid": "d5c4d2bc"}, {"prefix": "D", "content": "字符设备、块设备都是同一种 IO 方式", "itemUuid": "1fe7604a"}]}', NOW());
SET @tc31 = LAST_INSERT_ID();
INSERT INTO t_question
  (question_type, subject_id, score, grade_level, difficult, correct, info_text_content_id, create_user, status, deleted,
   title, options, correct_answer, analysis, difficulty, knowledge_point, source, source_year, source_question_no, tags, images,
   title_text, analysis_text, content_format, has_image, has_code)
VALUES
  (1, 3, 20, NULL, 2, 'D', @tc31, 1, 1, b'0',
   '<div class="question-html-ref" data-src="question-html/2026/q31-title.html" data-fallback="下列关于驱动程序的描述中，错误的是（）"></div>', '[{"prefix": "A", "content": "驱动程序是硬件与操作系统之间的接口程序", "itemUuid": "6a968b98"}, {"prefix": "B", "content": "驱动程序需根据硬件特性定制开发", "itemUuid": "49e9889b"}, {"prefix": "C", "content": "驱动程序需要设置统一的接口", "itemUuid": "d5c4d2bc"}, {"prefix": "D", "content": "字符设备、块设备都是同一种 IO 方式", "itemUuid": "1fe7604a"}]', 'D', '<div class="question-html-ref" data-src="question-html/2026/q31-analysis.html" data-fallback="正确答案： D 【解析】 驱动程序是硬件与操作系统之间的接口程序，使操作系统能够控制和管理硬件，因此 A 正确； 由于不同硬件具有不同的特性和操作方式，驱动程序需要针对具体硬件进行定制开发，因此 B 正确； 为了便于操作系统统一管理和调用，驱动程序需要遵循操作系统提供的统一接口规范，因此 C 正确； 字符设备和块设备是"></div>',
   2, NULL, '2026年408模拟题', 2026, 31, 'html,external_html', '',
   '下列关于驱动程序的描述中，错误的是（）', '正确答案： D 【解析】 驱动程序是硬件与操作系统之间的接口程序，使操作系统能够控制和管理硬件，因此 A 正确； 由于不同硬件具有不同的特性和操作方式，驱动程序需要针对具体硬件进行定制开发，因此 B 正确； 为了便于操作系统统一管理和调用，驱动程序需要遵循操作系统提供的统一接口规范，因此 C 正确； 字符设备和块设备是两种不同的 I/O 方式：字符设备以字符流为单位进行数据传输（例如键盘），而块设备以固定大小的数据块为单位（例如硬盘），因此 D 错误。', 'html', b'0', b'0');
SET @q31 = LAST_INSERT_ID();
INSERT INTO question_content
  (question_id, version, title, options, correct_answer, analysis, title_text, analysis_text, content_format, has_image, has_code, legacy_text_content_id, source_hash, is_current)
VALUES
  (@q31, 1, '<div class="question-html-ref" data-src="question-html/2026/q31-title.html" data-fallback="下列关于驱动程序的描述中，错误的是（）"></div>', '[{"prefix": "A", "content": "驱动程序是硬件与操作系统之间的接口程序", "itemUuid": "6a968b98"}, {"prefix": "B", "content": "驱动程序需根据硬件特性定制开发", "itemUuid": "49e9889b"}, {"prefix": "C", "content": "驱动程序需要设置统一的接口", "itemUuid": "d5c4d2bc"}, {"prefix": "D", "content": "字符设备、块设备都是同一种 IO 方式", "itemUuid": "1fe7604a"}]', 'D', '<div class="question-html-ref" data-src="question-html/2026/q31-analysis.html" data-fallback="正确答案： D 【解析】 驱动程序是硬件与操作系统之间的接口程序，使操作系统能够控制和管理硬件，因此 A 正确； 由于不同硬件具有不同的特性和操作方式，驱动程序需要针对具体硬件进行定制开发，因此 B 正确； 为了便于操作系统统一管理和调用，驱动程序需要遵循操作系统提供的统一接口规范，因此 C 正确； 字符设备和块设备是"></div>',
   '下列关于驱动程序的描述中，错误的是（）', '正确答案： D 【解析】 驱动程序是硬件与操作系统之间的接口程序，使操作系统能够控制和管理硬件，因此 A 正确； 由于不同硬件具有不同的特性和操作方式，驱动程序需要针对具体硬件进行定制开发，因此 B 正确； 为了便于操作系统统一管理和调用，驱动程序需要遵循操作系统提供的统一接口规范，因此 C 正确； 字符设备和块设备是两种不同的 I/O 方式：字符设备以字符流为单位进行数据传输（例如键盘），而块设备以固定大小的数据块为单位（例如硬盘），因此 D 错误。', 'html', b'0', b'0', @tc31, 'd2b0fa96847419652e3e844e9d8e6035eec4ea8b3e425a91b4fa9ddebeddcd5c', b'1');
INSERT INTO question_source
  (question_id, source_type, source_name, source_year, source_question_no, paper_name, raw_ref, metadata)
VALUES
  (@q31, 'crawler_html', '计算机考研杂货铺', 2026, '31', '2026年408计算机学科专业基础综合模拟试题',
   'C:/Users/wutia/Downloads/csgraduates2026.html', '{"subject": "操作系统", "html": true}');

-- Q32
INSERT INTO t_text_content (content, create_time)
VALUES ('{"titleContent": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q32-title.html\\" data-fallback=\\"下列操作中，鼠标中断处理程序完成的是（）\\"></div>", "analyze": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q32-analysis.html\\" data-fallback=\\"正确答案： D 【解析】 鼠标中断处理程序的主要职责是在硬件中断触发时，快速从数据寄存器中读取鼠标的原始数据，并将其送入内核缓冲区，以便操作系统内核或输入子系统后续处理。选项 D 直接描述了这一核心操作；而选项 A 涉及高级解析，通常由驱动程序或应用程序完成；选项 B 涉及用户空间同步，一般由内核的其他部分负责；选项 \\"></div>", "questionItemObjects": [{"prefix": "A", "content": "解析鼠标的输入指令含义", "itemUuid": "7e3a213f"}, {"prefix": "B", "content": "将鼠标数据同步到用户应用程序缓冲区", "itemUuid": "f0257644"}, {"prefix": "C", "content": "将数据从输入设备传输到数据寄存器", "itemUuid": "41f8c0d2"}, {"prefix": "D", "content": "将数据从数据寄存器传输到内核缓冲区", "itemUuid": "58c3a1e9"}]}', NOW());
SET @tc32 = LAST_INSERT_ID();
INSERT INTO t_question
  (question_type, subject_id, score, grade_level, difficult, correct, info_text_content_id, create_user, status, deleted,
   title, options, correct_answer, analysis, difficulty, knowledge_point, source, source_year, source_question_no, tags, images,
   title_text, analysis_text, content_format, has_image, has_code)
VALUES
  (1, 3, 20, NULL, 2, 'D', @tc32, 1, 1, b'0',
   '<div class="question-html-ref" data-src="question-html/2026/q32-title.html" data-fallback="下列操作中，鼠标中断处理程序完成的是（）"></div>', '[{"prefix": "A", "content": "解析鼠标的输入指令含义", "itemUuid": "7e3a213f"}, {"prefix": "B", "content": "将鼠标数据同步到用户应用程序缓冲区", "itemUuid": "f0257644"}, {"prefix": "C", "content": "将数据从输入设备传输到数据寄存器", "itemUuid": "41f8c0d2"}, {"prefix": "D", "content": "将数据从数据寄存器传输到内核缓冲区", "itemUuid": "58c3a1e9"}]', 'D', '<div class="question-html-ref" data-src="question-html/2026/q32-analysis.html" data-fallback="正确答案： D 【解析】 鼠标中断处理程序的主要职责是在硬件中断触发时，快速从数据寄存器中读取鼠标的原始数据，并将其送入内核缓冲区，以便操作系统内核或输入子系统后续处理。选项 D 直接描述了这一核心操作；而选项 A 涉及高级解析，通常由驱动程序或应用程序完成；选项 B 涉及用户空间同步，一般由内核的其他部分负责；选项 "></div>',
   2, NULL, '2026年408模拟题', 2026, 32, 'html,external_html', '',
   '下列操作中，鼠标中断处理程序完成的是（）', '正确答案： D 【解析】 鼠标中断处理程序的主要职责是在硬件中断触发时，快速从数据寄存器中读取鼠标的原始数据，并将其送入内核缓冲区，以便操作系统内核或输入子系统后续处理。选项 D 直接描述了这一核心操作；而选项 A 涉及高级解析，通常由驱动程序或应用程序完成；选项 B 涉及用户空间同步，一般由内核的其他部分负责；选项 C 涉及硬件传输，可能由硬件或 DMA 完成，并非中断处理程序的主要职责。', 'html', b'0', b'0');
SET @q32 = LAST_INSERT_ID();
INSERT INTO question_content
  (question_id, version, title, options, correct_answer, analysis, title_text, analysis_text, content_format, has_image, has_code, legacy_text_content_id, source_hash, is_current)
VALUES
  (@q32, 1, '<div class="question-html-ref" data-src="question-html/2026/q32-title.html" data-fallback="下列操作中，鼠标中断处理程序完成的是（）"></div>', '[{"prefix": "A", "content": "解析鼠标的输入指令含义", "itemUuid": "7e3a213f"}, {"prefix": "B", "content": "将鼠标数据同步到用户应用程序缓冲区", "itemUuid": "f0257644"}, {"prefix": "C", "content": "将数据从输入设备传输到数据寄存器", "itemUuid": "41f8c0d2"}, {"prefix": "D", "content": "将数据从数据寄存器传输到内核缓冲区", "itemUuid": "58c3a1e9"}]', 'D', '<div class="question-html-ref" data-src="question-html/2026/q32-analysis.html" data-fallback="正确答案： D 【解析】 鼠标中断处理程序的主要职责是在硬件中断触发时，快速从数据寄存器中读取鼠标的原始数据，并将其送入内核缓冲区，以便操作系统内核或输入子系统后续处理。选项 D 直接描述了这一核心操作；而选项 A 涉及高级解析，通常由驱动程序或应用程序完成；选项 B 涉及用户空间同步，一般由内核的其他部分负责；选项 "></div>',
   '下列操作中，鼠标中断处理程序完成的是（）', '正确答案： D 【解析】 鼠标中断处理程序的主要职责是在硬件中断触发时，快速从数据寄存器中读取鼠标的原始数据，并将其送入内核缓冲区，以便操作系统内核或输入子系统后续处理。选项 D 直接描述了这一核心操作；而选项 A 涉及高级解析，通常由驱动程序或应用程序完成；选项 B 涉及用户空间同步，一般由内核的其他部分负责；选项 C 涉及硬件传输，可能由硬件或 DMA 完成，并非中断处理程序的主要职责。', 'html', b'0', b'0', @tc32, 'ffdd41ef1326b6cfd2392d7fc0cfe0c675a4f46785f582964d9c85accdb5f963', b'1');
INSERT INTO question_source
  (question_id, source_type, source_name, source_year, source_question_no, paper_name, raw_ref, metadata)
VALUES
  (@q32, 'crawler_html', '计算机考研杂货铺', 2026, '32', '2026年408计算机学科专业基础综合模拟试题',
   'C:/Users/wutia/Downloads/csgraduates2026.html', '{"subject": "操作系统", "html": true}');

-- Q33
INSERT INTO t_text_content (content, create_time)
VALUES ('{"titleContent": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q33-title.html\\" data-fallback=\\"下列关于分层网络体系结构的叙述中，错误的是（ ）\\"></div>", "analyze": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q33-analysis.html\\" data-fallback=\\"正确答案： B 【解析】 分层网络体系结构中，每层都有明确的功能边界（A 正确），这有助于模块化和功能划分；分层设计允许各层技术独立演化（C 正确），只要接口保持不变；上层通过接口使用下层服务，无需关心下层的具体实现细节（D 正确）。但层次越多并不一定效率越高（B 错误），因为过多的层次会增加封装、解封装等处理开销，可\\"></div>", "questionItemObjects": [{"prefix": "A", "content": "每层都有明确的功能边界", "itemUuid": "d2f62784"}, {"prefix": "B", "content": "层次越多效率越高", "itemUuid": "c03662bb"}, {"prefix": "C", "content": "有利于各层技术独立演化", "itemUuid": "b4f3be34"}, {"prefix": "D", "content": "上层无需关心下层的具体实现细节", "itemUuid": "149e7e01"}]}', NOW());
SET @tc33 = LAST_INSERT_ID();
INSERT INTO t_question
  (question_type, subject_id, score, grade_level, difficult, correct, info_text_content_id, create_user, status, deleted,
   title, options, correct_answer, analysis, difficulty, knowledge_point, source, source_year, source_question_no, tags, images,
   title_text, analysis_text, content_format, has_image, has_code)
VALUES
  (1, 4, 20, NULL, 2, 'B', @tc33, 1, 1, b'0',
   '<div class="question-html-ref" data-src="question-html/2026/q33-title.html" data-fallback="下列关于分层网络体系结构的叙述中，错误的是（ ）"></div>', '[{"prefix": "A", "content": "每层都有明确的功能边界", "itemUuid": "d2f62784"}, {"prefix": "B", "content": "层次越多效率越高", "itemUuid": "c03662bb"}, {"prefix": "C", "content": "有利于各层技术独立演化", "itemUuid": "b4f3be34"}, {"prefix": "D", "content": "上层无需关心下层的具体实现细节", "itemUuid": "149e7e01"}]', 'B', '<div class="question-html-ref" data-src="question-html/2026/q33-analysis.html" data-fallback="正确答案： B 【解析】 分层网络体系结构中，每层都有明确的功能边界（A 正确），这有助于模块化和功能划分；分层设计允许各层技术独立演化（C 正确），只要接口保持不变；上层通过接口使用下层服务，无需关心下层的具体实现细节（D 正确）。但层次越多并不一定效率越高（B 错误），因为过多的层次会增加封装、解封装等处理开销，可"></div>',
   2, NULL, '2026年408模拟题', 2026, 33, 'html,external_html', '',
   '下列关于分层网络体系结构的叙述中，错误的是（ ）', '正确答案： B 【解析】 分层网络体系结构中，每层都有明确的功能边界（A 正确），这有助于模块化和功能划分；分层设计允许各层技术独立演化（C 正确），只要接口保持不变；上层通过接口使用下层服务，无需关心下层的具体实现细节（D 正确）。但层次越多并不一定效率越高（B 错误），因为过多的层次会增加封装、解封装等处理开销，可能导致延迟增加和效率降低，因此分层设计需权衡层次数量与性能。', 'html', b'0', b'0');
SET @q33 = LAST_INSERT_ID();
INSERT INTO question_content
  (question_id, version, title, options, correct_answer, analysis, title_text, analysis_text, content_format, has_image, has_code, legacy_text_content_id, source_hash, is_current)
VALUES
  (@q33, 1, '<div class="question-html-ref" data-src="question-html/2026/q33-title.html" data-fallback="下列关于分层网络体系结构的叙述中，错误的是（ ）"></div>', '[{"prefix": "A", "content": "每层都有明确的功能边界", "itemUuid": "d2f62784"}, {"prefix": "B", "content": "层次越多效率越高", "itemUuid": "c03662bb"}, {"prefix": "C", "content": "有利于各层技术独立演化", "itemUuid": "b4f3be34"}, {"prefix": "D", "content": "上层无需关心下层的具体实现细节", "itemUuid": "149e7e01"}]', 'B', '<div class="question-html-ref" data-src="question-html/2026/q33-analysis.html" data-fallback="正确答案： B 【解析】 分层网络体系结构中，每层都有明确的功能边界（A 正确），这有助于模块化和功能划分；分层设计允许各层技术独立演化（C 正确），只要接口保持不变；上层通过接口使用下层服务，无需关心下层的具体实现细节（D 正确）。但层次越多并不一定效率越高（B 错误），因为过多的层次会增加封装、解封装等处理开销，可"></div>',
   '下列关于分层网络体系结构的叙述中，错误的是（ ）', '正确答案： B 【解析】 分层网络体系结构中，每层都有明确的功能边界（A 正确），这有助于模块化和功能划分；分层设计允许各层技术独立演化（C 正确），只要接口保持不变；上层通过接口使用下层服务，无需关心下层的具体实现细节（D 正确）。但层次越多并不一定效率越高（B 错误），因为过多的层次会增加封装、解封装等处理开销，可能导致延迟增加和效率降低，因此分层设计需权衡层次数量与性能。', 'html', b'0', b'0', @tc33, '0a1f6a17bcc560c3a3ec49a6a9c90be9770eeeac790fd825d2d39a67812330ba', b'1');
INSERT INTO question_source
  (question_id, source_type, source_name, source_year, source_question_no, paper_name, raw_ref, metadata)
VALUES
  (@q33, 'crawler_html', '计算机考研杂货铺', 2026, '33', '2026年408计算机学科专业基础综合模拟试题',
   'C:/Users/wutia/Downloads/csgraduates2026.html', '{"subject": "计算机网络", "html": true}');

-- Q34
INSERT INTO t_text_content (content, create_time)
VALUES ('{"titleContent": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q34-title.html\\" data-fallback=\\"若在带宽 200 kHz ，信噪比 S / N = 1023 的信道上，发送一个长度为 1500 B 的分组，则发送该分组的传输时延至少是 ()\\"></div>", "analyze": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q34-analysis.html\\" data-fallback=\\"正确答案： D 【解析】 首先，根据香农定理，信道容量为 C = B lo g 2 ​ ( 1 + S / N ) 其中带宽 B = 200 kHz = 2 × 1 0 5 Hz ，信噪比 S / N = 1023 。 计算 1 + 1023 = 1024 ，且 lo g 2 ​ ( 1024 ) = 10 ，因此 C\\"></div>", "questionItemObjects": [{"prefix": "A", "content": "1ms", "itemUuid": "03464a0c"}, {"prefix": "B", "content": "2ms", "itemUuid": "5b4a411d"}, {"prefix": "C", "content": "3ms", "itemUuid": "003ba89f"}, {"prefix": "D", "content": "6ms", "itemUuid": "d183b168"}]}', NOW());
SET @tc34 = LAST_INSERT_ID();
INSERT INTO t_question
  (question_type, subject_id, score, grade_level, difficult, correct, info_text_content_id, create_user, status, deleted,
   title, options, correct_answer, analysis, difficulty, knowledge_point, source, source_year, source_question_no, tags, images,
   title_text, analysis_text, content_format, has_image, has_code)
VALUES
  (1, 4, 20, NULL, 2, 'D', @tc34, 1, 1, b'0',
   '<div class="question-html-ref" data-src="question-html/2026/q34-title.html" data-fallback="若在带宽 200 kHz ，信噪比 S / N = 1023 的信道上，发送一个长度为 1500 B 的分组，则发送该分组的传输时延至少是 ()"></div>', '[{"prefix": "A", "content": "1ms", "itemUuid": "03464a0c"}, {"prefix": "B", "content": "2ms", "itemUuid": "5b4a411d"}, {"prefix": "C", "content": "3ms", "itemUuid": "003ba89f"}, {"prefix": "D", "content": "6ms", "itemUuid": "d183b168"}]', 'D', '<div class="question-html-ref" data-src="question-html/2026/q34-analysis.html" data-fallback="正确答案： D 【解析】 首先，根据香农定理，信道容量为 C = B lo g 2 ​ ( 1 + S / N ) 其中带宽 B = 200 kHz = 2 × 1 0 5 Hz ，信噪比 S / N = 1023 。 计算 1 + 1023 = 1024 ，且 lo g 2 ​ ( 1024 ) = 10 ，因此 C"></div>',
   2, NULL, '2026年408模拟题', 2026, 34, 'html,external_html,katex', '',
   '若在带宽 200 kHz ，信噪比 S / N = 1023 的信道上，发送一个长度为 1500 B 的分组，则发送该分组的传输时延至少是 ()', '正确答案： D 【解析】 首先，根据香农定理，信道容量为 C = B lo g 2 ​ ( 1 + S / N ) 其中带宽 B = 200 kHz = 2 × 1 0 5 Hz ，信噪比 S / N = 1023 。 计算 1 + 1023 = 1024 ，且 lo g 2 ​ ( 1024 ) = 10 ，因此 C = 2 × 1 0 5 × 10 = 2 × 1 0 6 bit/s = 2 Mbps . 分组长度为 1500 B ，即 1500 × 8 = 12000 bits 。 传输时延是分组长度除以数据传输速率，在理想情况下，最大速率为信道容量，故最小传输时延为 T = 2 × 1 0 6 12000 ​ = 0.006 s = 6 ms . 因此，发送该分组的传输时延至少是 6 ms。', 'html', b'0', b'0');
SET @q34 = LAST_INSERT_ID();
INSERT INTO question_content
  (question_id, version, title, options, correct_answer, analysis, title_text, analysis_text, content_format, has_image, has_code, legacy_text_content_id, source_hash, is_current)
VALUES
  (@q34, 1, '<div class="question-html-ref" data-src="question-html/2026/q34-title.html" data-fallback="若在带宽 200 kHz ，信噪比 S / N = 1023 的信道上，发送一个长度为 1500 B 的分组，则发送该分组的传输时延至少是 ()"></div>', '[{"prefix": "A", "content": "1ms", "itemUuid": "03464a0c"}, {"prefix": "B", "content": "2ms", "itemUuid": "5b4a411d"}, {"prefix": "C", "content": "3ms", "itemUuid": "003ba89f"}, {"prefix": "D", "content": "6ms", "itemUuid": "d183b168"}]', 'D', '<div class="question-html-ref" data-src="question-html/2026/q34-analysis.html" data-fallback="正确答案： D 【解析】 首先，根据香农定理，信道容量为 C = B lo g 2 ​ ( 1 + S / N ) 其中带宽 B = 200 kHz = 2 × 1 0 5 Hz ，信噪比 S / N = 1023 。 计算 1 + 1023 = 1024 ，且 lo g 2 ​ ( 1024 ) = 10 ，因此 C"></div>',
   '若在带宽 200 kHz ，信噪比 S / N = 1023 的信道上，发送一个长度为 1500 B 的分组，则发送该分组的传输时延至少是 ()', '正确答案： D 【解析】 首先，根据香农定理，信道容量为 C = B lo g 2 ​ ( 1 + S / N ) 其中带宽 B = 200 kHz = 2 × 1 0 5 Hz ，信噪比 S / N = 1023 。 计算 1 + 1023 = 1024 ，且 lo g 2 ​ ( 1024 ) = 10 ，因此 C = 2 × 1 0 5 × 10 = 2 × 1 0 6 bit/s = 2 Mbps . 分组长度为 1500 B ，即 1500 × 8 = 12000 bits 。 传输时延是分组长度除以数据传输速率，在理想情况下，最大速率为信道容量，故最小传输时延为 T = 2 × 1 0 6 12000 ​ = 0.006 s = 6 ms . 因此，发送该分组的传输时延至少是 6 ms。', 'html', b'0', b'0', @tc34, 'badc73d495e911d4e4b32f08339135bee673a724d2b194f0cc6ffef0aa271a89', b'1');
INSERT INTO question_source
  (question_id, source_type, source_name, source_year, source_question_no, paper_name, raw_ref, metadata)
VALUES
  (@q34, 'crawler_html', '计算机考研杂货铺', 2026, '34', '2026年408计算机学科专业基础综合模拟试题',
   'C:/Users/wutia/Downloads/csgraduates2026.html', '{"subject": "计算机网络", "html": true}');

-- Q35
INSERT INTO t_text_content (content, create_time)
VALUES ('{"titleContent": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q35-title.html\\" data-fallback=\\"假设采用 CSMA/CA 的 IEEE 802.11 无线局域网，其数据传输速率为 300 Mbps，DIFS = 128 μs，SIFS = 28 μs。忽略除数据帧以外的其他帧的传输时延及信号传播时延，主机 H 发送一个总长度为 1500 B 的数据帧，则从开始发送数据帧至确认接收方收到所需的时间至少为（ ）。\\"></div>", "analyze": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q35-analysis.html\\" data-fallback=\\"正确答案： B 【解析】 在 IEEE 802.11 CSMA/CA 协议中，主机 H 发送数据帧的过程为：先等待 DIFS（本题中起始点从“开始发送数据帧”算起，故 DIFS 已过，不包含在计算内），然后传输数据帧，之后接收方等待 SIFS 后发送 ACK 确认帧。根据题目，忽略除数据帧外的其他帧传输时延（即 ACK\\"></div>", "questionItemObjects": [{"prefix": "A", "content": "40 us", "itemUuid": "3388e50d"}, {"prefix": "B", "content": "68 us", "itemUuid": "098d50b7"}, {"prefix": "C", "content": "168 us", "itemUuid": "1277a6f7"}, {"prefix": "D", "content": "196 us", "itemUuid": "562a7083"}]}', NOW());
SET @tc35 = LAST_INSERT_ID();
INSERT INTO t_question
  (question_type, subject_id, score, grade_level, difficult, correct, info_text_content_id, create_user, status, deleted,
   title, options, correct_answer, analysis, difficulty, knowledge_point, source, source_year, source_question_no, tags, images,
   title_text, analysis_text, content_format, has_image, has_code)
VALUES
  (1, 4, 20, NULL, 2, 'B', @tc35, 1, 1, b'0',
   '<div class="question-html-ref" data-src="question-html/2026/q35-title.html" data-fallback="假设采用 CSMA/CA 的 IEEE 802.11 无线局域网，其数据传输速率为 300 Mbps，DIFS = 128 μs，SIFS = 28 μs。忽略除数据帧以外的其他帧的传输时延及信号传播时延，主机 H 发送一个总长度为 1500 B 的数据帧，则从开始发送数据帧至确认接收方收到所需的时间至少为（ ）。"></div>', '[{"prefix": "A", "content": "40 us", "itemUuid": "3388e50d"}, {"prefix": "B", "content": "68 us", "itemUuid": "098d50b7"}, {"prefix": "C", "content": "168 us", "itemUuid": "1277a6f7"}, {"prefix": "D", "content": "196 us", "itemUuid": "562a7083"}]', 'B', '<div class="question-html-ref" data-src="question-html/2026/q35-analysis.html" data-fallback="正确答案： B 【解析】 在 IEEE 802.11 CSMA/CA 协议中，主机 H 发送数据帧的过程为：先等待 DIFS（本题中起始点从“开始发送数据帧”算起，故 DIFS 已过，不包含在计算内），然后传输数据帧，之后接收方等待 SIFS 后发送 ACK 确认帧。根据题目，忽略除数据帧外的其他帧传输时延（即 ACK"></div>',
   2, NULL, '2026年408模拟题', 2026, 35, 'html,external_html,katex', '',
   '假设采用 CSMA/CA 的 IEEE 802.11 无线局域网，其数据传输速率为 300 Mbps，DIFS = 128 μs，SIFS = 28 μs。忽略除数据帧以外的其他帧的传输时延及信号传播时延，主机 H 发送一个总长度为 1500 B 的数据帧，则从开始发送数据帧至确认接收方收到所需的时间至少为（ ）。', '正确答案： B 【解析】 在 IEEE 802.11 CSMA/CA 协议中，主机 H 发送数据帧的过程为：先等待 DIFS（本题中起始点从“开始发送数据帧”算起，故 DIFS 已过，不包含在计算内），然后传输数据帧，之后接收方等待 SIFS 后发送 ACK 确认帧。根据题目，忽略除数据帧外的其他帧传输时延（即 ACK 帧传输时延为 0），且忽略信号传播时延。数据帧长度为 1500 B，数据传输速率为 300 Mbps。 数据帧传输时间 300 × 1 0 6 bits/s 1500 × 8 bits ​ = 300000000 12000 ​ s = 40 μ s SIFS = 28 μs. 从数据帧开始发送到发送方收到 ACK 的时间 40 μ s + 28 μ s = 68 μ s 因此，所需时间至少为 68 μs。', 'html', b'0', b'0');
SET @q35 = LAST_INSERT_ID();
INSERT INTO question_content
  (question_id, version, title, options, correct_answer, analysis, title_text, analysis_text, content_format, has_image, has_code, legacy_text_content_id, source_hash, is_current)
VALUES
  (@q35, 1, '<div class="question-html-ref" data-src="question-html/2026/q35-title.html" data-fallback="假设采用 CSMA/CA 的 IEEE 802.11 无线局域网，其数据传输速率为 300 Mbps，DIFS = 128 μs，SIFS = 28 μs。忽略除数据帧以外的其他帧的传输时延及信号传播时延，主机 H 发送一个总长度为 1500 B 的数据帧，则从开始发送数据帧至确认接收方收到所需的时间至少为（ ）。"></div>', '[{"prefix": "A", "content": "40 us", "itemUuid": "3388e50d"}, {"prefix": "B", "content": "68 us", "itemUuid": "098d50b7"}, {"prefix": "C", "content": "168 us", "itemUuid": "1277a6f7"}, {"prefix": "D", "content": "196 us", "itemUuid": "562a7083"}]', 'B', '<div class="question-html-ref" data-src="question-html/2026/q35-analysis.html" data-fallback="正确答案： B 【解析】 在 IEEE 802.11 CSMA/CA 协议中，主机 H 发送数据帧的过程为：先等待 DIFS（本题中起始点从“开始发送数据帧”算起，故 DIFS 已过，不包含在计算内），然后传输数据帧，之后接收方等待 SIFS 后发送 ACK 确认帧。根据题目，忽略除数据帧外的其他帧传输时延（即 ACK"></div>',
   '假设采用 CSMA/CA 的 IEEE 802.11 无线局域网，其数据传输速率为 300 Mbps，DIFS = 128 μs，SIFS = 28 μs。忽略除数据帧以外的其他帧的传输时延及信号传播时延，主机 H 发送一个总长度为 1500 B 的数据帧，则从开始发送数据帧至确认接收方收到所需的时间至少为（ ）。', '正确答案： B 【解析】 在 IEEE 802.11 CSMA/CA 协议中，主机 H 发送数据帧的过程为：先等待 DIFS（本题中起始点从“开始发送数据帧”算起，故 DIFS 已过，不包含在计算内），然后传输数据帧，之后接收方等待 SIFS 后发送 ACK 确认帧。根据题目，忽略除数据帧外的其他帧传输时延（即 ACK 帧传输时延为 0），且忽略信号传播时延。数据帧长度为 1500 B，数据传输速率为 300 Mbps。 数据帧传输时间 300 × 1 0 6 bits/s 1500 × 8 bits ​ = 300000000 12000 ​ s = 40 μ s SIFS = 28 μs. 从数据帧开始发送到发送方收到 ACK 的时间 40 μ s + 28 μ s = 68 μ s 因此，所需时间至少为 68 μs。', 'html', b'0', b'0', @tc35, '549a9b20b68efd9faedb2a8a8e1fa1a75ebe10c1c7c0037464bcea22e8cb7762', b'1');
INSERT INTO question_source
  (question_id, source_type, source_name, source_year, source_question_no, paper_name, raw_ref, metadata)
VALUES
  (@q35, 'crawler_html', '计算机考研杂货铺', 2026, '35', '2026年408计算机学科专业基础综合模拟试题',
   'C:/Users/wutia/Downloads/csgraduates2026.html', '{"subject": "计算机网络", "html": true}');

-- Q36
INSERT INTO t_text_content (content, create_time)
VALUES ('{"titleContent": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q36-title.html\\" data-fallback=\\"支持 VLAN 划分的以太网交换机，已按端口划分了两个 VLAN。VLAN 划分结果及各端口连接主机的 MAC 地址如图所示。下列具有不同目的 MAC 地址（DA）和源 MAC 地址（SA）的以太帧 F1–F4 中，H3 会接收到的是（ ） 计算机考研杂货铺 1 2 3 4 5 6 7 8 9 10 11 12 13 \\"></div>", "analyze": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q36-analysis.html\\" data-fallback=\\"正确答案： B 【解析】 1. 主机和端口的对应关系 VLAN 1（左半部分） 端口范围：1–7、13–19 H1 → 端口 13 → MAC …-01 H2 → 端口 2 → MAC …-02 H3 → 端口 5 → MAC …-03 ✅（我们关心的主机） VLAN 2（右半部分） 端口范围：8–12、20–24 H\\"></div>", "questionItemObjects": [{"prefix": "A", "content": "仅 F2、F4", "itemUuid": "52f984cc"}, {"prefix": "B", "content": "仅 F1、F3", "itemUuid": "5abce99b"}, {"prefix": "C", "content": "仅 F1、F2", "itemUuid": "93d13387"}, {"prefix": "D", "content": "仅 F3、F4", "itemUuid": "598d39e2"}]}', NOW());
SET @tc36 = LAST_INSERT_ID();
INSERT INTO t_question
  (question_type, subject_id, score, grade_level, difficult, correct, info_text_content_id, create_user, status, deleted,
   title, options, correct_answer, analysis, difficulty, knowledge_point, source, source_year, source_question_no, tags, images,
   title_text, analysis_text, content_format, has_image, has_code)
VALUES
  (1, 4, 20, NULL, 2, 'B', @tc36, 1, 1, b'0',
   '<div class="question-html-ref" data-src="question-html/2026/q36-title.html" data-fallback="支持 VLAN 划分的以太网交换机，已按端口划分了两个 VLAN。VLAN 划分结果及各端口连接主机的 MAC 地址如图所示。下列具有不同目的 MAC 地址（DA）和源 MAC 地址（SA）的以太帧 F1–F4 中，H3 会接收到的是（ ） 计算机考研杂货铺 1 2 3 4 5 6 7 8 9 10 11 12 13 "></div>', '[{"prefix": "A", "content": "仅 F2、F4", "itemUuid": "52f984cc"}, {"prefix": "B", "content": "仅 F1、F3", "itemUuid": "5abce99b"}, {"prefix": "C", "content": "仅 F1、F2", "itemUuid": "93d13387"}, {"prefix": "D", "content": "仅 F3、F4", "itemUuid": "598d39e2"}]', 'B', '<div class="question-html-ref" data-src="question-html/2026/q36-analysis.html" data-fallback="正确答案： B 【解析】 1. 主机和端口的对应关系 VLAN 1（左半部分） 端口范围：1–7、13–19 H1 → 端口 13 → MAC …-01 H2 → 端口 2 → MAC …-02 H3 → 端口 5 → MAC …-03 ✅（我们关心的主机） VLAN 2（右半部分） 端口范围：8–12、20–24 H"></div>',
   2, NULL, '2026年408模拟题', 2026, 36, 'html,external_html', '',
   '支持 VLAN 划分的以太网交换机，已按端口划分了两个 VLAN。VLAN 划分结果及各端口连接主机的 MAC 地址如图所示。下列具有不同目的 MAC 地址（DA）和源 MAC 地址（SA）的以太帧 F1–F4 中，H3 会接收到的是（ ） 计算机考研杂货铺 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 6 17 18 19 20 21 22 23 24 计算机考研杂货铺 计算机考研杂货铺 计算机考研杂货铺 计算机考研杂货铺 计算机考研杂货铺 计算机考研杂货铺 H1 00-1A-2B-3C-4D-01 H2 00-1A-2B-3C-4D-02 H3 00-1A-2B-3C-4D-03 H4 00-1A-2B-3C-4D-04 H5 00-1A-2B-3C-4D-05 H6 00-1A-2B-3C-4D-06 F1: （DA）00-1A-2B-3C-4D-03；（SA）00-1A-2B-3C-4D-01 F2: （DA）00-1A-2B-3C-4D-04；（SA）00-1A-2B-3C-4D-05 F3: （DA）FF-FF-FF-FF-FF-FF；（SA）00-1A-2B-3C-4D-02 F4: （DA）00-1A-2B-3C-4D-06；（SA）00-1A-2B-3C-4D-03', '正确答案： B 【解析】 1. 主机和端口的对应关系 VLAN 1（左半部分） 端口范围：1–7、13–19 H1 → 端口 13 → MAC …-01 H2 → 端口 2 → MAC …-02 H3 → 端口 5 → MAC …-03 ✅（我们关心的主机） VLAN 2（右半部分） 端口范围：8–12、20–24 H4 → 端口 8 → MAC …-04 H5 → 端口 9 → MAC …-05 H6 → 端口 12 → MAC …-06 👉 H3 位于 VLAN 1 中。 2. 交换机与 VLAN 的转发规则 单播帧 仅在 源端口所属的 VLAN 内 查询 MAC 地址表并进行转发。 若目的 MAC 地址不在本 VLAN 的地址表中，则 不会转发 该帧。 广播帧 仅在本 VLAN 内的所有端口（除源端口）进行广播 。 VLAN 间完全隔离 在没有三层设备的情况下，不同 VLAN 之间无法直接通信。 3. 逐帧判断 H3 能否收到 F1 目的地址（DA）= …-03（H3） 源地址（SA）= …-01（H1，属于 VLAN 1） 分析：帧源自 VLAN 1，目的 MAC 地址正是 H3。属于同 VLAN 单播通信。 ✅ H3 会接收此帧。 F2 目的地址（DA）= …-04（H4，属于 VLAN 2） 源地址（SA）= …-05（H5，属于 VLAN 2） 分析：整个帧的源和目的均位于 VLAN 2 内，该帧的通信被限制在 VLAN 2 中。 ❌ H3 接收不到此帧。 F3 目的地址（DA）= FF-FF-FF-FF-FF-FF（广播地址） 源地址（SA）= …-02（H2，属于 VLAN 1） 分析：这是一个广播帧，且源位于 VLAN 1。广播范围仅限于 VLAN 1 内的所有端口（发送端口除外）。 ✅ H3 位于 VLAN 1，因此会收到此广播帧。 F4 目的地址（DA）= …-06（H6，属于 VLAN 2） 源地址（SA）= …-03（H3，属于 VLAN 1） 分析：帧源自 VLAN 1，但目的 MAC 地址属于 VLAN 2。交换机在 VLAN 1 的 MAC 地址表中 查不到该目的地址 ，且单播帧 不会跨 VLAN 进行泛洪 。 ❌ H3 收不到此帧（实际上这是 H3 自己发出的帧）。 最终结论 H3 能够接收到的帧是： ✅ F1 ✅ F3 对应选项为： B 仅 F1、F3', 'html', b'0', b'0');
SET @q36 = LAST_INSERT_ID();
INSERT INTO question_content
  (question_id, version, title, options, correct_answer, analysis, title_text, analysis_text, content_format, has_image, has_code, legacy_text_content_id, source_hash, is_current)
VALUES
  (@q36, 1, '<div class="question-html-ref" data-src="question-html/2026/q36-title.html" data-fallback="支持 VLAN 划分的以太网交换机，已按端口划分了两个 VLAN。VLAN 划分结果及各端口连接主机的 MAC 地址如图所示。下列具有不同目的 MAC 地址（DA）和源 MAC 地址（SA）的以太帧 F1–F4 中，H3 会接收到的是（ ） 计算机考研杂货铺 1 2 3 4 5 6 7 8 9 10 11 12 13 "></div>', '[{"prefix": "A", "content": "仅 F2、F4", "itemUuid": "52f984cc"}, {"prefix": "B", "content": "仅 F1、F3", "itemUuid": "5abce99b"}, {"prefix": "C", "content": "仅 F1、F2", "itemUuid": "93d13387"}, {"prefix": "D", "content": "仅 F3、F4", "itemUuid": "598d39e2"}]', 'B', '<div class="question-html-ref" data-src="question-html/2026/q36-analysis.html" data-fallback="正确答案： B 【解析】 1. 主机和端口的对应关系 VLAN 1（左半部分） 端口范围：1–7、13–19 H1 → 端口 13 → MAC …-01 H2 → 端口 2 → MAC …-02 H3 → 端口 5 → MAC …-03 ✅（我们关心的主机） VLAN 2（右半部分） 端口范围：8–12、20–24 H"></div>',
   '支持 VLAN 划分的以太网交换机，已按端口划分了两个 VLAN。VLAN 划分结果及各端口连接主机的 MAC 地址如图所示。下列具有不同目的 MAC 地址（DA）和源 MAC 地址（SA）的以太帧 F1–F4 中，H3 会接收到的是（ ） 计算机考研杂货铺 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 6 17 18 19 20 21 22 23 24 计算机考研杂货铺 计算机考研杂货铺 计算机考研杂货铺 计算机考研杂货铺 计算机考研杂货铺 计算机考研杂货铺 H1 00-1A-2B-3C-4D-01 H2 00-1A-2B-3C-4D-02 H3 00-1A-2B-3C-4D-03 H4 00-1A-2B-3C-4D-04 H5 00-1A-2B-3C-4D-05 H6 00-1A-2B-3C-4D-06 F1: （DA）00-1A-2B-3C-4D-03；（SA）00-1A-2B-3C-4D-01 F2: （DA）00-1A-2B-3C-4D-04；（SA）00-1A-2B-3C-4D-05 F3: （DA）FF-FF-FF-FF-FF-FF；（SA）00-1A-2B-3C-4D-02 F4: （DA）00-1A-2B-3C-4D-06；（SA）00-1A-2B-3C-4D-03', '正确答案： B 【解析】 1. 主机和端口的对应关系 VLAN 1（左半部分） 端口范围：1–7、13–19 H1 → 端口 13 → MAC …-01 H2 → 端口 2 → MAC …-02 H3 → 端口 5 → MAC …-03 ✅（我们关心的主机） VLAN 2（右半部分） 端口范围：8–12、20–24 H4 → 端口 8 → MAC …-04 H5 → 端口 9 → MAC …-05 H6 → 端口 12 → MAC …-06 👉 H3 位于 VLAN 1 中。 2. 交换机与 VLAN 的转发规则 单播帧 仅在 源端口所属的 VLAN 内 查询 MAC 地址表并进行转发。 若目的 MAC 地址不在本 VLAN 的地址表中，则 不会转发 该帧。 广播帧 仅在本 VLAN 内的所有端口（除源端口）进行广播 。 VLAN 间完全隔离 在没有三层设备的情况下，不同 VLAN 之间无法直接通信。 3. 逐帧判断 H3 能否收到 F1 目的地址（DA）= …-03（H3） 源地址（SA）= …-01（H1，属于 VLAN 1） 分析：帧源自 VLAN 1，目的 MAC 地址正是 H3。属于同 VLAN 单播通信。 ✅ H3 会接收此帧。 F2 目的地址（DA）= …-04（H4，属于 VLAN 2） 源地址（SA）= …-05（H5，属于 VLAN 2） 分析：整个帧的源和目的均位于 VLAN 2 内，该帧的通信被限制在 VLAN 2 中。 ❌ H3 接收不到此帧。 F3 目的地址（DA）= FF-FF-FF-FF-FF-FF（广播地址） 源地址（SA）= …-02（H2，属于 VLAN 1） 分析：这是一个广播帧，且源位于 VLAN 1。广播范围仅限于 VLAN 1 内的所有端口（发送端口除外）。 ✅ H3 位于 VLAN 1，因此会收到此广播帧。 F4 目的地址（DA）= …-06（H6，属于 VLAN 2） 源地址（SA）= …-03（H3，属于 VLAN 1） 分析：帧源自 VLAN 1，但目的 MAC 地址属于 VLAN 2。交换机在 VLAN 1 的 MAC 地址表中 查不到该目的地址 ，且单播帧 不会跨 VLAN 进行泛洪 。 ❌ H3 收不到此帧（实际上这是 H3 自己发出的帧）。 最终结论 H3 能够接收到的帧是： ✅ F1 ✅ F3 对应选项为： B 仅 F1、F3', 'html', b'0', b'0', @tc36, 'aea901e8d0bc2027c629dadca15a46c74e0b088e5eaa150a61325687e7509435', b'1');
INSERT INTO question_source
  (question_id, source_type, source_name, source_year, source_question_no, paper_name, raw_ref, metadata)
VALUES
  (@q36, 'crawler_html', '计算机考研杂货铺', 2026, '36', '2026年408计算机学科专业基础综合模拟试题',
   'C:/Users/wutia/Downloads/csgraduates2026.html', '{"subject": "计算机网络", "html": true}');

-- Q37
INSERT INTO t_text_content (content, create_time)
VALUES ('{"titleContent": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q37-title.html\\" data-fallback=\\"某网络在 t 0 ​ 时刻的网络拓扑与 R 1 ​ 的路由表如下图所示。 R 1 ​ ∼ R 4 ​ 为路由器，基于链路状态路由算法进行路由计算。 S 0 ​ ∼ S 4 ​ 为路由器 R 1 ​ 的接口，链路上的数值为链路开销。若在 t 1 ​ （ t 1 ​ &gt; t 0 ​ ）时刻， R 1 ​ 检测到 R 1 ​\\"></div>", "analyze": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q37-analysis.html\\" data-fallback=\\"正确答案： C 【解析】 在链路状态路由算法中，每个路由器维护全网的拓扑信息。当 R 1 ​ 检测到与 R 2 ​ 之间的链路断开后，会更新链路状态数据库并重新计算最短路径树。根据给定的网络拓扑（图中显示）， R 1 ​ 直连多个网络，并通过其他路由器学习到远程网络的路由。重新计算后，由于链路断开，部分路由的路径发生变\\"></div>", "questionItemObjects": [{"prefix": "A", "content": "3", "itemUuid": "a6ebfd6a"}, {"prefix": "B", "content": "4", "itemUuid": "82a05c32"}, {"prefix": "C", "content": "5", "itemUuid": "5523baea"}, {"prefix": "D", "content": "6", "itemUuid": "1ee490cd"}]}', NOW());
SET @tc37 = LAST_INSERT_ID();
INSERT INTO t_question
  (question_type, subject_id, score, grade_level, difficult, correct, info_text_content_id, create_user, status, deleted,
   title, options, correct_answer, analysis, difficulty, knowledge_point, source, source_year, source_question_no, tags, images,
   title_text, analysis_text, content_format, has_image, has_code)
VALUES
  (1, 4, 20, NULL, 2, 'C', @tc37, 1, 1, b'0',
   '<div class="question-html-ref" data-src="question-html/2026/q37-title.html" data-fallback="某网络在 t 0 ​ 时刻的网络拓扑与 R 1 ​ 的路由表如下图所示。 R 1 ​ ∼ R 4 ​ 为路由器，基于链路状态路由算法进行路由计算。 S 0 ​ ∼ S 4 ​ 为路由器 R 1 ​ 的接口，链路上的数值为链路开销。若在 t 1 ​ （ t 1 ​ &gt; t 0 ​ ）时刻， R 1 ​ 检测到 R 1 ​"></div>', '[{"prefix": "A", "content": "3", "itemUuid": "a6ebfd6a"}, {"prefix": "B", "content": "4", "itemUuid": "82a05c32"}, {"prefix": "C", "content": "5", "itemUuid": "5523baea"}, {"prefix": "D", "content": "6", "itemUuid": "1ee490cd"}]', 'C', '<div class="question-html-ref" data-src="question-html/2026/q37-analysis.html" data-fallback="正确答案： C 【解析】 在链路状态路由算法中，每个路由器维护全网的拓扑信息。当 R 1 ​ 检测到与 R 2 ​ 之间的链路断开后，会更新链路状态数据库并重新计算最短路径树。根据给定的网络拓扑（图中显示）， R 1 ​ 直连多个网络，并通过其他路由器学习到远程网络的路由。重新计算后，由于链路断开，部分路由的路径发生变"></div>',
   2, NULL, '2026年408模拟题', 2026, 37, 'html,external_html,table,katex', '',
   '某网络在 t 0 ​ 时刻的网络拓扑与 R 1 ​ 的路由表如下图所示。 R 1 ​ ∼ R 4 ​ 为路由器，基于链路状态路由算法进行路由计算。 S 0 ​ ∼ S 4 ​ 为路由器 R 1 ​ 的接口，链路上的数值为链路开销。若在 t 1 ​ （ t 1 ​ > t 0 ​ ）时刻， R 1 ​ 检测到 R 1 ​ 与 R 2 ​ 之间的链路断开，则 R 1 ​ 重新计算路由并进行充分路由聚合后，表中路由条目的数量为（ ）。 计算机考研杂货铺 5 3 4 6 199.10.20.0/27 Internet 199.10.20.32/27 199.10.20.64/27 199.10.20.128/25 计算机考研杂货铺 t1 2 → ♾️ R1 R2 R3 R4 0 1 2 3', '正确答案： C 【解析】 在链路状态路由算法中，每个路由器维护全网的拓扑信息。当 R 1 ​ 检测到与 R 2 ​ 之间的链路断开后，会更新链路状态数据库并重新计算最短路径树。根据给定的网络拓扑（图中显示）， R 1 ​ 直连多个网络，并通过其他路由器学习到远程网络的路由。重新计算后，由于链路断开，部分路由的路径发生变化，但所有网络仍可达。进行充分路由聚合时，可以将多个连续子网汇总为一个路由条目，从而减少路由表规模。根据拓扑结构、子网划分以及聚合原则，聚合后路由表结构如下： 目标网络 接口 199.10.20.0/27 2 199.10.20.32/27 2 199.10.20.64/27 3 199.10.20.128/25 4 0.0.0.0 1 所以路由表的个数仍然为 5，答案选择 C。', 'html', b'0', b'0');
SET @q37 = LAST_INSERT_ID();
INSERT INTO question_content
  (question_id, version, title, options, correct_answer, analysis, title_text, analysis_text, content_format, has_image, has_code, legacy_text_content_id, source_hash, is_current)
VALUES
  (@q37, 1, '<div class="question-html-ref" data-src="question-html/2026/q37-title.html" data-fallback="某网络在 t 0 ​ 时刻的网络拓扑与 R 1 ​ 的路由表如下图所示。 R 1 ​ ∼ R 4 ​ 为路由器，基于链路状态路由算法进行路由计算。 S 0 ​ ∼ S 4 ​ 为路由器 R 1 ​ 的接口，链路上的数值为链路开销。若在 t 1 ​ （ t 1 ​ &gt; t 0 ​ ）时刻， R 1 ​ 检测到 R 1 ​"></div>', '[{"prefix": "A", "content": "3", "itemUuid": "a6ebfd6a"}, {"prefix": "B", "content": "4", "itemUuid": "82a05c32"}, {"prefix": "C", "content": "5", "itemUuid": "5523baea"}, {"prefix": "D", "content": "6", "itemUuid": "1ee490cd"}]', 'C', '<div class="question-html-ref" data-src="question-html/2026/q37-analysis.html" data-fallback="正确答案： C 【解析】 在链路状态路由算法中，每个路由器维护全网的拓扑信息。当 R 1 ​ 检测到与 R 2 ​ 之间的链路断开后，会更新链路状态数据库并重新计算最短路径树。根据给定的网络拓扑（图中显示）， R 1 ​ 直连多个网络，并通过其他路由器学习到远程网络的路由。重新计算后，由于链路断开，部分路由的路径发生变"></div>',
   '某网络在 t 0 ​ 时刻的网络拓扑与 R 1 ​ 的路由表如下图所示。 R 1 ​ ∼ R 4 ​ 为路由器，基于链路状态路由算法进行路由计算。 S 0 ​ ∼ S 4 ​ 为路由器 R 1 ​ 的接口，链路上的数值为链路开销。若在 t 1 ​ （ t 1 ​ > t 0 ​ ）时刻， R 1 ​ 检测到 R 1 ​ 与 R 2 ​ 之间的链路断开，则 R 1 ​ 重新计算路由并进行充分路由聚合后，表中路由条目的数量为（ ）。 计算机考研杂货铺 5 3 4 6 199.10.20.0/27 Internet 199.10.20.32/27 199.10.20.64/27 199.10.20.128/25 计算机考研杂货铺 t1 2 → ♾️ R1 R2 R3 R4 0 1 2 3', '正确答案： C 【解析】 在链路状态路由算法中，每个路由器维护全网的拓扑信息。当 R 1 ​ 检测到与 R 2 ​ 之间的链路断开后，会更新链路状态数据库并重新计算最短路径树。根据给定的网络拓扑（图中显示）， R 1 ​ 直连多个网络，并通过其他路由器学习到远程网络的路由。重新计算后，由于链路断开，部分路由的路径发生变化，但所有网络仍可达。进行充分路由聚合时，可以将多个连续子网汇总为一个路由条目，从而减少路由表规模。根据拓扑结构、子网划分以及聚合原则，聚合后路由表结构如下： 目标网络 接口 199.10.20.0/27 2 199.10.20.32/27 2 199.10.20.64/27 3 199.10.20.128/25 4 0.0.0.0 1 所以路由表的个数仍然为 5，答案选择 C。', 'html', b'0', b'0', @tc37, '95588974ef396c51a31322e6a8dd68da6fcf61aee6f1d53b62359f843329f76c', b'1');
INSERT INTO question_source
  (question_id, source_type, source_name, source_year, source_question_no, paper_name, raw_ref, metadata)
VALUES
  (@q37, 'crawler_html', '计算机考研杂货铺', 2026, '37', '2026年408计算机学科专业基础综合模拟试题',
   'C:/Users/wutia/Downloads/csgraduates2026.html', '{"subject": "计算机网络", "html": true}');

-- Q38
INSERT INTO t_text_content (content, create_time)
VALUES ('{"titleContent": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q38-title.html\\" data-fallback=\\"下列路由协议中，能将一个自治系统划分为多个区域的内部网关协议是（ ） I. OSPF II. RIP III. BGP\\"></div>", "analyze": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q38-analysis.html\\" data-fallback=\\"正确答案： A 【解析】 OSPF（开放最短路径优先）是一种内部网关协议（IGP），它支持分层设计，可以将自治系统划分为多个区域（如骨干区域和其他区域），以提高网络的可扩展性和管理效率。RIP（路由信息协议）也是一种内部网关协议，但它采用距离向量算法，不支持区域划分。BGP（边界网关协议）是外部网关协议（EGP），用于\\"></div>", "questionItemObjects": [{"prefix": "A", "content": "仅 I", "itemUuid": "f8b37f35"}, {"prefix": "B", "content": "仅 II", "itemUuid": "7f7113e5"}, {"prefix": "C", "content": "仅 I、III", "itemUuid": "5fdf800a"}, {"prefix": "D", "content": "仅 II、III", "itemUuid": "2c97befc"}]}', NOW());
SET @tc38 = LAST_INSERT_ID();
INSERT INTO t_question
  (question_type, subject_id, score, grade_level, difficult, correct, info_text_content_id, create_user, status, deleted,
   title, options, correct_answer, analysis, difficulty, knowledge_point, source, source_year, source_question_no, tags, images,
   title_text, analysis_text, content_format, has_image, has_code)
VALUES
  (1, 4, 20, NULL, 2, 'A', @tc38, 1, 1, b'0',
   '<div class="question-html-ref" data-src="question-html/2026/q38-title.html" data-fallback="下列路由协议中，能将一个自治系统划分为多个区域的内部网关协议是（ ） I. OSPF II. RIP III. BGP"></div>', '[{"prefix": "A", "content": "仅 I", "itemUuid": "f8b37f35"}, {"prefix": "B", "content": "仅 II", "itemUuid": "7f7113e5"}, {"prefix": "C", "content": "仅 I、III", "itemUuid": "5fdf800a"}, {"prefix": "D", "content": "仅 II、III", "itemUuid": "2c97befc"}]', 'A', '<div class="question-html-ref" data-src="question-html/2026/q38-analysis.html" data-fallback="正确答案： A 【解析】 OSPF（开放最短路径优先）是一种内部网关协议（IGP），它支持分层设计，可以将自治系统划分为多个区域（如骨干区域和其他区域），以提高网络的可扩展性和管理效率。RIP（路由信息协议）也是一种内部网关协议，但它采用距离向量算法，不支持区域划分。BGP（边界网关协议）是外部网关协议（EGP），用于"></div>',
   2, NULL, '2026年408模拟题', 2026, 38, 'html,external_html', '',
   '下列路由协议中，能将一个自治系统划分为多个区域的内部网关协议是（ ） I. OSPF II. RIP III. BGP', '正确答案： A 【解析】 OSPF（开放最短路径优先）是一种内部网关协议（IGP），它支持分层设计，可以将自治系统划分为多个区域（如骨干区域和其他区域），以提高网络的可扩展性和管理效率。RIP（路由信息协议）也是一种内部网关协议，但它采用距离向量算法，不支持区域划分。BGP（边界网关协议）是外部网关协议（EGP），用于自治系统间的路由交换，不属于内部网关协议，也不支持区域划分。因此，只有 OSPF 符合题意。', 'html', b'0', b'0');
SET @q38 = LAST_INSERT_ID();
INSERT INTO question_content
  (question_id, version, title, options, correct_answer, analysis, title_text, analysis_text, content_format, has_image, has_code, legacy_text_content_id, source_hash, is_current)
VALUES
  (@q38, 1, '<div class="question-html-ref" data-src="question-html/2026/q38-title.html" data-fallback="下列路由协议中，能将一个自治系统划分为多个区域的内部网关协议是（ ） I. OSPF II. RIP III. BGP"></div>', '[{"prefix": "A", "content": "仅 I", "itemUuid": "f8b37f35"}, {"prefix": "B", "content": "仅 II", "itemUuid": "7f7113e5"}, {"prefix": "C", "content": "仅 I、III", "itemUuid": "5fdf800a"}, {"prefix": "D", "content": "仅 II、III", "itemUuid": "2c97befc"}]', 'A', '<div class="question-html-ref" data-src="question-html/2026/q38-analysis.html" data-fallback="正确答案： A 【解析】 OSPF（开放最短路径优先）是一种内部网关协议（IGP），它支持分层设计，可以将自治系统划分为多个区域（如骨干区域和其他区域），以提高网络的可扩展性和管理效率。RIP（路由信息协议）也是一种内部网关协议，但它采用距离向量算法，不支持区域划分。BGP（边界网关协议）是外部网关协议（EGP），用于"></div>',
   '下列路由协议中，能将一个自治系统划分为多个区域的内部网关协议是（ ） I. OSPF II. RIP III. BGP', '正确答案： A 【解析】 OSPF（开放最短路径优先）是一种内部网关协议（IGP），它支持分层设计，可以将自治系统划分为多个区域（如骨干区域和其他区域），以提高网络的可扩展性和管理效率。RIP（路由信息协议）也是一种内部网关协议，但它采用距离向量算法，不支持区域划分。BGP（边界网关协议）是外部网关协议（EGP），用于自治系统间的路由交换，不属于内部网关协议，也不支持区域划分。因此，只有 OSPF 符合题意。', 'html', b'0', b'0', @tc38, 'f7329bc794f0523796660b0239e1027e54bb68c5aa7b6f8b483e78238c6d4acf', b'1');
INSERT INTO question_source
  (question_id, source_type, source_name, source_year, source_question_no, paper_name, raw_ref, metadata)
VALUES
  (@q38, 'crawler_html', '计算机考研杂货铺', 2026, '38', '2026年408计算机学科专业基础综合模拟试题',
   'C:/Users/wutia/Downloads/csgraduates2026.html', '{"subject": "计算机网络", "html": true}');

-- Q39
INSERT INTO t_text_content (content, create_time)
VALUES ('{"titleContent": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q39-title.html\\" data-fallback=\\"若将 IP 网络 123.4.4.0/22 划分为规模均衡的 32 个子网，则 IP 地址 123.4.5.11 所在的子网是（）\\"></div>", "analyze": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q39-analysis.html\\" data-fallback=\\"正确答案： C 【解析】 1. 原始网络信息 给定网络： 123.4.4.0/22 /22 表示网络位共有 22 位 主机位 = 32 − 22 = 10 位 地址总数 = (2^{10} = 1024) 该 /22 网络覆盖范围是： 123.4.4.0 ～ 123.4.7.255 2. 划分为 32 个规模均衡的子网\\"></div>", "questionItemObjects": [{"prefix": "A", "content": "123.4.4.0/27", "itemUuid": "8d0b35f2"}, {"prefix": "B", "content": "123.4.4.32/27", "itemUuid": "368d5b63"}, {"prefix": "C", "content": "123.4.5.0/27", "itemUuid": "f3aa5fc6"}, {"prefix": "D", "content": "123.4.5.32/27", "itemUuid": "2f934beb"}]}', NOW());
SET @tc39 = LAST_INSERT_ID();
INSERT INTO t_question
  (question_type, subject_id, score, grade_level, difficult, correct, info_text_content_id, create_user, status, deleted,
   title, options, correct_answer, analysis, difficulty, knowledge_point, source, source_year, source_question_no, tags, images,
   title_text, analysis_text, content_format, has_image, has_code)
VALUES
  (1, 4, 20, NULL, 2, 'C', @tc39, 1, 1, b'0',
   '<div class="question-html-ref" data-src="question-html/2026/q39-title.html" data-fallback="若将 IP 网络 123.4.4.0/22 划分为规模均衡的 32 个子网，则 IP 地址 123.4.5.11 所在的子网是（）"></div>', '[{"prefix": "A", "content": "123.4.4.0/27", "itemUuid": "8d0b35f2"}, {"prefix": "B", "content": "123.4.4.32/27", "itemUuid": "368d5b63"}, {"prefix": "C", "content": "123.4.5.0/27", "itemUuid": "f3aa5fc6"}, {"prefix": "D", "content": "123.4.5.32/27", "itemUuid": "2f934beb"}]', 'C', '<div class="question-html-ref" data-src="question-html/2026/q39-analysis.html" data-fallback="正确答案： C 【解析】 1. 原始网络信息 给定网络： 123.4.4.0/22 /22 表示网络位共有 22 位 主机位 = 32 − 22 = 10 位 地址总数 = (2^{10} = 1024) 该 /22 网络覆盖范围是： 123.4.4.0 ～ 123.4.7.255 2. 划分为 32 个规模均衡的子网"></div>',
   2, NULL, '2026年408模拟题', 2026, 39, 'html,external_html,code,katex', '',
   '若将 IP 网络 123.4.4.0/22 划分为规模均衡的 32 个子网，则 IP 地址 123.4.5.11 所在的子网是（）', '正确答案： C 【解析】 1. 原始网络信息 给定网络： 123.4.4.0/22 /22 表示网络位共有 22 位 主机位 = 32 − 22 = 10 位 地址总数 = (2^{10} = 1024) 该 /22 网络覆盖范围是： 123.4.4.0 ～ 123.4.7.255 2. 划分为 32 个规模均衡的子网 需要 32 个子网： 32 = 2 5 ⇒ 从主机位中 再借 5 位作为子网位 新前缀长度： 22 + 5 = 27 子网前缀为 /27 3. /27 子网的地址块大小 /27： 主机位 = 5 位 每个子网地址数 = (2^5 = 32) 也就是说，每个子网 步长是 32 。 4. 确定 123.4.5.11 属于哪个 /27 子网 看第三个字节为 5 的情况： 123.4.5.0 ~ 123.4.5.31 （第一个 /27） 123.4.5.32 ~ 123.4.5.63 （第二个 /27） IP 地址 123.4.5.11 落在： 123.4.5.0 ~ 123.4.5.31 5. 结论 该 IP 所在子网是： 123.4.5.0/27', 'html', b'0', b'1');
SET @q39 = LAST_INSERT_ID();
INSERT INTO question_content
  (question_id, version, title, options, correct_answer, analysis, title_text, analysis_text, content_format, has_image, has_code, legacy_text_content_id, source_hash, is_current)
VALUES
  (@q39, 1, '<div class="question-html-ref" data-src="question-html/2026/q39-title.html" data-fallback="若将 IP 网络 123.4.4.0/22 划分为规模均衡的 32 个子网，则 IP 地址 123.4.5.11 所在的子网是（）"></div>', '[{"prefix": "A", "content": "123.4.4.0/27", "itemUuid": "8d0b35f2"}, {"prefix": "B", "content": "123.4.4.32/27", "itemUuid": "368d5b63"}, {"prefix": "C", "content": "123.4.5.0/27", "itemUuid": "f3aa5fc6"}, {"prefix": "D", "content": "123.4.5.32/27", "itemUuid": "2f934beb"}]', 'C', '<div class="question-html-ref" data-src="question-html/2026/q39-analysis.html" data-fallback="正确答案： C 【解析】 1. 原始网络信息 给定网络： 123.4.4.0/22 /22 表示网络位共有 22 位 主机位 = 32 − 22 = 10 位 地址总数 = (2^{10} = 1024) 该 /22 网络覆盖范围是： 123.4.4.0 ～ 123.4.7.255 2. 划分为 32 个规模均衡的子网"></div>',
   '若将 IP 网络 123.4.4.0/22 划分为规模均衡的 32 个子网，则 IP 地址 123.4.5.11 所在的子网是（）', '正确答案： C 【解析】 1. 原始网络信息 给定网络： 123.4.4.0/22 /22 表示网络位共有 22 位 主机位 = 32 − 22 = 10 位 地址总数 = (2^{10} = 1024) 该 /22 网络覆盖范围是： 123.4.4.0 ～ 123.4.7.255 2. 划分为 32 个规模均衡的子网 需要 32 个子网： 32 = 2 5 ⇒ 从主机位中 再借 5 位作为子网位 新前缀长度： 22 + 5 = 27 子网前缀为 /27 3. /27 子网的地址块大小 /27： 主机位 = 5 位 每个子网地址数 = (2^5 = 32) 也就是说，每个子网 步长是 32 。 4. 确定 123.4.5.11 属于哪个 /27 子网 看第三个字节为 5 的情况： 123.4.5.0 ~ 123.4.5.31 （第一个 /27） 123.4.5.32 ~ 123.4.5.63 （第二个 /27） IP 地址 123.4.5.11 落在： 123.4.5.0 ~ 123.4.5.31 5. 结论 该 IP 所在子网是： 123.4.5.0/27', 'html', b'0', b'1', @tc39, 'fc39b5492611aaa4b922320af61ee528a495230a91945a1070b69e691176ba19', b'1');
INSERT INTO question_source
  (question_id, source_type, source_name, source_year, source_question_no, paper_name, raw_ref, metadata)
VALUES
  (@q39, 'crawler_html', '计算机考研杂货铺', 2026, '39', '2026年408计算机学科专业基础综合模拟试题',
   'C:/Users/wutia/Downloads/csgraduates2026.html', '{"subject": "计算机网络", "html": true}');

-- Q40
INSERT INTO t_text_content (content, create_time)
VALUES ('{"titleContent": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q40-title.html\\" data-fallback=\\"下列叙述中不属于 cookie 的技术典型用途的是（）\\"></div>", "analyze": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q40-analysis.html\\" data-fallback=\\"正确答案： D 【解析】Cookie 主要用于在客户端存储状态信息，以支持用户会话和个性化体验。选项 A（用户跟踪）、B（个性化推荐）和 C（构建虚拟购物车）都是 Cookie 的典型应用，分别用于记录用户行为、存储偏好以提供定制内容以及维护购物车状态。而选项 D（缩短 Web 对象的响应时间）并非 Cookie 的用\\"></div>", "questionItemObjects": [{"prefix": "A", "content": "用户跟踪", "itemUuid": "fe6140f6"}, {"prefix": "B", "content": "个性化推荐", "itemUuid": "54a4bd1e"}, {"prefix": "C", "content": "构建虚拟购物车", "itemUuid": "89d8234a"}, {"prefix": "D", "content": "缩短 web 对象的响应时间", "itemUuid": "c9288439"}]}', NOW());
SET @tc40 = LAST_INSERT_ID();
INSERT INTO t_question
  (question_type, subject_id, score, grade_level, difficult, correct, info_text_content_id, create_user, status, deleted,
   title, options, correct_answer, analysis, difficulty, knowledge_point, source, source_year, source_question_no, tags, images,
   title_text, analysis_text, content_format, has_image, has_code)
VALUES
  (1, 4, 20, NULL, 2, 'D', @tc40, 1, 1, b'0',
   '<div class="question-html-ref" data-src="question-html/2026/q40-title.html" data-fallback="下列叙述中不属于 cookie 的技术典型用途的是（）"></div>', '[{"prefix": "A", "content": "用户跟踪", "itemUuid": "fe6140f6"}, {"prefix": "B", "content": "个性化推荐", "itemUuid": "54a4bd1e"}, {"prefix": "C", "content": "构建虚拟购物车", "itemUuid": "89d8234a"}, {"prefix": "D", "content": "缩短 web 对象的响应时间", "itemUuid": "c9288439"}]', 'D', '<div class="question-html-ref" data-src="question-html/2026/q40-analysis.html" data-fallback="正确答案： D 【解析】Cookie 主要用于在客户端存储状态信息，以支持用户会话和个性化体验。选项 A（用户跟踪）、B（个性化推荐）和 C（构建虚拟购物车）都是 Cookie 的典型应用，分别用于记录用户行为、存储偏好以提供定制内容以及维护购物车状态。而选项 D（缩短 Web 对象的响应时间）并非 Cookie 的用"></div>',
   2, NULL, '2026年408模拟题', 2026, 40, 'html,external_html', '',
   '下列叙述中不属于 cookie 的技术典型用途的是（）', '正确答案： D 【解析】Cookie 主要用于在客户端存储状态信息，以支持用户会话和个性化体验。选项 A（用户跟踪）、B（个性化推荐）和 C（构建虚拟购物车）都是 Cookie 的典型应用，分别用于记录用户行为、存储偏好以提供定制内容以及维护购物车状态。而选项 D（缩短 Web 对象的响应时间）并非 Cookie 的用途，响应时间的优化通常依赖于缓存、内容分发网络（CDN）或服务器端技术，Cookie 反而可能因增加请求头大小而轻微影响性能。', 'html', b'0', b'0');
SET @q40 = LAST_INSERT_ID();
INSERT INTO question_content
  (question_id, version, title, options, correct_answer, analysis, title_text, analysis_text, content_format, has_image, has_code, legacy_text_content_id, source_hash, is_current)
VALUES
  (@q40, 1, '<div class="question-html-ref" data-src="question-html/2026/q40-title.html" data-fallback="下列叙述中不属于 cookie 的技术典型用途的是（）"></div>', '[{"prefix": "A", "content": "用户跟踪", "itemUuid": "fe6140f6"}, {"prefix": "B", "content": "个性化推荐", "itemUuid": "54a4bd1e"}, {"prefix": "C", "content": "构建虚拟购物车", "itemUuid": "89d8234a"}, {"prefix": "D", "content": "缩短 web 对象的响应时间", "itemUuid": "c9288439"}]', 'D', '<div class="question-html-ref" data-src="question-html/2026/q40-analysis.html" data-fallback="正确答案： D 【解析】Cookie 主要用于在客户端存储状态信息，以支持用户会话和个性化体验。选项 A（用户跟踪）、B（个性化推荐）和 C（构建虚拟购物车）都是 Cookie 的典型应用，分别用于记录用户行为、存储偏好以提供定制内容以及维护购物车状态。而选项 D（缩短 Web 对象的响应时间）并非 Cookie 的用"></div>',
   '下列叙述中不属于 cookie 的技术典型用途的是（）', '正确答案： D 【解析】Cookie 主要用于在客户端存储状态信息，以支持用户会话和个性化体验。选项 A（用户跟踪）、B（个性化推荐）和 C（构建虚拟购物车）都是 Cookie 的典型应用，分别用于记录用户行为、存储偏好以提供定制内容以及维护购物车状态。而选项 D（缩短 Web 对象的响应时间）并非 Cookie 的用途，响应时间的优化通常依赖于缓存、内容分发网络（CDN）或服务器端技术，Cookie 反而可能因增加请求头大小而轻微影响性能。', 'html', b'0', b'0', @tc40, 'f4d0e07c2ed5a6363daab6921bb9195b675cea81e29235df04c0be378aa1e500', b'1');
INSERT INTO question_source
  (question_id, source_type, source_name, source_year, source_question_no, paper_name, raw_ref, metadata)
VALUES
  (@q40, 'crawler_html', '计算机考研杂货铺', 2026, '40', '2026年408计算机学科专业基础综合模拟试题',
   'C:/Users/wutia/Downloads/csgraduates2026.html', '{"subject": "计算机网络", "html": true}');

-- Q41
INSERT INTO t_text_content (content, create_time)
VALUES ('{"titleContent": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q41-title.html\\" data-fallback=\\"（本题满分 13 分） 假定二叉搜索树使用二叉链表存储，存储结构如下： typedef struct BSTNode { int data ; struct BSTNode * left , * right ; } BSTNode ; typedef BSTNode BTNode ; 给一棵二叉搜索树 T 和整数 K，\\"></div>", "analyze": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q41-analysis.html\\" data-fallback=\\"(1) 算法设计思想 ： 由于二叉搜索树的中序遍历序列为递增序列，本算法采用中序递归遍历二叉树，并记录当前找到的最小绝对值差值 min 。 遍历过程中，每访问一个结点时计算目标值与当前结点值之差的绝对值： 若该值小于 min ，则更新 min ； 若该值大于或等于 min ，说明后续结点的差值会更大，此时可停止查找（可\\"></div>", "questionItemObjects": []}', NOW());
SET @tc41 = LAST_INSERT_ID();
INSERT INTO t_question
  (question_type, subject_id, score, grade_level, difficult, correct, info_text_content_id, create_user, status, deleted,
   title, options, correct_answer, analysis, difficulty, knowledge_point, source, source_year, source_question_no, tags, images,
   title_text, analysis_text, content_format, has_image, has_code)
VALUES
  (5, 1, 130, NULL, 2, '', @tc41, 1, 1, b'0',
   '<div class="question-html-ref" data-src="question-html/2026/q41-title.html" data-fallback="（本题满分 13 分） 假定二叉搜索树使用二叉链表存储，存储结构如下： typedef struct BSTNode { int data ; struct BSTNode * left , * right ; } BSTNode ; typedef BSTNode BTNode ; 给一棵二叉搜索树 T 和整数 K，"></div>', '[]', '', '<div class="question-html-ref" data-src="question-html/2026/q41-analysis.html" data-fallback="(1) 算法设计思想 ： 由于二叉搜索树的中序遍历序列为递增序列，本算法采用中序递归遍历二叉树，并记录当前找到的最小绝对值差值 min 。 遍历过程中，每访问一个结点时计算目标值与当前结点值之差的绝对值： 若该值小于 min ，则更新 min ； 若该值大于或等于 min ，说明后续结点的差值会更大，此时可停止查找（可"></div>',
   2, NULL, '2026年408模拟题', 2026, 41, 'html,external_html,code', '',
   '（本题满分 13 分） 假定二叉搜索树使用二叉链表存储，存储结构如下： typedef struct BSTNode { int data ; struct BSTNode * left , * right ; } BSTNode ; typedef BSTNode BTNode ; 给一棵二叉搜索树 T 和整数 K，查找树中关键字与 K 之差的绝对值最小的所有结点，并输出该绝对值与结点中的关键字。 （1）给出算法的基本思想。（4 分） （2）使用 C/C++ 描述算法思想。（8 分）', '(1) 算法设计思想 ： 由于二叉搜索树的中序遍历序列为递增序列，本算法采用中序递归遍历二叉树，并记录当前找到的最小绝对值差值 min 。 遍历过程中，每访问一个结点时计算目标值与当前结点值之差的绝对值： 若该值小于 min ，则更新 min ； 若该值大于或等于 min ，说明后续结点的差值会更大，此时可停止查找（可通过标志变量 flag 控制递归终止）。 最后输出所有差值为 min 的结点。 注意：题目要求输出与目标值差的绝对值最小的所有结点，可能不止一个结点。例如下图中： 结点 5、15 与目标值 10 的差的绝对值均为 5，此时应全部输出。 满足条件的结点最多只可能有两个。 10 / \\ 5 15 (2) 算法实现： // 当前的绝对值差值最小值 int min = INT_MAX ; // 最小绝对值差值是否已经找到 int flag = 0 ; // 存储待输出的结点关键字 int min_data [ 2 ]; int min_idx = 0 ; void searchMinDiff ( BTNode * root , int K ) { if ( ! root ) return ; if ( flag ) return ; searchMinDiff ( root -> left , K ); // 中序遍历 int diff = abs ( K - root -> data ); if ( diff < min ) { min = diff ; min_data [ 0 ] = root -> data ; min_idx = 1 ; } else if ( diff == min ) { min_data [ min_idx ++ ] = root -> data ; } else { flag = 1 ; } searchMinDiff ( root -> right , K ); } void solve ( BTNode * root , int K ) { searchMinDiff ( root , K ); printf ( "min diff: %d \\n " , min ); for ( int i = 0 ; i < min_idx ; i ++ ) { printf ( "min element: %d \\n " , min_data [ i ]); } }', 'html', b'0', b'1');
SET @q41 = LAST_INSERT_ID();
INSERT INTO question_content
  (question_id, version, title, options, correct_answer, analysis, title_text, analysis_text, content_format, has_image, has_code, legacy_text_content_id, source_hash, is_current)
VALUES
  (@q41, 1, '<div class="question-html-ref" data-src="question-html/2026/q41-title.html" data-fallback="（本题满分 13 分） 假定二叉搜索树使用二叉链表存储，存储结构如下： typedef struct BSTNode { int data ; struct BSTNode * left , * right ; } BSTNode ; typedef BSTNode BTNode ; 给一棵二叉搜索树 T 和整数 K，"></div>', '[]', '', '<div class="question-html-ref" data-src="question-html/2026/q41-analysis.html" data-fallback="(1) 算法设计思想 ： 由于二叉搜索树的中序遍历序列为递增序列，本算法采用中序递归遍历二叉树，并记录当前找到的最小绝对值差值 min 。 遍历过程中，每访问一个结点时计算目标值与当前结点值之差的绝对值： 若该值小于 min ，则更新 min ； 若该值大于或等于 min ，说明后续结点的差值会更大，此时可停止查找（可"></div>',
   '（本题满分 13 分） 假定二叉搜索树使用二叉链表存储，存储结构如下： typedef struct BSTNode { int data ; struct BSTNode * left , * right ; } BSTNode ; typedef BSTNode BTNode ; 给一棵二叉搜索树 T 和整数 K，查找树中关键字与 K 之差的绝对值最小的所有结点，并输出该绝对值与结点中的关键字。 （1）给出算法的基本思想。（4 分） （2）使用 C/C++ 描述算法思想。（8 分）', '(1) 算法设计思想 ： 由于二叉搜索树的中序遍历序列为递增序列，本算法采用中序递归遍历二叉树，并记录当前找到的最小绝对值差值 min 。 遍历过程中，每访问一个结点时计算目标值与当前结点值之差的绝对值： 若该值小于 min ，则更新 min ； 若该值大于或等于 min ，说明后续结点的差值会更大，此时可停止查找（可通过标志变量 flag 控制递归终止）。 最后输出所有差值为 min 的结点。 注意：题目要求输出与目标值差的绝对值最小的所有结点，可能不止一个结点。例如下图中： 结点 5、15 与目标值 10 的差的绝对值均为 5，此时应全部输出。 满足条件的结点最多只可能有两个。 10 / \\ 5 15 (2) 算法实现： // 当前的绝对值差值最小值 int min = INT_MAX ; // 最小绝对值差值是否已经找到 int flag = 0 ; // 存储待输出的结点关键字 int min_data [ 2 ]; int min_idx = 0 ; void searchMinDiff ( BTNode * root , int K ) { if ( ! root ) return ; if ( flag ) return ; searchMinDiff ( root -> left , K ); // 中序遍历 int diff = abs ( K - root -> data ); if ( diff < min ) { min = diff ; min_data [ 0 ] = root -> data ; min_idx = 1 ; } else if ( diff == min ) { min_data [ min_idx ++ ] = root -> data ; } else { flag = 1 ; } searchMinDiff ( root -> right , K ); } void solve ( BTNode * root , int K ) { searchMinDiff ( root , K ); printf ( "min diff: %d \\n " , min ); for ( int i = 0 ; i < min_idx ; i ++ ) { printf ( "min element: %d \\n " , min_data [ i ]); } }', 'html', b'0', b'1', @tc41, 'ad46fd96ce68207ad1ea8a89d347bd8b2a611df2525417ba1c35929ba28eb08a', b'1');
INSERT INTO question_source
  (question_id, source_type, source_name, source_year, source_question_no, paper_name, raw_ref, metadata)
VALUES
  (@q41, 'crawler_html', '计算机考研杂货铺', 2026, '41', '2026年408计算机学科专业基础综合模拟试题',
   'C:/Users/wutia/Downloads/csgraduates2026.html', '{"subject": "数据结构", "html": true}');

-- Q42
INSERT INTO t_text_content (content, create_time)
VALUES ('{"titleContent": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q42-title.html\\" data-fallback=\\"（本题满分 10 分） 栈的基本操作有出栈和入栈。将序列 1 , 2 , 3 , … , n 依次入栈，回答下列问题： (1) 当 n = 9 时，可以得到出栈序列 { 2 , 3 , 1 , 6 , 4 , 7 , 5 , 8 } 吗？可以得到出栈序列 { 2 , 3 , 1 , 4 , 6 , 5 , 7 , 8 \\"></div>", "analyze": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q42-analysis.html\\" data-fallback=\\"（1）当 n = 9 时，出栈序列的可能性分析 序列 { 2 , 3 , 1 , 6 , 4 , 7 , 5 , 8 } （假设包含 9 ，即 { 2 , 3 , 1 , 6 , 4 , 7 , 5 , 8 , 9 } ）： 存在下标 i = 4 , j = 5 , k = 7 ，满足 P j ​ = 4 &lt; P k \\"></div>", "questionItemObjects": []}', NOW());
SET @tc42 = LAST_INSERT_ID();
INSERT INTO t_question
  (question_type, subject_id, score, grade_level, difficult, correct, info_text_content_id, create_user, status, deleted,
   title, options, correct_answer, analysis, difficulty, knowledge_point, source, source_year, source_question_no, tags, images,
   title_text, analysis_text, content_format, has_image, has_code)
VALUES
  (5, 1, 100, NULL, 2, '', @tc42, 1, 1, b'0',
   '<div class="question-html-ref" data-src="question-html/2026/q42-title.html" data-fallback="（本题满分 10 分） 栈的基本操作有出栈和入栈。将序列 1 , 2 , 3 , … , n 依次入栈，回答下列问题： (1) 当 n = 9 时，可以得到出栈序列 { 2 , 3 , 1 , 6 , 4 , 7 , 5 , 8 } 吗？可以得到出栈序列 { 2 , 3 , 1 , 4 , 6 , 5 , 7 , 8 "></div>', '[]', '', '<div class="question-html-ref" data-src="question-html/2026/q42-analysis.html" data-fallback="（1）当 n = 9 时，出栈序列的可能性分析 序列 { 2 , 3 , 1 , 6 , 4 , 7 , 5 , 8 } （假设包含 9 ，即 { 2 , 3 , 1 , 6 , 4 , 7 , 5 , 8 , 9 } ）： 存在下标 i = 4 , j = 5 , k = 7 ，满足 P j ​ = 4 &lt; P k "></div>',
   2, NULL, '2026年408模拟题', 2026, 42, 'html,external_html,code,katex', '',
   '（本题满分 10 分） 栈的基本操作有出栈和入栈。将序列 1 , 2 , 3 , … , n 依次入栈，回答下列问题： (1) 当 n = 9 时，可以得到出栈序列 { 2 , 3 , 1 , 6 , 4 , 7 , 5 , 8 } 吗？可以得到出栈序列 { 2 , 3 , 1 , 4 , 6 , 5 , 7 , 8 } 吗？（2 分） (2) 假设 1 , 2 , … , n 组成任意序列的出栈序列 P 1 ​ , P 2 ​ , … , P n ​ ，在序列中有 P i ​ 、 P j ​ 、 P k ​ （ i < j < k ），若该出栈序列不能由栈得到，则 P i ​ 、 P j ​ 、 P k ​ 的大小关系是？（2 分） (3) 若 n = 4 ，则以 2 开头的序列个数有多少个？（2 分） (4) 若 n = k − 1 时，出栈序列总共共有 M 个，如果 n = k ，那么以 1 开头的出栈序列个数有多少个？以 2 开头的出栈序列有多少个？总共的出栈序列有多少个？（4 分）', '（1）当 n = 9 时，出栈序列的可能性分析 序列 { 2 , 3 , 1 , 6 , 4 , 7 , 5 , 8 } （假设包含 9 ，即 { 2 , 3 , 1 , 6 , 4 , 7 , 5 , 8 , 9 } ）： 存在下标 i = 4 , j = 5 , k = 7 ，满足 P j ​ = 4 < P k ​ = 5 < P i ​ = 6 ，即存在“312”模式，因此不能由栈得到。 序列 { 2 , 3 , 1 , 4 , 6 , 5 , 7 , 8 } （假设包含 9 ，即 { 2 , 3 , 1 , 4 , 6 , 5 , 7 , 8 , 9 } ）： 不存在任何三个下标 i < j < k 满足 P j ​ < P k ​ < P i ​ ，因此可以由栈得到。 答案 ：第一个序列不能得到，第二个序列可以得到。 （2）不能由栈得到的出栈序列中 P i ​ , P j ​ , P k ​ 的大小关系 若出栈序列 P 1 ​ , P 2 ​ , … , P n ​ 不能由栈得到，则存在三个下标 i < j < k ，满足 P j ​ < P k ​ < P i ​ . 即第二个出栈的数最小，第三个出栈的数居中，第一个出栈的数最大。 答案 ： P j ​ < P k ​ < P i ​ . （3） n = 4 时以 2 开头的出栈序列个数 枚举所有以 2 开头的出栈序列： { 2 , 1 , 3 , 4 } , { 2 , 1 , 4 , 3 } , { 2 , 3 , 1 , 4 } , { 2 , 3 , 4 , 1 } , { 2 , 4 , 3 , 1 } . 共 5 个。 答案 ： 5 个。 （4） n = k 时，以 1 开头、以 2 开头的序列个数及总个数 已知当 n = k − 1 时，栈可得到的出栈序列总数为 C k − 1 ​ = M 其中 C n ​ 为第 n 个卡特兰数。 以 1 开头的出栈序列个数 若第一个出栈元素为 1，则只能是： push(1) → pop(1) 此后对 2 , 3 , … , k 的出栈过程不再受限制，其出栈序列个数等于 C k − 1 ​ = M 以 1 开头的出栈序列个数为 M。 以 2 开头的出栈序列个数 若第一个出栈元素为 2，则操作前缀必为： push(1), push(2), pop(2) 此时栈中剩余元素为 1，尚未处理的元素为 3 , 4 , … , k 。 在后续过程中，相当于在 栈底固定 1 的条件下，对 3 , 4 , … , k 进行出栈操作。 不加限制的总数为： C k − 1 ​ 其中 1 在 3 , … , k 之前出栈的情况非法，其个数为： C k − 2 ​ 故 合法序列个数 为： C k − 1 ​ − C k − 2 ​ 出栈序列总数 卡特兰数满足递推关系： C k ​ = k + 1 2 ( 2 k − 1 ) ​ C k − 1 ​ 由 (C_{k-1}=M)，得： C k ​ = k + 1 2 ( 2 k − 1 ) ​ M 所以 以 1 开头的出栈序列个数： M ​ 以 2 开头的出栈序列个数： C k − 1 ​ − C k − 2 ​ ​ 出栈序列总数： k + 1 2 ( 2 k − 1 ) ​ M ​', 'html', b'0', b'1');
SET @q42 = LAST_INSERT_ID();
INSERT INTO question_content
  (question_id, version, title, options, correct_answer, analysis, title_text, analysis_text, content_format, has_image, has_code, legacy_text_content_id, source_hash, is_current)
VALUES
  (@q42, 1, '<div class="question-html-ref" data-src="question-html/2026/q42-title.html" data-fallback="（本题满分 10 分） 栈的基本操作有出栈和入栈。将序列 1 , 2 , 3 , … , n 依次入栈，回答下列问题： (1) 当 n = 9 时，可以得到出栈序列 { 2 , 3 , 1 , 6 , 4 , 7 , 5 , 8 } 吗？可以得到出栈序列 { 2 , 3 , 1 , 4 , 6 , 5 , 7 , 8 "></div>', '[]', '', '<div class="question-html-ref" data-src="question-html/2026/q42-analysis.html" data-fallback="（1）当 n = 9 时，出栈序列的可能性分析 序列 { 2 , 3 , 1 , 6 , 4 , 7 , 5 , 8 } （假设包含 9 ，即 { 2 , 3 , 1 , 6 , 4 , 7 , 5 , 8 , 9 } ）： 存在下标 i = 4 , j = 5 , k = 7 ，满足 P j ​ = 4 &lt; P k "></div>',
   '（本题满分 10 分） 栈的基本操作有出栈和入栈。将序列 1 , 2 , 3 , … , n 依次入栈，回答下列问题： (1) 当 n = 9 时，可以得到出栈序列 { 2 , 3 , 1 , 6 , 4 , 7 , 5 , 8 } 吗？可以得到出栈序列 { 2 , 3 , 1 , 4 , 6 , 5 , 7 , 8 } 吗？（2 分） (2) 假设 1 , 2 , … , n 组成任意序列的出栈序列 P 1 ​ , P 2 ​ , … , P n ​ ，在序列中有 P i ​ 、 P j ​ 、 P k ​ （ i < j < k ），若该出栈序列不能由栈得到，则 P i ​ 、 P j ​ 、 P k ​ 的大小关系是？（2 分） (3) 若 n = 4 ，则以 2 开头的序列个数有多少个？（2 分） (4) 若 n = k − 1 时，出栈序列总共共有 M 个，如果 n = k ，那么以 1 开头的出栈序列个数有多少个？以 2 开头的出栈序列有多少个？总共的出栈序列有多少个？（4 分）', '（1）当 n = 9 时，出栈序列的可能性分析 序列 { 2 , 3 , 1 , 6 , 4 , 7 , 5 , 8 } （假设包含 9 ，即 { 2 , 3 , 1 , 6 , 4 , 7 , 5 , 8 , 9 } ）： 存在下标 i = 4 , j = 5 , k = 7 ，满足 P j ​ = 4 < P k ​ = 5 < P i ​ = 6 ，即存在“312”模式，因此不能由栈得到。 序列 { 2 , 3 , 1 , 4 , 6 , 5 , 7 , 8 } （假设包含 9 ，即 { 2 , 3 , 1 , 4 , 6 , 5 , 7 , 8 , 9 } ）： 不存在任何三个下标 i < j < k 满足 P j ​ < P k ​ < P i ​ ，因此可以由栈得到。 答案 ：第一个序列不能得到，第二个序列可以得到。 （2）不能由栈得到的出栈序列中 P i ​ , P j ​ , P k ​ 的大小关系 若出栈序列 P 1 ​ , P 2 ​ , … , P n ​ 不能由栈得到，则存在三个下标 i < j < k ，满足 P j ​ < P k ​ < P i ​ . 即第二个出栈的数最小，第三个出栈的数居中，第一个出栈的数最大。 答案 ： P j ​ < P k ​ < P i ​ . （3） n = 4 时以 2 开头的出栈序列个数 枚举所有以 2 开头的出栈序列： { 2 , 1 , 3 , 4 } , { 2 , 1 , 4 , 3 } , { 2 , 3 , 1 , 4 } , { 2 , 3 , 4 , 1 } , { 2 , 4 , 3 , 1 } . 共 5 个。 答案 ： 5 个。 （4） n = k 时，以 1 开头、以 2 开头的序列个数及总个数 已知当 n = k − 1 时，栈可得到的出栈序列总数为 C k − 1 ​ = M 其中 C n ​ 为第 n 个卡特兰数。 以 1 开头的出栈序列个数 若第一个出栈元素为 1，则只能是： push(1) → pop(1) 此后对 2 , 3 , … , k 的出栈过程不再受限制，其出栈序列个数等于 C k − 1 ​ = M 以 1 开头的出栈序列个数为 M。 以 2 开头的出栈序列个数 若第一个出栈元素为 2，则操作前缀必为： push(1), push(2), pop(2) 此时栈中剩余元素为 1，尚未处理的元素为 3 , 4 , … , k 。 在后续过程中，相当于在 栈底固定 1 的条件下，对 3 , 4 , … , k 进行出栈操作。 不加限制的总数为： C k − 1 ​ 其中 1 在 3 , … , k 之前出栈的情况非法，其个数为： C k − 2 ​ 故 合法序列个数 为： C k − 1 ​ − C k − 2 ​ 出栈序列总数 卡特兰数满足递推关系： C k ​ = k + 1 2 ( 2 k − 1 ) ​ C k − 1 ​ 由 (C_{k-1}=M)，得： C k ​ = k + 1 2 ( 2 k − 1 ) ​ M 所以 以 1 开头的出栈序列个数： M ​ 以 2 开头的出栈序列个数： C k − 1 ​ − C k − 2 ​ ​ 出栈序列总数： k + 1 2 ( 2 k − 1 ) ​ M ​', 'html', b'0', b'1', @tc42, 'a37e1d9f972b6d7f97920fecd80f0f7d653bb7c875494ca79fb3875fbbf47267', b'1');
INSERT INTO question_source
  (question_id, source_type, source_name, source_year, source_question_no, paper_name, raw_ref, metadata)
VALUES
  (@q42, 'crawler_html', '计算机考研杂货铺', 2026, '42', '2026年408计算机学科专业基础综合模拟试题',
   'C:/Users/wutia/Downloads/csgraduates2026.html', '{"subject": "数据结构", "html": true}');

-- Q43
INSERT INTO t_text_content (content, create_time)
VALUES ('{"titleContent": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q43-title.html\\" data-fallback=\\"（本题满分 10 分） 某 16 位计算机按字节编址，通用寄存器 R0～R15 的编号为 0～15，存储器地址为 16 位，采用定长指令字，指令格式有 R 型、I 型、M 型三种，如下表所示。 计算机考研杂货铺 R 型 0000 rt rs/num op1 R[rt] ← R[rt] op1 R[rs] R[rt] ←\\"></div>", "analyze": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q43-analysis.html\\" data-fallback=\\"(1) 主存单元和通用寄存器的宽度 该计算机是 按字节编址 → 所以主存单元存储的是字节即 8 位 通用寄存器 R 0 ∼ R 15 用于参与算术、移位、访存等运算， 且指令中的运算（如加法、移位、取数/存数）都是以“字”为基本操作单位 → 寄存器必须能容纳一个完整的字。 结论： 主存单元宽度：8 位 通用寄存器宽度：\\"></div>", "questionItemObjects": []}', NOW());
SET @tc43 = LAST_INSERT_ID();
INSERT INTO t_question
  (question_type, subject_id, score, grade_level, difficult, correct, info_text_content_id, create_user, status, deleted,
   title, options, correct_answer, analysis, difficulty, knowledge_point, source, source_year, source_question_no, tags, images,
   title_text, analysis_text, content_format, has_image, has_code)
VALUES
  (5, 2, 100, NULL, 2, '', @tc43, 1, 1, b'0',
   '<div class="question-html-ref" data-src="question-html/2026/q43-title.html" data-fallback="（本题满分 10 分） 某 16 位计算机按字节编址，通用寄存器 R0～R15 的编号为 0～15，存储器地址为 16 位，采用定长指令字，指令格式有 R 型、I 型、M 型三种，如下表所示。 计算机考研杂货铺 R 型 0000 rt rs/num op1 R[rt] ← R[rt] op1 R[rs] R[rt] ←"></div>', '[]', '', '<div class="question-html-ref" data-src="question-html/2026/q43-analysis.html" data-fallback="(1) 主存单元和通用寄存器的宽度 该计算机是 按字节编址 → 所以主存单元存储的是字节即 8 位 通用寄存器 R 0 ∼ R 15 用于参与算术、移位、访存等运算， 且指令中的运算（如加法、移位、取数/存数）都是以“字”为基本操作单位 → 寄存器必须能容纳一个完整的字。 结论： 主存单元宽度：8 位 通用寄存器宽度："></div>',
   2, NULL, '2026年408模拟题', 2026, 43, 'html,external_html,code,table,katex', '',
   '（本题满分 10 分） 某 16 位计算机按字节编址，通用寄存器 R0～R15 的编号为 0～15，存储器地址为 16 位，采用定长指令字，指令格式有 R 型、I 型、M 型三种，如下表所示。 计算机考研杂货铺 R 型 0000 rt rs/num op1 R[rt] ← R[rt] op1 R[rs] R[rt] ← R[rt] op1 num I 型 op2 rt imm8 R[rt] ← R[rt] op2 imm8 M 型 op3 offset R[0] ← M[R[15] + offset] M[R[15] + offset] ← R[0] 格式 4 位 4 位 4 位 4 位 功能说明 其中： OP1 为 0001、0010 分别表示加、左移指令； OP2 为 0100 表示加立即数指令； OP3 为 1110、1111 分别表示取数、存数指令； R[r] 表示寄存器 r 中的内容； mm 表示移位位数； M[addr] 表示存储器地址 addr 中的内容。 请回答下列问题： (1) 主存单元和通用寄存器的宽度各为多少位？（2 分） (2) op1 和 op2 的编码是否可以相同？op2 和 op3 的编码是否可以相同？（2 分） (3) 若 R(2)=ABCDH，R(9)=F00H1，则指令 0000 0010 1001 0001 执行后，R2 和 R9 中的内容分别是多少？（2 分） (4) 若变量 x 、 y 均为 16 位带符号整数，在存储器中依次从低地址向高地址连续存放， x 的地址在 R15 中。实现 y = 16 x − 5 的 4 条指令 11–14 如题 43 表所示，写出 ①～④ 处的内容。（4 分） 题 43 表： 地址 内容 11 1 ​ 0000 0000 0000 12 0000 2 ​ 0010 13 0100 0000 3 ​ 14 1111 4 ​', '(1) 主存单元和通用寄存器的宽度 该计算机是 按字节编址 → 所以主存单元存储的是字节即 8 位 通用寄存器 R 0 ∼ R 15 用于参与算术、移位、访存等运算， 且指令中的运算（如加法、移位、取数/存数）都是以“字”为基本操作单位 → 寄存器必须能容纳一个完整的字。 结论： 主存单元宽度：8 位 通用寄存器宽度：16 位 (2) op1 和 op2 可以相同 ，因为两者在指令中占据不同位。op2 和 op3 不能相同 ，因为两者在指令中占据相同位，若相同会导致指令冲突。 (3) 0000 0010 1001 0001 属于 R 型指令，下表中给出了每个字段的具体含义： 字段 1 字段 2 字段 3 字段 4 0000 0010 1001 0001 R 型指令前缀 目标寄存器为 R[2] 源寄存器为 R[9] op 字段为加 所以这个指令的实际含义为： R[2] ← R[2] + R[9] R[2] = ABCDH + F001H = 9BCEH 所以 R2 中的内容变为 98CEH ，R9 中的内容保持不变为 F001H 。 (4) y = x * 16 需要通过四个步骤得到： 从 x 的地址中获取 x 的值：通过取数指令 通过移位指令实现 x * 16 的乘法操作 通过减法指令实现 - 5 的操作 将 x * 16 - 5 的值存储到 y 中：通过存数指令 所以四条指令的二进制如下： R[0] ← M[R[15]] ： 1110 0000 0000 0000 R[0] ← R[0] << 4 : 0000 0000 0100 0010 R[0] ← R[0] + (-5) ： 0100 0000 1111 1011 M[R[15] + 2] ← R[0] : 1111 0000 0000 0010 所以 ① = 1110，② = 0000 0100，③ = 1111 1011，④ = 0000 0000 0010。', 'html', b'0', b'1');
SET @q43 = LAST_INSERT_ID();
INSERT INTO question_content
  (question_id, version, title, options, correct_answer, analysis, title_text, analysis_text, content_format, has_image, has_code, legacy_text_content_id, source_hash, is_current)
VALUES
  (@q43, 1, '<div class="question-html-ref" data-src="question-html/2026/q43-title.html" data-fallback="（本题满分 10 分） 某 16 位计算机按字节编址，通用寄存器 R0～R15 的编号为 0～15，存储器地址为 16 位，采用定长指令字，指令格式有 R 型、I 型、M 型三种，如下表所示。 计算机考研杂货铺 R 型 0000 rt rs/num op1 R[rt] ← R[rt] op1 R[rs] R[rt] ←"></div>', '[]', '', '<div class="question-html-ref" data-src="question-html/2026/q43-analysis.html" data-fallback="(1) 主存单元和通用寄存器的宽度 该计算机是 按字节编址 → 所以主存单元存储的是字节即 8 位 通用寄存器 R 0 ∼ R 15 用于参与算术、移位、访存等运算， 且指令中的运算（如加法、移位、取数/存数）都是以“字”为基本操作单位 → 寄存器必须能容纳一个完整的字。 结论： 主存单元宽度：8 位 通用寄存器宽度："></div>',
   '（本题满分 10 分） 某 16 位计算机按字节编址，通用寄存器 R0～R15 的编号为 0～15，存储器地址为 16 位，采用定长指令字，指令格式有 R 型、I 型、M 型三种，如下表所示。 计算机考研杂货铺 R 型 0000 rt rs/num op1 R[rt] ← R[rt] op1 R[rs] R[rt] ← R[rt] op1 num I 型 op2 rt imm8 R[rt] ← R[rt] op2 imm8 M 型 op3 offset R[0] ← M[R[15] + offset] M[R[15] + offset] ← R[0] 格式 4 位 4 位 4 位 4 位 功能说明 其中： OP1 为 0001、0010 分别表示加、左移指令； OP2 为 0100 表示加立即数指令； OP3 为 1110、1111 分别表示取数、存数指令； R[r] 表示寄存器 r 中的内容； mm 表示移位位数； M[addr] 表示存储器地址 addr 中的内容。 请回答下列问题： (1) 主存单元和通用寄存器的宽度各为多少位？（2 分） (2) op1 和 op2 的编码是否可以相同？op2 和 op3 的编码是否可以相同？（2 分） (3) 若 R(2)=ABCDH，R(9)=F00H1，则指令 0000 0010 1001 0001 执行后，R2 和 R9 中的内容分别是多少？（2 分） (4) 若变量 x 、 y 均为 16 位带符号整数，在存储器中依次从低地址向高地址连续存放， x 的地址在 R15 中。实现 y = 16 x − 5 的 4 条指令 11–14 如题 43 表所示，写出 ①～④ 处的内容。（4 分） 题 43 表： 地址 内容 11 1 ​ 0000 0000 0000 12 0000 2 ​ 0010 13 0100 0000 3 ​ 14 1111 4 ​', '(1) 主存单元和通用寄存器的宽度 该计算机是 按字节编址 → 所以主存单元存储的是字节即 8 位 通用寄存器 R 0 ∼ R 15 用于参与算术、移位、访存等运算， 且指令中的运算（如加法、移位、取数/存数）都是以“字”为基本操作单位 → 寄存器必须能容纳一个完整的字。 结论： 主存单元宽度：8 位 通用寄存器宽度：16 位 (2) op1 和 op2 可以相同 ，因为两者在指令中占据不同位。op2 和 op3 不能相同 ，因为两者在指令中占据相同位，若相同会导致指令冲突。 (3) 0000 0010 1001 0001 属于 R 型指令，下表中给出了每个字段的具体含义： 字段 1 字段 2 字段 3 字段 4 0000 0010 1001 0001 R 型指令前缀 目标寄存器为 R[2] 源寄存器为 R[9] op 字段为加 所以这个指令的实际含义为： R[2] ← R[2] + R[9] R[2] = ABCDH + F001H = 9BCEH 所以 R2 中的内容变为 98CEH ，R9 中的内容保持不变为 F001H 。 (4) y = x * 16 需要通过四个步骤得到： 从 x 的地址中获取 x 的值：通过取数指令 通过移位指令实现 x * 16 的乘法操作 通过减法指令实现 - 5 的操作 将 x * 16 - 5 的值存储到 y 中：通过存数指令 所以四条指令的二进制如下： R[0] ← M[R[15]] ： 1110 0000 0000 0000 R[0] ← R[0] << 4 : 0000 0000 0100 0010 R[0] ← R[0] + (-5) ： 0100 0000 1111 1011 M[R[15] + 2] ← R[0] : 1111 0000 0000 0010 所以 ① = 1110，② = 0000 0100，③ = 1111 1011，④ = 0000 0000 0010。', 'html', b'0', b'1', @tc43, 'ea3405eaeff28382c6c586632bf982470859d6d5a69596b83ba1649fae3226a8', b'1');
INSERT INTO question_source
  (question_id, source_type, source_name, source_year, source_question_no, paper_name, raw_ref, metadata)
VALUES
  (@q43, 'crawler_html', '计算机考研杂货铺', 2026, '43', '2026年408计算机学科专业基础综合模拟试题',
   'C:/Users/wutia/Downloads/csgraduates2026.html', '{"subject": "组成原理", "html": true}');

-- Q44
INSERT INTO t_text_content (content, create_time)
VALUES ('{"titleContent": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q44-title.html\\" data-fallback=\\"（本题满分 15 分） 假定 43 题中计算机 C 的部分数据通路如题 44 所示。 计算机考研杂货铺 GPRs 通用寄存器组 Ra Rb M U X M U X 0 1 0 1 2 A B A L U PC MDR M U X 0 1 ARLA Src ALUB Src PCin 1 0 ALUCtr IR bus \\"></div>", "analyze": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q44-analysis.html\\" data-fallback=\\"(1) 多路选择器 R 型指令需要用到寄存器编号 rs 和 rt，M 型指令需要用到寄存器 0 和 15，所以需要通过二路选择器进行选择。 (2) 只需要 1 位 ，因为只需要 1 位就可以实现零扩展和符号扩展这两种操作。 (3) 先解释各个控制信号的含义： 信号 本质问题 MARSrC 访问内存的地址来自 PC 还是\\"></div>", "questionItemObjects": []}', NOW());
SET @tc44 = LAST_INSERT_ID();
INSERT INTO t_question
  (question_type, subject_id, score, grade_level, difficult, correct, info_text_content_id, create_user, status, deleted,
   title, options, correct_answer, analysis, difficulty, knowledge_point, source, source_year, source_question_no, tags, images,
   title_text, analysis_text, content_format, has_image, has_code)
VALUES
  (5, 2, 150, NULL, 2, '', @tc44, 1, 1, b'0',
   '<div class="question-html-ref" data-src="question-html/2026/q44-title.html" data-fallback="（本题满分 15 分） 假定 43 题中计算机 C 的部分数据通路如题 44 所示。 计算机考研杂货铺 GPRs 通用寄存器组 Ra Rb M U X M U X 0 1 0 1 2 A B A L U PC MDR M U X 0 1 ARLA Src ALUB Src PCin 1 0 ALUCtr IR bus "></div>', '[]', '', '<div class="question-html-ref" data-src="question-html/2026/q44-analysis.html" data-fallback="(1) 多路选择器 R 型指令需要用到寄存器编号 rs 和 rt，M 型指令需要用到寄存器 0 和 15，所以需要通过二路选择器进行选择。 (2) 只需要 1 位 ，因为只需要 1 位就可以实现零扩展和符号扩展这两种操作。 (3) 先解释各个控制信号的含义： 信号 本质问题 MARSrC 访问内存的地址来自 PC 还是"></div>',
   2, NULL, '2026年408模拟题', 2026, 44, 'html,external_html,table', '',
   '（本题满分 15 分） 假定 43 题中计算机 C 的部分数据通路如题 44 所示。 计算机考研杂货铺 GPRs 通用寄存器组 Ra Rb M U X M U X 0 1 0 1 2 A B A L U PC MDR M U X 0 1 ARLA Src ALUB Src PCin 1 0 ALUCtr IR bus A bus B M U X MAR MAR Src RegWr Regwsrc 扩展器 ExtOp 1 2 IR.rt IR11-0 12 16 CU 主 存 储 器 2 15 IR.rs 0 M U X 0 1 RegDst IR.rt 0 ABus CBus IRin 控制信号 图中带箭头虚线代表控制信号，IR.rt、IR.rs 分别表示 IR 中的 rt、rs 字段，IR₁₁₋₀ 为 IR 的低 12 位，要求取指令周期完成 PC 增量操作，请回答下列问题 （1）①和②是同一类部件，其名称是什么（1 分） （2）I 型指令中 imm8 可以是带符号或无符号整数，M 型指令中 offset 是带符号整数，则 EXTOP 至少有几位？为什么？（2 分） （3）取指周期中 MARSrC、ALUA SrC、ALUB SrC、RegWr 的取值各是什么？（4 分） （4）左移指令周期中 ALUB SrC、RegWsrc、RegDst、RegWr 的取值各是什么？Extop 是否可以与 M 型指令中的 EXTop 相同？为什么？（2 分）', '(1) 多路选择器 R 型指令需要用到寄存器编号 rs 和 rt，M 型指令需要用到寄存器 0 和 15，所以需要通过二路选择器进行选择。 (2) 只需要 1 位 ，因为只需要 1 位就可以实现零扩展和符号扩展这两种操作。 (3) 先解释各个控制信号的含义： 信号 本质问题 MARSrC 访问内存的地址来自 PC 还是 ALU ALUASrC ALU 的 A 端用 PC 还是寄存器 ALUBSrC ALU 的 B 端用 Rb / 常数 / 立即数 RegWr 要不要写寄存器 RegWsrc 写回数据来自 ALU 还是 MDR RegDst 写哪个寄存器 2R 指令分阶段送给控制器 在取指阶段需要读取 PC 地址的指令内容，并且要计算 PC=PC+2 获取下一条指令的地址，不涉及到通用寄存器的写入。 所以 MARSrc=0, ALUA Src=0, ALUB Src=1, RegWr = 0 (4) 左移指令需要通过扩展器获取到左移的立即数，所以 ALUB Src=2，计算结果通过 ALU 写回到通用寄存器中，所以 RegWSrc=1，RegWr=1，写入的寄存器位 R[rt]，所以 RegDst=1。 综上： ALUB Src=2, RegWSrc=1, RegDst=1, RegWr=1', 'html', b'0', b'0');
SET @q44 = LAST_INSERT_ID();
INSERT INTO question_content
  (question_id, version, title, options, correct_answer, analysis, title_text, analysis_text, content_format, has_image, has_code, legacy_text_content_id, source_hash, is_current)
VALUES
  (@q44, 1, '<div class="question-html-ref" data-src="question-html/2026/q44-title.html" data-fallback="（本题满分 15 分） 假定 43 题中计算机 C 的部分数据通路如题 44 所示。 计算机考研杂货铺 GPRs 通用寄存器组 Ra Rb M U X M U X 0 1 0 1 2 A B A L U PC MDR M U X 0 1 ARLA Src ALUB Src PCin 1 0 ALUCtr IR bus "></div>', '[]', '', '<div class="question-html-ref" data-src="question-html/2026/q44-analysis.html" data-fallback="(1) 多路选择器 R 型指令需要用到寄存器编号 rs 和 rt，M 型指令需要用到寄存器 0 和 15，所以需要通过二路选择器进行选择。 (2) 只需要 1 位 ，因为只需要 1 位就可以实现零扩展和符号扩展这两种操作。 (3) 先解释各个控制信号的含义： 信号 本质问题 MARSrC 访问内存的地址来自 PC 还是"></div>',
   '（本题满分 15 分） 假定 43 题中计算机 C 的部分数据通路如题 44 所示。 计算机考研杂货铺 GPRs 通用寄存器组 Ra Rb M U X M U X 0 1 0 1 2 A B A L U PC MDR M U X 0 1 ARLA Src ALUB Src PCin 1 0 ALUCtr IR bus A bus B M U X MAR MAR Src RegWr Regwsrc 扩展器 ExtOp 1 2 IR.rt IR11-0 12 16 CU 主 存 储 器 2 15 IR.rs 0 M U X 0 1 RegDst IR.rt 0 ABus CBus IRin 控制信号 图中带箭头虚线代表控制信号，IR.rt、IR.rs 分别表示 IR 中的 rt、rs 字段，IR₁₁₋₀ 为 IR 的低 12 位，要求取指令周期完成 PC 增量操作，请回答下列问题 （1）①和②是同一类部件，其名称是什么（1 分） （2）I 型指令中 imm8 可以是带符号或无符号整数，M 型指令中 offset 是带符号整数，则 EXTOP 至少有几位？为什么？（2 分） （3）取指周期中 MARSrC、ALUA SrC、ALUB SrC、RegWr 的取值各是什么？（4 分） （4）左移指令周期中 ALUB SrC、RegWsrc、RegDst、RegWr 的取值各是什么？Extop 是否可以与 M 型指令中的 EXTop 相同？为什么？（2 分）', '(1) 多路选择器 R 型指令需要用到寄存器编号 rs 和 rt，M 型指令需要用到寄存器 0 和 15，所以需要通过二路选择器进行选择。 (2) 只需要 1 位 ，因为只需要 1 位就可以实现零扩展和符号扩展这两种操作。 (3) 先解释各个控制信号的含义： 信号 本质问题 MARSrC 访问内存的地址来自 PC 还是 ALU ALUASrC ALU 的 A 端用 PC 还是寄存器 ALUBSrC ALU 的 B 端用 Rb / 常数 / 立即数 RegWr 要不要写寄存器 RegWsrc 写回数据来自 ALU 还是 MDR RegDst 写哪个寄存器 2R 指令分阶段送给控制器 在取指阶段需要读取 PC 地址的指令内容，并且要计算 PC=PC+2 获取下一条指令的地址，不涉及到通用寄存器的写入。 所以 MARSrc=0, ALUA Src=0, ALUB Src=1, RegWr = 0 (4) 左移指令需要通过扩展器获取到左移的立即数，所以 ALUB Src=2，计算结果通过 ALU 写回到通用寄存器中，所以 RegWSrc=1，RegWr=1，写入的寄存器位 R[rt]，所以 RegDst=1。 综上： ALUB Src=2, RegWSrc=1, RegDst=1, RegWr=1', 'html', b'0', b'0', @tc44, 'e7697a9070f2e669b2229f04b029b688ac56b2dd4522943bc31e3d051fa3ff23', b'1');
INSERT INTO question_source
  (question_id, source_type, source_name, source_year, source_question_no, paper_name, raw_ref, metadata)
VALUES
  (@q44, 'crawler_html', '计算机考研杂货铺', 2026, '44', '2026年408计算机学科专业基础综合模拟试题',
   'C:/Users/wutia/Downloads/csgraduates2026.html', '{"subject": "组成原理", "html": true}');

-- Q45
INSERT INTO t_text_content (content, create_time)
VALUES ('{"titleContent": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q45-title.html\\" data-fallback=\\"（本题满分 7 分） 系统采用优先级（优先级越大表示优先级越高）与时间片轮转调度算法，仅当发生时钟中断时才触发抢占 CPU 操作，时钟中断间隔为 10 ms。进程首次进入就绪队列时，其时间片为 50 ms。若进程因时间片用完而返回就绪队列，其优先级值减 1；若进程被更高优先级进程抢占而返回就绪队列，其优先级值保持不变。\\"></div>", "analyze": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q45-analysis.html\\" data-fallback=\\"（1）中断次数、CPU 调度次数与各进程首次调度时刻 模拟调度过程，考虑时钟中断每 10 ms 发生一次，进程到达、完成及调度事件如下： 10 ms ：P1、P2 到达，CPU 空闲，调度 P2 运行（首次调度）。 20 ms ：时钟中断，P2 运行 10 ms 后被更高优先级的 P4 抢占，调度 P4 运行（首次调度\\"></div>", "questionItemObjects": []}', NOW());
SET @tc45 = LAST_INSERT_ID();
INSERT INTO t_question
  (question_type, subject_id, score, grade_level, difficult, correct, info_text_content_id, create_user, status, deleted,
   title, options, correct_answer, analysis, difficulty, knowledge_point, source, source_year, source_question_no, tags, images,
   title_text, analysis_text, content_format, has_image, has_code)
VALUES
  (5, 3, 70, NULL, 2, '', @tc45, 1, 1, b'0',
   '<div class="question-html-ref" data-src="question-html/2026/q45-title.html" data-fallback="（本题满分 7 分） 系统采用优先级（优先级越大表示优先级越高）与时间片轮转调度算法，仅当发生时钟中断时才触发抢占 CPU 操作，时钟中断间隔为 10 ms。进程首次进入就绪队列时，其时间片为 50 ms。若进程因时间片用完而返回就绪队列，其优先级值减 1；若进程被更高优先级进程抢占而返回就绪队列，其优先级值保持不变。"></div>', '[]', '', '<div class="question-html-ref" data-src="question-html/2026/q45-analysis.html" data-fallback="（1）中断次数、CPU 调度次数与各进程首次调度时刻 模拟调度过程，考虑时钟中断每 10 ms 发生一次，进程到达、完成及调度事件如下： 10 ms ：P1、P2 到达，CPU 空闲，调度 P2 运行（首次调度）。 20 ms ：时钟中断，P2 运行 10 ms 后被更高优先级的 P4 抢占，调度 P4 运行（首次调度"></div>',
   2, NULL, '2026年408模拟题', 2026, 45, 'html,external_html,table', '',
   '（本题满分 7 分） 系统采用优先级（优先级越大表示优先级越高）与时间片轮转调度算法，仅当发生时钟中断时才触发抢占 CPU 操作，时钟中断间隔为 10 ms。进程首次进入就绪队列时，其时间片为 50 ms。若进程因时间片用完而返回就绪队列，其优先级值减 1；若进程被更高优先级进程抢占而返回就绪队列，其优先级值保持不变。当多个进程优先级相同时，先进入就绪队列的进程优先被调度。四个进程的到达时刻、初始优先级与 CPU 运行时间如下表所示： 进程 到达就绪队列时间（ms） 优先级 CPU 运行时间（ms） P1 10 3 95 P2 10 4 20 P3 12 2 40 P4 14 5 60 （1）从 10 ms 开始进程调度，直至所有进程调度结束，此时中断次数与 CPU 调度次数分别为多少？P1、P2、P3、P4 各自的首次调度发生在哪个时刻？（5 分） （2）若时间片由 50 ms 改为 100 ms，CPU 调度次数将增大、不变还是减少？若时钟中断间隔由 10 ms 改为 1 ms，系统开销将增大、不变还是减少？（2 分）', '（1）中断次数、CPU 调度次数与各进程首次调度时刻 模拟调度过程，考虑时钟中断每 10 ms 发生一次，进程到达、完成及调度事件如下： 10 ms ：P1、P2 到达，CPU 空闲，调度 P2 运行（首次调度）。 20 ms ：时钟中断，P2 运行 10 ms 后被更高优先级的 P4 抢占，调度 P4 运行（首次调度）。 70 ms ：时钟中断，P4 时间片用完，优先级减 1，调度 P2 运行。 80 ms ：时钟中断，P2 完成，调度 P4 运行。 90 ms ：时钟中断，P4 完成，调度 P1 运行（首次调度）。 140 ms ：时钟中断，P1 时间片用完，优先级减 1，调度 P3 运行（首次调度）。 180 ms ：时钟中断，P3 完成，调度 P1 运行。 225 ms ：P1 完成，所有进程结束。 中断次数 ：从 10 ms 开始，时钟中断时刻为 10, 20, …, 220 ms，共 22 次。 CPU 调度次数 ：共 7 次（10 ms、20 ms、70 ms、80 ms、90 ms、140 ms、180 ms）。 首次调度时刻 ： P1:90 ms P2:10 ms P3:140 ms P4:20 ms （2）参数变化的影响 时间片由 50 ms 改为 100 ms ：时间片增大，进程因时间片用完而让出 CPU 的次数减少，更多进程可能一次运行完成，从而降低进程切换频率，CPU 调度次数减少。 时钟中断间隔由 10 ms 改为 1 ms ：中断更频繁，每次中断均需进行调度检查，可能增加上下文切换次数与中断处理时间，系统开销增大。', 'html', b'0', b'0');
SET @q45 = LAST_INSERT_ID();
INSERT INTO question_content
  (question_id, version, title, options, correct_answer, analysis, title_text, analysis_text, content_format, has_image, has_code, legacy_text_content_id, source_hash, is_current)
VALUES
  (@q45, 1, '<div class="question-html-ref" data-src="question-html/2026/q45-title.html" data-fallback="（本题满分 7 分） 系统采用优先级（优先级越大表示优先级越高）与时间片轮转调度算法，仅当发生时钟中断时才触发抢占 CPU 操作，时钟中断间隔为 10 ms。进程首次进入就绪队列时，其时间片为 50 ms。若进程因时间片用完而返回就绪队列，其优先级值减 1；若进程被更高优先级进程抢占而返回就绪队列，其优先级值保持不变。"></div>', '[]', '', '<div class="question-html-ref" data-src="question-html/2026/q45-analysis.html" data-fallback="（1）中断次数、CPU 调度次数与各进程首次调度时刻 模拟调度过程，考虑时钟中断每 10 ms 发生一次，进程到达、完成及调度事件如下： 10 ms ：P1、P2 到达，CPU 空闲，调度 P2 运行（首次调度）。 20 ms ：时钟中断，P2 运行 10 ms 后被更高优先级的 P4 抢占，调度 P4 运行（首次调度"></div>',
   '（本题满分 7 分） 系统采用优先级（优先级越大表示优先级越高）与时间片轮转调度算法，仅当发生时钟中断时才触发抢占 CPU 操作，时钟中断间隔为 10 ms。进程首次进入就绪队列时，其时间片为 50 ms。若进程因时间片用完而返回就绪队列，其优先级值减 1；若进程被更高优先级进程抢占而返回就绪队列，其优先级值保持不变。当多个进程优先级相同时，先进入就绪队列的进程优先被调度。四个进程的到达时刻、初始优先级与 CPU 运行时间如下表所示： 进程 到达就绪队列时间（ms） 优先级 CPU 运行时间（ms） P1 10 3 95 P2 10 4 20 P3 12 2 40 P4 14 5 60 （1）从 10 ms 开始进程调度，直至所有进程调度结束，此时中断次数与 CPU 调度次数分别为多少？P1、P2、P3、P4 各自的首次调度发生在哪个时刻？（5 分） （2）若时间片由 50 ms 改为 100 ms，CPU 调度次数将增大、不变还是减少？若时钟中断间隔由 10 ms 改为 1 ms，系统开销将增大、不变还是减少？（2 分）', '（1）中断次数、CPU 调度次数与各进程首次调度时刻 模拟调度过程，考虑时钟中断每 10 ms 发生一次，进程到达、完成及调度事件如下： 10 ms ：P1、P2 到达，CPU 空闲，调度 P2 运行（首次调度）。 20 ms ：时钟中断，P2 运行 10 ms 后被更高优先级的 P4 抢占，调度 P4 运行（首次调度）。 70 ms ：时钟中断，P4 时间片用完，优先级减 1，调度 P2 运行。 80 ms ：时钟中断，P2 完成，调度 P4 运行。 90 ms ：时钟中断，P4 完成，调度 P1 运行（首次调度）。 140 ms ：时钟中断，P1 时间片用完，优先级减 1，调度 P3 运行（首次调度）。 180 ms ：时钟中断，P3 完成，调度 P1 运行。 225 ms ：P1 完成，所有进程结束。 中断次数 ：从 10 ms 开始，时钟中断时刻为 10, 20, …, 220 ms，共 22 次。 CPU 调度次数 ：共 7 次（10 ms、20 ms、70 ms、80 ms、90 ms、140 ms、180 ms）。 首次调度时刻 ： P1:90 ms P2:10 ms P3:140 ms P4:20 ms （2）参数变化的影响 时间片由 50 ms 改为 100 ms ：时间片增大，进程因时间片用完而让出 CPU 的次数减少，更多进程可能一次运行完成，从而降低进程切换频率，CPU 调度次数减少。 时钟中断间隔由 10 ms 改为 1 ms ：中断更频繁，每次中断均需进行调度检查，可能增加上下文切换次数与中断处理时间，系统开销增大。', 'html', b'0', b'0', @tc45, '7a4c092812a38c70ce91b8318ecb57dd90b37718e5d8450419d629aed62c625e', b'1');
INSERT INTO question_source
  (question_id, source_type, source_name, source_year, source_question_no, paper_name, raw_ref, metadata)
VALUES
  (@q45, 'crawler_html', '计算机考研杂货铺', 2026, '45', '2026年408计算机学科专业基础综合模拟试题',
   'C:/Users/wutia/Downloads/csgraduates2026.html', '{"subject": "操作系统", "html": true}');

-- Q46
INSERT INTO t_text_content (content, create_time)
VALUES ('{"titleContent": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q46-title.html\\" data-fallback=\\"（本题满分 8 分） 文件系统的目录项包括文件名和索引节点号。磁盘包含索引节点表、位图、目录、文件数据等元数据。若盘块大小为 4 KB，盘块号占 4 B，索引节点表存放了系统的所有文件，从 0 开始编号，存放在盘块号 100 开始连续的 4096 个盘块中。索引节点占用 128 B，包含直接地址项 5 个，一级间接地址\\"></div>", "analyze": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q46-analysis.html\\" data-fallback=\\"（1） 文件的索引节点所在盘块号： 盘块大小为 4 KB，索引节点占用 128 B，每个盘块可存放 4096 ÷ 128 = 32 个索引节点。 索引节点表从盘块号 100 开始，连续占用 4096 个盘块，索引节点从 0 开始编号。 对于索引节点号 1000，块内偏移为 1000 ÷ 32 = 31 （余 8），因此\\"></div>", "questionItemObjects": []}', NOW());
SET @tc46 = LAST_INSERT_ID();
INSERT INTO t_question
  (question_type, subject_id, score, grade_level, difficult, correct, info_text_content_id, create_user, status, deleted,
   title, options, correct_answer, analysis, difficulty, knowledge_point, source, source_year, source_question_no, tags, images,
   title_text, analysis_text, content_format, has_image, has_code)
VALUES
  (5, 3, 80, NULL, 2, '', @tc46, 1, 1, b'0',
   '<div class="question-html-ref" data-src="question-html/2026/q46-title.html" data-fallback="（本题满分 8 分） 文件系统的目录项包括文件名和索引节点号。磁盘包含索引节点表、位图、目录、文件数据等元数据。若盘块大小为 4 KB，盘块号占 4 B，索引节点表存放了系统的所有文件，从 0 开始编号，存放在盘块号 100 开始连续的 4096 个盘块中。索引节点占用 128 B，包含直接地址项 5 个，一级间接地址"></div>', '[]', '', '<div class="question-html-ref" data-src="question-html/2026/q46-analysis.html" data-fallback="（1） 文件的索引节点所在盘块号： 盘块大小为 4 KB，索引节点占用 128 B，每个盘块可存放 4096 ÷ 128 = 32 个索引节点。 索引节点表从盘块号 100 开始，连续占用 4096 个盘块，索引节点从 0 开始编号。 对于索引节点号 1000，块内偏移为 1000 ÷ 32 = 31 （余 8），因此"></div>',
   2, NULL, '2026年408模拟题', 2026, 46, 'html,external_html,katex', '',
   '（本题满分 8 分） 文件系统的目录项包括文件名和索引节点号。磁盘包含索引节点表、位图、目录、文件数据等元数据。若盘块大小为 4 KB，盘块号占 4 B，索引节点表存放了系统的所有文件，从 0 开始编号，存放在盘块号 100 开始连续的 4096 个盘块中。索引节点占用 128 B，包含直接地址项 5 个，一级间接地址项、二级间接地址项、三级间接地址项各 1 个。磁盘位示图和索引节点位示图分别记录磁盘和索引节点的使用情况，0 表示未使用，1 表示已使用。其中目录结构图与文件的索引节点表如下所示（此处假定图中信息已给出），file 文件占 30 KB。 计算机考研杂货铺 dir dir1 file 文件 索引节点号 dir 100 dir1 201 file 1000 （1）file 的索引节点所在的盘块号是多少？若 file 的索引节点已经读取到内存，要访问 file 文件中偏移地址 21460 的一个字节数据，则最多需要读多少个盘块？如果文件系统中有足够的磁盘空间，则最多可以存放多少个文件？（3 分） （2）如果要删除目录 dir1，则需要对元数据进行哪些操作？（5 分）', '（1） 文件的索引节点所在盘块号： 盘块大小为 4 KB，索引节点占用 128 B，每个盘块可存放 4096 ÷ 128 = 32 个索引节点。 索引节点表从盘块号 100 开始，连续占用 4096 个盘块，索引节点从 0 开始编号。 对于索引节点号 1000，块内偏移为 1000 ÷ 32 = 31 （余 8），因此 盘块号为 100 + 31 = 131 。 访问偏移地址 21460 的一个字节最多需要读的盘块数： 盘块大小为 4 KB，逻辑块号为 ⌊ 21460 ÷ 4096 ⌋ = 5 ，块内偏移为 21460 mod 4096 = 980 。 索引节点有 5 个直接地址项（对应逻辑块号 0～4），逻辑块号 5 需通过一级间接地址项访问。 索引节点已在内存，但一级间接块需从磁盘读取，再读取数据块，因此 最多需要读 2 个盘块 （一级间接块和数据块）。 最多可存放的文件数： 索引节点表占用 4096 个盘块，每个盘块含 32 个索引节点，因此索引节点总数为 4096 × 32 = 131072 。 每个文件（含目录）占用一个索引节点，故 最多可存放 131072 个文件 。 （2） 删除目录 dir1（非空）需递归删除其下文件 file，再删除自身，对元数据的操作包括： 删除文件 file： 根据 file 的索引节点（节点号 1000）释放其占用的所有数据块（包括直接块、间接块及间接块本身），在磁盘位示图中将对应位清零。 在索引节点位示图中将节点 1000 对应位清零。 修改 dir1 的目录数据块，删除 file 的目录项。 删除目录 dir1： 释放 dir1 目录文件占用的数据块（存放目录项的数据块），在磁盘位示图中将对应位清零。 在索引节点位示图中将 dir1 的索引节点（节点号 201）对应位清零。 修改父目录 dir 的目录数据块，删除 dir1 的目录项。', 'html', b'0', b'0');
SET @q46 = LAST_INSERT_ID();
INSERT INTO question_content
  (question_id, version, title, options, correct_answer, analysis, title_text, analysis_text, content_format, has_image, has_code, legacy_text_content_id, source_hash, is_current)
VALUES
  (@q46, 1, '<div class="question-html-ref" data-src="question-html/2026/q46-title.html" data-fallback="（本题满分 8 分） 文件系统的目录项包括文件名和索引节点号。磁盘包含索引节点表、位图、目录、文件数据等元数据。若盘块大小为 4 KB，盘块号占 4 B，索引节点表存放了系统的所有文件，从 0 开始编号，存放在盘块号 100 开始连续的 4096 个盘块中。索引节点占用 128 B，包含直接地址项 5 个，一级间接地址"></div>', '[]', '', '<div class="question-html-ref" data-src="question-html/2026/q46-analysis.html" data-fallback="（1） 文件的索引节点所在盘块号： 盘块大小为 4 KB，索引节点占用 128 B，每个盘块可存放 4096 ÷ 128 = 32 个索引节点。 索引节点表从盘块号 100 开始，连续占用 4096 个盘块，索引节点从 0 开始编号。 对于索引节点号 1000，块内偏移为 1000 ÷ 32 = 31 （余 8），因此"></div>',
   '（本题满分 8 分） 文件系统的目录项包括文件名和索引节点号。磁盘包含索引节点表、位图、目录、文件数据等元数据。若盘块大小为 4 KB，盘块号占 4 B，索引节点表存放了系统的所有文件，从 0 开始编号，存放在盘块号 100 开始连续的 4096 个盘块中。索引节点占用 128 B，包含直接地址项 5 个，一级间接地址项、二级间接地址项、三级间接地址项各 1 个。磁盘位示图和索引节点位示图分别记录磁盘和索引节点的使用情况，0 表示未使用，1 表示已使用。其中目录结构图与文件的索引节点表如下所示（此处假定图中信息已给出），file 文件占 30 KB。 计算机考研杂货铺 dir dir1 file 文件 索引节点号 dir 100 dir1 201 file 1000 （1）file 的索引节点所在的盘块号是多少？若 file 的索引节点已经读取到内存，要访问 file 文件中偏移地址 21460 的一个字节数据，则最多需要读多少个盘块？如果文件系统中有足够的磁盘空间，则最多可以存放多少个文件？（3 分） （2）如果要删除目录 dir1，则需要对元数据进行哪些操作？（5 分）', '（1） 文件的索引节点所在盘块号： 盘块大小为 4 KB，索引节点占用 128 B，每个盘块可存放 4096 ÷ 128 = 32 个索引节点。 索引节点表从盘块号 100 开始，连续占用 4096 个盘块，索引节点从 0 开始编号。 对于索引节点号 1000，块内偏移为 1000 ÷ 32 = 31 （余 8），因此 盘块号为 100 + 31 = 131 。 访问偏移地址 21460 的一个字节最多需要读的盘块数： 盘块大小为 4 KB，逻辑块号为 ⌊ 21460 ÷ 4096 ⌋ = 5 ，块内偏移为 21460 mod 4096 = 980 。 索引节点有 5 个直接地址项（对应逻辑块号 0～4），逻辑块号 5 需通过一级间接地址项访问。 索引节点已在内存，但一级间接块需从磁盘读取，再读取数据块，因此 最多需要读 2 个盘块 （一级间接块和数据块）。 最多可存放的文件数： 索引节点表占用 4096 个盘块，每个盘块含 32 个索引节点，因此索引节点总数为 4096 × 32 = 131072 。 每个文件（含目录）占用一个索引节点，故 最多可存放 131072 个文件 。 （2） 删除目录 dir1（非空）需递归删除其下文件 file，再删除自身，对元数据的操作包括： 删除文件 file： 根据 file 的索引节点（节点号 1000）释放其占用的所有数据块（包括直接块、间接块及间接块本身），在磁盘位示图中将对应位清零。 在索引节点位示图中将节点 1000 对应位清零。 修改 dir1 的目录数据块，删除 file 的目录项。 删除目录 dir1： 释放 dir1 目录文件占用的数据块（存放目录项的数据块），在磁盘位示图中将对应位清零。 在索引节点位示图中将 dir1 的索引节点（节点号 201）对应位清零。 修改父目录 dir 的目录数据块，删除 dir1 的目录项。', 'html', b'0', b'0', @tc46, '2804c866fefae6acf80d1965a9b413a00c2d502bd573957c4cb664b204ca4372', b'1');
INSERT INTO question_source
  (question_id, source_type, source_name, source_year, source_question_no, paper_name, raw_ref, metadata)
VALUES
  (@q46, 'crawler_html', '计算机考研杂货铺', 2026, '46', '2026年408计算机学科专业基础综合模拟试题',
   'C:/Users/wutia/Downloads/csgraduates2026.html', '{"subject": "操作系统", "html": true}');

-- Q47
INSERT INTO t_text_content (content, create_time)
VALUES ('{"titleContent": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q47-title.html\\" data-fallback=\\"（本题满分 9 分） 假设客户端 C 建立一条 TCP 连接，向服务器 Si 上传一个总长度为 2000 B 的计算任务描述文件。已知 C 的拥塞窗口初始阈值为 8 MSS，MSS = 500 B，Si 对收到的每个 TCP 段进行确认，且确认段不封装数据。接收窗口始终为 1000 B，RTT = 5 ms，C 建立连\\"></div>", "analyze": "<div class=\\"question-html-ref\\" data-src=\\"question-html/2026/q47-analysis.html\\" data-fallback=\\"（1）TCP 连接需要 三次握手 。C 收到的 SYN=1、ACK=1 的 TCP 段是第二次握手，其确认序号为 C 的初始序号加 1，即 1000 + 1 = 1001 。 （2）收到该确认段时，C 的拥塞窗口增加 1 MSS，从 2 MSS 增加到 3 MSS 即 1500B 。发送窗口取拥塞窗口和接收窗口的最小值\\"></div>", "questionItemObjects": []}', NOW());
SET @tc47 = LAST_INSERT_ID();
INSERT INTO t_question
  (question_type, subject_id, score, grade_level, difficult, correct, info_text_content_id, create_user, status, deleted,
   title, options, correct_answer, analysis, difficulty, knowledge_point, source, source_year, source_question_no, tags, images,
   title_text, analysis_text, content_format, has_image, has_code)
VALUES
  (5, 4, 90, NULL, 2, '', @tc47, 1, 1, b'0',
   '<div class="question-html-ref" data-src="question-html/2026/q47-title.html" data-fallback="（本题满分 9 分） 假设客户端 C 建立一条 TCP 连接，向服务器 Si 上传一个总长度为 2000 B 的计算任务描述文件。已知 C 的拥塞窗口初始阈值为 8 MSS，MSS = 500 B，Si 对收到的每个 TCP 段进行确认，且确认段不封装数据。接收窗口始终为 1000 B，RTT = 5 ms，C 建立连"></div>', '[]', '', '<div class="question-html-ref" data-src="question-html/2026/q47-analysis.html" data-fallback="（1）TCP 连接需要 三次握手 。C 收到的 SYN=1、ACK=1 的 TCP 段是第二次握手，其确认序号为 C 的初始序号加 1，即 1000 + 1 = 1001 。 （2）收到该确认段时，C 的拥塞窗口增加 1 MSS，从 2 MSS 增加到 3 MSS 即 1500B 。发送窗口取拥塞窗口和接收窗口的最小值"></div>',
   2, NULL, '2026年408模拟题', 2026, 47, 'html,external_html', '',
   '（本题满分 9 分） 假设客户端 C 建立一条 TCP 连接，向服务器 Si 上传一个总长度为 2000 B 的计算任务描述文件。已知 C 的拥塞窗口初始阈值为 8 MSS，MSS = 500 B，Si 对收到的每个 TCP 段进行确认，且确认段不封装数据。接收窗口始终为 1000 B，RTT = 5 ms，C 建立连接时选择的初始序号为 1000，Si 选择的初始序号为 2000，SYN、ACK、FIN 为标志位，seq 为序号，ack_seq 为确认序号。在整个文件传输过程中未出现任何重传或报文丢失。 计算机考研杂货铺 计算机考研杂货铺 计算机考研杂货铺 计算机考研杂货铺 算力调度平台 S1 Sn C 计算机考研杂货铺 Si （1）C 与 Si 建立 TCP 连接过程需要几次握手？C 收到的 SYN = 1，ACK = 1 的 TCP 段的确认序号是多少？ （2）当 C 接收 Si 发送的 ACK = 1，seq = 2001，ack_seq = 2001，rwnd = 1000 确认段后，C 的拥塞窗口增加到多少？C 的发送窗口设置为多少？ （3）C 与 Si 释放 TCP 连接过程需要几次挥手？C 收到最后一个 TCP 报文段的序号（seq），确认序号（ack_seq），FIN 的值分别是多少？ （4）忽略报文段传输时延，且时间从 C 请求建立 TCP 连接时刻算起，则 C 确定 Si 已成功接收到文件的时间是多少？', '（1）TCP 连接需要 三次握手 。C 收到的 SYN=1、ACK=1 的 TCP 段是第二次握手，其确认序号为 C 的初始序号加 1，即 1000 + 1 = 1001 。 （2）收到该确认段时，C 的拥塞窗口增加 1 MSS，从 2 MSS 增加到 3 MSS 即 1500B 。发送窗口取拥塞窗口和接收窗口的最小值，即 min(3 MSS, 1000 B) = 1000 B 。 （3）TCP 连接释放需要 四次挥手 。C 收到的最后一个报文段是 Si 发送的 FIN+ACK 段，其序列号 seq 为 Si 的初始序号加 1（SYN 消耗一个序号），即 2000 + 1 = 2001 ；确认序号为 C 的 FIN 序号加 1，C 发送的数据最后一个字节序号为 3000，FIN 段序号为 3001，故确认号为 3001 + 1 = 3002 ； FIN 标志位为 1 。 （4）从连接建立开始，忽略报文段传输时延，连接建立耗时 1 RTT = 5 ms。数据传输过程中，受接收窗口限制，每次最多发送 2 MSS，共需传输 4 MSS。第一个报文段在连接建立后发送，其 ACK 在 1 RTT 后到达（5 + 5 = 10 ms），随后发送两个报文段，其 ACK 在下一个 RTT 后到达（10 + 5 = 15 ms），接着发送最后一个报文段，其 ACK 在再一个 RTT 后到达（15 + 5 = 20 ms）。故 C 确定 Si 成功接收文件的时间为 20 ms 。', 'html', b'0', b'0');
SET @q47 = LAST_INSERT_ID();
INSERT INTO question_content
  (question_id, version, title, options, correct_answer, analysis, title_text, analysis_text, content_format, has_image, has_code, legacy_text_content_id, source_hash, is_current)
VALUES
  (@q47, 1, '<div class="question-html-ref" data-src="question-html/2026/q47-title.html" data-fallback="（本题满分 9 分） 假设客户端 C 建立一条 TCP 连接，向服务器 Si 上传一个总长度为 2000 B 的计算任务描述文件。已知 C 的拥塞窗口初始阈值为 8 MSS，MSS = 500 B，Si 对收到的每个 TCP 段进行确认，且确认段不封装数据。接收窗口始终为 1000 B，RTT = 5 ms，C 建立连"></div>', '[]', '', '<div class="question-html-ref" data-src="question-html/2026/q47-analysis.html" data-fallback="（1）TCP 连接需要 三次握手 。C 收到的 SYN=1、ACK=1 的 TCP 段是第二次握手，其确认序号为 C 的初始序号加 1，即 1000 + 1 = 1001 。 （2）收到该确认段时，C 的拥塞窗口增加 1 MSS，从 2 MSS 增加到 3 MSS 即 1500B 。发送窗口取拥塞窗口和接收窗口的最小值"></div>',
   '（本题满分 9 分） 假设客户端 C 建立一条 TCP 连接，向服务器 Si 上传一个总长度为 2000 B 的计算任务描述文件。已知 C 的拥塞窗口初始阈值为 8 MSS，MSS = 500 B，Si 对收到的每个 TCP 段进行确认，且确认段不封装数据。接收窗口始终为 1000 B，RTT = 5 ms，C 建立连接时选择的初始序号为 1000，Si 选择的初始序号为 2000，SYN、ACK、FIN 为标志位，seq 为序号，ack_seq 为确认序号。在整个文件传输过程中未出现任何重传或报文丢失。 计算机考研杂货铺 计算机考研杂货铺 计算机考研杂货铺 计算机考研杂货铺 算力调度平台 S1 Sn C 计算机考研杂货铺 Si （1）C 与 Si 建立 TCP 连接过程需要几次握手？C 收到的 SYN = 1，ACK = 1 的 TCP 段的确认序号是多少？ （2）当 C 接收 Si 发送的 ACK = 1，seq = 2001，ack_seq = 2001，rwnd = 1000 确认段后，C 的拥塞窗口增加到多少？C 的发送窗口设置为多少？ （3）C 与 Si 释放 TCP 连接过程需要几次挥手？C 收到最后一个 TCP 报文段的序号（seq），确认序号（ack_seq），FIN 的值分别是多少？ （4）忽略报文段传输时延，且时间从 C 请求建立 TCP 连接时刻算起，则 C 确定 Si 已成功接收到文件的时间是多少？', '（1）TCP 连接需要 三次握手 。C 收到的 SYN=1、ACK=1 的 TCP 段是第二次握手，其确认序号为 C 的初始序号加 1，即 1000 + 1 = 1001 。 （2）收到该确认段时，C 的拥塞窗口增加 1 MSS，从 2 MSS 增加到 3 MSS 即 1500B 。发送窗口取拥塞窗口和接收窗口的最小值，即 min(3 MSS, 1000 B) = 1000 B 。 （3）TCP 连接释放需要 四次挥手 。C 收到的最后一个报文段是 Si 发送的 FIN+ACK 段，其序列号 seq 为 Si 的初始序号加 1（SYN 消耗一个序号），即 2000 + 1 = 2001 ；确认序号为 C 的 FIN 序号加 1，C 发送的数据最后一个字节序号为 3000，FIN 段序号为 3001，故确认号为 3001 + 1 = 3002 ； FIN 标志位为 1 。 （4）从连接建立开始，忽略报文段传输时延，连接建立耗时 1 RTT = 5 ms。数据传输过程中，受接收窗口限制，每次最多发送 2 MSS，共需传输 4 MSS。第一个报文段在连接建立后发送，其 ACK 在 1 RTT 后到达（5 + 5 = 10 ms），随后发送两个报文段，其 ACK 在下一个 RTT 后到达（10 + 5 = 15 ms），接着发送最后一个报文段，其 ACK 在再一个 RTT 后到达（15 + 5 = 20 ms）。故 C 确定 Si 成功接收文件的时间为 20 ms 。', 'html', b'0', b'0', @tc47, '541d260c08d146c34591beb2eac33cefe7eb49386b5407b03e446e1acb759c7d', b'1');
INSERT INTO question_source
  (question_id, source_type, source_name, source_year, source_question_no, paper_name, raw_ref, metadata)
VALUES
  (@q47, 'crawler_html', '计算机考研杂货铺', 2026, '47', '2026年408计算机学科专业基础综合模拟试题',
   'C:/Users/wutia/Downloads/csgraduates2026.html', '{"subject": "计算机网络", "html": true}');

INSERT INTO t_text_content (content, create_time)
VALUES (CAST(JSON_ARRAY(JSON_OBJECT('name', '一、单项选择题（1-40题，每题2分，共80分）', 'questionItems', JSON_ARRAY(JSON_OBJECT('id', @q1, 'itemOrder', 1), JSON_OBJECT('id', @q2, 'itemOrder', 2), JSON_OBJECT('id', @q3, 'itemOrder', 3), JSON_OBJECT('id', @q4, 'itemOrder', 4), JSON_OBJECT('id', @q5, 'itemOrder', 5), JSON_OBJECT('id', @q6, 'itemOrder', 6), JSON_OBJECT('id', @q7, 'itemOrder', 7), JSON_OBJECT('id', @q8, 'itemOrder', 8), JSON_OBJECT('id', @q9, 'itemOrder', 9), JSON_OBJECT('id', @q10, 'itemOrder', 10), JSON_OBJECT('id', @q11, 'itemOrder', 11), JSON_OBJECT('id', @q12, 'itemOrder', 12), JSON_OBJECT('id', @q13, 'itemOrder', 13), JSON_OBJECT('id', @q14, 'itemOrder', 14), JSON_OBJECT('id', @q15, 'itemOrder', 15), JSON_OBJECT('id', @q16, 'itemOrder', 16), JSON_OBJECT('id', @q17, 'itemOrder', 17), JSON_OBJECT('id', @q18, 'itemOrder', 18), JSON_OBJECT('id', @q19, 'itemOrder', 19), JSON_OBJECT('id', @q20, 'itemOrder', 20), JSON_OBJECT('id', @q21, 'itemOrder', 21), JSON_OBJECT('id', @q22, 'itemOrder', 22), JSON_OBJECT('id', @q23, 'itemOrder', 23), JSON_OBJECT('id', @q24, 'itemOrder', 24), JSON_OBJECT('id', @q25, 'itemOrder', 25), JSON_OBJECT('id', @q26, 'itemOrder', 26), JSON_OBJECT('id', @q27, 'itemOrder', 27), JSON_OBJECT('id', @q28, 'itemOrder', 28), JSON_OBJECT('id', @q29, 'itemOrder', 29), JSON_OBJECT('id', @q30, 'itemOrder', 30), JSON_OBJECT('id', @q31, 'itemOrder', 31), JSON_OBJECT('id', @q32, 'itemOrder', 32), JSON_OBJECT('id', @q33, 'itemOrder', 33), JSON_OBJECT('id', @q34, 'itemOrder', 34), JSON_OBJECT('id', @q35, 'itemOrder', 35), JSON_OBJECT('id', @q36, 'itemOrder', 36), JSON_OBJECT('id', @q37, 'itemOrder', 37), JSON_OBJECT('id', @q38, 'itemOrder', 38), JSON_OBJECT('id', @q39, 'itemOrder', 39), JSON_OBJECT('id', @q40, 'itemOrder', 40))), JSON_OBJECT('name', '二、综合应用题（41-47题，共72分）', 'questionItems', JSON_ARRAY(JSON_OBJECT('id', @q41, 'itemOrder', 41), JSON_OBJECT('id', @q42, 'itemOrder', 42), JSON_OBJECT('id', @q43, 'itemOrder', 43), JSON_OBJECT('id', @q44, 'itemOrder', 44), JSON_OBJECT('id', @q45, 'itemOrder', 45), JSON_OBJECT('id', @q46, 'itemOrder', 46), JSON_OBJECT('id', @q47, 'itemOrder', 47)))) AS CHAR), NOW());
SET @frame_content_id = LAST_INSERT_ID();

INSERT INTO t_subject (id, name, level, level_name, item_order, deleted)
VALUES (5, '计算机408综合', 1, NULL, 5, b'0')
ON DUPLICATE KEY UPDATE
  name = VALUES(name),
  level = VALUES(level),
  item_order = VALUES(item_order),
  deleted = b'0';

INSERT INTO t_exam_paper
  (name, subject_id, paper_type, grade_level, score, question_count, suggest_time, limit_start_time, limit_end_time, frame_text_content_id, create_user, deleted, task_exam_id, source_year, description)
VALUES
  ('2026年408计算机学科专业基础综合模拟试题', 5, 1, NULL, 1520, 47, 180, NULL, NULL, @frame_content_id, 1, b'0', NULL, 2026, '从 csgraduates HTML 导入的 2026 408 模拟卷，题干和解析保留 HTML 结构。');

COMMIT;
