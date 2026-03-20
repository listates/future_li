@echo off
echo ========================================
echo   多驱动器重复文件清理工具
echo ========================================
echo.
echo 警告：这将清理 E: 到 N: 所有驱动器！
echo 请确保已备份重要文件！
echo.
echo 可用的驱动器：
wmic logicaldisk where "drivetype=3" get caption | findstr /v "Caption"
echo.

set /p confirm="确认要清理 E: 到 N: 所有驱动器吗？(y/n): "

if /i "%confirm%" neq "y" (
    echo 操作已取消。
    pause
    exit /b 0
)

echo.
echo 请选择清理模式：
echo   1. 仅扫描查看（推荐先使用）
echo   2. 扫描并删除重复文件
echo.

set /p mode="请选择 (1/2): "

if "%mode%"=="1" (
    echo 开始扫描模式（不删除文件）...
    call :scan_all
) else if "%mode%"=="2" (
    echo 开始清理模式（删除重复文件）...
    call :clean_all
) else (
    echo 无效选择！
    pause
    exit /b 1
)

echo.
echo 操作完成！
pause
exit /b 0

:scan_all
echo.
echo ========================================
echo   开始扫描所有驱动器 (E: 到 N:)
echo ========================================

for %%d in (E F G H I J K L M N) do (
    if exist %%d:\ (
        echo.
        echo 扫描驱动器 %%d: ...
        echo ==========================
        powershell -ExecutionPolicy Bypass -File "%~dp0find_duplicates.ps1" -Path "%%d:\" 2>nul
        if errorlevel 1 (
            echo 扫描 %%d: 时出错或没有重复文件
        )
    ) else (
        echo 驱动器 %%d: 不存在，跳过
    )
)
goto :eof

:clean_all
echo.
echo ========================================
echo   开始清理所有驱动器 (E: 到 N:)
echo ========================================
echo 警告：这将实际删除文件！
echo.

set /p final_confirm="最后确认：真的要删除所有重复文件吗？(输入 YES 确认): "

if /i "%final_confirm%" neq "YES" (
    echo 操作已取消。
    goto :eof
)

for %%d in (E F G H I J K L M N) do (
    if exist %%d:\ (
        echo.
        echo 清理驱动器 %%d: ...
        echo ==========================
        powershell -ExecutionPolicy Bypass -File "%~dp0find_duplicates.ps1" -Path "%%d:\" -Delete 2>nul
        if errorlevel 1 (
            echo 清理 %%d: 时出错
        )
    ) else (
        echo 驱动器 %%d: 不存在，跳过
    )
)
goto :eof