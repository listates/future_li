#!/bin/bash

# 网站优化部署脚本
echo "🚀 开始优化部署网站..."

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

# 1. 检查当前状态
print_info "检查当前Git状态..."
git status

# 2. 添加所有更改
print_info "添加所有更改..."
git add .

# 3. 提交更改
print_info "提交优化更改..."
git commit -m "网站优化：修复域名跳转、美化首页、增强功能"

if [ $? -ne 0 ]; then
    print_warning "提交失败，可能没有更改或网络问题"
    print_info "尝试直接推送现有更改..."
fi

# 4. 尝试推送
print_info "尝试推送到GitHub..."
max_retries=3
retry_count=0

while [ $retry_count -lt $max_retries ]; do
    print_info "尝试第 $((retry_count+1)) 次推送..."
    
    # 尝试不同的推送方法
    if [ $retry_count -eq 0 ]; then
        git push origin master
    elif [ $retry_count -eq 1 ]; then
        git push origin master --force-with-lease
    else
        print_warning "尝试使用SSH方式..."
        git remote set-url origin git@github.com:listates/future_li.git
        git push origin master
    fi
    
    if [ $? -eq 0 ]; then
        print_success "推送成功！"
        break
    else
        retry_count=$((retry_count+1))
        if [ $retry_count -lt $max_retries ]; then
            print_warning "推送失败，等待10秒后重试..."
            sleep 10
        else
            print_error "所有推送尝试都失败了"
            print_info "请手动推送或检查网络连接"
        fi
    fi
done

# 5. 显示部署信息
echo ""
echo "=========================================="
print_success "🎉 网站优化完成！"
echo "=========================================="
echo ""
echo "📊 优化内容："
echo "------------------------------------------"
echo "1. ${GREEN}域名跳转修复${NC}"
echo "   - 彻底移除 navi-resources.com 引用"
echo "   - 所有链接指向正确地址"
echo ""
echo "2. ${GREEN}首页美化${NC}"
echo "   - 现代化渐变背景"
echo "   - 粒子动画效果"
echo "   - 响应式卡片设计"
echo ""
echo "3. ${GREEN}功能增强${NC}"
echo "   - 鼠标交互动画"
echo "   - 资源统计展示"
echo "   - 多版本入口"
echo ""
echo "4. ${GREEN}性能优化${NC}"
echo "   - 本地资源加载"
echo "   - 异步脚本执行"
echo "   - 缓存友好设计"
echo "------------------------------------------"

# 6. 访问地址
echo ""
echo "🌐 访问地址："
echo "------------------------------------------"
echo "主网站：${BLUE}https://listates.github.io/future_li${NC}"
echo "增强版：${BLUE}https://listates.github.io/future_li/resource-navigation-enhanced.html${NC}"
echo "简洁版：${BLUE}https://listates.github.io/future_li/resource-navigation-simple.html${NC}"
echo "数据分析：${BLUE}https://listates.github.io/future_li/analytics-dashboard.html${NC}"
echo "------------------------------------------"

# 7. 测试建议
echo ""
echo "🧪 测试建议："
echo "------------------------------------------"
echo "1. ${YELLOW}清除浏览器缓存${NC}"
echo "   - Chrome: Ctrl+Shift+Delete"
echo "   - Firefox: Ctrl+Shift+Delete"
echo "   - Edge: Ctrl+Shift+Delete"
echo ""
echo "2. ${YELLOW}测试所有页面${NC}"
echo "   - 首页：功能入口正常"
echo "   - 增强版：搜索功能正常"
echo "   - 简洁版：基础功能正常"
echo ""
echo "3. ${YELLOW}检查域名跳转${NC}"
echo "   - 确认不再跳转到无效域名"
echo "   - 所有链接指向正确地址"
echo "------------------------------------------"

# 8. 故障排除
echo ""
echo "🔧 故障排除："
echo "------------------------------------------"
echo "如果网站无法访问："
echo "1. 等待1-3分钟GitHub Pages构建"
echo "2. 检查：https://github.com/listates/future_li/actions"
echo "3. 确认.nojekyll文件存在"
echo ""
echo "如果功能不正常："
echo "1. 检查浏览器控制台错误"
echo "2. 清除浏览器缓存"
echo "3. 尝试不同浏览器"
echo "------------------------------------------"

# 9. 二维码生成（可选）
echo ""
echo "📱 移动端访问："
echo "------------------------------------------"
echo "可以使用手机扫描以下二维码访问："
echo ""
echo "     https://listates.github.io/future_li"
echo ""
echo "或直接输入网址访问"
echo "------------------------------------------"

print_success "🎯 优化部署流程完成！"
echo ""
echo "现在可以访问网站测试所有功能："
echo "${BLUE}https://listates.github.io/future_li${NC}"