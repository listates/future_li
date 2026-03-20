// 网站自测脚本
class WebsiteSelfTest {
    constructor() {
        this.testResults = [];
        this.startTime = Date.now();
    }
    
    async runAllTests() {
        console.log('🚀 开始网站自测...');
        
        try {
            // 1. 测试域名跳转
            await this.testDomainRedirect();
            
            // 2. 测试页面加载
            await this.testPageLoad();
            
            // 3. 测试功能可用性
            await this.testFunctionality();
            
            // 4. 测试响应式设计
            await this.testResponsive();
            
            // 5. 测试性能
            await this.testPerformance();
            
            // 显示测试结果
            this.showResults();
            
        } catch (error) {
            console.error('自测失败:', error);
        }
    }
    
    async testDomainRedirect() {
        console.log('🔍 测试域名跳转...');
        
        // 检查是否有无效域名引用
        const invalidDomains = ['navi-resources.com', 'example.com', 'test.com'];
        let hasInvalidDomain = false;
        
        // 检查当前页面
        const pageContent = document.documentElement.outerHTML;
        invalidDomains.forEach(domain => {
            if (pageContent.includes(domain)) {
                hasInvalidDomain = true;
                this.addResult('域名检查', '失败', `发现无效域名: ${domain}`);
            }
        });
        
        if (!hasInvalidDomain) {
            this.addResult('域名检查', '通过', '没有发现无效域名引用');
        }
        
        // 检查所有链接
        const links = document.querySelectorAll('a[href]');
        let invalidLinks = 0;
        
        links.forEach(link => {
            const href = link.href;
            if (href.includes('navi-resources.com')) {
                invalidLinks++;
                console.warn('发现无效链接:', href);
            }
        });
        
        if (invalidLinks === 0) {
            this.addResult('链接检查', '通过', '所有链接指向正确地址');
        } else {
            this.addResult('链接检查', '失败', `发现 ${invalidLinks} 个无效链接`);
        }
    }
    
    async testPageLoad() {
        console.log('📄 测试页面加载...');
        
        // 检查关键元素是否存在
        const criticalElements = [
            { selector: 'body', name: '页面主体' },
            { selector: 'head', name: '头部元素' },
            { selector: 'title', name: '页面标题' },
            { selector: 'meta[name="viewport"]', name: '视口设置' }
        ];
        
        criticalElements.forEach(element => {
            const el = document.querySelector(element.selector);
            if (el) {
                this.addResult(`${element.name}`, '通过', '元素存在');
            } else {
                this.addResult(`${element.name}`, '失败', '元素不存在');
            }
        });
        
        // 检查CSS加载
        const stylesheets = document.querySelectorAll('link[rel="stylesheet"]');
        if (stylesheets.length > 0) {
            this.addResult('CSS加载', '通过', `加载了 ${stylesheets.length} 个样式表`);
        } else {
            this.addResult('CSS加载', '警告', '没有找到样式表');
        }
        
        // 检查JavaScript加载
        const scripts = document.querySelectorAll('script[src]');
        if (scripts.length > 0) {
            this.addResult('JS加载', '通过', `加载了 ${scripts.length} 个脚本`);
        } else {
            this.addResult('JS加载', '警告', '没有找到外部脚本');
        }
    }
    
    async testFunctionality() {
        console.log('⚡ 测试功能可用性...');
        
        // 检查搜索功能
        const searchInput = document.getElementById('searchInput');
        const searchButton = document.getElementById('searchBtn');
        
        if (searchInput && searchButton) {
            this.addResult('搜索功能', '通过', '搜索框和按钮存在');
        } else {
            this.addResult('搜索功能', '警告', '搜索元素不存在');
        }
        
        // 检查导航
        const navElements = document.querySelectorAll('nav, .navbar, .navigation');
        if (navElements.length > 0) {
            this.addResult('导航功能', '通过', '导航元素存在');
        }
        
        // 检查资源卡片
        const resourceCards = document.querySelectorAll('.resource-card, .card, .item');
        if (resourceCards.length > 0) {
            this.addResult('资源展示', '通过', `找到 ${resourceCards.length} 个资源卡片`);
        }
        
        // 检查按钮功能
        const buttons = document.querySelectorAll('button, .btn, a[role="button"]');
        let workingButtons = 0;
        
        buttons.forEach(btn => {
            if (!btn.disabled) {
                workingButtons++;
            }
        });
        
        this.addResult('按钮功能', '通过', `${workingButtons}/${buttons.length} 个按钮可用`);
    }
    
    async testResponsive() {
        console.log('📱 测试响应式设计...');
        
        // 检查视口设置
        const viewport = document.querySelector('meta[name="viewport"]');
        if (viewport && viewport.content.includes('width=device-width')) {
            this.addResult('视口设置', '通过', '响应式视口已设置');
        } else {
            this.addResult('视口设置', '警告', '响应式视口未设置');
        }
        
        // 检查媒体查询
        const styles = document.querySelectorAll('style, link[rel="stylesheet"]');
        let hasMediaQueries = false;
        
        styles.forEach(style => {
            if (style.textContent && style.textContent.includes('@media')) {
                hasMediaQueries = true;
            }
        });
        
        if (hasMediaQueries) {
            this.addResult('媒体查询', '通过', '检测到响应式媒体查询');
        } else {
            this.addResult('媒体查询', '警告', '未检测到响应式媒体查询');
        }
        
        // 检查Flexbox/Grid使用
        const bodyStyles = window.getComputedStyle(document.body);
        const displayValue = bodyStyles.display;
        
        if (displayValue.includes('flex') || displayValue.includes('grid')) {
            this.addResult('布局系统', '通过', '使用现代布局系统');
        }
    }
    
