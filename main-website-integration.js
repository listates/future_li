// 主网站集成 - 将所有功能整合到一起
class MainWebsiteIntegration {
    constructor() {
        this.resourceSearch = null;
        this.mouseAnimations = null;
        this.userSystem = null;
        this.isInitialized = false;
        
        this.init();
    }
    
    async init() {
        try {
            console.log('开始初始化主网站...');
            
            // 1. 加载资源数据库
            await this.loadResourceDatabase();
            
            // 2. 初始化鼠标动画
            this.initMouseAnimations();
            
            // 3. 初始化用户系统
            await this.initUserSystem();
            
            // 4. 设置事件监听
            this.setupEventListeners();
            
            // 5. 渲染初始内容
            this.renderInitialContent();
            
            this.isInitialized = true;
            console.log('主网站初始化完成');
            
        } catch (error) {
            console.error('网站初始化失败:', error);
        }
    }
    
    async loadResourceDatabase() {
        // 加载资源搜索功能
        this.resourceSearch = resourceSearch;
        console.log('资源数据库已加载，总数:', this.resourceSearch.getAllResources().length);
    }
    
    initMouseAnimations() {
        this.mouseAnimations = initMouseAnimations();
        console.log('鼠标动画已初始化');
    }
    
    async initUserSystem() {
        // 延迟加载用户系统，避免影响页面加载
        setTimeout(async () => {
            try {
                // 这里可以加载用户系统
                console.log('用户系统准备就绪');
            } catch (error) {
                console.warn('用户系统初始化失败:', error);
            }
        }, 3000);
    }
    
    setupEventListeners() {
        // 搜索框事件
        const searchInput = document.getElementById('searchInput');
        if (searchInput) {
            searchInput.addEventListener('input', (e) => this.onSearchInput(e));
            searchInput.addEventListener('keypress', (e) => {
                if (e.key === 'Enter') this.performSearch();
            });
        }
        
        // 搜索按钮事件
        const searchBtn = document.getElementById('searchBtn');
        if (searchBtn) {
            searchBtn.addEventListener('click', () => this.performSearch());
        }
        
        // 分类过滤事件
        document.querySelectorAll('.category-filter').forEach(btn => {
            btn.addEventListener('click', (e) => this.filterByCategory(e.target.dataset.category));
        });
        
        // 登录按钮事件
        const loginBtn = document.getElementById('loginBtn');
        if (loginBtn) {
            loginBtn.addEventListener('click', () => this.showLoginModal());
        }
        
        // 窗口调整事件
        window.addEventListener('resize', () => this.onWindowResize());
        
        // 滚动事件
        window.addEventListener('scroll', () => this.onWindowScroll());
    }
    
    renderInitialContent() {
        // 渲染热门资源
        this.renderPopularResources();
        
        // 渲染分类
        this.renderCategories();
        
        // 渲染统计信息
        this.renderStats();
        
        // 添加动态效果到元素
        this.addDynamicEffects();
    }
    
    renderPopularResources() {
        const container = document.getElementById('popularResources');
        if (!container) return;
        
        const popularResources = this.resourceSearch.getPopularResources(12);
        
        container.innerHTML = popularResources.map(resource => `
            <div class="resource-card" data-resource-id="${resource.id}">
                <div class="resource-header">
                    <h3 class="resource-title">${resource.name}</h3>
                    <span class="resource-category">${resource.category}</span>
                </div>
                <div class="resource-body">
                    <p class="resource-description">${resource.description}</p>
                    <div class="resource-tags">
                        ${resource.tags.map(tag => `<span class="resource-tag">${tag}</span>`).join('')}
                    </div>
                    <div class="resource-meta">
                        <span class="resource-rating">⭐ ${resource.rating.toFixed(1)}</span>
                        <span class="resource-visits">👁️ ${this.formatNumber(resource.visits)}</span>
                    </div>
                </div>
                <div class="resource-actions">
                    <a href="${resource.url}" target="_blank" class="btn-primary">访问网站</a>
                    <button class="favorite-btn" onclick="toggleFavorite('${resource.id}')">🤍 收藏</button>
                </div>
            </div>
        `).join('');
    }
    
    renderCategories() {
        const container = document.getElementById('categoriesContainer');
        if (!container) return;
        
        const categories = this.resourceSearch.getAllCategories();
        
        container.innerHTML = categories.map(category => `
            <div class="category-card floating-element">
                <h3>${this.getCategoryDisplayName(category)}</h3>
                <p>${this.resourceSearch.getResourcesByCategory(category).length} 个资源</p>
                <button class="category-filter" data-category="${category}">
                    查看全部
                </button>
            </div>
        `).join('');
    }
    
