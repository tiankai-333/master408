# 408Master 阿里云镜像仓库部署脚本
# 用法: .\deploy\cloud-acr.ps1 [命令] [选项]
#
# 命令:
#   build       本地构建镜像（不推送）
#   push        构建并推送到 ACR
#   deploy      服务器拉取镜像并重启
#   full        构建 + 推送 + 部署（默认）
#   login       登录 ACR
#   status      查看云端服务状态
#
# 选项:
#   -y                跳过确认
#   -SkipFrontend     跳过前端镜像构建
#   -SkipBackend      跳过后端镜像构建
#   -Tag <tag>        指定镜像 tag（默认: 日期 yyyymmdd）

[CmdletBinding()]
param(
    [Parameter(Position=0)]
    [ValidateSet('build','push','deploy','full','login','status')]
    [string]$Command = 'full',

    [switch]$y,
    [switch]$SkipFrontend,
    [switch]$SkipBackend,
    [string]$Tag
)

$ErrorActionPreference = 'Stop'

# ---- 路径 ----
$DeployDir   = if ($PSScriptRoot) { $PSScriptRoot } else { Join-Path $PWD 'deploy' }
$ProjectRoot = Split-Path $DeployDir -Parent

# ---- 加载 .env.acr ----
$AcrRegion     = 'cn-hangzhou'
$AcrRegistry   = 'registry.cn-hangzhou.aliyuncs.com'
$AcrNamespace  = '408master'
$AcrUsername   = ''
$AcrPassword   = ''
$ImageTag      = 'latest'
$Server        = 'root@127.0.0.1'
$Remote        = '/opt/xzs-deploy'

# 加载 .env.acr
$acrEnvFile = Join-Path $DeployDir '.env.acr'
if (Test-Path $acrEnvFile) {
    Get-Content $acrEnvFile | ForEach-Object {
        if ($_ -match '^\s*([^#][^=]+?)\s*=\s*(.+)$') {
            $key = $matches[1].Trim()
            $val = $matches[2].Trim()
            switch ($key) {
                'ACR_REGION'    { $AcrRegion = $val }
                'ACR_REGISTRY'  { $AcrRegistry = $val }
                'ACR_NAMESPACE' { $AcrNamespace = $val }
                'ACR_USERNAME'  { $AcrUsername = $val }
                'ACR_PASSWORD'  { $AcrPassword = $val }
                'IMAGE_TAG'     { $ImageTag = $val }
            }
        }
    }
}

# 加载 .env（服务器配置）
$envFile = Join-Path $DeployDir '.env'
if (Test-Path $envFile) {
    Get-Content $envFile | ForEach-Object {
        if ($_ -match '^\s*([^#][^=]+?)\s*=\s*(.+)$') {
            $key = $matches[1].Trim()
            $val = $matches[2].Trim()
            switch ($key) {
                'SERVER' { $Server = $val }
                'REMOTE' { $Remote = $val }
            }
        }
    }
}

# ---- tag 默认用日期 ----
if (-not $Tag) {
    $Tag = Get-Date -Format 'yyyyMMdd'
}

# ---- 镜像地址 ----
$BackendImage = "${AcrRegistry}/${AcrNamespace}/backend:${Tag}"
$NginxImage   = "${AcrRegistry}/${AcrNamespace}/nginx:${Tag}"

# ---- 输出函数 ----
function Write-Info($msg)  { Write-Host "[INFO]  $msg" -ForegroundColor Cyan }
function Write-Ok($msg)    { Write-Host "[ OK ]  $msg" -ForegroundColor Green }
function Write-Warn($msg)  { Write-Host "[WARN]  $msg" -ForegroundColor Yellow }
function Write-Fail($msg)  { Write-Host "[FAIL]  $msg" -ForegroundColor Red; exit 1 }

function Confirm-Action($msg) {
    if ($y) { return }
    $msg = if ($msg) { "$msg [y/N]" } else { '继续？[y/N]' }
    $ans = Read-Host $msg
    if ($ans -notmatch '^[yY]') { Write-Host '已取消'; exit 0 }
}

# ---- SSH 封装 ----
$SshKey = $null
foreach ($c in @("$env:USERPROFILE\.ssh\id_ed25519", "$env:USERPROFILE\.ssh\id_rsa")) {
    if (Test-Path $c) { $SshKey = $c; break }
}

function Get-SshArgs() {
    $args = @('-o', 'StrictHostKeyChecking=no', '-o', 'BatchMode=yes', '-o', 'ConnectTimeout=10')
    if ($SshKey) { $args += @('-i', $SshKey) }
    return $args
}

