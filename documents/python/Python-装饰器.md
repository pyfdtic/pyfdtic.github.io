---
title: Python-装饰器
date: 2018-03-15 15:37:04
categories:
- Python
tags:
- python 装饰器
---
摘要
<!-- more -->
装饰器通常是一个命名的对象(不允许 lambda 表达式), 在被(装饰函数)调用时接受单一参数, 并返回另一个可调用对象. 这里的可调用对象, 不仅仅包含函数和方法, 还包括类. 任何可调用对象(任何实现了 __call__ 方法的对象都是可调用的)都可用作装饰器, 他们返回的对象也不是简单的函数, 而是实现了自己的 __call__ 方法的更复杂的类实例.

    @some_decorator
    def decorated_function():
        pass

    # 以上写法总是可以替换为显式的装饰器调用和函数的重新赋值:

    decorated_function = some_decorator(decorated_function)   

### 1. 装饰器定义/使用方法

#### 1.1 通用模式: 作为一个函数
    
    def mydecorator(function):
        def wrapped(*args, **kwargs):
            # 在函数调用之前, 做点什么
            result = function(*args, **kwargs)
            # 在函数调用之后, 做点什么

            # 返回结果
            return result

        # 返回 wrapper 作为装饰函数
        return wrapped

#### 1.2 实现 __call__ 方法: 作为一个类

非参数化装饰器用作类的通用模式如下:
    
    class DecoratorAsClass:
        def __init__(self, function):
            self.function = function

        def __call__(self, *args, **kw):
            # 在调用原始函数之前, 做点什么
            result = self.function(*args, **kwargs)

            # 在调用原始函数之后, 做点什么

            # 返回结果
            return result

#### 1.3 参数化装饰器 : 实现第二层包装
    
    def repeat(number=3):
        """
        多次重复执行装饰函数, 
        返回最后一次原始函数调用的值作为结果.
        : param number: 重复次数, 默认值为 3
        """
        def actual_decorator(function):
            def wrapped(*args, **kwargs):
                result = None
                for _ in range(number):
                    result = function(*args, **kwargs)
                return result

            return wrapped
        return actual_decorator

    @repeat(2)
    def foo():
        print("foo")

带参数的装饰器总是可以做如下装换:
    
    foo = repeat(number=3)(foo)
        
**即使参数化装饰器的参数有默认值, 但名字后面也必须加括号**
    
    @repeat()
    def bar():
        print("bar")


#### 1.4 保存内省的装饰器
使用装饰器的常见缺点是: 使用装饰器时, 不保存函数元数据(主要是文档字符串和原始函数名). 装饰器组合创建了一个新函数, 并返回一个新对象, 完全没有考虑原函数的标志. 这将导致调试装饰器装饰过的函数更加困难, 也会破坏可能用到的大多数自动生产文档的工具, 应为无法访问原始的文档字符串和函数签名.

解决这个问题的方式, 就是使用 `functools` 模块内置的 `wraps()` 装饰器.
    
    from functools import wraps

    def preserving_decorator(function):
        @wraps(function)
        def wrapped(*args, **kwargs):
            """包装函数内部文档"""
            return function(*args, **kwargs)

        return wrapped

    @preserving_decorator
    def function_with_important_docstring():
        """这是我们想要保存的文档字符串"""
        pass

    print(function_with_important_docstring.__name__)
    print(function_with_important_docstring.__doc__)

### 2. 装饰器常用示例
#### 2.1 参数检查

检查函数接受或返回的参数, 在特定上下文中执行时可能有用.
    
    # 装饰器代码
    rpc_info = {}   # 在实际读取时, 这个类定义会填充 rpc_info 字典, 并用于检查参数类型的特定环境中.

    def xmlrpc(in_=(), out=(type(None), )):
        def _xmlrpc(function):
            # 注册签名
            func_name = function.__name__
            rpc_info[func_name] = (in_, out)

            def _check_types(elements, types):
                """用来检查类型的子函数"""
                if len(elements) != len(types):
                    raise TypeError("Argumen count is wrong")

                typed = enumerate(zip(elements, types))

                for index, couple in typed:
                    arg, of_the_right_type = couple
                    if isinstance(arg, of_the_right_type):
                        continue
                    raise TypeError("Arg #%d should be %s" % (index, of_the_right_type))

            def __xmlrpc(*args):    # 没有允许的关键词
                # 检查输入的内容
                if function.__class__ == "method":
                    checkable_args = args[1:]   # 类方法, 去掉 self
                else:
                    checkable_args = args[:]    # 普通函数
                _check_types(checkable_args, in_)

                # 运行函数
                res = function(*args)

                # 检查输入内容
                if not type(res) in (tuple, list):
                    checkable_res = (res, )
                else:
                    checkable_res = res

                _check_types(checkable_res, out)

                # 函数机器类型检查成功
                return res

            return __xmlrpc
        return _xmlrpc


    # 使用示例
    class RPCView:
        @xmlrpc((int, int))     # two int --> None
        def meth1(self, int1, int2):
            print("received %d and %d" % (int1, int2))

        @xmlrpc((str, ), (int, ))   # string --> int
        def meth2(self, phrase):
            print("received %s" % phrase)
            return 12

    # 调用输出
    print(rpc_info) 
    # 输出:
    # {'meth1': ((<class 'int'>, <class 'int'>), (<class 'NoneType'>,)), 'meth2': ((<class 'str'>,), (<class 'int'>,))}

    my = RPCView()
    my.meth1(1, 2)
    # 输出: 类型检查成功
    # received 1 and 2

    my.meth2(2)
    # 输出: 类型检查失败
    #   File "D:\VBoxShare\Work\Documents\PyProject\PyCookbook\test.py", line 57, in <module>
    #     my.meth2(2)
    #   File "D:\VBoxShare\Work\Documents\PyProject\PyCookbook\test.py", line 25, in __xmlrpc
    #     _check_types(checkable_args, in_)
    #   File "D:\VBoxShare\Work\Documents\PyProject\PyCookbook\test.py", line 20, in _check_types
    #     raise TypeError("Arg #%d should be %s" % (index, of_the_right_type))
    # TypeError: Arg #0 should be <class 'str'>

