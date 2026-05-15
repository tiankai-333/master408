# -*- coding: utf-8 -*-
import bcrypt

# 数据库中的原始密码哈希
db_hash = "$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH"

# 测试密码
password = "123456"
password_bytes = password.encode('utf-8')
hash_bytes = db_hash.encode('utf-8')

print(f"测试密码: '{password}'")
print(f"数据库哈希: {db_hash}")
print()

try:
    result = bcrypt.checkpw(password_bytes, hash_bytes)
    print(f"bcrypt.checkpw 结果: {result}")

    # 尝试手动验证
    encoder = bcrypt.BCryptPasswordEncoder()
    manual_result = encoder.matches(password, db_hash)
    print(f"手动验证结果: {manual_result}")

except Exception as e:
    print(f"验证出错: {e}")
    import traceback
    traceback.print_exc()
