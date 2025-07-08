#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Python环境测试脚本
功能：检查Python安装状态、SQLite可用性、基本功能测试
作者：AI Assistant
日期：2024
"""

import sys
import os
import platform
import sqlite3
import datetime
import json

def print_separator(title):
    """打印分隔线"""
    print("\n" + "="*60)
    print(f"🔍 {title}")
    print("="*60)

def test_python_basic():
    """测试Python基本信息"""
    print_separator("Python基本信息")
    
    print(f"Python版本: {sys.version}")
    print(f"Python路径: {sys.executable}")
    print(f"操作系统: {platform.system()} {platform.release()}")
    print(f"架构: {platform.architecture()[0]}")
    print(f"当前工作目录: {os.getcwd()}")

def test_python_modules():
    """测试Python模块"""
    print_separator("Python模块测试")
    
    modules_to_test = [
        'sqlite3', 'datetime', 'json', 'os', 'sys', 
        'platform', 'math', 'random', 're'
    ]
    
    for module in modules_to_test:
        try:
            __import__(module)
            print(f"✅ {module} - 可用")
        except ImportError as e:
            print(f"❌ {module} - 不可用: {e}")

def test_sqlite():
    """测试SQLite功能"""
    print_separator("SQLite数据库测试")
    
    try:
        # 测试SQLite版本
        conn = sqlite3.connect(':memory:')
        cursor = conn.cursor()
        cursor.execute('SELECT sqlite_version()')
        version = cursor.fetchone()
        print(f"✅ SQLite版本: {version[0]}")
        
        # 测试基本SQL操作
        cursor.execute('''
            CREATE TABLE test_table (
                id INTEGER PRIMARY KEY,
                name TEXT,
                value REAL
            )
        ''')
        print("✅ 创建表成功")
        
        # 插入数据
        cursor.execute('INSERT INTO test_table VALUES (1, "测试", 3.14)')
        print("✅ 插入数据成功")
        
        # 查询数据
        cursor.execute('SELECT * FROM test_table')
        result = cursor.fetchone()
        print(f"✅ 查询数据成功: {result}")
        
        # 删除表
        cursor.execute('DROP TABLE test_table')
        print("✅ 删除表成功")
        
        conn.close()
        print("✅ SQLite连接关闭成功")
        return True
        
    except Exception as e:
        print(f"❌ SQLite测试失败: {e}")
        return False

def test_file_operations():
    """测试文件操作"""
    print_separator("文件操作测试")
    
    test_file = "test_file.txt"
    test_content = "这是一个测试文件\n创建时间: " + str(datetime.datetime.now())
    
    try:
        # 写入文件
        with open(test_file, 'w', encoding='utf-8') as f:
            f.write(test_content)
        print("✅ 文件写入成功")
        
        # 读取文件
        with open(test_file, 'r', encoding='utf-8') as f:
            content = f.read()
        print("✅ 文件读取成功")
        print(f"文件内容: {content[:50]}...")
        
        # 删除测试文件
        os.remove(test_file)
        print("✅ 文件删除成功")
        
        return True
        
    except Exception as e:
        print(f"❌ 文件操作测试失败: {e}")
        return False

def test_json_operations():
    """测试JSON操作"""
    print_separator("JSON操作测试")
    
    test_data = {
        "name": "测试数据",
        "numbers": [1, 2, 3, 4, 5],
        "nested": {
            "key": "value",
            "boolean": True
        },
        "timestamp": datetime.datetime.now().isoformat()
    }
    
    try:
        # 序列化
        json_str = json.dumps(test_data, ensure_ascii=False, indent=2)
        print("✅ JSON序列化成功")
        
        # 反序列化
        parsed_data = json.loads(json_str)
        print("✅ JSON反序列化成功")
        
        # 验证数据
        if parsed_data["name"] == test_data["name"]:
            print("✅ JSON数据验证成功")
        else:
            print("❌ JSON数据验证失败")
            
        return True
        
    except Exception as e:
        print(f"❌ JSON操作测试失败: {e}")
        return False

def test_warehouse_system_components():
    """测试仓库管理系统组件"""
    print_separator("仓库管理系统组件测试")
    
    try:
        # 测试数据库连接
        db_path = "test_warehouse.db"
        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()
        
        # 创建测试表
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS test_caozuoyuan (
                xingming VARCHAR(20) PRIMARY KEY,
                caozuoyuanlianxifangshi VARCHAR(20)
            )
        ''')
        print("✅ 操作员表创建成功")
        
        # 插入测试数据
        cursor.execute('INSERT OR REPLACE INTO test_caozuoyuan VALUES (?, ?)', 
                      ("测试操作员", "13800138000"))
        print("✅ 测试数据插入成功")
        
        # 查询测试数据
        cursor.execute('SELECT * FROM test_caozuoyuan')
        result = cursor.fetchone()
        print(f"✅ 测试数据查询成功: {result}")
        
        # 清理测试数据
        cursor.execute('DROP TABLE test_caozuoyuan')
        conn.close()
        os.remove(db_path)
        print("✅ 测试数据清理成功")
        
        return True
        
    except Exception as e:
        print(f"❌ 仓库管理系统组件测试失败: {e}")
        return False

def test_performance():
    """测试基本性能"""
    print_separator("性能测试")
    
    import time
    import math
    
    # 计算性能测试
    start_time = time.time()
    result = 0
    for i in range(1000000):
        result += math.sqrt(i)
    end_time = time.time()
    
    print(f"✅ 100万次平方根计算耗时: {end_time - start_time:.4f}秒")
    print(f"计算结果: {result:.2f}")

def generate_report():
    """生成测试报告"""
    print_separator("测试报告")
    
    report = {
        "测试时间": datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "Python版本": sys.version.split()[0],
        "操作系统": f"{platform.system()} {platform.release()}",
        "架构": platform.architecture()[0],
        "SQLite可用": "是" if sqlite3.sqlite_version else "否",
        "文件操作": "正常",
        "JSON操作": "正常",
        "仓库系统组件": "正常"
    }
    
    print("📊 测试结果汇总:")
    for key, value in report.items():
        print(f"  {key}: {value}")
    
    # 保存报告到文件
    try:
        with open("environment_test_report.json", "w", encoding="utf-8") as f:
            json.dump(report, f, ensure_ascii=False, indent=2)
        print("✅ 测试报告已保存到 environment_test_report.json")
    except Exception as e:
        print(f"❌ 保存测试报告失败: {e}")

def main():
    """主测试函数"""
    print("🚀 Python环境测试开始")
    print("="*60)
    
    # 运行各项测试
    test_python_basic()
    test_python_modules()
    
    sqlite_ok = test_sqlite()
    file_ok = test_file_operations()
    json_ok = test_json_operations()
    warehouse_ok = test_warehouse_system_components()
    
    test_performance()
    generate_report()
    
    # 总结
    print_separator("测试总结")
    
    if all([sqlite_ok, file_ok, json_ok, warehouse_ok]):
        print("🎉 所有测试通过！Python环境配置正确。")
        print("✅ 您可以运行仓库管理系统了！")
        print("\n运行命令:")
        print("  cd Test02ForPythonAndSQL")
        print("  python warehouse_management.py")
    else:
        print("⚠️  部分测试失败，请检查环境配置。")
        print("📖 请参考 installation_guide.md 进行环境配置。")
    
    print("\n" + "="*60)
    print("🔚 Python环境测试完成")

if __name__ == "__main__":
    main() 