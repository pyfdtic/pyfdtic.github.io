---
title: python-资源汇总
date: 2018-03-16 17:21:01
categories:
- Python
tags:
---
python 最佳实践 (部分)

# 一. 结构化工程

| 文件    | 功能    |
| ---       | ---   |
| README.rst          | readme |
| LICENSE             | 许可证 |
| setup.py            | 打包和发布管理 |
| requirements.txt    | 开发依赖 |
| sample/__init__.py  | 核心代码 |
| sample/core.py      | 核心代码 |
| sample/helpers.py   | 核心代码 |
| docs/conf.py        | 文档 |
| docs/index.rst      | 文档  |
| tests/test_basic.py | 单元测试 |
| tests/test_advanced.py | 单元测试 |

# 二. 开发环境

## vim : 
    python-mode : 在 vim 中使用 Python 的综合解决方案.
    SuperTab : vim 小插件, 通过使用 <tab> 或任何其他指定的按键, 能够使代码补全变得更方便.
## Sublime Text 
## PyCharm 

# 三. 虚拟环境
    virtualenv : 
    [virtualenvwrapper](http://virtualenvwrapper.readthedocs.io/en/latest/index.html) : 命令的完整列表(http://virtualenvwrapper.readthedocs.io/en/latest/command_ref.html)        
    [virtualenv-burrito](https://github.com/brainsik/virtualenv-burrito) : 能使用单行命令拥有 virtualenv + virtualenvwrapper 的环境.
    [autoenv](https://github.com/kennethreitz/autoenv) : 当 cd 进入一个包含 .env 的目录中, 就会自动激活那个环境.

# 四. 文档


### pydoc : 在安装 python 时自动安装的 工具, 允许在 shell 中快速检索文档, 

    $ pydoc time    # 查看 time 模块的文档.


# 五. PEP8 : Python 事实上的代码风格指南.

### pep8 : 检查代码的一致性.
    $ pip install pep8
    $ pep8 optparse.py     # 检查文件是否符合 PEP8 规范

### autopep8 : 自动格式化为 PEP8 风格
    $ autopep8 [ARGS] optparse.py   # 无参数, 则程序直接将更改的代码输出到控制台.
        --in-place      # 直接修改文件.
        --aggressive    # 执行更多实质性的变化, 可以执行多次, 已达到最佳效果.

# 六. 解包

### 交换变量 : 

    a,b = b,a

### 嵌套解包:

    a, (b,c) = 1, (2,3)

### 扩展解包: python 3

    a, *rest = range(10)        # a = 0, rest = [1, 2, 3, 4, 5, 6, 7, 8, 9]  
    a, *middle, c = range(11)   # a = 0, middle = [1, 2, 3, 4, 5, 6, 7, 8, 9], c = 10

### 创建一个被忽略的变量:

    filename = 'foobar.txt'
    basename,_,ext = filename.rpartition(".")

### 创建一个包含 N 个对象的列表:

    >>> four_none = [None]*4
    >>> four_none
    [None, None, None, None]
    >>> four_one = [1]*4
    >>> four_one
    [1, 1, 1, 1]        

### 创建一个包含 N 个列表的列表

    four_list = [[] for _ in xrange(4)]
    

# 七. 约定 pythonnic
## 检查变量是否等于常量 : 比较一个值是 True, None,False, 0 等 : 使用 if

        if attr :
            print "attr is truthy."

        if not attr:
            print "attr is falsey."

        # since None is considered false , explicitly check for it .
        if attr is None:
            print "attr is None."


## 访问字典元素:

    x in d
    dict.get() 

示例: 

    d = {"hello": "world"}

    print d.get("hello", "default_value")   # "world"
    print d.get("thingy", "default_value")  # "default_value"

    if  "hello" in d:
        print d["hello"]

## 维护列表的捷径:

列表推导
map()
filter()
enumerate() : 或得列表中当前位置的计数.

示例:

    # 过滤大于 4 的元素

    # 列表推到
    a = range(10)
    b = [i for i in a if i > 4]
    
    # filter
    b = filter(lambda x: x > 4, a)

    # 列表的每个元素 + 3
    
    # 列表推导
    a = range(10)
    a = [i + 3 for i in a]

    # map
    a = map(lambda x: x + 3, a)

## 读取文件:  with open

    with open('file.txt') as f:
        for line in f:
            print line

## 行的延续: 当一个代码逻辑行的长度超多可接受的限制时, 需要将至分为多个物理行.
    使用括号.

    my_very_big_line = (
        "for a long time i used to go to bed early. Sometime ,"
        "when i had put out my candle , my eyes would close so quickly"
        "That i had not even time to say 'I'm going to sleep.' "
    )

    from some.deep.module.inside.a.moule import (
        a_nice_function, another_nice_function, yet_another_nice_function )


# 九. 密码学

[Cryptography](https://cryptography.io/en/latest/) : 提供了加密方法 recipes 和 primitives . Cryptography 分为两个层, 方法(recipes, 提供用于对称加密) 和 危险底层(hazardous materials,简称 hazmat, 提供底层的加密基元).
[PyCrypto](https://www.dlitz.net/software/pycrypto/) : 提供安全的 哈希函数和各种加密算法.


# 十. 命令行应用

[Clint](https://pypi.python.org/pypi/clint/) : 是一个Python模块，它包含了很多 对命令行应用开发有用的工具。它支持诸如CLI着色以及缩进，简洁而强大的列打印， 基于进度条的迭代以及参数控制的特性。
[Click](http://click.pocoo.org/) : 它创建了一个命令行接口, 可以尽可能的简化组合代码。命令行接口创建工具（“Command-line Interface Creation Kit”,Click） 支持很多配置但也有开箱可用的默认值设定。
[docopt](http://docopt.org/) : 是一个轻量级，高度Pythonic风格的包，它支持 简单而直觉地创建命令行接口，它是通过解析POSIX-style的用法指示文本实现的。
[Plac](https://pypi.python.org/pypi/plac) : Python标准库 argparse [http://docs.python.org/2/library/argparse.html] 的简单封装，它隐藏了大量声明接口的细节：参数解析器是被推断的，其优于写命令明确处理. 这个模块的面向是不想太复杂的用户，程序员，系统管理员，科学家以及只是想写个只运行一次的脚本的人们，使用这个命令行接口的理由是它可以快速实现并且简单。
[Cliff](http://docs.openstack.org/developer/cliff/) : 是一个建立命令行程序的框架。 它使用setuptools入口点（entry points）来提供子命令，输出格式化，以及其他的扩展。这个框架 可以用来创建多层命令程序，如subversion与git，其主程序要进行一些简单的参数解析然后调用 一个子命令干活。


# 十一. 阅读代码

[Howdoi](https://github.com/gleitz/howdoi)  : 代码搜寻工具
[flask](https://github.com/mitsuhiko/flask)   : 基于 Werkzeug 和 Jinja2 , 使用 Python 的微框架.
[Diamond](https://github.com/python-diamond/Diamond) : Python 的守护进程, 收集指标, 并将它们发布至 Graphite 或其他后端. 能收取 CPU,内存,网络,IO,负载和硬盘指标, 拥有实现自定义收集器的API, 该 API 几乎能从任何资源中获取指标.
[Werkzeug]()    : WSGI 实用模型.包括强大的调试器，功能齐全的请求和响应对象，处理entitytags的HTTP工具，缓存控制标头，HTTP数据，cookie处理，文件上传，强大的URL路由系统和一些社区提供的插件模块。   

# 十二. 测试

### 通用规则 : 

- 测试单元应该集中于小部分的功能, 并且证明他是对的.
- 每个测试单元都应该完全独立. 每个都能独立运行, 除了调用的命令, 都需在测试套件中. 测试单元应该加载最新的数据集, 之后在做一些清理. 如 setUp() 和 tearDown() 方法.
- 尽量使单元测试快速运行.
- 实现钩子(hook) 是一个非常好的主意. 因为一旦将代码放入仓库, 这个钩子可以运行所有的测试单元.
- 当调试代码的时候, 需要首先写一个精确定位 bug 的测试单元.
- 测试函数使用长且描述性的名字.

### 单元测试
[unittest](http://docs.python.org/library/unittest.html#module-unittest)
    unittest.TestCase

[doctest]() 文档测试. 模块查找零碎文本, 就像 Python 中 docstrings 内的交互式会话, 执行那些会话以正式工作正常.

[Nose](http://readthedocs.org/docs/nose/en/latest/) : 
    nose 集成测试单元, 能使测试更加容易.
    自动化测试, 发现并节省人工创建测试组件的麻烦

[tox](http://testrun.org/tox/latest/) : 自动化测试管理和针对多种解释器配置测试工具.

[mock](https://docs.python.org/dev/library/unittest.mock) : 测试库. unittest.mock 是 python 中用于测试的一个库.

# 十三. 持续集成
[Jenkins](http://jenkins-ci.org) : 可扩展的持续集成引擎。
[Tox](http://tox.readthedocs.org/en/latest/) : 是一款为Python软件提供打包、测试和 开发的自动化工具，基于命令行或CI服务器。它是一个通用的虚拟环境管理和测试的命令行 工具