function Invoke-Remote([string]$Cmd) {
    $sshArgs = Get-SshArgs
    $allArgs = $sshArgs + @($Server, $Cmd)
    & ssh @allArgs 2>$null
}

# =============================================================================
#  login
# =============================================================================
function Invoke-Login {
    Write-Info "登录 ACR: $AcrRegistry"
    if (-not $AcrUsername -or -not $AcrPassword) {
        Write-Fail '请先在 deploy/.env.acr 中填入 ACR_USERNAME 和 ACR_PASSWORD'
    }
    $env:DOCKER_CLI_HINTS = 'false'
    echo $AcrPassword | docker login --username $AcrUsername --password-stdin $AcrRegistry
    if ($LASTEXITCODE -eq 0) { Write-Ok 'ACR 登录成功' }
    else { Write-Fail 'ACR 登录失败，请检查用户名和密码' }
}

# =============================================================================
#  build
# =============================================================================
function Invoke-Build {
    Write-Info "Backend image: $BackendImage"
    Write-Info "Nginx image:   $NginxImage"
    Write-Host ''

    # 1. 后端镜像
    if (-not $SkipBackend) {
        Write-Info '[1/2] 构建后端镜像...'
        $jarPath = Join-Path $ProjectRoot 'source\xzs\target\xzs-3.9.0.jar'
        if (-not (Test-Path $jarPath)) {
            Write-Fail 'JAR 不存在，请先构建: .\deploy\cloud-update.ps1 build'
        }

        # 复制 JAR 到 deploy 目录（Dockerfile 需要）
        Copy-Item $jarPath (Join-Path $DeployDir 'xzs-3.9.0.jar') -Force

        Push-Location $DeployDir
        docker build -f Dockerfile -t $BackendImage .
        if ($LASTEXITCODE -ne 0) { Pop-Location; Write-Fail '后端镜像构建失败' }
        Pop-Location
        Write-Ok "后端镜像: $BackendImage"
    } else {
        Write-Info '[1/2] 跳过后端镜像 (-SkipBackend)'
    }

    # 2. Nginx 镜像
    if (-not $SkipFrontend) {
        Write-Info '[2/2] 构建 Nginx 镜像（含前端静态文件）...'
        Push-Location $DeployDir
        docker build -f Dockerfile.nginx -t $NginxImage .
        if ($LASTEXITCODE -ne 0) { Pop-Location; Write-Fail 'Nginx 镜像构建失败' }
        Pop-Location
        Write-Ok "Nginx 镜像: $NginxImage"
    } else {
        Write-Info '[2/2] 跳过前端镜像 (-SkipFrontend)'
    }

    Write-Host ''
    Write-Ok '镜像构建完成'
}

# =============================================================================
#  push
# =============================================================================
function Invoke-Push {
    # 确保 ACR 已登录
    Write-Info '检查 ACR 登录状态...'
    $loginCheck = docker info 2>&1 | Select-String $AcrRegistry
    if (-not $loginCheck) {
        Write-Info '未登录 ACR，正在登录...'
        Invoke-Login
    }

    # 构建
    Invoke-Build

    # 推送
    Write-Host ''
    if (-not $SkipBackend) {
        Write-Info "推送后端镜像: $BackendImage"
        docker push $BackendImage
        if ($LASTEXITCODE -ne 0) { Write-Fail '后端镜像推送失败' }
        Write-Ok '后端镜像已推送'
    }

    if (-not $SkipFrontend) {
        Write-Info "推送 Nginx 镜像: $NginxImage"
        docker push $NginxImage
        if ($LASTEXITCODE -ne 0) { Write-Fail 'Nginx 镜像推送失败' }
        Write-Ok 'Nginx 镜像已推送'
    }

    Write-Host ''
    Write-Ok '镜像推送完成'
}

