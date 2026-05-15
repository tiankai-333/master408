$headers = @{}
$headers["Content-Type"] = "application/json"

Write-Host "=== 1. 检查数据库中的学科数据 ==="
$result = Invoke-RestMethod -Uri "http://localhost:8000/api/test/check-subjects" -Method GET -Headers $headers
Write-Host ($result | ConvertTo-Json -Depth 10)
