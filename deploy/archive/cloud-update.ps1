# 408Master 云端 Docker 部署脚本 (PowerShell 版)
#
# 注意:
#   这个脚本用于云端 Docker 部署，会操作远程服务器、Docker Compose 和数据库。
#   它不是本地 Spring Boot 开发启动脚本。
#   日常开发 Java 接口时请优先使用:
#     cd source\xzs
#     mvn spring-boot:run -Dspring-boot.run.profiles=dev
#
# 用法: .\deploy\cloud-update.ps1 [命令] [选项]
#
# 命令:
#   doctor      部署前环境诊断
#   setup-key   配置 SSH 免密登录
#   build       只做本地构建
#   upload      只上传已构建的产物
#   deploy      远端部署
#   full        构建 + 上传 + 远端部署（默认，强制构建）
#   status      查看云端服务状态
#   upload-qdrant 上传并替换云端 Qdrant 向量数据
#   setup-ssl   为 wx.hhhuu.com 签发并启用 HTTPS 证书
#   renew-ssl   续期 wx.hhhuu.com HTTPS 证书
#   reset-db    用本地快照重置云端数据库
#   rollback    回滚到上次数据库备份
#   logs        查看后端日志
#   ssh         直接 SSH 进服务器
#
# 选项:
#   -y                    跳过确认提示
#   -SkipBuild            跳过本地构建
#   -SkipFrontend         跳过前端上传
#   -SkipMigration        跳过 SQL 导入
#   -NoBackup             跳过数据库备份
#   -ForceBuild           强制重建（仅 build 命令）

[CmdletBinding()]
param(
    [Parameter(Position=0)]
    [ValidateSet('doctor','setup-key','build','upload','deploy','full','status','upload-qdrant','setup-ssl','renew-ssl','reset-db','rollback','logs','ssh')]
    [string]$Command = 'full',

    [switch]$y,
    [switch]$SkipBuild,
    [switch]$SkipFrontend,
    [switch]$SkipMigration,
    [switch]$NoBackup,
    [switch]$ForceBuild
)

$ErrorActionPreference = 'Continue'

# ---- 路径常量 ----
$DeployDir   = if ($PSScriptRoot) { $PSScriptRoot } else { Join-Path $PWD 'deploy' }
$ProjectRoot = Split-Path $DeployDir -Parent
$SqlDir      = Join-Path $ProjectRoot 'database\current'
$SslDomain   = 'wx.hhhuu.com'

# ---- 加载 .env ----
$Server   = 'root@127.0.0.1'
$Remote   = '/opt/xzs-deploy'
$MysqlPwd = ''
$MysqlUser = 'root'
$MysqlDb   = 'xzs'

$envFile = Join-Path $DeployDir '.env'
if (Test-Path $envFile) {
    Get-Content $envFile | ForEach-Object {
        if ($_ -match '^\s*([^#][^=]+?)\s*=\s*(.+)$') {
            $key = $matches[1].Trim()
            $val = $matches[2].Trim()
            switch ($key) {
                'SERVER'     { $Server    = $val }
                'REMOTE'     { $Remote    = $val }
                'MYSQL_PWD'  { $MysqlPwd  = $val }
                'MYSQL_USER' { $MysqlUser = $val }
                'MYSQL_DB'   { $MysqlDb   = $val }
            }
        }
    }
}

# ---- 输出函数 ----
function Write-Info($msg)  { Write-Host "[INFO]  $msg" -ForegroundColor Cyan }
function Write-Ok($msg)    { Write-Host "[ OK ]  $msg" -ForegroundColor Green }
function Write-Warn($msg)  { Write-Host "[WARN]  $msg" -ForegroundColor Yellow }
function Write-Fail($msg)  { Write-Host "[FAIL]  $msg" -ForegroundColor Red; exit 1 }

function Write-Separator($title) {
    Write-Host ''
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "  $title" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
}

function Confirm-Action($msg) {
    if ($y) { return }
    $msg = if ($msg) { "$msg [y/N]" } else { '继续？[y/N]' }
    $ans = Read-Host $msg
    if ($ans -notmatch '^[yY]') { Write-Host '已取消'; exit 0 }
}

# ---- SSH 封装 ----
$SshKey = $null
$keyUser = $env:USERNAME
$candidates = @(
    "$env:USERPROFILE\.ssh\id_ed25519"
    "$env:USERPROFILE\.ssh\id_rsa"
)
foreach ($c in $candidates) {
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
    return $LASTEXITCODE
}

function Invoke-RemoteOutput([string]$Cmd) {
    $sshArgs = Get-SshArgs
    $allArgs = $sshArgs + @($Server, $Cmd)
    return (& ssh @allArgs)
}

function Invoke-RemoteVisible([string]$Cmd) {
    $sshArgs = Get-SshArgs
    $allArgs = $sshArgs + @($Server, $Cmd)
    & ssh @allArgs
    return $LASTEXITCODE
}

function Send-Upload([string[]]$Paths, [string]$Dest) {
    $sshArgs = Get-SshArgs
    $allArgs = $sshArgs + @($Paths; $Dest)
    & scp @allArgs 2>$null
    return $LASTEXITCODE
}

function Send-RemoteText([string]$Content, [string]$Path) {
    $normalized = $Content -replace "`r", ''
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($normalized)
    $encoded = [Convert]::ToBase64String($bytes)
    $cmd = "printf %s '$encoded' | base64 -d > '$Path'"
    return Invoke-Remote $cmd
}

