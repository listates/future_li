#!/bin/bash

# 互联网资源导航网站部署脚本
# 使用方法: ./deploy.sh [选项]

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 显示帮助信息
show_help() {
    cat << EOF
互联网资源导航网站部署脚本

使用方法: $0 [选项]

选项:
  -h, --help          显示此帮助信息
  -l, --local         本地预览（默认）
  -s, --simple        使用简洁版（默认使用简洁版）
  -f, --full          使用完整版
  -c, --compress      压缩HTML文件
  -d, --deploy        部署到GitHub Pages
  -u, --update        更新资源数据
  -b, --build         构建生产版本

示例:
  $0                   本地预览简洁版
  $0 -l -f            本地预览完整版
  $0 -c -b            构建压缩的生产版本
  $0 -d               部署到GitHub Pages
EOF
}

# 检查依赖
check_dependencies() {
    echo -e "${BLUE}检查依赖...${NC}"
    
    # 检查curl
    if ! command -v curl &> /dev/null; then
        echo -e "${YELLOW}警告: curl未安装，部分功能可能受限${NC}"
    fi
    
    # 检查git（用于GitHub Pages部署）
    if ! command -v git &> /dev/null; then
        echo -e "${YELLOW}警告: git未安装，无法使用GitHub Pages部署${NC}"
    fi
    
    echo -e "${GREEN}依赖检查完成${NC}"
}

# 本地预览
local_preview() {
    local file=$1
    echo -e "${BLUE}启动本地预览...${NC}"
    
    # 检查文件是否存在
    if [ ! -f "$file" ]; then
        echo -e "${RED}错误: 文件 $file 不存在${NC}"
        exit 1
    fi
    
    # 获取绝对路径
    local abs_path=$(realpath "$file")
    
    echo -e "${GREEN}文件: $file${NC}"
    echo -e "${GREEN}路径: $abs_path${NC}"
    echo -e "${YELLOW}在浏览器中打开: file://$abs_path${NC}"
    
    # 尝试在默认浏览器中打开
    if command -v xdg-open &> /dev/null; then
        # Linux
        xdg-open "file://$abs_path" &
    elif command -v open &> /dev/null; then
        # macOS
        open "file://$abs_path" &
    elif command -v start &> /dev/null; then
        # Windows (Git Bash)
        start "file://$abs_path" &
    else
        echo -e "${YELLOW}请手动在浏览器中打开: file://$abs_path${NC}"
    fi
    
    # 启动简单的HTTP服务器用于更好的预览（可选）
    echo -e "${BLUE}启动HTTP服务器 (按Ctrl+C停止)...${NC}"
    echo -e "${YELLOW}访问地址: http://localhost:8080${NC}"
    
    # 使用Python启动简单HTTP服务器
    if command -v python3 &> /dev/null; then
        python3 -m http.server 8080 &
        SERVER_PID=$!
        trap "kill $SERVER_PID 2>/dev/null" EXIT
        wait $SERVER_PID
    elif command -v python &> /dev/null; then
        python -m SimpleHTTPServer 8080 &
        SERVER_PID=$!
        trap "kill $SERVER_PID 2>/dev/null" EXIT
        wait $SERVER_PID
    else
        echo -e "${YELLOW}Python未安装，跳过HTTP服务器${NC}"
        echo -e "${YELLOW}按Enter键继续...${NC}"
        read
    fi
}

# 压缩HTML文件
compress_html() {
    local input_file=$1
    local output_file="${input_file%.html}-min.html"
    
    echo -e "${BLUE}压缩HTML文件: $input_file -> $output_file${NC}"
    
    # 简单的压缩（移除多余空格和换行）
    if command -v html-minifier &> /dev/null; then
        # 使用html-minifier（需要安装: npm install -g html-minifier）
        html-minifier \
            --collapse-whitespace \
            --remove-comments \
            --remove-optional-tags \
            --remove-redundant-attributes \
            --remove-script-type-attributes \
            --remove-tag-whitespace \
            --use-short-doctype \
            --minify-css true \
            --minify-js true \
            -o "$output_file" \
            "$input_file"
    else
        # 简单的sed压缩
        sed ':a;N;$!ba;s/>\s*</></g' "$input_file" | \
        tr -d '\n' | \
        sed 's/  \+/ /g' > "$output_file"
    fi
    
    # 计算压缩率
    local original_size=$(stat -f%z "$input_file" 2>/dev/null || stat -c%s "$input_file")
    local compressed_size=$(stat -f%z "$output_file" 2>/dev/null || stat -c%s "$output_file")
    local reduction=$((100 - compressed_size * 100 / original_size))
    
    echo -e "${GREEN}压缩完成:${NC}"
    echo -e "  原始大小: $((original_size / 1024)) KB"
    echo -e "  压缩后: $((compressed_size / 1024)) KB"
    echo -e "  压缩率: ${reduction}%"
}

