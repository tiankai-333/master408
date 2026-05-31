# 408Master 阿里云镜像仓库部署脚本 v2.0
# 用法: .\deploy\cloud-acr.ps1 <命令> [选项]
#
# 命令:
#   login                登录 ACR
#   build-backend        构建后端 Docker 镜像
#   push-backend         构建并推送后端镜像（失败自动重试 3 次）
#   deploy-backend       远程替换 backend image 并 force-recreate
#   build-student        构建学生端 dist
#   build-admin          构建管理端 dist
#   deploy-student-static  上传并替换远程 static/student
#   deploy-admin-static    上传并替换远程 static/admin
#   status               查看云端容器状态和当前镜像
#
# 选项:
#   -y                跳过确认
#   -Tag <tag>        指定镜像 tag（默认: yyyymmdd）
#   -Retry <n>        push 重试次数（默认: 3）

[CmdletBinding()]
param(
    [Parameter(Position=0)]
    [ValidateSet(
        'login','build-backend','push-backend','deploy-backend',
        'build-student','build-admin',
        'deploy-student-static','deploy-admin-static',
        'status'
    )]
    [string]$Command = 'status',

    [switch]$y,
    [string]$Tag,
    [int]$Retry = 3
)

$ErrorActionPreference = 'Stop'

# ---- 路径 ----
$DeployDir   = if ($PSScriptRoot) { $PSScriptRoot } else { Join-Path $PWD 'deploy' }
$ProjectRoot = Split-Path $DeployDir -Parent
$StudentDir  = Join-Path $ProjectRoot 'source\vue\xzs-student'
$AdminDir    = Join-Path $ProjectRoot 'source\vue\xzs-admin'

# ---- 默认配置 ----
$AcrRegion    = 'cn-hangzhou'
$AcrRegistry  = ''
$AcrNamespace = ''
$AcrRepo      = '408master'
$AcrUsername  = ''
$AcrPassword  = ''
$Server       = ''
$Remote       = '/opt/xzs-deploy'

# ---- 加载 .env.acr ----
$acrEnvFile = Join-Path $DeployDir '.env.acr'
if (-not (Test-Path $acrEnvFile)) {
    $acrEnvFile = Join-Path $ProjectRoot '.env.acr'
}
if (Test-Path $acrEnvFile) {
    Get-Content $acrEnvFile | ForEach-Object {
        if ($_ -match '^\s*([^#][^=]+?)\s*=\s*(.+)$') {
            $key = $matches[1].Trim(); $val = $matches[2].Trim()
            switch ($key) {
                'ACR_REGION'    { $AcrRegion = $val }
                'ACR_REGISTRY'  { $AcrRegistry = $val }
                'ACR_NAMESPACE' { $AcrNamespace = $val }
                'ACR_REPO'      { $AcrRepo = $val }
                'ACR_USERNAME'  { $AcrUsername = $val }
                'ACR_PASSWORD'  { $AcrPassword = $val }
            }
        }
    }
}

# ---- 加载 .env（服务器配置）----
$envFile = Join-Path $DeployDir '.env'
if (-not (Test-Path $envFile)) {
    $envFile = Join-Path $ProjectRoot '.env'
}
if (Test-Path $envFile) {
    Get-Content $envFile | ForEach-Object {
        if ($_ -match '^\s*([^#][^=]+?)\s*=\s*(.+)$') {
            $key = $matches[1].Trim(); $val = $matches[2].Trim()
            switch ($key) {
                'SERVER' { $Server = $val }
                'REMOTE' { $Remote = $val }
            }
        }
    }
}

# ---- 校验必要配置 ----
function Assert-Config {
    param([string[]]$Required)
    foreach ($r in $Required) {
        $val = Get-Variable $r -ValueOnly -ErrorAction SilentlyContinue
        if (-not $val) {
            Write-Fail "缺少配置: $r，请在 deploy/.env.acr 或 deploy/.env 中设置"
        }
    }
}

# ---- tag 默认用日期 ----
if (-not $Tag) {
    $Tag = Get-Date -Format 'yyyyMMdd'
}

# ---- 镜像地址 ----
$BackendImage = "${AcrRegistry}/${AcrNamespace}/${AcrRepo}:backend-${Tag}"

# ---- 输出函数 ----
function Write-Info($msg)  { Write-Host "[INFO]  $msg" -ForegroundColor Cyan }
function Write-Ok($msg)    { Write-Host "[ OK ]  $msg" -ForegroundColor Green }
function Write-Warn($msg)  { Write-Host "[WARN]  $msg" -ForegroundColor Yellow }
function Write-Fail($msg)  { Write-Host "[FAIL]  $msg" -ForegroundColor Red; exit 1 }

