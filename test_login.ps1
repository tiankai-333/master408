$headers = @{}
$headers["Content-Type"] = "application/json"

$body = @{
    userName = "student"
    password = "123456"
}

Write-Host "测试登录 (正确的接口):"
$result = Invoke-RestMethod -Uri "http://localhost:8000/api/user/login" -Method POST -Headers $headers -Body ($body | ConvertTo-Json)
Write-Host ($result | ConvertTo-Json -Depth 10)
