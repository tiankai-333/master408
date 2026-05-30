#!/bin/bash
# =============================================================================
#  408Master 云端 Docker 部署脚本（开发/演示环境）
#  用法: bash deploy/cloud-update.sh [命令] [选项]
#
#  命令:
#    doctor      部署前环境诊断
#    setup-key   配置 SSH 免密登录（只需执行一次）
#    build       只做本地构建
#    upload      只上传已构建的产物
#    deploy      远端部署（备份数据库 → 导入快照 → 重启 → 验证）
#    full        构建 + 上传 + 远端部署（默认命令，强制构建）
#    status      查看云端服务状态
#    reset-db    用本地快照重置云端数据库
#    rollback    回滚到上次部署前的数据库备份
#    logs        查看云端后端日志
#    ssh         直接 SSH 进服务器
#
#  选项:
#    --server USER@HOST    服务器地址
#    --remote PATH         远端部署目录
#    --no-backup           跳过数据库备份
#    --skip-migration      跳过 SQL 导入
#    --skip-frontend       跳过前端上传
#    --skip-build          跳过本地构建（仅 full 命令）
#    --force-build         强制重建（仅 build 命令）
#    -y                    跳过确认提示
#
#  配置:
#    复制 deploy/.env.example → deploy/.env 并填入真实值
#    优先级: 脚本默认值 < deploy/.env < 命令行参数
# =============================================================================

set -euo pipefail

# ---- 脚本默认值（安全值，不含真实密码） ----
SERVER="root@127.0.0.1"
REMOTE="/opt/xzs-deploy"
MYSQL_PWD=""
MYSQL_USER="root"
MYSQL_DB="xzs"
NO_BACKUP=false
SKIP_MIGRATION=false
SKIP_FRONTEND=false
SKIP_BUILD=false
FORCE_BUILD=false
AUTO_YES=false
COMMAND="full"

# ---- 路径常量 ----
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SQL_DIR="$PROJECT_ROOT/database/current"
DEPLOY_DIR="$PROJECT_ROOT/deploy"

# ---- 加载 .env（覆盖默认值） ----
if [[ -f "$DEPLOY_DIR/.env" ]]; then
    # shellcheck disable=SC1090
    source "$DEPLOY_DIR/.env"
fi

# ---- 解析命令行参数（优先级最高） ----
while [[ $# -gt 0 ]]; do
    case "$1" in
        doctor|setup-key|build|upload|deploy|full|status|reset-db|rollback|logs|ssh)
            COMMAND="$1"; shift ;;
        --server)          SERVER="$2"; shift 2 ;;
        --remote)          REMOTE="$2"; shift 2 ;;
        --no-backup)       NO_BACKUP=true; shift ;;
        --skip-migration)  SKIP_MIGRATION=true; shift ;;
        --skip-frontend)   SKIP_FRONTEND=true; shift ;;
        --skip-build)      SKIP_BUILD=true; shift ;;
        --force-build)     FORCE_BUILD=true; shift ;;
        -y)                AUTO_YES=true; shift ;;
        -h|--help)
            sed -n '2,26p' "$0" | sed 's/^# \?//'
            exit 0 ;;
        *) echo "未知参数: $1"; exit 1 ;;
    esac
done

