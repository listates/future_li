@echo off
echo ========================================
echo   Duplicate File Cleaner
echo ========================================
echo.
echo This script helps you find and remove duplicate files.
echo.
echo Options:
echo   1. Scan current directory
echo   2. Scan specific directory
echo   3. Exit
echo.

set /p choice="Enter your choice (1-3): "

if "%choice%"=="1" (
    set scan_path=.
    goto :scan
) else if "%choice%"=="2" (
    set /p scan_path="Enter directory path: "
    goto :scan
) else if "%choice%"=="3" (
    exit /b 0
) else (
    echo Invalid choice!
    pause
    exit /b 1
)

:scan
echo.
echo Scanning for duplicates in: %scan_path%
echo This may take a while depending on the number of files...
echo.

powershell -ExecutionPolicy Bypass -File "%~dp0find_duplicates.ps1" -Path "%scan_path%"

echo.
echo ========================================
echo   Next Steps:
echo ========================================
echo.
echo 1. Review the duplicate files listed above
echo 2. To delete duplicates, run:
echo    powershell -ExecutionPolicy Bypass -File "%~dp0find_duplicates.ps1" -Path "%scan_path%" -Delete -DryRun:$false
echo.
echo WARNING: Make sure to backup important files before deleting!
echo.
pause