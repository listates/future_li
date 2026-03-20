#!/usr/bin/env python3
"""
自动化网站优化系统
基于监控数据自动优化网站配置和用户体验
"""

import json
import time
import subprocess
from datetime import datetime, timedelta
import os

class AutoOptimizer:
    def __init__(self):
        self.status_log_file = "website_status_log.json"
        self.optimization_log = []
        self.start_time = datetime.now()
        
    def load_status_data(self):
        """加载监控数据"""
        try:
            with open(self.status_log_file, 'r', encoding='utf-8') as f:
                return json.load(f)
        except FileNotFoundError:
            return None
        except Exception as e:
            print(f"加载监控数据失败: {str(e)}")
            return None
    
    def analyze_status_trends(self, data):
        """分析状态趋势"""
        if not data or "status_history" not in data:
            return {"error": "无有效数据"}
        
        history = data["status_history"]
        if len(history) < 2:
            return {"info": "数据不足，需要更多监控数据"}
        
        # 分析趋势
        trends = {
            "dns_success_rate": 0,
            "https_success_rate": 0,
            "overall_success_rate": 0,
            "issues": [],
            "improvements": []
        }
        
        # 计算成功率
        total_checks = len(history)
        dns_success = 0
        https_success = 0
        overall_success = 0
        
        for check in history:
            checks = check.get("checks", {})
            
            # DNS成功率
            dns_check = checks.get("DNS解析", {})
            if dns_check.get("passed", False):
                dns_success += 1
            
            # HTTPS成功率
            https_check = checks.get("HTTPS访问", {})
            if https_check.get("passed", False):
                https_success += 1
            
            # 整体成功率
            all_passed = all(c.get("passed", False) for c in checks.values())
            if all_passed:
                overall_success += 1
        
        trends["dns_success_rate"] = (dns_success / total_checks * 100) if total_checks > 0 else 0
        trends["https_success_rate"] = (https_success / total_checks * 100) if total_checks > 0 else 0
        trends["overall_success_rate"] = (overall_success / total_checks * 100) if total_checks > 0 else 0
        
        # 识别问题
        latest_check = history[-1]
        latest_checks = latest_check.get("checks", {})
        
        for check_name, check_data in latest_checks.items():
            if not check_data.get("passed", False):
                trends["issues"].append({
                    "check": check_name,
                    "message": check_data.get("message", "未知错误"),
                    "severity": self.assess_severity(check_name)
                })
        
        # 生成改进建议
        trends["improvements"] = self.generate_improvements(trends)
        
        return trends
    
    def assess_severity(self, check_name):
        """评估问题严重性"""
        critical_checks = ["DNS解析", "HTTPS访问"]
        if check_name in critical_checks:
            return "critical"
        elif check_name == "SSL证书":
            return "high"
        else:
            return "medium"
    
    def generate_improvements(self, trends):
        """生成改进建议"""
        improvements = []
        
        # DNS问题建议
        if trends["dns_success_rate"] < 90:
            improvements.append({
                "area": "DNS配置",
                "action": "检查DNS记录配置，确保CNAME指向正确",
                "priority": "high",
                "command": "nslookup navi-resources.com 8.8.8.8"
            })
        
        # HTTPS问题建议
        if trends["https_success_rate"] < 90:
            improvements.append({
                "area": "HTTPS/SSL",
                "action": "检查GitHub Pages SSL证书配置",
                "priority": "high",
                "command": "curl -I https://navi-resources.com"
            })
        
        # 整体性能建议
        if trends["overall_success_rate"] < 80:
            improvements.append({
                "area": "整体配置",
                "action": "重新配置GitHub Pages自定义域名",
                "priority": "critical",
                "steps": [
                    "1. 删除旧的自定义域名配置",
                    "2. 等待5分钟",
                    "3. 重新添加自定义域名",
                    "4. 启用强制HTTPS"
                ]
            })
        
        # 预防性建议
        improvements.append({
            "area": "监控",
            "action": "设置定期健康检查",
            "priority": "medium",
            "schedule": "每30分钟检查一次"
        })
        
        improvements.append({
            "area": "备份",
            "action": "定期备份网站配置",
            "priority": "medium",
            "frequency": "每天一次"
        })
        
        return improvements
    
    def execute_optimization(self, improvement):
        """执行优化操作"""
        action = improvement.get("action", "")
        area = improvement.get("area", "")
        priority = improvement.get("priority", "medium")
        
        print(f"\n🔧 执行优化: {area} - {action}")
        print(f"优先级: {priority}")
        
        result = {
            "timestamp": datetime.now().isoformat(),
            "area": area,
            "action": action,
            "priority": priority,
            "success": False,
            "output": ""
        }
        
        try:
            # 根据不同的优化类型执行相应操作
            if area == "DNS配置":
                # 检查DNS
                cmd = improvement.get("command", "nslookup navi-resources.com")
                output = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=30)
                result["output"] = output.stdout[:500]
                result["success"] = "185.199" in output.stdout
            
            elif area == "HTTPS/SSL":
                # 检查HTTPS
                cmd = improvement.get("command", "curl -I https://navi-resources.com")
                output = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=30)
                result["output"] = output.stdout[:500]
                result["success"] = "200" in output.stdout or "301" in output.stdout
            
            elif area == "整体配置":
                # 提供配置步骤
                steps = improvement.get("steps", [])
                result["output"] = "\n".join(steps)
                result["success"] = True  # 需要人工操作
            
            else:
                result["output"] = "无需自动操作，请参考建议手动优化"
                result["success"] = True
            
        except Exception as e:
            result["output"] = f"执行失败: {str(e)}"
            result["success"] = False
        
        # 记录优化结果
        self.optimization_log.append(result)
        self.save_optimization_log()
        
        return result
    
    def save_optimization_log(self):
        """保存优化日志"""
        log_file = "optimization_log.json"
        try:
            with open(log_file, 'w', encoding='utf-8') as f:
                json.dump({
                    "optimization_start_time": self.start_time.isoformat(),
                    "current_time": datetime.now().isoformat(),
                    "total_optimizations": len(self.optimization_log),
                    "optimization_history": self.optimization_log
                }, f, indent=2, ensure_ascii=False)
        except Exception as e:
            print(f"保存优化日志失败: {str(e)}")
    
    def generate_optimization_report(self):
        """生成优化报告"""
        if not self.optimization_log:
            return "暂无优化记录"
        
        report = f"""
{'='*60}
自动化优化报告
{'='*60}
优化开始时间: {self.start_time.strftime('%Y-%m-%d %H:%M:%S')}
总优化次数: {len(self.optimization_log)}
最新优化时间: {datetime.fromisoformat(self.optimization_log[-1]['timestamp']).strftime('%Y-%m-%d %H:%M:%S')}

优化记录:
"""
        
        successful = 0
        for opt in self.optimization_log:
            status = "✅ 成功" if opt["success"] else "❌ 失败"
            report += f"\n- {opt['area']}: {opt['action']} ({status})"
            if opt["output"]:
                report += f"\n  输出: {opt['output'][:100]}..."
        
        successful = sum(1 for opt in self.optimization_log if opt["success"])
        success_rate = (successful / len(self.optimization_log) * 100) if self.optimization_log else 0
        
        report += f"\n\n优化成功率: {success_rate:.1f}% ({successful}/{len(self.optimization_log)})"
        
        # 加载状态数据
        status_data = self.load_status_data()
        if status_data:
            trends = self.analyze_status_trends(status_data)
            report += f"\n\n当前状态趋势:"
            report += f"\n- DNS成功率: {trends.get('dns_success_rate', 0):.1f}%"
            report += f"\n- HTTPS成功率: {trends.get('https_success_rate', 0):.1f}%"
            report += f"\n- 整体成功率: {trends.get('overall_success_rate', 0):.1f}%"
            
            if trends.get("issues"):
                report += f"\n\n待解决问题:"
                for issue in trends["issues"]:
                    report += f"\n- {issue['check']}: {issue['message']} (严重性: {issue['severity']})"
        
        report += "\n" + "="*60
        return report
    
    def continuous_optimization(self, interval_minutes=30, max_cycles=48):
        """持续优化循环"""
        print("🚀 启动自动化优化系统")
        print(f"优化间隔: {interval_minutes}分钟")
        print(f"最大循环次数: {max_cycles}")
        print(f"开始时间: {self.start_time.strftime('%Y-%m-%d %H:%M:%S')}")
        print("="*60)
        
        cycle_count = 0
        try:
            while True:
                if max_cycles and cycle_count >= max_cycles:
                    print(f"\n达到最大优化次数: {max_cycles}")
                    break
                
                cycle_count += 1
                print(f"\n第 {cycle_count} 次优化循环")
                print(f"时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
                
                # 加载并分析数据
                status_data = self.load_status_data()
                if not status_data:
                    print("⚠️ 无监控数据，等待下一次检查")
                    time.sleep(interval_minutes * 60)
                    continue
                
                # 分析趋势
                trends = self.analyze_status_trends(status_data)
                
                # 执行优化
                if trends.get("issues"):
                    print(f"发现 {len(trends['issues'])} 个问题")
                    
                    # 按优先级排序
                    critical_issues = [i for i in trends["issues"] if i["severity"] == "critical"]
                    high_issues = [i for i in trends["issues"] if i["severity"] == "high"]
                    other_issues = [i for i in trends["issues"] if i["severity"] not in ["critical", "high"]]
                    
                    # 先处理关键问题
                    issues_to_fix = critical_issues + high_issues
                    
                    for issue in issues_to_fix:
                        # 找到对应的改进建议
                        for improvement in trends.get("improvements", []):
                            if improvement["area"].lower() in issue["check"].lower():
                                print(f"\n处理问题: {issue['check']}")
                                result = self.execute_optimization(improvement)
                                if result["success"]:
                                    print(f"✅ 优化成功")
                                else:
                                    print(f"❌ 优化失败: {result['output'][:100]}")
                                break
                else:
                    print("✅ 未发现问题，系统运行正常")
                
                # 生成报告
                if cycle_count % 6 == 0:  # 每3小时生成一次报告
                    print("\n" + self.generate_optimization_report())
                
                print(f"\n⏳ 等待 {interval_minutes} 分钟后再次优化...")
                time.sleep(interval_minutes * 60)
                
        except KeyboardInterrupt:
            print("\n\n👋 优化被用户中断")
        finally:
            print("\n" + "="*60)
            print("最终优化报告:")
            print(self.generate_optimization_report())
            print("="*60)

if __name__ == "__main__":
    optimizer = AutoOptimizer()
    
    # 立即执行一次分析
    print("执行首次优化分析...")
    status_data = optimizer.load_status_data()
    
    if status_data:
        trends = optimizer.analyze_status_trends(status_data)
        
        print("\n分析结果:")
        print(f"DNS成功率: {trends.get('dns_success_rate', 0):.1f}%")
        print(f"HTTPS成功率: {trends.get('https_success_rate', 0):.1f}%")
        print(f"整体成功率: {trends.get('overall_success_rate', 0):.1f}%")
        
        if trends.get("issues"):
            print(f"\n发现 {len(trends['issues'])} 个问题:")
            for issue in trends["issues"]:
                print(f"- {issue['check']}: {issue['message']} (严重性: {issue['severity']})")
            
            print(f"\n生成 {len(trends.get('improvements', []))} 条改进建议")
            
            # 询问是否执行优化
            response = input("\n是否执行优化建议？(y/n): ")
            if response.lower() == 'y':
                for improvement in trends.get("improvements", []):
                    if improvement.get("priority") in ["critical", "high"]:
                        optimizer.execute_optimization(improvement)
        
        # 开始持续优化
        print("\n🚀 开始持续优化监控...")
        optimizer.continuous_optimization(interval_minutes=30, max_cycles=48)
    else:
        print("⚠️ 无监控数据，请先运行监控系统")
        print("运行: python website_monitor.py")