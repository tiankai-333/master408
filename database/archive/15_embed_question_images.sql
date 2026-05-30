-- 15: 将 t_question.images 路径转为 <img> 标签追加到 title 末尾
-- 同时更新 question_content 规范表对应记录
-- 幂等：仅处理 images 非空且 title 中尚未包含该图片的行

-- 1) 修正路径分隔符：images\2012\2012_4.svg → images/2012/2012_4.svg
-- 使用 0x5c 避免 MySQL 字符串转义导致反斜杠匹配失败。
UPDATE t_question
SET images = REPLACE(images, 0x5c, '/')
WHERE images IS NOT NULL AND images != '';

-- 若旧脚本已经把反斜杠写入 title/img 标签，先修正为浏览器可访问的 URL。
UPDATE t_question
SET title = REPLACE(title, 0x5c, '/')
WHERE title IS NOT NULL;

-- 幂等清理：移除旧脚本可能重复追加的题目附图标签，再统一追加一个。
UPDATE t_question
SET title = REGEXP_REPLACE(
    title,
    '<br><img src="/images[^"]*" style="max-width:100%;height:auto;margin:8px 0" alt="[^"]*">',
    ''
)
WHERE images IS NOT NULL AND images != '';

-- 2) 将图片追加到 t_question.title
UPDATE t_question
SET title = CONCAT(
    title,
    '<br><img src="/', images, '" style="max-width:100%;height:auto;margin:8px 0" alt="题目附图">'
)
WHERE images IS NOT NULL
  AND images != ''
  AND title NOT LIKE CONCAT('%<img src="/', images, '%');

-- 3) 同步到 question_content 规范表
UPDATE question_content qc
JOIN t_question q ON q.id = qc.question_id
SET qc.title = q.title,
    qc.has_image = 1
WHERE q.images IS NOT NULL
  AND q.images != ''
  AND (qc.title NOT LIKE '%<img%' OR qc.has_image = 0);
