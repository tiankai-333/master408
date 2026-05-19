-- 为取消年级选择后的注册流程提供兼容默认值。
-- 旧逻辑仍会读取 t_user.user_level，因此统一将空年级视为默认年级 1。

UPDATE `t_user`
SET `user_level` = 1
WHERE `user_level` IS NULL;

ALTER TABLE `t_user`
  MODIFY COLUMN `user_level` int DEFAULT 1;