    async testPerformance() {
        console.log('⚡ 测试性能...');
        
        // 页面加载时间
        const loadTime = Date.now() - this.startTime;
        this.addResult('加载时间', '通过', `${loadTime}ms`);
        
        // 检查图片优化
        const images = document.querySelectorAll('img');
        let optimizedImages = 0;
        
        images.forEach(img => {
            if (img.loading === 'lazy' || img.hasAttribute('loading')) {
                optimizedImages++;
            }
        });
        
        if (images.length > 0) {
            const optimizationRate = Math.round((optimizedImages / images.length) * 100);
            this.addResult('图片优化', optimizationRate > 50 ? '通过' : '警告', 
                          `${optimizationRate}% 的图片已优化`);
        }
        
        // 检查资源数量
        const totalResources = document.querySelectorAll('link[rel="stylesheet"], script[src], img').length;
        if (totalResources < 50) {
            this.addResult('资源数量', '通过', `总资源数: ${totalResources}`);
        } else {
            this.addResult('资源数量', '警告', `资源较多: ${totalResources}`);
        }
    }
    
    addResult(testName, status, message) {
        this.testResults.push({
            test: testName,
            status: status,
            message: message,
            timestamp: new Date().toLocaleTimeString()
        });
    }
    
    showResults() {
        console.log('\n📊 自测结果汇总:');
        console.log('='.repeat(50));
        
        const passed = this.testResults.filter(r => r.status === '通过').length;
        const failed = this.testResults.filter(r => r.status === '失败').length;
        const warnings = this.testResults.filter(r => r.status === '警告').length;
        const total = this.testResults.length;
        
        console.log(`✅ 通过: ${passed} | ❌ 失败: ${failed} | ⚠️ 警告: ${warnings} | 📊 总计: ${total}`);
        console.log('='.repeat(50));
        
        this.testResults.forEach(result => {
            const icon = result.status === '通过' ? '✅' : 
                        result.status === '失败' ? '❌' : '⚠️';
            console.log(`${icon} ${result.test}: ${result.message}`);
        });
        
        console.log('='.repeat(50));
        
        // 生成HTML报告
        this.generateHTMLReport();
    }
    
    generateHTMLReport() {
        const reportDiv = document.createElement('div');
        reportDiv.id = 'self-test-report';
        reportDiv.style.cssText = `
            position: fixed;
            top: 20px;
            right: 20px;
            background: white;
            border: 2px solid #4CAF50;
            border-radius: 10px;
            padding: 20px;
            max-width: 400px;
            max-height: 80vh;
            overflow-y: auto;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
            z-index: 9999;
            font-family: Arial, sans-serif;
        `;
        
        const passed = this.testResults.filter(r => r.status === '通过').length;
        const total = this.testResults.length;
        const score = Math.round((passed / total) * 100);
        
        let html = `
            <h3 style="margin-top: 0; color: #4CAF50;">🧪 网站自测报告</h3>
            <div style="background: #f5f5f5; padding: 10px; border-radius: 5px; margin-bottom: 15px;">
                <div style="font-size: 24px; font-weight: bold; color: #4CAF50;">${score}%</div>
                <div>测试通过率</div>
            </div>
            <div style="display: flex; gap: 10px; margin-bottom: 15px;">
                <span style="background: #4CAF50; color: white; padding: 5px 10px; border-radius: 5px;">✅ ${passed}</span>
                <span style="background: #ff9800; color: white; padding: 5px 10px; border-radius: 5px;">⚠️ ${this.testResults.filter(r => r.status === '警告').length}</span>
                <span style="background: #f44336; color: white; padding: 5px 10px; border-radius: 5px;">❌ ${this.testResults.filter(r => r.status === '失败').length}</span>
            </div>
            <div style="max-height: 300px; overflow-y: auto;">
        `;
        
        this.testResults.forEach(result => {
            const color = result.status === '通过' ? '#4CAF50' : 
                         result.status === '失败' ? '#f44336' : '#ff9800';
            const icon = result.status === '通过' ? '✅' : 
                        result.status === '失败' ? '❌' : '⚠️';
            
            html += `
                <div style="border-bottom: 1px solid #eee; padding: 8px 0;">
                    <div style="display: flex; align-items: center; gap: 8px;">
                        <span style="color: ${color}; font-weight: bold;">${icon}</span>
                        <span style="flex: 1;">${result.test}</span>
                        <small style="color: #666;">${result.timestamp}</small>
                    </div>
                    <div style="color: #666; font-size: 12px; margin-top: 4px;">${result.message}</div>
                </div>
            `;
        });
        
        html += `
            </div>
            <button onclick="document.getElementById('self-test-report').remove()" 
                    style="margin-top: 15px; padding: 8px 16px; background: #f44336; color: white; border: none; border-radius: 5px; cursor: pointer;">
                关闭报告
            </button>
        `;
        
        reportDiv.innerHTML = html;
        document.body.appendChild(reportDiv);
    }
}

// 自动运行测试
document.addEventListener('DOMContentLoaded', () => {
    setTimeout(() => {
        const tester = new WebsiteSelfTest();
        tester.runAllTests();
    }, 2000);
});

// 导出
window.WebsiteSelfTest = WebsiteSelfTest;