    renderStats() {
        const container = document.getElementById('statsContainer');
        if (!container) return;
        
        const stats = this.resourceSearch.getStats();
        
        container.innerHTML = `
            <div class="stat-card">
                <h3>📊 资源统计</h3>
                <div class="stat-item">
                    <span class="stat-label">总资源数:</span>
                    <span class="stat-value">${stats.totalResources}</span>
                </div>
                <div class="stat-item">
                    <span class="stat-label">总访问量:</span>
                    <span class="stat-value">${this.formatNumber(stats.totalVisits)}</span>
                </div>
                <div class="stat-item">
                    <span class="stat-label">平均评分:</span>
                    <span class="stat-value">${stats.averageRating.toFixed(2)}</span>
                </div>
            </div>
        `;
    }
    
    addDynamicEffects() {
        // 为所有卡片添加浮动效果
        setTimeout(() => {
            document.querySelectorAll('.resource-card, .category-card').forEach(card => {
                if (this.mouseAnimations) {
                    this.mouseAnimations.addFloatAnimation(card);
                }
            });
        }, 1000);
    }
    
    onSearchInput(e) {
        const query = e.target.value.trim();
        
        if (query.length >= 2) {
            // 实时搜索建议
            this.showSearchSuggestions(query);
        } else {
            this.hideSearchSuggestions();
        }
    }
    
    performSearch() {
        const query = document.getElementById('searchInput').value.trim();
        
        if (!query) {
            this.showNotification('请输入搜索关键词', 'warning');
            return;
        }
        
        const results = this.resourceSearch.search(query, { limit: 50 });
        
        this.renderSearchResults(results, query);
    }
    
    showSearchSuggestions(query) {
        const suggestions = this.resourceSearch.search(query, { limit: 5 });
        
        const suggestionsContainer = document.getElementById('searchSuggestions');
        if (!suggestionsContainer) return;
        
        if (suggestions.length > 0) {
            suggestionsContainer.innerHTML = suggestions.map(resource => `
                <div class="search-suggestion" onclick="selectSuggestion('${resource.name}')">
                    <strong>${resource.name}</strong>
                    <span>${resource.category} • ${resource.description.substring(0, 50)}...</span>
                </div>
            `).join('');
            suggestionsContainer.style.display = 'block';
        } else {
            suggestionsContainer.style.display = 'none';
        }
    }
    
    hideSearchSuggestions() {
        const container = document.getElementById('searchSuggestions');
        if (container) {
            container.style.display = 'none';
        }
    }
    
    renderSearchResults(results, query) {
        const container = document.getElementById('searchResults');
        if (!container) return;
        
        if (results.length === 0) {
            container.innerHTML = `
                <div class="no-results">
                    <h3>😔 没有找到相关资源</h3>
                    <p>尝试使用其他关键词搜索，或者浏览我们的分类。</p>
                </div>
            `;
            return;
        }
        
        container.innerHTML = `
            <h3 class="search-results-title">
                搜索 "${query}" 找到 ${results.length} 个结果
            </h3>
            <div class="search-results-grid">
                ${results.map(resource => `
                    <div class="resource-card">
                        <div class="resource-header">
                            <h3 class="resource-title">${resource.name}</h3>
                            <span class="resource-category">${resource.category}</span>
                        </div>
                        <div class="resource-body">
                            <p class="resource-description">${resource.description}</p>
                            <div class="resource-tags">
                                ${resource.tags.map(tag => `<span class="resource-tag">${tag}</span>`).join('')}
                            </div>
                            <div class="resource-meta">
                                <span class="resource-rating">⭐ ${resource.rating.toFixed(1)}</span>
                                <span class="resource-visits">👁️ ${this.formatNumber(resource.visits)}</span>
                            </div>
                        </div>
                        <div class="resource-actions">
                            <a href="${resource.url}" target="_blank" class="btn-primary">访问网站</a>
                            <button class="favorite-btn">🤍 收藏</button>
                        </div>
                    </div>
                `).join('')}
            </div>
        `;
        
        // 滚动到搜索结果
        container.scrollIntoView({ behavior: 'smooth' });
    }
    
    filterByCategory(category) {
        const resources = this.resourceSearch.getResourcesByCategory(category, 30);
        this.renderCategoryResults(resources, category);
    }
    
