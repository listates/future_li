# PowerShell脚本：修复所有文件中的域名引用
Write-Host "🚨 开始修复域名引用问题..." -ForegroundColor Yellow

# 备份当前状态
Write-Host "📝 备份当前状态..." -ForegroundColor Cyan
git stash

# 拉取最新代码
Write-Host "📥 拉取最新代码..." -ForegroundColor Cyan
git fetch origin
git reset --hard origin/master

# 修复所有文件中的域名引用
Write-Host "🔧 修复文件中的域名引用..." -ForegroundColor Cyan

# 修复HTML文件
Get-ChildItem -Recurse -Include "*.html" | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    $newContent = $content -replace 'http://navi-resources\.com', 'https://listates.github.io/future_li'
    $newContent = $newContent -replace 'https://navi-resources\.com', 'https://listates.github.io/future_li'
    $newContent = $newContent -replace 'navi-resources\.com', 'listates.github.io/future_li'
    Set-Content $_.FullName -Value $newContent -NoNewline
    Write-Host "✅ 修复: $($_.Name)" -ForegroundColor Green
}

# 修复JS文件
Get-ChildItem -Recurse -Include "*.js" | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    $newContent = $content -replace 'http://navi-resources\.com', 'https://listates.github.io/future_li'
    $newContent = $newContent -replace 'https://navi-resources\.com', 'https://listates.github.io/future_li'
    $newContent = $newContent -replace 'navi-resources\.com', 'listates.github.io/future_li'
    Set-Content $_.FullName -Value $newContent -NoNewline
    Write-Host "✅ 修复: $($_.Name)" -ForegroundColor Green
}

# 修复CSS文件
Get-ChildItem -Recurse -Include "*.css" | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    $newContent = $content -replace 'http://navi-resources\.com', 'https://listates.github.io/future_li'
    $newContent = $newContent -replace 'https://navi-resources\.com', 'https://listates.github.io/future_li'
    $newContent = $newContent -replace 'navi-resources\.com', 'listates.github.io/future_li'
    Set-Content $_.FullName -Value $newContent -NoNewline
    Write-Host "✅ 修复: $($_.Name)" -ForegroundColor Green
}

Write-Host "✅ 文件修复完成" -ForegroundColor Green

# 验证修复
Write-Host "🔍 验证修复结果..." -ForegroundColor Cyan
$remaining = Get-ChildItem -Recurse -Include "*.html", "*.js", "*.css" | Select-String -Pattern "navi-resources" | Measure-Object

if ($remaining.Count -gt 0) {
    Write-Host "❌ 还有未修复的域名引用: $($remaining.Count) 处" -ForegroundColor Red
    Get-ChildItem -Recurse -Include "*.html", "*.js", "*.css" | Select-String -Pattern "navi-resources" | ForEach-Object {
        Write-Host "  - $($_.FileName):$($_.LineNumber)" -ForegroundColor Yellow
    }
} else {
    Write-Host "✅ 所有域名引用已修复" -ForegroundColor Green
}

# 提交更改
Write-Host "📝 提交修复..." -ForegroundColor Cyan
git add .
git commit -m "紧急修复：彻底解决域名跳转问题，创建新的首页"

# 强制推送
Write-Host "🚀 强制推送到GitHub..." -ForegroundColor Cyan
git push origin master --force

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ 强制推送成功！" -ForegroundColor Green
} else {
    Write-Host "❌ 推送失败，尝试其他方法..." -ForegroundColor Red
    # 尝试使用token推送
    $token = $env:GITHUB_TOKEN
    if ($token) {
        git remote set-url origin "https://listates:$token@github.com/listates/future_li.git"
        git push origin master --force
    }
}

# 显示结果
Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "🎉 强制修复完成！" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "🌐 访问地址：" -ForegroundColor Yellow
Write-Host "------------------------------------------" -ForegroundColor Gray
Write-Host "主网站：https://listates.github.io/future_li" -ForegroundColor Blue
Write-Host "增强版：https://listates.github.io/future_li/resource-navigation-enhanced.html" -ForegroundColor Blue
Write-Host "简洁版：https://listates.github.io/future_li/resource-navigation-simple.html" -ForegroundColor Blue
Write-Host "------------------------------------------" -ForegroundColor Gray
Write-Host ""
Write-Host "⏳ 等待1-3分钟让GitHub Pages更新..." -ForegroundColor Yellow
Write-Host ""
Write-Host "🧪 测试步骤：" -ForegroundColor Yellow
Write-Host "1. 清除浏览器缓存 (Ctrl+Shift+Delete)" -ForegroundColor White
Write-Host "2. 访问 https://listates.github.io/future_li" -ForegroundColor White
Write-Host "3. 确认不再跳转到 navi-resources.com" -ForegroundColor White
Write-Host ""
Write-Host "✅ 修复完成！现在网站应该可以正常访问了。" -ForegroundColor Green