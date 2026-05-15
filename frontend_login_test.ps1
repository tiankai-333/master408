$headers = @{}
$headers["Content-Type"] = "application/json"
$headers["request-ajax"] = "true"

$body = @{
    userName = "student"
    password = "123456"
}

Write-Host "=== 通过前端代理 (localhost:8002) 登录 ==="
$result = Invoke-RestMethod -Uri "http://localhost:8002/api/user/login" -Method POST -Headers $headers -Body ($body | ConvertTo-Json)
Write-Host ($result | ConvertTo-Json -Depth 5)

Write-Host "`n=== 直接连接后端 (localhost:8000) 登录 ==="
$result2 = Invoke-RestMethod -Uri "http://localhost:8000/api/user/login" -Method POST -Headers $headers -Body ($body | ConvertTo-Json)
Write-Host ($result2 | ConvertTo-Json -Depth 5)

if ($result.code -eq 1 -and $result2.code -eq 1) {
    Write-Host "`n✅ 两种方式都登录成功！"
} else {
    Write-Host "`n❌ 登录存在问题"
}
