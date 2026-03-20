# Simple duplicate file finder
param(
    [string[]]$Paths = @("E:\"),
    [switch]$Quick
)

Write-Host "Duplicate File Finder" -ForegroundColor Cyan
Write-Host "Scanning: $($Paths -join ', ')" -ForegroundColor Yellow
Write-Host ""

# Collect file info
$fileTable = @{}
$totalFiles = 0
$startTime = Get-Date

foreach ($path in $Paths) {
    if (-not (Test-Path $path)) {
        Write-Host "Path not found: $path" -ForegroundColor Red
        continue
    }
    
    Write-Host "Scanning: $path" -ForegroundColor Green
    $files = Get-ChildItem -Path $path -Recurse -File -ErrorAction SilentlyContinue
    
    foreach ($file in $files) {
        $key = "$($file.Name)|$($file.Length)"
        
        if (-not $fileTable.ContainsKey($key)) {
            $fileTable[$key] = @()
        }
        $fileTable[$key] += $file.FullName
        
        $totalFiles++
        if ($totalFiles % 1000 -eq 0) {
            Write-Host "Scanned $totalFiles files..." -ForegroundColor Gray
        }
    }
}

$endTime = Get-Date
$scanTime = ($endTime - $startTime).TotalSeconds

# Find duplicates
$duplicates = $fileTable.GetEnumerator() | Where-Object { $_.Value.Count -gt 1 }

Write-Host ""
Write-Host "=" * 60
Write-Host "Scan complete!" -ForegroundColor Green
Write-Host "Time: $scanTime seconds"
Write-Host "Total files: $totalFiles"
Write-Host "Duplicate groups: $($duplicates.Count)"
Write-Host "=" * 60
Write-Host ""

if ($duplicates.Count -eq 0) {
    Write-Host "No duplicates found!" -ForegroundColor Green
    return
}

# Show duplicates
$totalSaved = 0
$groupNum = 1

foreach ($dup in $duplicates) {
    $files = $dup.Value
    $firstFile = Get-Item $files[0]
    $size = $firstFile.Length
    
    Write-Host "Group $groupNum - Size: $(Format-FileSize $size)" -ForegroundColor Cyan
    
    for ($i = 0; $i -lt $files.Count; $i++) {
        $color = if ($i -eq 0) { "Green" } else { "Yellow" }
        $prefix = if ($i -eq 0) { "[KEEP] " } else { "[DELETE] " }
        Write-Host "  $($i+1). $prefix$($files[$i])" -ForegroundColor $color
    }
    
    $totalSaved += $size * ($files.Count - 1)
    $groupNum++
    Write-Host ""
}

Write-Host "=" * 60
Write-Host "Total space to save: $(Format-FileSize $totalSaved)" -ForegroundColor Magenta
Write-Host "=" * 60

# Generate cleanup script
$scriptContent = @'
@echo off
echo Duplicate file cleaner
echo Will delete duplicate files (keeping first in each group):
echo.
'@

foreach ($dup in $duplicates) {
    $files = $dup.Value
    for ($i = 1; $i -lt $files.Count; $i++) {
        $scriptContent += "echo Delete: `"$($files[$i])`"`r`n"
        $scriptContent += "del /f `"$($files[$i])`"`r`n"
    }
    $scriptContent += "echo.`r`n"
}

$scriptContent += @'
echo Cleanup complete!
pause
'@

$scriptPath = "CleanDuplicates.bat"
$scriptContent | Out-File -FilePath $scriptPath -Encoding ASCII

Write-Host ""
Write-Host "Generated cleanup script: $scriptPath" -ForegroundColor Green
Write-Host "Review the script before running!" -ForegroundColor Yellow

function Format-FileSize {
    param([long]$Size)
    
    if ($Size -lt 1KB) { return "$Size B" }
    elseif ($Size -lt 1MB) { return "{0:N2} KB" -f ($Size / 1KB) }
    elseif ($Size -lt 1GB) { return "{0:N2} MB" -f ($Size / 1MB) }
    elseif ($Size -lt 1TB) { return "{0:N2} GB" -f ($Size / 1GB) }
    else { return "{0:N2} TB" -f ($Size / 1TB) }
}