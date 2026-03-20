// 鼠标动画效果
class MouseAnimations {
    constructor() {
        this.follower = null;
        this.trails = [];
        this.maxTrails = 20;
        this.lastX = 0;
        this.lastY = 0;
        this.velocity = 0;
        this.isInitialized = false;
        
        this.init();
    }
    
    init() {
        // 创建鼠标跟随元素
        this.createFollower();
        
        // 绑定事件
        document.addEventListener('mousemove', (e) => this.onMouseMove(e));
        document.addEventListener('mouseenter', () => this.showFollower());
        document.addEventListener('mouseleave', () => this.hideFollower());
        
        // 初始化粒子
        this.createParticles();
        
        this.isInitialized = true;
        console.log('鼠标动画已初始化');
    }
    
    createFollower() {
        this.follower = document.createElement('div');
        this.follower.className = 'mouse-follower';
        document.body.appendChild(this.follower);
    }
    
    createParticles() {
        const container = document.createElement('div');
        container.className = 'particles-container';
        document.body.appendChild(container);
        
        // 创建50个粒子
        for (let i = 0; i < 50; i++) {
            const particle = document.createElement('div');
            particle.className = 'particle';
            
            // 随机大小和位置
            const size = Math.random() * 20 + 5;
            particle.style.width = `${size}px`;
            particle.style.height = `${size}px`;
            particle.style.left = `${Math.random() * 100}vw`;
            particle.style.top = `${Math.random() * 100}vh`;
            
            // 随机动画延迟
            particle.style.animationDelay = `${Math.random() * 20}s`;
            
            container.appendChild(particle);
        }
    }
    
    onMouseMove(e) {
        const x = e.clientX;
        const y = e.clientY;
        
        // 计算速度
        const deltaX = x - this.lastX;
        const deltaY = y - this.lastY;
        this.velocity = Math.sqrt(deltaX * deltaX + deltaY * deltaY);
        
        // 更新鼠标跟随
        this.updateFollower(x, y);
        
        // 创建鼠标轨迹
        this.createTrail(x, y);
        
        // 更新卡片悬停效果
        this.updateCardHover(x, y);
        
        this.lastX = x;
        this.lastY = y;
    }
    
    updateFollower(x, y) {
        if (!this.follower) return;
        
        // 根据速度调整大小
        const size = Math.min(40 + this.velocity * 0.5, 80);
        this.follower.style.width = `${size}px`;
        this.follower.style.height = `${size}px`;
        
        // 平滑移动
        const followerX = parseFloat(this.follower.style.left || 0);
        const followerY = parseFloat(this.follower.style.top || 0);
        
        const smoothX = followerX + (x - followerX - size/2) * 0.2;
        const smoothY = followerY + (y - followerY - size/2) * 0.2;
        
        this.follower.style.left = `${smoothX}px`;
        this.follower.style.top = `${smoothY}px`;
        
        // 根据速度调整透明度
        const opacity = Math.min(0.3 + this.velocity * 0.002, 0.8);
        this.follower.style.opacity = opacity;
    }
    
    createTrail(x, y) {
        // 限制轨迹数量
        if (this.trails.length >= this.maxTrails) {
            const oldTrail = this.trails.shift();
            if (oldTrail && oldTrail.parentNode) {
                oldTrail.parentNode.removeChild(oldTrail);
            }
        }
        
        // 创建新轨迹
        const trail = document.createElement('div');
        trail.className = 'mouse-trail';
        
        // 根据速度调整大小
        const size = Math.min(8 + this.velocity * 0.05, 15);
        trail.style.width = `${size}px`;
        trail.style.height = `${size}px`;
        
        trail.style.left = `${x - size/2}px`;
        trail.style.top = `${y - size/2}px`;
        
        // 根据速度调整颜色
        const hue = 240 + Math.min(this.velocity * 0.5, 120);
        trail.style.background = `linear-gradient(45deg, hsl(${hue}, 100%, 65%), hsl(${hue + 60}, 100%, 65%))`;
        
        document.body.appendChild(trail);
        this.trails.push(trail);
        
        // 动画结束后移除
        setTimeout(() => {
            if (trail.parentNode) {
                trail.parentNode.removeChild(trail);
            }
            this.trails = this.trails.filter(t => t !== trail);
        }, 1000);
    }
    
