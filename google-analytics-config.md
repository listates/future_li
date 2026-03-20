# Google Analytics 配置详情

## 📊 账户信息
- **账户名称**: Resource Navigation
- **属性名称**: Resource Navigation Website
- **测量ID**: G-XXXXXXXXXX (获取后填写)
- **网站URL**: https://navi-resources.com
- **时区**: Asia/Shanghai
- **货币**: CNY

## 🔧 已配置的跟踪功能

### 1. 基本页面跟踪
```javascript
gtag('config', 'G-XXXXXXXXXX', {
  'page_title': document.title,
  'page_location': 'https://navi-resources.com',
  'send_page_view': true
});
```

### 2. 自定义事件跟踪
| 事件名称 | 触发条件 | 跟踪参数 |
|---------|---------|---------|
| `page_view` | 页面加载 | 页面标题、URL |
| `search` | 用户搜索 | 搜索关键词 |
| `resource_click` | 点击资源 | 资源标题、URL |
| `add_to_favorites` | 收藏资源 | 资源ID、标题 |
| `submit_comment` | 发布评论 | 评论长度 |

### 3. 增强型测量（建议启用）
- [x] 页面滚动跟踪
- [x] 出站点击跟踪
- [x] 站点搜索跟踪
- [x] 视频互动跟踪
- [x] 文件下载跟踪

## 🚀 快速设置清单

### 已完成：
- [x] GA代码集成到网页
- [x] 事件跟踪配置
- [x] 自定义维度预留
- [x] 数据分析仪表板

### 需要你完成：
- [ ] 创建Google Analytics账户
- [ ] 获取测量ID (G-XXXXXXXXXX)
- [ ] 替换代码中的测量ID
- [ ] 验证数据接收
- [ ] 设置转化目标

## 📈 建议的转化目标

### 目标1：资源点击
- **类型**: 事件
- **事件**: `resource_click`
- **价值**: 每次点击计1分

### 目标2：收藏添加
- **类型**: 事件
- **事件**: `add_to_favorites`
- **价值**: 每次收藏计2分

### 目标3：评论提交
- **类型**: 事件
- **事件**: `submit_comment`
- **价值**: 每次评论计3分

### 目标4：搜索使用
- **类型**: 事件
- **事件**: `search`
- **条件**: 搜索关键词长度 > 2
- **价值**: 每次搜索计1分

## 🔍 验证安装

### 方法1：GA调试器
1. 安装Google Tag Assistant Chrome扩展
2. 访问 https://navi-resources.com
3. 检查GA标签是否正常触发

### 方法2：实时报告
1. 登录Google Analytics
2. 进入"实时" → "概览"
3. 访问网站，查看实时用户数

### 方法3：控制台检查
按F12打开开发者工具，在控制台查看：
```
gtag 事件日志
```

## 🛠️ 故障排除

### 问题1：数据未显示
- 检查测量ID是否正确
- 确认网站已部署
- 等待24小时数据延迟

### 问题2：事件未跟踪
- 检查事件名称拼写
- 确认事件触发逻辑
- 验证网络请求

### 问题3：实时数据延迟
- GA实时数据有1-2分钟延迟
- 历史数据需要24小时处理

## 📞 支持资源

### 官方文档
- [GA4 入门指南](https://support.google.com/analytics/answer/10089681)
- [事件跟踪文档](https://developers.google.com/analytics/devguides/collection/ga4/events)
- [自定义维度](https://developers.google.com/analytics/devguides/collection/ga4/custom-dimensions)

### 学习资源
- [Google Analytics Academy](https://analytics.google.com/analytics/academy/)
- [GA4 新功能](https://support.google.com/analytics/answer/10089681)

---

**配置状态**: 等待测量ID  
**最后更新**: 2026-03-20  
**负责人**: 资源导航团队