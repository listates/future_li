# 重复文件查找脚本 - PowerShell版本
param(
    [string[]]$Paths = @("E:\"),
    [switch]$Quick,  # 快速模式，只按文件名和大小
    [switch]$Delete  # 危险：直接删除重复文件
)

Write-Host "重复文件查找工具" -ForegroundColor Cyan
Write-Host "扫描路径: $($Paths -join ', ')" -ForegroundColor Yellow
Write-Host ""

# 收集文件信息
$fileTable = @{}
$totalFiles = 0
$startTime = Get-Date

foreach ($path in $Paths) {
    if (-not (Test-Path $path)) {
        Write-Host "路径不存在: $path" -ForegroundColor Red
        continue
    }
    
    Write-Host "正在扫描: $path" -ForegroundColor Green
    $files = Get-ChildItem -Path $path -Recurse -File -ErrorAction SilentlyContinue
    
    foreach ($file in $files) {
        $key = if ($Quick) {
            # 快速模式：文件名+大小
            "$($file.Name)|$($file.Length)"
        } else {
            # 完整模式：计算哈希值
            try {
                $hash = Get-FileHash -Path $file.FullName -Algorithm MD5 -ErrorAction Stop
                "$($hash.Hash)|$($file.Length)"
            } catch {
                # 如果计算哈希失败，回退到快速模式
                "$($file.Name)|$($file.Length)"
            }
        }
        
        if (-not $fileTable.ContainsKey($key)) {
            $fileTable[$key] = @()
        }
        $fileTable[$key] += $file.FullName
        
        $totalFiles++
        if ($totalFiles % 1000 -eq 0) {
            Write-Host "已扫描 $totalFiles 个文件..." -ForegroundColor Gray
        }
    }
}

$endTime = Get-Date
$scanTime = ($endTime - $startTime).TotalSeconds

# 找出重复文件
$duplicates = $fileTable.GetEnumerator() | Where-Object { $_.Value.Count -gt 1 }

Write-Host ""
Write-Host "=" * 60
Write-Host "扫描完成!" -ForegroundColor Green
Write-Host "耗时: $scanTime 秒"
Write-Host "总文件数: $totalFiles"
Write-Host "重复文件组数: $($duplicates.Count)"
Write-Host "=" * 60
Write-Host ""

if ($duplicates.Count -eq 0) {
    Write-Host "未找到重复文件！" -ForegroundColor Green
    return
}

# 显示重复文件
$totalSaved = 0
$groupNum = 1

foreach ($dup in $duplicates) {
    $files = $dup.Value
    $firstFile = Get-Item $files[0]
    $size = $firstFile.Length
    
    Write-Host "第 $groupNum 组 - 大小: $(Format-FileSize $size)" -ForegroundColor Cyan
    Write-Host "标识: $($dup.Key.Substring(0, [Math]::Min(30, $dup.Key.Length)))..."
    
    for ($i = 0; $i -lt $files.Count; $i++) {
        $color = if ($i -eq 0) { "Green" } else { "Yellow" }
        $prefix = if ($i -eq 0) { "[保留] " } else { "[删除] " }
        Write-Host "  $($i+1). $prefix$($files[$i])" -ForegroundColor $color
    }
    
    # 计算可节省空间（保留第一个，删除其余）
    $totalSaved += $size * ($files.Count - 1)
    $groupNum++
    Write-Host ""
}

Write-Host "=" * 60
Write-Host "总计可节省空间: $(Format-FileSize $totalSaved)" -ForegroundColor Magenta
Write-Host "=" * 60

# 生成清理脚本
$scriptContent = @'
@echo off
echo 重复文件清理脚本
echo 将删除以下重复文件（保留每组第一个）:
echo.
'@

foreach ($dup in $duplicates) {
    $files = $dup.Value
    for ($i = 1; $i -lt $files.Count; $i++) {
        $scriptContent += "echo 删除: `"$($files[$i])`"`r`n"
        $scriptContent += "del /f `"$($files[$i])`"`r`n"
    }
    $scriptContent += "echo.`r`n"
}

$scriptContent += @'
echo 清理完成！
pause
'@

$scriptPath = "Clean-Duplicates.bat"
$scriptContent | Out-File -FilePath $scriptPath -Encoding UTF8

Write-Host ""
Write-Host "已生成清理脚本: $scriptPath" -ForegroundColor Green
Write-Host "请先检查脚本内容，确认无误后再运行！" -ForegroundColor Yellow

if ($Delete) {
    Write-Host ""
    Write-Host "警告：-Delete 参数已启用，将直接删除重复文件！" -ForegroundColor Red
    $confirm = Read-Host "确认删除？(输入 YES 继续)"
    if ($confirm -eq "YES") {
        foreach ($dup in $duplicates) {
            $files = $dup.Value
            for ($i = 1; $i -lt $files.Count; $i++) {
                try {
                    Remove-Item -Path $files[$i] -Force -ErrorAction Stop
                    Write-Host "已删除: $($files[$i])" -ForegroundColor Red
                } catch {
                    Write-Host "删除失败: $($files[$i]) - $_" -ForegroundColor DarkRed
                }
            }
        }
        Write-Host "清理完成！" -ForegroundColor Green
    } else {
        Write-Host "已取消删除操作。" -ForegroundColor Yellow
    }
}

function Format-FileSize {
    param([long]$Size)
    
    if ($Size -lt 1KB) { return "$Size B" }
    elseif ($Size -lt 1MB) { return "{0:N2} KB" -f ($Size / 1KB) }
    elseif ($Size -lt 1GB) { return "{0:N2} MB" -f ($Size / 1MB) }
    elseif ($Size -lt 1TB) { return "{0:N2} GB" -f ($Size / 1GB) }
    else { return "{0:N2} TB" -f ($Size / 1TB) }
}