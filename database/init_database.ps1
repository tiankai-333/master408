# ============================================
# 数据库初始化脚本
# 按顺序执行所有SQL文件
# ============================================

Write-Host "开始执行数据库SQL文件..." -ForegroundColor Green
Write-Host ""

# SQL文件列表
$sqlFiles = @(
    @{Name="01 - 表结构初始化"; File="database/01_init_structure.sql"},
    @{Name="02 - 真题题目导入"; File="database/02_exam_questions.sql"},
    @{Name="03 - 试卷数据生成"; File="database/03_exam_papers.sql"},
    @{Name="04 - 学生做题数据"; File="database/04_student_exam_data.sql"}
)

# MySQL连接参数
$mysqlUser = "root"
$mysqlPassword = "123456"
$database = "xzs"

# 依次执行SQL文件
foreach ($sql in $sqlFiles) {
    Write-Host "正在执行: $($sql.Name)..." -ForegroundColor Cyan
    
    try {
        $result = Get-Content $sql.File | mysql -u $mysqlUser -p$mysqlPassword $database 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  ✓ 执行成功" -ForegroundColor Green
        } else {
            Write-Host "  ✗ 执行失败: $result" -ForegroundColor Red
        }
    } catch {
        Write-Host "  ✗ 执行出错: $_" -ForegroundColor Red
    }
    
    Write-Host ""
}

# 验证数据
Write-Host "验证数据导入结果..." -ForegroundColor Green
Write-Host ""

$verificationQuery = @"
SELECT '学科表' as table_name, COUNT(*) as count FROM t_subject 
UNION ALL SELECT '用户表', COUNT(*) FROM t_user 
UNION ALL SELECT '题目表', COUNT(*) FROM t_question 
UNION ALL SELECT '试卷表', COUNT(*) FROM t_exam_paper 
UNION ALL SELECT '试卷题目关联表', COUNT(*) FROM t_exam_paper_question 
UNION ALL SELECT '学生答题记录表', COUNT(*) FROM t_student_answer 
UNION ALL SELECT '学生考试记录表', COUNT(*) FROM t_exam_record;
"@

$verifyResult = mysql -u $mysqlUser -p$mysqlPassword $database -e $verificationQuery 2>&1 | Select-Object -Skip 2

Write-Host $verifyResult -ForegroundColor Yellow

Write-Host ""
Write-Host "数据库初始化完成！" -ForegroundColor Green
