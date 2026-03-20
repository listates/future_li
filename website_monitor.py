#!/usr/bin/env python3
"""
网站上线监控系统
持续监控 navi-resources.com 上线状态
"""

import time
import subprocess
import json
from datetime import datetime
import os

class WebsiteMonitor:
    def __init__(self):
        self.domain = "navi-resources.com"
        self.github_url = "https://listates.github.io/future_li/"
        self.ga_id = "G-61KYKBJ4MX"
        self.status_log = []
        self.start_time = datetime.now()
        
    def check_dns(self):
        """检查DNS解析状态"""
        try:
            result = subprocess.run(
                ["nslookup", self.domain, "8.8.8.8"],
                capture_output=True,
                text=True,
                timeout=10
            )
            if "185.199" in result.stdout:
                return True, "DNS解析正常（指向GitHub）"
            else:
                return False, f"DNS解析异常: {result.stdout[:100]}"
        except Exception as e:
            return False, f"DNS检查失败: {str(e)}"
    
    def check_http(self, use_https=True):
        """检查HTTP/HTTPS访问"""
        protocol = "https" if use_https else "http"
        url = f"{protocol}://{self.domain}"
        
        try:
            result = subprocess.run(
                ["curl", "-I", "-s", "-m", "10", url],
                capture_output=True,
                text=True,
                timeout=15
            )
            
            if "200 OK" in result.stdout:
                return True, f"{protocol.upper()} 200 OK"
            elif "301" in result.stdout or "302" in result.stdout:
                return True, f"{protocol.upper()} 重定向正常"
            elif "404" in result.stdout:
                return False, f"{protocol.upper()} 404 页面未找到"
            elif "timeout" in result.stdout.lower():
                return False, f"{protocol.upper()} 连接超时"
            else:
                return False, f"{protocol.upper()} 响应异常: {result.stdout[:50]}"
        except Exception as e:
            return False, f"{protocol.upper()} 检查失败: {str(e)}"
    
    def check_github_pages(self):
        """检查GitHub Pages状态"""
        try:
            result = subprocess.run(
                ["curl", "-s", "-m", "10", self.github_url],
                capture_output=True,
                text=True,
                timeout=15
            )
            if "资源导航" in result.stdout or "Resource Navigation" in result.stdout:
                return True, "GitHub Pages内容正常"
            elif "404" in result.stdout:
                return False, "GitHub Pages 404错误"
            else:
                return False, "GitHub Pages内容异常"
        except Exception as e:
            return False, f"GitHub Pages检查失败: {str(e)}"
    
    def check_ssl_certificate(self):
        """检查SSL证书状态"""
        try:
            result = subprocess.run(
                ["curl", "-I", "-s", "-m", "10", f"https://{self.domain}"],
                capture_output=True,
                text=True,
                timeout=15
            )
            if "Strict-Transport-Security" in result.stdout:
                return True, "SSL证书正常（HSTS启用）"
            else:
                return False, "SSL证书未检测到HSTS"
        except Exception as e:
            return False, f"SSL检查失败: {str(e)}"
    
    def run_monitoring_cycle(self):
        """执行一次完整的监控周期"""
        print(f"\n{'='*60}")
        print(f"监控时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print(f"监控域名: {self.domain}")
        print(f"{'='*60}")
        
        checks = [
            ("DNS解析", self.check_dns),
            ("HTTPS访问", lambda: self.check_http(use_https=True)),
            ("HTTP访问", lambda: self.check_http(use_https=False)),
            ("GitHub Pages", self.check_github_pages),
            ("SSL证书", self.check_ssl_certificate),
        ]
        
        status_summary = {
            "timestamp": datetime.now().isoformat(),
            "domain": self.domain,
            "checks": {}
        }
        
        all_passed = True
        for check_name, check_func in checks:
            try:
                passed, message = check_func()
                status = "✅" if passed else "❌"
                print(f"{status} {check_name}: {message}")
                
                status_summary["checks"][check_name] = {
                    "passed": passed,
                    "message": message,
                    "timestamp": datetime.now().isoformat()
                }
                
                if not passed:
                    all_passed = False
                    
            except Exception as e:
                print(f"⚠️ {check_name}: 检查异常 - {str(e)}")
                status_summary["checks"][check_name] = {
                    "passed": False,
                    "message": f"检查异常: {str(e)}",
                    "timestamp": datetime.now().isoformat()
                }
                all_passed = False
        
        # 保存状态日志
        self.status_log.append(status_summary)
        self.save_status_log()
        
        return all_passed, status_summary
    
    def save_status_log(self):
        """保存状态日志到文件"""
        log_file = "website_status_log.json"
        try:
            with open(log_file, 'w', encoding='utf-8') as f:
                json.dump({
                    "monitor_start_time": self.start_time.isoformat(),
                    "current_time": datetime.now().isoformat(),
                    "total_checks": len(self.status_log),
                    "status_history": self.status_log
                }, f, indent=2, ensure_ascii=False)
        except Exception as e:
            print(f"保存日志失败: {str(e)}")
    
    def generate_report(self):
        """生成监控报告"""
        if not self.status_log:
            return "暂无监控数据"
        
        latest = self.status_log[-1]
        total_checks = len(self.status_log)
        
        report = f"""
{'='*60}
网站监控报告
{'='*60}
监控开始时间: {self.start_time.strftime('%Y-%m-%d %H:%M:%S')}
最新检查时间: {datetime.fromisoformat(latest['timestamp']).strftime('%Y-%m-%d %H:%M:%S')}
总检查次数: {total_checks}
监控域名: {self.domain}

最新状态:
"""
        
        for check_name, check_data in latest["checks"].items():
            status = "✅ 通过" if check_data["passed"] else "❌ 失败"
            report += f"- {check_name}: {status} - {check_data['message']}\n"
        
        # 计算成功率
        successful_checks = sum(1 for log in self.status_log 
                              if all(check["passed"] for check in log["checks"].values()))
        success_rate = (successful_checks / total_checks * 100) if total_checks > 0 else 0
        
        report += f"\n总体成功率: {success_rate:.1f}% ({successful_checks}/{total_checks})\n"
        
        if success_rate == 100:
            report += "🎉 网站运行状态完美！\n"
        elif success_rate >= 80:
            report += "⚠️ 网站运行基本正常，有小问题需要关注\n"
        else:
            report += "🚨 网站存在严重问题，需要立即处理\n"
        
        report += "="*60
        return report
    
    def continuous_monitoring(self, interval_minutes=5, max_cycles=None):
        """持续监控"""
        print("🚀 启动网站持续监控系统")
        print(f"监控间隔: {interval_minutes}分钟")
        print(f"监控域名: {self.domain}")
        print(f"开始时间: {self.start_time.strftime('%Y-%m-%d %H:%M:%S')}")
        print("="*60)
        
        cycle_count = 0
        try:
            while True:
                if max_cycles and cycle_count >= max_cycles:
                    print(f"\n达到最大监控次数: {max_cycles}")
                    break
                
                cycle_count += 1
                print(f"\n第 {cycle_count} 次监控循环")
                
                all_passed, _ = self.run_monitoring_cycle()
                
                if all_passed:
                    print(f"\n🎉 所有检查通过！网站已正常上线")
                    print(f"访问地址: https://{self.domain}")
                    print(f"备用地址: {self.github_url}")
                    break
                
                print(f"\n⏳ 等待 {interval_minutes} 分钟后再次检查...")
                time.sleep(interval_minutes * 60)
                
        except KeyboardInterrupt:
            print("\n\n👋 监控被用户中断")
        finally:
            print("\n" + "="*60)
            print("监控报告:")
            print(self.generate_report())
            print("="*60)

if __name__ == "__main__":
    monitor = WebsiteMonitor()
    
    # 立即执行一次检查
    print("执行首次检查...")
    all_passed, _ = monitor.run_monitoring_cycle()
    
    if all_passed:
        print("\n🎉 网站已正常上线！")
        print(f"主域名: https://{monitor.domain}")
        print(f"备用地址: {monitor.github_url}")
        print(f"GA跟踪ID: {monitor.ga_id}")
    else:
        print("\n⚠️ 网站尚未完全上线，开始持续监控...")
        # 持续监控，每5分钟检查一次，最多检查12次（1小时）
        monitor.continuous_monitoring(interval_minutes=5, max_cycles=12)