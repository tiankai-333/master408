-- 替换用户动态中的旧系统品牌名，避免学生档案/日志页出现“学之思开源考试系统”。

UPDATE t_user_event_log
SET content = REPLACE(content, '学之思开源考试系统', '408Master 智能学习系统')
WHERE content LIKE '%学之思开源考试系统%';
