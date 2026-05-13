/*
 * ============================================
 * 数据库编码修复脚本
 * ============================================
 *
 * 问题：前端界面显示"???"乱码
 * 原因：数据库或连接字符集设置不正确
 *
 * 使用方法（二选一）：
 *
 * 方法1：直接修复（推荐 - 不丢失数据）
 *   mysql -u root -p xzs < fix_database_charset.sql
 *
 * 方法2：完全重建（会删除所有数据）
 *   mysql -u root -p
 *   DROP DATABASE xzs;
 *   source C:/Dev/Workspaces/master408/sql/init_database_utf8.sql
 *
 * ============================================
 */

USE xzs;

-- ----------------------------
-- 1. 设置连接字符集
-- ----------------------------
SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;

-- ----------------------------
-- 2. 修改数据库默认字符集
-- ----------------------------
ALTER DATABASE xzs CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ----------------------------
-- 3. 修改所有表的字符集
-- ----------------------------
ALTER TABLE t_subject CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE t_text_content CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE t_question CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE t_user CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE t_exam_paper CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE t_exam_paper_answer CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE t_exam_paper_question_customer_answer CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE t_message CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE t_message_user CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE t_task_exam CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE t_task_exam_customer_answer CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE t_user_event_log CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE t_user_token CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ----------------------------
-- 4. 修复用户表的中文姓名
-- ----------------------------
UPDATE t_user SET real_name = '学生小明' WHERE user_name = 'student' AND (real_name IS NULL OR real_name = '???' OR real_name = '');
UPDATE t_user SET real_name = '系统管理员' WHERE user_name = 'admin' AND (real_name IS NULL OR real_name = '???' OR real_name = '');

-- ----------------------------
-- 5. 验证修复结果
-- ----------------------------
SELECT '========================================' AS '';
SELECT '数据库编码修复完成！' AS result;
SELECT '' AS '';
SELECT '当前字符集设置：' AS info;
SHOW VARIABLES LIKE 'character_set%';
SELECT '' AS '';
SELECT '学科列表：' AS info;
SELECT id, name, level_name FROM t_subject;
SELECT '' AS '';
SELECT '用户列表：' AS info;
SELECT id, user_name, real_name, role FROM t_user;