    updateCardHover(x, y) {
        const cards = document.querySelectorAll('.resource-card');
        
        cards.forEach(card => {
            const rect = card.getBoundingClientRect();
            const cardX = rect.left + rect.width / 2;
            const cardY = rect.top + rect.height / 2;
            
            const distance = Math.sqrt(
                Math.pow(x - cardX, 2) + Math.pow(y - cardY, 2)
            );
            
            // 如果鼠标在卡片附近，增强悬停效果
            if (distance < 200) {
                const intensity = 1 - (distance / 200);
                
                // 添加发光效果
                card.style.boxShadow = `
                    0 ${4 + intensity * 16}px ${6 + intensity * 34}px 
                    rgba(67, 97, 238, ${0.1 + intensity * 0.3})
                `;
                
                // 轻微旋转
                card.style.transform = `
                    translateY(${-5 - intensity * 5}px) 
                    scale(${1 + intensity * 0.03})
                    rotate(${intensity * 2}deg)
                `;
            } else {
                // 恢复默认状态
                card.style.boxShadow = '0 4px 6px rgba(0, 0, 0, 0.1)';
                card.style.transform = 'translateY(0) scale(1) rotate(0deg)';
            }
        });
    }
    
    showFollower() {
        if (this.follower) {
            this.follower.style.opacity = '0.3';
        }
    }
    
    hideFollower() {
        if (this.follower) {
            this.follower.style.opacity = '0';
        }
    }
    
    // 页面加载动画
    showPageLoader() {
        const loader = document.createElement('div');
        loader.className = 'page-loader';
        loader.innerHTML = `
            <div class="loader-content">
                <div class="loader-spinner"></div>
                <h2 class="animated-text">资源导航</h2>
                <p>加载中...</p>
            </div>
        `;
        document.body.appendChild(loader);
        
        // 2秒后移除
        setTimeout(() => {
            if (loader.parentNode) {
                loader.parentNode.removeChild(loader);
            }
        }, 2000);
    }
    
    // 添加浮动动画到元素
    addFloatAnimation(element) {
        element.classList.add('floating-element');
        
        // 随机动画延迟
        const delay = Math.random() * 2;
        element.style.animationDelay = `${delay}s`;
    }
    
    // 移除浮动动画
    removeFloatAnimation(element) {
        element.classList.remove('floating-element');
    }
    
    // 销毁清理
    destroy() {
        document.removeEventListener('mousemove', this.onMouseMove);
        document.removeEventListener('mouseenter', this.showFollower);
        document.removeEventListener('mouseleave', this.hideFollower);
        
        if (this.follower && this.follower.parentNode) {
            this.follower.parentNode.removeChild(this.follower);
        }
        
        const particlesContainer = document.querySelector('.particles-container');
        if (particlesContainer && particlesContainer.parentNode) {
            particlesContainer.parentNode.removeChild(particlesContainer);
        }
        
        this.trails.forEach(trail => {
            if (trail && trail.parentNode) {
                trail.parentNode.removeChild(trail);
            }
        });
        
        this.trails = [];
        this.isInitialized = false;
    }
}

// 全局实例
let mouseAnimations = null;

// 初始化函数
function initMouseAnimations() {
    if (!mouseAnimations) {
        mouseAnimations = new MouseAnimations();
        
        // 显示页面加载动画
        mouseAnimations.showPageLoader();
        
        // 为所有卡片添加浮动动画
        setTimeout(() => {
            document.querySelectorAll('.resource-card').forEach(card => {
                mouseAnimations.addFloatAnimation(card);
            });
        }, 2100);
    }
    return mouseAnimations;
}

// 销毁函数
function destroyMouseAnimations() {
    if (mouseAnimations) {
        mouseAnimations.destroy();
        mouseAnimations = null;
    }
}

// 页面加载时初始化
document.addEventListener('DOMContentLoaded', () => {
    // 延迟初始化，避免影响页面加载
    setTimeout(initMouseAnimations, 500);
});

// 导出
export { MouseAnimations, initMouseAnimations, destroyMouseAnimations };