# PowerShell script to find duplicate files by content hash
param(
    [string]$Path = ".",
    [switch]$Delete,
    [switch]$DryRun = $true
)

Write-Host "Searching for duplicate files in: $Path" -ForegroundColor Cyan

# Get all files recursively
$files = Get-ChildItem -Path $Path -File -Recurse | Where-Object { $_.Length -gt 0 }

Write-Host "Found $($files.Count) files to process..." -ForegroundColor Yellow

# Dictionary to store hash -> file list
$hashMap = @{}

# Progress counter
$counter = 0
$total = $files.Count

foreach ($file in $files) {
    $counter++
    $percent = [math]::Round(($counter / $total) * 100, 2)
    Write-Progress -Activity "Calculating file hashes" -Status "$percent% complete" -PercentComplete $percent
    
    try {
        # Calculate MD5 hash of file content
        $hash = (Get-FileHash -Path $file.FullName -Algorithm MD5).Hash
        
        if (-not $hashMap.ContainsKey($hash)) {
            $hashMap[$hash] = @()
        }
        $hashMap[$hash] += $file
    }
    catch {
        Write-Warning "Could not process file: $($file.FullName)"
    }
}

Write-Progress -Activity "Calculating file hashes" -Completed

# Find duplicates
$duplicates = $hashMap.GetEnumerator() | Where-Object { $_.Value.Count -gt 1 }

if ($duplicates.Count -eq 0) {
    Write-Host "No duplicate files found!" -ForegroundColor Green
    return
}

Write-Host "`nFound $($duplicates.Count) sets of duplicate files:" -ForegroundColor Cyan

$totalDuplicates = 0
$spaceSaved = 0

foreach ($dup in $duplicates) {
    $filesList = $dup.Value
    $totalDuplicates += ($filesList.Count - 1)
    $spaceSaved += (($filesList.Count - 1) * $filesList[0].Length)
    
    Write-Host "`nHash: $($dup.Key)" -ForegroundColor Yellow
    Write-Host "Files ($($filesList.Count) duplicates):" -ForegroundColor White
    
    # Sort by creation time (oldest first)
    $sortedFiles = $filesList | Sort-Object CreationTime
    
    for ($i = 0; $i -lt $sortedFiles.Count; $i++) {
        $file = $sortedFiles[$i]
        $sizeMB = [math]::Round($file.Length / 1MB, 2)
        
        if ($i -eq 0) {
            Write-Host "  [KEEP] $($file.FullName) ($sizeMB MB) - Created: $($file.CreationTime)" -ForegroundColor Green
        }
        else {
            Write-Host "  [DELETE] $($file.FullName) ($sizeMB MB) - Created: $($file.CreationTime)" -ForegroundColor Red
            
            if ($Delete -and -not $DryRun) {
                try {
                    Remove-Item -Path $file.FullName -Force
                    Write-Host "    -> Deleted" -ForegroundColor DarkRed
                }
                catch {
                    Write-Host "    -> Failed to delete: $_" -ForegroundColor DarkYellow
                }
            }
        }
    }
}

$spaceSavedMB = [math]::Round($spaceSaved / 1MB, 2)
Write-Host "`nSummary:" -ForegroundColor Cyan
Write-Host "Total duplicate files found: $totalDuplicates" -ForegroundColor White
Write-Host "Potential space to save: $spaceSavedMB MB" -ForegroundColor White

if ($DryRun -and -not $Delete) {
    Write-Host "`nThis was a dry run. To actually delete duplicates, run:" -ForegroundColor Yellow
    Write-Host ".\find_duplicates.ps1 -Path `"$Path`" -Delete -DryRun:`$false" -ForegroundColor Green
}
elseif ($Delete -and $DryRun) {
    Write-Host "`nDry run mode: No files were actually deleted." -ForegroundColor Yellow
}