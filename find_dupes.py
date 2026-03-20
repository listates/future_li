#!/usr/bin/env python3
"""
简单重复文件查找工具 - 按文件大小和哈希值比对
"""

import os
import hashlib
import sys
from collections import defaultdict
import time

def get_file_hash(filepath, chunk_size=8192):
    """计算文件的MD5哈希值"""
    md5 = hashlib.md5()
    try:
        with open(filepath, 'rb') as f:
            while chunk := f.read(chunk_size):
                md5.update(chunk)
        return md5.hexdigest()
    except (OSError, IOError):
        return None

def find_duplicate_files(directories):
    """查找重复文件"""
    print(f"扫描目录: {directories}")
    print("正在收集文件信息...")
    
    # 按文件大小分组
    size_map = defaultdict(list)
    total_files = 0
    
    for directory in directories:
        for root, dirs, files in os.walk(directory):
            for file in files:
                filepath = os.path.join(root, file)
                try:
                    size = os.path.getsize(filepath)
                    size_map[size].append(filepath)
                    total_files += 1
                    if total_files % 1000 == 0:
                        print(f"已扫描 {total_files} 个文件...")
                except (OSError, IOError):
                    continue
    
    print(f"\n扫描完成，共 {total_files} 个文件")
    print("正在分析重复文件...")
    
    # 只检查大小相同的文件
    duplicates = []
    processed = 0
    
    for size, filepaths in size_map.items():
        if len(filepaths) > 1:  # 有相同大小的文件
            # 按哈希值分组
            hash_map = defaultdict(list)
            for filepath in filepaths:
                file_hash = get_file_hash(filepath)
                if file_hash:
                    hash_map[file_hash].append(filepath)
            
            # 收集重复文件
            for file_hash, paths in hash_map.items():
                if len(paths) > 1:
                    duplicates.append({
                        'size': size,
                        'hash': file_hash,
                        'paths': paths
                    })
        
        processed += 1
        if processed % 100 == 0:
            print(f"已分析 {processed}/{len(size_map)} 个大小分组...")
    
    return duplicates

def format_size(size):
    """格式化文件大小"""
    for unit in ['B', 'KB', 'MB', 'GB']:
        if size < 1024.0:
            return f"{size:.2f} {unit}"
        size /= 1024.0
    return f"{size:.2f} TB"

def main():
    if len(sys.argv) < 2:
        print("用法: python find_dupes.py <目录1> [目录2 ...]")
        print("示例: python find_dupes.py E:\\ F:\\")
        sys.exit(1)
    
    directories = sys.argv[1:]
    
    # 检查目录是否存在
    for directory in directories:
        if not os.path.exists(directory):
            print(f"错误: 目录不存在 - {directory}")
            sys.exit(1)
    
    start_time = time.time()
    duplicates = find_duplicate_files(directories)
    end_time = time.time()
    
    print(f"\n{'='*60}")
    print(f"扫描完成，耗时: {end_time - start_time:.2f} 秒")
    print(f"找到 {len(duplicates)} 组重复文件")
    print(f"{'='*60}\n")
    
    if duplicates:
        total_saved = 0
        for i, dup in enumerate(duplicates, 1):
            size = dup['size']
            paths = dup['paths']
            total_saved += size * (len(paths) - 1)  # 可节省的空间
            
            print(f"第 {i} 组 - 大小: {format_size(size)}")
            print(f"哈希: {dup['hash'][:16]}...")
            for j, path in enumerate(paths):
                print(f"  {j+1}. {path}")
            print()
        
        print(f"{'='*60}")
        print(f"总计可节省空间: {format_size(total_saved)}")
        print(f"{'='*60}")
        
        # 生成清理脚本
        script_path = "clean_dupes.bat"
        with open(script_path, 'w', encoding='utf-8') as f:
            f.write("@echo off\n")
            f.write("REM 重复文件清理脚本\n")
            f.write("REM 保留每组第一个文件，删除其余重复文件\n\n")
            
            for dup in duplicates:
                paths = dup['paths']
                if len(paths) > 1:
                    # 保留第一个，删除后面的
                    for path in paths[1:]:
                        f.write(f'echo 删除: "{path}"\n')
                        f.write(f'del /f "{path}"\n')
                    f.write("\n")
            
            f.write("echo 清理完成！\n")
            f.write("pause\n")
        
        print(f"\n已生成清理脚本: {script_path}")
        print("运行此脚本将删除所有重复文件（保留每组第一个）")
        print("请先检查脚本内容，确认无误后再运行！")
    else:
        print("未找到重复文件！")

if __name__ == "__main__":
    main()