# 构建生产版本
build_production() {
    echo -e "${BLUE}构建生产版本...${NC}"
    
    # 创建dist目录
    mkdir -p dist
    
    # 复制文件
    cp resource-navigation-simple.html dist/
    cp README.md dist/
    
    # 压缩HTML
    compress_html "dist/resource-navigation-simple.html"
    
    # 创建CNAME文件（用于自定义域名）
    echo "# 自定义域名配置" > dist/CNAME
    echo "# 取消注释并修改为你的域名：" >> dist/CNAME
    echo "# example.com" >> dist/CNAME
    
    # 创建.nojekyll文件（用于GitHub Pages）
    touch dist/.nojekyll
    
    echo -e "${GREEN}生产版本构建完成，文件位于 dist/ 目录${NC}"
}

# 部署到GitHub Pages
deploy_github_pages() {
    echo -e "${BLUE}部署到GitHub Pages...${NC}"
    
    # 检查git仓库
    if [ ! -d .git ]; then
        echo -e "${YELLOW}初始化git仓库...${NC}"
        git init
        git add .
        git commit -m "初始提交: 互联网资源导航网站"
    fi
    
    # 构建生产版本
    build_production
    
    # 切换到dist目录
    cd dist
    
    # 初始化git仓库（用于gh-pages分支）
    git init
    git add .
    git commit -m "部署: $(date '+%Y-%m-%d %H:%M:%S')"
    
    echo -e "${YELLOW}请按照以下步骤手动部署:${NC}"
    echo "1. 在GitHub上创建新仓库"
    echo "2. 添加远程仓库: git remote add origin https://github.com/用户名/仓库名.git"
    echo "3. 推送到GitHub: git push -u origin main"
    echo "4. 在仓库设置中启用GitHub Pages"
    echo ""
    echo "或者使用gh-pages工具自动部署:"
    echo "  npm install -g gh-pages"
    echo "  gh-pages -d dist"
    
    cd ..
}

# 更新资源数据
update_resources() {
    echo -e "${BLUE}更新资源数据...${NC}"
    
    # 这里可以添加自动更新资源的逻辑
    # 例如从API获取最新资源列表
    
    echo -e "${YELLOW}目前需要手动更新 resourcesData 对象${NC}"
    echo -e "${GREEN}请编辑HTML文件中的resourcesData对象来更新资源${NC}"
}

# 主函数
main() {
    # 默认选项
    MODE="local"
    VERSION="simple"
    COMPRESS=false
    DEPLOY=false
    UPDATE=false
    BUILD=false
    
    # 解析参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -l|--local)
                MODE="local"
                shift
                ;;
            -s|--simple)
                VERSION="simple"
                shift
                ;;
            -f|--full)
                VERSION="full"
                shift
                ;;
            -c|--compress)
                COMPRESS=true
                shift
                ;;
            -d|--deploy)
                DEPLOY=true
                shift
                ;;
            -u|--update)
                UPDATE=true
                shift
                ;;
            -b|--build)
                BUILD=true
                shift
                ;;
            *)
                echo -e "${RED}未知选项: $1${NC}"
                show_help
                exit 1
                ;;
        esac
    done
    
    # 显示标题
    echo -e "${BLUE}=================================${NC}"
    echo -e "${GREEN}  互联网资源导航网站部署工具   ${NC}"
    echo -e "${BLUE}=================================${NC}"
    
    # 检查依赖
    check_dependencies
    
    # 确定要使用的文件
    if [ "$VERSION" = "simple" ]; then
        FILE="resource-navigation-simple.html"
    else
        FILE="resource-navigation.html"
    fi
    
    # 执行操作
    if [ "$UPDATE" = true ]; then
        update_resources
    fi
    
    if [ "$BUILD" = true ]; then
        build_production
    fi
    
    if [ "$COMPRESS" = true ] && [ "$BUILD" = false ]; then
        compress_html "$FILE"
    fi
    
    if [ "$DEPLOY" = true ]; then
        deploy_github_pages
    fi
    
    if [ "$MODE" = "local" ] && [ "$DEPLOY" = false ] && [ "$BUILD" = false ]; then
        local_preview "$FILE"
    fi
    
    echo -e "${GREEN}操作完成！${NC}"
}

# 运行主函数
main "$@"