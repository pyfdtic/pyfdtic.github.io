---
title: python-Ipython自动重载
date: 2018-03-16 16:56:01
categories:
- Python
tags:
- Ipython
- 自动重载
- PyPi
---
## 一. 使用示例

    In [1]: %load_ext autoreload

    In [2]: %autoreload 2       # Reload all modules (except those excluded by %aimport) every time before executing the Python code typed.

    In [3]: from foo import some_function

    In [4]: some_function()
    Out[4]: 42

    In [5]: # open foo.py in an editor and change some_function to return 43

    In [6]: some_function()
    Out[6]: 43

## 二. Magic Commands.

The following magic commands are provided:

- `%autoreload` : Reload all modules (except those excluded by %aimport) automatically now.

- `%autoreload 0` : Disable automatic reloading.

- `%autoreload 1` : Reload all modules imported with %aimport every time before executing the Python code typed.

- `%autoreload 2` : Reload all modules (except those excluded by %aimport) every time before executing the Python code typed.

- `%aimport` : List modules which are to be automatically imported or not to be imported.

- `%aimport foo` : Import module ‘foo’ and mark it to be autoreloaded for %autoreload 1

- `%aimport -foo` : Mark module ‘foo’ to not be autoreloaded.