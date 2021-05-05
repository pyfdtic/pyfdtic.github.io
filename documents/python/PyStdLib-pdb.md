---
title: PyStdLib--pdb 代码调试技巧
date: 2018-03-27 17:35:09
categories:
- Python
tags:
- python 标准库
- 代码调试
---

## 设置断点方式
1. 命令行方式
        
        $ python -m pdb myscript.py

2. 代码方式
    
    在 代码中希望调试的部分, 插入如下代码

        import pdb; pdb.set_trace();

## pdb 常用命令

| 命令 | 含义 |
| -- | -- |
| `break` 或 `b` 设置断点 | 设置断点 |
| `continue` 或 `c` | 继续执行程序 |
| `list` 或 `l` | 查看当前行的代码段 |
| `step` 或 `s` | 进入 函数 |
| `return` 或 `r` | 执行代码直到从函数返回 |
| `exit` 或 `q` | 终止并退出 |
| `next` 或 `n` | 执行下一行 |
| `pp VAR` | 格式化打印变量的值 |
| `p VAR` | 打印变量的值 |
| `help` | 显示帮助 |
| `key = value` | 变量赋值 |
| `!key = value` | 变量重新赋值 |

pdb 一个明显的缺陷就是对于多线程, 远程调试等支持的不够好, 同时没有直观的界面显示.

## ipdb 
pdb 调试会话非常简单, 并没有提供 tab 补全或 代码高亮等功能, [ipdb](https://pypi.python.org/pypi/ipdb) 可以提供基于 `ipython` 的扩展包, 实现上诉功能.
    
    # 安装
    $ pip install ipdb

    # 使用
    $ python -m ipdb my_script.py
    >> from ipdb import set_trace; set_trace()
    
