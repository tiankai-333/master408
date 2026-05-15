$headers = @{}
$headers["Content-Type"] = "application/json"

Write-Host "=== 修改 student 用户 role 为 1 ==="

$result = Invoke-RestMethod -Uri "http://localhost:8000/api/test/reset-role?userName=student&role=1" -Method GET -Headers $headers
Write-Host ($result | ConvertTo-Json -Depth 5)

Write-Host "`n=== 再测试登录 ==="
$body = @{
    userName = "student"
    password = "123456"
}
$result2 = Invoke-RestMethod -Uri "http://localhost:8000/api/user/login" -Method POST -Headers $headers -Body ($body | ConvertTo-Json)
Write-Host ($result2 | ConvertTo-Json -Depth 5)