# =============================================================================
#  deploy（服务器拉取并重启）
# =============================================================================
function Invoke-Deploy {
    Write-Info "服务器拉取镜像并重启..."
    Write-Info "Backend: $BackendImage"
    Write-Info "Nginx:   $NginxImage"
    Write-Host ''

    # 在服务器上创建 ACR 专用的 docker-compose
    $composeContent = @"
version: '3'
services:
  mysql:
    image: registry.cn-hangzhou.aliyuncs.com/mindskip/mysql:8.0.33
    container_name: xzs-mysql
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: "doushijiaxiang0."
      MYSQL_DATABASE: "xzs"
      TZ: "Asia/Shanghai"
    volumes:
      - ./mysql-data:/var/lib/mysql
    mem_limit: 512m
    networks:
      - xzs-net

  qdrant:
    image: qdrant/qdrant:latest
    container_name: xzs-qdrant
    restart: always
    volumes:
      - ./qdrant-data:/qdrant/storage
    mem_limit: 512m
    networks:
      - xzs-net

  backend:
    image: ${BackendImage}
    container_name: xzs-backend
    restart: always
    environment:
      SPRING_DATASOURCE_URL: "jdbc:mysql://mysql:3306/xzs?useSSL=false&useUnicode=true&serverTimezone=Asia/Shanghai&characterEncoding=utf8&zeroDateTimeBehavior=convertToNull&allowPublicKeyRetrieval=true&allowMultiQueries=true"
      SPRING_DATASOURCE_USERNAME: "root"
      SPRING_DATASOURCE_PASSWORD: "doushijiaxiang0."
      AI_SECRET_MASTER_KEY: "408MasterLocalSecret"
      TZ: "Asia/Shanghai"
    mem_limit: 512m
    depends_on:
      - mysql
      - qdrant
    networks:
      - xzs-net

  nginx:
    image: ${NginxImage}
    container_name: xzs-nginx
    restart: always
    ports:
      - "80:80"
      - "443:443"
    depends_on:
      - backend
    mem_limit: 128m
    networks:
      - xzs-net

networks:
  xzs-net:
    driver: bridge
"@

    # 登录 ACR（服务器端）
    Write-Info '[1/4] 服务器登录 ACR...'
    Invoke-Remote "echo '$AcrPassword' | docker login --username '$AcrUsername' --password-stdin $AcrRegistry 2>/dev/null"

    # 上传 docker-compose 文件
    Write-Info '[2/4] 上传 docker-compose 配置...'
    $tmpCompose = Join-Path $env:TEMP 'docker-compose-acr.yml'
    $composeContent | Set-Content $tmpCompose -Encoding UTF8
    $sshArgs = Get-SshArgs
    $allArgs = $sshArgs + @($tmpCompose, "${Server}:${Remote}/docker-compose.yml")
    & scp @allArgs

    # 拉取并重启
    Write-Info '[3/4] 拉取新镜像...'
    Invoke-Remote "cd $Remote && docker compose pull 2>/dev/null"

    Write-Info '[4/4] 重启服务...'
    Invoke-Remote "cd $Remote && docker compose up -d"

    # 检查状态
    Start-Sleep -Seconds 10
    Write-Host ''
    Invoke-Remote "docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'"

    $ip = $Server -replace '^.*@', ''
    Write-Host ''
    Write-Ok '部署完成！'
    Write-Host "  学生端: http://${ip}/student/"
    Write-Host "  管理端: http://${ip}/admin/"
}

# =============================================================================
#  status
# =============================================================================
function Invoke-Status {
    Write-Info '云端服务状态:'
    Invoke-Remote "docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'"
    Write-Host ''
    Write-Info '镜像信息:'
    Invoke-Remote "docker images --format 'table {{.Repository}}\t{{.Tag}}\t{{.Size}}' | grep 408master"
}

# =============================================================================
#  主流程
# =============================================================================
Write-Host ''
Write-Host '╔═══════════════════════════════════════════════╗' -ForegroundColor Green
Write-Host '║     408Master ACR 镜像部署工具 v1.0            ║' -ForegroundColor Green
Write-Host '╠═══════════════════════════════════════════════╣' -ForegroundColor Green
Write-Host ('║  ACR:      {0,-34}║' -f "$AcrNamespace ($AcrRegion)") -ForegroundColor Green
Write-Host ('║  Tag:      {0,-34}║' -f $Tag) -ForegroundColor Green
Write-Host ('║  后端镜像: {0,-34}║' -f $BackendImage) -ForegroundColor Green
Write-Host ('║  Nginx:    {0,-34}║' -f $NginxImage) -ForegroundColor Green
Write-Host '╚═══════════════════════════════════════════════╝' -ForegroundColor Green

switch ($Command) {
    'login'  { Invoke-Login }
    'build'  { Invoke-Build }
    'push'   { Invoke-Push }
    'full'   {
        Invoke-Push
        Write-Host ''
        Confirm-Action '镜像已推送，是否在服务器上部署？'
        Invoke-Deploy
    }
    'deploy' { Invoke-Deploy }
    'status' { Invoke-Status }
}