# ---- 颜色 ----
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()  { echo -e "${BLUE}[INFO]${NC}  $*"; }
ok()    { echo -e "${GREEN}[ OK ]${NC}  $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
fail()  { echo -e "${RED}[FAIL]${NC}  $*"; exit 1; }

separator() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  $*${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

confirm() {
    if $AUTO_YES; then return 0; fi
    echo -en "${YELLOW}继续？[y/N]${NC} "
    read -r ans
    [[ "$ans" =~ ^[yY] ]] || { echo "已取消"; exit 0; }
}

# ---- SSH key 自动检测 ----
detect_ssh_key() {
    SSH_KEY=""
    local win_user
    win_user="$(cmd.exe /c echo %USERNAME% 2>/dev/null | tr -d '\r\n')" || true
    for candidate in \
        "$HOME/.ssh/id_ed25519" \
        "$HOME/.ssh/id_rsa" \
        "/mnt/c/Users/${win_user}/.ssh/id_ed25519" \
        "/mnt/c/Users/${win_user}/.ssh/id_rsa" \
        "/mnt/c/Users/$USER/.ssh/id_ed25519" \
        "/mnt/c/Users/$USER/.ssh/id_rsa" \
        "/c/Users/${win_user}/.ssh/id_ed25519" \
        "/c/Users/${win_user}/.ssh/id_rsa"; do
        if [[ -f "$candidate" ]]; then
            SSH_KEY="$candidate"
            break
        fi
    done
}
detect_ssh_key

SSH_OPTS="-o StrictHostKeyChecking=no -o BatchMode=yes -o ConnectTimeout=10"
[[ -n "$SSH_KEY" ]] && SSH_OPTS="$SSH_OPTS -i $SSH_KEY"

remote()       { ssh $SSH_OPTS "$SERVER" "$@"; }
upload()       { scp $SSH_OPTS "$@"; }
rsync_upload() { rsync -avz -e "ssh $SSH_OPTS" --delete "$@"; }

# ---- 环境检测 ----
detect_env() {
    if grep -qi microsoft /proc/version 2>/dev/null; then
        echo "WSL"
    elif [[ "${OSTYPE:-}" == msys* || "${OSTYPE:-}" == cygwin* ]]; then
        echo "Git Bash / MSYS"
    else
        echo "Linux / macOS"
    fi
}

check_cmd() {
    if command -v "$1" >/dev/null 2>&1; then
        ok "$1: $(command -v "$1")"
        return 0
    else
        warn "$1: 未找到"
        return 1
    fi
}

# =============================================================================
#  doctor 命令
# =============================================================================
do_doctor() {
    separator "部署环境诊断"

    local env_type
    env_type=$(detect_env)

    echo ""
    info "=== 本地环境 ==="
    info "运行环境: $env_type"
    info "HOME: $HOME"
    info "USER: $(whoami)"
    info "PWD: $(pwd)"
    echo ""

    info "=== 本地命令 ==="
    check_cmd ssh
    check_cmd scp
    check_cmd rsync
    check_cmd java
    check_cmd mvn
    check_cmd npm
    echo ""

    info "=== Java / Maven ==="
    if command -v java >/dev/null 2>&1; then
        java -version 2>&1 | head -1
    fi
    if command -v mvn >/dev/null 2>&1; then
        mvn -version 2>&1 | head -2
    else
        warn "Maven 不可用，常见原因是 JAVA_HOME 配置错误"
    fi
    echo ""

    info "=== SSH 配置 ==="
    info "SSH_KEY: ${SSH_KEY:-未找到，将使用默认 ssh 配置}"
    if [[ -n "$SSH_KEY" ]]; then
        if [[ -f "$SSH_KEY" ]]; then
            ok "密钥文件存在"
        else
            warn "密钥文件不存在: $SSH_KEY"
        fi
    else
        warn "未找到 SSH 密钥（id_ed25519 / id_rsa）"
        info "已搜索: \$HOME/.ssh/, /mnt/c/Users/<WIN_USER>/.ssh/, /c/Users/<WIN_USER>/.ssh/"
    fi

    if [[ "$env_type" == "WSL" ]]; then
        warn "当前运行在 WSL 中。PowerShell 的 ssh 和 WSL 的 ssh 可能使用不同的 ~/.ssh 目录"
        info "部署脚本通过 bash 运行时，以 WSL/bash 中的 SSH 为准"
    fi
    echo ""

    info "=== .env 配置 ==="
    if [[ -f "$DEPLOY_DIR/.env" ]]; then
        ok "$DEPLOY_DIR/.env 已加载"
        info "SERVER=$SERVER"
        info "REMOTE=$REMOTE"
        info "MYSQL_DB=$MYSQL_DB"
    else
        warn "$DEPLOY_DIR/.env 不存在，请复制 .env.example 并填入真实值"
    fi
    echo ""

    info "=== SSH 连接测试 ==="
    info "执行: ssh $SSH_OPTS $SERVER 'echo OK'"
    if remote "echo OK" >/dev/null 2>&1; then
        ok "SSH 连接成功"
    else
        warn "SSH 连接失败"
        echo "  实际命令: ssh $SSH_OPTS $SERVER 'echo OK'"
        echo "  如果是密钥问题，运行: bash deploy/cloud-update.sh setup-key"
    fi
    echo ""

    info "=== 远端环境 ==="
    if remote "echo OK" >/dev/null 2>&1; then
        remote "echo 'Docker:' \$(docker --version 2>/dev/null || echo '未安装')"
        remote "echo 'Compose:' \$(docker compose version 2>/dev/null || echo '未安装')"
        remote "df -h / | tail -1"
        remote "free -h | grep Mem"
    else
        warn "SSH 不通，跳过远端检查"
    fi
}

# =============================================================================
#  SSH 免密登录配置
# =============================================================================
do_setup_key() {
    separator "配置 SSH 免密登录"

    local env_type
    env_type=$(detect_env)

    info "当前运行环境: $env_type"
    info "HOME: $HOME"
    info "当前选择的 SSH key: ${SSH_KEY:-无}"
    echo ""

    if [[ "$env_type" == "WSL" ]]; then
        warn "注意: PowerShell 的 ssh 和 WSL bash 的 ssh 使用不同的 ~/.ssh 目录"
        info "PowerShell 的 ~/.ssh 通常在 C:\\Users\\<你的用户名>\\.ssh\\"
        info "WSL 的 ~/.ssh 在 /home/<wsl用户名>/.ssh/"
        info "部署脚本通过 bash 运行，以 WSL/bash 的 SSH 为准"
        echo ""
    fi

    local key_file="${SSH_KEY:-$HOME/.ssh/id_ed25519}"
    local key_pub="${key_file}.pub"

    if [[ ! -f "$key_file" ]]; then
        info "未找到 SSH key，生成新的 ed25519 key..."
        ssh-keygen -t ed25519 -f "$key_file" -N "" -C "408master-deploy"
        ok "SSH key 已生成: $key_file"
    else
        ok "已有 SSH key: $key_file"
    fi

    echo ""
    info "公钥路径: $key_pub"
    info "公钥内容:"
    cat "$key_pub"
    echo ""

    echo -e "${YELLOW}将公钥复制到服务器 ${SERVER}:${NC}"
    echo ""
    echo "  1. SSH 登录服务器:"
    echo "     ssh $SERVER"
    echo ""
    echo "  2. 在服务器上执行:"
    echo "     mkdir -p ~/.ssh && chmod 700 ~/.ssh"
    echo "     echo \"$(cat "$key_pub")\" >> ~/.ssh/authorized_keys"
    echo "     chmod 600 ~/.ssh/authorized_keys"
    echo ""
    echo "  3. 验证免密登录:"
    echo "     ssh -i $key_file $SERVER 'echo 免密登录成功'"
}

# =============================================================================
#  本地构建
# =============================================================================
do_build() {
    separator "本地构建"

    # 1. 后端 JAR
    local jar="$PROJECT_ROOT/source/xzs/target/xzs-3.9.0.jar"
    if $FORCE_BUILD || [[ ! -f "$jar" ]]; then
        build_jar
    else
        info "后端 JAR 已存在 ($(du -h "$jar" | cut -f1))，跳过构建"
    fi

    # 2. 学生端
    local student_dist="$PROJECT_ROOT/source/vue/xzs-student/dist/index.html"
    if $FORCE_BUILD || [[ ! -f "$student_dist" ]]; then
        build_student
    else
        info "学生端 dist 已存在 ($(du -sh "$PROJECT_ROOT/source/vue/xzs-student/dist/" | cut -f1))，跳过构建"
    fi

    # 3. 管理端
    local admin_dist="$PROJECT_ROOT/source/vue/xzs-admin/dist/index.html"
    if $FORCE_BUILD || [[ ! -f "$admin_dist" ]]; then
        build_admin
    else
        info "管理端 dist 已存在 ($(du -sh "$PROJECT_ROOT/source/vue/xzs-admin/dist/" | cut -f1))，跳过构建"
    fi

    # 4. 同步 SQL
    info "同步 deploy/sql/ <- database/current/"
    rm -f "$DEPLOY_DIR"/sql/*.sql
    cp "$SQL_DIR"/*.sql "$DEPLOY_DIR"/sql/
    ok "已同步 $(ls "$DEPLOY_DIR"/sql/*.sql 2>/dev/null | wc -l) 个 SQL 文件"

    echo ""
    ok "本地构建全部完成"
}

build_jar() {
    info "构建后端 JAR..."
    rm -f "$PROJECT_ROOT/source/xzs/target/xzs-3.9.0.jar"
    (cd "$PROJECT_ROOT/source/xzs" && mvn package -DskipTests -q) \
        || fail "后端 JAR 构建失败，请检查 JAVA_HOME / Maven 配置"
    [[ -f "$PROJECT_ROOT/source/xzs/target/xzs-3.9.0.jar" ]] \
        || fail "Maven 执行结束，但未生成 JAR"
    ok "JAR: $(du -h "$PROJECT_ROOT/source/xzs/target/xzs-3.9.0.jar" | cut -f1)"
}

build_student() {
    info "构建学生端前端..."
    (cd "$PROJECT_ROOT/source/vue/xzs-student" \
        && npm install --registry=https://registry.npmmirror.com --silent 2>/dev/null \
        && npm run build 2>&1 | tail -1) \
        || fail "学生端前端构建失败"
    [[ -f "$PROJECT_ROOT/source/vue/xzs-student/dist/index.html" ]] \
        || fail "学生端构建完成，但未生成 dist/index.html"
    ok "学生端: $(du -sh "$PROJECT_ROOT/source/vue/xzs-student/dist/" | cut -f1)"
}

build_admin() {
    info "构建管理端前端..."
    (cd "$PROJECT_ROOT/source/vue/xzs-admin" \
        && printf 'VITE_APP_URL=\n' > .env.production \
        && npm install --registry=https://registry.npmmirror.com --silent 2>/dev/null \
        && npm run build 2>&1 | tail -1) \
        || fail "管理端前端构建失败"
    [[ -f "$PROJECT_ROOT/source/vue/xzs-admin/dist/index.html" ]] \
        || fail "管理端构建完成，但未生成 dist/index.html"
    ok "管理端: $(du -sh "$PROJECT_ROOT/source/vue/xzs-admin/dist/" | cut -f1)"
}

# =============================================================================
#  上传文件
# =============================================================================
do_upload() {
    separator "上传文件到 $SERVER"

    info "SSH_KEY: ${SSH_KEY:-使用默认配置}"

    info "测试 SSH 连接..."
    if ! remote "echo OK" > /dev/null 2>&1; then
        echo "  实际命令: ssh $SSH_OPTS $SERVER 'echo OK'"
        fail "无法连接 $SERVER，请先运行: bash deploy/cloud-update.sh doctor"
    fi
    ok "SSH 连接正常"

    remote "mkdir -p $REMOTE/{static/student,static/admin,sql,logs,qdrant-data,ssl}"

    # 1. 部署配置
    info "[1/5] 上传部署配置 (docker-compose.yml, Dockerfile, nginx.conf)..."
    upload "$DEPLOY_DIR/docker-compose.yml" "$DEPLOY_DIR/Dockerfile" "$DEPLOY_DIR/nginx.conf" "$SERVER:$REMOTE/"
    ok "配置文件已上传"

    # 2. 后端 JAR
    info "[2/5] 上传后端 JAR..."
    upload "$PROJECT_ROOT/source/xzs/target/xzs-3.9.0.jar" "$SERVER:$REMOTE/"
    ok "JAR 已上传"

    # 3. 学生端
    if ! $SKIP_FRONTEND; then
        info "[3/5] 上传学生端前端 (rsync 增量)..."
        rsync_upload "$PROJECT_ROOT/source/vue/xzs-student/dist/" "$SERVER:$REMOTE/static/student/"
        ok "学生端已同步"
    else
        info "[3/5] 跳过学生端上传 (--skip-frontend)"
    fi

    # 4. 管理端
    if ! $SKIP_FRONTEND; then
        info "[4/5] 上传管理端前端..."
        rsync_upload "$PROJECT_ROOT/source/vue/xzs-admin/dist/" "$SERVER:$REMOTE/static/admin/"
        ok "管理端已同步"
    else
        info "[4/5] 跳过管理端上传 (--skip-frontend)"
    fi

    # 5. SQL 文件
    info "[5/5] 上传 SQL 文件..."
    remote "rm -f $REMOTE/sql/source.sql $REMOTE/sql/README.md"
    scp $SSH_OPTS "$SQL_DIR"/0*.sql "$SERVER:$REMOTE/sql/"
    ok "SQL 文件已上传"

    echo ""
    ok "全部上传完成"
}

# =============================================================================
#  远端部署
# =============================================================================
wait_mysql_ready() {
    local retries=0
    local max_retries=30
    info "等待 MySQL 就绪..."
    while [[ $retries -lt $max_retries ]]; do
        if remote "docker exec xzs-mysql mysqladmin ping -u$MYSQL_USER -p'$MYSQL_PWD' --silent" >/dev/null 2>&1; then
            ok "MySQL 已就绪"
            return 0
        fi
        retries=$((retries + 1))
        echo -n "."
        sleep 3
    done
    echo ""
    fail "MySQL 启动超时（90秒）"
}

do_deploy() {
    separator "远端部署 $SERVER:$REMOTE"

    # 检查 MySQL 容器是否存在
    local mysql_exists=false
    if remote "docker ps -a --format '{{.Names}}' | grep -q '^xzs-mysql\$'" 2>/dev/null; then
        mysql_exists=true
    fi

    # Step 1: 备份数据库
    if ! $NO_BACKUP && $mysql_exists; then
        info "[1/7] 备份数据库..."
        local backup_file="backup_$(date +%Y%m%d_%H%M%S).sql"
        remote "cd $REMOTE && docker exec xzs-mysql mysqldump -u $MYSQL_USER -p'$MYSQL_PWD' --single-transaction $MYSQL_DB > $backup_file" 2>/dev/null
        local backup_size
        backup_size=$(remote "du -h $REMOTE/$backup_file | cut -f1" 2>/dev/null)
        ok "备份完成: $backup_file ($backup_size)"

        # 清理旧备份，保留最近 3 个
        remote "cd $REMOTE && ls -t backup_*.sql 2>/dev/null | tail -n +4 | xargs -r rm -f"
    else
        if ! $mysql_exists; then
            warn "[1/7] 未发现 xzs-mysql 容器（首次部署），跳过数据库备份"
        else
            warn "[1/7] 跳过备份 (--no-backup)"
        fi
    fi

    # Step 2: 停旧服务 + 释放端口
    info "[2/7] 停止旧服务..."
    remote "cd $REMOTE && \
        docker stop xzs-backend 2>/dev/null || true; \
        docker rm xzs-backend 2>/dev/null || true; \
        systemctl stop nginx 2>/dev/null || true; \
        systemctl disable nginx 2>/dev/null || true"
    ok "旧服务已停止"

    # Step 3: 确保 MySQL 运行
    info "[3/7] 启动 MySQL..."
    if ! $mysql_exists; then
        remote "cd $REMOTE && docker compose up -d mysql"
    fi
    wait_mysql_ready

    # Step 4: 导入 SQL 快照
    if ! $SKIP_MIGRATION; then
        info "[4/7] 导入 SQL 快照..."
        remote "cd $REMOTE && \
            docker exec -i xzs-mysql mysql -u $MYSQL_USER -p'$MYSQL_PWD' -e \
            'DROP DATABASE IF EXISTS $MYSQL_DB; CREATE DATABASE $MYSQL_DB DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci;' \
            && for f in sql/0*.sql; do \
                [ -f \"\$f\" ] && docker exec -i xzs-mysql mysql -u $MYSQL_USER -p'$MYSQL_PWD' $MYSQL_DB < \"\$f\"; \
            done \
            && echo 'SQL imported OK'"
        ok "数据库已导入"
    else
        info "[4/7] 跳过 SQL 导入 (--skip-migration)"
    fi

    # Step 5: 验证数据
    info "[5/7] 验证数据库..."
    remote "docker exec xzs-mysql mysql -u $MYSQL_USER -p'$MYSQL_PWD' $MYSQL_DB -e \"
        SELECT 't_question' AS tbl, COUNT(*) AS cnt FROM t_question
        UNION ALL SELECT 't_exam_paper', COUNT(*) FROM t_exam_paper
        UNION ALL SELECT 'knowledge_point', COUNT(*) FROM knowledge_point
        UNION ALL SELECT 'question_content', COUNT(*) FROM question_content
        UNION ALL SELECT 't_subject', COUNT(*) FROM t_subject;\"" 2>/dev/null
    ok "数据验证完成"

    # Step 6: 构建并启动 Docker 服务
    info "[6/7] 启动 Docker 服务..."
    remote "cd $REMOTE && \
        mkdir -p qdrant-data logs ssl && \
        docker compose build backend --quiet && \
        docker compose up -d"
    ok "Docker 服务已启动"

    # Step 7: 等待后端启动 + 健康检查
    info "[7/7] 等待后端启动..."
    local retries=0
    local max_retries=20
    while [[ $retries -lt $max_retries ]]; do
        # 先检查容器是否还在运行（可能 OOM / 崩溃）
        local container_status
        container_status=$(remote "docker inspect -f '{{.State.Status}}' xzs-backend 2>/dev/null" || echo "missing")
        if [[ "$container_status" == "missing" ]]; then
            echo ""
            fail "xzs-backend 容器不存在，请检查 docker compose 是否正常"
        fi
        if [[ "$container_status" != "running" ]]; then
            echo ""
            echo ""
            warn "xzs-backend 容器状态: $container_status（可能 OOM 或启动失败）"
            info "最近日志:"
            remote "docker logs xzs-backend --tail 40 2>&1" || true
            echo ""
            fail "后端容器已退出，请检查上方日志"
        fi
        if remote "docker logs xzs-backend 2>&1 | grep -q 'Started XzsApplication'" 2>/dev/null; then
            ok "后端启动成功"
            break
        fi
        retries=$((retries + 1))
        echo -n "."
        sleep 5
    done
    echo ""

    if [[ $retries -ge $max_retries ]]; then
        warn "后端启动超时（100秒）"
        info "容器状态:"
        remote "docker ps -a --filter name=xzs-backend --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'" 2>/dev/null || true
        echo ""
        info "最近日志（后 50 行）:"
        remote "docker logs xzs-backend --tail 50 2>&1" || true
        echo ""
        warn "详细日志: bash deploy/cloud-update.sh logs"
    fi

    # 健康检查
    echo ""
    local student_code admin_code
    student_code=$(remote "curl -s -o /dev/null -w '%{http_code}' http://localhost/student/" 2>/dev/null)
    admin_code=$(remote "curl -s -o /dev/null -w '%{http_code}' http://localhost/admin/" 2>/dev/null)
    local api_result
    api_result=$(remote "curl -s http://localhost/api/student/ai/styles | head -c 80" 2>/dev/null)

    echo "  ┌───────────────────────────────────────────────┐"
    echo "  │  健康检查结果                                  │"
    echo "  ├───────────────────────────────────────────────┤"
    printf "  │  学生端  /student/    %-4s  %-4s                │\n" "$student_code" "$([ "$student_code" = "200" ] && echo "OK" || echo "FAIL")"
    printf "  │  管理端  /admin/      %-4s  %-4s                │\n" "$admin_code" "$([ "$admin_code" = "200" ] && echo "OK" || echo "FAIL")"
    printf "  │  AI API  /ai/styles   %s\n" "$(echo "$api_result" | head -c 30)"
    echo "  └───────────────────────────────────────────────┘"

    echo ""
    remote "docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'"

    echo ""
    ok "部署完成！"
    echo ""
    echo "  学生端: http://${SERVER#*@}/student/"
    echo "  管理端: http://${SERVER#*@}/admin/"
    echo ""
    echo "  常用命令:"
    echo "    bash deploy/cloud-update.sh logs       # 查看后端日志"
    echo "    bash deploy/cloud-update.sh status      # 查看服务状态"
    echo "    bash deploy/cloud-update.sh reset-db    # 重置数据库"
}

# =============================================================================
#  子命令
# =============================================================================
do_status() {
    separator "云端服务状态"
    echo ""
    info "Docker 容器:"
    remote "docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}' 2>/dev/null || echo '  (无运行中的容器)'"
    echo ""
    info "磁盘:"
    remote "df -h / | tail -1"
    echo ""
    info "内存:"
    remote "free -h | grep Mem"
    echo ""
    info "端口 80:"
    remote "ss -tlnp | grep ':80 ' || echo '  (端口 80 未被监听)'"
    echo ""
    info "数据库表计数:"
    remote "docker exec xzs-mysql mysql -u $MYSQL_USER -p'$MYSQL_PWD' $MYSQL_DB -e \"
        SELECT 't_question' AS tbl, COUNT(*) AS cnt FROM t_question
        UNION ALL SELECT 't_exam_paper', COUNT(*) FROM t_exam_paper
        UNION ALL SELECT 't_subject', COUNT(*) FROM t_subject
        UNION ALL SELECT 'knowledge_point', COUNT(*) FROM knowledge_point;\"" 2>/dev/null || warn "无法连接数据库"
}

do_reset_db() {
    separator "重置云端数据库"
    warn "这会用本地最新快照替换云端数据库的所有数据！"
    confirm

    info "上传 SQL 文件..."
    remote "rm -f $REMOTE/sql/source.sql $REMOTE/sql/README.md"
    scp $SSH_OPTS "$SQL_DIR"/0*.sql "$SERVER:$REMOTE/sql/"

    info "停止后端..."
    remote "docker stop xzs-backend 2>/dev/null || true"

    info "确保 MySQL 运行..."
    if ! remote "docker ps --format '{{.Names}}' | grep -q '^xzs-mysql\$'" 2>/dev/null; then
        remote "cd $REMOTE && docker compose up -d mysql"
    fi
    wait_mysql_ready

    info "清空并导入..."
    remote "cd $REMOTE && \
        docker exec -i xzs-mysql mysql -u $MYSQL_USER -p'$MYSQL_PWD' -e \
        'DROP DATABASE IF EXISTS $MYSQL_DB; CREATE DATABASE $MYSQL_DB DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci;' \
        && for f in sql/0*.sql; do \
            [ -f \"\$f\" ] && docker exec -i xzs-mysql mysql -u $MYSQL_USER -p'$MYSQL_PWD' $MYSQL_DB < \"\$f\"; \
        done"
    ok "数据库已重置"

    info "重启后端..."
    remote "cd $REMOTE && docker compose up -d backend"
    ok "后端已重启"
}

do_rollback() {
    separator "回滚数据库"
    local latest_backup
    latest_backup=$(remote "ls -t $REMOTE/backup_*.sql 2>/dev/null | head -1")
    if [[ -z "$latest_backup" ]]; then
        fail "未找到备份文件"
    fi

    warn "将回滚到: $latest_backup"
    confirm

    info "停止后端..."
    remote "docker stop xzs-backend 2>/dev/null || true"

    info "恢复数据库..."
    remote "docker exec -i xzs-mysql mysql -u $MYSQL_USER -p'$MYSQL_PWD' -e \
        'DROP DATABASE IF EXISTS $MYSQL_DB; CREATE DATABASE $MYSQL_DB DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci;' \
        && docker exec -i xzs-mysql mysql -u $MYSQL_USER -p'$MYSQL_PWD' $MYSQL_DB < $latest_backup"
    ok "数据库已回滚"

    info "重启后端..."
    remote "cd $REMOTE && docker compose up -d backend"
    ok "后端已重启"
}

do_logs() {
    separator "后端日志 (最近 100 行，Ctrl+C 退出)"
    remote "docker logs xzs-backend --tail 100 -f 2>&1" || true
}

do_ssh() {
    info "SSH 到 $SERVER ..."
    ssh "$SERVER"
}

# =============================================================================
#  主流程
# =============================================================================
echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║       408Master 云端部署工具 v3.0              ║${NC}"
echo -e "${GREEN}╠═══════════════════════════════════════════════╣${NC}"
printf "${GREEN}║  %-12s %-30s ║${NC}\n" "服务器:" "$SERVER"
printf "${GREEN}║  %-12s %-30s ║${NC}\n" "远端目录:" "$REMOTE"
printf "${GREEN}║  %-12s %-30s ║${NC}\n" "命令:" "$COMMAND"
echo -e "${GREEN}╚═══════════════════════════════════════════════╝${NC}"

case "$COMMAND" in
    doctor)     do_doctor ;;
    setup-key)  do_setup_key ;;
    build)      do_build ;;
    upload)     do_upload ;;
    deploy)     do_deploy ;;
    full)
        do_doctor
        if ! $SKIP_BUILD; then
            FORCE_BUILD=true
            do_build
            echo ""
            confirm "构建完成，是否继续上传和部署？"
        else
            warn "已跳过构建 (--skip-build)"
        fi
        do_upload
        echo ""
        confirm "上传完成，是否继续远端部署？"
        do_deploy
        ;;
    status)     do_status ;;
    reset-db)   do_reset_db ;;
    rollback)   do_rollback ;;
    logs)       do_logs ;;
    ssh)        do_ssh ;;
    *)          fail "未知命令: $COMMAND" ;;
esac