function Confirm-Action($msg) {
    if ($y) { return }
    $prompt = if ($msg) { "$msg [y/N]" } else { '继续？[y/N]' }
    $ans = Read-Host $prompt
    if ($ans -notmatch '^[yY]') { Write-Host '已取消'; exit 0 }
}

# ---- SSH 封装 ----
$SshKey = $null
foreach ($c in @("$env:USERPROFILE\.ssh\id_ed25519", "$env:USERPROFILE\.ssh\id_rsa")) {
    if (Test-Path $c) { $SshKey = $c; break }
}

function Get-SshArgs() {
    $args = @('-o', 'StrictHostKeyChecking=no', '-o', 'ConnectTimeout=10')
    if ($SshKey) {
        $args += @('-i', $SshKey, '-o', 'BatchMode=yes')
    }
    return $args
}

function Assert-SshReady {
    if (-not $SshKey) {
        Write-Warn '未找到 SSH 密钥 (~/.ssh/id_ed25519 或 id_rsa)'
        Write-Warn '请确保已配置 SSH 密钥认证，或手动指定 -i 参数'
        Write-Fail '缺少 SSH 密钥，无法连接服务器'
    }
}

function Invoke-Remote([string]$Cmd) {
    Assert-SshReady | Out-Null
    $sshArgs = Get-SshArgs
    $allArgs = $sshArgs + @($Server, $Cmd)
    & ssh @allArgs
    if ($LASTEXITCODE -ne 0) {
        Write-Fail "远程命令执行失败 (exit $LASTEXITCODE): $Cmd"
    }
}

function Invoke-RemoteQuiet([string]$Cmd) {
    Assert-SshReady | Out-Null
    $sshArgs = Get-SshArgs
    $allArgs = $sshArgs + @($Server, $Cmd)
    & ssh @allArgs 2>$null
}

# =============================================================================
#  login
# =============================================================================
function Invoke-Login {
    Assert-Config 'AcrUsername','AcrPassword','AcrRegistry'
    Write-Info "登录 ACR: $AcrRegistry"
    $env:DOCKER_CLI_HINTS = 'false'
    docker login --username $AcrUsername --password $AcrPassword $AcrRegistry
    if ($LASTEXITCODE -eq 0) { Write-Ok 'ACR 登录成功' }
    else { Write-Fail 'ACR 登录失败，请检查用户名和密码' }
}

# =============================================================================
#  build-backend
# =============================================================================
function Invoke-BuildBackend {
    Assert-Config 'AcrRegistry','AcrNamespace','AcrRepo'
    Write-Info "构建后端镜像: $BackendImage"

    $jarPath = Join-Path $ProjectRoot 'source\xzs\target\xzs-3.9.0.jar'
    if (-not (Test-Path $jarPath)) {
        Write-Fail 'JAR 不存在，请先构建: cd source/xzs && ./mvnw package -DskipTests'
    }

    Copy-Item $jarPath (Join-Path $DeployDir 'xzs-3.9.0.jar') -Force

    Push-Location $DeployDir
    try {
        docker build -f Dockerfile -t $BackendImage .
        if ($LASTEXITCODE -ne 0) { Write-Fail '后端镜像构建失败' }
    } finally {
        Pop-Location
    }
    Write-Ok "后端镜像构建完成: $BackendImage"
}

# =============================================================================
#  push-backend（含重试）
# =============================================================================
function Invoke-PushBackend {
    Assert-Config 'AcrRegistry','AcrNamespace','AcrRepo'

    # 确保 ACR 已登录
    $loginCheck = docker info 2>&1 | Select-String $AcrRegistry
    if (-not $loginCheck) {
        Write-Info '未登录 ACR，正在登录...'
        Invoke-Login
    }

    # 先构建
    Invoke-BuildBackend

    # 带重试的推送
    Write-Info "推送后端镜像: $BackendImage"
    $pushed = $false
    for ($i = 1; $i -le $Retry; $i++) {
        docker push $BackendImage
        if ($LASTEXITCODE -eq 0) {
            $pushed = $true
            break
        }
        if ($i -lt $Retry) {
            Write-Warn "推送失败 (第 $i/$Retry 次)，${i}0 秒后重试..."
            Start-Sleep -Seconds ($i * 10)
        }
    }
    if (-not $pushed) { Write-Fail "后端镜像推送失败（已重试 $Retry 次）" }
    Write-Ok "后端镜像已推送: $BackendImage"
}

