@echo off
echo 正在配置Git凭据...
git config --global user.email "listates449@gmail.com"
git config --global user.name "listates"

echo 正在推送到GitHub仓库...
git push -u origin main

if %errorlevel% equ 0 (
    echo 推送成功！
    echo 仓库地址: https://github.com/listates/future_li
) else (
    echo 推送失败，请检查:
    echo 1. 网络连接
    echo 2. GitHub凭据
    echo 3. 仓库权限
)

pause