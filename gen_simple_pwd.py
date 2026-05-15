# -*- coding: utf-8 -*-
import bcrypt

# 原始密码
password = "123456"

# 生成 BCrypt 哈希
password_bytes = password.encode('utf-8')
salt = bcrypt.gensalt(rounds=10)  # 使用 10 轮
hashed = bcrypt.hashpw(password_bytes, salt)

print(f"密码: {password}")
print(f"BCrypt哈希: {hashed.decode('utf-8')}")
print()

# 验证
if bcrypt.checkpw(password_bytes, hashed):
    print("✅ 验证通过！")
else:
    print("❌ 验证失败！")