#### 2.2 缓存
缓存装饰器与参数检查十分相似, 不过他重点是关注那些内容状态不会影响输入的函数, 每组参数都可以链接到唯一的结果. 因此, 缓存装饰器可以将输出与计算法所需的参数放在一起, 并在后续的调用中直接返回他(这种行为成为 memoizing).

    import time
    import hashlib
    import pickle

    cache = {}

    def is_obsolete(entry, duration):
        return time.time() - entry["time"] > duration

    def compute_key(function, args, kw):
        """ 利用已排序的参数来构建 SHA 哈希键, 并将结果保存在一个全局字典中.
        利用 pickle 来建立 hash , 这是冻结所有作为参数传入的对象状态的快捷方式, 以确保所有参数都满足于要求.
        """
        key = pickle.dumps((function.__name__, args, kw))
        return hashlib.sha1(key).hexdigest()

    def memoize(duration=10):
        def _memoize(function):
            def __memoize(*args, **kw):
                key = compute_key(function, args, kw)

                # 是否已经拥有它了?
                if (key in cache and not is_obsolete(cache[key], duration)):
                    print("We got a winner.")
                    return cache[key]["value"]

                # 计算
                result = function(*args, **kw)

                # 保存结果
                cache[key] = {
                    "value": result,
                    "time": time.time()
                }

                return result
            return __memoize
        return _memoize

    @memoize()
    def func_1(a, b):
        return a + b

    print(func_1(2, 2))     # 4
    print(func_1(2, 2))     # print , 4

    @memoize(1)
    def func_2(a, b):
        return a + b

    print(func_2(2, 2))     # 4
    time.sleep(1)
    print(func_2(2, 2))     # 4

缓存值还可以与函数本身绑定, 以管理其作用域和生命周期, 代替集中化的字典. 但在任何情况下, 更高效的装饰器会使用基于高级缓存算法的专用缓存库.

#### 2.3 代理
代理装饰器使用全局代理来标记和注册函数. 例如, 一个根据当前用户来保护代码访问的安全层可以使用集中式检查器和相关的可调用对象要求的权限来实现.

    class User:
        def __init__(self, roles):
            self.roles = roles

    class Unauthorized(Exception):
        pass

    def protect(role):
        def _protect(function):
            def __protect(*args, **kw):
                user = globals().get("user")
                if user is None or role not in user.roles:
                    raise Unauthorized("I won't tell you.")

                return function(*args, **kw)
            return __protect
        return _protect


    tarek = User(("admin", "user"))    
    bill = User(("user",))

    class MySecrets:
        @protect("admin")
        def waffle_recipe(self):
            print("use tons of butter")    

    these_are = MySecrets()

    user = tarek
    these_are.waffle_recipe()   # use tons of butter

    user = bill
    these_are.waffle_recipe()   # __main__.Unauthorized: I won't tell you.

以上模型常用于 Python Web 框架中(权限验证), 用于定义可发布类的安全性. 例如, Django 提供装饰器来保护函数访问的安全.

#### 2.4 上下文提供者

上下文装饰器确保函数可以运行在正确的上下文中, 或者在函数前后运行一些代码, 换句话说, 他设定并复位一个特定的执行环境. 

例如, 当一个数据项需要在多个线程之间共享时, 就要用一个锁来保护她避免多次访问, 这个锁可以在装饰器中编写.

    from threading import RLock
    lock = RLock()

    def synchronized(function):
        def _synchronized(*args, **kw):
            lock.acquire()

            try:
                return function(*args, **kw)
            finally:
                lock.release()
            
        return _synchronized

    @synchronized
    def thread_safe():  # 确保锁定资源
        pass

上下装饰器通常会被上下文管理器(with) 替代.