# 互联网资源导航

智能一站式互联网资源导航平台，提供分类搜索、热门推荐、个性化收藏和用户评论功能。

## 🌐 在线演示

- [GitHub Pages](https://your-username.github.io/resource-navigation)
- [Vercel](https://resource-navigation.vercel.app)
- [Netlify](https://resource-navigation.netlify.app)

## ✨ 功能特性

### 核心功能
- 🔍 **智能搜索** - 实时搜索、搜索提示、高亮匹配
- 📁 **分类浏览** - 6大分类，48+精选资源
- ⭐ **热门推荐** - 每日更新热门工具和资源
- 💖 **用户收藏** - 本地存储收藏功能
- 💬 **用户评论** - 社区交流互动
- 📊 **数据统计** - 访问量、收藏数、评论数统计

### 用户体验
- 📱 **响应式设计** - 完美适配手机、平板、电脑
- 🎨 **现代UI** - 渐变背景、卡片阴影、平滑动画
- ⌨️ **键盘快捷键** - Ctrl+K搜索、ESC清空
- 🚀 **快速导航** - 分类直达、平滑滚动
- 📈 **分析跟踪** - Google Analytics集成

## 🚀 快速部署

### GitHub Pages（免费）
1. Fork此仓库
2. 仓库设置 → Pages → 选择main分支
3. 访问 `https://你的用户名.github.io/resource-navigation`

### Vercel（推荐）
```bash
npm i -g vercel
vercel
vercel --prod
```

### Netlify
直接拖拽文件夹到 https://app.netlify.com

## 🔧 自定义配置

### 1. 自定义域名
1. 在部署平台配置自定义域名
2. 在域名注册商处配置CNAME记录
3. 更新 `CNAME` 文件

### 2. Google Analytics
1. 获取GA测量ID（格式：G-XXXXXXXXXX）
2. 替换 `resource-navigation-enhanced.html` 中的GA ID
3. 重新部署

### 3. 添加新资源
编辑 `resource-navigation-enhanced.html`，在对应分类中添加：
```html
<li class="resource-item" data-id="唯一ID">
    <a href="资源URL" class="resource-link" target="_blank">
        <div>
            <div class="resource-title">资源名称</div>
            <div class="resource-desc">资源描述</div>
        </div>
        <i class="fas fa-external-link-alt external-icon"></i>
    </a>
    <div class="resource-actions">
        <button class="action-btn favorite-btn" data-id="唯一ID">
            <i class="far fa-heart"></i> 收藏
        </button>
        <button class="action-btn comment-btn" data-id="唯一ID">
            <i class="far fa-comment"></i> 评论
        </button>
    </div>
</li>
```

## 📁 项目结构

```
resource-navigation/
├── resource-navigation-enhanced.html  # 主页面（增强版）
├── resource-navigation-optimized.html # 优化版
├── resource-navigation.html          # 基础版
├── _config.yml                       # GitHub Pages配置
├── vercel.json                       # Vercel配置
├── netlify.toml                      # Netlify配置
├── CNAME                            # 自定义域名
├── .nojekyll                        # 禁用Jekyll
├── README.md                        # 项目文档
└── memory/                          # 项目记忆
    └── 2026-03-19.md
```

## 📊 数据分析

### Google Analytics事件跟踪
- `page_view` - 页面浏览
- `search` - 搜索事件
- `resource_click` - 资源点击
- `add_to_favorites` - 添加收藏
- `submit_comment` - 提交评论

### 本地统计
- 每日访问量
- 收藏总数
- 评论总数
- 资源点击统计

## 🛠️ 开发

### 本地运行
```bash
# 使用Python简单HTTP服务器
python -m http.server 8000

# 或使用Node.js
npx serve .
```

### 浏览器打开
```bash
start resource-navigation-enhanced.html
```

## 📄 许可证

MIT License

## 🤝 贡献

1. Fork项目
2. 创建功能分支
3. 提交更改
4. 发起Pull Request

## 📞 联系

如有问题或建议，请提交Issue或通过以下方式联系：
- GitHub Issues
- Email: contact@example.com