# -*- coding: utf-8 -*-
import subprocess

# 常见的测试密码
passwords = ["123456", "student", "123", "admin", "12345678", "password", "wutiankai"]

# BCrypt哈希（来自数据库）
bcrypt_hash = "$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH"

print("测试密码匹配...")
print()

# 由于Python的bcrypt库需要安装，我们用另一种方式
# 创建一个简单的测试工具

# 先检查是否有bcrypt
try:
    import bcrypt
    print("bcrypt库已安装")
    
    # 测试每个密码
    for pwd in passwords:
        pwd_bytes = pwd.encode('utf-8')
        hash_bytes = bcrypt_hash.encode('utf-8')
        
        # bcrypt.checkpw(password, hashed_password)
        if bcrypt.checkpw(pwd_bytes, hash_bytes):
            print(f"✅ 匹配成功！密码是: '{pwd}'")
            break
    else:
        print("❌ 未找到匹配密码")
        print()
        print("请输入你认为的密码，我来验证:")
        user_input = input("密码: ")
        pwd_bytes = user_input.encode('utf-8')
        hash_bytes = bcrypt_hash.encode('utf-8')
        if bcrypt.checkpw(pwd_bytes, hash_bytes):
            print(f"✅ 匹配成功！")
        else:
            print(f"❌ 不匹配")
            
except ImportError:
    print("bcrypt库未安装，正在安装...")
    subprocess.run(["pip", "install", "bcrypt"], check=True)
    print("安装完成，请重新运行此脚本")