function Test-DomainResolvesToServer([string]$Domain) {
    $expectedIp = $Server -replace '^.*@', ''
    Write-Info "检查 DNS: $Domain -> $expectedIp"
    $addresses = @()
    try {
        $records = Resolve-DnsName $Domain -Type A -ErrorAction Stop
        $addresses = @($records | Where-Object { $_.IPAddress } | ForEach-Object { $_.IPAddress })
    } catch {
        try {
            $addresses = [System.Net.Dns]::GetHostAddresses($Domain) |
                Where-Object { $_.AddressFamily -eq [System.Net.Sockets.AddressFamily]::InterNetwork } |
                ForEach-Object { $_.IPAddressToString }
        } catch {
            Write-Fail "无法解析域名: $Domain"
        }
    }

    if ($addresses -notcontains $expectedIp) {
        Write-Fail "DNS 未指向当前服务器。当前解析: $($addresses -join ', '), 期望: $expectedIp"
    }
    Write-Ok "DNS 已指向 $expectedIp"
}

function Get-NginxChallengeConfig {
@"
server {
    listen 80 default_server;
    server_name _;

    root /usr/share/nginx/html;
    index index.html;

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
        try_files `$uri =404;
    }

    location /api/ {
        resolver 127.0.0.11 valid=30s ipv6=off;
        set `$backend_upstream http://backend:8000;
        proxy_pass `$backend_upstream;
        proxy_set_header Host `$host;
        proxy_set_header X-Real-IP `$remote_addr;
        proxy_set_header X-Forwarded-For `$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto `$scheme;
        proxy_buffering off;
        proxy_cache off;
        gzip off;
        add_header X-Accel-Buffering no;
        proxy_read_timeout 300s;
        proxy_connect_timeout 30s;
    }

    location /student {
        alias /usr/share/nginx/html/student;
        try_files `$uri `$uri/ /student/index.html;
    }

    location /admin {
        alias /usr/share/nginx/html/admin;
        try_files `$uri `$uri/ /admin/index.html;
    }

    location /images/ {
        alias /usr/share/nginx/html/images/;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }

    location = / {
        return 302 /student/index;
    }
}

server {
    listen 80;
    server_name $SslDomain;

    root /usr/share/nginx/html;
    index index.html;

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
        try_files `$uri =404;
    }

    location /api/ {
        resolver 127.0.0.11 valid=30s ipv6=off;
        set `$backend_upstream http://backend:8000;
        proxy_pass `$backend_upstream;
        proxy_set_header Host `$host;
        proxy_set_header X-Real-IP `$remote_addr;
        proxy_set_header X-Forwarded-For `$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto `$scheme;
        proxy_buffering off;
        proxy_cache off;
        gzip off;
        add_header X-Accel-Buffering no;
        proxy_read_timeout 300s;
        proxy_connect_timeout 30s;
    }

    location /student {
        alias /usr/share/nginx/html/student;
        try_files `$uri `$uri/ /student/index.html;
    }

    location /admin {
        alias /usr/share/nginx/html/admin;
        try_files `$uri `$uri/ /admin/index.html;
    }

    location /images/ {
        alias /usr/share/nginx/html/images/;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }

    location = / {
        return 302 /student/index;
    }
}
"@
}

function Get-DeploySqlFiles {
    $names = @(
        '01_schema.sql',
        '02_seed.sql',
        '03_questions_and_exams.sql',
        '04_knowledge_and_rag.sql',
        '05_student_data.sql',
        '06_schema_fix.sql'
    )
    $files = @()
    foreach ($name in $names) {
        $path = Join-Path $SqlDir $name
        if (-not (Test-Path $path)) {
            Write-Fail "缺少 SQL 文件: $path"
        }
        $files += Get-Item $path
    }
    return $files
}

function Import-RemoteSqlFiles {
    $sqlNames = @(
        '01_schema.sql',
        '02_seed.sql',
        '03_questions_and_exams.sql',
        '04_knowledge_and_rag.sql',
        '05_student_data.sql',
        '06_schema_fix.sql'
    )
    foreach ($name in $sqlNames) {
        $remoteFile = "$Remote/sql/$name"
        $exists = Invoke-Remote "test -f '$remoteFile'"
        if ($exists -ne 0) {
            Write-Fail "远端 SQL 文件不存在: $remoteFile"
        }
        Write-Info "  导入 $name ..."
        $code = Invoke-Remote "docker exec -i xzs-mysql mysql -u $MysqlUser -p'$MysqlPwd' $MysqlDb < '$remoteFile'"
        if ($code -ne 0) {
            Write-Fail "导入失败: $name"
        }
    }
}

function Backup-RemoteDatabase([string]$Prefix) {
    $ts = Get-Date -Format 'yyyyMMdd_HHmmss'
    $backupFile = "${Prefix}_${ts}.sql"
    $code = Invoke-Remote "cd $Remote && docker exec xzs-mysql mysqldump -u $MysqlUser -p'$MysqlPwd' --single-transaction $MysqlDb > $backupFile"
    if ($code -ne 0) {
        Write-Fail "数据库备份失败: $backupFile"
    }
    Write-Ok "备份完成: $backupFile"
    return $backupFile
}

function Reset-RemoteDatabaseFromCurrentSql {
    Write-Info '清空并按固定顺序导入 current SQL...'
    $code = Invoke-Remote "cd $Remote && docker exec -i xzs-mysql mysql -u $MysqlUser -p'$MysqlPwd' -e 'DROP DATABASE IF EXISTS $MysqlDb; CREATE DATABASE $MysqlDb DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci;'"
    if ($code -ne 0) {
        Write-Fail '重建数据库失败'
    }
    Import-RemoteSqlFiles
    Write-Ok '数据库已导入'
}

