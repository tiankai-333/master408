$headers = @{}
$headers["Content-Type"] = "application/json"

Write-Host "1. 先解密看看数据库密码是什么:"
$result = Invoke-RestMethod -Uri "http://localhost:8000/api/test/decryptRsa?encrypted=D1AGFL+Gx37t0NPG4d6biYP5Z31cNbwhK5w1lUeiHB2zagqbk8efYfSjYoh1Z/j1dkiRjHU+b0EpwzCh8IGsksJjzD65ci5LsnodQVf4Uj6D3pwoscXGqmkjjpzvSJbx42swwNTA+QoDU8YLo7JhtbUK2X0qCjFGpd+8eJ5BGvk=" -Method GET -Headers $headers
Write-Host ($result | ConvertTo-Json -Depth 10)

Write-Host "`n2. 重置student密码为123456:"
$result = Invoke-RestMethod -Uri "http://localhost:8000/api/test/resetPwd?userName=student&password=123456" -Method GET -Headers $headers
Write-Host ($result | ConvertTo-Json -Depth 10)
