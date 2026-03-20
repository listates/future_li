# 清理E盘明显重复文件
Write-Host "清理E盘重复文件" -ForegroundColor Cyan
Write-Host "=" * 50

# 1. 查找明显的重复（文件名+大小相同）
$duplicates = Get-ChildItem -Path "E:\" -Recurse -File -ErrorAction SilentlyContinue | 
              Where-Object {$_.Length -gt 0} |
              Group-Object {$_.Name + "|" + $_.Length} | 
              Where-Object {$_.Count -gt 1}

Write-Host "找到 $($duplicates.Count) 组重复文件"

if ($duplicates.Count -eq 0) {
    Write-Host "没有找到重复文件" -ForegroundColor Green
    exit
}

# 2. 分析并清理
$totalDeleted = 0
$totalSpaceSaved = 0
$deletedFiles = @()

foreach ($group in $duplicates) {
    $files = $group.Group | Sort-Object LastWriteTime -Descending
    $keepFile = $files[0]  # 保留最新的
    $deleteFiles = $files[1..($files.Count-1)]
    
    Write-Host "`n文件: $($group.Name.Split('|')[0])" -ForegroundColor Yellow
    Write-Host "大小: $(Format-Size $keepFile.Length)" -ForegroundColor Gray
    Write-Host "保留: $($keepFile.FullName)" -ForegroundColor Green
    
    foreach ($file in $deleteFiles) {
        try {
            Write-Host "删除: $($file.FullName)" -ForegroundColor Red
            Remove-Item -Path $file.FullName -Force -ErrorAction Stop
            $deletedFiles += $file.FullName
            $totalDeleted++
            $totalSpaceSaved += $file.Length
        } catch {
            Write-Host "删除失败: $_" -ForegroundColor DarkRed
        }
    }
}

# 3. 结果汇总
Write-Host "`n" + "=" * 50
Write-Host "清理完成!" -ForegroundColor Green
Write-Host "删除文件数: $totalDeleted"
Write-Host "节省空间: $(Format-Size $totalSpaceSaved)"
Write-Host "=" * 50

# 4. 保存删除记录
if ($deletedFiles.Count -gt 0) {
    $logFile = "E_Cleaned_Files_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
    $deletedFiles | Out-File -FilePath $logFile -Encoding UTF8
    Write-Host "删除记录已保存到: $logFile" -ForegroundColor Gray
}

function Format-Size {
    param([long]$Size)
    if ($Size -ge 1GB) { return "{0:N2} GB" -f ($Size / 1GB) }
    elseif ($Size -ge 1MB) { return "{0:N2} MB" -f ($Size / 1MB) }
    elseif ($Size -ge 1KB) { return "{0:N2} KB" -f ($Size / 1KB) }
    else { return "$Size B" }
}