    renderCategoryResults(resources, category) {
        const container = document.getElementById('categoryResults');
        if (!container) return;
        
        container.innerHTML = `
            <h3 class="category-results-title">
                ${this.getCategoryDisplayName(category)} - ${resources.length} 个资源
            </h3>
            <div class="category-results-grid">
                ${resources.map(resource => `
                    <div class="resource-card">
                        <div class="resource-header">
                            <h3 class="resource-title">${resource.name}</h3>
                        </div>
                        <div class="resource-body">
                            <p class="resource-description">${resource.description}</p>
                            <div class="resource-tags">
                                ${resource.tags.map(tag => `<span class="resource-tag">${tag}</span>`).join('')}
                            </div>
                            <div class="resource-meta">
                                <span class="resource-rating">⭐ ${resource.rating.toFixed(1)}</span>
                            </div>
                        </div>
                        <div class="resource-actions">
                            <a href="${resource.url}" target="_blank" class="btn-primary">访问网站</a>
                        </div>
                    </div>
                `).join('')}
            </div>
        `;
        
        // 滚动到分类结果
        container.scrollIntoView({ behavior: 'smooth' });
    }
    
    showLoginModal() {
        // 这里可以调用用户系统的登录模态框
        console.log('显示登录模态框');
        // window.frontendIntegration.showLoginModal();
    }
    
    onWindowResize() {
        // 响应式调整
        console.log('窗口大小改变');
    }
    
    onWindowScroll() {
        // 滚动效果
        const scrollTop = window.pageYOffset;
        
        // 导航栏透明度
        const navbar = document.querySelector('.navbar');
        if (navbar) {
            if (scrollTop > 100) {
                navbar.style.background = 'rgba(255, 255, 255, 0.98)';
                navbar.style.boxShadow = '0 2px 20px rgba(0, 0, 0, 0.1)';
            } else {
                navbar.style.background = 'rgba(255, 255, 255, 0.95)';
                navbar.style.boxShadow = '0 2px 20px rgba(0, 0, 0, 0.1)';
            }
        }
        
        // 显示回到顶部按钮
        const backToTop = document.getElementById('backToTop');
        if (backToTop) {
            if (scrollTop > 500) {
                backToTop.style.display = 'block';
            } else {
                backToTop.style.display = 'none';
            }
        }
    }
    
    showNotification(message, type = 'info') {
        // 这里可以调用通知系统
        console.log(`[${type}] ${message}`);
    }
    
    formatNumber(num) {
        if (num >= 1000000) {
            return (num / 1000000).toFixed(1) + 'M';
        } else if (num >= 1000) {
            return (num / 1000).toFixed(1) + 'K';
        }
        return num.toString();
    }
    
    getCategoryDisplayName(category) {
        const names = {
            'development': '开发工具',
            'learning': '学习资源',
            'design': '设计资源',
            'business': '商业工具',
            'creative': '创意工具',
            'productivity': '效率工具'
        };
        return names[category] || category;
    }
    
    // 销毁清理
    destroy() {
        if (this.mouseAnimations) {
            destroyMouseAnimations();
        }
        
        // 移除事件监听
        // ...
        
        this.isInitialized = false;
    }
}

// 全局实例
let mainWebsite = null;

// 初始化函数
function initMainWebsite() {
    if (!mainWebsite) {
        mainWebsite = new MainWebsiteIntegration();
    }
    return mainWebsite;
}

// 全局辅助函数
window.selectSuggestion = function(query) {
    const searchInput = document.getElementById('searchInput');
    if (searchInput) {
        searchInput.value = query;
        searchInput.focus();
    }
    
    const suggestionsContainer = document.getElementById('searchSuggestions');
    if (suggestionsContainer) {
        suggestionsContainer.style.display = 'none';
    }
    
    if (mainWebsite) {
        mainWebsite.performSearch();
    }
};

window.toggleFavorite = function(resourceId) {
    console.log('切换收藏:', resourceId);
    // 这里可以调用收藏功能
};

window.scrollToTop = function() {
    window.scrollTo({
        top: 0,
        behavior: 'smooth'
    });
};

// 页面加载时初始化
document.addEventListener('DOMContentLoaded', () => {
    // 延迟初始化，确保所有资源加载完成
    setTimeout(() => {
        initMainWebsite();
    }, 1000);
});

// 导出
export { MainWebsiteIntegration, initMainWebsite };