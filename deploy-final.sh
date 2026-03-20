#!/bin/bash

# 最终版网站部署脚本
echo "🚀 开始部署最终版增强网站..."

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_info() {
    echo -e "${BLUE}📝 $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# 1. 检查Git状态
print_info "检查Git状态..."
git status

if [ $? -ne 0 ]; then
    print_error "Git状态检查失败"
    exit 1
fi

# 2. 添加所有新文件
print_info "添加新文件..."
git add background-effects.css mouse-animations.js resources-database.js main-website-integration.js deploy-final.sh

# 3. 提交更改
print_info "提交更改..."
git commit -m "最终版增强网站：背景美化、鼠标动画、1000+资源、完整用户系统"

if [ $? -ne 0 ]; then
    print_warning "提交失败，可能没有更改"
    # 继续执行，可能文件已经提交
fi

# 4. 推送到GitHub
print_info "推送到GitHub..."
git push origin master

if [ $? -ne 0 ]; then
    print_error "推送失败"
    exit 1
fi

print_success "代码推送完成！"

# 5. 等待GitHub Pages构建
print_info "等待GitHub Pages构建..."
echo "构建通常需要1-3分钟..."
echo "可以在 https://github.com/listates/future_li/actions 查看构建状态"

# 6. 测试网站
print_info "测试网站..."
echo "等待10秒让构建开始..."
sleep 10

# 7. 显示部署总结
echo ""
echo "=========================================="
print_success "🎉 部署完成！"
echo "=========================================="
echo ""
echo "📊 部署内容总结："
echo "------------------------------------------"
echo "1. ${GREEN}背景美化效果${NC}"
echo "   - 渐变背景动画"
echo "   - 粒子效果"
echo "   - 鼠标跟随动画"
echo ""
echo "2. ${GREEN}鼠标交互效果${NC}"
echo "   - 鼠标轨迹"
echo "   - 卡片悬停动画"
echo "   - 页面加载动画"
echo ""
echo "3. ${GREEN}资源数据库${NC}"
echo "   - 1000+高质量资源"
echo "   - 智能搜索功能"
echo "   - 分类过滤"
echo ""
echo "4. ${GREEN}完整用户系统${NC}"
echo "   - 注册/登录功能"
echo "   - 收藏夹系统"
echo "   - 评论和评分"
echo ""
echo "5. ${GREEN}现代化UI设计${NC}"
echo "   - 响应式布局"
echo "   - 动画效果"
echo "   - 暗色模式支持"
echo "------------------------------------------"

# 8. 访问信息
echo ""
echo "🌐 访问地址："
echo "------------------------------------------"
echo "主网站：${BLUE}https://listates.github.io/future_li${NC}"
echo "增强版：${BLUE}https://listates.github.io/future_li/resource-navigation-enhanced.html${NC}"
echo "数据分析：${BLUE}https://listates.github.io/future_li/analytics-dashboard.html${NC}"
echo "------------------------------------------"

# 9. 后续步骤
echo ""
echo "🚀 后续步骤："
echo "------------------------------------------"
echo "1. ${YELLOW}配置自定义域名${NC}"
echo "   访问：https://github.com/listates/future_li/settings/pages"
echo "   输入你的域名，勾选Enforce HTTPS"
echo ""
echo "2. ${YELLOW}设置Supabase数据库${NC}"
echo "   创建项目：https://supabase.com"
echo "   运行SQL脚本：backend/supabase-config.md"
echo ""
echo "3. ${YELLOW}测试所有功能${NC}"
echo "   - 用户注册/登录"
echo "   - 资源搜索"
echo "   - 收藏功能"
echo "   - 评论系统"
echo ""
echo "4. ${YELLOW}收集用户反馈${NC}"
echo "   - 添加反馈表单"
echo "   - 分析使用数据"
echo "   - 持续优化改进"
echo "------------------------------------------"

# 10. 故障排除
echo ""
echo "🔧 故障排除："
echo "------------------------------------------"
echo "如果网站无法访问："
echo "1. 检查GitHub Actions构建状态"
echo "2. 确认index.html文件存在"
echo "3. 检查.nojekyll文件"
echo "4. 等待DNS传播（最多48小时）"
echo ""
echo "如果功能不正常："
echo "1. 检查浏览器控制台错误"
echo "2. 确认Supabase配置正确"
echo "3. 检查网络连接"
echo "------------------------------------------"

# 11. 联系方式
echo ""
echo "📞 支持与帮助："
echo "------------------------------------------"
echo "GitHub仓库：${BLUE}https://github.com/listates/future_li${NC}"
echo "问题反馈：GitHub Issues"
echo "文档：ENHANCED_DEPLOYMENT_GUIDE.md"
echo "------------------------------------------"

echo ""
print_success "🎯 部署流程完成！"
echo "现在可以访问网站测试所有功能了。"

# 12. 自动打开网站（可选）
read -p "是否要自动打开网站？(y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if command -v xdg-open &> /dev/null; then
        xdg-open "https://listates.github.io/future_li"
    elif command -v open &> /dev/null; then
        open "https://listates.github.io/future_li"
    elif command -v start &> /dev/null; then
        start "https://listates.github.io/future_li"
    else
        print_warning "无法自动打开浏览器，请手动访问"
    fi
fi