# -*- coding: utf-8 -*-
import bcrypt

# 数据库中的原始密码哈希
db_hash = "$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH"

# 常见密码列表
test_passwords = [
    "123456",
    "12345678",
    "123456789",
    "admin",
    "student",
    "password",
    "123",
    "12345",
    "1234567",
    "1234567890",
    "admin123",
    "student123",
    "88888888",
    "666666",
    "000000"
]

print("测试数据库中的密码哈希...")
print(f"哈希: {db_hash}")
print()

found = False
for pwd in test_passwords:
    pwd_bytes = pwd.encode('utf-8')
    hash_bytes = db_hash.encode('utf-8')
    
    try:
        if bcrypt.checkpw(pwd_bytes, hash_bytes):
            print(f"✅ 找到匹配！密码是: '{pwd}'")
            found = True
            break
    except Exception as e:
        print(f"测试 '{pwd}' 时出错: {e}")

if not found:
    print("❌ 在常见密码列表中未找到匹配")
    print()
    print("请告诉我你原来的密码是什么，我来验证：")