function Test-RemoteDatabaseData {
    Write-Info '验证数据库关键表...'
    $remoteScript = @"
set -e
docker exec -e MYSQL_PWD='$MysqlPwd' xzs-mysql mysql -u '$MysqlUser' '$MysqlDb' <<'SQL'
SELECT 't_user' AS tbl, COUNT(*) AS cnt FROM t_user
UNION ALL SELECT 't_question', COUNT(*) FROM t_question
UNION ALL SELECT 't_exam_paper', COUNT(*) FROM t_exam_paper
UNION ALL SELECT 'knowledge_point', COUNT(*) FROM knowledge_point
UNION ALL SELECT 'rag_chunk', COUNT(*) FROM rag_chunk;
SQL
"@
    $remoteScript = $remoteScript -replace "`r", ''
    $remoteBytes = [System.Text.Encoding]::UTF8.GetBytes($remoteScript)
    $remoteEncoded = [Convert]::ToBase64String($remoteBytes)
    $remoteCmd = "printf %s '$remoteEncoded' | base64 -d | bash"
    $sshArgs = Get-SshArgs
    $allArgs = $sshArgs + @($Server, $remoteCmd)
    & ssh @allArgs
    if ($LASTEXITCODE -ne 0) {
        Write-Fail '数据库验证失败'
    }
    Write-Ok '数据验证完成'
}

