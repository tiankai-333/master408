# -*- coding: utf-8 -*-
import bcrypt

# 要设置的密码
password = "123456"

# 生成BCrypt哈希
password_bytes = password.encode('utf-8')
salt = bcrypt.gensalt()
hashed = bcrypt.hashpw(password_bytes, salt)

print(f"密码: {password}")
print(f"BCrypt哈希: {hashed.decode('utf-8')}")
print()
print("请使用以下SQL更新数据库:")
print(f"UPDATE t_user SET password = '{hashed.decode('utf-8')}' WHERE user_name = 'student';")