# =============================================================================
#  deploy-backend（远程只替换 backend image，不动 compose 文件结构）
# =============================================================================
function Invoke-DeployBackend {
    Assert-Config 'AcrRegistry','AcrNamespace','AcrRepo','Server','Remote'
    Assert-SshReady

    Write-Info "目标镜像: $BackendImage"
    Write-Info "服务器: $Server:$Remote"
    Write-Host ''

    # [1/5] 确认
    Confirm-Action "将替换 backend 镜像为 ${Tag} 并重启，是否继续？"

    # [2/5] 备份远程 compose
    $timestamp = (Get-Date).ToString('yyyyMMdd-HHmmss')
    Write-Info '[1/5] 备份远程 docker-compose.yml ...'
    Invoke-RemoteQuiet "cp ${Remote}/docker-compose.yml ${Remote}/docker-compose.yml.bak.${timestamp}"
    if ($LASTEXITCODE -eq 0) {
        Write-Ok "已备份: docker-compose.yml.bak.${timestamp}"
    } else {
        Write-Fail '备份 docker-compose.yml 失败，中止部署'
    }

    # [3/5] 服务器端登录 ACR
    Write-Info '[2/5] 服务器登录 ACR...'
    Invoke-Remote "echo '$AcrPassword' | docker login --username '$AcrUsername' --password-stdin $AcrRegistry"

    # [4/5] 替换 compose 中的 backend image
    Write-Info '[3/5] 替换 backend 镜像地址...'
    $oldImage = Invoke-RemoteQuiet "grep 'image:.*backend' ${Remote}/docker-compose.yml || true"
    if ($oldImage) {
        $oldImage = ($oldImage -replace '^\s*image:\s*', '').Trim()
        Write-Info "  旧镜像: $oldImage"
    }
    # 用 sed 只替换 backend service 下的 image 行
    Invoke-Remote ("cd $Remote && sed -i '/container_name: xzs-backend/,/depends_on/ s|image: .*|image: $BackendImage|' docker-compose.yml")
    Write-Info "  新镜像: $BackendImage"

    # [5/5] 拉取并 force-recreate 仅 backend
    Write-Info '[4/5] 拉取新镜像...'
    Invoke-Remote "cd $Remote && docker compose pull backend"

    Write-Info '[5/5] 重启 backend 容器...'
    Invoke-Remote "cd $Remote && docker compose up -d --force-recreate backend"

    # 等待并检查
    Start-Sleep -Seconds 5
    Write-Host ''
    Write-Info '容器状态:'
    Invoke-RemoteQuiet "docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'"

    $ip = $Server -replace '^.*@', ''
    Write-Host ''
    Write-Ok '后端部署完成'
    Write-Host "  学生端: http://${ip}/student/"
    Write-Host "  管理端: http://${ip}/admin/"
}

# =============================================================================
#  build-student
# =============================================================================
function Invoke-BuildStudent {
    if (-not (Test-Path $StudentDir)) {
        Write-Fail "学生端目录不存在: $StudentDir"
    }
    Write-Info '构建学生端 dist...'
    Push-Location $StudentDir
    try {
        if (-not (Test-Path 'node_modules')) {
            Write-Info '安装依赖...'
            npm install
            if ($LASTEXITCODE -ne 0) { Write-Fail 'npm install 失败' }
        }
        npm run build
        if ($LASTEXITCODE -ne 0) { Write-Fail '学生端构建失败' }
    } finally {
        Pop-Location
    }
    $distPath = Join-Path $StudentDir 'dist'
    if (Test-Path $distPath) {
        Write-Ok "学生端构建完成: $distPath"
    } else {
        Write-Fail '学生端构建完成但 dist 目录不存在'
    }
}

# =============================================================================
#  build-admin
# =============================================================================
function Invoke-BuildAdmin {
    if (-not (Test-Path $AdminDir)) {
        Write-Fail "管理端目录不存在: $AdminDir"
    }
    Write-Info '构建管理端 dist...'
    Push-Location $AdminDir
    try {
        if (-not (Test-Path 'node_modules')) {
            Write-Info '安装依赖...'
            npm install
            if ($LASTEXITCODE -ne 0) { Write-Fail 'npm install 失败' }
        }
        npm run build
        if ($LASTEXITCODE -ne 0) { Write-Fail '管理端构建失败' }
    } finally {
        Pop-Location
    }
    $distPath = Join-Path $AdminDir 'dist'
    if (Test-Path $distPath) {
        Write-Ok "管理端构建完成: $distPath"
    } else {
        Write-Fail '管理端构建完成但 dist 目录不存在'
    }
}

