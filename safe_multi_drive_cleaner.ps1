# 安全的多驱动器重复文件清理脚本
# 建议先扫描查看，确认无误后再删除

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   多驱动器重复文件安全清理工具" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 获取所有固定驱动器
$drives = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Root -like "*:" } | Select-Object -ExpandProperty Root

Write-Host "检测到的驱动器:" -ForegroundColor Yellow
$drives | ForEach-Object { Write-Host "  $_" -ForegroundColor White }

# 用户选择要清理的驱动器范围
Write-Host ""
Write-Host "请选择要清理的驱动器范围:" -ForegroundColor Yellow
Write-Host "1. E: 到 N: (用户指定)" -ForegroundColor White
Write-Host "2. 所有非系统驱动器 (排除C:)" -ForegroundColor White
Write-Host "3. 自定义选择" -ForegroundColor White
Write-Host ""

$choice = Read-Host "请输入选择 (1-3)"

$selectedDrives = @()

switch ($choice) {
    "1" {
        # E: 到 N:
        $selectedDrives = @('E:', 'F:', 'G:', 'H:', 'I:', 'J:', 'K:', 'L:', 'M:', 'N:') | Where-Object { Test-Path $_ }
    }
    "2" {
        # 所有非系统驱动器
        $selectedDrives = $drives | Where-Object { $_ -ne 'C:\' -and $_ -ne 'C:' }
    }
    "3" {
        # 自定义选择
        Write-Host ""
        Write-Host "可用的驱动器:" -ForegroundColor Yellow
        for ($i = 0; $i -lt $drives.Count; $i++) {
            Write-Host "$($i+1). $($drives[$i])" -ForegroundColor White
        }
        Write-Host ""
        $driveChoices = Read-Host "请输入要清理的驱动器编号（用逗号分隔，如 2,3,4）"
        $indices = $driveChoices -split ',' | ForEach-Object { [int]$_ - 1 }
        $selectedDrives = $indices | ForEach-Object { $drives[$_] } | Where-Object { $_ }
    }
    default {
        Write-Host "无效选择！" -ForegroundColor Red
        exit 1
    }
}

if ($selectedDrives.Count -eq 0) {
    Write-Host "没有选择任何驱动器！" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "选择的驱动器:" -ForegroundColor Green
$selectedDrives | ForEach-Object { Write-Host "  $_" -ForegroundColor White }

# 选择模式
Write-Host ""
Write-Host "请选择操作模式:" -ForegroundColor Yellow
Write-Host "1. 仅扫描查看（安全模式，不删除）" -ForegroundColor Green
Write-Host "2. 扫描并删除重复文件" -ForegroundColor Red
Write-Host ""

$mode = Read-Host "请输入模式 (1/2)"

if ($mode -notin @('1', '2')) {
    Write-Host "无效模式！" -ForegroundColor Red
    exit 1
}

# 安全确认
if ($mode -eq '2') {
    Write-Host ""
    Write-Host "⚠️  警告：这将实际删除文件！" -ForegroundColor Red -BackgroundColor Black
    Write-Host "请确保已备份重要文件！" -ForegroundColor Red
    Write-Host ""
    $confirm = Read-Host "输入 'YES' 确认删除操作"
    
    if ($confirm -ne 'YES') {
        Write-Host "操作已取消。" -ForegroundColor Yellow
        exit 0
    }
}

# 执行清理
Write-Host ""
Write-Host "开始处理..." -ForegroundColor Cyan

$totalSpaceSaved = 0
$totalDuplicates = 0

foreach ($drive in $selectedDrives) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "处理驱动器: $drive" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    
    if (-not (Test-Path $drive)) {
        Write-Host "驱动器 $drive 不存在，跳过" -ForegroundColor Yellow
        continue
    }
    
    if ($mode -eq '1') {
        # 仅扫描
        Write-Host "模式：仅扫描查看" -ForegroundColor Green
        & ".\find_duplicates.ps1" -Path $drive
    }
    else {
        # 扫描并删除
        Write-Host "模式：扫描并删除" -ForegroundColor Red
        & ".\find_duplicates.ps1" -Path $drive -Delete
    }
    
    Write-Host ""
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "所有操作完成！" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan

if ($mode -eq '1') {
    Write-Host "提示：查看完扫描结果后，如需删除重复文件，请重新运行并选择模式2。" -ForegroundColor Yellow
}

Write-Host ""
Read-Host "按回车键退出"