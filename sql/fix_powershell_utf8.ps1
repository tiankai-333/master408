# PowerShell UTF-8 显示修复
# 运行此脚本修复中文显示问题

# 方案1：临时修改控制台编码（推荐）
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 > $null

Write-Host "✅ 已切换到UTF-8编码 (65001)" -ForegroundColor Green

# 方案2：永久修改（需要管理员权限）
# Set-ItemProperty -Path 'HKCU:\Console' -Name CodePage -Value 65001

# 验证
Write-Host ""
Write-Host "验证编码设置：" -ForegroundColor Yellow
Write-Host "Console.OutputEncoding: $([Console]::OutputEncoding.EncodingName)"
Write-Host "chcp 结果: $(chcp)"