# rsync 不一定在 Windows 上可用，用 scp -r 替代
function Send-Dir([string]$SrcDir, [string]$Dest) {
    # 尝试 rsync，失败则回退到 scp -r
    $sshArgs = Get-SshArgs
    $sshStr = ($sshArgs -join ' ')
    $rsyncArgs = @('-avz', '-e', "ssh $sshStr", '--delete', $SrcDir, $Dest)
    try {
        & rsync @rsyncArgs 2>$null
    } catch {
        Write-Warn 'rsync 不可用，使用 scp -r（非增量，会较慢）'
        $scpArgs = Get-SshArgs
        $scpArgs += @('-r', $SrcDir.TrimEnd('\'), $Dest)
        & scp @scpArgs 2>$null
    }
}

# ---- 命令实现 ----

function Invoke-Doctor {
    Write-Separator '部署环境诊断'

    Write-Host ''
    Write-Info '=== 本地环境 ==='
    Write-Info "运行环境: PowerShell $($PSVersionTable.PSVersion)"
    Write-Info "用户: $env:USERNAME"
    Write-Info "路径: $PWD"
    Write-Host ''

    Write-Info '=== 本地命令 ==='
    foreach ($cmd in @('ssh','scp','java','mvn','npm','rsync')) {
        $found = Get-Command $cmd -ErrorAction SilentlyContinue
        if ($found) { Write-Ok "$cmd`: $($found.Source)" }
        else { Write-Warn "$cmd`: 未找到" }
    }
    Write-Host ''

    Write-Info '=== Java / Maven ==='
    $javaCmd = Get-Command java -ErrorAction SilentlyContinue
    if ($javaCmd) {
        $javaver = (cmd /c 'java -version 2>&1' | Select-Object -First 1)
        Write-Info $javaver
    }
    $mvnCmd = Get-Command mvn -ErrorAction SilentlyContinue
    if ($mvnCmd) {
        $mvnver = (cmd /c 'mvn -version 2>&1' | Select-Object -First 2) -join ', '
        Write-Info $mvnver
    }
    else { Write-Warn 'Maven 不可用，常见原因是 JAVA_HOME 配置错误' }
    Write-Host ''

    Write-Info '=== SSH 配置 ==='
    Write-Info "SSH_KEY: $(if ($SshKey) { $SshKey } else { '未找到' })"
    if ($SshKey) {
        if (Test-Path $SshKey) { Write-Ok '密钥文件存在' }
        else { Write-Warn "密钥文件不存在: $SshKey" }
    } else {
        Write-Warn "未找到 SSH 密钥，已搜索: $env:USERPROFILE\.ssh\"
    }
    Write-Host ''

    Write-Info '=== .env 配置 ==='
    if (Test-Path $envFile) {
        Write-Ok "$envFile 已加载"
        Write-Info "SERVER=$Server"
        Write-Info "REMOTE=$Remote"
        Write-Info "MYSQL_DB=$MysqlDb"
    } else {
        Write-Warn "$envFile 不存在，请复制 .env.example 并填入真实值"
    }
    Write-Host ''

    Write-Info '=== SSH 连接测试 ==='
    $result = Invoke-Remote 'echo OK' 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Ok 'SSH 连接成功'
    } else {
        Write-Warn 'SSH 连接失败'
        $sshArgs = Get-SshArgs
        Write-Host "  实际命令: ssh $($sshArgs -join ' ') $Server 'echo OK'"
        Write-Host '  如果是密钥问题，运行: .\deploy\cloud-update.ps1 setup-key'
    }
    Write-Host ''

    Write-Info '=== 远端环境 ==='
    if ($LASTEXITCODE -eq 0 -or (Invoke-Remote 'echo OK' 2>$null)) {
        Invoke-Remote 'echo "Docker: $(docker --version 2>/dev/null || echo 未安装)"'
        Invoke-Remote 'echo "Compose: $(docker compose version 2>/dev/null || echo 未安装)"'
        Invoke-Remote 'df -h / | tail -1'
        Invoke-Remote 'free -h | grep Mem'
    } else {
        Write-Warn 'SSH 不通，跳过远端检查'
    }
}

function Invoke-SetupKey {
    Write-Separator '配置 SSH 免密登录'

    Write-Info "当前运行环境: PowerShell"
    Write-Info "用户: $env:USERNAME"
    Write-Info "SSH key: $(if ($SshKey) { $SshKey } else { '无' })"
    Write-Host ''

    $keyFile = if ($SshKey) { $SshKey } else { Join-Path $env:USERPROFILE '.ssh\id_ed25519' }
    $keyPub = "$keyFile.pub"

    if (-not (Test-Path $keyFile)) {
        Write-Info '未找到 SSH key，生成新的 ed25519 key...'
        & ssh-keygen -t ed25519 -f $keyFile -N '""' -C '408master-deploy'
        Write-Ok "SSH key 已生成: $keyFile"
    } else {
        Write-Ok "已有 SSH key: $keyFile"
    }

    Write-Host ''
    Write-Info "公钥路径: $keyPub"
    Write-Info '公钥内容:'
    Get-Content $keyPub
    Write-Host ''

    Write-Warn "将公钥复制到服务器 ${Server}:"
    Write-Host ''
    Write-Host '  1. SSH 登录服务器:'
    Write-Host "     ssh $Server"
    Write-Host ''
    Write-Host '  2. 在服务器上执行:'
    Write-Host '     mkdir -p ~/.ssh && chmod 700 ~/.ssh'
    $pubContent = (Get-Content $keyPub -Raw).Trim()
    Write-Host "     echo ""$pubContent"" >> ~/.ssh/authorized_keys"
    Write-Host '     chmod 600 ~/.ssh/authorized_keys'
    Write-Host ''
    Write-Host '  3. 验证免密登录:'
    Write-Host "     ssh $Server 'echo 免密登录成功'"
}

function Invoke-Build {
    Write-Separator '本地构建'

    $force = $ForceBuild -or ($Command -eq 'full')

    # 1. JAR
    $jar = Join-Path $ProjectRoot 'source\xzs\target\xzs-3.9.0.jar'
    if ($force -or -not (Test-Path $jar)) {
        Write-Info '构建后端 JAR...'
        Push-Location (Join-Path $ProjectRoot 'source\xzs')
        cmd /c 'mvn package -DskipTests -q'
        if ($LASTEXITCODE -ne 0) { Pop-Location; Write-Fail '后端 JAR 构建失败，请检查 JAVA_HOME / Maven' }
        Pop-Location
        if (-not (Test-Path $jar)) { Write-Fail 'Maven 执行结束，但未生成 JAR' }
        $size = (Get-Item $jar).Length / 1MB
        Write-Ok ("JAR: {0:N0} MB" -f $size)
    } else {
        $size = (Get-Item $jar).Length / 1MB
        Write-Info ("后端 JAR 已存在 ({0:N0} MB)，跳过构建" -f $size)
    }

    # 2. 学生端
    $studentDist = Join-Path $ProjectRoot 'source\vue\xzs-student\dist\index.html'
    if ($force -or -not (Test-Path $studentDist)) {
        Write-Info '构建学生端前端...'
        Push-Location (Join-Path $ProjectRoot 'source\vue\xzs-student')
        cmd /c 'npm install --registry=https://registry.npmmirror.com --silent 2>nul'
        cmd /c 'npm run build 2>&1' | Select-Object -Last 1
        if ($LASTEXITCODE -ne 0) { Pop-Location; Write-Fail '学生端前端构建失败' }
        Pop-Location
        if (-not (Test-Path $studentDist)) { Write-Fail '学生端构建完成，但未生成 dist/index.html' }
        Write-Ok '学生端构建完成'
    } else {
        Write-Info '学生端 dist 已存在，跳过构建'
    }

    # 3. 管理端
    $adminDist = Join-Path $ProjectRoot 'source\vue\xzs-admin\dist\index.html'
    if ($force -or -not (Test-Path $adminDist)) {
        Write-Info '构建管理端前端...'
        Push-Location (Join-Path $ProjectRoot 'source\vue\xzs-admin')
        '' | Set-Content '.env.production' -Encoding UTF8
        cmd /c 'npm install --registry=https://registry.npmmirror.com --silent 2>nul'
        cmd /c 'npm run build 2>&1' | Select-Object -Last 1
        if ($LASTEXITCODE -ne 0) { Pop-Location; Write-Fail '管理端前端构建失败' }
        Pop-Location
        if (-not (Test-Path $adminDist)) { Write-Fail '管理端构建完成，但未生成 dist/index.html' }
        Write-Ok '管理端构建完成'
    } else {
        Write-Info '管理端 dist 已存在，跳过构建'
    }

    # 4. 同步 SQL
    Write-Info '同步 deploy\sql\ <- database\current\'
    $sqlDest = Join-Path $DeployDir 'sql'
    if (-not (Test-Path $sqlDest)) { New-Item $sqlDest -ItemType Directory -Force | Out-Null }
    Get-ChildItem (Join-Path $sqlDest '*.sql') -ErrorAction SilentlyContinue | Remove-Item -Force
    foreach ($f in Get-DeploySqlFiles) {
        Copy-Item $f.FullName $sqlDest
    }
    $count = (Get-ChildItem (Join-Path $sqlDest '*.sql')).Count
    Write-Ok "已同步 $count 个 SQL 文件"

    Write-Host ''
    Write-Ok '本地构建全部完成'
}

function Invoke-Upload {
    Write-Separator "上传文件到 $Server"

    Write-Info "SSH_KEY: $(if ($SshKey) { $SshKey } else { '使用默认配置' })"

    Write-Info '测试 SSH 连接...'
    $null = Invoke-Remote 'echo OK' 2>&1
    if ($LASTEXITCODE -ne 0) {
        $sshArgs = Get-SshArgs
        Write-Host "  实际命令: ssh $($sshArgs -join ' ') $Server 'echo OK'"
        Write-Fail "无法连接 $Server，请先运行: .\deploy\cloud-update.ps1 doctor"
    }
    Write-Ok 'SSH 连接正常'

    Invoke-Remote "mkdir -p $Remote/{static/student,static/admin,sql,logs,qdrant-data,ssl,certbot/www}"

    # 1. 部署配置
    Write-Info '[1/5] 上传部署配置...'
    $configs = @(
        (Join-Path $DeployDir 'docker-compose.yml'),
        (Join-Path $DeployDir 'Dockerfile'),
        (Join-Path $DeployDir 'nginx.conf')
    )
    Send-Upload $configs "${Server}:${Remote}/"
    Write-Ok '配置文件已上传'

    # 2. JAR
    Write-Info '[2/5] 上传后端 JAR...'
    $jar = Join-Path $ProjectRoot 'source\xzs\target\xzs-3.9.0.jar'
    Send-Upload $jar "${Server}:${Remote}/"
    Write-Ok 'JAR 已上传'

    # 3. 学生端
    if (-not $SkipFrontend) {
        Write-Info '[3/5] 上传学生端前端...'
        Send-Dir (Join-Path $ProjectRoot 'source\vue\xzs-student\dist\') "${Server}:${Remote}/static/student/"
        Write-Ok '学生端已同步'
    } else {
        Write-Info '[3/5] 跳过学生端上传 (-SkipFrontend)'
    }

    # 4. 管理端
    if (-not $SkipFrontend) {
        Write-Info '[4/5] 上传管理端前端...'
        Send-Dir (Join-Path $ProjectRoot 'source\vue\xzs-admin\dist\') "${Server}:${Remote}/static/admin/"
        Write-Ok '管理端已同步'
    } else {
        Write-Info '[4/5] 跳过管理端上传 (-SkipFrontend)'
    }

    # 5. SQL
    Write-Info '[5/5] 上传 SQL 文件...'
    Invoke-Remote "mkdir -p '$Remote/sql' && rm -f '$Remote/sql'/0*.sql"
    $sqlFiles = Get-DeploySqlFiles
    foreach ($f in $sqlFiles) {
        $code = Send-Upload @($f.FullName) "${Server}:${Remote}/sql/"
        if ($code -ne 0) {
            Write-Fail "SQL 文件上传失败: $($f.Name)"
        }
    }
    Write-Ok "SQL 文件已上传 ($($sqlFiles.Count) 个)"

    Write-Host ''
    Write-Ok '全部上传完成'
}

function Wait-MysqlReady {
    $retries = 0
    $maxRetries = 30
    Write-Info '等待 MySQL 就绪...'
    while ($retries -lt $maxRetries) {
        $null = Invoke-Remote "docker exec xzs-mysql mysqladmin ping -u$MysqlUser -p'$MysqlPwd' --silent" 2>&1
        if ($LASTEXITCODE -eq 0) { Write-Ok 'MySQL 已就绪'; return }
        $retries++
        Write-Host -NoNewline '.'
        Start-Sleep -Seconds 3
    }
    Write-Host ''
    Write-Fail 'MySQL 启动超时（90秒）'
}

function Invoke-Deploy {
    Write-Separator "远端部署 $Server`:$Remote"

    # 检查 MySQL 容器
    $mysqlOut = Invoke-RemoteOutput "docker ps -a --format '{{.Names}}'" 2>$null
    $mysqlExists = $mysqlOut -match 'xzs-mysql'

    # Step 1: 备份
    if (-not $NoBackup -and $mysqlExists) {
        Write-Info '[1/7] 备份数据库...'
        $null = Backup-RemoteDatabase 'backup'
        # 清理旧备份
        Invoke-Remote "cd $Remote && ls -t backup_*.sql 2>/dev/null | tail -n +4 | xargs -r rm -f"
    } else {
        if (-not $mysqlExists) { Write-Warn '[1/7] 未发现 xzs-mysql 容器（首次部署），跳过备份' }
        else { Write-Warn '[1/7] 跳过备份 (-NoBackup)' }
    }

    # Step 2: 停旧服务
    Write-Info '[2/7] 停止旧服务...'
    Invoke-Remote "cd $Remote && docker stop xzs-backend 2>/dev/null || true; docker rm xzs-backend 2>/dev/null || true; systemctl stop nginx 2>/dev/null || true; systemctl disable nginx 2>/dev/null || true"
    Write-Ok '旧服务已停止'

    # Step 3: 确保 MySQL 运行
    Write-Info '[3/7] 启动 MySQL...'
    if (-not $mysqlExists) {
        Invoke-Remote "cd $Remote && docker compose up -d mysql"
    }
    Wait-MysqlReady

    # Step 4: 导入 SQL
    if (-not $SkipMigration) {
        Write-Info '[4/7] 导入 SQL...'
        Reset-RemoteDatabaseFromCurrentSql
    } else {
        Write-Info '[4/7] 跳过 SQL 导入 (-SkipMigration)'
    }

    # Step 5: 验证
    Write-Info '[5/7] 验证数据库...'
    Test-RemoteDatabaseData

    # Step 6: 启动 Docker
    Write-Info '[6/7] 启动 Docker 服务...'
    Invoke-Remote "cd $Remote && mkdir -p qdrant-data logs ssl && docker compose build backend --quiet && docker compose up -d"
    Write-Ok 'Docker 服务已启动'

    # Step 7: 等待后端
    Write-Info '[7/7] 等待后端启动...'
    $retries = 0
    while ($retries -lt 15) {
        $logs = Invoke-Remote "docker logs xzs-backend 2>&1" 2>$null
        if ($logs -match 'Started XzsApplication') { Write-Ok '后端启动成功'; break }
        $retries++
        Write-Host -NoNewline '.'
        Start-Sleep -Seconds 5
    }
    Write-Host ''
    if ($retries -ge 15) { Write-Warn '后端启动超时（75秒），请手动检查' }

    # 健康检查
    Write-Host ''
    $ip = $Server -replace '^.*@', ''
    Write-Host "  学生端: http://${ip}/student/"
    Write-Host "  管理端: http://${ip}/admin/"
    Write-Host ''
    Write-Ok '部署完成！'
}

function Invoke-Status {
    Write-Separator '云端服务状态'
    Write-Host ''
    Write-Info 'Docker 容器:'
    Invoke-Remote "docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'"
    Write-Host ''
    Write-Info '磁盘:'
    Invoke-Remote 'df -h / | tail -1'
    Write-Host ''
    Write-Info '内存:'
    Invoke-Remote 'free -h | grep Mem'
    Write-Host ''
    Write-Info '数据库:'
    Invoke-Remote "docker exec xzs-mysql mysql -u $MysqlUser -p'$MysqlPwd' $MysqlDb -e `"SELECT 't_question' AS tbl, COUNT(*) AS cnt FROM t_question UNION ALL SELECT 't_exam_paper', COUNT(*) FROM t_exam_paper UNION ALL SELECT 'knowledge_point', COUNT(*) FROM knowledge_point;`""
}

function Invoke-UploadQdrant {
    Write-Separator '上传 Qdrant 向量数据'

    $qdrantDir = Join-Path $DeployDir 'qdrant-data'
    $archive = Join-Path $DeployDir 'qdrant-data.tar.gz'

    Write-Info "本地 Qdrant 数据目录: $qdrantDir"
    if (-not (Test-Path $qdrantDir -PathType Container)) {
        Write-Fail "本地 qdrant-data 不存在: $qdrantDir"
    }
    Write-Ok '本地 qdrant-data 存在'

    Write-Info '测试 SSH 连接...'
    $null = Invoke-Remote 'echo OK' 2>&1
    if ($LASTEXITCODE -ne 0) {
        $sshArgs = Get-SshArgs
        Write-Host "  实际命令: ssh $($sshArgs -join ' ') $Server 'echo OK'"
        Write-Fail "无法连接 $Server，请先运行: .\deploy\cloud-update.ps1 doctor"
    }
    Write-Ok 'SSH 连接正常'

    if (Test-Path $archive) {
        Write-Info '删除旧压缩包 qdrant-data.tar.gz...'
        Remove-Item $archive -Force
    }

    Write-Info '压缩 qdrant-data -> qdrant-data.tar.gz...'
    Push-Location $DeployDir
    & tar -czf 'qdrant-data.tar.gz' 'qdrant-data'
    $tarCode = $LASTEXITCODE
    Pop-Location
    if ($tarCode -ne 0 -or -not (Test-Path $archive)) {
        Write-Fail 'Qdrant 数据压缩失败'
    }

    $archiveSize = (Get-Item $archive).Length / 1MB
    Write-Ok ("压缩包大小: {0:N2} MB" -f $archiveSize)

    Write-Info "上传压缩包到 ${Server}:${Remote}/qdrant-data.tar.gz ..."
    $uploadCode = Send-Upload @($archive) "${Server}:${Remote}/qdrant-data.tar.gz"
    if ($uploadCode -ne 0) {
        Write-Fail 'Qdrant 压缩包上传失败'
    }
    Write-Ok '压缩包上传完成'

    Write-Info '云端停止、备份、替换并重启 Qdrant...'
    $remoteScript = @'
set -e
cd __REMOTE__
echo "[INFO] Remote directory: $(pwd)"
docker compose stop qdrant
backup=""
if [ -d qdrant-data ]; then
  backup="qdrant-data.bak.$(date +%Y%m%d-%H%M%S)"
  mv qdrant-data "$backup"
  echo "[OK] Backup: $backup"
else
  echo "[WARN] Existing qdrant-data not found, skip backup"
fi
rm -rf qdrant-data
tar -xzf qdrant-data.tar.gz
chmod -R 777 qdrant-data
docker compose up -d qdrant
echo "[INFO] 等待 Qdrant HTTP 就绪..."
for i in $(seq 1 30); do
  if curl -fsS http://127.0.0.1:6333/collections >/tmp/qdrant_collections.json; then
    break
  fi
  sleep 1
done
echo "[INFO] Qdrant containers:"
docker compose ps qdrant
echo "[INFO] Collections:"
cat /tmp/qdrant_collections.json
echo
echo "[INFO] Collection xzs_408_chunks:"
curl -fsS http://127.0.0.1:6333/collections/xzs_408_chunks
echo
'@
    $remoteScript = $remoteScript.Replace('__REMOTE__', $Remote) -replace "`r", ''
    $remoteBytes = [System.Text.Encoding]::UTF8.GetBytes($remoteScript)
    $remoteEncoded = [Convert]::ToBase64String($remoteBytes)
    $remoteCmd = "printf %s '$remoteEncoded' | base64 -d | bash"
    $sshArgs = Get-SshArgs
    $allArgs = $sshArgs + @($Server, $remoteCmd)
    & ssh @allArgs
    if ($LASTEXITCODE -ne 0) {
        Write-Fail '云端 Qdrant 数据替换失败'
    }

    Write-Host ''
    Write-Ok 'Qdrant 数据迁移完成'
}

function Invoke-SetupSsl {
    Write-Separator "配置 HTTPS 证书: $SslDomain"

    Test-DomainResolvesToServer $SslDomain

    Write-Info '测试 SSH 连接...'
    $null = Invoke-Remote 'echo OK' 2>&1
    if ($LASTEXITCODE -ne 0) {
        $sshArgs = Get-SshArgs
        Write-Host "  实际命令: ssh $($sshArgs -join ' ') $Server 'echo OK'"
        Write-Fail "无法连接 $Server，请先运行: .\deploy\cloud-update.ps1 doctor"
    }
    Write-Ok 'SSH 连接正常'

    Write-Info '创建远端 SSL / Certbot 目录...'
    $code = Invoke-Remote "mkdir -p '$Remote/ssl/letsencrypt' '$Remote/certbot/www/.well-known/acme-challenge'"
    if ($code -ne 0) { Write-Fail '远端目录创建失败' }
    Write-Ok '远端目录已就绪'

    Write-Info '上传 docker-compose.yml（包含 certbot webroot 挂载）...'
    $composePath = Join-Path $DeployDir 'docker-compose.yml'
    $code = Send-Upload @($composePath) "${Server}:${Remote}/docker-compose.yml"
    if ($code -ne 0) { Write-Fail 'docker-compose.yml 上传失败' }
    Write-Ok 'docker-compose.yml 已上传'

    Write-Info '应用 HTTP challenge 临时 Nginx 配置...'
    $challengeConfig = Get-NginxChallengeConfig
    $code = Send-RemoteText $challengeConfig "$Remote/nginx.conf"
    if ($code -ne 0) { Write-Fail '写入临时 Nginx 配置失败' }
    $code = Invoke-RemoteVisible "cd '$Remote' && docker compose up -d --no-deps --force-recreate nginx && docker exec xzs-nginx nginx -t"
    if ($code -ne 0) { Write-Fail '临时 Nginx 配置启动失败' }
    Write-Ok 'HTTP challenge 配置已启用'

    Write-Info '验证 HTTP challenge 路径可被公网访问...'
    $token = "codex-ssl-check-$([Guid]::NewGuid().ToString('N'))"
    $remoteTokenCmd = "mkdir -p '$Remote/certbot/www/.well-known/acme-challenge' && printf %s '$token' > '$Remote/certbot/www/.well-known/acme-challenge/codex-ssl-check.txt'"
    $code = Invoke-Remote $remoteTokenCmd
    if ($code -ne 0) { Write-Fail '写入 challenge 测试文件失败' }
    $challengeUrl = "http://$SslDomain/.well-known/acme-challenge/codex-ssl-check.txt"
    $challengeBody = (& curl.exe -fsS --max-time 15 $challengeUrl 2>$null)
    if ($LASTEXITCODE -ne 0 -or "$challengeBody" -ne $token) {
        Write-Fail "HTTP challenge 访问失败: $challengeUrl"
    }
    Write-Ok 'HTTP challenge 路径验证通过'

    Write-Info '运行 Certbot 签发证书（Let''s Encrypt HTTP-01 webroot）...'
    $certCmd = "docker run --rm -v '$Remote/ssl/letsencrypt:/etc/letsencrypt' -v '$Remote/certbot/www:/var/www/certbot' certbot/certbot certonly --webroot -w /var/www/certbot -d '$SslDomain' --agree-tos --non-interactive --register-unsafely-without-email --keep-until-expiring --expand"
    $code = Invoke-RemoteVisible $certCmd
    if ($code -ne 0) {
        $certExists = Invoke-Remote "test -f '$Remote/ssl/letsencrypt/live/$SslDomain/fullchain.pem' -a -f '$Remote/ssl/letsencrypt/live/$SslDomain/privkey.pem'"
        if ($certExists -ne 0) {
            Write-Fail 'Certbot 证书签发失败'
        }
        Write-Warn 'Certbot 返回非零，但证书文件已存在，继续启用 HTTPS'
    } else {
        Write-Ok '证书签发完成'
    }

    Write-Info '上传并启用 HTTPS Nginx 配置...'
    $nginxPath = Join-Path $DeployDir 'nginx.conf'
    $code = Send-Upload @($nginxPath) "${Server}:${Remote}/nginx.conf"
    if ($code -ne 0) { Write-Fail 'HTTPS Nginx 配置上传失败' }
    $code = Invoke-RemoteVisible "cd '$Remote' && docker compose up -d --no-deps --force-recreate nginx && docker exec xzs-nginx nginx -t"
    if ($code -ne 0) { Write-Fail 'HTTPS Nginx 配置启动失败' }
    Write-Ok 'HTTPS Nginx 配置已启用'

    Write-Info '验证 HTTP 跳转和 HTTPS 页面...'
    & curl.exe -I --max-time 15 "http://$SslDomain/student/login"
    if ($LASTEXITCODE -ne 0) { Write-Fail 'HTTP 验证失败' }
    & curl.exe -I --max-time 20 "https://$SslDomain/student/login"
    if ($LASTEXITCODE -ne 0) { Write-Fail 'HTTPS 验证失败' }

    Write-Host ''
    Write-Ok "SSL 配置完成: https://$SslDomain/student/login"
}

function Invoke-RenewSsl {
    Write-Separator "续期 HTTPS 证书: $SslDomain"

    Write-Info '测试 SSH 连接...'
    $null = Invoke-Remote 'echo OK' 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Fail "无法连接 $Server，请先运行: .\deploy\cloud-update.ps1 doctor"
    }
    Write-Ok 'SSH 连接正常'

    Write-Info '运行 Certbot renew...'
    $renewCmd = "docker run --rm -v '$Remote/ssl/letsencrypt:/etc/letsencrypt' -v '$Remote/certbot/www:/var/www/certbot' certbot/certbot renew --webroot -w /var/www/certbot"
    $code = Invoke-RemoteVisible $renewCmd
    if ($code -ne 0) { Write-Fail '证书续期失败' }

    Write-Info '重启 Nginx 加载证书...'
    $code = Invoke-RemoteVisible "cd '$Remote' && docker compose up -d --no-deps --force-recreate nginx && docker exec xzs-nginx nginx -t"
    if ($code -ne 0) { Write-Fail 'Nginx 重启失败' }

    & curl.exe -I --max-time 20 "https://$SslDomain/student/login"
    if ($LASTEXITCODE -ne 0) { Write-Fail 'HTTPS 验证失败' }
    Write-Ok '证书续期检查完成'
}

function Invoke-ResetDb {
    Write-Separator '重置云端数据库'
    Write-Warn '这会用本地最新快照替换云端数据库的所有数据！'
    Confirm-Action

    Write-Info '上传 SQL 文件...'
    Invoke-Remote "mkdir -p '$Remote/sql' && rm -f '$Remote/sql'/0*.sql"
    $sqlFiles = Get-DeploySqlFiles
    foreach ($f in $sqlFiles) {
        $code = Send-Upload @($f.FullName) "${Server}:${Remote}/sql/"
        if ($code -ne 0) {
            Write-Fail "SQL 文件上传失败: $($f.Name)"
        }
    }

    Write-Info '停止后端...'
    Invoke-Remote 'docker stop xzs-backend 2>/dev/null || true'

    Write-Info '确保 MySQL 运行...'
    $mysqlOut = Invoke-RemoteOutput "docker ps --format '{{.Names}}'" 2>$null
    if ($mysqlOut -notmatch 'xzs-mysql') {
        Invoke-Remote "cd $Remote && docker compose up -d mysql"
    }
    Wait-MysqlReady

    Write-Info '备份当前数据库...'
    $null = Backup-RemoteDatabase 'backup_login_fix'

    Reset-RemoteDatabaseFromCurrentSql
    Test-RemoteDatabaseData

    Write-Info '重启后端...'
    Invoke-Remote 'cd /opt/xzs-deploy && docker compose up -d backend'
    Write-Ok '后端已重启'
}

function Invoke-Rollback {
    Write-Separator '回滚数据库'
    $latest = Invoke-RemoteOutput "ls -t ${Remote}/backup_*.sql 2>/dev/null | head -1"
    if (-not $latest) { Write-Fail '未找到备份文件' }

    Write-Warn "将回滚到: $latest"
    Confirm-Action

    Write-Info '停止后端...'
    Invoke-Remote 'docker stop xzs-backend 2>/dev/null || true'

    Write-Info '恢复数据库...'
    Invoke-Remote "docker exec -i xzs-mysql mysql -u $MysqlUser -p'$MysqlPwd' -e 'DROP DATABASE IF EXISTS $MysqlDb; CREATE DATABASE $MysqlDb DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci;' && docker exec -i xzs-mysql mysql -u $MysqlUser -p'$MysqlPwd' $MysqlDb < $latest"
    Write-Ok '数据库已回滚'

    Write-Info '重启后端...'
    Invoke-Remote 'cd /opt/xzs-deploy && docker compose up -d backend'
    Write-Ok '后端已重启'
}

function Invoke-Logs {
    Write-Separator '后端日志 (最近 100 行)'
    Invoke-Remote 'docker logs xzs-backend --tail 100 2>&1'
}

# =============================================================================
#  主流程
# =============================================================================
Write-Host ''
Write-Host '╔═══════════════════════════════════════════════╗' -ForegroundColor Green
Write-Host '║       408Master 云端部署工具 v3.0 (PS)         ║' -ForegroundColor Green
Write-Host '╠═══════════════════════════════════════════════╣' -ForegroundColor Green
Write-Host ('║  服务器:   {0,-32}║' -f $Server) -ForegroundColor Green
Write-Host ('║  远端目录: {0,-32}║' -f $Remote) -ForegroundColor Green
Write-Host ('║  命令:     {0,-32}║' -f $Command) -ForegroundColor Green
Write-Host '╚═══════════════════════════════════════════════╝' -ForegroundColor Green

switch ($Command) {
    'doctor'     { Invoke-Doctor }
    'setup-key'  { Invoke-SetupKey }
    'build'      { Invoke-Build }
    'upload'     { Invoke-Upload }
    'deploy'     { Invoke-Deploy }
    'full' {
        Invoke-Doctor
        if (-not $SkipBuild) {
            $ForceBuild = $true
            Invoke-Build
            Write-Host ''
            Confirm-Action '构建完成，是否继续上传和部署？'
        } else {
            Write-Warn '已跳过构建 (-SkipBuild)'
        }
        Invoke-Upload
        Write-Host ''
        Confirm-Action '上传完成，是否继续远端部署？'
        Invoke-Deploy
    }
    'status'     { Invoke-Status }
    'upload-qdrant' { Invoke-UploadQdrant }
    'setup-ssl'  { Invoke-SetupSsl }
    'renew-ssl'  { Invoke-RenewSsl }
    'reset-db'   { Invoke-ResetDb }
    'rollback'   { Invoke-Rollback }
    'logs'       { Invoke-Logs }
    'ssh'        { Write-Info "SSH 到 $Server ..."; & ssh $Server }
}
