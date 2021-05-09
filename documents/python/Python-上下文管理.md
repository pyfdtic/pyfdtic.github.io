
## 1. 编写实现上下文管理器

### 1.1 作为一个类: 上下文管理协议

任何实现了 **上下文管理协议**的对象都可以用作上下文管理器. 该协议包含两个特殊方法:

- `__enter__(self)` : 调用该方法, 任何返回值都会绑定到指定的 as 语句.

- `__exit__(self, exc_type, exc_value, traceback)` : 接受代码块中出现错误时填入的 3 个参数. 如果没有错误, 三个都为 None. 出现错误时, `__exit__` **不应该重新引发这个错误**, 因为这是调用者(caller) 的责任. 但他可以通过返回 True 来避免引发异常. 多数情况下, 这一方法只是执行一些清理工作, 无论代码块中发生什么, **他都不会返回任何内容**.

代码示例: 

    class ContextIllustration:
        def __enter__(self):
            print("entering context")

        def __exit__(self, exc_type, exc_value, traceback):
            print("leveling context")

            if exc_type is None:
                print("With no ERROR")
            else:
                print("With an ERROR (%s)" % exc_value)

    with ContextIllustration():
        print("inside")            

    # 输出:
    # entering context
    # inside
    # leveling context
    # With no ERROR

    with ContextIllustration():
        raise RuntimeError("Raised within 'with'")    
    # 输出:
    # entering context
    # leveling context
    # With an ERROR (Raised within 'with')
    # Traceback (most recent call last):
    #   File "D:\VBoxShare\Work\Documents\PyProject\PyCookbook\test.py", line 23, in <module>
    #     raise RuntimeError("Raised within 'with'")    
    # RuntimeError: Raised within 'with'    

通过返回 `True` 来避免触发异常:

    class ContextIllustration:
        def __enter__(self):
            print("entering context")

        def __exit__(self, exc_type, exc_value, traceback):
            print("leveling context")

            if exc_type is None:
                print("With no ERROR")
            else:
                print("With an ERROR (%s)" % exc_value)

            return True    



    with ContextIllustration():
        raise RuntimeError("Raised within 'with'")  

    # 输出: 
    # entering context
    # leveling context
    # With an ERROR (Raised within 'with')

### 1.2 作为一个函数: contextlib 模块

标准库 contextlib 提供了与上下文管理器一起使用的辅助函数: `contextmanager`, 他可以在一个函数里同时提供 `__enter__` 和 `__exit__` 两部分, 中间用 `yield` 分开(函数变成了生成器).

    from contextlib import contextmanager

    thelist = [1, 2, 3]

    @contextmanager
    def ListTransaction(thelist):
        workingcopy = list(thelist)
        yield workingcopy

        # 尽在没有出现错误时才会修改原始列表.
        thelist[:] = workingcopy


    with ListTransaction(thelist) as l:
        print(l)
        print(type(l))

传递给 `yield` 的值, 用作 `__enter__()` 方法的返回值, 调用 `__exit__()` 方法时, 执行将在 yield 语句后恢复. 如果上下文中出现异常, 他将以异常形式出现在生成器函数中.如有需要可以捕获异常, 以上例子中, 异常被传递出生成器, 并其他地方进行处理.

**如果出现任何异常, 被装饰函数需要再次抛出异常, 以便传递异常**

    from contextlib import contextmanager

    @contextmanager
    def context_illustration():
        print("Entering context")

        try:
            yield
        except Exception as e:
            print("Leaving context")
            print("with an ERROR (%s)" % e)

            # 抛出异常
            raise
        else:
            print("Leaving context")
            print("with no error")

    with context_illustration():
        print("Entering")

    # 输出: 
    # Entering context
    # Entering
    # Leaving context
    # with no error

    with context_illustration():
        raise RuntimeError("MyError")        
    # 输出: 
    # Entering context
    # Traceback (most recent call last):
    #   File "D:\VBoxShare\Work\Documents\PyProject\PyCookbook\test.py", line 18, in <module>
    # Leaving context
    # with an ERROR (MyError)
    #     raise RuntimeError("MyError")        
    # RuntimeError: MyError

`contextlib` 还提供其他三个辅助函数:
- `closing(element)` : 返回一个上下文管理器, 在退出时, 调用该元素的 `close()` 方法, 对处理流的类很有用.
- `supress(*exceptions)` : 他会压制发生在 with 语句正文中的特定异常.
- `redirect_stdout(new_target)` : 将代码内任何代码的 sys.stdout 输出重定向到类文件(file-like)对象的另一个文件.
- `redirect_stderr(new_target)` : 将代码内任何代码的 sys.stderr 输出重定向到类文件(file-like)对象的另一个文件.

## 2. 使用方式
1. 基本使用
    
        with context_manager:
            # code here
            ...
    
2. 上下文变量: 使用 as 语句保存为局部变量
    
    ` __enter__()` 的任何返回值都会绑定到指定的 as 子句.
        
        with context_manager as context:
            # code here
            ...

3. 多个上下文管理器(嵌套)
    
        with A() as a, B() as b:
            # code here
            ...

    等价于嵌套使用:

        with A() as a:
            with B() as b:
                # code here
                ...