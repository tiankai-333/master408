import requests, json

base = "http://localhost:8000"

s = requests.Session()
r = s.post(f"{base}/api/user/login", json={"userName": "student", "password": "123456"})
print(f"login: {r.status_code}, cookies: {dict(s.cookies)}")

r2 = s.post(f"{base}/api/student/exampaper/answer/pageList", json={"pageIndex": 1, "pageSize": 10})
print(f"\npageList: {r2.status_code}")
try:
    data = r2.json()
    print(json.dumps(data, ensure_ascii=False, indent=2)[:1000])
except:
    print(f"body: {r2.text[:500]}")
