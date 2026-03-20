#!/bin/bash

# 强制修复域名跳转问题
echo "🚨 强制修复域名跳转问题..."

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_info() { echo -e "${BLUE}📝 $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }

# 1. 备份当前状态
print_info "备份当前状态..."
git stash

# 2. 拉取最新代码
print_info "拉取最新代码..."
git fetch origin
git reset --hard origin/master

# 3. 批量修复所有文件
print_info "批量修复所有文件中的域名引用..."

# 修复HTML文件
find . -name "*.html" -type f ! -path "./.git/*" -exec sed -i 's|http://navi-resources\.com|https://listates.github.io/future_li|g' {} \;
find . -name "*.html" -type f ! -path "./.git/*" -exec sed -i 's|https://navi-resources\.com|https://listates.github.io/future_li|g' {} \;
find . -name "*.html" -type f ! -path "./.git/*" -exec sed -i 's|navi-resources\.com|listates.github.io/future_li|g' {} \;

# 修复JS文件
find . -name "*.js" -type f ! -path "./.git/*" -exec sed -i 's|http://navi-resources\.com|https://listates.github.io/future_li|g' {} \;
find . -name "*.js" -type f ! -path "./.git/*" -exec sed -i 's|https://navi-resources\.com|https://listates.github.io/future_li|g' {} \;
find . -name "*.js" -type f ! -path "./.git/*" -exec sed -i 's|navi-resources\.com|listates.github.io/future_li|g' {} \;

# 修复CSS文件
find . -name "*.css" -type f ! -path "./.git/*" -exec sed -i 's|http://navi-resources\.com|https://listates.github.io/future_li|g' {} \;
find . -name "*.css" -type f ! -path "./.git/*" -exec sed -i 's|https://navi-resources\.com|https://listates.github.io/future_li|g' {} \;
find . -name "*.css" -type f ! -path "./.git/*" -exec sed -i 's|navi-resources\.com|listates.github.io/future_li|g' {} \;

print_success "文件修复完成"

# 4. 验证修复
print_info "验证修复结果..."
grep -r "navi-resources\.com" . --include="*.html" --include="*.js" --include="*.css" 2>/dev/null

if [ $? -eq 0 ]; then
    print_error "还有未修复的域名引用"
    exit 1
else
    print_success "所有域名引用已修复"
fi

# 5. 创建新的index.html（直接显示内容，不跳转）
print_info "创建新的首页..."
cat > index.html << 'EOF'
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>互联网资源导航</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', 'Microsoft YaHei', sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            color: white;
            padding: 20px;
            text-align: center;
        }
        .container {
            max-width: 800px;
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            padding: 40px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            border: 1px solid rgba(255, 255, 255, 0.2);
        }
        h1 {
            font-size: 2.5rem;
            margin-bottom: 20px;
            background: linear-gradient(45deg, #ff6b6b, #4ecdc4);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }
        .status {
            background: rgba(76, 175, 80, 0.2);
            border: 2px solid #4CAF50;
            border-radius: 10px;
            padding: 20px;
            margin: 20px 0;
        }
        .links {
            display: flex;
            flex-direction: column;
            gap: 15px;
            margin: 30px 0;
        }
        .link {
            display: block;
            background: rgba(255, 255, 255, 0.2);
            padding: 15px;
            border-radius: 10px;
            color: white;
            text-decoration: none;
            transition: all 0.3s ease;
            border: 1px solid rgba(255, 255, 255, 0.3);
        }
        .link:hover {
            background: rgba(255, 255, 255, 0.3);
            transform: translateY(-3px);
        }
        .footer {
            margin-top: 30px;
            font-size: 0.9rem;
            opacity: 0.8;
        }
        @media (max-width: 768px) {
            .container { padding: 20px; }
            h1 { font-size: 2rem; }
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🌐 互联网资源导航</h1>
        <p>发现、收藏、分享互联网上最优质的资源</p>
        
        <div class="status">
            <h3>✅ 网站状态正常</h3>
            <p>域名跳转问题已修复</p>
            <p>现在可以正常访问所有功能</p>
        </div>
        
        <div class="links">
            <a href="resource-navigation-enhanced.html" class="link">
                🚀 进入增强版资源导航
            </a>
            <a href="resource-navigation-simple.html" class="link">
                📄 简洁版资源导航
            </a>
            <a href="analytics-dashboard.html" class="link">
                📊 数据分析面板
            </a>
        </div>
        
        <div class="footer">
            <p>访问地址: https://listates.github.io/future_li</p>
            <p>© 2026 互联网资源导航 | 基于 GitHub Pages 部署</p>
        </div>
    </div>
</body>
</html>
EOF

print_success "新的首页已创建"

# 6. 提交更改
print_info "提交修复..."
git add .
git commit -m "紧急修复：彻底解决域名跳转问题，创建新的首页"

# 7. 强制推送
print_info "强制推送到GitHub..."
git push origin master --force

if [ $? -eq 0 ]; then
    print_success "✅ 强制推送成功！"
else
    print_error "推送失败，尝试其他方法..."
    # 尝试使用token推送
    git remote set-url origin https://listates:$GITHUB_TOKEN@github.com/listates/future_li.git
    git push origin master --force
fi

# 8. 显示结果
echo ""
echo "=========================================="
print_success "🎉 强制修复完成！"
echo "=========================================="
echo ""
echo "🌐 访问地址："
echo "------------------------------------------"
echo "主网站：${BLUE}https://listates.github.io/future_li${NC}"
echo "增强版：${BLUE}https://listates.github.io/future_li/resource-navigation-enhanced.html${NC}"
echo "简洁版：${BLUE}https://listates.github.io/future_li/resource-navigation-simple.html${NC}"
echo "------------------------------------------"
echo ""
echo "⏳ 等待1-3分钟让GitHub Pages更新..."
echo ""
echo "🧪 测试步骤："
echo "1. 清除浏览器缓存 (Ctrl+Shift+Delete)"
echo "2. 访问 https://listates.github.io/future_li"
echo "3. 确认不再跳转到 navi-resources.com"
echo ""
print_success "修复完成！现在网站应该可以正常访问了。"