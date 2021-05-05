---
title: Python 汇总
date: 2018-03-14 23:28:28
categories:
- Python
tags:
- python 标准库
top: 3
---
## 零. py2 VS py3
Python2 将在 2018 年停止维护.

已经使用 Python3 兼容的库列表 : [PYTHON 3 WALL OF SUPERPOWERS](https://python3wos.appspot.com/)

### (一) 语法变化
- `print` 不再是一条语句, 而是一个函数

    可以使用如下方法, 在 py2 和 py3 之间兼容

        from __future__ import print_function
        print(123)
- `exec` 不再是一条语句, 而是一个函数
- 异常捕获语法由 `except exc, var` 转变为 `except exc as var`
- `from module import *` 只能用于模块中, **不能**用于函数中.
- `sorted` 函数与列表的 `sort` 方法不再接受 `cmp` 参数, 应该用 `key` 参数代替.
- 整数除法返回的是浮点数, 取整运算可以使用 `//` 运算符.
- py3 中, 不再使用 `staticmethod` 装饰器, 没有 `self` 参数的类方法即静态方法.
- 所有类都是新式类, 不再有新式类和旧式类的区分, 无需继承 `object` 对象.
- 函数注解
- 扩展的可迭代解包

        items = [1,2,3,4,5]
        a, *rest = items    # a = 1, rest = [2,3,4,5]

### (二) 标准库变化
- urlparse
- asynccore
- asyncchat
### (三) 数据类型与集合变化
- 统一了类和类型.
- 所有字符串都是 Unicode, 字节(bytes)前添加 `b` 或 `B` 前缀, py2 中的 `u`前缀, 在 Py3 中没有语法意义, 只做兼容.
- `range()`, `map()`, `reduce()` 等返回的是可迭代对象, 而不再是 list.

### (四) py2 py3 跨版本兼容常用工具及技术.

#### 1. __future__
- `from __future__ import division` : python3 除法
- `from __future__ import absolute_import` : 将所有不以点字符开头的 import 语句格式解释为绝对导入
- `from __future__ import print_function` : 打印函数
- `from __future__ import unicode_literals` : 将每个字符串解释为 Unicode.

#### 2. compat.py
将所有兼容性代码放在一个 附加模块中, 通常命名为 `compat.py`

编写兼容性代码示例

    # 使用 sys.version_info
    import sys
    if sys.version_info < (3, 0,0):
        import urlparse

        def is_string(s):
            return isinstance(s, basestring)
    else:
        from urllib import parse as urlparse

        def is_string(s):
            return isinstance(s, str)

    # 使用 try, except
    try:
        import simplejson as json
    except ImportError:
        import json

[six](http://six.readthedocs.io/) 是另一个跨版本兼容的工具包, 名字起的很有趣, 2 x 3 = six ? ,:)

    # 使用 six 
    import six
    if six.PY3:
        import urlparse

        def is_string(s):
            return isinstance(s, basestring)

    elif six.PY2:
        from urllib import parse as urlparse

        def is_string(s):
            return isinstance(s, str)
    else:
        raise ImportError
    
#### 5. python3 2to3 包
2to3 可以协助实现 python2 向 python3 的代码迁移, 他是一个命令行工具. 通常位于 Python 源码的 `Tools/scripts` 目录中.

    # 输入如下命令, 他将输出有问题的和可能需要修改的程序部分, 输出格式类似 git diff 输出.
    $ 2to3 script.py

    # 显示可用修复项列表
    $ 2to3 -l

    # 指定单独的修复项来修复.
    $ 2to3 -f xrange script.py

## 一. Python 类型与对象
### (一) 内置数据类型

### (二) 程序结构的内置类型

### (三) 解释器内置类型

## 二. Python 库

### (一) Python 标准库

- [pdb 代码调试技巧](https://www.pyfdtic.com/2018/03/27/PyStdLib-pdb/)
- [unittest](https://www.pyfdtic.com/2018/03/19/PyStdLib-unittest/)
- [logging](https://www.pyfdtic.com/2018/03/19/PyStdLib-logging/)
- [random](https://www.pyfdtic.com/2018/03/19/PyStdLib-random/)
- [requests](https://www.pyfdtic.com/2018/03/19/PyStdLib-requests/)
- [datetime](https://www.pyfdtic.com/2018/03/19/PyStdLib-datetime/)
- [time](https://www.pyfdtic.com/2018/03/19/PyStdLib-time/)
- [configparser](https://www.pyfdtic.com/2018/03/19/PyStdLib-configparser/)
- [multiprocessing](https://www.pyfdtic.com/2018/03/19/PyStdLib-multiprocessing/)
- [subprocess](https://www.pyfdtic.com/2018/03/19/PyStdLib-subprocess/)
- [shutil](https://www.pyfdtic.com/2018/03/19/PyStdLib-shutil/)
- [pickle](https://www.pyfdtic.com/2018/03/19/PyStdLib-pickle/)
- [re](https://www.pyfdtic.com/2018/03/19/PyStdLib-re/)
- [signal](https://www.pyfdtic.com/2018/03/19/PyStdLib-signal/)
- [os](https://www.pyfdtic.com/2018/03/19/PyStdLib-os/)
- [threading](https://www.pyfdtic.com/2018/03/19/PyStdLib-threading/)
- [glob](https://www.pyfdtic.com/2018/03/19/PyStdLib-glob/)
- [optparse](https://www.pyfdtic.com/2018/03/15/PyStdLib-optparse/)

### (二) python 第三方库

- [Flask-学习总结](https://www.pyfdtic.com/2018/03/14/flask-%E5%AD%A6%E4%B9%A0%E6%80%BB%E7%BB%93/)
- [Ansible-学习总结](https://www.pyfdtic.com/2018/03/14/Ansible-%E5%AD%A6%E4%B9%A0%E6%80%BB%E7%BB%93/)
- [Django 学习总结](https://www.pyfdtic.com/2018/03/14/django-%E5%AD%A6%E4%B9%A0%E6%80%BB%E7%BB%93/)
- [python celery 任务队列](https://www.pyfdtic.com/2018/03/16/python-celery-%E4%BB%BB%E5%8A%A1%E9%98%9F%E5%88%97/)
- [Scrapy](https://www.pyfdtic.com/2018/03/15/Scrapy/)
- [python state_machine 文档及源码分析](https://www.pyfdtic.com/2018/03/27/python-state-machine/)
- [python 微信接口 -- itchat 文档](https://www.pyfdtic.com/2018/03/16/python-itchat-weixin-api/)
- [python pyecharts-文档笔记](https://www.pyfdtic.com/2018/03/16/python-pyecharts-%E6%96%87%E6%A1%A3%E7%AC%94%E8%AE%B0/)
- [python yaml 解析](https://www.pyfdtic.com/2018/03/16/python-yml%E8%A7%A3%E6%9E%90/)
- [Splinter 自动化测试](https://www.pyfdtic.com/2018/03/15/%E8%87%AA%E5%8A%A8%E5%8C%96%E6%B5%8B%E8%AF%95-splinter/)
- [fake-useragent-文档](https://www.pyfdtic.com/2018/03/15/fake-useragent-%E6%96%87%E6%A1%A3/)

## 三. Python 编程
### (一) 原理

### (二) 函数式编程

### (三) 面向对象编程

- [python-设计模式](https://www.pyfdtic.com/tags/%E8%AE%BE%E8%AE%A1%E6%A8%A1%E5%BC%8F/)

### (四) 数据结构与算法

### (五) 高级主题

1. 装饰器

1. 元编程

2. 自省

3. 描述符

4. 多线程, 多进程, 异步编程

### (六) 模块, 包与分发

### (七) 代码质量检查
#### 1. 代码规范 与 PEP8
#### 2. Pylint
#### 3. Flake8

## 四. Python web 编程

### 0. wsgi 与 asgi
[PEP-0333](https://www.python.org/dev/peps/pep-0333/)
[asgi](https://blog.ernest.me/post/asgi-draft-spec-zh)
### 1. Werkzeug && Flask

#### Werkzeug

#### Flask
- [Flask-学习总结](https://www.pyfdtic.com/2018/03/14/flask-%E5%AD%A6%E4%B9%A0%E6%80%BB%E7%BB%93/)
- [Flask 扩展之--flask-login](https://www.pyfdtic.com/2018/03/19/flaskExt--flask-login/)
- [Flask 扩展之--flask-pagedown](https://www.pyfdtic.com/2018/03/19/flaskExt--flask-pagedown/)
- [Flask 扩展之--flask-mail](https://www.pyfdtic.com/2018/03/19/flaskExt--flask-mail/)
- [Flask 扩展之--flask-moment](https://www.pyfdtic.com/2018/03/19/flaskExt--flask-moment/)
- [Flask 扩展之--flask-script](https://www.pyfdtic.com/2018/03/19/flaskExt--flask-script/)
- [Fask 扩展之--flask-sqlalchemy](https://www.pyfdtic.com/2018/03/19/flaskExt--flask-sqlalchemy/)
- [Flask 扩展之--flask-sse](https://www.pyfdtic.com/2018/03/16/flaskExt--flask-sse/)
- [Flask 扩展之--flask-socketio](https://www.pyfdtic.com/2018/03/16/flaskExt--flask-socketio/)
- [Flask 扩展之--flask-whooshee](https://www.pyfdtic.com/2018/03/16/flaskExt--flask-whooshee/)

### 2. Django

- [Django 学习总结](https://www.pyfdtic.com/2018/03/14/django-%E5%AD%A6%E4%B9%A0%E6%80%BB%E7%BB%93/)
- [django之零--入门篇](https://www.pyfdtic.com/2018/03/16/django%E4%B9%8B%E9%9B%B6--%E5%85%A5%E9%97%A8%E7%AF%87/)
- [django之一--视图篇](https://www.pyfdtic.com/2018/03/16/django%E4%B9%8B%E4%B8%80--%E8%A7%86%E5%9B%BE%E7%AF%87/)
- [django之二--模板篇](https://www.pyfdtic.com/2018/03/16/django%E4%B9%8B%E4%BA%8C--%E6%A8%A1%E6%9D%BF%E7%AF%87/)
- [django之三--模型篇](https://www.pyfdtic.com/2018/03/16/django%E4%B9%8B%E4%B8%89--%E6%A8%A1%E5%9E%8B%E7%AF%87/)
- [django之五--表单](https://www.pyfdtic.com/2018/03/16/django%E4%B9%8B%E4%BA%94--%E8%A1%A8%E5%8D%95/)
- [django之四--Admin管理工具](https://www.pyfdtic.com/2018/03/16/django%E4%B9%8B%E5%9B%9B--Admin%E7%AE%A1%E7%90%86%E5%B7%A5%E5%85%B7/)
- [django之六--部署篇](https://www.pyfdtic.com/2018/03/16/django%E4%B9%8B%E5%85%AD--%E9%83%A8%E7%BD%B2%E7%AF%87/)
- [django-模板原理及扩展](https://www.pyfdtic.com/2018/03/16/django-%E6%A8%A1%E6%9D%BF%E5%8E%9F%E7%90%86%E5%8F%8A%E6%89%A9%E5%B1%95/)

### 3. 前端
#### 3.1 AngularJS
- [AngularJS高级程序设计读书笔记--大纲篇](https://www.pyfdtic.com/2018/03/16/AngularJS%E9%AB%98%E7%BA%A7%E7%A8%8B%E5%BA%8F%E8%AE%BE%E8%AE%A1%E8%AF%BB%E4%B9%A6%E7%AC%94%E8%AE%B0--%E5%A4%A7%E7%BA%B2%E7%AF%87/)
- [AngularJS高级程序设计读书笔记--模块篇](https://www.pyfdtic.com/2018/03/16/AngularJS%E9%AB%98%E7%BA%A7%E7%A8%8B%E5%BA%8F%E8%AE%BE%E8%AE%A1%E8%AF%BB%E4%B9%A6%E7%AC%94%E8%AE%B0--%E6%A8%A1%E5%9D%97%E7%AF%87/)
- [AngularJS高级程序设计读书笔记--控制器篇](https://www.pyfdtic.com/2018/03/16/AngularJS%E9%AB%98%E7%BA%A7%E7%A8%8B%E5%BA%8F%E8%AE%BE%E8%AE%A1%E8%AF%BB%E4%B9%A6%E7%AC%94%E8%AE%B0--%E6%8E%A7%E5%88%B6%E5%99%A8%E7%AF%87/)
- [AngularJS高级程序设计读书笔记--指令篇之内置指令](https://www.pyfdtic.com/2018/03/16/AngularJS%E9%AB%98%E7%BA%A7%E7%A8%8B%E5%BA%8F%E8%AE%BE%E8%AE%A1%E8%AF%BB%E4%B9%A6%E7%AC%94%E8%AE%B0--%E6%8C%87%E4%BB%A4%E7%AF%87%E4%B9%8B%E5%86%85%E7%BD%AE%E6%8C%87%E4%BB%A4/)
- [AngularJS高级程序设计读书笔记--指令篇之自定义指令](https://www.pyfdtic.com/2018/03/16/AngularJS%E9%AB%98%E7%BA%A7%E7%A8%8B%E5%BA%8F%E8%AE%BE%E8%AE%A1%E8%AF%BB%E4%B9%A6%E7%AC%94%E8%AE%B0--%E6%8C%87%E4%BB%A4%E7%AF%87%E4%B9%8B%E8%87%AA%E5%AE%9A%E4%B9%89%E6%8C%87%E4%BB%A4/)
- [AngularJS高级程序设计读书笔记--过滤器篇](https://www.pyfdtic.com/2018/03/16/AngularJS%E9%AB%98%E7%BA%A7%E7%A8%8B%E5%BA%8F%E8%AE%BE%E8%AE%A1%E8%AF%BB%E4%B9%A6%E7%AC%94%E8%AE%B0--%E8%BF%87%E6%BB%A4%E5%99%A8%E7%AF%87/)
- [AngularJS高级程序设计读书笔记--服务篇](https://www.pyfdtic.com/2018/03/16/AngularJS%E9%AB%98%E7%BA%A7%E7%A8%8B%E5%BA%8F%E8%AE%BE%E8%AE%A1%E8%AF%BB%E4%B9%A6%E7%AC%94%E8%AE%B0--%E6%9C%8D%E5%8A%A1%E7%AF%87/)

#### 3.2 Vue
- [Vuex]()

## 五. Python 爬虫

### 1. scrapy

- [Scrapy](https://www.pyfdtic.com/2018/03/15/Scrapy/)
- [Scrapy-命令行工具](https://www.pyfdtic.com/2018/03/15/Scrapy-%E5%91%BD%E4%BB%A4%E8%A1%8C%E5%B7%A5%E5%85%B7/)
- [fake-useragent-文档](https://www.pyfdtic.com/2018/03/15/fake-useragent-%E6%96%87%E6%A1%A3/)

### 2. 其他

- [lxml](http://lxml.de/) : 是一个优美的扩展库, 用来快速解析 XML 和 HTML 文档, 
- [Requests](http://docs.python-requests.org/en/latest/) : 用来取代内建的 urllib2 模块.

## 六. 数据统计与分析

## 七. DevOps
### 1. Ansible
- [Ansible-学习总结](https://www.pyfdtic.com/2018/03/14/Ansible-%E5%AD%A6%E4%B9%A0%E6%80%BB%E7%BB%93/)
- [Ansible-基本原理与安装配置](https://www.pyfdtic.com/2018/03/15/Ansible-%E5%9F%BA%E6%9C%AC%E5%8E%9F%E7%90%86%E4%B8%8E%E5%AE%89%E8%A3%85%E9%85%8D%E7%BD%AE/)
- [Ansible task/role/playbook](https://www.pyfdtic.com/2018/03/15/Ansible-task-role-playbook/)
- [Ansible-配置文件](https://www.pyfdtic.com/2018/03/15/Ansible-%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B6/)
- [Ansible-API](https://www.pyfdtic.com/2018/03/15/Ansible-API/)
- [Ansible-模块](https://www.pyfdtic.com/2018/03/15/Ansible-%E6%A8%A1%E5%9D%97/)
- [Ansible-变量](https://www.pyfdtic.com/2018/03/15/Ansible-%E5%8F%98%E9%87%8F/)
- [Ansible-流程控制](https://www.pyfdtic.com/2018/03/15/Ansible-%E6%B5%81%E7%A8%8B%E6%8E%A7%E5%88%B6/)
- [Ansible-Inventory](https://www.pyfdtic.com/2018/03/15/Ansible-Inventory/)

### 2. Docker

- [docker 内部组件结构 docker daemon, container,runC](https://www.pyfdtic.com/2018/03/16/docker-%E5%86%85%E9%83%A8%E7%BB%84%E4%BB%B6%E7%BB%93%E6%9E%84-docker-daemon-container-runC/)
- [docker-daemon-参数最佳实践](https://www.pyfdtic.com/2018/03/16/docker-daemon-%E5%8F%82%E6%95%B0%E6%9C%80%E4%BD%B3%E5%AE%9E%E8%B7%B5/)

### 3. Kubernet
- [kubernetes 学习笔记](https://www.pyfdtic.com/2018/03/16/docker-kubernetes/)
- [kubernetes 学习笔记总结](https://www.pyfdtic.com/2018/07/15/k8s-kubernetes-learn-note/)

## 八. Pythonic
### 1. 查询函数参数
```
import inspect
print(inspect.getargspec(func))
```
### 2. 查询对象所属的类和类名称
```
a = [1,2,3]
print a.__class__
print a.__class__.__name__
```
查询父类
```
cls.__base__
```
### 3. 百分号 模板
格式 : 

    %[(name)][flags][width].[precision]typecode

示例 : 

    tpl = "i am %(name)s, and i am %(age)d years old." % {"name": "bob", "age": 22} 

### 4. 获取本机 mac 地址 和 IP 地址

**获取本地 mac 地址**

    import uuid
    def get_mac_address(): 
        mac=uuid.UUID(int = uuid.getnode()).hex[-12:] 
        return ":".join([mac[e:e+2] for e in range(0,11,2)])

**获取 ip 地址**

    import socket
    #获取本机电脑名
    myname = socket.getfqdn(socket.gethostname(  ))
    #获取本机ip
    myaddr = socket.gethostbyname(myname)
    print myname
    print myaddr

### 5. 模块全局变量
**模块**全局变量

    __name__    : 模块名, 如果是主文件, __name__ == "__main__", 否则等于 模块名.

    __file__    : 当前模块文件的绝对路径.
    __package__ : 模块所属的包, 当前文件为 None, 

    __doc__     : 模块文档. 文档最开头, 三引号 包围的内容.
    __cached__  : 缓存, py 3.x, 实质是一个 pyc 文件.

    __loader__  : 
    __builtins__: 
    __spec__    : 

### 6. 命令行获取密码保护: getpass
getpass 密码处理

    >> import getpass
    >> password = getpass.getpass("Plz input passwd:")

### 7. 函数定义, 函数调用, 函数作用域

示例1
    
    def makeActionsA():
        acts = []
        for i in range(5):
            acts.append(lambda x: i ** x)
        return acts

    acts = makeActionsA()
    acts[0](2)          # 16 
    acts[1](2)          # 16
    acts[2](2)          # 16
    acts[3](2)          # 16
    acts[4](2)          # 16

以上代码, 原本的意思, 是要实现 返回 4 个函数, 其中每个 i 的值都不一样(参见示例2). 但事实是, 返回的所有的 i 的值都是 4 , 原因如下:

1. `acts.append(lambda x : i ** x)` 该语句只是定义了函数, 而函数**只有在调用时**, 才会实际执行其中的语句, 既示例中的 for 循环, 只是定义了 4 个 一模一样的函数 `lambda x : i ** x`

2. 当在执行 `acts[n](2)` 时, 才会实际执行函数定义的语句, 此时, i 的值为循环元素最后一个值 4, 因为 Python 函数查找变量的 LEGB 原则, 此时 lambda 函数回向上层函数中, 查找变量 i, 此时 i 为 4. 既, 所有 acts 中的函数中的 i , 在函数执行并查找 i 变量时, 得到的是同一个值 4.

示例2 

    def makeActionsA():
        acts = []
        for i in range(5):
            acts.append(lambda x, i = i : i ** x)
        return acts

    acts = makeActionsA()
    acts[0](2)          # 0 
    acts[1](2)          # 1
    acts[2](2)          # 4
    acts[3](2)          # 9
    acts[4](2)          # 16

以上示例实现了, 当 i 为不同值的 lambda 函数. 其核心原理仍然有关函数的定义, 调用, 及作用域.

1. 当定义 lambda 函数时, 默认参数 i 同时被定义, 为当前 for 循环中的 i 值. 同时, lambda 的函数体, **仍然只是 i \*\* x** 表达式, 此时 函数体中的 i 值, 仍未赋值(因为尚未调用).

2. 当调用函数时, acts[0](2) , 此时, 函数体执行时的 i 的值, 不取自于 嵌套函数, 而取自于 lambda 函数自己定义时, 传入的默认参数 i, 而默认参数 i 的值, 在不同的函数定义中时不同的, 最终实现了, 不同 lambda 函数定义生成的 acts 列表.

### 8. enumerate
```Python
s = range(10)   # s 是一个 列表

# 普通写法
for inx in range(len(s)):
    print inx, s[inx]

# pythonic 写法
for inx, val in enumerate(s):       # inx 从 0 开始
    print inx, val

for inx, val in enumerate(s, 1):    # inx 从 1 开始
    print inx, val
```
### 9. 使用 join 连接字符
```Python
letters = ["s", "p", "a", "m"]
word = "".join(letters)
```
### 10. 使用 format 格式化字符串

### 11. 解包


## 九. 杂项
### 0. 源码安装 python3

#### centos 安装 python3 环境及 pip3

1. yum 安装
    
        $ yum install python34  		                            # 安装python3.4 只有centos7 中才有.
        $ curl https://bootstrap.pypa.io/get-pip.py |python3      # 安装pip3

2. 源码安装 : 自带 pip3 

        $ yum install gcc zlib-devel bzip2-devel openssl-devel ncurser-devel
        $ wget https://www.python.org/ftp/python/3.5.1/Python-3.5.1.tgz 
        $ tar xf Python-3.5.1.tgz && cd Python-3.5.1
        $ ./configure --prefix=/opt/python-3.5
        $ make && make install
        $ vim /etc/profile.d/python3.sh
            export PATH=$PATH:/opt/python-3.5/bin
        $ source /etc/profile.d/python3.sh
        $ python3 -V
        $ pip3 -V
        $ pip3 install --upgrade  pip 

#### Amazon Linux EC2 安装 python3
主要在 **openssl-devel** 上出问题, 因为 gcc 的 devel 包的版本太低.

    $ rpm --nodeps -e openssl
    $ ln -sv /usr/local/platform/openssl/lib/libssl.so.1.0.0 /lib64/libssl.so.10
    $ ln -sv /usr/local/platform/openssl/lib/libcrypto.so.1.0.0 /lib64/libcrypto.so.10
    $ yum groupinstall "Development tools" -y
    $ yum install openssl-devel -y

    $ ./configure --prefix=/opt/python3 && make && make test && make install 

`amazon 2015.9 linux` 无法安装 gcc:

    从 amzn-ami-hvm-2017.03.rc-1.20170327-x86_64-ebs (ami-0074e160) linux 上下载 对应的 glibc-headers, glibc-devel 版本, 然后 yum install gcc 

### 1. python 命令行

python 命令行与环境变量

    $ python [-bBdEiOQsRStuUvVWxX3?] [-c command | -m module-name | script | - ] [args]

    # 博客 email 防爬 : 使用编码转换后的字符串, 如使用 base64 编码
    $ python -c "from __future__ import print_function; import base64; print(base64.b64decode('YWRtaW5AZXhhbXBsZS5jb20='))"

    # 简单 web 服务, 根目录为当前目录
    $ python -m SimpleHTTPServer

    # 支持 CGI 脚本
    $ python -m CGIHTTPServer

    # 执行完脚本之后, 进入交互式解释器, 并保存命名空间. ipython 也支持.
    $ python -i SCRIPT.py
    $ ipython -i SCRIPT.py
    
Python 2.7 中 `-o` 具有如下效果:

1. python 字节码扩展名变为 `.pyo`
2. `sys.flags.optimize` set to `1`
3. `__debug__` if False
4. `asserts` 语句不在执行.

`-oo` 效果, **包含上面的效果**:
1. `sys.flags.optimize` set to `2`
2. 文档字符串不可用.

### 2. ipython 解释器.

### 3. pip 包管理

1. 安装 pip

    python3 自带, 无需安装

        $ easy_install pip
        $ yum install python-pip

2. 安装 第三方包 
        
        $ pip install PKG_NAME            # 最新版本
        $ pip install PKG_NAME==1.0.4     # 指定版本
        $ pip install 'PKG_NAME>=1.0.4'   # 最低版本

        # 指定安装版本
        $ pip install Django==1.6.8
        
    一次安装多个包

        $ pip install BeautifulSoup4 fabric virtualenv

    从文本中安装, 文本中为包名, 一行一个, 可以指定版本号

        $ pip install -r requirements.txt

    导出当前已经安装的包

        $ pip freeze >requirements.txt

    列出已安装的包

        $ pip list
        $ pip list --outdates  # 列出以过期的包

    查看已安装包的详细信息.

        $ pip show PKG_nAME    # 显示包的详细信息. 

    搜索安装包

        $ pip search "KEY_WORD"

3. 卸载

        $ pip uninstall xlrd

4. 升级
  
        $ pip install bpython --upgrade
        $ pip install bpython -U

### 4. virtualenv 虚拟环境

独立python环境管理,virtualenvwrapper 使得virtualenv变得更好用. 适用于多版本 python 情况, 也可用于保持 Pypi 包的整洁干净的环境.

1. 安装

        $ pip install virtualenv virtualenvwrapper

        # 修改.bash_profile , 添加如下语句

        $ vim .bash_profile
            +export WORK_HOME=$HOME/.virtualenvs
            +export PROJECT_HOME=$HOME/workspace
            +source /usr/local/bin/virtualenvwrapper.sh

2. 使用示例:

        $ virtualenv --no-site-packages venv        # 创建虚拟环境
        $ source venv/bin/active 				    # 进入虚拟环境
        (venv) $ deactivate 						# 退出虚拟环境

3. 命令管理 virtualenvwrapper: 

        $ mkvirtualenv ENV                      : 创建运行环境ENV
        $ rmvirtualenv ENV                      : 删除运行环境ENV
        $ mkproject mic                         : 创建mic项目和运行环境mic
        $ mktemenv 		                        : 创建临时运行环境
        $ workon bsp 		                    : 工作在bsp运行环境
        $ lsvirtualenv 	                        : 列出可用的运行环境
        $ lssitepackages 	                    : 列出当前环境安装了的包
        $ source /path/ENV_NAME/bin/active      : 进入ENV_NAME虚拟环境

4. 添加钩子

### 5. 语义化版本
语义化版本(Semantic Versioning, SEMVER), 版本格式为: `主版本号.次版本号.修订号`, 版本号递增规则如下:

- 主版本号(MAJOR) : 增加不兼容 API 修改.
- 次版本号(MINOR) : 相后兼容的功能性新增.
- 修订版本号(PATCH) : 向后兼容的问题修正.