# =============================================================================
#  deploy-student-static
# =============================================================================
function Invoke-DeployStudentStatic {
    Assert-Config 'Server','Remote'
    Assert-SshReady

    $distPath = Join-Path $StudentDir 'dist'
    if (-not (Test-Path $distPath)) {
        Write-Fail "学生端 dist 不存在，请先运行: .\deploy\cloud-acr.ps1 build-student"
    }

    $remoteStatic = "${Remote}/static/student"
    Write-Info "上传学生端静态文件到 ${Server}:${remoteStatic}"
    Confirm-Action "将替换远程 ${remoteStatic}，是否继续？"

    # 备份远程现有文件
    $timestamp = (Get-Date).ToString('yyyyMMdd-HHmmss')
    Write-Info '备份远程旧文件...'
    Invoke-RemoteQuiet "if [ -d ${remoteStatic} ]; then mv ${remoteStatic} ${remoteStatic}.bak.${timestamp}; fi"

    # 创建目标目录并上传
    Invoke-RemoteQuiet "mkdir -p ${remoteStatic}"
    $sshArgs = Get-SshArgs
    $scpArgs = $sshArgs + @('-r', "${distPath}/.", "${Server}:${remoteStatic}/")
    & scp @scpArgs
    if ($LASTEXITCODE -ne 0) { Write-Fail '学生端静态文件上传失败' }

    Write-Ok "学生端静态文件已部署到 ${remoteStatic}"
    $ip = $Server -replace '^.*@', ''
    Write-Host "  访问: http://${ip}/student/"
}

# =============================================================================
#  deploy-admin-static
# =============================================================================
function Invoke-DeployAdminStatic {
    Assert-Config 'Server','Remote'
    Assert-SshReady

    $distPath = Join-Path $AdminDir 'dist'
    if (-not (Test-Path $distPath)) {
        Write-Fail "管理端 dist 不存在，请先运行: .\deploy\cloud-acr.ps1 build-admin"
    }

    $remoteStatic = "${Remote}/static/admin"
    Write-Info "上传管理端静态文件到 ${Server}:${remoteStatic}"
    Confirm-Action "将替换远程 ${remoteStatic}，是否继续？"

    # 备份远程现有文件
    $timestamp = (Get-Date).ToString('yyyyMMdd-HHmmss')
    Write-Info '备份远程旧文件...'
    Invoke-RemoteQuiet "if [ -d ${remoteStatic} ]; then mv ${remoteStatic} ${remoteStatic}.bak.${timestamp}; fi"

    # 创建目标目录并上传
    Invoke-RemoteQuiet "mkdir -p ${remoteStatic}"
    $sshArgs = Get-SshArgs
    $scpArgs = $sshArgs + @('-r', "${distPath}/.", "${Server}:${remoteStatic}/")
    & scp @scpArgs
    if ($LASTEXITCODE -ne 0) { Write-Fail '管理端静态文件上传失败' }

    Write-Ok "管理端静态文件已部署到 ${remoteStatic}"
    $ip = $Server -replace '^.*@', ''
    Write-Host "  访问: http://${ip}/admin/"
}

# =============================================================================
#  status
# =============================================================================
function Invoke-Status {
    Assert-Config 'Server'
    Assert-SshReady

    Write-Info '云端容器状态:'
    Invoke-RemoteQuiet "docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'"
    Write-Host ''
    Write-Info '相关镜像:'
    Invoke-RemoteQuiet "docker images --format 'table {{.Repository}}\t{{.Tag}}\t{{.Size}}' | grep -E '408master|xzs|HEADER'"
}

# =============================================================================
#  主入口
# =============================================================================
Write-Host ''
Write-Host '╔══════════════════════════════════════════════════╗' -ForegroundColor Green
Write-Host '║     408Master ACR 部署工具 v2.0                  ║' -ForegroundColor Green
Write-Host '╠══════════════════════════════════════════════════╣' -ForegroundColor Green
Write-Host ('║  命令:    {0,-36}║' -f $Command) -ForegroundColor Green
Write-Host ('║  Tag:     {0,-36}║' -f $Tag) -ForegroundColor Green
if ($AcrRegistry) {
    Write-Host ('║  ACR:     {0,-36}║' -f "$AcrNamespace/$AcrRepo") -ForegroundColor Green
}
if ($Server) {
    Write-Host ('║  服务器: {0,-36}║' -f $Server) -ForegroundColor Green
}
Write-Host '╚══════════════════════════════════════════════════╝' -ForegroundColor Green

switch ($Command) {
    'login'                 { Invoke-Login }
    'build-backend'         { Invoke-BuildBackend }
    'push-backend'          { Invoke-PushBackend }
    'deploy-backend'        { Invoke-DeployBackend }
    'build-student'         { Invoke-BuildStudent }
    'build-admin'           { Invoke-BuildAdmin }
    'deploy-student-static' { Invoke-DeployStudentStatic }
    'deploy-admin-static'   { Invoke-DeployAdminStatic }
    'status'                { Invoke-Status }
}
