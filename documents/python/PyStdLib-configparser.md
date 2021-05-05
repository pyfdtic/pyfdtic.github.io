---
title: PyStdLib--configparser
date: 2018-03-19 18:35:17
categories:
- Python
tags:
- python 标准库
---
configparser 用于处理 ini 格式的配置文件, 其本质上是利用 open 来操作文件. 

## 示例文件 : 

    [zhangsan]
    name = zhangsan
    age = 12
    job = worker

    [lisi]
    name = lisi
    age = 32
    job = manager

**文件中不需要引号, 所有内容都是字符串. 并且在程序中返回的也是 字符串. 使用时, 需要根据需要进行类型转换.**

## 用法:

    import configparser

    conf = configparser.ConfigParser()
    conf.read('test.ini', encoding='utf-8')     # 读取文件
    conf.write(open('test.ini', 'w'))           # 写入文件

    conf.sections() : 获取所有节点, 返回 所有键组成的列表.
    conf.has_section(SEC_NAME)      # 判断是否具有某个节点, 返回布尔值.
    conf.add_section(NEW_SEC)       # 添加节点,
    conf.remove_section(SEC_NAME)   # 删除节点.

    conf.items() : 获取指定节点下所有的键值对, 返回元组组成的列表.
    conf.options(section) : 获取指定节点下所有的键, 返回 所有键组成的列表.
    conf.get("SEC_NAME", "KEY")          # 获取指定 键 的 值. 返回为 字符串形式.
    conf.getint("SEC_NAME", "KEY")       # 返回 int 形式
    conf.getfloat("SEC_NAME", "KEY")     # 返回 float 形式
    conf.getboolean("SEC_NAME", "KEY")   # 返回 boolean 形式

    conf.has_option(SEC_NAME, KEY)       # 判断某个 section 下是否有 某个 item .
    conf.remove_option(SEC_NAME, KEY)    # 删除某个 section 下的 item
    conf.set(SECTION, KEY, VALUE)        # 在某个 section 下 修改/新增 item.