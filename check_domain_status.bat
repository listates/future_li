@echo off
echo ========================================
echo 域名配置状态检查工具
echo 域名: navi-resources.com
echo 时间: %date% %time%
echo ========================================

echo.
echo [1] 检查DNS解析...
nslookup navi-resources.com 2>nul | findstr "Address\|canonical"

echo.
echo [2] 检查HTTP响应...
curl -I https://navi-resources.com 2>nul | findstr "HTTP"

echo.
echo [3] 检查HTTPS证书...
curl -I https://navi-resources.com 2>nul | findstr "Strict-Transport-Security"

echo.
echo [4] 检查GitHub Pages...
curl -I https://listates.github.io/future_li/ 2>nul | findstr "HTTP"

echo.
echo ========================================
echo 检查完成！
echo.
echo 如果看到以下结果表示配置成功：
echo 1. DNS解析到GitHub IP
echo 2. HTTP 200 OK 或 301重定向
echo 3. 有Strict-Transport-Security头
echo 4. GitHub Pages返回200 OK
echo ========================================
pause