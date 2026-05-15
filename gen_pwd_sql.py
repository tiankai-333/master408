import hashlib
import os

salt = os.urandom(16)
password = "123456"
result = hashlib.pbkdf2_hmac('sha256', password.encode('utf-8'), salt, 100000)
print(f"PBKDF2-SHA256: {salt.hex()}{result.hex()}")

print("\n生成SQL语句:")
bcrypt_placeholder = "$2a$10$-placeholder-placeholder-placeholder-placeholder"
print(f"UPDATE t_user SET password = '{bcrypt_placeholder}' WHERE user_name = 'student';")
