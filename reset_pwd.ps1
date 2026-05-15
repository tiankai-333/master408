$headers = @{}
$headers["Content-Type"] = "application/json"
$result = Invoke-RestMethod -Uri "http://localhost:8000/api/admin/user/resetPassword?userName=student&password=123456" -Method POST -Headers $headers
Write-Host $result
