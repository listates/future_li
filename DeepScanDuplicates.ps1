# Deep duplicate scanner using file hash
param(
    [string]$Path = "E:\"
)

function Get-FileHashSafe {
    param([string]$FilePath)
    try {
        return (Get-FileHash -Path $FilePath -Algorithm MD5 -ErrorAction Stop).Hash
    } catch {
        return $null
    }
}

Write-Host "Deep duplicate scan: $Path" -ForegroundColor Cyan
Write-Host "This may take a while..." -ForegroundColor Yellow
Write-Host ""

# Phase 1: Group by size first (fast)
Write-Host "Phase 1: Grouping by file size..." -ForegroundColor Green
$files = Get-ChildItem -Path $Path -Recurse -File -ErrorAction SilentlyContinue | Where-Object {$_.Length -gt 0}
$sizeGroups = $files | Group-Object Length | Where-Object {$_.Count -gt 1}

Write-Host "Found $($sizeGroups.Count) size groups with potential duplicates"
Write-Host ""

# Phase 2: Check hash for same-size files
$hashGroups = @{}
$processed = 0
$totalToCheck = ($sizeGroups | Measure-Object -Property Count -Sum).Sum

foreach ($group in $sizeGroups) {
    foreach ($file in $group.Group) {
        $hash = Get-FileHashSafe -FilePath $file.FullName
        if ($hash) {
            if (-not $hashGroups.ContainsKey($hash)) {
                $hashGroups[$hash] = @()
            }
            $hashGroups[$hash] += $file.FullName
        }
        
        $processed++
        if ($processed % 100 -eq 0) {
            $percent = [math]::Round(($processed / $totalToCheck) * 100, 1)
            Write-Host "Progress: $processed/$totalToCheck files ($percent%)" -ForegroundColor Gray
        }
    }
}

# Filter to actual duplicates
$duplicates = $hashGroups.GetEnumerator() | Where-Object {$_.Value.Count -gt 1}

Write-Host ""
Write-Host "=" * 60
Write-Host "Scan complete!" -ForegroundColor Green
Write-Host "Total files scanned: $($files.Count)"
Write-Host "Duplicate groups found: $($duplicates.Count)"
Write-Host "=" * 60
Write-Host ""

if ($duplicates.Count -eq 0) {
    Write-Host "No duplicates found!" -ForegroundColor Green
    return
}

# Show results
$totalSaved = 0
$groupNum = 1
$results = @()

foreach ($dup in $duplicates) {
    $files = $dup.Value
    $firstFile = Get-Item $files[0]
    $size = $firstFile.Length
    
    $result = [PSCustomObject]@{
        Group = $groupNum
        Size = $size
        Hash = $dup.Key.Substring(0, 16) + "..."
        Files = $files
        Keep = $files[0]
        Delete = $files[1..($files.Count-1)]
    }
    $results += $result
    
    Write-Host "Group $groupNum - Size: $(Format-Size $size)" -ForegroundColor Cyan
    Write-Host "Hash: $($dup.Key.Substring(0, 16))..."
    
    Write-Host "  [KEEP] $($files[0])" -ForegroundColor Green
    for ($i = 1; $i -lt $files.Count; $i++) {
        Write-Host "  [DELETE] $($files[$i])" -ForegroundColor Yellow
    }
    Write-Host ""
    
    $totalSaved += $size * ($files.Count - 1)
    $groupNum++
}

Write-Host "=" * 60
Write-Host "Total space to save: $(Format-Size $totalSaved)" -ForegroundColor Magenta
Write-Host "=" * 60

# Generate cleanup script
$scriptContent = @'
@echo off
REM Duplicate file cleanup script
REM Generated on {0}
echo Starting duplicate file cleanup...
echo.
'@ -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss")

foreach ($result in $results) {
    foreach ($file in $result.Delete) {
        $scriptContent += "echo Deleting: `"$file`"`r`n"
        $scriptContent += "del /f `"$file`"`r`n"
    }
}

$scriptContent += @'
echo.
echo Cleanup complete!
echo Total space saved: {0}
pause
'@ -f (Format-Size $totalSaved)

$scriptPath = "CleanDuplicates_Deep.bat"
$scriptContent | Out-File -FilePath $scriptPath -Encoding ASCII

Write-Host ""
Write-Host "Generated cleanup script: $scriptPath" -ForegroundColor Green
Write-Host "Review before running!" -ForegroundColor Yellow

# Save results to CSV
$csvPath = "DuplicateResults.csv"
$results | ForEach-Object {
    $row = [PSCustomObject]@{
        Group = $_.Group
        Size_GB = [math]::Round($_.Size / 1GB, 3)
        Hash = $_.Hash
        Keep_File = $_.Keep
        Delete_Count = $_.Delete.Count
        Delete_Files = ($_.Delete -join " | ")
    }
    $row
} | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8

Write-Host "Results saved to: $csvPath" -ForegroundColor Green

function Format-Size {
    param([long]$Size)
    
    if ($Size -lt 1KB) { return "$Size B" }
    elseif ($Size -lt 1MB) { return "{0:N2} KB" -f ($Size / 1KB) }
    elseif ($Size -lt 1GB) { return "{0:N2} MB" -f ($Size / 1MB) }
    elseif ($Size -lt 1TB) { return "{0:N2} GB" -f ($Size / 1GB) }
    else { return "{0:N2} TB" -f ($Size / 1TB) }
}