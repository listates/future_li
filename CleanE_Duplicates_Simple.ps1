# Clean duplicate files in E: drive
Write-Host "Cleaning duplicate files in E:" -ForegroundColor Cyan
Write-Host "=" * 50

# Find duplicates (same name + size)
$duplicates = Get-ChildItem -Path "E:\" -Recurse -File -ErrorAction SilentlyContinue | 
              Where-Object {$_.Length -gt 0} |
              Group-Object {$_.Name + "|" + $_.Length} | 
              Where-Object {$_.Count -gt 1}

Write-Host "Found $($duplicates.Count) duplicate groups"

if ($duplicates.Count -eq 0) {
    Write-Host "No duplicates found" -ForegroundColor Green
    exit
}

# Clean up
$totalDeleted = 0
$totalSpaceSaved = 0
$deletedFiles = @()

foreach ($group in $duplicates) {
    $files = $group.Group | Sort-Object LastWriteTime -Descending
    $keepFile = $files[0]  # Keep newest
    $deleteFiles = $files[1..($files.Count-1)]
    
    Write-Host "`nFile: $($group.Name.Split('|')[0])" -ForegroundColor Yellow
    Write-Host "Size: $(FormatSize $keepFile.Length)" -ForegroundColor Gray
    Write-Host "Keep: $($keepFile.FullName)" -ForegroundColor Green
    
    foreach ($file in $deleteFiles) {
        try {
            Write-Host "Delete: $($file.FullName)" -ForegroundColor Red
            Remove-Item -Path $file.FullName -Force -ErrorAction Stop
            $deletedFiles += $file.FullName
            $totalDeleted++
            $totalSpaceSaved += $file.Length
        } catch {
            Write-Host "Failed: $_" -ForegroundColor DarkRed
        }
    }
}

# Results
Write-Host "`n" + "=" * 50
Write-Host "Cleanup complete!" -ForegroundColor Green
Write-Host "Files deleted: $totalDeleted"
Write-Host "Space saved: $(FormatSize $totalSpaceSaved)"
Write-Host "=" * 50

# Save log
if ($deletedFiles.Count -gt 0) {
    $logFile = "E_Cleaned_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
    $deletedFiles | Out-File -FilePath $logFile -Encoding ASCII
    Write-Host "Log saved: $logFile" -ForegroundColor Gray
}

function FormatSize($size) {
    if ($size -ge 1GB) { return "{0:N2} GB" -f ($size / 1GB) }
    elseif ($size -ge 1MB) { return "{0:N2} MB" -f ($size / 1MB) }
    elseif ($size -ge 1KB) { return "{0:N2} KB" -f ($size / 1KB) }
    else { return "$size B" }
}