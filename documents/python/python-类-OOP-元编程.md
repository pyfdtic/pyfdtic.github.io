---
title: python 类, OOP 与 元编程
date: 2018-03-13 10:59:21
categories:
tags:
---
Python 

闭合(clusure)/工厂函数 : 一个能够记住嵌套作用域的变量值得函数, 尽管那个作用域或许已经不存在了.


python 保持状态信息的方法:

1. 全局变量
2. 非本地变量 nonlocal
3. 类属性
4. 函数属性

# 函数
## 1. 函数作用域

## 2. 函数参数
函数参数匹配表:

| 语法 | 位置 | 解释 |
| --- | --- | --- |
| func(value) | 调用者 | 常规参数: 通过位置进行匹配 |
| func(name=value) | 调用者 | 关键字参数, 通过变量名进行匹配 |
| func(*sequence) | 调用者 | 以 name 传递所有的对象, 并作为独立的基于位置的参数 |
| func(**dict) | 调用者 | 以 name 成对的传递所有的关键字/值, 并作为独立的关键字参数 |
| def func(name) | 函数 | 常规参数, 通过位置或变量名进行匹配 |
| def func(name=value) | 函数 | 默认参数值, 如果没有在调用中传递的话 |
| def func(*name) | 函数 | 匹配并收集(在元组中)所有包含位置的参数 |
| def func(**name) | 函数 | 匹配并收集(在字典中)所有包含位置的参数 |
| def func(*args,name) , def func(*, name=value)  | 函数 | 参数必须在调用中按照关键字传递( Python 3.0) |

**name=value 的形式在调用时和 def 中有两种不同的含义. 在调用中代表关键字参数, 在函数头部代表默认值参数**

参数顺序:

1. 在函数调用中, 参数必须以如下顺序出现:
	
	位置参数 , 关键字参数, `*sequence`, `**dict`

2. 在函数定义中, 参数必须以如下顺序出现:
	
	一般参数 , 默认参数, `*name`, `name` 或 name=value keyword-only 参数, `**name` 参数

## 3. 高阶函数
### 3.1 递归



### 3.2 函数对象
#### 1. 间接调用
```
def echo(msg):
    print msg

schedule = [(echo, "SPAM"), (echo, "HAM")]
for (func, arg) in schedule:
    func(arg)

# 偏函数
def make(lable):
    def echo(msg):
        print lable + ":" + msg
    return echo

f = make("SPAM")
f("HAM")
```
#### 2. 函数内省
```
f.__name__
dir(f)

f.__code__
dir(f.__code__)
f.__code__.co_varnames
f.__code__.co_argcount
```
#### 3. 函数属性

函数属性可以用来直接把状态信息附加到函数对象, 而不必使用全局,非本地,类等其他技术. 
函数属性可以在函数的任何地方访问, 也是模拟其他语言中"静态本地变量"的一种方式: 这种变量的名称对于一个函数来说是本地的, 但是, 其值在函数退出后仍然保留. 
函数属性与对象相关, 而不是与作用域相关.
```
f.age = 12
f.age += 11
f.job = "manager"
dir(f)
```

#### 4. python 3.0 函数注解
在 Python 3.0 中可以给函数对象添加注释信息 -- 与函数的参数和结果相关的任意用户自定义数据. 注解本身是可选的, 并且自身不做任何事情, 当使用注解时, 他将直接附加到函数的 `__annotations__` 属性, 供其他用户使用.

```
语法: 函数注解编写在 def 头部行, 
- 参数 :紧随参数名之后的冒号之后, 并且出现在函数默认值之**前**;
- 返回值 : 编写与紧跟在参数列表之后的一个 `->` 之后.

def func(a: "SPAM" = 4, b: (1,10) = 5, c: float = 6) -> int:
    return a + b + c

func(1,2,3)     # 6
func()          # 15
func(1, c=10)   # 16
func.__annotations__    # {"a": "SPAM", "b": (1,10), "c": <class 'float'>, "return": <class 'int'>}
```
调用一个注解过的函数, 与普通函数无异. 但, 当注解被定义的时候, Python 将其收集到 `FUNC.__annotations__` 字典, 并将它附加给函数对象本身. 参数名变成键. 如果编写了返回值注解, 键为 'return'.

由于注解只是附加到一个 python 对象的python 对象, 注解可以直接处理.


注解可以用作参数类型或值得限制, 并且较大的 API 可能使用这一功能作为注册函数接口信息的方式.

**注解只在 def 语句中生效, 在 lamdba 表达式中无效**


### 3.3 匿名函数 lambda
lamdba 是一种生成函数对象的表达式形式. 这个表达式创建了一个之后能调用的函数, 但是他返回一个函数而**不是将这个函数赋值给一个变量名**, 这也是 lambda 被称为匿名函数(没有函数名)的原因.

- lambda 是一个表达式, 而不是一个语句;
- lambda 的主体是一个单个的表达式, 而不是一个代码块.

在 lambda 主体中大代码遵循与 def 定义函数相同的作用于查找法则, LEGB.
```
L = [ lambda x : x**2, lambda x: x ** 3, lambda x : x ** 4]
for i in L:
    print i(2)      # 4,8,16

# f 被赋值给一个 lambda 表达式创建的函数对象.
f = lambda x,y,z : x + y + z

# lamdba 支持默认参数:
x = (lamdba a="fee", b="fie", c="foe": a + b + c)

# 两个数中, 取最小值.
lower = (lambda x,y: x if x < y else y)
```
### 3.4 函数式编程

函数式编程就是对**序列**应用一些函数的工具.

在 python 3 中, map 和 filter 都返回**可迭代**对象.

#### map
map 函数会对一个序列对象中每一个元素应用被传入的函数, 并且返回一个包含了所有函数调用结果的一个列表.

**在 Python 3 中, map 是一个可迭代对象**    
```
# 普通定义形式
def inc(x):
    return x + 10
map(inc, range(1,5))

# lambda 定义形式
map(lambda x : x + 10, range(1,5))

# 在 python 3 中
list(map(inc, range(1,5)))
list(map(lambda x : x + 10, range(1,5)))
```

高级用法: 多个序列时, map 期待一个 N 参数的函数用于 N 序列.
```
pow(3,4)    # 81
map(pow, [1,2,3], [2,3,4])  # 1,8,81
```
#### filter(func, list)
对于 list 中的每个元素, 作为参数传入 func 中, 并将所有 func 返回真的 元素, 加入到 结果列表中返回.
```
# 返回列表中, 所有大于 0 的值.
filter(lambda x : x > 0, range(-5,5))

# python 3 中
list(filter(lambda x : x > 0, range(-5,5)))
```
#### reduce(func, list)

reduce 中的 func 接受两个参数, 并返回一个结果. 首先将 func 用于 list 中的前两个元素, 然后将返回的结果与list 中的下一个元素, 作为参数, 再次传入 func, 依次类推. 最后返回一个单个元素的结果.

reduce 接受一个迭代器来处理, 但是, 他本身并不是迭代器, 而是返回单个结果.

**在 python 3 中, 需要从 functools 中导入**.    
```
# python 3 
from functools import reduce
reduce((lambda x, y : x + y), range(1,5))   # 10

# python 2.6
reduce((lambda x, y : x + y), range(1,5))
```
---------------------------------------
# 迭代和解析


---------------------------------------
# 模块
模块和模块包是 python 中程序代码重用的最高层次.

## import: 导入:
在 Python 中导入并非只是把一个文件文本插入另一个文件而已, 导入其实是运行时的运算, 会执行如下三个步骤:
1. 找到模块文件 --> 标准模块搜索路径.
2. 编译成位码
    
    python 检查文件的时间戳, 如果发现字节码文件比源代码文件旧, 就会在程序运行时自动重新生成字节代码. 如果发现 字节码文件不比源码文件旧, 则跳过编译步骤, 直接加载 pyc 字节码文件.

    当文件导入时, 就会进行编译. 因此通常不会看到顶层文件的字节码文件, 除非顶层文件也被其他文件导入: 只有被导入的文件才会在机器上留下字节码 .pyc 文件. 顶层文件的字节码时在内存中使用后就丢弃了; 被导入文件的字节码则保存在文件中从而可以提高之后导入的运行速度.

3. 执行模块的代码来创建其所定义的对象.

这三个步骤只在程序执行时, 模块第一次导入时才会运行. 之后, 导入相同模块时, 会跳过三个步骤, 而只是提取内存中已加载的模块对象.

Python 把载入的模块存储到一个名为 sys.modules 的表中, 并在一次导入操作的开始检查该表, 如果模块不存在, 才会启动上面的三个步骤.

## 模块搜索路径
1. 程序主目录
2. PYTHONPATH 目录(如果有定义)
3. 标准链接库目录
4. 任何 .pth 文件的内容(如果存在)

打印模块搜索路径:
```
import sys
print sys.path                  # 导入操作, 会从左自右搜索列表中的每一个目录
sys.path.append(dirname)        # 添加新的目录
```
## 模块文件选择:
- 源代码文件 .py
- 字节码文件 .pyc
- 目录, 包导入
- 编译扩展模块(通常使用C 或 C++ 编写), 导入时使用动态链接.
- 用 C 编写的编译好的内置模块, 并通过静态链接至python
- zip 文件组, 导入时会自动解压
- 内存内映像, 对于 frozen 可执行文件
- java 类, 在 Jython 版本的 python 中.
- .NET 组件, 在 IronPython 版本的 python 中.

## 导入钩子
用于重新定义 import 操作所做的事, 如从归档中加载文件, 执行解密.
使用 __import__ 函数, 订制 import 操作.

## distutils
Python 的第三方扩展, 通常是会用 distutils 工具自动安装.

distutils 自带 setup.py 脚本, 该脚本导入并使用 distutils 模块, 将该扩展放在属于模块自动搜索路径一本的目录内, 通常为 Lib/site-pacgages 子目录中.

第三方开源的 eggs 系统, 功能更强大, 增加了对已安装的 python 软件的依存关系的检查.


# OOP
类也是命名空间.

类与模块的不同:
1. 支持多个对象的产生
2. 命名空间继承
3. 运算符重载.
    运算符重载就是让用类写成的对象, 可截获并响应用在内置类型上的运算: 加法, 切片,打印, 点号运算符等. 

    以上只是自动分发机制: 表达式和其他内置运算流程需要经类的实现来控制.

    运算符只是表达式对方法的分发机制.

    运算符重载时可选的功能, 主要是替其他 Python 程序员开发工具的人在使用, 而不是那些应用程序开发人员在使用.

    1. 以双下划线命名的方法(__xx__) 是特殊钩子. Python 为每种运算和特殊命名的方法之间, 定义了固定不变的映射关系.
    
    2. 当时李出现在内置运算时, 这类方法会自动调用. 

    3. 类可覆盖多数内置类型运算.有几十种特殊运算符重载的方法的名称, 几乎可截获并实现内置类型的所有运算, 他不仅包括了表达式, 而且打印和对象建立这类基本运算也包含在内.

    4. 运算符覆盖方法没有默认值, 而且也不需要. 如果类没有定义或继承运算符重载方法, 就是说相应的运算在类实例中并不支持. 例如, 如果类没有定义 __add__ 方法, 则 + 表达式就会引发异常.

    5. 运算符可让类与 python 的对象模型相继承. 重载类型运算时, 以类实现的用户定义对象的行为就会像内置对象一样, 因此, 提供了一致性, 以及与预期接口的兼容性.


类对象和实例对象:
1. 类对象提供默认行为, 是实例对象的工厂. 实例对象是程序处理的实际对象: 各自都有独立的命名空间, 但是继承(可自动存取)创建该实例的类中的变量名.
2. 类对象来源于语句, 而实例来自于调用.


类对象提供默认行为:
1. class 语句创建类对象并将其赋值给变量名.
2. class 语句内的赋值语句会创建类的属性.
    
    class 语句的作用域会变成类属性的命名空间.

3. 类属性提供对象的状态和行为.
    
    类对象的属性记录状态信息和行为, 可由这个类所创建的所有实例共享.


实例对象是具体的元素:
1. 像函数那样调用类对象会创建新的实例对象.
2. 每个实例对象继承类的属性并获得自己的命名空间.
3. 在方法内对 self 属性做赋值运算会产生每个实例自己的属性.


**重载**在类的继承树中较低处发生的重新定义的, 取代属性的行为.

命名空间对象的属性通常都是以字典的形式实现的, 而类继承树(一般而言)只是连接至其他字典的字典而已.

__dict__ 属性是针对大多数大多数基于类的对象的命名空间字典(一些类也可能用 __slots__ 中定义了的属性, 这是一个高级而少用的功能)

python 在内存中类树常量的表示方法:
1. __class__ : 查看当前**实例**的父类.
2. __bases__ : 查看当前**类**的父类的元组.


Python 的 OOP 其实就是在已连接命名空间内寻找属性而已. 

方法函数中的特殊 self 参数和 __init__ 构造函数是 Python 的 OOP 的两个基石.



## 27 更多实例
构造函数
行为方法
运算符重载
子类
```
类方法总是可以在一个实例中调用(这是通常方法, python 自动把该实例发送给 self 参数), 或者通过类来调用(较少见的方式, 其中我们必须手动的传递实例).

如下的常规方法调用:
    instance.method(args ...)
由 python 自动转换为如下的同等形式:
    class.method(instance, args ...)

class Person:
    def __init__(self, name, job=None, pay=0):
        self.name = name
        self.job = job
        self.pay = pay

    def get_raise(self, percent):
        self.pay = self.pay * (1 + percent)    

class Manager(Person):
    def get_raise(self, percent, bonus=0.1):
        Person.get_raise(self, percent + bonus)
```
订制构造函数
内省工具
将对象存储到数据库中

Python OOP 的重要概念:
1. 实例创建 --> 填充实例属性
2. 行为方法 --> 在类方法中封装逻辑
3. 运算符重载 --> 为打印这样的内置操作提供行为
4. 订制行为 --> 重新定义子类中的方法以使其特殊化.
5. 订制构造函数 --> 为超类步骤添加初始化逻辑
6. 装饰器和元类
7. 内省工具

`_METHODNAME` : 用于不想做其他用途的方法.
`__METHODNAME` : Python 自动扩展 包含 `__` 前缀的方法, 以包含类的名称, 从而使他们变得整整唯一. 该功能称为 "伪私有类属性".

## 28 代码编写细节:
class 语句

方法
继承
    属性树的构造
    继承方法的专有化
    类接口技术

    ```
    class Super:
        def method(self):
            print "In Super.method"

        def delegate(self):
            self.action()


    class Inheritor(Super):
        pass


    class Replacer(Super):
        def method(self):
            print "In Replacer Method"


    class Extender(Super):
        def method(self):
            print "Starting Extender.method"
            Super.method(self)
            print "Ending Extender.method"


    class Provider(Super):
        def action(self):
            print "In Provider.action"

    if __name__ == "__main__":
        for klass in (Inheritor, Replacer, Extender):
            print "\n" + klass.__name__ + '...'
            klass().method()

        print "\n Provider"
        x = Provider()
        x.delegate()
    ```
    抽象超类 : 类的部分默认行为由其子类所提供. 如上面代码中的 Provider 向其超类 Super 提供 action 方法. 类的编写者, 通常会使用 assert 语言, 使得这种子类需求更为明显, 或者引发内置的异常 NotImplementedError. 即如果子类中没有方法定义来替代超类中的默认方法, 将会得到异常.
    ```
        class Super:
            def delegate(self):
                self.action()

            def action(self):
                assert False, "Action must be defined"


        class Super:
            def delegate(self):
                self.action()

            def action(self):
                raise NotImplementedError("Action must be defined.")
    ```
    抽象超类也可以由特殊的类语法来实现, 其编写方法根据版本不同, 而有所变化.
    ```
        # python 3
        form abc import ABCMeta, abstractmethod
        class Super(metaclass=ABCMeta):
            @abstractmethod
            def method(self):
                pass

        # python 2.6
        class Super:
            __metaclass__ = ABCMeta
            @abstractmethod
            def method(self):
                pass
    ```
    使用这种方式编写的代码, 带有一个抽象方法的类是不能继承的(即, 我们不同通过调用它来创建一个实例), 除非其所有的抽象方法都已经在子类中定义了.
    


命名空间
    简单变量名
    属性名称
    禅: 赋值将变量名分类
    命名空间字典
    命名空间链接

文档字符串
类与模块的关系

## 29 运算符重载
运算符重载只是意味着在类方法中**拦截**内置操作 : 当类的实例出现在内置操作中, Python自动调用重载的方法, 并且该方法的返回值编程了相应操作的结果.
- 运算符重载让类拦截常规的 python 运算.
- 类可重载所有 python 表达式运算符
- 类可重载打印,函数调用,属性点号运算等内置运算.
- 重载使 类实例的行为像内置函数
- 重载使通过提供特殊名称的类方法来实现的.

在类中, 对内置对象(如整数和列表)所能做的事, 几乎都有相应的特殊名称的重载方法.

### 常见运算符重载方法:



### 构造函数和表达式
__init__ : 构造函数
__sub__  : 减法
```
    class Number:
        def __init__(self, start):
            self.data = start

        def __sub__(self, other):
            return Number(self.data - other)

    s = Number(6)
    y = s - 2
    print type(y)
    print y.data
```
### 索引和分片:
#### __getitem__

1. 索引运算:
    ```
    class Indexer:
        def __getitem__(self, index):
            return index ** 2

    X = Indexer()
    print X[2]   
    ```
2. 拦截分片
分片边界绑定到了一个分片对象中, 并且传递给索引的列表实现. 分片语法主要是用一个分片对象进行索引的语法糖.
    ```
    class Indexer:
        data = [5, 6, 7, 8, 9]

        def __getitem__(self, index):
            print "GetItem: ", index
            return self.data[index]

    X = Indexer()       # GetItem:  slice(2, 4, None)
    print X[2:4]        # [7, 8]
    ```
当针对分片调用时, 方法接受一个分片对象, 他在一个新的索引表达式中直接传递给嵌套的列表索引.

#### __setitem__
`__setitem__` 索引赋值方法类似的拦截索引和分片赋值, 他为后者接受了分片对象, 可能一同样的方式传递到另一个索引赋值中.
    ```
    def __setitem__(self, index, value):
        # ...
        self.data[index] = value
    ```

在 Python 3.0 之前, 类也可以定义 `__getslice__` 和 `__setslice__` 方法来专门拦截分片获取和赋值, 他将传递一些列的分片表达式, 并且优先于 `__getitem__` 和 `__setitem__` 用于分片. 但是这些方法已经在 python 3.0 中移除了.


#### __getitem__ : 索引迭代 --> 这种迭代只是迭代的一种退而求其次的方式.
for 循环每次循环是都会调用类的 __getitem__ , 并持续搭配有更高的偏移值. 这是*买一送一*的情况: **任何会响应索引运算的内置或用户定义的对象, 同样会响应迭代**.

任何支持 for 循环的类, 也会自动支持 Python 所有迭代环境, 如 成员关系测试 in , 列表解析, 内置函数 Map, 列表和元组赋值运算及类型构造方法.

在实际应用中, 这个技巧可以用于建立提供序列接口的对象, 并新增逻辑到内置的序列类型运算.
```
    class Stepper:
        def __getitem__(self, i):
            return self.data[i]

    x = Stepper()
    x.data = "spam"
    for item in X:
        print item,     # s p a m
```

### 迭代器对象: __iter__, __next__
迭代环境是通过调用内置函数 iter 去尝试寻找 __iter__ 方法来实现的, 而这种方法应该返回一个迭代器对象. 
如果已经提供了, Python 会重复调用这个迭代器的 next 方法, 知道发生 StopIteration 异常. 
如果没有找到这类 __iter__ 方法, Python 会改用 __getitem__ 机制, 通过偏移量重复索引, 知道发生 IndexError 异常.

在 __iter__ 机制中, 列就是通过实现**迭代协议**来实现用户自定义的迭代器的.

1. 单一迭代器对象, __iter__ 只需返回 self 即可.
    
    生成器函数和表达式, 以及map, zip 这样的内置函数, 都是单迭代对象.
    ```
        class Squares:
            def __init__(self, start, stop):
                self.value = start - 1
                self.stop = stop

            def __iter__(self):
                return self

            def __next__(self):         # def next(self): Python 2.6
                if self.value == self.stop:
                    raise StopIteration
                self.value += 1
                return self.value ** 2

        for i in Squares(1, 5):
            print i,       # 1 4 9 16 25
    ```
2. 多迭代对象 : 

    range 内置函数和其他内置类型(如列表), 支持独立位置的多个活跃迭代器.
    ```
    # 多活跃迭代器.

    S = "ace"
    for x in S:
        for y in S:
            print x + y
    
    # 类实现示例:
    class SkipIterator:
        def __init__(self, wrapped):
            self.wrapped = wrapped
            self.offset = 0

        def __next__(self):
            if self.offset >= len(self.wrapped):
                raise StopIteration
            else:
                item = self.wrapped[self.offset]
                self.offset += 1
                return item

    class SkipObj:
        def __init__(self, wrapped):
            self.wrapped = wrapped

        def __iter__(self):
            return SkipIterator(self.wrapped)

    if __name__ == "__main__":
        alpha = "abcdef"
        skipper = SkipObj(alpha)
        I = iter(skipper)
        print(next(I), next(I), next(I))

        for x in skipper:
            for y in skipper:
                print(x + y, end=" ")        
    ```

### 成员关系: __contains__ > __iter__ > __getitem__

迭代器的内容比我们看到的还要丰富. 运算符重载往往是**多个层级**的: 类可以提供特定的方法, 或者用作退而求其次选项的更通用的替代方案.

在迭代领域, 通常把 in 成员关系运算符实现为一个迭代, 使用 __iter__ 方法或 __getitem__ 方法. 如果要支持更加特定的成员关系, 类可能编写一个 __container__ 方法, __container__ 方法应该把成员关系定义为对一个**映射应用键**(并且可以使用快速查找), 以及用于序列的搜索. 三个方法的优先级如下:

```
__container__ > __iter__ > __getitem__ 

# 依次注释掉 __container__, __iter__ 查看输出效果.
class Iters:
    def __init__(self, value):
        self.data = value

    def __getitem__(self, i):
        print("get[%s]: " % i, end="")
        return self.data[i]

    def __iter__(self):
        print("iter => ", end="")
        self.ix = 0
        return self

    def __next__(self):
        print("next:", end="")
        if self.ix == len(self.data):
            raise StopIteration
        item = self.data[self.ix]
        self.ix += 1
        return item

    def __contains__(self, x):
        print("contains: ", end="")
        return x in self.data

X = Iters([1, 2, 3, 4, 5])
print(3 in X)
for i in X:
    print(i, end=" | ")

print()
print([i ** 2 for i in X])
print(list(map(bin, X)))

I = Iters(X)
while True:
    try:
        print(next(I), end=" @ ")
    except StopIteration:
        break
```

### 属性索引:
#### __getattr__
__getattr__ 方法是拦截属性点号运算. 更确切的说, 当通过对**未定义**(不存在)的属性名称和实力进行点号运算时, 就会使用属性名称作为字符串调用这个方法. 如果 Python 可通过其继承树搜索流程找到这个属性, 该方法就不会被调用. 因为有这种情况, 所以 __getattr__ 可以作为钩子来通过通用的方式响应属性请求.

```    
# 下例子中, Empty 和 其实例本身没有属性, __getattr__ 让其看起来像是一个属性, 实际上, age 变成了一个动态计算的属性.
class Empty:
    def __getattr__(self, attrname):
        if attrname == "age":
            return 12
        else:
            raise AttributeError(attrname)

x = Empty()
print(x.age)
print(x.name)

```

`__getattr__` 做实际**内容委托**和**内容属性**.

#### __setattr__
__setattr__ 会拦截所有属性的赋值语句. 如果定义了这个方法, self.attr = value 会变成 self.__setattr__("attr", value). 这一点技巧性很高, 因为在 __setattr__ 中对任何self 属性做赋值, 都会再调用 __setattr__, 导致无穷递归循环, 最后堆栈溢出. 如果希望使用该方法, 要确定是通过对属性字典做索引运算来赋值任何势力属性的.即, 使用 self.__dict__["name"] = x 而不是 self.name = x.
```
class AccessControl:
    def __setattr__(self, key, value):
        if key == "age":
            self.__dict__[key] = value
        else:
            raise AttributeError(key + " not Allow!")

x = AccessControl()
x.age = 40
print(x.age)

x.name = 'tom'
```
#### 其他属性管理工具
- `__getattribute__` 方法拦截所有的属性获取, 而不只是那些未定义的, 但是当使用它的时候, 必须必使用 __getattr__ 更小心的避免循环.
- `Property` 内置函数允许我们把**方法**和**特定类属性**上的**获取**和**设置**操作关联起来.
- **描述符**提供了一个协议, 把一个类的 __get__, __set__ 方法与对特定类属性的访问关联起来.


#### 模拟实例属性的私有性
如下是 Python 中实现属性私有性(即如法在类外对属性名进行修改)的首选方法.

为使其更有效, 必须增强他的功能, 让子类能够设置私有属性, 并且使用 __getattr__ 和包装(有时称为代理) 来检测对私有属性的读取. 更完整的方案是使用 **类装饰器** 来实现拦截和验证属性.

```
class PrivateEcx(Exception):
    pass


class Privacy:
    def __setattr__(self, attrname, value):
        if attrname in self.privates:
            raise PrivateEcx(attrname, self)

        else:
            self.__dict__[attrname] = value


class Test1(Privacy):
    privates = ["age"]


class Test2(Privacy):
    privates = ["name", "age"]

    def __init__(self):
        self.__dict__["name"] = 'tom'


x = Test1()
y = Test2()
print(x.privates, y.privates)
x.name = "jerry"    # success
y.name = "sue"      # fail

y.age = 30          # fail
x.age = 40          # fail

```
### 对象的字符串表达形式 __repr__ & __str__

__repr__ & __str__ 可替对象定义更好的显示格式, 而不是使用默认的实例显示.

__str__ : 打印操作会首先尝试 __str__ 和 str 内置函数(print 运行的内部等价形式). 他通常应该返回一个用户友好的显示.
__repr__ : 用于所有其他的环境中: 用于交互式模糊四线提示回应以及 repr 函数. 他通常应该返回一个编码字符串, 可以用来重新创建对象, 或者给开发者一个详细的提示.

如果没有定义 __str__ , 打印还是使用 __repr__ , 但反过来并不成立. 其他环境, 如交互式响应模式, 只是使用 __repr__ , 并且根本不尝试 __str__ .
```
class Addr:
    def __init__(self, value=0):
        self.data = value

    def __add__(self, other):
        self.data += other

x = Addr()
print(x)

class AddRepr(Addr):
    def __repr__(self):
        return "AddRepr(%s)" % self.data

y = AddRepr(2)
print(y)
y + 1
print(y)
print(str(y), repr(y))
```
如果想让所有环境都用统一的显示, __repr__ 是最佳选择.

注意:
1. __repr__ 和 __str__ 必须返回字符串, 其他的结果类型, 不会转换并会引发错误. 如果必要的话, 请确保一个转换器处理他.
2. 根据一个容器的字符串转换逻辑, __str__ 的用户友好的显示可能只有当对象出现在一个打印操作顶层的时候才应用, 嵌套到较大对象中的对象可能用其 __repr__ 或默认方法打印. 为确保一个定义显示在所有的环境中都显示, 而不管容器是什么, 请编写 __repr__ , 而不是 __str__ .

### 左侧叫法(__add__), 右侧加法(__radd__)和原处加法(__iadd__):
`__add__`  : 当 + 左侧的对象是类实例, 而右边对象不是类实例时.
`__radd__` : 当 + 右侧的对象是类实例, 而左边对象不是类实例时.
`__iadd__` : 

当不同类的实例混合出现在表达式时, Python 优先选择左侧的那个类.

```
class Commuter:
    def __init__(self, val):
        self.val = val

    def __add__(self, other):
        print("add", self.val, other)
        return self.val + other

    def __radd__(self, other):
        print("radd", self.val, other)
        return other + self.val

x = Commuter(88)
y = Commuter(99)
x + 1
1 + y
x + y

# 原处加法
class Number:
    def __init__(self, val):
        self.val = val

    def __add__(self, other):
        return Number(self.val + other)

m = Number(5)
m += 1
m += 1
print(m.val)
```

每个二元运算符都有类似的右侧和原处重载方法, 他们以相同的方式工作(如 __mul__, __rmul__, __imul__). 右侧方法是一个高级话题, 并且在实际中很少用到, 只有在需要运算符有交换性质的时候, 才会编写他们, 并且只有在正真需要支持这样的运算符的时候, 才会使用. 如矢量运算等.

### Call 表达式
#### __call__
```
class Callee:
    def __call__(self, *args, **kwargs):
        print("Called: ", args, kwargs)

C = Callee()
C(1, 2, 3)
C(1, 2, 3, x=4, y=5)
```
带有 __call__ 的类和实例, 支持与常规函数和方法完全相同的参数语法和定义. 所有参数传递方式, __call__ 方法都支持, 传递给实例的任何内容都会传递给该方法, 包括通常隐式的实例参数.
```
class C:
    def __call__(self, a, b, c=5, d=6): ...

class C:
    def __call__(self, *args, **kwargs): ...

class C:
    def __call__(self, *args, d=6, **kwargs): ...

```
像这样的拦截表达式允许类实例模拟类似函数的外观, 但是, 也在调用中保持了状态信息以供使用. 当需要函数的API 编写接口时, __call__ 就变得很有用: 这可以编写遵循所需要的函数来调用接口对象, 同时又能保留状态信息.
```        
class Prod:
    def __init__(self, value):
        self.value = value

    def __call__(self, other):
        return self.value * other

x = Prod(4)
print(x(2))     # 8    
```
函数接口和回调代码

### 比较:

__lt__ & __gt__ : 比较方法, 没有右端形式, 相反, 当只有一个运算数支持比较的时候, 使用其对应方法. 比较运算符没有隐式关系, 如 == 并不表示 != 是假的, 因此 __eq__ 和 __ne__ 应该定义为确保两个运算符都正确的使用.

__cmp__ : python 2.6 , 如果没有定义更为具体的比较方法的话, 对所有比较使用该方法, 它返回一个 小于, 等于 或 大于 0 的数, 以表示比较其两个参数(self 和 另一个参数)的结果. 该方法往往使用 cmp(x, y) 内置函数来计算器结果. Python 3 删除了 __cmp__ 和 cpm() .

```
class C:
    data = "spam"

    def __gt__(self, other):
        return self.data > other

    def __lt__(self, other):
        return self.data < other

X = C()
print(X > "ham")    # True, __gt__
print(X < "ham")    # False, __lt__
```
### 布尔测试 : __bool__ & __len__
在布尔环境中, Python 首先尝试 __bool__ 来获取一个直接的布尔值, 然后, 如果没有该方法, 就尝试 __len__ 根据对象的长度确定一个真值.
```
class Truth:
    def __bool__(self):
        return True

X = Truth()
if X:
    print("Yes!")

class Truths:
    def __len__(self):
        return 0
```
Python 2.6 中 __bool__ 仅仅被当做一个特殊方法, 而不是重载布尔运算符. 如果需要重载, 请使用 __nonzero__ 方法, Python 3 把 python 2.6 中的 __nonzero__ 改名为 __bool__. 同时, __len__ 在 python 2.6 和 Python 3 中都作为 运算符重载的候补.
```    
class C:
    def __nonzoro__(self):
        print "in nonzero"
        return False
```
### 对象析构函数 : __del__
当实例对象的最后一次引用失去时, 执行 __del__ 方法. 但是由于无法轻易预测垃圾何时回收, 该方法实际上较少使用.   
```
class Life:

    def __init__(self, name="Unknown"):
        print("hello", name)
        self.name = name

    def __del__(self):
        print("Goodby", self.name)

brian = Life("brian")   # hello brian
brian = 123             # Goodby brian
```
## 30 类的设计: 如何使用类来对有用的对象进行建模.
常用设计模式:

### 继承: **是一个**关系
从程序员的角度来看, 继承是由属性点号运算启动的, 由此出发实例, 类以及任意超类中的变量名搜索.
从设计师的角度来看, 继承是一种定义集合成员关系的方式, 类定义了一组内容属性, 可由更具体的集合(子类)继承和订制.
```
class Employee:
    def __init__(self, name, salary=0):
        self.name = name
        self.salary = salary

    def give_raise(self, percent):
        self.salary = self.salary + (self.salary * percent)

    def work(self):
        print(self.name, "dose stuff")

    def __repr__(self):
        return "<Emplpyee: name=%s, salary=%s>" % (self.name, self.salary)


class Chef(Employee):
    def __init__(self, name):
        Employee.__init__(self, name, 50000)

    def work(self):
        print(self.name, "makes food")


class Server(Employee):
    def __init__(self, name):
        Employee.__init__(self, name, 40000)

    def work(self):
        print(self.name, "interfaces with customer")


class PizzaRobot(Chef):
    def __init__(self, name):
        Chef.__init__(self, name)

    def work(self):
        print(self.name, "make pizza")


if __name__ == "__main__":
    bob = PizzaRobot("bob")
    print(bob)
    bob.work()
    bob.give_raise(0.20)
    print(bob)
    print('-' * 12)

    for klass in Employee, Chef, Server, PizzaRobot:
        print(klass.__name__)
        obj = klass(klass.__name__)
        obj.work()
```
### 组合: **有一个**关系
从程序员的角度看, 组合设计吧其他对象嵌入容器对象内, 并使其实现容器方法.
对设计师来说, 组合是另一种表示问题领域中关系的方式. 

组合是组件, 就是整体中的组成部分. 组合反应了各组成部分之间的关系, 通常称为**有一个**关系. 有些 OOP 设计书籍中把它称为**聚合**. 组合就是指内嵌对象几何体, 组合类一般提供自己的接口, 并通过内嵌的对象来实现接口.

如下面示例中的 PizzaShop 类, 是容器和控制器, 其构造函数会创建员工实例, 并将其嵌入.
```
from employees import PizzaRobot, Server

class Customer:
    def __init__(self, name):
        self.name = name

    def order(self, server):
        print(self.name, "order from", server)

    def pay(self, server):
        print(self.name, "pays for item to", server)

class Oven:
    def bake(self):
        print("oven back")

class PizzaShop:
    def __init__(self):
        self.server = Server("Pzt")
        self.chef = PizzaRobot("bob")
        self.oven = Oven()

    def order(self, name):
        customer = Customer(name)
        customer.order(self.server)
        self.chef.work()
        self.oven.bake()
        customer.pay(self.server)

if __name__ == "__main__":
    scene = PizzaShop()
    scene.order("Homer")
    print("-" * 20)
    scene.order("Shaggy")


# 数据流处理器示例: 包含组合和继承
class Processor:
    def __init__(self, reader, writer):
        self.reader = reader
        self.writer = writer

    def process(self):
        while 1:
            data = self.reader.readline()
            if not data:
                break
            data = self.converter(data)
            self.writer.write(data)

    def converter(self):
        assert False, "Convert must be defined"

class Uppercase(Processor):
    def converter(self, data):
        return data.upper()

if __name__ == "__main__":
    import sys
    obj = Uppercase(open("test.txt"), sys.stdout)
    obj.process()    
```
### 委托: delegation
委托: 值控制器对象内嵌其他对象, 而把运算请求传给这些对象. 控制器负责管理工作, 如记录存取等.

在 Python 中委托以 __getattr__ 钩子方法实现, 该方法会拦截对不存在属性的读取, 包装类(有时称为代理类) 可以使用 __getattr__ 把任意读取转发给被包装的对象. 包装类包有被包装对象的接口, 而且自己也可以增加其他运算.

```
class Wrapper:
    def __init__(self, obj):
        self.wrapped = obj

    def __getattr__(self, attr_name):
        print("Trace", attr_name)
        return getattr(self.wrapped, attr_name)


x = Wrapper([1, 2, 3])
x.append(4)
print(x.wrapped)

y = Wrapper({"a": 1, "b": 2})
print(y.keys())
```
实际效果就是以包装类内额外的代码来增强被包装的对象的整个接口. 可以利用这种方式记录方法调用, 把方法调用转给其他或订制的逻辑等的.

包装对象和委托操作是扩展内置类型的一种方式. 与函数装饰器是关联性很强的概念, 只在用来增加特定函数或方法调用, 而不是对对象的整个接口. 还有类装饰器, 他充当向一个类的所有实例自动添加诸如基于委托的包装器的一种方式.

类的伪私有属性: 让类内的某些变量局部化. 也称为变量名压缩, 压缩后的变量名有时会被称为私有属性, 但这其实只是一种把类所创建的变量名**局部化**的一种方式而已: 名称压缩无法阻止类外代码对他的读取. 这种功能主要是为了避免实例内的命名空间的冲突, 而不是限制变量名的读取. 因此, 压缩的变量名最好称为*伪私有*, 而不是私有.

使用一个单个的下划线来编写内部名称(如 `_x`), 这只是一个非正式的惯例, 即这是一个不应该修改的名字, 这对 Python 自身来说没有什么意义.

变量名压缩: class 语句内开头有两个下划线, 但结尾没有两个下划线的变量, 会自动扩张, 从而包含所在类的名称, 如 位于 spam 类中的 `__x` 变量会变为 `_spam__x` : 原始的变量名会在头部加入一个下划线, 然后是所在类名称. 因为修改后的变量名包含了所在类的名称, 相当于变得独特, 不会和同一层次中其他类所创建的类似变量名相冲突. 变量名压缩只发生在 class 语句内, 而且只针对开头有两个下划线的变量名, 包含实例方法和实例属性

```
    class C1:
        def meth1(self):
            self.__x = 88

        def meth2(self):
            print(self.__x)

    class C2:

        def metha(self):
            self.__x = 99

        def methb(self):
            print(self.__x)

    class C3(C1, C2):
        pass

    I = C3()
    I.meth1()
    I.metha()
    print(I.__dict__)       # {'_C1__x': 88, '_C2__x': 99}
    I.meth2()               # 88
    I.methb()               # 99

```
### 多重继承
多重继承: 类和其实例继承了列出的所有超类的变量名.

搜索属性时, Python 会由左到右搜索类首行中的超类, 知道找到相符者.

属性搜索方式:

1. 传统类: 深度优先, Python 3.0 之前
    
    属性搜索对所有路径优先, 知道继承树的最顶端, 然后从左到右进行.
    
    可以自继承 object 类, 转变为新式类.

2. 新式类: 广度优先, Python 3.0
    
    属性搜索处理, 沿着树层级, 以更加广度优先的方式进行.
    所有类都继承自 object.

    新式类变化:

    1. 类和类型合并

        类现在就是类型, 并且类型现在就是类. type(I) 内置函数返回一个实例所创建自的类, 而不是一个通用的实例类型, 并且通常和 I.__class__ 相同.

        类是 type类 的实例, type可能子类化为定制类创建, 并且所有的类继承自 object .
          
    2. 继承搜索顺序
        多继承的钻石模式有一种略微不同的搜索顺序. 总体而言, 他可能先横向搜索再纵向搜索, 并且先宽度优先, 就深度优先搜索.
    3. 针对内置函数的属性获取
    4. 新的高级工具
        slot
        特性
        描述符
        `__getattribute__` 方法.



### 类是对象 : 通用对象的工厂.
工厂可以将代码和动态配置对象的构造细节隔离开.
```
def factory(aClass, *args):
    return aClass(*args)

class Spam:
    def doit(self, message):
        print(message)

class Person:
    def __init__(self, name, job):
        self.name = name
        self.job = job

obj1 = factory(Spam)
obj1.doit("hello world")
obj2 = factory(Person, "Guido", "guru")
print(obj2.__dict__)

```
## 31 类的高级主题
###扩展内置类型:
#### 通过嵌入扩展类型
```
class Set:
    def __init__(self, value=[]):
        self.data = []
        self.concat(value)

    def intersect(self, other):
        res = []
        for x in self.data:
            if x in other:
                res.append(x)

        return Set(res)

    def union(self, other):
        res = self.data[:]
        for x in other:
            if not x in res:
                res.append(x)

        return Set(res)

    def concat(self, value):
        for x in value:
            if not x in self.data:
                self.data.append(x)

    def __len__(self):
        return len(self.data)

    def __getitem__(self, item):
        return self.data[item]

    def __and__(self, other):
        return self.intersect(other)

    def __or__(self, other):
        return self.union(other)

    def __repr__(self):
        return "Set: " + repr(self.data)


x = Set([1, 3, 5, 7])
print(x.union(Set([1, 4, 7])))
print(x | Set([1, 4, 6]))
```
#### 通过子类扩展类型
```
    class MyList(list):
        def __getitem__(self, offset):
            print("(indexing %s at %s)" % (self, offset))
            return list.__getitem__(self, offset-1)


    if __name__ == "__main__":
        print(list("abc"))
        x = MyList("abc")
        print(x)

        print(x[1])
        print(x[3])
        x.append("spam")
        print(x)
        x.reverse()
        print(x)
```        
新式类
    变化:
        类型模型变化
        钻石继承变动
    扩展 
        slots 实例
        类特性
        __getattribute__ 和 描述符
        元类

静态方法和类方法

装饰器和元类:
    函数装饰器
    类装饰器
    元类

类陷阱:
    修改类属性的副作用
    修改可变的类属性也可能产生副作用
    多重继承: 顺序很重要
    类,方法及嵌套作用域
    Python 中基于委托的类: 
        __getattr__ 和 内置函数

    过度包装


## 36 Unicode 和 字符串

## 37 管理属性

## 38 装饰器

## 39 元类


--------------------------
与设计相关的其他话题
1. 抽象超类
2. 装饰器
3. 类型子类
4. 静态方法和类方法
5. 管理属性
6. 元类
7. 混合类
    委托
    组合
    继承, 多重继承
    工厂
    私有属性, 绑定方法

---------------------------------
## 数据结构和算法
1. 序列解包  Python2,3

    解包可以作用在任何可迭代对象上, 而不仅仅是列表或元组. 包含字符串,文件对象, 迭代器和生成器.
    ```
    >> data = ["ACME",21,21.1,(2012,12,21)]
    >> name,shares,price,(year,mon,day) = data
    >> name
        "ACME"
    >> year
        2012

    
    # 解压部分
    >> data = ["ACME",21,21.1,(2012,12,21)]
    >> _, _, price,date = data
    >> price
        21.1
    >> date
        (2012,12,21)
    ```    
2. 星号表达式 : 解压可迭代对象赋值给多个变量 : Python3
    ```
    >>> record = ('Dave', 'dave@example.com', '773-555-1212', '847-555-1212')
    >>> name, email, *phone_numbers = record
    >>> name
        'Dave'
    >>> email
        'dave@example.com'
    >>> phone_numbers       # 此处 , phone_numbers 永远是列表类型, 不管解压的电话号码数量是多少.
        ['773-555-1212', '847-555-1212']    

    ```
    位于前半段 :
    ```
    >>> *night,ten = range(11)
    >>> night
        [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    >>> ten
        10

    ```
    字符串操作
    ```
    >>> line = 'nobody:*:-2:-2:Unprivileged User:/var/empty:/usr/bin/false'
    >>> uname,*fields,homedir,sh = line.split(":")
    >>> uname
    'nobody'
    >>> fields
    ['*', '-2', '-2', 'Unprivileged User']
    >>> homedir
    '/var/empty'
    >>> sh
    '/usr/bin/false'    
    ```
    丢弃元素 : 可以使用普通的废弃名字, 如 `_` 或者 ign 等
    ```
    >>> record = ("ACME",50,123.45,(12,15,2012))
    >>> name,*_,(*_,year) = record
    >>> name
    'ACME'
    ```    
3. 双端队列, deque : 保留最后 N 个元素
    ```
    >> from collections import deque
    >> q = deque(maxlen=3)
    >> q.append(1)
    >> q.append(2)
    >> q.append(3)
    >> q 
        deque([1, 2, 3], maxlen=3)
    >> q.append(4)
    >> q
        deque([2, 3, 4], maxlen=3)
    ```    

    可用方法 :
    ```
    q.append()
        Add an element to the right side of the deque .

    q.appendleft()
        Add an element to the left side of the deque
    
    q.clear()
        Remove all element from the deque

    copy()
        Return a shallow copy of a deque

    count()
        D.count(value) --> integer -- return number of occurrences of value .

    extend()
        Extend the right side of the deque with elements from the iterable.

    extendleft()
        Extend the left side of the deque with elements from the iterable .

    index()
        Return the first index of value .
        Raise ValueError if the value is not present.

    insert()
        insert object before index .

    pop()
        Remove and return the rightmost element.

    popleft()
        Remove and return the leftmost element.

    remove()
        remove the first occurrence of value.

    reverse()
        reverse *IN PLACE*

    ```    

    ** 在双端队列两端插入或删除元素时间复杂度都是 O(1) 的, 而在 列表的开头插入或删除元素的时间复杂度是 O(n)**

4.  堆数据结构 : 查找最大或最小的 N 个元素.
    

    `heapq.nlargest() & heapq.nsmallest()`

    ```
    import heapq
    nums = [1, 8, 2, 23, 7, -4, 18, 23, 42, 37, 2]
    print(heapq.nlargest(3, nums))
    print(heapq.nsmallest(3, nums))

    [42, 37, 23]
    [-4, 1, 2]

    复杂数据结构 :
        portfolio = [
            {'name': 'IBM', 'shares': 100, 'price': 91.1},
            {'name': 'AAPL', 'shares': 50, 'price': 543.22},
            {'name': 'FB', 'shares': 200, 'price': 21.09},
            {'name': 'HPQ', 'shares': 35, 'price': 31.75},
            {'name': 'YHOO', 'shares': 45, 'price': 16.35},
            {'name': 'ACME', 'shares': 75, 'price': 115.65}
        ]

        cheap = heapq.nsmallest(3, portfolio, key=lambda s: s['price'])
        expensive = heapq.nlargest(3, portfolio, key=lambda s: s['price'])      

        # 上面的代码在对每个元素进行对比的时候, 会以 price 的值进行比较.
    ```
    堆数据结构
    ```
    如果希望在一个集合中查找最小或最大的 N 个元素, 并且 N 小于集合元素数量, 

    >>> nums = [1, 8, 2, 23, 7, -4, 18, 23, 42, 37, 2]
    >>> import heapq
    >>> heapq.heapify(nums)
    >>> nums
    [-4, 2, 1, 23, 7, 2, 18, 23, 42, 37, 8]     

    堆数据结构最重要的特征是 heap[0] 永远是最小的元素. 并且剩余的元素可以很容易的通过调用 heapq.heappop() 方法得到, 该方法会先将第一个元素弹出来, 然后用下一个最小的元素来取代被弹出元素(时间复杂度 O(log N), N为堆大小).

    >> heapq.heappop(nums)
        -4
    >> heapq.heappop(nums)
        1
    >> heapq.heappop(nums)
        2


    ** 仅仅查找唯一最大或最小的元素, 那么 min() 和 max() 函数更快.
    ** 如果 N 的大小和集合大小接近的时候, 通常先排序该集合, 然后使用切片操作会更快.    
    ```
    `heapq.heappush()` & `heapq.heappop()` : `heapq.heappop()` 删除并返回优先级最高的元素, 并一次类推. 如果优先级相同, 则比较 `index`(如果有的话).

    ```
    import heapq

    class PriorityQueue:
        def __init__(self):
            self._queue = []
            self._index = 0

        def push(self, item, priority):
            heapq.heappush(self._queue, (-priority, self._index, item))
            self._index += 1

        def pop(self):
            return heapq.heappop(self._queue)[-1]

    >>> class Item:
    ...     def __init__(self, name):
    ...         self.name = name
    ...     def __repr__(self):
    ...         return 'Item({!r})'.format(self.name)
    ...
    >>> q = PriorityQueue()
    >>> q.push(Item('foo'), 1)
    >>> q.push(Item('bar'), 5)
    >>> q.push(Item('spam'), 4)
    >>> q.push(Item('grok'), 1)
    >>> q.pop()
        Item('bar')
    >>> q.pop()
        Item('spam')
    >>> q.pop()
        Item('foo')
    >>> q.pop()
        Item('grok')
    ```
5. 字典
    
    字典中键映射多个值
    ```
    from collections import defaultdict

    d = defaultdict(list)
    d['a'].append(1)
    d['a'].append(2)
    d['b'].append(4)

    d = defaultdict(set)
    d['a'].add(1)
    d['a'].add(2)
    d['b'].add(4)
    ```
    字典排序: 在迭代时时, 保持元素被插入式的顺序. 
    ```
    dic = {'a':31, 'bc':5, 'c':3, 'asd':4, 'aa':74, 'd':0}
    dict= sorted(dic.iteritems(), key=lambda d: d[1], reverse = True)
    print dict

    # 输出
    [('aa', 74), ('a', 31), ('bc', 5), ('asd', 4), ('c', 3), ('d', 0)]
    ```    
    OrderedDict内部维护着一个根据键插入顺序排序的双向链表。每次当一个新的元素插入进来的时候，它会被放到链表的尾部。对于一个已经存在的键的重复赋值不会改变键的顺序。

    需要注意的是，一个OrderedDict的大小是一个普通字典的两倍，因为它内部维护着另外一个链表。
    ```
    from collections import OrderedDict
    def ordered_dict():
        d = OrderedDict()
        d['foo'] = 1
        d['bar'] = 2
        d['spam'] = 3
        d['grok'] = 4
        # Outputs "foo 1", "bar 2", "spam 3", "grok 4"
        for key in d:
            print(key, d[key])
    ```
    查找字典相同点 : 为了寻找两个字典的相同点，可以简单的在两字典的 keys() 或者 items() 方法返回结果上执行集合操作。

    ```
    python 3

    # Find keys in common
    a.keys() & b.keys() # { 'x', 'y' }

    # Find keys in a that are not in b
    a.keys() - b.keys() # { 'z' }
    
    # Find (key,value) pairs in common
    a.items() & b.items() # { ('y', 2) }
    ```
    字典列表, 根据某个或某几个字典字段来排序 `operator.itemgetter()` . operator.itemgetter() 函数有一个被rows中的记录用来查找值的索引参数。可以是一个字典键名称，一个整形值或者任何能够传入一个对象的 __getitem__() 方法的值。如果你传入多个索引参数给 itemgetter() ，它生成的 callable 对象会返回一个包含所有元素值的元组，并且sorted()函数会根据这个元组中元素顺序去排序。但你想要同时在几个字段上面进行排序(比如通过姓和名来排序，也就是例子中的那样)的时候这种方法是很有用的。
    ```
    >>> rows = [
        {'fname': 'Brian', 'lname': 'Jones', 'uid': 1003},
        {'fname': 'David', 'lname': 'Beazley', 'uid': 1002},
        {'fname': 'John', 'lname': 'Cleese', 'uid': 1001},
        {'fname': 'Big', 'lname': 'Jones', 'uid': 1004}
    ]

    >>> from operator import itemgetter
    >>> rows_by_fname = sorted(rows, key=itemgetter('fname'))
    >>> rows_by_uid = sorted(rows, key=itemgetter('uid'))

    # itemgetter()函数也支持多个keys
    >>> rows_by_lfname = sorted(rows, key=itemgetter('lname','fname'))

    # 适用于min()和max()等函数
    >>> min(rows, key=itemgetter('uid'))
        {'fname': 'John', 'lname': 'Cleese', 'uid': 1001}

    >>> max(rows, key=itemgetter('uid'))
        {'fname': 'Big', 'lname': 'Jones', 'uid': 1004}
    ```        
    用一个字典的子集构建另一个字典: 字典推到
    ```
    prices = {
        'ACME': 45.23,
        'AAPL': 612.78,
        'IBM': 205.55,
        'HPQ': 37.20,
        'FB': 10.75
    }

    # Make a dictionary of all prices over 200
    p1 = {key: value for key, value in prices.items() if value > 200}
    
    # Make a dictionary of tech stocks
    tech_names = {'AAPL', 'IBM', 'HPQ', 'MSFT'}
    p2 = {key: value for key, value in prices.items() if key in tech_names}
    ```    
6. 命名切片
    ```
    >>> items = [0, 1, 2, 3, 4, 5, 6]
    >>> a = slice(2, 4)
    >>> items[2:4]
    [2, 3]
    >>> items[a]
    [2, 3]
    >>> items[a] = [10,11]
    >>> items
    [0, 1, 10, 11, 4, 5, 6]
    >>> del items[a]
    >>> items
    [0, 1, 4, 5, 6]

    # 对切片对象, 分别调用它的s.start, s.stop, s.step属性来获取更多的信息
    >>> a = slice(5, 50, 2)
    >>> a.start
        5
    >>> a.stop
        50
    >>> a.step
        2

    # 通过调用切片的indices(size)方法将它映射到一个确定大小的序列上，这个方法返回一个三元组(start,stop,step)，所有值都会被合适的缩小以满足边界限制，从而使用的时候避免出现IndexError异常。
    >>> s = 'HelloWorld'
    >>> a.indices(len(s))
        (5, 10, 2)
    >>> for i in range(*a.indices(len(s))):
             print(s[i])
    
        W
        r
        d
    ```
6. 命名元组: `collections.namedtuple()` 支持所有的元组操作.
    
    collections.namedtuple() 函数通过使用一个普通的元组对象来帮你解决这个问题。这个函数实际上是一个返回Python中标准元组类型子类的一个工厂方法。你需要传递一个类型名和你需要的字段给它，然后它就会返回一个类，你可以初始化这个类，为你定义的字段传递值等。
    ```    
    >>> from collections import namedtuple
    >>> Subscriber = namedtuple('Subscriber', ['addr', 'joined'])
    >>> sub = Subscriber('jonesy@example.com', '2012-10-19')
    >>> sub
        Subscriber(addr='jonesy@example.com', joined='2012-10-19')
    >>> sub.addr
        'jonesy@example.com'
    >>> sub.joined
        '2012-10-19'
    >>>
    ```
    命名元组另一个用途就是作为字典的替代，因为字典存储需要更多的内存空间。如果你需要构建一个非常大的包含字典的数据结构，那么使用命名元组会更加高效。但是需要注意的是，不像字典那样，一个命名元组是不可更改的。如果你真的需要改变然后的属性，那么可以使用命名元组实例的 `_replace()` 方法， 它会创建一个全新的命名元组并将对应的字段用新的值取代。`_replace()` 方法还有一个很有用的特性就是当你的命名元组拥有可选或者缺失字段时候，它是一个非常方便的填充数据的方法。你可以先创建一个包含缺省值的原型元组，然后使用 `_replace()` 方法创建新的值被更新过的实例。
    ```
    from collections import namedtuple

    Stock = namedtuple('Stock', ['name', 'shares', 'price', 'date', 'time'])

    # Create a prototype instance
    stock_prototype = Stock('', 0, 0.0, None, None)

    # Function to convert a dictionary to a Stock
    def dict_to_stock(s):
        return stock_prototype._replace(**s)

    >>> a = {'name': 'ACME', 'shares': 100, 'price': 123.45}
    >>> dict_to_stock(a)
        Stock(name='ACME', shares=100, price=123.45, date=None, time=None)
    >>> b = {'name': 'ACME', 'shares': 100, 'price': 123.45, 'date': '12/17/2012'}
    >>> dict_to_stock(b)
        Stock(name='ACME', shares=100, price=123.45, date='12/17/2012', time=None)
    ```
    如果你的目标是定义一个需要更新很多实例属性的高效数据结构，那么命名元组并不是你的最佳选择。这时候你应该考虑定义一个包含 `__slots__` 方法的类.

7. 找出序列中出现次数最多的元素 `collections.Counter()`
    ```
    from collections import Counter

    words = [
        'look', 'into', 'my', 'eyes', 'look', 'into', 'my', 'eyes',
        'the', 'eyes', 'the', 'eyes', 'the', 'eyes', 'not', 'around', 'the',
        'eyes', "don't", 'look', 'around', 'the', 'eyes', 'look', 'into',
        'my', 'eyes', "you're", 'under'
    ]
    
    word_counts = Counter(words)
    
    # 出现频率最高的3个单词
    top_three = word_counts.most_common(3)
    
    print(top_three)
    # Outputs [('eyes', 8), ('the', 5), ('look', 4)]

    >>> word_counts['not']
        1
    >>> word_counts['eyes']
        8

    # 更新, 增加更多方法.
    >>> morewords = ['why','are','you','not','looking','in','my','eyes']
    >>> word_counts.update(morewords)

    # 数学运算
    >>> a = Counter(words)
    >>> b = Counter(morewords)
    >>> a
    Counter({'eyes': 8, 'the': 5, 'look': 4, 'into': 3, 'my': 3, 'around': 2,
    "you're": 1, "don't": 1, 'under': 1, 'not': 1})
    >>> b
    Counter({'eyes': 1, 'looking': 1, 'are': 1, 'in': 1, 'not': 1, 'you': 1,
    'my': 1, 'why': 1})
    
    # Combine counts
    >>> c = a + b
    >>> c
    Counter({'eyes': 9, 'the': 5, 'look': 4, 'my': 4, 'into': 3, 'not': 2,
    'around': 2, "you're": 1, "don't": 1, 'in': 1, 'why': 1,
    'looking': 1, 'are': 1, 'under': 1, 'you': 1})
    
    # Subtract counts
    >>> d = a - b
    >>> d
    Counter({'eyes': 7, 'the': 5, 'look': 4, 'into': 3, 'my': 2, 'around': 2,
    "you're": 1, "don't": 1, 'under': 1})
    ```    
7. 从一个数据序列中取出需要的值或缩短序列
    
    列表推导式
    ```
        >>> mylist = [1, 4, -5, 10, -7, 2, 3, -1]
        >>> [n for n in mylist if n > 0]
            [1, 4, 10, 2, 3]
        >>> [n for n in mylist if n < 0]
            [-5, -7, -1]
        >>> [n if n>0 else 0 for n in mylist]
            [1, 4, 0, 10, 0, 2, 3, 0]
    ```        
    生成器
    ```
    >>> pos = (n for n in mylist if n > 0)
    >>> pos
        <generator object <genexpr> at 0x1006a0eb0>
    >>> for x in pos:
            print(x)
    ```            
    filter() 
    ```
    values = ['1', '2', '-3', '-', '4', 'N/A', '5']

    def is_int(val):
        try:
            x = int(val)
            return True
        except ValueError:
            return False

    ivals = list(filter(is_int, values))
    print(ivals)
    ```
    `itertools.compress()` ，它以一个 iterable 对象和一个相对应的Boolean选择器序列作为输入参数。然后输出 iterable 对象中对应选择器为True的元素。当你需要用另外一个相关联的序列来过滤某个序列的时候，这个函数是非常有用的。
    ```
    addresses = [
        '5412 N CLARK',
        '5148 N CLARK',
        '5800 E 58TH',
        '2122 N CLARK'
        '5645 N RAVENSWOOD',
        '1060 W ADDISON',
        '4801 N BROADWAY',
        '1039 W GRANVILLE',
    ]
    counts = [ 0, 3, 10, 4, 1, 7, 6, 1]

    >>> from itertools import compress
    >>> more5 = [n > 5 for n in counts]
    >>> more5
        [False, False, True, False, False, True, True, False]
    >>> list(compress(addresses, more5))
        ['5800 E 58TH', '4801 N BROADWAY', '1039 W GRANVILLE']
    ```        
8. sorted()/min()/max()
    
    内置的 sorted() 函数有一个关键字参数 key ，可以传入一个 callable 对象给它，这个 callable 对象对每个传入的对象返回一个值，这个值会被 sorted 用来排序这些对象。比如，如果你在应用程序里面有一个User实例序列，并且你希望通过他们的user_id属性进行排序，你可以提供一个以User实例作为输入并输出对应user_id值的 callable 对象。
    ```
    # 使用 lambda
    class User:
        def __init__(self, user_id):
            self.user_id = user_id

        def __repr__(self):
            return 'User({})'.format(self.user_id)

    def sort_notcompare():
        users = [User(23), User(3), User(99)]
        print(users)
        print(sorted(users, key=lambda u: u.user_id))

    # 使用 operator.attrgetter()
    >>> from operator import attrgetter
    >>> sorted(users, key=attrgetter('user_id'))
    [User(3), User(23), User(99)]

    ```
9. itertools.groupby() : 有一个字典或实例的序列, 然后根据某个特定的字段来分组迭代访问.   
    
    groupby() 函数扫描整个序列并且查找连续相同值(或者根据指定key函数返回值相同)的元素序列。在每次迭代的时候，它会返回一个值和一个迭代器对象，这个迭代器对象可以生成元素值全部等于上面那个值的组中所有对象。

    一个非常重要的准备步骤是要根据指定的字段将数据排序。因为 groupby() 仅仅检查连续的元素，如果事先并没有排序完成的话，分组函数将得不到想要的结果。
    ```
    rows = [
        {'address': '5412 N CLARK', 'date': '07/01/2012'},
        {'address': '5148 N CLARK', 'date': '07/04/2012'},
        {'address': '5800 E 58TH', 'date': '07/02/2012'},
        {'address': '2122 N CLARK', 'date': '07/03/2012'},
        {'address': '5645 N RAVENSWOOD', 'date': '07/02/2012'},
        {'address': '1060 W ADDISON', 'date': '07/02/2012'},
        {'address': '4801 N BROADWAY', 'date': '07/01/2012'},
        {'address': '1039 W GRANVILLE', 'date': '07/04/2012'},
    ]

    from operator import itemgetter
    from itertools import groupby

    # Sort by the desired field first
    rows.sort(key=itemgetter('date'))

    # Iterate in groups
    for date, items in groupby(rows, key=itemgetter('date')):
        print(date)
        for i in items:
            print(' ', i)


    07/01/2012
      {'date': '07/01/2012', 'address': '5412 N CLARK'}
      {'date': '07/01/2012', 'address': '4801 N BROADWAY'}
    07/02/2012
      {'date': '07/02/2012', 'address': '5800 E 58TH'}
      {'date': '07/02/2012', 'address': '5645 N RAVENSWOOD'}
      {'date': '07/02/2012', 'address': '1060 W ADDISON'}
    07/03/2012
      {'date': '07/03/2012', 'address': '2122 N CLARK'}
    07/04/2012
      {'date': '07/04/2012', 'address': '5148 N CLARK'}
      {'date': '07/04/2012', 'address': '1039 W GRANVILLE'}

    ```      
10. 多个字典或映射, 从逻辑上合并为一个单一的映射后执行某些操作.
    
    ChainMap对于编程语言中的作用范围变量(比如globals, locals等)是非常有用的。
    ```
    a = {'x': 1, 'z': 3 }
    b = {'y': 2, 'z': 4 }

    from collections import ChainMap
    c = ChainMap(a,b)
    print(c['x'])   # Outputs 1 (from a)
    print(c['y'])   # Outputs 2 (from b)
    print(c['z'])   # Outputs 3 (from a)

    # 如果出现重复键，那么第一次出现的映射值会被返回。因此，例子程序中的c[‘z']总是会返回字典a中对应的值，而不是b中对应的值。
    >>> len(c)
        3
    >>> list(c.keys())
        ['x', 'y', 'z']
    >>> list(c.values())
        [1, 2, 3]

    # 对于字典的更新或删除操作总是影响的是列表中第一个字典
    >>> c['z'] = 10
    >>> c['w'] = 40
    >>> del c['x']
    >>> a
        {'w': 40, 'z': 10}
    >>> del c['y']
        Traceback (most recent call last):
        ...
        KeyError: "Key not found in the first mapping: 'y'"


    >>> values = ChainMap()
    >>> values['x'] = 1

    # Add a new mapping
    >>> values = values.new_child()
    >>> values['x'] = 2
    
    # Add a new mapping
    >>> values = values.new_child()
    >>> values['x'] = 3
    >>> values
        ChainMap({'x': 3}, {'x': 2}, {'x': 1})
    >>> values['x']
        3
    
    # Discard last mapping
    >>> values = values.parents
    >>> values['x']
        2
    
    # Discard last mapping
    >>> values = values.parents
    >>> values['x']
        1
    >>> values
        ChainMap({'x': 1})
    ```    
# 字符串与文本
## 字符串分割
1. 简单分割
    ```
    string.split()  
    ```    
2. 指定多个分割符或分隔符周围不确定
    ```    
    >>> line = 'asdf fjdk; afed, fjek,asdf, foo'
    >>> import re
    
    # 匹配 , ; 空格, 并且后面紧跟任意个的空格.
    >>> re.split(r'[;,\s]\s*', line)
        ['asdf', 'fjdk', 'afed', 'fjek', 'asdf', 'foo']
    ```    
    如果正则表达式中有括号分组, 那么被匹配的文本也将出现在结果列表中.
    ```
    >>> fields = re.split(r'(;|,|\s)\s*', line)
    >>> fields
        ['asdf', ' ', 'fjdk', ';', 'afed', ',', 'fjek', ',', 'asdf', ',', 'foo']
    
    >>> re.split(r'(?:,|;|\s)\s*', line)
        ['asdf', 'fjdk', 'afed', 'fjek', 'asdf', 'foo']
    ```        
    有时候, 获取分割字符也是有用的.
    ```
    >>> values = fields[::2]
    >>> delimiters = fields[1::2] + ['']
    >>> values
        ['asdf', 'fjdk', 'afed', 'fjek', 'asdf', 'foo']
    >>> delimiters
        [' ', ';', ',', ',', ',', '']
    
    # Reform the line using the same delimiters
    >>> ''.join(v+d for v,d in zip(values, delimiters))
        'asdf fjdk;afed,fjek,asdf,foo'
    ```    

## 字符串匹配
1. 检查字符串开头或结尾匹配: str.startswith(), str.endswith()
    ```
        >>> filename = 'spam.txt'
        >>> filename.endswith('.txt')
            True
    ```        
    如果检查多种匹配可能, 只要将所有的匹配放入到一个**元组**中即可
    ```
    >>> import os
    >>> filenames = os.listdir('.')
    >>> filenames
        [ 'Makefile', 'foo.c', 'bar.py', 'spam.c', 'spam.h' ]
    >>> [name for name in filenames if name.endswith(('.c', '.h')) ]
        ['foo.c', 'spam.c', 'spam.h'
    >>> any(name.endswith('.py') for name in filenames)
        True
    ```    

2. glob 通配符匹配字符串: fnmatch.fnmatch(), fnmatch.fnmatchcase()
    
    fnmatch() 函数匹配能力介于简单的字符串方法和强大的正则表法式之间.

    但是如果你的代码需要做文件名的匹配, 最好使用 glob 模块
    ```
    >>> from fnmatch import fnmatch, fnmatchcase
    >>> fnmatch('foo.txt', '*.txt')
        True
    >>> fnmatch('foo.txt', '?oo.txt')
        True
    >>> fnmatch('Dat45.csv', 'Dat[0-9]*')
        True
    >>> names = ['Dat1.csv', 'Dat2.csv', 'config.ini', 'foo.py']
    >>> [name for name in names if fnmatch(name, 'Dat*.csv')]
        ['Dat1.csv', 'Dat2.csv']
    ```        
    fnmatch.fnmatch() 使用底层的操作系统的大小写敏感规则来匹配. fnmatch.fnmatchcase() 则完全使用自定义的模式做大小写匹配.

    ```
    # On OS X (Mac)
    >>> fnmatch('foo.txt', '*.TXT')
        False
    
    # On Windows
    >>> fnmatch('foo.txt', '*.TXT')
        True

    # fnmatchcase()
    >>> fnmatchcase('foo.txt', '*.TXT')
        False
    ```        
3. str.find()

    如果匹配到, 则返回匹配第一个字符的索引;
    如果没有匹配到, 则返回负数(-1)

4. re 与正则表达式, re.compile(),re.mathc(),re.findall(),re.finditer()
    ```
    >>> text1 = '11/27/2012'
    >>> text2 = 'Nov 27, 2012'

    >>> import re

    # Simple matching: \d+ means match one or more digits
    >>> if re.match(r'\d+/\d+/\d+', text1):
            print('yes')
        yes

    >>> if re.match(r'\d+/\d+/\d+', text2):
            print('yes')
    ```            
    使用同一个模式做多次匹配, 可以先将模式字符串预编译为模式对象.
    ```
    >>> datepat = re.compile(r'\d+/\d+/\d+')

    >>> if datepat.match(text1): print "yes"
        yes

    >>> if datepat.match(text2): print "yes"
    ```    
    re.match() 总是从字符串开始去匹配, re.findall() 查找字符串任意部分的模式出现位置, 并以列表形式返回所有的匹配. re.finditer() 同 re.findall() 以迭代方式返回匹配.
    ```
    >>> text = 'Today is 11/27/2012. PyCon starts 3/13/2013.'
    >>> datepat.findall(text)
        ['11/27/2012', '3/13/2013']
    ```        
    定义正则时, 通常利用括号来捕获分组. 捕获分组可以使得后面的处理更加简单, 因为可以分别为每个组的内容提取出来.
    ```
    >>> datepat = re.compile(r'(\d+)/(\d+)/(\d+)')

    >>> m = datepat.match('11/27/2012')
    >>> m
        <_sre.SRE_Match object at 0x1005d2750>
    
    # Extract the contents of each group
    >>> m.group(0)
        '11/27/2012'
    >>> m.group(1)
        '11'
    >>> m.group(2)
        '27'
    >>> m.group(3)
        '2012'
    >>> m.groups()
        ('11', '27', '2012')
    >>> month, day, year = m.groups()
    
    
    # Find all matches (notice splitting into tuples)
    >>> text
        'Today is 11/27/2012. PyCon starts 3/13/2013.'
    >>> datepat.findall(text)
        [('11', '27', '2012'), ('3', '13', '2013')]
    >>> for month, day, year in datepat.findall(text):
            print('{}-{}-{}'.format(year, month, day))
    
        2012-11-27
        2013-3-13


    # re 模块级别的函数
    >>> re.findall(r'(\d+)/(\d+)/(\d+)', text)
        [('11', '27', '2012'), ('3', '13', '2013')]
    ```    

## 字符串替换
1. str.replace()
    ```    
    >>> text = 'yeah, but no, but yeah, but no, but yeah'
    >>> text.replace('yeah', 'yep')
        'yep, but no, but yep, but no, but yep'
    ```        
2. re.sub(), re.subn()
    ```
    >>> text = 'Today is 11/27/2012. PyCon starts 3/13/2013.'
    >>> import re
    >>> re.sub(r'(\d+)/(\d+)/(\d+)', r'\3-\1-\2', text)
        'Today is 2012-11-27. PyCon starts 2013-3-13.'


    # 预编译处理
    >>> import re
    >>> datepat = re.compile(r'(\d+)/(\d+)/(\d+)')
    >>> datepat.sub(r'\3-\1-\2', text)
        'Today is 2012-11-27. PyCon starts 2013-3-13.'
    ```    
    除了替换后的结果, 还需要知道共替换了几次 `re.subn()`.
    ```
    >>> newtext, n = datepat.subn(r'\3-\1-\2', text)
    >>> newtext
        'Today is 2012-11-27. PyCon starts 2013-3-13.'
    >>> n
        2
    ```

    传递一个替换回调函数: 一个替换回调函数的参数是一个 `match` 对象, 也就是 `match()` 或者 `find()` 返回的对象. 使用 `group()` 方法来提取特定的匹配部分. 回调函数最后返回替换字符串.
    ```
    >>> from calendar import month_abbr
    >>> def change_date(m):
            mon_name = month_abbr[int(m.group(1))]
            return '{} {} {}'.format(m.group(2), mon_name, m.group(3))

    >>> datepat.sub(change_date, text)
        'Today is 27 Nov 2012. PyCon starts 13 Mar 2013.'
    ```        
## 文本操作时, 忽略大小写.

1. re.IGNORECASE
    ```
    >>> text = 'UPPER PYTHON, lower python, Mixed Python'
    >>> re.findall('python', text, flags=re.IGNORECASE)
        ['PYTHON', 'python', 'Python']
    >>> re.sub('python', 'snake', text, flags=re.IGNORECASE)
        'UPPER snake, lower snake, Mixed snake'
    ```
2. re.DOTALL
    
    `re.DOTALL` 让正则表达式中的 `.` 匹配包括换行符在内的任意字符.

## 处理 Unicode 字符串
2.9 将 Unicode 文本标准化.


# 数字,日期和时间

## 数字的四舍五入
1. round(value, ndigits) : 四舍五入
    ```    
    >>> round(1.23, 1)
        1.2
    >>> round(1.27, 1)
        1.3
    >>> round(-1.27, 1)
        -1.3
    >>> round(1.25361,3)
        1.254
    ```        
    当一个值刚好在两个边界的中间的时候, `round()` 返回离他最近的偶数. 即 1.5 和 2.5 四舍五入后都得到 2.
    ```
    >>> round(1.5)
        2.0

    >>> round(2.5)
        3.0
    ```        
    给 `round()` 函数的 `ndigits` 参数也可以是负数, 此时, 舍入运算会作用在十位, 百位, 千位等上面.
    ```
    >>> a = 1627731
    >>> round(a, -1)
        1627730
    >>> round(a, -2)
        1627700
    >>> round(a, -3)
        1628000
    ```
    不要把四舍五入运算与格式化输出混淆.

    ```
    >>> x = 1.23456
    >>> format(x, '0.2f')
        '1.23'
    >>> format(x, '0.3f')
        '1.235'
    >>> 'value is {:0.3f}'.format(x)
        'value is 1.235'
    ```
2. decimal : 精确的数学运算
    
    decimal 模块实现了 IBM 的 **通用小数运算规范**, 但会有一定的性能损耗.
    ```
    >>> from decimal import Decimal
    >>> a = Decimal('4.2')      // 参数为字符串
    >>> b = Decimal('2.1')      // 参数为字符串
    >>> a + b
        Decimal('6.3')
    >>> print(a + b)
        6.3
    >>> (a + b) == Decimal('6.3')
        True
    ```
    Decimal 对象支持所有的常用数学计算.

    decimal 模块的一个主要特征是允许你控制计算的每一方面, 包括数字位数和四舍五入计算.
    ```
    >>> from decimal import localcontext
    >>> a = Decimal('1.3')
    >>> b = Decimal('1.7')
    >>> print(a / b)
        0.7647058823529411764705882353
    >>> with localcontext() as ctx:
            ctx.prec = 3
            print(a / b)
    
        0.765
    >>> with localcontext() as ctx:
            ctx.prec = 50
            print(a / b)
    
        0.76470588235294117647058823529411764705882352941176
    ```
3. format() : 数字的格式化输出

    `format()` 格式化输出数字, 支持 浮点数 和 decimal 模块中的 Decimal 对象.

    格式化输出单个数字的时候, 可以使用内置的 `format()` 函数. 指出数字的位数后, 结果值或根据 `round()` 函数同样的规则进行四舍五入.
    ```
    >>> x = 1234.56789

    # Two decimal places of accuracy
    >>> format(x, '0.2f')
        '1234.57'

    # Right justified in 10 chars, one-digit accuracy
    >>> format(x, '>10.1f')
        '    1234.6'

    # Left justified
    >>> format(x, '<10.1f')
        '1234.6    '

    # Centered
    >>> format(x, '^10.1f')
        '  1234.6  '

    # Inclusion of thousands separator
    >>> format(x, ',')
        '1,234.56789'
    >>> format(x, '0,.1f')
        '1,234.6'
    ```
    使用指数法输出, 将 f 改成 e/E 即可.
    ```
    >>> format(x, 'e')
        '1.234568e+03'
    >>> format(x, '0.2E')
        '1.23E+03'
    ```
    指定宽度和精度: 同时指定宽度和精度的一般形式是 `[<>^]?width[,]?(.digits)?` ，其中 `width` 和 `digits` 为整数，`?` 代表可选部分. 同样的格式也被用在字符串的 format() 方法中
    ```
    >>> 'The value is {:0,.2f}'.format(x)
        'The value is 1,234.57'
    ```
4. 二进制 bin(), 八进制 oct(), 十六进制 hex() 整数
    
    大多数情况下处理二进制, 八进制, 十六进制整数是简单的. 只需记住那些转换属于整数和其对应的文本表示之间的转换即可. **永远只有一种整数类型**.
    ```
    >>> x = 1234
    >>> bin(x)
        '0b10011010010'
    >>> oct(x)
        '0o2322'
    >>> hex(x)
        '0x4d2'
    ```
    不输出 `0b`, `0o`, `0x` 前缀.
    ```
    >>> format(x, 'b')
        '10011010010'
    >>> format(x, 'o')
        '2322'
    >>> format(x, 'x')
        '4d2'
    ```
    为了以不同的进制转换数字字符串, 使用带有进制的 `int()` 函数即可.
    ```
    >>> int('4d2', 16)
        1234
    >>> int('10011010010', 2)
        1234
    ```    
    Python 的八进制语法:
    ```
    >>> import os
    >>> os.chmod("script.py", 0o755)    // 注意 0o755
    ```

5. 整数与字节字符串: int.from_bytes(), int.to_bytes(), int.bit_length(). **Python3** 
    
    字节顺序规则 (little或big) 仅仅指定了构建整数时的字节的低位高位排列方式。

    `int.from_bytes()` 将 bytes 解析为整数.
    ```
    data = b'\x00\x124V\x00x\x90\xab\x00\xcd\xef\x01\x00#\x004'

    >>> len(data)
        16
    >>> int.from_bytes(data, 'little')
        69120565665751139577663547927094891008
    >>> int.from_bytes(data, 'big')
        94522842520747284487117727783387188
    ```
    `int.to_bytes()` 将一个大整数转换为一个字节字符串.
    ```
    >>> x = 94522842520747284487117727783387188
    >>> x.to_bytes(16, 'big')
        b'\x00\x124V\x00x\x90\xab\x00\xcd\xef\x01\x00#\x004'
    >>> x.to_bytes(16, 'little')
        b'4\x00#\x00\x01\xef\xcd\x00\xab\x90x\x00V4\x12\x00'
    ```
    `int.bit_length()` 确定字节大小
    ```
    >>> x = 523 ** 23
    >>> x
        335381300113661875107536852714019056160355655333978849017944067
    >>> x.to_bytes(16, 'little')
        Traceback (most recent call last):
        File "<stdin>", line 1, in <module>
        OverflowError: int too big to convert
    >>> x.bit_length()
        208
    >>> nbytes, rem = divmod(x.bit_length(), 8)
    >>> if rem:
            nbytes += 1
    
    >>> x.to_bytes(nbytes, 'little')
        b'\x03X\xf1\x82iT\x96\xac\xc7c\x16\xf3\xb9\xcf...\xd0'
    ```
6. 正无穷, 负无穷或 Nan 的浮点数 : float()
    ```
    >>> a = float('inf')
    >>> b = float('-inf')
    >>> c = float('nan')
    >>> a
        inf
    >>> b
        -inf
    >>> c
        nan
    ```

    测试 正无穷, 负无穷和 Nan 的存在，使用 `math.isinf()` 和 `math.isnan()` 函数
    ```
    >>> math.isinf(a)
        True
    >>> math.isnan(c)
        True
    ```
    无穷大数在执行数学计算的时候会传播:
    ```
    >>> a = float('inf')
    >>> a + 45
        inf
    >>> a * 10
        inf
    >>> 10 / a
        0.0

    # 有些操作时未定义的额会返回一个 NaN 结果
    >>> a = float('inf')
    >>> a/a
        nan
    >>> b = float('-inf')
    >>> a + b
        nan
    ```
    NaN 值会在所有操作中传播, 而不会产生异常.
    ```
    >>> c = float('nan')
    >>> c + 23
        nan
    >>> c / 2
        nan
    >>> c * 2
        nan
    >>> math.sqrt(c)
        nan

    # NaN 值的一个特别的地方是, 他们之间的比较操作总是返回 False. 
    # 也因此, 测试 NaN 值唯一安全的方法就是使用 math.isnan()
    >>> c = float('nan')
    >>> d = float('nan')
    >>> c == d
        False
    >>> c is d
        False
    ```
7. fractions() 分数计算
    
    fractions 模块可以被用来执行包含分数的数学运算.
    ```
    >>> from fractions import Fraction
    >>> a = Fraction(5, 4)
    >>> b = Fraction(7, 16)
    >>> print(a + b)
        27/16
    >>> print(a * b)
        35/64

    # Getting numerator/denominator
    >>> c = a * b
    >>> c.numerator
        35
    >>> c.denominator
        64

    # Converting to a float
    >>> float(c)
        0.546875

    # Limiting the denominator of a value
    >>> print(c.limit_denominator(8))
        4/7

    # Converting a float to a fraction
    >>> x = 3.75
    >>> y = Fraction(*x.as_integer_ratio())
    >>> y
        Fraction(15, 4)
    ```
8. numpy 大数据集运算(数组/网格)/矩阵/线性代数运算
    
    底层实现中, NumPy 数组使用了 C 或者 Fortran 语言的机制分配内存, 即他们是一个非常大的连续的并由同类型数据组成的内存区域. 所以, 可以构造一个比普通 Python 列表大的多的数组.
    ```
    >>> grid += 10
    >>> grid
        array([[ 10., 10., 10., ..., 10., 10., 10.],
            [ 10., 10., 10., ..., 10., 10., 10.],
            [ 10., 10., 10., ..., 10., 10., 10.],
            ...,
            [ 10., 10., 10., ..., 10., 10., 10.],
            [ 10., 10., 10., ..., 10., 10., 10.],
            [ 10., 10., 10., ..., 10., 10., 10.]])

    >>> np.sin(grid)
        array([[-0.54402111, -0.54402111, -0.54402111, ..., -0.54402111, -0.54402111, -0.54402111],
               [-0.54402111, -0.54402111, -0.54402111, ..., -0.54402111, -0.54402111, -0.54402111],
               [-0.54402111, -0.54402111, -0.54402111, ..., -0.54402111, -0.54402111, -0.54402111],
                ...,
               [-0.54402111, -0.54402111, -0.54402111, ..., -0.54402111, -0.54402111, -0.54402111],
               [-0.54402111, -0.54402111, -0.54402111, ..., -0.54402111, -0.54402111, -0.54402111],
               [-0.54402111, -0.54402111, -0.54402111, ..., -0.54402111, -0.54402111, -0.54402111]])
    ```
    NumPy 的一个主要特征是他会给 Python 提供一个数组对象, 相比标准的 Python 列表更适合做数学运算.
    ```
        >>> import numpy as np
        >>> ax = np.array([1, 2, 3, 4])
        >>> ay = np.array([5, 6, 7, 8])
        >>> ax * 2              // 标量运算
            array([2, 4, 6, 8])
        >>> ax + 10             // 标量运算
            array([11, 12, 13, 14])
        >>> ax + ay
            array([ 6, 8, 10, 12])
        >>> ax * ay
            array([ 5, 12, 21, 32])
    ```
    对整个数组中的所有元素同时执行数学运算可以使得作用在整个数组上的函数 运算简单而快速.
    ```
        >>> def f(x):
                return 3*x**2 - 2*x + 7

        >>> f(ax)
            array([ 8, 15, 28, 47])
    ```
    其他通用数学函数: 使用这些通用函数比循环数组并使用 math 模块中的函数要快得多.
    ```
        >>> np.sqrt(ax)
            array([ 1. , 1.41421356, 1.73205081, 2. ])
        >>> np.cos(ax)
            array([ 0.54030231, -0.41614684, -0.9899925 , -0.65364362])
    ```
    NumPy 中的索引功能: 它扩展了 Python 列表的索引功能, 特别是对于多维数组.
    ```
        >>> a = np.array([[1, 2, 3, 4], [5, 6, 7, 8], [9, 10, 11, 12]])
        >>> a
            array([[ 1, 2, 3, 4],
                   [ 5, 6, 7, 8],
                   [ 9, 10, 11, 12]])

        # Select row 1
        >>> a[1]
            array([5, 6, 7, 8])

        # Select column 1
        >>> a[:,1]
            array([ 2, 6, 10])

        # Select a subregion and change it
        >>> a[1:3, 1:3]
            array([[ 6, 7],
                   [10, 11]])
        >>> a[1:3, 1:3] += 10
        >>> a
            array([[ 1, 2, 3, 4],
                   [ 5, 16, 17, 8],
                   [ 9, 20, 21, 12]])

        # Broadcast a row vector across an operation on all rows
        >>> a + [100, 101, 102, 103]
            array([[101, 103, 105, 107],
                   [105, 117, 119, 111],
                   [109, 121, 123, 115]])
        >>> a
            array([[ 1, 2, 3, 4],
                   [ 5, 16, 17, 8],
                   [ 9, 20, 21, 12]])

        # Conditional assignment on an array
        >>> np.where(a < 10, a, 10)
            array([[ 1, 2, 3, 4],
                   [ 5, 10, 10, 8],
                   [ 9, 10, 10, 10]])
    ```
    矩阵 : 类似数组对象, 但遵循线性代数的计算规则.
    ```
        >>> import numpy as np
        >>> m = np.matrix([[1,-2,3],[0,4,5],[7,8,-9]])
        >>> m
            matrix([[ 1, -2, 3],
                    [ 0, 4, 5],
                    [ 7, 8, -9]])

        # Return transpose
        >>> m.T
            matrix([[ 1, 0, 7],
                    [-2, 4, 8],
                    [ 3, 5, -9]])

        # Return inverse
        >>> m.I
            matrix([[ 0.33043478, -0.02608696, 0.09565217],
                    [-0.15217391, 0.13043478, 0.02173913],
                    [ 0.12173913, 0.09565217, -0.0173913 ]])

        # Create a vector and multiply
        >>> v = np.matrix([[2],[3],[4]])
        >>> v
            matrix([[2],
                    [3],
                    [4]])
        >>> m * v
            matrix([[ 8],
                    [32],
                    [ 2]])
    ```
    `numpy.linalg` 子包中包含更多的操作函数.
    ```
        >>> import numpy.linalg

        # Determinant
        >>> numpy.linalg.det(m)
        -229.99999999999983

        # Eigenvalues
        >>> numpy.linalg.eigvals(m)
            array([-13.11474312, 2.75956154, 6.35518158])

        # Solve for x in mx = v
        >>> x = numpy.linalg.solve(m, v)
        >>> x
            matrix([[ 0.96521739],
                    [ 0.17391304],
                    [ 0.46086957]])
        >>> m * x
            matrix([[ 2.],
                    [ 3.],
                    [ 4.]])
        >>> v
            matrix([[2],
                    [3],
                    [4]])
    ```
9. `random()` 随机数
    
    `random()` 有大量的函数用来产生随机数和随机选择元素.



    `random.choice(list)` 从一个序列中随机的抽取一个元素
        
        >>> import random
        >>> values = [1, 2, 3, 4, 5, 6]
        >>> random.choice(values)
            2
        >>> random.choice(values)
            3
        >>> random.choice(values)
            1

    `random.sample(list, N)` 提取 N 个不同的元素样本

        >>> random.sample(values, 2)
            [6, 2]
        >>> random.sample(values, 2)
            [4, 3]
        >>> random.sample(values, 3)
            [4, 3, 1]
        >>> random.sample(values, 3)
            [5, 4, 1]

    `random.shuffle(list)` 打乱序列中元素的顺序.

        >>> random.shuffle(values)
        >>> values
            [2, 4, 6, 5, 3, 1]
        >>> random.shuffle(values)
        >>> values
            [3, 5, 2, 1, 6, 4]

    `random.randint(start_num, end_num)` 生成随机整数

        >>> random.randint(0,10)
            0
        >>> random.randint(0,10)
            7
        >>> random.randint(0,10)
            10
        >>> random.randint(0,10)
            3

    `random.random()` 生成 0 ~ 1 之间均匀分布的浮点数.
    
        >>> random.random()
            0.9406677561675867
        >>> random.random()
            0.133129581343897
        >>> random.random()
            0.4144991136919316

    `random.getrandbits(N)` 获取 N 位随机位(二进制)的整数

        >>> random.getrandbits(200)
            335837000776573622800628485064121869519521710558559406913275


    random模块使用 `Mersenne Twister` 算法来计算生成随机数。这是一个确定性算法，但是你可以通过 `random.seed()` 函数修改初始化种子。比如：

        random.seed()               # Seed based on system time or os.urandom()
        random.seed(12345)          # Seed based on integer given
        random.seed(b'bytedata')    # Seed based on byte data

    除了上述介绍的功能，random模块还包含基于**均匀分布**、**高斯分布**和其他分布的随机数生成函数。比如
    - `random.uniform()` 计算均匀分布随机数，
    - `random.gauss()` 计算正态分布随机数
    - 其他随机数算法.

    在random模块中的函数**不应该**用在和密码学相关的程序中。如果你确实需要类似的功能，可以使用`ssl模块`中相应的函数。比如，`ssl.RAND_bytes()` 可以用来生成一个安全的随机字节序列。

## 日期和时间

1. 时间间隔 `dateutil.relativadelta()`  `datetime.timedelta`
    
    `datetime.timedelta`

        >>> from datetime import timedelta
        >>> a = timedelta(days=2, hours=6)
        >>> b = timedelta(hours=4.5)
        >>> c = a + b
        >>> c.days
            2
        >>> c.seconds
            37800
        >>> c.seconds / 3600
            10.5
        >>> c.total_seconds() / 3600
            58.5

    `dateutil.relativadelta()`

        >>> a = datetime(2012, 9, 23)
        >>> a + timedelta(months=1)
            Traceback (most recent call last):
            File "<stdin>", line 1, in <module>
            TypeError: 'months' is an invalid keyword argument for this function
        >>>
        >>> from dateutil.relativedelta import relativedelta
        >>> a + relativedelta(months=+1)
            datetime.datetime(2012, 10, 23, 0, 0)
        >>> a + relativedelta(months=+4)
            datetime.datetime(2013, 1, 23, 0, 0)
        >>>
        
        # Time between two dates
        >>> b = datetime(2012, 12, 21)
        >>> d = b - a
        >>> d
            datetime.timedelta(89)
        >>> d = relativedelta(b, a)
        >>> d
            relativedelta(months=+2, days=+28)
        >>> d.months
            2
        >>> d.days
            28
    
        # 下一个周五
        >>> from datetime import datetime
        >>> from dateutil.relativedelta import relativedelta
        >>> from dateutil.rrule import *
        >>> d = datetime.now()
        >>> print(d)
            2012-12-23 16:31:52.718111

        # 下一个周五
        >>> print(d + relativedelta(weekday=FR))
        2012-12-28 16:31:52.718111
        >>>

        # 上一个周五
        >>> print(d + relativedelta(weekday=FR(-1)))
        2012-12-21 16:31:52.718111

        # 日期修改
        from datetime import date
        d = date.today()    # datetime.date(2017, 12, 11)
        d.replace(day=1)    # datetime.date(2017, 12, 1)
        d.replace(month=1)  # datetime.date(2017, 1, 11)
        
    
2. 字符串转换为日期

    `datetime.strptime`

        >>> from datetime import datetime
        >>> text = '2012-09-20'
        >>> y = datetime.strptime(text, '%Y-%m-%d')
        >>> z = datetime.now()
        >>> diff = z - y
        >>> diff
            datetime.timedelta(3, 77824, 177393)

    `dateutil.parser.parse`

3. 结合时区的日期操作

        >>> from datetime import datetime
        >>> from pytz import timezone
        >>> d = datetime(2012, 12, 21, 9, 30, 0)
        >>> print(d)
        2012-12-21 09:30:00
        
        # Localize the date for Chicago : 本地化时间
        >>> central = timezone('US/Central')
        >>> loc_d = central.localize(d)
        >>> print(loc_d)
            2012-12-21 09:30:00-06:00


        # Convert to Bangalore time : 转换为 班加罗尔 时间
        >>> bang_d = loc_d.astimezone(timezone('Asia/Kolkata'))
        >>> print(bang_d)
            2012-12-21 21:00:00+05:30

        # 时间转换为 UTC 时间
        >>> print(loc_d)
            2013-03-10 01:45:00-06:00
        >>> utc_d = loc_d.astimezone(pytz.utc)
        >>> print(utc_d)
            2013-03-10 07:45:00+00:00

        # 使用ISO 3166国家代码作为关键字去查阅字典 pytz.country_timezones 获取时区
        >>> pytz.country_timezones['IN']
            ['Asia/Kolkata']

        >>> pytz.country_names      # 所有国家全名与 ISO 3166 对应字典.


## 迭代器与生成器

0. 迭代协议机制
    
    `__iter__()`
    `__next__()`
    `StopIteration`

    Python 的迭代协议要求一个 `__iter__()` 方法, 返回一个特殊的迭代器对象, 这个迭代器对象实现了 `__next__()` 方法并通过 `StopIteration` 异常标识迭代完成.

1. 手动遍历迭代器
        
        def manual_iter():
            with open("/etc/passwd") as f:
                try:
                    while True:
                        line = next(f)
                        print line
                except StopIteration:
                    pass

2. `__iter__` 
    
    Python 的迭代协议需要 `__iter__()`  方法返回一个实现了 `__next__()` 方法的迭代器对象. 如果只是遍历其他容器的内容, 无需关系底层是怎样实现的, 所做的只是传递迭代请求即可.

    `iter()` 函数只是简单的调用 `obj.__iter__()` 方法返回对应的迭代器对象.

        class Node:
            def __init__(self, value):
                self._value = value
                self._children = []

            def __repr__(self):
                return 'Node({!r})'.format(self._value)

            def add_child(self, node):
                self._children.append(node)

            def __iter__(self):
                return iter(self._children)

        # Example
        if __name__ == '__main__':
            root = Node(0)
            child1 = Node(1)
            child2 = Node(2)
            root.add_child(child1)
            root.add_child(child2)
            # Outputs Node(1), Node(2)
            for ch in root:
                print(ch)

3. 使用生成器创建迭代器.
    
    一个函数中需要有一个 `yield` 语句即可将其转换为一个生成器, 生成器只能用于迭代操作.

    一个生成器函数主要特征是它只会回应在迭代中使用到的 `next` 操作. 一旦生成器函数返回退出, 迭代终止.

        def frange(start, stop, incre=1):
            x = start
            while x < stop:
                yield x
                x += incre


        >>> def countdown(n):
        ...     print('Starting to count from', n)
        ...     while n > 0:
        ...         yield n
        ...         n -= 1
        ...     print('Done!')
        
        # Create the generator, notice no output appears
        >>> c = countdown(3)
        >>> c
            <generator object countdown at 0x1006a0af0>

        # Run to first yield and emit a value
        >>> next(c)
            Starting to count from 3
            3

        # Run to the next yield
        >>> next(c)
            2

        # Run to next yield
        >>> next(c)
            1

        # Run to next yield (iteration stops)
        >>> next(c)
            Done!
            Traceback (most recent call last):
                File "<stdin>", line 1, in <module>
            StopIteration

4. 实现迭代器协议
    
    `depth_first()` 方法 首先返回自己本身并迭代每一个子节点, 并通过调用子节点的 `depth_first()` 方法(使用 `yield from` 语句) 返回对应元素.

        class Node(object):
            """docstring for Node"""
            def __init__(self, value):
                self._value = value
                self._children = []

            def __repr__(self):
                return "Node({!r})".format(self._value)

            def add_child(self, node):
                self._children.append(node)

            def __iter__(self):
                return iter(self._children)

            def depth_first(self):
                yield self
                for c in self:
                    yield from c.depth_first()


        if __name__ == "__main__":
            root = Node(0)
            child1 = Node(1)
            child2 = Node(2)
            root.add_child(child1)
            root.add_child(child2)

            child1.add_child(Node(3))
            child1.add_child(Node(4))
            child2.add_child(Node(5))

            for ch in root.depth_first():
                print(ch)               # Outputs Node(0), Node(1), Node(3), Node(4), Node(2), Node(5)
            

    手动实现迭代器协议:

        class Node2(object):
            def __init(self, value):
                self._value = value
                self._children = []

            def __repr__(self):
                return "Node2({!r})".format(self._value)

            def add_child(self, node):
                self._children.append(node)

            def __iter__(self):
                return iter(self._children)

            def depth_first(self):
                return DepthFirstIterator(self)

        class DepthFirstIterator(object):
            """
            Depth-first traversal
            """

            def __init__(self, start_node):
                self._node = start_node
                self._children_iter = None
                self._child_iter = None

            def __iter__(self):
                return self

            def __next__(self):
                """
                return myself if just started
                create an iterator for children
                """
                if self._children_iter is None:
                    self._children_iter = iter(self)
                    return self._node
                # if processing a child, return its next item
                elif self._child_iter:
                    try:
                        nextchild = next(self._child_iter)
                        return nextchild
                    except StopIteration:
                        self._child_iter = None
                        return next(self)
                else:
                    self._child_iter = next(self._children_iter).depth_first()
                    return next(self)
                
                    
5. 实现一个反方向的迭代
    
    使用内置的 `reversed()` 函数: 反向迭代仅仅当对象的大小可预先确定或者对象实现了 `__reversed__()` 的特殊方法时才能生效. 如果两者都不符合, 则必须手动转换为一个列表才可以.

        >>> a = range(1,5)
        >> for i in reversed(a): print i

    实现  `__reversed__()` 方法来实现反向迭代

        class Countdown(object):
            def __init__(self, start):
                self.start = start

            def __iter__(self):
                n = self.start
                while n>0:
                    yield n
                    n -= 1

            def __reversed__(self):
                n = 1
                while n <= self.start:
                    yield n
                    n += 1

        for rr in reversed(Countdown(10)):
            print rr
        for rr in Countdown(10):
            print rr

6. 带有外部状态的生成器

        from collections import deque

        class LineHistory:
            def __init__(self, lines, histlen=3):
                self.lines = lines
                self.history = deque(maxlen=3)

            def __iter__(self):
                for lineno, line in enumerate(self.lines, 1):
                    self.history.append((lineno, line))
                    yield line

            def clear(self):
                self.history.clear()

        with open("/path/to/somefile.txt") as f:
            lines = LineHistory(f)
            for line in lines:
                if "python" in line:
                    for lineno, hline in lines.history:
                        print("{}:{}".format(linene, hline), end="")

7. 迭代器/生成器切片`itertools.islice()`
    
    迭代器和生成器不能使用标准的切片操作, 因为他们的长度事先我们并不知道, 并且也没有实现索引.

    `itertools.islice()` 函数返回一个可以生成指定元素的迭代器, 他通过遍历并丢弃知道切片开始索引位置的所有元素. 然后, 开始一个一个的返回元素, 知道切片结束索引位置.

    `islice()` 会消耗传入的迭代器中的数据. 因此,必须考虑迭代器时不可逆的事实.

        >>> def count(n):
        ...     while True:
        ...         yield n
        ...         n += 1
        ...
        >>> c = count(0)
        >>> c[10:20]
            Traceback (most recent call last):
                File "<stdin>", line 1, in <module>
            TypeError: 'generator' object is not subscriptable

        
        # Now using islice()
        >>> import itertools
        >>> for x in itertools.islice(c, 10, 20):
                print(x)
            
            10
            11
            12
            13
            14
            15
            16
            17
            18
            19
    
8. 跳过可迭代对象的开始部分`itertools.dropwhile()` 和 `itertools.islice()`
    
    `itertools.dropwhile()` 接受一个函数对象和一个可迭代对象作为参数, 它返回一个迭代器对象, 丢弃原有序列知道函数返回 True 之前的所有元素, 然后返回后面所有的元素.

        # 跳过文件 开头的, 以 `#` 开始的行.
        from itertools import dropwhile

        with open("/etc/fstab") as f:
            for line in dropwhile(lambda line: line.startswith("#"), f):
                print(line, end="")


        # 跳过文件中, 所有以 `#` 开头的行.
        with open('/etc/passwd') as f:
            lines = (line for line in f if not line.startswith('#'))
            for line in lines:
                print(line, end='')

    `itertools.islice()` 如果知道要跳过的元素的个数时.

        from itertools import islice

        items = ['a', 'b', 'c', 1, 4, 10, 15]

        for x in islice(iterms, 3, None):
            print x

9. 迭代遍历一个集合中元素的所有可能的排列或组合
    
    `itertools.permutations()` 它接受一个集合并产生一个元素序列, 每个元组由集合中的所有元素的一个可能排列组成, 即通过打乱集合中元素排列顺序生成一个元组. 另, 可以传递一个可选的长度参数, 得到指定长度的所有排列.

        items = ["a", "b", "c"]

        from itertools import permutations

        for p in permutations(items):
            print p

        # output
        ('a', 'b', 'c')
        ('a', 'c', 'b')
        ('b', 'a', 'c')
        ('b', 'c', 'a')
        ('c', 'a', 'b')
        ('c', 'b', 'a')


    `itertools.combinations()` 可以得到输入集合中元素的所有组合. 对于 combinations() 来说, 元素的顺序已经不重要了, 即 ("a", "b") 跟 ("b", "a") 其实是一样的(最终只会输出一个).

        >>> from itertools import combinations
        >>> for c in combinations(items, 3):
        ...     print(c)
        ...
            ('a', 'b', 'c')

        >>> for c in combinations(items, 2):
        ...     print(c)
        ...
            ('a', 'b')
            ('a', 'c')
            ('b', 'c')

        >>> for c in combinations(items, 1):
        ...     print(c)
        ...
            ('a',)
            ('b',)
            ('c',)

    `itertools.combinations_with_replacement()` 计算组合的时候, 一旦元素被选取就会从候选中剔除掉, 那么接下来就不会考虑他了. 而 `itertools.combinations_with_replacement()` 允许一个元素被选择多次.

        for c in combinations_with_replacement(items, 3):
            print c

        # output 
        ('a', 'a', 'a')
        ('a', 'a', 'b')
        ('a', 'a', 'c')
        ('a', 'b', 'b')
        ('a', 'b', 'c')
        ('a', 'c', 'c')
        ('b', 'b', 'b')
        ('b', 'b', 'c')
        ('b', 'c', 'c')
        ('c', 'c', 'c')


10. 在迭代一个序列的同时, 跟踪正在被处理的元素索引
    
    `enumerate()` 可以实现在迭代一个序列的同时, 跟踪正在被处理的元素索引.

        items = ["a", "b", "c"]

        for idx, val in enumerate(items, 1):
            print idx, val

        1 a
        2 b
        3 c

    在遍历文件时, 想在错误消息中使用行号定位时, 非常有用.

        def parse_date(filename):
            with open(filename, 'rt') as f:
                for lineno, line in enumerate(f, 1):
                    fields = line.split()
                    try:
                        count = int(filelds[1])
                        # ...
                    except ValueError as e:
                        print("Line {} : Parse error: {}".format(lineno, e))

    一个简单的单词统计程序: 统计单词都出现在那些行

        from collections import defaultdict

        word_summary = defaultdict(list)

        with open("/path/to/file.txt", 'r') as f:
            lines = f.readlines()

            for idx, line in enumerate(lines):
                words = [w.strip().lower() for w in line.split()]
                for word in words:
                    word_summary[word].append(idx)

11. 迭代多个序列, 每次分别从一个序列中取一个元素.

    `zip(list_a, list_b)` 会生成一个可返回元组 `(x,y)`的迭代器, 其中 x 来自 list_a, y 来自 list_b. 一旦其中某个序列结束, 则整个迭代宣告结束, 因此, 迭代长度跟参数中最短序列长度一致.

        >>> a = [1, 2, 3]
        >>> b = ['w', 'x', 'y', 'z']
        >>> for i in zip(a,b):
                print(i)
            
            (1, 'w')
            (2, 'x')
            (3, 'y')

    `itertools.zip_longest()` 则一最长的序列为准, 返回元组.

        >>> from itertools import zip_longest
        >>> for i in zip_longest(a,b):
                print(i)
            
            (1, 'w')
            (2, 'x')
            (3, 'y')
            (None, 'z')

        >>> for i in zip_longest(a, b, fillvalue=0):
                print(i)
            
            (1, 'w')
            (2, 'x')
            (3, 'y')
            (0, 'z')

12. 不同集合上元素的迭代.

    `itertools.chain()` 接受一个或多个可迭代对象作为输入参数, 然后创建一个**迭代器**, 依次连续的返回每个可迭代对象中的元素. 对不同集合中所有元素执行某些操作, 即把不同集合当做一个集合来处理, 更加优雅, 而不是用 for 循环.

        >>> a = [1, 2, 3, 4]
        >>> b = ['x', 'y', 'z']
        >>> from itertools import chain
        >>> for x in chain(a,b):
                print x
            1
            2
            3
            4
            x
            y
            z

13. 创建数据处理管道: 生成器.
    
    一个遍历目录寻找文件, 并搜索文件内容的程序.

    在如下代码中, `yield` 作为数据的生产者, 而 for 循环语句作为数据的消费者. 当这些生成器被连在一起后, 每个 `yield` 会将一个单独的数据元素传递给迭代处理管道的下一阶段. 在例子的最后部分, `sum()` 函数是最终的程序驱动者, 每次从生成器管道中提取出一个元素.

        import os
        import fnmatch
        import gzip
        import bz2
        import re


        def gen_find(filepat, top):
            """
            Find all filenames in a dir tree that match a shell wildcard pattern
            """
            for path, dirlist, filelist in os.walk(top):
                for name in fnmatch.filter(filelist, filepat):
                    yield os.path.join(path, name)

        def gen_opeber(filenames):
            """
            Open a sequence of filenames once at a time producing a file object. 
            The file is closed immediately when proceeding to the next iteration.
            """
            for filename in filenames:
                if filenam.endswith(".gz"):
                    f = gzip.open(filename, 'rt')
                elif filename.endswith(".bz2"):
                    f = bz2.open(filename, "rt")
                else:
                    f = open(filename, 'rt')

                yield f

                f.close()

        def gen_concatenate(iterators):
            """
            Chain a sequence of iterators together into a single sequence. 
            将输入序列拼接成一个很长的序列.

            yield from it : 将 yield 操作代理到父生成器上, 简单的返回生成器 it 所产生的所有值.
            """
            for it in iterators:
                yield from it

        def gen_grep(pattern, lines):
            """
            Look for a regex pattern in a sequence of lines.
            """
            pat = re.compile(pattern)
            for line in lines:
                if pat.search(line):
                    yield line



        lognames = gen_find("access-log*", 'www')
        files = gen_opener(lognames)
        lines = gen_concatenate(files)
        pylines = gen_grep('(?i)python', lines)
        bytecolumn = (line.rsplit(None, 1)[1] for line in pylines)
        all_bytes = (int(x) for x in bytecolumn if x != '-')
        print("Total", sum(all_bytes))

14. 将一个多层嵌套的序列展开成一个单层列表 `yield from`.
    
    `yield from` 在希望在生成器中调用其他生成器作为子例程时非常有用.

    `yield from` 在涉及到基于协程和生成器的并发编程中扮演着更加重要的角色.

        from collection import Iterable
        def flatten(items, ignore_types=(str, bytes)):
            for x in items:
                if isinstance(x, Iterable) and not isinstance(x, ignore_types):
                    yield from flatten(x)
                eles:
                    yield x

        items = [1, 2, [3, 4, [5, 6], 7], 8]
        for x in flatten(items):
            print(x)
    
15. 将多个序列, 合并到一个序列然后迭代遍历 `heapq.merge()`.
    
    `heapq.merge()` 需要所有输入序列必须是拍过序的.他仅仅是检查所有序列的开始部分, 并返回最小的值, 这个过程会一直持续直到所有输入序列中的元素都被遍历完.

    `heapq.merge()` 可迭代特性意味着他不会立马读取所有序列, 可以再非常长的序列中使用它, 而不会有太大的开销.
    
         >>> import heapq

         >>> b = [2, 5, 6, 11]

         >>> a = [1, 4, 7, 10]

         >>> for i in heapq.merge(a,b):
                 print(i)
                 
            1
            2
            4
            5
            6
            7
            10
            11

        >>> a
        >>> [1, 4, 7, 10]

        >>> b
        >>> [2, 5, 6, 11]

16. 迭代器代替 while 无线循环
    
    `iter()` 函数可以接受一个可选的 `callable` 对象和一个标记(结尾)值作为输入参数. 当以这种方式使用时, 他会创建一个迭代器, 这个迭代器会不断调用`callable` 对象直到返回值和标记值相等位置.

    该方法对于一些特定的会被重复调用的函数很有效果, 如涉及到 IO 调用的函数(从套接字或文件中以数据块的方式读取数据).

        CHUNKSIZE=8192

        def reader(s):
            for chunk in iter(lamdba: s.recv(CHUNKSIZE), b""):
                process_data(data)


## 文件与IO

1. 读写文本/二进制数据
        
        # 指定文件换行符
        open('somefile.txt', 'rt', newline='')  

        # 指定编码
        open('sample.txt', 'rt', encoding='ascii')

        # 编码出现问题时, 使用 `errors` 参数来处理错误.
        open('sample.txt', 'rt', encoding='ascii', errors='replace')
        open('sample.txt', 'rt', encoding='ascii', errors='ignore')

        # 读写模式
        rt: 文本模式, 读
        wt: 文本模式, 写, 之前的内容会被覆盖重写.
        at: 文本模式, 写, 追加
        xt: 文件在文件系统上不存在, 才会写入.即不允许覆盖已存在的文件内容.

        ## 在读取和写入二进制数据时, 需要指明所有返回的数据都是字节字符串格式的, 而不是文本字符串.
        rb: 二进制模式, 读,
        wb: 二进制模式, 写,
        xb: 文件在文件系统上不存在, 才会写入.即不允许覆盖已存在的文件内容.

        # Read the entire file as a single byte string
        with open('somefile.bin', 'rb') as f:
            data = f.read()

        # Write binary data to a file
        with open('somefile.bin', 'wb') as f:
            f.write(b'Hello World')

        # 从二进制模式的文件中读取或写入文本数据，必须确保要进行解码和编码操作.
        with open('somefile.bin', 'rb') as f:
            data = f.read(16)
            text = data.decode('utf-8')

        with open('somefile.bin', 'wb') as f:
            text = 'Hello World'
            f.write(text.encode('utf-8'))

        # 二进制 IO 的一个鲜为人知的特性就是: 数组和C结构体能直接写入, 而不需要中间转换为对象.
        import array
        nums = array.array('i', [1, 2, 3, 4])
        with open('data.bin','wb') as f:
            f.write(nums)

2. 将 `print()` 函数的输出重定向到一个文件中取, 分割符, 换行符
        
        # 文件必须是以文本模式打开的.
        with open("somefile.txt", 'rt') as f:
            print("Hello World!", file=f)

        # 以非空格分隔符来输出数据, 设置换行符.
        >>> print('ACME', 50, 91.5, sep=',', end='!!\n')
            ACME,50,91.5!!

        >>> row = ('ACME', 50, 91.5)
        >>> print(*row, sep=',')
            ACME,50,91.5

3. 字符串的 IO 操作. `io.StringIO()` 和 `io.BytesIO()`

    使用操作类文件对象的程序来操作文本或二进制字符串.
    `io.StringIO` `io.BytesIO` 在模拟普通的文件时, 很有用. 但是, 他们的实例没有正确的整数类型文件描述符, 因此, 他们不能再那些需要使用真实的系统级文件如文件, 管道或者套接字的程序中使用.

    `io.StringIO()` 只能用于文本

        >>> s = io.StringIO()
        >>> s.write('Hello World\n')
            12
        >>> print('This is a test', file=s)
            15
        # Get all of the data written so far
        >>> s.getvalue()
            'Hello World\nThis is a test\n'
        >>>

        # Wrap a file interface around an existing string
        >>> s = io.StringIO('Hello\nWorld\n')
        >>> s.read(4)
            'Hell'
        >>> s.read()
            'o\nWorld\n'

    `io.BytesIO()` 二进制数据.

        >>> s = io.BytesIO()
        >>> s.write(b'binary data')
        >>> s.getvalue()
            b'binary data'

4. 读写压缩文件`gzip``bz2`
    
    以文本(rt,wt)/二进制(rb, wb)形式读写数据

        # 读取
        import  gzip
        with gzip.open("somefile.zip", 'rt') as f:
            text = f.read()

        import bz2
        with bz2.open("somefile.bz2", 'rt') as f:
            text = f.read()

        # 写入
        import gzip
        with gzip.open('somefile.gz', 'wt') as f:
            f.write(text)

        
        import bz2
        with bz2.open('somefile.bz2', 'wt') as f:
            f.write(text)


        # 指定压缩级别, 默认为 9, 即最高压缩级别.
        with gzip.open('somefile.gz', 'wt', compresslevel=5) as f:
            f.write(text)

    `gzip.open()` 和 `bz2.open()` 可以作用在一个已存在并以二进制模式打开的文件上.这样就允许, `gzip` 和 `bz2` 模块工作在很多类文件对象上, 如套接字, 管道和内存中的文件等.
    
        import gzip
        f = open('somefile.gz', 'rb')
        with gzip.open(f, 'rt') as g:
            text = g.read()

5. 内存映射的二进制文件`mmp`
    
    内存映射一个二进制文件到一个可变字节数组中, 目的可能是为了随机访问他的内容或是原地做些修改.

        import os
        import mmap

        def memory_map(filename, access=mmap.ACCESS_WRITE):
            size = os.path.getsize(filename)
            fd = os.open(filename, os.O_RDWR)
            return mmap.mmap(fd, szie, access=access)

        size = 1000000
        with open('data', 'wb') as f:
            f.seek(size - 1)
            f.write(b'\x00')

        with memory_map('data') as m:
            print(len(m))
            print(m[0:10])

    mmap.ACCESS_WRITE : 同时支持读和写操作.
    mmap.ACCESS_READ : 只读
    mmap.ACCESS_COPY : 只在本地修改数据, 不写回原始文件.
            
    内存映射文件并不会导致整个文件被读取到内存中, 即文件并没有被复制到内存缓存或数组中, 相反, 操作系统仅仅为文件内容保留了一段虚拟内存.当访问文件的不同区域时, 这些区域的内容才根据需要被读取并映射到内存区域中.

6. `os.path`    
    
    目录文件操作

    path = '/path/to/test.txt'
    os.path.basename(path)
    os.path.dirname(path)
    os.path.join("tmp", "data")
    os.path.expanduser(path)

        >>> path = '~/Data/data.csv'

        >>> os.path.expanduser(path)
            '/root/Data/data.csv'

        >>> os.path.splitext(path)
            ('~/Data/data', '.csv')

    文件或目录是否存在
    os.path.exists('/etc/passwd')
    os.path.isfile("/etc/passwd")
    os.path.islink("/usr/local/bin/python3")
    os.path.realpath("/usr/local/bin/python3")  # 根据链接寻找源文件.

    获取文件元数据 --> 需要考虑文件的权限问题.
    os.path.getsize("/etc/passwd")
    os.path.getmtime("/etc/passwd")
    os.path.getctime("/etc/passwd")
    os.path.getatime("/etc/passwd")
    os.stat("/etc/passwd")

    获取某个目录下的文件列表
    os.listdir("somedir")

        # 获取所有文件
        names = [name for name in os.listdir('somedir')
                if os.path.isfile(os.path.join('somedir', name))]

        # 获取所有目录
        dirnames = [name for name in os.listdir('somedir')
                if os.path.isdir(os.path.join('somedir', name))]

        # 根据文件扩展名匹配
        pyfiles = [name for name in os.listdir('somedir')
            if name.endswith('.py')]

        # 使用 glob 和 fnmatch 匹配
        import glob
        pyfiles = glob.glob('somedir/*.py')

        from fnmatch import fnmatch
        pyfiles = [name for name in os.listdir('somedir')
                    if fnmatch(name, '*.py')]

    os.walk("/path/to/dir")

7. 将文件描述符包装成文件对象.
    
    一个操作系统上已经打开的 IO 通道(如文件, 管道, 套接字等)的整型文件描述符, 可以被包装成为一个更高层的 Python 文件对象.

    文件描述符仅仅是一个有操作系统指定的整数, 用来指代某个系统的 IO 通道.

        # 打开一个低级文件描述符
        import os
        fd = os.open("somefile.txt", os.O_WRONLY | os.O_CREAT)

        # turn into a proper file
        f = open(fd, 'wt')
        f.write("Hello world\n")
        f.close()

    操作管道的例子

        from socket import socket, AF_INET, SOCK_STREAM

        def echo_client(client_sock, addr):
            print("Got connection from", addr)

            # make text-mode file wrappers for socket reading/writing
            client_in = open(client_sock.fileno(), 'rt', encoding='latin-1', closed=False)

            client_out = open(client_sock.fileno(), 'wt', encoding='latin-1', closed=False)

            # echo lines back to the client using file IO
            for line in client_in:
                client_out.write(line)
                client_out.flush()
                client_out.close()

        def echo_server(address):
            sock = socket(AF_INET, SOCK_STREAM)
            sock.bind(address)
            sock.listen(1)
            while True:
                client, addr = sock.accept()
                echo_client(client, addr)


8. 创建临时文件和文件夹: 使用完成之后, 自动销毁掉.

    `tempfile` 模块

    `tempfile.TemporaryFile(mode)` 创建临时匿名文件

        from tempfile import TemporaryFile
        with TemporaryFile('w+t') as f:
            # Read/write to the file
            f.write('Hello World\n')
            f.write('Testing\n')

            # Seek back to beginning and read the data
            f.seek(0)
            data = f.read()
        # Temporary file is destroyed

        或

        f = TemporaryFile('w+t')
        # Use the temporary file
        ...
        f.close()
        # File is destroyed

    `tempfile.NamedTemporaryFile()` 创建临时命名文件


        with NamedTemporaryFile('w+t', delete=False) as f:
            print('filename is:', f.name)

        f.name : 获取文件名

        delete=False : 文件关闭时, 不自动删除文件.

        # 指定文件的前缀, 后缀, 及存放目录
        f = NamedTemporaryFile(prefix='mytemp', suffix='.txt', dir='/tmp')
        f.name      # '/tmp/mytemp8ee899.txt'


    `tempfile.TemporaryDirectory()` 创建临时目录

        from tempfile import TemporaryDirectory

        with TemporaryDirectory() as dirname:
            print('dirname is:', dirname)
            # Use the directory
            ...
        # Directory and all contents destroyed

    获取临时文件的存放目录

        >>> tempfile.gettempdir()
            '/var/folders/7W/7WZl5sfZEF0pljrEB1UMWE+++TI/-Tmp-'

    更加底层的创建临时文件/目录方法: `tempfile.mkstemp()`, `tempfile.mkdtemp()` , 这些方法只负责创建, 而不再做进一步的管理工作. 如 `mkstemp()` 仅仅返回一个原始的 OS 文件描述符, 需要自己实现将其转换为一个真正的文件对象, 同时还需要自己清理这些文件.
        
        # 创建临时文件
        >>> tempfile.mkstemp()
            (3, '/var/folders/7W/7WZl5sfZEF0pljrEB1UMWE+++TI/-Tmp-/tmp7fefhv')

        # 创建临时目录
        >>> tempfile.mkdtemp()
            '/var/folders/7W/7WZl5sfZEF0pljrEB1UMWE+++TI/-Tmp-/tmp5wvcv6'

## 函数
1. 强制关键字参数
    
        def recv(maxsize, *, block):
            'Receives a message'
            pass

        recv(1024, True)        # TypeError
        recv(1024, block=True)  # Ok

        # 在接受任意多个位置参数的函数中指定关键字参数.
        def mininum(*values, clip=None):
            m = min(values)
            if clip is not None:
                m = clip if clip > m else m
            return m

        minimum(1, 5, 2, -5, 10) # Returns -5
        minimum(1, 5, 2, -5, 10, clip=0) # Returns 0

2. 给函数增加元信息 : 函数参数注解.
    
    函数参数注解能提示程序员应该怎样正确使用这个函数. Python 解释器不会对这些注解添加任何语义, 也不会被类型检查, 运行时与没有添加注解之前的效果没有任何差别, 然而, 对那些阅读源码的人非常有帮助, 第三方工具和框架核能对这些注解添加语义.

        def fadd(x:int, y:int) -> int:
            return x + y

        >>> help(fadd)
            Help on function fadd in module __main__:
            fadd(x:int, y:int) -> int

    函数的注解信息, 存储在函数的  `__annotations__` 属性中.

        >>> fadd.__annotations__
            {'return': int, 'x': int, 'y': int}

    用注解实现多分派(重载函数)

3. lambda 函数
    
    lambda 允许定义简单的函数, 但他的使用时由限制的, 只能指定单个表达式, 其结果就是表达式的返回值. 

    lamdba 的典型使用场景就时排序或数据 reduce 等.

        In [60]: names = ['David Beazley', 'Brian Jones', 'Raymond Hettinger', 'Ned Batchelde
            ...: r']

        In [61]: sorted(names, key=lambda name: name.split()[-1].lower())
        Out[61]: ['Ned Batchelder', 'David Beazley', 'Raymond Hettinger', 'Brian Jones']

    lambda 表达式的参数, 是一个自由变量, 在运行时绑定, 如果想让 lambda 函数在定义时就捕获到值, 可以将那个参数值定义成默认参数即可.

        # 自由变量, 在运行时绑定.

        In [64]: x = 10

        In [65]: a = lambda y: x+y

        In [66]: x = 20

        In [67]: b = lambda y: x+y

        In [68]: a(10)
        Out[68]: 30

        In [69]: b(10)
        Out[69]: 30

        # 使用默认值: 定义时绑定.
        In [70]: x = 10

        In [71]: a = lambda y, x=x: x+y

        In [72]: x = 20

        In [73]: b = lambda y, x=x: x+y

        In [74]: a(10)
        Out[74]: 20

        In [75]: b(10)
        Out[75]: 30

4. 闭包 ---
    
    使用闭包将单个方法的类转换为函数.

        # 类
        from urllib.request import urlopen
        class UrlTemplate:
            def __init__(self, template):
                self.template = template

            def open(self, **kwagrs):
                return urlopen(self.template.format_map(kwagrs))

        yahoo = UrlTemplate("http://finance.yahoo.com/d/quotes.csv?s={names}&f={fields}")
        for line in yahoo.open(names="IBM,APPLE,FB", field="sl1c1v"):
            print(line.decode("utf-8"))

        # 闭包
        def urltemplate(template):
            def opener(**kwargs):
                return urlopen(template.format_map(kwargs))
            return opener

        yahoo = UrlTemplate("http://finance.yahoo.com/d/quotes.csv?s={names}&f={fields}")
        for line in yahoo.open(names="IBM,APPLE,FB", field="sl1c1v"):
            print(line.decode("utf-8"))


    带额外状态信息的回调函数: 比如是事件处理器, 等待后台任务完成后的回调, 并且还需要让回调函数拥有额外的状态值.

        >>> def apply_async(func, args, *, callback):
                result = func(*args)
                callback(result)
                
        >>> def print_result(result):
                print("Got: ", result)
                
        >>> def add(x,y):
                return x+y

        >>> apply_async(add, (2,3), callback=print_result)
            Got:  5

        >>> apply_async(add, ('hello', 'world'), callback=print_result)
            Got:  helloworld

    让回调函数访问外部信息.

        # 方式一 : 使用一个绑定方法来替代一个简单函数
        >>> class ResultHandler:
                def __init__(self):
                    self.sequence = 0
                def handler(self, result):
                    self.sequence += 1
                    print('[{}] Got: {}'.format(self.sequence, result))
       
        >>> r = ResultHandler()
        >>> apply_async(add, (2,3), callback=r.handler)
            [1] Got: 5
        >>> apply_async(add, (2,3), callback=r.handler)
            [2] Got: 5

        # 方式二 : 使用一个闭包来捕获状态值

        >>> def make_handler():
                sequence = 0
                def handler(result):
                    nonlocal sequence 
                    sequence += 1
                    print('[{}] Got: {}'.format(sequence, result))

                return handler
            
        >>> handler = make_handler()
            
        >>> apply_async(add, (2,3), callback=handler)
            [1] Got: 5

        >>> apply_async(add, (2,3), callback=handler)
            [2] Got: 5

        >>> apply_async(add, (2,3), callback=handler)
            [3] Got: 5
        

        # 方式三 : 使用协程来完成

        >>> def make_handler():
                sequence = 0
                while True:
                    result = yield
                    sequence += 1
                    print('[{}] Got: {}'.format(sequence, result))
                    
        >>> handler = make_handler()

        >>> next(handler)

        >>> apply_async(add, (2,3),callback=handler.send)
            [1] Got: 5

        >>> apply_async(add, (2,3),callback=handler.send)
            [2] Got: 5

    基于回调函数的软件通常都有可能变得非常复杂. 一部分原因是回调函数通常会跟请求执行代码断开. 因此, 请求执行和处理结果之间的执行环境实际上已经丢失. 如果希望回调函数连续执行多步操作, 那就必须解决如何保存和恢复相关的状态信息了.

    至少有两种主要方式来捕获和保存状态信息, 

    1. 在一个对象实例(通过一个绑定方法)捕获保存状态信息

    2. 在一个闭包中保存, 捕获保存状态信息

        使用闭包或许更加轻量级和自然一点, 因为闭包可以很自然的通过函数来构造, 还能自动捕获所有被使用到的变量.因此, 无需去担心如何取存储额外的状态信息(代码中自动判定).

    3. 使用协程作为回调函数.

        协程与闭包密切相关. 某种意义上, 协程更加简洁, 因为他只有一个函数. 并且, 可以很自由的修改变量而无需去使用 `nonlocal` 声明. 唯一的缺点就是比较难以理解: 比如使用之前需要调用 `next()`.

        另, 协程还可以作为一个内联回调函数的定义.

        通过使用生成器和协程可以使得回调函数内联在某个函数中.

            >>> from queue import Queue
            >>> from functools import wraps

            >>> class Async:
                    def __init__(self, func, args):
                        self.func = func
                        self.args = args

            >>> def inlined_async(func):
                    @wraps(func)
                    def wrapper(*args):
                        f = func(*args)
                        result_queue = Queue()
                        result_queue.put(None)

                        while True:
                            result = result_queue.get()
                            try:
                                a = f.send(result)
                                apply_async(a.func, a.args, callback=result_queue.put)
                            except StopIteration:
                                break

                    return wrapper

            >>> @inlined_async
                def test():
                    r = yield Async(add,(2,3))
                    print(r)
                    r = yield Async(add,('hello', 'world'))
                    print(r)
                    for n in range(10):
                        r = yield Async(add,(n,n))
                        print(r)
                    print("Bye")
                    
            >>> test()
                5
                helloworld
                0
                2
                4
                6
                8
                10
                12
                14
                16
                18
                Bye

        首先, 在需要使用到回调的代码中, 关键点在于当前计算工作会挂起并在将来的某个时候重启(如异步执行). 当计算重启时, 回调函数被调用来持续处理结果. `apply_async()` 函数演示了执行回调的实际逻辑, 尽管实际情况中它可能会更加复杂(包括线程, 进程, 事件处理器等).

        计算的暂停与重启思路与生成器函数的执行模型不谋而合. 具体来讲, `yield` 操作会使一个生成器函数产生一个值并暂停. 接下来调用生成器的 `__next__()` 或 `send()` 方法又会让他从暂停处继续处理.

        上例中, `inline_async()` 装饰器会逐步遍历生成器函数的所有 `yield` 语句, 每次一个. 为了这样做, 刚开始的时候, 创建了一个 `result` 队列并向里面放入一个 `None` 值. 然后开始一个循环操作, 从队列中取出结果值, 并发送给生成器. 他会持续到下一个 `yield` 语句, 在这里一个 `Async` 的实例被接收到. 然后, 循环开始检查函数和参数, 并开始进行异步计算 `apply_async()` , 然后, 这个计算有一个诡异部分是它没有使用一个普通的回调函数, 而是用队列的 `put()` 方法来回调.

        主循环立即返回顶部并在队列上执行 `get()` 操作, 如果数据存在, 他一定是 `put()` 回调存放的结果. 如果没有数据, 那么先暂停操作并等待结果的到来, 其具体实现由  `apply_async()` 函数来决定.


    扩展函数中的某个闭包, 允许他能访问和修改函数的内部变量. 通常, 闭包的内部变量对于外界来讲是完全隐藏的. 但是, 可以通过编写访问函数并将其作为函数属性绑定到闭包上来实现这个目的.

        >>> def sample():
                n = 0
                def func():
                    print('n=', n)
                def get_n():
                    return n
                def set_n(value):
                    nonlocal n      # nonlocal 可以让我们编写函数来修改内部变量的值.
                    n = value
                func.get_n = get_n  # 函数属性允许用一种很简单的方式将访问方法绑定到闭包函数上
                func.set_n = set_n
                return func

        >>> f = sample()
        >>> f()
            n= 0
        >>> f.set_n(10)
        >>> f()
            n= 10
        >>> f.get_n()
            10

## 类与对象
1. 通过 `format()` 函数和字符串方法使得一个对象能支持自定义的格式化.
    
    `__format__()` 方法给 Pyuthon 的字符串格式化功能提供一个钩子, 但是格式化代码的解析工作完全由类自己决定, 因此, 格式化代码可以是任何值.

        _formats = {
            'ymd' : '{d.year}-{d.month}-{d.day}',
            'mdy' : '{d.month}/{d.day}/{d.year}',
            'dmy' : '{d.day}/{d.month}/{d.year}'
            }

        class Date:
            def __init__(self, year, month, day):
                self.year = year
                self.month = month
                self.day = day

            def __format__(self, code):
                if code == '':
                    code = 'ymd'
                fmt = _formats[code]
                return fmt.format(d=self)

        >>> d = Date(2012, 12, 21)
        >>> format(d)
            '2012-12-21'
        >>> format(d, 'mdy')
            '12/21/2012'
        >>> 'The date is {:ymd}'.format(d)
            'The date is 2012-12-21'
        >>> 'The date is {:mdy}'.format(d)
            'The date is 12/21/2012'

2. 让对象支持上下文管理(with 语句)
    
    让对象兼容 `with` 语句, 需要实现 `__enter__()` 和 `__exit__()` 方法.

    当出现 `with` 语句的时候, 对象的 `__enter__()` 方法会被触发, 它返回的值(如果有的话) 会被赋值给 `as` 声明的变量. 然后, `with` 语句块里面的代码开始执行. 最后, `__exit__()` 方法被触发进行清理工作.

    `__exit__()` 方法的三个参数包含了异常类型、异常值和追溯信息(如果有的话). `__exit__()` 方法能自己决定怎样利用这个异常信息，或者忽略它并返回一个`None`值。如果 `__exit__()` 返回 `True` ，那么异常会被清空，就好像什么都没发生一样，`with` 语句后面的程序继续在正常执行。

        from socket import socket, AF_INET, SOCK_STREAM

        class LazyConnection:
            """ 该类的关键特点是它表示一个网络连接, 但是初始化的时候, 不做任何事(如没有建立一个链接). 连接的建立和关闭是使用 with 语句自动完成的.
            """
            def __init__(self, address, family=AF_INET, type=SOCK_STREAM):
                self.address = address
                self.family = family
                self.type = type
                self.sock = None

            def __enter__(self):
                if self.sock is not None:
                    raise RuntimeError("Already connected)

                self.sock = socket(self.family, self.type)
                self.sock.connect(self.address)
                return self.sock

            def __exit__(self, exc_ty, exc_val, tb):
                self.sock.close()
                self.sock = None


        from functools import partial

        conn = LazyConnection(("www.python.com", 80))

        with conn as s:
            # conn.__enter__() executes: connection open
            s.send(b'GET /index.html HTTP/1.0\r\n')
            s.send(b'Host: www.python.com\r\n')
            s.send(b'\r\n')
            resp = b''.join(iter(partial(s.recv, 8192), b''))
            # conn.__exit__() executes: connection closed

3. `__slots__` 属性来减少实例所占的内存
    
    `__slots__` 更多的使用来做为一个内存优化工具. 当定义 `__slots__` 后, Python 会为实例使用一种更加紧凑的内部表示. 实例通过一个很小的固定大小的数组来构建, 而不是为每个实例定义一个字典. 在 `__slots__` 中列出的属性名在内部被映射到这个数组的指定小标上.

    使用 `__slots__` 后,不能再给实例添加新的属性了, 只能使用在 `__slots__` 中定义的属性.

    定义了 `__slots__` 后, 类不再支持一些普通的类特性了, 如继承.

        class Date:
            __slots__ = ["year", "month", "day"]

            def __init__(self, year, month, day):
                self.year = year
                self.month = month
                self.day = day

4. 私有数据与属性

    `_` 开头 : 内部实现, 适用于属性, 方法, 模块名和模块级别的函数.

    `__` 开头 : 在类定义中, 这种定义形式的方法的访问形式变为 `_CLASSNAME__METHODNAME`. 这种重命名的目的是为了继承, 即这种属性通过继承时无法覆盖的.

    大多数情况下, 应该使用非公共名称以单下划线开头, 但是如果涉及到子类, 并且有些内部属性应该在子类中隐藏起来, 才考虑使用双下划线方案.


5. property: 给实例增加除了访问与修改之外的其他处理逻辑.
    
    property 的一个关键特征是他看上与普通的 attribute 没什么两样, 但是访问他的时候会自动触发 `getter`, `setter` 和 `deleter` 方法.

        class Person:
            def __init__(self, first_name):
                self.first_name = first_name

            # Getter function
            @property
            def first_name(self):
                return self._first_name

            # Setter function
            @first_name.setter
            def first_name(self, value):
                if not isinstance(value, str):
                    raise TypeError("Expected a string")
                self._first_name = value

            # deleter function(optional)
            @first_name.deleter
            def first_name(self):
                raise AttributeError("Can't delete attribute")

        tom = Person("tom")
        print(tom.first_name)
        tom.first_name = "NotJerry"
        print(tom.first_name)

    在已存在的 `get` 和 `set` 方法的基础上定义 property.

        class Person:
            def __init__(self, first_name):
                self.set_first_name(first_name)

            def get_first_name(self):
                return self._first_name 

            def set_first_name(self, value):
                if not isinstance(value, str):
                    raise TypeError("Expected a string")
                self._first_name = value

            def del_first_name(self):
                raise AttributeError("Cann't delete attribute")

            name = property(get_first_name, set_first_name, del_first_name)

    一个 property 属性其实就是一系列相关绑定方法的集合.如果查看拥有 property 的类, 就会发现 property 本身的 `fget`, `fset`, `fdel` 属性就是类里面的普通方法.

        In [2]: Person.first_name.fget
        Out[2]: <function __main__.Person.first_name>

        In [3]: Person.first_name.fdel
        Out[3]: <function __main__.Person.first_name>

        In [4]: Person.first_name.fset
        Out[4]: <function __main__.Person.first_name>

    Property 还是一种定义动态计算 attribute 的方法. 这种类型的 attribute 并不会被实际存储, 而是在需要的时候, 计算出来.

        import math

        class Circle:
            """关于圆的半径, 直径, 周长和面积. 统一了所有的访问接口.
            """
            def __init__(self, radius):
                self.radius = radius

            @property
            def area(self):
                return math.pi * self.radius ** 2

            @property
            def diameter(self):
                return self.radius * 2

            @property
            def perimeter(self):
                return 2 * math.pi * self.radius

6. `super()` : 在子类中调用父类的方法
    
    主要有一些用途:

    1. 调用父类中的一个方法

            class A:
                def spam(self):
                    print("A.spam")

            class B:
                def spam(self):
                    print("B.spam")
                    super().spam()      # call parent spam()

    2. 在 `__init__()` 方法中确保父类被正确的初始化了

            class A:
                def __init__(self):
                    self.x = 0

            class B(A):
                def __init__(self):
                    super().__init__()
                    self.y = 1

    3. 覆盖 Python 特殊方法

            class Proxy:
                def __init__(self, obj):
                    self._obj = obj

                # Delegate attribute lookup to internal obj
                def __getattr__(self, name):
                    return getattr(self._obj, name)

                # Delegate attribute assignment
                def __setattr__(self, name, value):
                    if name.startswith("_"):
                        super().__setattr__(name, value)    # Call original __setattr__
                    else:
                        setattr(self._obj, name, value)

    **Python 是如何实现继承的**: 对于定义的每一个类, Python 会计算出一个所谓的 **方法解析顺序(MRO) 列表**, 这个 MRO 列表就是一个简单的所有基类的线性顺序表.

        # 使用 Base.__init__() 示例 : 有些 `__init__()` 方法被调用多次.
        class Base:
            def __init__(self):
                print("Base.__init__")

        class A(Base):
            def __init__(self):
                Base.__init__(self)
                print("A.__init__")

        class B(Base):
            def __init__(self):
                Base.__init__(self)
                print("B.__init__")

        class C(A, B):
            def __init__(self):
                A.__init__(self)
                B.__init__(self)
                print("C.__init__")

        >>> c = C()
            Base.__init__
            A.__init__
            Base.__init__
            B.__init__
            C.__init__

        # 使用 super().__init__() 示例 : 每个 `__init__()` 只会被调用一次
        class Base:
            def __init__(self):
                print("Base.__init__")

        class A(Base):
            def __init__(self):
                super().__init__()
                print("A.__init__")
                print(self.__mro__)

        class B(Base):
            def __init__(self):
                super().__init__()
                print("B.__init__")
                print(self.__mro__)

        class C(A, B):
            def __init__(self):
                super().__init__()      # only one call to super() here
                print("C.__init__")
                print(self.__mro__)

        >>> c = C()
            Base.__init__
            B.__init__
            A.__init__
            C.__init__


    Python 在 MRO(Class.__mro__) 列表上, 从左到右开始查找基类, 直到找到第一个匹配这个属性的类为止. 而 MRO 列表的构造是通过一个 C3 线性化算法 来实现的. 它实际上就是合并所有父类的 MRO 列表并遵循如下三条准则:
        ① 子类会先于父类被检查
        ② 多个父类会根据他们在列表中的顺序被检查
        ③ 如果对下一个类存在两个合法的选择, 选择第一个父类.

    MRO 列表中的类顺序会让你定义的任意类层级关系变得有意义. 当使用 `super()` 函数时, Python 会在 MRO 列表上继续搜索下一个类. 只要每一个重定义的方法统一使用 `super()` 并只调用它一次, 那么控制流会遍历整个 MRO 列表, 每个方法也只会被调用一次. 这也是为什么在第二个例子中不会出现调用两次 `Base.__init__()` 的原因.

    `super()` 不一定去查找某个类在 MRO 中下一个直接父类, 因此, 甚至可以在一个没有直接父类的类中使用它.


7. 在子类中扩展定义在父类中的 property 功能

        class Person:
            def __init__(self, name):
                self.name = name

            @property
            def name(self):
                return self._name 

            @name.setter
            def name(self, value):
                if not isinstance(value, str):
                    raise TypeError("Expected a string")
                self._name = value

            @name.deleter
            def name(self):
                raise AttributeError("Can't delete attribute")

        class SubPerson(Person):
            """继承并扩展了 name 属性
            """
            @property
            def name(self):
                print("Getting name")
                return super().name

            @name.setter
            def name(self, value):
                print("setting name to", value)
                
                # 为了委托给之前定义的 seter 方法, 
                # 需要将控制权传递给之前定义的 name 属性的 __set__() 方法.
                # 但是, 获取这个方法的唯一途径就是使用 类变量 而不是 实例变量 来访问它. 
                super(SubPerson, SubPerson).name.__set__(self, value)

            @name.deleter
            def name(self):
                print("Deleting name")
                super(SubPerson, SubPerson).name.__delete__(self)

        class SubPerson2(Person):
            # 只扩展 property 的 getter 方法
            @Person.name.getter
            def name(self):
                print("Getting name in SubPerson2")
                return super().name

            # 只扩展 property 的 setter 方法
            @Person.name.setter
            def name(self, value):
                print("Setting name to %s in SubPerson2" % value)
                super(SubPerson2, SubPerson2).name.__set__(self, value)

    在子类中扩展一个 property 可能会引出许多不易察觉的问题, 因为一个 property 其实是 getter, setter, deleter 方法的集合, 而不是单个方法. 因此, 在扩展一个 property 的时候, 需要先确定你是否要重新定义所有的方法, 还是说只修其中的一个.

    用于扩展一个描述器
        
        # A descriptoy
        class String:
            def __init__(self, name):
                self.name = name

            def __get__(self, instance, cls):
                if instance is None:
                    return self
                return instance.__dict__[self.name]

            def __set__(self, instance, value):
                if not isinstance(value, str):
                    raise TypeError("Expected a string")
                instance.__dict__[self.name] = value

        # A class with a descriptor
        class Person:
            name = String("name")

            def __init__(self, name):
                self.name = name

        # Extending a descriptor with a property
        class SUbPerson(Person):
            @property
            def name(self):
                print("Getting name")
                return super().name

            @name.setter
            def name(self, value):
                print("Setting name to", value)
                super(SUbPerson, SubPerson).name.__set__(self, value)

            @name.deleter
            def name(self):
                print("Deleting name")
                super(SubPerson, SubPerson).name.__delete__(self)


8. 创建新的类或实例属性: 描述器
    
    一个描述器就是一个实现了三个核心的属性访问操作(get, set, delete)的类, 分别为 `__get__()`, `__set__()`, `__delete__()` 这三个特殊的方法. 这些方法接受一个实例作为输入, 之后相应的操作实例底层的字典. 为了使用一个描述器, 需将这个描述器的实例作为类属性放到一个类的定义中. 当使用一个描述器之后, 所有对描述器属性的访问都会被 `__get__()`, `__set__()`, `__delete__()` 方法捕获到.

    作为输入, 描述器的每一个方法会接受一个操作实例. 为了实现请求操作, 会相应的操作实例底层的字典(dict 属性).

        class Integer:
            def __init__(self, name):
                self.name = name

            def __get__(self, instance, cls):
                """ __get__ 方法比较复杂的原因归结于 实例变量和类变量的不同, 如果一个描述器被当做一个类变量来访问, 那么 instance 参数被设置成 None. 这种情况下, 标准做法就是简单返回这个描述器本身即可.
                """
                print("__get__")
                if instance is None:
                    return self
                else:
                    return instance.__dict__[self.name]

            def __set__(self, instance, value):
                print("__set__")
                if not isinstance(value, int):
                    raise TypeError("Expected an int")
                instance.__dict__[self.name] = value

            def __delete__(self, instance):
                print("__delete__")
                del instance.__dict__[self.name]


        class Point:
            x = Integer('x')
            y = Integer('y')

            def __init__(self, x, y):
                self.x = x
                self.y = y


        p = Point(2, 3)
        print(p.x)      # Calls Point.x.__get__(p, Point)
        print(p.y)      # Calls Point.y.__get__(p, Point)
        p.x = 123       # Calls Point.x.__set__(p, 123)
        p.y = 456       # Calls Point.x.__set__(p, 456)
        print(p.x)
        print(p.y)

    描述器可实现大部分 Python 类特性中的底层魔法, 包括 `@classmethod`, `@staticmethod`, `@property`, 甚至是 `__slots__` 特性, 他也是很多高级库和框架中的重要工具之一.

    描述器只能在类级别被定义, 而不能为每个实例单独定义.

    如果只是想简单的自定义某个类的单个属性访问的话, 无需使用描述器, 使用 property 技术更加容易和简单.

    描述器通常是那些使用到 装饰器或者元类的大型框架中的一个组件. 同时他们的使用也被隐藏在后面.

        # Descriptor for a type-checked attribute
        class Typed:
            def __init__(self, name, expected_type):
                self.name = name
                self.expected_type = expected_type

            def __get__(self, instance, cls):
                if instance is None:
                    return self
                else:
                    return instance.__dict__[self.name]

            def __set__(self, instance, value):
                if not isinstance(value, self.expected_type):
                    raise TypeError("Expected " + self.expected_type)

                instance.__dict__[self.name] = value

            def __delete__(self, instance):
                del instance.__dict__[self.name]


        # Class decorator that applies it to selected attributes
        def typeassert(**kwargs):
            def decorate(cls):
                for name, expected_type in kwargs.items():
                    # Attach a Typed descriptor to the class 
                    setattr(cls, name, Typed(name, expected_type))

                return cls
            return decorate

        # Example use
        @typeassert(name=str, shares=int, price=float)
        class Stock:
            def __init__(self, name, shares, price):
                self.name = name
                self.shares = shares
                self.price = price


9. 使用延迟计算属性: 使用一个描述器类.
    
    构建延迟计算属性的主要目的是为了提升性能.他通过以非常高效的方式使用描述器的一个精妙特性来达到这种效果.

    当一个描述器被放入一个类的定义时, 每次访问属性时他的 `__get__()`, `__set__()`, `__delete__()` 方法就会被触发. 不过, 如果一个描述器只定义了一个 `__get__()` 方法的话, 他比通常的具有更弱的绑定. 特别的, 只有在当被访问属性不在实例底层的字典中时 `__get__()` 方法才会被触发. lazyproperty 类利用了这一点, 使用 `__get__()` 方法在实例中存储计算出来的值, 这个实例使用相同的名字作为他的 property. 这样一来, 结果值被存储在实力字典中, 并且以后就不需要再去计算这个 property 了.

        class lazyproperty:
            def __init__(self, func):
                self.func = func

            def __get__(self, instance, cls):
                if instance is None:
                    return self
                else:
                    value = self.func(instance)
                    setattr(instance, self.func.__name__, value)
                    return value

            # def __set__(self, instance, value):
            #     pass

        import math
        class Circle:
            def __init__(self, radius):
                self.radius = radius

            @lazyproperty
            def area(self):
                print("Computing area")
                return math.pi * self.radius**2

            @lazyproperty
            def perimeter(self):
                print("Computing perimeter")
                return 2 * math.pi * self.radius


        c = Circle(4.0)
        print(vars(c))
        print(c.radius)
        print(vars(c))
        print(c.area)
        print(vars(c))
        print(c.perimeter)
        print(c.perimeter)
        print(c.perimeter)
        print(c.perimeter)
        print(c.perimeter)
        print(vars(c))

        # 输出
        {'radius': 4.0}
        4.0
        {'radius': 4.0}
        Computing area
        50.26548245743669
        {'radius': 4.0, 'area': 50.26548245743669}
        Computing perimeter
        25.132741228718345
        25.132741228718345
        25.132741228718345
        25.132741228718345
        25.132741228718345
        {'radius': 4.0, 'area': 50.26548245743669, 'perimeter': 25.132741228718345}

    但是, 这种方案有种小缺陷就是: 值被创建出来后时可以被修改的. 如下是一个不是非常高效的修改方案:

        def lazyproperty(func):
            name = "__lazy__" + func.__name__

            @property
            def  lazy(self):
                if hasattr(self, name):
                    return getattr(self, name)
                else:
                    value = func(self)
                    setattr(self, name, value)
                    return value
            return lazy

10. 简化数据结构的初始化:
    
    很多仅仅作为数据结构的类, 不想写太多 `__init__()` 函数. 可以在一个基类中写一个公用的 `__init__()` 函数.

        # 支持位置参数
        class Structure1:
            # class variable that specifies expected fields
            _fields = []

            def __init__(self, *args):
                if len(args) != len(self._fields):
                    raise TypeError("Expected {} arguments".format(len(self._fields)))

                # set the arguments
                for name, value in zip(self._fields, args):
                    setattr(self, name, value)

        class Stock(Structure1):
            _fields = ["name", "shares", "price"]


        # 支持位置参数和关键字参数, 可以将关键字参数设置为实例属性.
        class Structure2:
            _fields = []

            def __init__(self, *args, **kwargs):
                if len(args) > len(self._fields):
                    raise TypeError("Expected {} arguments".format(len(self._fields)))

                # Set all of the positional arguments
                for name, value in zip(self._fields, args):
                    setattr(self, name, value)

                # Set the remaining keyword arguments
                for name in self._fields[len(args):]:
                    setattr(self, name, kwargs.pop(name))

                # check for any remaining unknown arguments
                if kwargs:
                    raise TypeError("Invalid arguments(s): {}".format(','.join(kwargs)))


        class Stock(Structure2):
            _fields = ["name", "shares", "price"]

        s1 = Stock("ACME", 50, 91.1)
        s2 = Stock("ACME", 50, price=91.1)
        s3 = Stock("ACME", shares=50, price=91.1)
        s4 = Stock("ACME", shares=50, price=91.1, aa=1)     # Error


        # 将不在 _fields 中的名称加入到属性中.
        class Structure3:
            # Class variable that specifies expected fields
            _fields = []

            def __init__(self, *args, **kwargs):
                if len(args) != len(self._fields):
                    raise TypeError("Expected {} arguments".format(len(self._fields)))

                # Set the arguments
                for name, value in zip(self._fields, args):
                    setattr(self, name, value)

                # Set the additional arguments (if any)
                extra_args = kwargs.keys() - self._fields
                for name in extra_args:
                    setattr(self, name, kwargs.pop[name])

                if kwargs:
                    raise TypeError("Duplicate values for {}".format(",".join(kwargs)))


        class Stock(Structure3):
            _fields = ["name", "shares", "price"]

        s1 = Stock("ACME", 50, 91.1)
        s2 = Stock("ACME", 50, 91.1, date="8/2/2012")

11. 定义接口或抽象基类, 并通过执行类型检查来确保子类实现了某些特定的方法: abc 模块

    抽象类的一个特点是他不能直接被实例化. 使用 `abc` 模块可以轻松定义抽象基类. 抽象类的目的就是**让别的类继承并实现特定的抽象方法**.

        class Stock(IStream):
                    def read(self, maxbytes=-1):
                        pass

                    def write(self, data):
                        pass

    抽象基类的一个主要用途是在代码中**检查某些类是否为特定类型**, 实现了特定的接口.

        def serialize(obj, stream):
            if not isinstance(stream, IStream):
                raise TypeError("Ex[ected an IStream")
            pass

    通过**注册**的方式实现的抽象基类:

        import io

        # Register the built-in I/O classes as supporting our interface
        IStream.register(io.IOBase)

        # Open a normal ifle and type check

        f= open("foo.txt")
        print(isinstance(f, IStream))   # True

    `@abstractmethod` 还能注解静态方法, 类方法 和 `property`, 只需保证这个注解紧靠在函数定义前即可.

        class A(metaclass=ABCMeta):
            @property
            @abstractmethod
            def name(self):
                pass

            @name.setter
            @abstractmethod
            def name(self, value):
                pass

            @classmethod
            @abstractmethod
            def method1(cls):
                pass


            @staticmethod
            @abstractmethod
            def method2():
                pass


    标准库中有很多用到抽象基类的地方. 
    - `collections` 模块定义了很多跟容器和迭代器(序列, 映射, 集合等)有关的抽象基类.
    - `numbers` 库定义了跟数字对象(整数, 浮点数, 有理数等)有关的基类.
    - `io` 库定义了很多跟 I/O 操作相关的基类.

    可以使用预定义的抽象类来执行更通用的类型检查.

        import collections

        # Check if x is a Sequence
        if isinstance(x, collections.Sequence):
            pass

        # Check if x is a iterable
        if isinstance(x, collections.Iterable):
            pass

        # Check if x has a size
        if isinstance(x, collections.Sized):
            pass

        # Check if x is a mapping
        if isinstance(x, collections.Mapping):
            pass


    尽管 ABCs 可以很方便的进行类型检查, 但是在代码中不要过多的使用它. 因为 Python 本质是一门动态编程语言, 其目的是提供更多的灵活性, 强制类型检查会使代码变得更加复杂.

12. 实现数据模型的类型约束
    
    希望定义某些在属性赋值上面有限制的数据结构.所以, 要自定义属性赋值函数, 这种情况下最好使用描述器.

        # Base class. Usea a descriptor to set a value.
        class Descriptor:
            def __init__(self, name=None, **opts):
                self.name = name
                for name, value in opts.items():
                    setattr(self, name, value)

            def __set__(self, instance, value):
                instance.__dict__[self.name] = value


        # Descriptor for enforcing types:
        class Typed(Descriptor):
            expected_type = type(None)

            def __set__(self, instance, value):
                if not isinstance(value, self.expected_type):
                    raise TypeError("Expected " + str(self.expected_type))

                super().__set__(instance, value)

        # Descriptor for enforcing types
        class Unsigned(Descriptor):
            def __set__(self, instance, value):
                if value < 0:
                    raise ValueError("Expected >= 0")
                super().__set__(instance, value)


        class MaxSized(Descriptor):
            def __init__(self, name=None, **opts):
                if "size" not in opts:
                    raise TypeError("Missing size option")
                super().__init__(name, **opts)

            def __set__(self, instance, value):
                if len(value) >= self.size:
                    raise ValueError("Size must be <" + str(self.size))
                super().__set__(instance, value)

        # 实际定义的各种不同数据类型.
        class Integer(Typed):
            expected_type = int

        class UnsignedInteger(Integer, Unsigned):
            pass

        class Float(Typed):
            expected_type = float

        class UnsignedFloat(Float, Unsigned):
            pass

        class String(Typed):
            expected_type = str

        class SizedString(String, MaxSized):
            pass


        # 使用以上类型约束, 定义类
        class Stock:
            # Specify constraints
            name = SizedString("name", size=8)
            shares = UnsignedInteger("shares")
            price = UnsignedFloat("price")

            def __init__(self, name, shares, price):
                self.name = name
                self.shares = shares
                self.price = price

    使用**类装饰器**实现的类型约束检查

        # Class decorator to apply constraints
        def check_attribute(**kwargs):
            def decorate(cls):
                for key, value in kwargs.items():
                    if isinstance(value, Descriptor):
                        value.name = key
                        setattr(cls, key, value)
                    else:
                        setattr(cls, key, value(key))
                return cls

            return decorate

        # Example
        @check_attributes(name=SizedString, shares=UnsignedInteger, price=UnsignedFloat)
        class Stock:
            def __init__(self, name, shares, price):
                self.name = name
                self.shares = shares
                self.price = price

    使用**元类**实现的类型约束检查

        # A Metaclass that applies checking
        class CheckedMeta(type):
            def __new__(cls, clsname, bases, methods):
                # Attach attribute names to the descriptors
                for key, value in methods.items():
                    if isinstance(value, Descriptor):
                        value.name = key
                return type.__new__(cls, clsname, bases, methods)

        # Example
        class Stock(metaclass=CheckedMeta):
            name = SizedString(size=8)
            shares = UnsignedInteger()
            price = UnsignedFloat()

            def __init__(self, name, shares, price):
                self.name = name
                self.shares = shares
                self.price = price

    使用**装饰器**实现的类型约束: 效果与上面的一样, 但执行速度更快.

        # Base class. Uses a descriptor to set a value
        class Descriptor:
            def __init__(self, name=None, **opts):
                self.name = name
                for key, value in opts.items():
                    setattr(self, key, value)

            def __set__(self, instance, value):
                instance.__dict__[self.name] = value

        # Decorator for applying type checking
        def Typed(expected_type, cls=None):
            if cls is None:
                return lambda cls: Typed(expected_type, cls)
            super_set = cls.__set__

            def __set__(self, instance, value):
                if not isinstance(value, expected_type):
                    raise TypeError("Expected " + str(expected_type))
                super_set(self, instance, value)

            cls.__set__ = __set__

            return cls


        # Decorator for unsigned values
        def Unsigned(cls):
            super_set = cls.__set__

            def __set__(self, instance, value):
                if value < 0:
                    raise ValueError("Expected >= 0")
                super_set(self, instance, value)

            cls.__set__ = __set__

            return cls


        # Decorator for allowing sized values
        def MaxSized(cls):
            super_init = cls.__init__

            def __init__(self, name=None, **opts):
                if "size" not in opts:
                    raise TypeError("Missing size option")

                super_init(self, name, **opts)

            cls.__init__ = __init__

            super_set = cls.__set__

            def __set__(self, instance, value):
                if len(value) >= self.size:
                    raise ValueError("Size must be <" + str(self.size))
                super_set(self, instance, value)

            cls.__set__ = __set__

            return cls

        # Specialized decriptors
        @Typed(int)
        class Integer(Descriptor):
            pass

        @Unsigned
        class UnsignedInteger(Integer):
            pass

        @Typed(float)
        class Float(Descriptor):
            pass

        @Unsigned
        class UnsignedFloat(Float):
            pass

        @Typed(str)
        class String(Descriptor):
            pass

        @MaxSized
        class SizedString(String):
            pass


        class Stock:
            # Specify constraints
            name = SizedString('name', size=8)
            shares = UnsignedInteger('shares')
            price = UnsignedFloat('price')

            def __init__(self, name, shares, price):
                self.name = name
                self.shares = shares
                self.price = price

13. 实现自定义容器
    
    `collections` 定义了很多抽象基类, 当需要自定义容器类的时候, 他们会非常有用. 但是, 有时候需要实现 `collections` 抽象基类中的所有抽象方法.

        # 继承自 Sequence 抽象类, 并且实现元素按照顺序存储.
        import collections
        import bisect

        class SortedItems(collections.Sequence):
            def __init__(self, initial=None):
                self._items = sorted(initial) if initial is not None else []

            # Required sequence methods
            def __getitem__(self, index):
                return self._items[index]

            # Required sequence methods
            def __len__(self):
                return len(self._items)

            # method for adding an item in the right location
            # bisect 是在一个排序列表中插入元素的高效方法, 可以保证元素插入后还保持顺序.
            def add(self, item):
                bisect.insort(self._items, item)

        items = SortedItems([5, 3, 1])
        print(list(items))              # [1, 3, 5]
        print(items[0], items[-1])      # 1 5
        items.add(2) 
        print(list(items))              # [1, 2, 3, 5]

        # 自定义容器会满足大部分类型检查需要
        print(isinstance(items, collections.Iterable))  # True
        print(isinstance(items, collections.Sequence))  # True
        print(isinstance(items, collections.Container)) # True
        print(isinstance(items, collections.Sized))     # True
        print(isinstance(items, collections.Mapping))   # False

    使用 `collections` 中的抽象基类可以确保自定义的容器实现了所有必要的方法. 并且还能简化类型检查. `collections` 中的很多抽象类会为一些常见容器操作提供默认实现, 这样一来, 只需实现最感兴趣的方法即可.

        class Items(collections.MutableSequence):
            def __init__(self, initial=None):
                self._items = list(initial) if initial is not None else []

            def __getitem__(self, index):
                print("Getting: ", index)
                return self._items[index]

            def __setitem__(self, index, value):
                print("Setting: ", index, value)
                self._items[index] = value

            def __delitem__(self, index):
                print("Deleting: ", index)
                del self._items[index]

            def insert(self, index, value):
                print("Inserting: ", index, vlaue)
                self._items.insert(index, object)

            def __len__(self):
                print("Len")
                return len(self._items)

    `numbers` 提供了一个类似的跟整数类型相关的抽象类型集合.

14. 属性的代理访问: 将某个实例的属性访问代理到内部另一个实例方法中去, 目的可能是作为继承的一个替代方法或者实现代理模式.
    
    通过自定义属性访问方法, 可以用不同方式自定义代理类行为(如插入日志, 只读访问等)

    **代理** 是一种编程模式, 他将某个操作转移到另外一个对象来实现.

    `__getatt__` 实际是一个后备方法, 只有在**属性不存在**的时候才会调用. 因此, 如果代理类实例本身有这个属性的话, 那么, 不会触发这个方法. 

    另外, `__getattr__` 对于大部分以双下划线 `__` 开始和结尾的属性并**不适用**.

    另外, `__setattr__` `__delattr__` 需要额外的魔法来区分代理实例和被代理实例 `_obj` 属性. 一个通常的约定是只代理那些不以下划线`_` 开头的属性(代理类只暴露被代理类的**公共属性**).

        class A:
            def spam(self, x):
                print("spam")

            def foo(self):
                print("foo")

        class B2:
            def __init__(self):
                self._a = A()

            def bar(self):
                print("bar")

            # Expost all of the methods defined on class A
            # __getattr__ 方法是在访问 attribute 不存在的时候被调用.
            def __getattr__(self, name):
                return getattr(self._a, name)

        b = B2()
        b.spam(123)     # Call B.__getattr__("spam")
        b.bar()         # Call B.bar()

    一个通用代理模式的示例:

        # A proxy class that wraps around another object, but exposts its public attributes
        class Proxy:
            def __init__(self, obj):
                self._obj = obj

            # Delegate attribute lookup to internal obj
            def __getattr__(self, name):
                print("Getattr: ", name)
                return getattr(self._obj, name)

            # Delegate attribute assignment
            def __setattr__(self, name, value):
                if name.startswith("_"):
                    super().__setattr__(name, value)
                else:
                    print("Setattr: ", name, value)
                    setattr(self._obj, name, value)

            # Delegate attributes deletion
            def __delattr__(self, name):
                if name.startswith("_"):
                    super().__delattr__(name)
                else:
                    delattr(self._obj, name)

        class Spam:
            def __init__(self, x):
                self.x = x

            def bar(self, y):
                print("Spam.bar: ", self.x, y)

        s = Spam(2)
        p = Proxy(s)

        print(p.x)
        p.bar(3)
        p.x = 36

15. 在类中定义多个构造器: 类方法.
    
    为了实现多个构造器, 需要使用到 **类方法**. 类方法的一个主要用途就是定义多个构造器, 他接受一个 `class` 作为第一个参数(cls).

        import time

        class Date:
            def __init__(self, year, month, day):
                self.year = year
                self.month = month
                self.day = day

            @classmethod
            def today(cls):
                t = time.localtime()

                return cls(t.tm_year, t.tm_mon, t.tm_mday)

        a = Date(2012, 12, 21)
        b = Date.today()

16. 绕过 `__init__`, 使用 `__new__` 来创建新的类实例.

    使用 `__new__` 创建新的类实例 : 在反序列对象或实现某个类方法构造函数时需要绕过 `__init__()` 方法来创建对象.

        from time import localtime

        class Date:
            def __init__(self, year, month, day):
                self.year = year
                self.month = month
                self.day = day

            @classmethod
            def today(cls):
                d = cls.__new__(cls)
                t = localtime()
                d.year = t.tm_year
                d.month = t.tm_mon
                d.day = t.tm_mday
                return d

17. 使用 Mixins 扩展类功能
    
    你有很多有用的方法, 向使用它们类扩展其他类的功能. 但是这些类并没有任何继承的关系. 此时, 应当使用混入类. 

    如下的混入类使用起来没有任何意义, 事实上, 如果去实例化任何一个类, 除了产生异常外没有任何作用. 他们是用来通过多重继承和其他映射对象混入使用的.

        class LoggedMappingMixin:
            """Add logging to get/set/delete operations for debugging. """
            __slots__ = ()  # 混入类都没有实例变量, 因为直接实例化混入类没有任何意义.

            def __getitem__(self, key):
                print("Getting " + str(key))
                return super().__getitem__(key)

            def __setitem__(self, key, value):
                print("Setting {} = {!r}".format(key, value))
                return super().__setitem__(key, value)

            def __delitem__(self, key):
                print("Deleting " + str(key))
                return super().__delitem__(key)


        class SetOnceMappingMixin:
            """Only allow a key to be set once. """
            __slots__ = ()

            def __setitem__(self, key, value):
                if key in self:
                    raise KeyError(str(key) + " already set")
                return super().__setitem__(key, value)


        class StringKeysMappingMixin:
            """Restrict keys to strings only """
            __slots__ = ()

            def __setitem__(self, key, value):
                if not isinstance(key, str):
                    raise TypeError("Key must be a string")

                return super().__setitem__(key, value)


        class LoggedDict(LoggedMappingMixin, dict):
            pass

        d = LoggedDict()
        d["x"] = 23
        print(d["x"])
        del d["x"]

        from collections import defaultdict

        class SetOnceDefaultDict(SetOnceMappingMixin, defaultdict):
            pass

        sd = SetOnceDefaultDict(list)
        sd["x"].append(2)
        sd["x"].append(3)
        sd["x"] = 23        # KeyError: x already set.

    混入类在标准库中很多地方都出现过, 通常都是用来扩展某些类的功能. 他们也是多继承的一个主要用途. 例如, 编写网络代码时, 通常会使用 `socketserver` 模块中的 `ThreadingMixIn` 来给其他网络相关类增加多线程支持.

        from xmlrpc.server import SimpleXMLRPCServer
        from socketserver import ThreadingMixIn

        class ThreadedXMLRPCServer(ThreadingMixIn, SimpleXMLRPCServer):
            pass

    混入类注意事项:
    1. 混入类不能直接被实例化使用
    2. 混入类没有自己的状态信息, 即 没有定义 `__init__()` 方法, 并且没有实例属性.

    **类装饰器实现的混入类**:

        def LoggedMapping(cls):
            cls_getitem = cls.__getitem__
            cls_setitem = cls.__setitem__
            cls_delitem = cls.__delitem__

            def __getitem__(self, key):
                print("Getting " + str(key))
                return cls_getitem(self, key)

            def __setitem__(self, key, value):
                print("Setting {} = {!r}".format(key, value))
                return cls_setitem(self, key, value)

            def __delitem__(self, key):
                print("Deleteing " + str(key))
                return cls_delitem(self, key)

            cls.__getitem__ = __getitem__
            cls.__setitem__ = __setitem__
            cls.__delitem__ = __delitem__

            return cls

        @LoggedMapping
        class LoggedDict(dict):
            pass

18. 实现状态对象或状态机: 状态模式
    
    有很多程序中, 有些对象会根据状态的不同来执行不同的操作. 使用**状态模式**, 为每个状态定义一个对象(类), 代码如下:

        class Connection1:

            def __init__(self):
                self.new_state(ClosedConnectionState)

            def new_state(self, newstate):
                self._state = newstate
                # Delegate to the state class

            def read(self):
                return self._state.read(self)

            def write(self, data):
                return self._state.write(self, data)

            def open(self):
                return self._state.open(self)

            def close(self):
                return self._state.close(self)

        # Connection state base class
        class ConnectionState:
            @staticmethod
            def read(conn):
                raise NotImplementedError()

            @staticmethod
            def write(conn, data):
                raise NotImplementedError()

            @staticmethod
            def open(conn):
                raise NotImplementedError()

            @staticmethod
            def close(conn):
                raise NotImplementedError()

        # Implementation of different states
        class ClosedConnectionState(ConnectionState):
            @staticmethod
            def read(conn):
                raise RuntimeError("Not Open")

            @staticmethod
            def write(conn, data):
                raise RuntimeError("Not Open")

            @staticmethod
            def open(conn):
                conn.new_state(OpenConnectionState)

            @staticmethod
            def close(conn):
                raise RuntimeError("Already closed")

        class OpenConnectionState(ConnectionState):
            @staticmethod
            def read(conn):
                print("reading")

            @staticmethod
            def write(conn, data):
                print("Writing")

            @staticmethod
            def open(conn):
                raise RuntimeError("Already Open")

            @staticmethod
            def close(conn):
                conn.new_state(ClosedConnectionState)

        # Example to use
        c = Connection1()
        print(c._state)     # <class '__main__.ClosedConnectionState'>
        c.read()            # Error: Not Open
        c.open()
        print(c._state)     # <class '__main__.OpenConnectionState'>
        c.read()            # reading
        c.close()           
        print(c._state)     # <class '__main__.ClosedConnectionState'> 

    这里看上去有点奇怪, 每个状态对象都只有静态方法, 并没有存储任何的实例属性数据. 实际上, 所有状态信息都只存在 `Connection1` 实例中. 在基类中定义的 `NotImplementedError` 只是确保子类实现了相应的方法, 这离也可以使用**抽象基类**的方式实现.

19. 通过**字符串**调用对象方法
    
    调用一个方法实际上是两部独立操作, 第一步是查找属性, 第二步是函数调用. 因为, 为了调用某个方法, 可以先通过 `getattr()` 来查找这个属性, 然后再去以函数方式调用它即可.

    `operator.methodcaller()` 创建一个可调用对象, 并同时提供所有必要参数, 然后调用的时候只需要将实例对象传递给他即可.

    - 使用 `getattr()`

            import math

            class Point:
                def __init__(self, x, y):
                    self.x = x
                    self.y = y

                def __repr__(self):
                    return "Point({!r},{!r})".format(self.x, self.y)
                
                def distance(self, x, y):
                    return math.hypot(self.x - x, self.y - y)

            p = Point(2, 3)
            d = getattr(p, "distance")(0, 0)    # Calls p.distance(0, 0)

    - 使用 `operator.methodcaller()`

            import operator

            operator.methodcaller("distance", 0, 0)(p)

        当需要通过相同的参数多次调用某个方法时, 使用 `operator.methodcaller` 就很方便.

            points = [
                Point(1, 2),
                Point(3, 0),
                Point(10, -3),
                Point(-5, -7),
                Point(-1, 8),
                Point(3, 2)
            ]

            # Sort by distance from origin (0, 0)
            points.sort(key=operator.methodcaller("distance", 0, 0))

20. 实现**访问者模式**
    
    当需要处理由大量不同类型的对象组成的复杂数据结构, 每一个对象都需要进行不同的处理. 此时, 可以使用**访问者模式**来编码.
    
    - 使用**递归**

        这种方式实现的访问者模式的一个缺点就是他严重依赖递归, 如果数据结构嵌套层次太深, 可能会有问题, 有时会超过 Python 的递归深度限制(`sys.getrecursionlimit()`)

            class Node:
                pass

            class UnaryOperator(Node):
                def __init__(self, operand):
                    self.operand = operand

            class BinaryOperator(Node):
                def __init__(self, left, right):
                    self.left = left
                    self.right = right

            class Add(BinaryOperator):
                pass

            class Sub(BinaryOperator):
                pass

            class Mul(BinaryOperator):
                pass

            class Div(BinaryOperator):
                pass

            class Negate(UnaryOperator):
                pass

            class Number(Node):
                def __init__(self, value):
                    self.value = value

            # 1 + 2 * (3 - 4) / 5
            t1 = Sub(Number(3), Number(4))
            t2 = Mul(Number(2), t1)
            t3 = Div(t2, Number(5))
            t4 = Add(Number(1), t3)

            # print(t1, t2, t3, t4)

            print("-" * 30)

            class NodeVisitor:
                def visit(self, node):
                    methname = "visit_" + type(node).__name__
                    meth = getattr(self, methname, None)
                    if meth is None:
                        meth = self.generic_visit
                    return meth(node)

                def generic_visit(self, node):
                    raise RuntimeError("No {} method".format("visit_" + type(node).__name__))

            class Evaluator(NodeVisitor):
                def visit_Number(self, node):
                    return node.value

                def visit_Add(self, node):
                    return self.visit(node.left) + self.visit(node.right)

                def visit_Sub(self, node):
                    return self.visit(node.left) - self.visit(node.right)

                def visit_Mul(self, node):
                    return self.visit(node.left) * self.visit(node.right)

                def visit_Div(self, node):
                    return self.visit(node.left) / self.visit(node.right)

                def visit_Negate(self, node):
                    return -node.operand

            e = Evaluator()
            print(e.visit(t4))      # 0.6

            print("-" * 20)

            class StackCode(NodeVisitor):
                def generate_code(self, node):
                    self.instructions = []
                    self.visit(node)
                    return self.instructions

                def visit_Number(self, node):
                    self.instructions.append(("PUSH", node.value))

                def binop(self, node, instruction):
                    self.visit(node.left)
                    self.visit(node.right)
                    self.instructions.append((instruction))

                def visit_Add(self, node):
                    self.binop(node, "ADD")

                def visit_Sub(self, node):
                    self.binop(node, "SUB")

                def visit_Mul(self, node):
                    self.binop(node, "MUL")

                def visit_Div(self, node):
                    self.binop(node, "DIV")

                def unaryop(self, node, instruction):
                    self.visit(node.operand)
                    self.instructions.append((instruction, ))

                def visit_Negate(self, node):
                    self.unaryop(node, "NEG")


            s = StackCode()
            print(s.generate_code(t4))      # [('PUSH', 1), ('PUSH', 2), ('PUSH', 3), ('PUSH', 4), ('SUB',), ('MUL',), ('PUSH', 5), ('DIV',), ('ADD',)]


        HTTP 的请求分发控制器

            class HTTPHandler:
                def handle(self, request):
                    methname = "do_" + request.request_method
                    getattr(self, methname)(request)

                def do_GET(self, request):
                    pass

                def do_POST(self, request):
                    pass

                def do_HEAD(slef, request):
                    pass

        在跟解析和编译相关的编程中, 使用后访问者模式是非常常见的额. Python 本身的 `ast` 模块值得关注一下.

    - 使用**生成器或迭代器**

        避免递归的一个通常方法是使用一个栈或对垒的数据结构. 例如, 深度优先的遍历算法, 第一次碰到一个节点时, 将其压如栈中, 处理完后弹出栈. `visit()` 方法的核心思路就是这样.

        如下展示了生成器和迭代器在程序控制流方面的强大功能. 

        当程序执行碰到 `yield` 语句时, 生成器会返回一个数据并暂时挂起.即, yield 暂时将程序控制器让出给调用者.

            import types

            class Node:
                pass

            class UnaryOperator(Node):
                def __init__(self, operand):
                    self.operand = operand

            class BinaryOperator(Node):
                def __init__(self, left, right):
                    self.left = left
                    self.right = right

            class Add(BinaryOperator):
                pass

            class Sub(BinaryOperator):
                pass

            class Mul(BinaryOperator):
                pass

            class Div(BinaryOperator):
                pass

            class Negate(UnaryOperator):
                pass

            class Number(Node):
                def __init__(self, value):
                    self.value = value


            class NodeVisitor:
                def visit(self, node):
                    stack = [node]
                    last_result = None
                    while stack:
                        try:
                            last = stack[-1]
                            if isinstance(last, types.GeneratorType):
                                stack.append(last.send(last_result))
                                last_result = None
                            elif isinstance(last, Node):
                                stack.append(self._visit(stack.pop()))
                            else:
                                last_result = stack.pop()
                        except StopIteration:
                            stack.pop()
                    return last_result

                def _visit(self, node):
                    methname = "visit_" + type(node).__name__
                    meth = getattr(self, methname, None)
                    if meth is None:
                        meth = self.generic_visit

                    return meth(node)

                def generic_visit(self, node):
                    raise RuntimeError("No {} method".format("visit_" + type(node).__name__))


            class Evaluator(NodeVisitor):
                def visit_Number(self, node):
                    return node.value

                def visit_Add(self, node):
                    yield (yield node.left) + (yield node.right)

                def visit_Sub(self, node):
                    yield (yield node.left) - (yield node.right)

                def visit_Mul(self, node):
                    yield (yield node.left) * (yield node.right)

                def visit_Div(self, node):
                    yield (yield node.left) / (yield node.right)

                def visit_Negate(self, node):
                    yield - (yield node.operand)

            if __name__ == '__main__':
                t1 = Sub(Number(3), Number(4))
                t2 = Mul(Number(2), t1)
                t3 = Div(t2, Number(5))
                t4 = Add(Number(1), t3)

                e = Evaluator()
                print(e.visit(t4))      # 0.6

                
                a = Number(0)
                for n in range(1, 100000):
                    a = Add(a, Number(n))

                e = Evaluator()
                print(e.visit(a))       # 4999950000

21. 循环引用数据结构的内存管理.
    
    当程序创建了很多循环引用数据结构(如树, 图, 观察者模式等), 此时, 即处理内存管理.

        import weakref

        class Node:
            def __init__(self, value):
                self.value = value
                self._parent = None
                self.children = []

            def __repr__(self):
                return "Node({!r:})".format(self.value)

            @property
            def parent(self):
                return None if self._parent is None else self._parent()

            @parent.setter
            def parent(self, node):
                self._parent = weakref.ref(node)

            def add_child(self, child):
                self.children.append(child)
                child.parent = self

        # 允许 parent 静默终止.
        root = Node("parent")
        c1 = Node("child")
        root.add_child(c1)
        print(c1.parent)    # Node('parent')
        del root
        print(c1.parent)    # None

    循环引用的数据结构在 Python 中是一个很棘手的问题, 因为正常的垃圾回收机制不能适用于这种情形.

    弱引用消除了引用循环的问题, 本质来讲, 弱引用就是一个对象指针, 他不会增加他的引用计数. 可以通过 `weakref` 来创建弱引用. 为了访问弱引用所引用的对象, 可以像函数一样调用即可. 如果那个对象还存在就返回它, 否则返回 None. 由于原始对象的引用计数没有增加, 那么就可以删除它了.

        >>> import weakref
        >>> a = Node()
        >>> a_ref = weakref.ref(a)
        >>> a_ref
        <weakref at 0x100581f70; to 'Node' at 0x1005c5410>

        >>> print(a_ref())
        <__main__.Node object at 0x1005c5410>
        >>> del a
        Data.__del__
        >>> print(a_ref())
        None

22. 让类支持比较操作
    
    可以实现一个特殊方法来支持, 如 `__ge__()` 实现 `>=` 操作. 但是, 当要实现所有的操作符方法, 就比较麻烦.

    装饰器 `functools.total_ordering` 可用来简化这个处理. 使用它来装饰一个类, 只需定义一个 `__eq__()` 方法, 外加其他方法(lt, le, gt, ge) 中的一个即可. 然后装饰器会自动填充其他比较方法.

        from functools import total_ordering 

        class Room:
            def __init__(self, name, length, width):
                self.name = name
                self.length = length
                self.width = width
                self.square_feet = self.length * self.width


        @total_ordering
        class House:
            def __init__(self, name, style):
                self.name = name
                self.style = style
                self.rooms = list()

            @property
            def living_space_footage(self):
                return sum(r.square_feet for r in self.rooms)

            def add_room(self, room):
                self.rooms.append(room)

            def __str__(self):
                return "{}: {} square foot {}".format(self.name, 
                    self.living_space_footage, 
                    self.style)

            def __eq__(self, other):
                return self.living_space_footage == other.living_space_footage

            def __lt__(self, other):
                return self.living_space_footage < other.living_space_footage

        h1 = House("h1", "Cape")
        h1.add_room(Room('Master Bedroom', 14, 21))
        h1.add_room(Room('Living Room', 18, 20))
        h1.add_room(Room('Kitchen', 12, 16))
        h1.add_room(Room('Office', 12, 12))

        h2 = House('h2', 'Ranch')
        h2.add_room(Room('Master Bedroom', 14, 21))
        h2.add_room(Room('Living Room', 18, 20))
        h2.add_room(Room('Kitchen', 12, 16))

        h3 = House('h3', 'Split')
        h3.add_room(Room('Master Bedroom', 14, 21))
        h3.add_room(Room('Living Room', 18, 20))
        h3.add_room(Room('Office', 12, 16))
        h3.add_room(Room('Kitchen', 15, 17))

        houses = [h1, h2, h3]
        print('Is h1 bigger than h2?', h1 > h2) # prints True
        print('Is h2 smaller than h3?', h2 < h3) # prints True
        print('Is h2 greater than or equal to h1?', h2 >= h1) # Prints False
        print('Which one is biggest?', max(houses)) # Prints 'h3: 1101-square-foot Split'
        print('Which is smallest?', min(houses)) # Prints 'h2: 846-square-foot Ranch'

    实际上, `total_ordering` 就是定义了一个从每个比较支持方法到所有需要定义的其他方法的一个映射而已. 如果定义了 `__le__()` 方法, 那么, 他就被用来构建所有其他的需要定义的那些特殊方法.

        class House:
            def __eq__(self, other):
                pass
            def __lt__(self, other):
                pass

            # methods create by @total_ordering
            __le__ = lambda self, other: self < other or self == other
            __gt__ = lambda self, other: not (self < other or self == other)
            __ge__ = lambda self, other: not (self < other)
            __ne__ = lambda self, other: not self == other

23. 创建缓存实例
    
    在创建一个类对象时, 如果之前使用同样参数创建过这个对象, 希望返回它的缓存引用.

    1. 使用一个和类本身分开的工厂函数
        
            class Spam:
                def __init__(self, name):
                    self.name = name

            import weakref
            _spam_cache = weakref.WeakValueDictionary()

            # 使用一个和类本身分开的工厂函数
            def get_spam(name):
                if name not in _spam_cache:
                    s = Spam(name)
                    _spam_cache[name] = s
                else:
                    s = _spam_cache[name]
                return s 

            a = get_spam("foo")
            b = get_spam("bar")
            print(a is b)       # False

            c = get_spam("foo")
            print(a is c)       # True

    2. 将缓存代码放到一个单独的管理类中. 然后将这些组件粘合起来.

        这种写法为潜在的灵活性提供了更多的支持.

            import weakref

            class CacheSpamManager:
                def __init__(self):
                    self._cache = weakref.WeakValueDictionary()

                def get_spam(self, name):
                    if name not in self._cache:
                        s = Spam(name)
                        self._cache[name] = s 
                    else:
                        s = self._cache[name]
                    return s 

                def clear(self):
                    self._cache.clear()

            class Spam:
                manager = CacheSpamManager()
                def __init__(self, name):
                    self.name = name

                # Python 3 中的静态方法
                def get_spam(name):
                    return Spam.manager.get_spam(name)

            a = Spam.get_spam("name")
            b = Spam.get_spam("name")
            print(a is b)       # True

            c = Spam("foo")
            d = Spam("foo")
            print(c is d)       # False


        另一种更加强化的暗示: 不应该直接实例化 Spam 对象, 可以让 `__init__()` 方法抛出一个异常.

            class CacheSpamManager:
                def __init__(self):
                    self._cache = weakref.WeakValueDictionary()

                def get_spam(self, name):
                    if name not in self._cache:
                        s = Spam._new(name)
                        self._cache[name] = s
                    else:
                        s = self._cache[name]
                    return s

            class Spam:
                def __init__(self, *args, **kwagrs):
                    raise RuntimeError("Can't instantiate directly!")

                # Alternate constructor
                @classmethod
                def _new(cls, name):
                    self = cls.__new__(cls)
                    self.name = name
                    return self

            a = CacheSpamManager()
            m = a.get_spam("name")
            n = a.get_spam("name")
            print(m is n)           # True


## 元编程
**元编程**的主要目的是创建函数和类, 并用他们来操作代码(比如修改, 生成或者包装已有的代码). Python 中基于这个目的的主要特性包括 装饰器, 类装饰器, 以及元类. 还有其他主题, 包括对象签名, 用 exec() 来执行代码 以及 检查函数和类的内部结构.

1. 装饰器 及保存函数元数据
    
    一个简单的装饰器.

        import time
        from functools import wraps

        def timethis(func):
            """ Decorator that reports the execution time."""
            @wraps(func)    # 用来保存函数的元数据
            def wrapper(*args, **kwargs):
                start = time.time()
                result = func(*args, **kwargs)
                end = time.time()
                print(func.__name__, end - start)
                return result

            return wrapper 

        @timethis
        def countdown(n):
            while n>0:
                n -= 1

        countdown(10123901)   # countdown 1.0877728462219238
        countdown(101111)     # countdown 0.01100778579711914

    保存函数的元数据`@wraps(func)`: `@wraps` 装饰器的一个重要特性就是他可以通过`__wrapped__` 属性来访问被包装的那个函数(原函数). 但是, 并不是所有的装饰器都使用了 `@wraps`, 如 @staticmethod, @classmethod 创建的描述符对象吧原数函数保存在 `__func__` 属性中.

    底层的函数签名可以使用 `__wrapped__` 属性来传递.

        import time
        from functools import wraps

        def timethis(func):
            """ Decorator that reports the execution time."""
            @wraps(func)    # 用来保存函数的元数据
            def wrapper(*args, **kwargs):
                start = time.time()
                result = func(*args, **kwargs)
                end = time.time()
                print(func.__name__, end - start)
                return result

            return wrapper 

        @timethis
        def countdown(n:int):
            """DocString for countdown"""
            while n>0:
                n -= 1

        countdown(101111)     # countdown 0.01100778579711914
        print(countdown.__doc__)  # DocString for countdown
        print(countdown.__name__)  # countdown
        print(countdown.__annotations__)  # {'n': <class 'int'>}

2. 可接受参数的装饰器
    
    其中的思想很简单: 最外层的 `logged()` 函数接受所需的参数, 并让他们对装饰器的内层函数可见. 内层的 `decorate()` 函数接受一个函数并给他加上一个包装层. 关键部分在于: 这个包装层可以使用传递给 `logged()` 的参数.

        from functools import wraps
        import logging

        def logged(level, name=None, message=None):
            """Add logging to a function. Level is the logging level, 
            name is the logger name, add message is the log message.
            If name and message aren't specified, they default to the 
            function's module and name.
            """
            def decorate(func):
                logname = name if name else func.__module__
                log = logging.getLogger(logname)
                logmsg = message if message else func.__name__

                @wraps(func)
                def wrapper(*args, **kwargs):
                    log.log(level, logmsg)
                    return func(*args, **kwargs)
                return wrapper
            return decorate

        # Example use
        @logged(logging.DEBUG)
        def add(x, y):
            return x + y

        @logged(logging.CRITICAL, message="Example")
        def spam():
            print("Spam!")

    编写一个可接受参数的装饰器是需要技巧的, 因为涉及底层的调用顺序.

        @decorator(x, y, z)
        def func(a, b):
            pass

        # 可以映射为如下调用

        def func(a, b):
            pass
        func = decorator(x, y, z)(a, b)     # decorator(x, y, z) 必须返回一个可调用对象. 该对象接受一个函数作为参数, 并对其进行包装.

3. 定义一个属性可由用户修改的装饰器
    
    编写一个装饰器来包装函数, 但是可以让用户调整装饰器的属性, 这样在运行时能够控制装饰器的行为.

    P342 --
    

        from functools import wraps, partial
        import logging

        # Utility decorator to attach a function as an attribute of obj
        def attach_wrapper(obj, func=None):
            if func is None:
                return partial(attach_wrapper, obj)
            setattr(obj, func.__name__, func)
            return func

        def logged(level, name=None, message=None):
            """Add logging to a function. Level is the logging level, 
            name is the logger name, add message is the log message.
            If name and message aren't specified, they default to the 
            function's module and name.
            """
            def decorate(func):
                logname = name if name else func.__module__
                log = logging.getLogger(logname)
                logmsg = message if message else func.__name__

                @wraps(func)
                def wrapper(*args, **kwargs):
                    log.log(level, logmsg)
                    return func(*args, **kwargs)

                # Attach setter functions
                @attach_wrapper(wrapper)
                def set_level(newlevel):
                    nonlocal level
                    level = newlevel

                @attach_wrapper(wrapper)
                def set_message(newmsg):
                    nonlocal logmsg
                    logmsg = newmsg

                return wrapper
            return decorate

        # Example use
        @logged(logging.DEBUG)
        def add(x, y):
            return x + y

        @logged(logging.CRITICAL, message="Example")
        def spam():
            print("Spam!")


        logging.basicConfig(level=logging.DEBUG)
        add(2, 4)   # DEBUG:__main__:add

        add.set_message("Add called!")
        add(2, 4)   # DEBUG:__main__:Add called!

        add.set_level(logging.WARNING)
        add(2, 4)   # WARNING:__main__:Add called!


## 模块与包
`__init__.py` 文件优先 py 文件被导入.
`__all__` = ["a", "b"] :  用来显式列出可导出的符号名. 如果列表为空, 则任何符号都不会导出; 如果 `__all__` 中包含有未定义的名称, 那么在执行 import 语句是会产生一个 AttributeError 异常.

重新加载模块:
    
    import imp
    imp.reload(MOD_NAME)    # 是适用于 from module import name 这样的语句导入定义.

让目录或 zip 文件称为可运行的脚本 `__main__.py` : 这与标准库中的包有所不同, 这里只是把代码打包起来方便给其他人执行.
    
    # 目录 : 
        $ tree new
            new/
            ├── a.py
            └── __main__.py
            
        $ python new

    # zip 文件
        $ cd new && zip new.zip *
        $ python new.zip

获取包中的数据文件
    
    mypkg/
        __init__.py
        somedata.dat
        spam.py

    # spam.py
    import pkgutil
    data = pkgutil.get_data(__package__, "somedata.dat")

    pkgutil.get_data() 函数是一个高级工具, 可以把文件内容以**字节串**形式返回文件原始内容. 其第一个参数为 包名的字符串表示, 也可以使用 __package__ 变量; 第二个参数为 数据文件 相对于包的名称(数据文件必须位于包内).

## 网络与 web 编程


## 并发编程


## 脚本编程与系统管理


## 测试调试与异常



--------------------------------
# 管理属性

1. __getattr__ 和 __setattr__ 方法: 

    把未定义的属性获取和所有的属性赋值, 指定通用的处理器方法

2. __getattribute__ 方法: 
    
    把所有属性获取都执行 Python2.6 的新式类和 Python3.0 的所有类中的一个泛型处理器方法.

3. property 内置函数: 
    
    把特性属性访问定位到 get 和 set 处理器函数, 也叫作特性(Property). 特性和描述符有很大关系, 基本上是描述符的一种受限制的形式.
    
4. 描述符协议, 把特定属性访问定位到具有任意 get 和 set 处理器方法的类的实例.

## 特性

    class Person:
        def __init__(self, name):
            self._name = name

        def getName(self):
            print("Fetch ...")
            return self._name

        def setName(self, value):
            print("Setting ...")
            self._name = value

        def delName(self):
            print("remove ing")
            del self._name
        name = property(getName, setName, delName, "Name Property Docs")

## 描述符
描述符协议允许吧一个特性属性的 get 和 set 操作执行一个单独类对象的方法. 提供了一种方式来插入在访问属性的时候自动运行的代码, 并且允许拦截属性删除并且为属性提供文档.

描述符作为单独的类创建, 并且他们就像方法函数一样分配给类属性. 和任何其他的类属性一样, 他们可以通过子类和实例继承. 通过为描述符自身提供一个 self, 以及提供客户类的实例, 都可以提供访问拦截方法.
    
    class Descriptor:
        """Docstring goes here
        self: 描述符实例
        instance: 描述符实例所附加的客户类的实例. 可以是访问的属性所属的实例(用于 instance.attr), 也可以是所访问的属性直接属于类的时候是 None(用于 class.attr )
        owner: 指定描述符实例要附加到的类.
        value: 
        """
        def __get__(self, instance, owner):
            """return attr value """
            pass

        def __set__(self, instance, value):
            """Return None"""
            pass

        def __delete__(self, instance):
            """Return None"""
            pass

如果描述符的任意一个方法空缺, 通常意味着不支持相应类型的访问. 例如, 要设置一个属性是只读的, 必须定义 __set__ 来捕获赋值并引发一个异常.

    class Descriptor:
        def __get__(self, instance, owner):
            print(self, instance, owner, sep="\n")
            return "Bob"

    class Sub:
        attr = Descriptor()

    x = Sub()
    x.attr
        <__main__.Descriptor object at 0x03AD4410>
        <__main__.Sub object at 0x03AD4470>
        <class '__main__.Sub'>
    Sub.attr
        <__main__.Descriptor object at 0x03874410>
        None
        <class '__main__.Sub'>


计算属性

    class DescSquare:
        def __init__(self, start):
            self.value = start

        def __get__(self, instance, owner):
            return self.value ** 2

        def __set__(self, instance, value):
            self.value = value

    class Client:
        x = DescSquare(3)

    c = Client()
    print(c.x)  # 9
    c.x = 4
    print(c.x)  # 16

在描述符中使用状态信息: 实例状态 或 描述符状态.
1. 描述符状态用来管理内部用于描述符工作的数据
2. 实例状态记录了和客户类相关的信息, 以及可能由客户类创建的信息.

使用实例状态示例:

    class InstState:
        def __get__(self, instance, owner):
            print("InstState get")
            return instance._Y * 100

        def __set__(self, instance, value):
            print("InstState Set")
            instance._Y = value

    class CalcAttrs:
        Y = InstState()
        def __init__(self):
            self._Y = 3
            self.Z = 4

    obj = CalcAttrs()
    print(obj.Y, obj.Z)  # 300 4
    obj.Y = 6
    obj.Z = 7
    print(obj.Y, obj.Z)  # 600 4

特性与描述符相关

    class Property:
        def __init__(self, fget=None, fset=None, fdel=None, doc=None):
            self.fget = fget
            self.fset= fset
            self.fdel = fdel
            self.__doc__ = doc

        def __get__(self, instance, instancetype=None):
            if instance is None:
                return self

            if self.fget is None:
                raise AttributeError("Cann't get attribute")

            return self.fget(instance)

        def __set__(self, instance, value):
            if self.fget is None:
                raise AttributeError("Can't set attribute")
            self.fset(instance, value)

        def __delete__(self, isinstance):
            if self.fdel is None:
                raise AttributeError("Can't delete attribute")
            self.fdel(instance)

## __getattr__ 和 __getattribute__

__getattr__ 和 __getattribute__ 操作符重载方法, 提供了拦截类实例的**属性获取**的另一种方法. 允许插入当访问属性的时候, 自动运行的代码. 

`__getattr__` : 针对未定义的属性运行.即, 属性没有存储在实例上, 或者没有从其父类继承.

`__getattribute__` : 针对每个属性. 在使用时, 应当避免通过把属性访问传递给超类而导致递归循环.


如果一个类定义或继承了如下方法, 那么当一个实例用于后面的注释所提到的情况时, 他们将自动运行:
    
    def __getattr__(self, name)     # On undefined attribude fetch [obj.name]
    def __getattribute__(self, name)    # On all attribude fetch [obj.name]
    def __setattr__(self, name)     # On all attribude assignment [obj.name = value]
    def __delattr__(self, name)     # On all attribude deletion [del obj.name]

实例:

    class Catcher:
        def __getattr__(self, name):
            print("Get:", name)

        def __setattr__(self, name, value):
            print("Set: ", name, value)

    x = Catcher()

    x.job       # Get: job
    x.pay       # Get: pay
    x.pay = 100 # Set:  pay 100
    x.pay       # Get: pay


避免循环: 由于 __getattr__ 仅针对未定义的属性调用, 所以他可以在自己的代码中自由的获取其他属性. 然而, 由于 __getattribute__ 和 __setattr__ 针对所有属性, 因此, 他们的代码中要注意在访问其他属性的时候, 避免再次调用自己并触发一次递归循环.

1. __getattribute__ : 把获取指向更高的超类
        
        # WRONG: 死循环
        def __getattribute__(self, name):
            x = self.other

        # 把获取指向更高的超类
        def __getattribute__(self, name):
            x = object.__getattribute__(self, "other")

2. __setattr__ : 把属性作为实例 __dict__ 命名空间字典中一个键赋值
    

        # 死循环
        def __setattr__(self, name, value):
            self.name = value

        # 把属性作为实例的 __dict__ 命名空间字典的一个键赋值
        def __setattr__(self, name, value):
            self.__dict__[name] = value

示例: 在 `__init__` 构造函数中的属性赋值也会触发 `__setattr__`

    class Person:
        def __init__(self, name):
            self._name = name

        def __getattr__(self, attr):
            if attr == "name":
                print("Fetch ...")
                return self._name
            else:
                raise AttributeError(attr)
                
        # __getattr__ 替换为 __getattribute__ 实现
        # def __getattribute__(self, attr):
        #     if attr == "name":
        #         print("Fetch ...")
        #         attr = "_name"
        #     return object.__getattribute__(self, attr)

        def __setattr__(self, attr, value):
            if attr == "name":
                print("Set ...")
                attr = "_name"

            self.__dict__[attr] = value

        def __delattr__(self, attr):
            if attr == "name":
                print("Remove ...")
                attr = "_name"

            del self.__dict__[attr]

    bob = Person("Bob Smith")
    print(bob.name)
    bob.name = "Robert Smith"
    print(bob.name)
    del bob.name

__getattr__ 和 __getattribute__ 区别:

1. __getattr__ 仅拦截未定义属性;  __getattribute__ 拦截所有属性.
        
        # __getattr__
        class GetAttr:
            attr1 = 1
            def __init__(self):
                self.attr2 =2

            def __getattr__(self, attr):
                print("Get:" + attr)
                return 3

        obj = GetAttr()
        print(obj.attr1)    # 1
        print(obj.attr2)    # 2
        print(obj.attr3)    # Get: attr3\n3

        # __getattribute__
        class GetAttribute:
            attr1 = 1
            def __init__(self):
                self.attr2 =2

            def __getattribute__(self, attr):
                print("Get:" + attr)
                if attr == "attr3":
                    return 3
                else:
                    return object.__getattribute__(self, attr)

        obj = GetAttribute()
        print(obj.attr1)    # Get:attr1\n1
        print(obj.attr2)    # Get:attr2\n1
        print(obj.attr3)    # Get:attr3\n1

2. 拦截内置操作

    针对 __str__, __add__, __getitem__ 方法的属性获取分别通过打印, +表达式, 索引 隐式调用运行.

    - 在 Python3.0 中, __getattr__ 和 __getattribute__ 都不会针对这样的属性运行.
    - 在 Python2.6 中, 如果属性在类中未定义的话, __getattr__ 会针对这样的属性运行.
    - 在 Python2.6 中, __getattribute__ 只针对新式类可用, 并且在 Python3.0 中可用.

# 装饰器
装饰器本身的形式是处理其他的可调用对象的可调用对象. 装饰器提供一种方法, 在函数和类**定义语句的末尾**插入自动运行代码. 对于函数装饰器, 在 def 末尾; 对于类装饰器, 在 class 末尾.

Python 装饰器以两种相关的形式呈现:
1. 函数装饰器
    
    在函数定义的时候进行名称重绑定, 提供一个逻辑层来管理函数和方法, 或随后对他们的调用.

2. 类装饰器
    
    在类定义的时候, 进程名称重绑定, 提供一个逻辑层来管理类, 或管理随后调用他们所创建的实例.


装饰器用法:
1. 用包装器来拦截对函数和类的调用.
2. 通过返回装饰的对象自身, 而不是包装器, 装饰器编程针对函数和类的一种简单的后创建步骤.

    - 函数装饰器可以用来管理函数对象, 即可以用来管理函数调用和函数对象.
    - 类装饰器可以用来直接管理类对象, 即可以用来管理类实例和类自身. 这种用法与元类有重合, 实际上, 都是在类创建过程的最后运行.

    示例代码:

        def decorator(O):
            # Save of augment funciton or class O
            return O

        @decorator
        def F():
            ...

        @decorator
        class C:
            ...

## 装饰器基础

### 函数装饰器
函数装饰器是一种关于函数的运行时声明, 函数的定义需要遵守此声明. 
    
    @decorator      # 装饰器返回与 F 具有相同数目的参数的一个可调用对象.
    def F(arg):
        ...
    F(99)

    # 等同于
    def F(arg):
        ...
    F = decorator(F)
    F(99)


#### 编写函数装饰器示例
1. 跟踪调用
    
    统计对装饰的函数的调用次数

        class tracer:
            def __init__(self, func):
                self.calls = 0
                self.func = func
  
            def __call__(self, *args):
                self.calls += 1
                print("Call %s to %s" % (self.calls, self.func.__name__))
                self.func(*args)

        @tracer
        def spam(a, b, c):
            print(a + b + c)

        for i in range(10):
            spam(i , i+1, i+2)

        print(spam.calls)   # 10
        print(spam)         # <__main__.tracer object at 0x035C4470>

2. 状态信息保持选项
    
    函数装饰器有各种选项来保持装饰的时候所提供的状态信息, 一遍在实际函数调用过程中使用. 他们通常需要支持多个装饰的对象以及多个调用, 但是, 有多重方法来实现这些目标: 实例属性, 全局变量, 非局部变量, 函数属性, 等都可用于保持状态.

    
    - 类实例属性    

            class tracer:
                def __init__(self, func):
                    self.calls = 0
                    self.func = func

                def __call__(self, *args, **kwargs):
                    self.calls += 1
                    print("Call %s to %s" % (self.calls, self.func.__name__))
                    self.func(*args, **kwargs)

            @tracer
            def spam(a, b, c):
                print(a + b + c)

            @tracer
            def eggs(x, y):
                print(x * y)

            spam(1, 2, 3)       # Call 1 to spam \n 6
            spam(a=4, b=5, c=6) # Call 2 to spam \n 15

            eggs(2, 16)         # Call 1 to eggs \n 32
            eggs(4, y=16)       # Call 2 to eggs \n 64

    - 封闭作用域和全局作用域

        将计数器溢出到共同的全局作用域意味着计数器将为每个包装的函数所共享. 和类实例属性不同, 全局计数器是跨程序的, 而不是针对每个函数的, 对于任何跟踪的函数的调用, 计数器都会递增.

            calls = 0

            def tracer(func):
                def wrapper(*args, **kwagrs):
                    global calls 
                    calls += 1
                    print("Call %s to %s" % (calls, func.__name__))
                    return func(*args, **kwagrs)

                return wrapper 
                
            @tracer
            def spam(a, b, c):
                print(a + b + c)

            @tracer
            def eggs(x, y):
                print(x * y)

            spam(1, 2, 3)       # Call 1 to spam \n 6
            spam(a=4, b=5, c=6) # Call 2 to spam \n 15

            eggs(2, 16)         # Call 3 to eggs \n 32
            eggs(4, y=16)       # Call 4 to eggs \n 64

    - 封闭作用域和 nonlocal

        nonlocal 语序修改封闭的函数作用于变量, 所以他可以充当针对每次装饰的, 可修改的数据.

            def tracer(func):
                calls = 0
                def wrapper(*args, **kwagrs):
                    nonlocal calls
                    calls += 1
                    print("Call %s to %s" % (calls, func.__name__))
                    return func(*args, **kwagrs)

                return wrapper 

            @tracer
            def spam(a, b, c):
                print(a + b + c)

            @tracer
            def eggs(x, y):
                print(x * y)

            spam(1, 2, 3)       # Call 1 to spam \n 6
            spam(a=4, b=5, c=6) # Call 2 to spam \n 15

            eggs(2, 16)         # Call 1 to eggs \n 32
            eggs(4, y=16)       # Call 2 to eggs \n 64

        由于封装的作用域变量不能跨程序而成为全局的, 所以每个包装的函数再次有了自己的计数器.

    - 函数属性.

        函数属性可以实现与 nonlocal 一样的功能: 每个被装饰的函数有自己的计数器.

        这种方法有效是因为名称 wrapper 保持在封闭的 tracer 函数的作用域中. 当我们随后增加 wrapper.calls 时, 并不是在修改 wrapper 本身, 因此不需要 nonlocal 声明.

        同时, 函数属性允许我们从装饰器代码的外部访问保存的状态, 因此, 它具有更广泛的可见性.

            def tracer(func):
                def wrapper(*args, **kwargs):
                    wrapper.calls += 1
                    print("Call %s to %s" % (wrapper.calls, func.__name__))
                    return func(*args, **kwargs)
                wrapper.calls = 0
                return wrapper 

3. 装饰类方法
    
    使用基于类的装饰器装饰类的时候失败了(如下), 其根本原因在于 tracer 类的 __call__ 方法的 self , 它必须是  tracer 对象, 以提供对 tracer 的状态信息的访问. 但是, 当我们用 __call__ 把装饰方法名重绑定到一个类实例对象的时候, Python 指向 self 传递了 tracer 实例, 根本没有在参数列表中传递 Person 主体. 此外, 由于 tracer 不知道我们要用方法调用处理的 Person 实例的任何信息, 没有办法创建一个带有一个实例的绑定的方法, 因此, 没有办法正确的分配调用.

        class tracer:
            def __init__(self, func):
                self.calls = 0
                self.func = func

            def __call__(self, *args, **kwargs):
                self.calls += 1
                print("Call %s to %s" % (self.calls, self.func.__name__))
                return self.func(*args, **kwargs)

        @tracer
        def spam(a, b, c):
            print(a+b+c)

        spam(1, 2, 3)
        spam(a=1, b=2, c=4)

        class Person:
            def __init__(self, name, pay):
                self.name = name
                self.pay = pay

            @tracer
            def giveRaise(self, percent):
                self.pay *= (1.0 + percent)

            @tracer
            def lastName(self):
                return self.name.split()[-1]

        bob = Person("Bob Smith", 500)
        bob.giveRaise(0.25)     # 失败, TypeError: giveRaise() missing 1 required positional argument: 'percent'

    - 使用嵌套函数来装饰方法



            def tracer(func):
                calls = 0
                def onCall(*args, **kwargs):
                    nonlocal calls
                    calls += 1
                    print("Call %s to %s" % (calls, func.__name__))
                    return func(*args, **kwargs)

                return onCall 

            @tracer
            def spam(a, b, c):
                print(a+b+c)

            spam(1, 2, 3)
            spam(a=1, b=2, c=4)

            class Person:
                def __init__(self, name, pay):
                    self.name = name
                    self.pay = pay

                @tracer
                def giveRaise(self, percent):
                    self.pay *= (1.0 + percent)

                @tracer
                def lastName(self):
                    return self.name.split()[-1]

            bob = Person("Bob Smith", 500)
            bob.giveRaise(0.25)
            print(bob.pay)
            print(bob.lastName())

    - 使用描述符装饰方法

            class tracer:
                def __init__(self, func):
                    self.calls = 0
                    self.func = func

                def __call__(self, *args, **kwargs):
                    self.calls += 1
                    print("Call %s to %s" % (self.calls, self.func.__name__))
                    return self.func(*args, **kwargs)

                def __get__(self, instance, owner):
                    return wrapper(self, instance)

            class wrapper:
                def __init__(self, desc, subj):
                    self.desc = desc
                    self.subj = subj

                def __call__(self, *args, **kwargs):
                    return self.desc(self.subj, *args, **kwargs)


            @tracer
            def spam(a, b, c):
                print(a+b+c)

            spam(1, 2, 3)
            spam(a=1, b=2, c=4)

            class Person:
                def __init__(self, name, pay):
                    self.name = name
                    self.pay = pay

                @tracer
                def giveRaise(self, percent):
                    self.pay *= (1.0 + percent)

                @tracer
                def lastName(self):
                    return self.name.split()[-1]

            bob = Person("Bob Smith", 500)
            bob.giveRaise(0.25)
            print(bob.pay)
            print(bob.lastName())

            # 也可以使用如下实现嵌套函数和封闭作用域:
            class tracer:
                def __init__(self, func):
                    self.calls = 0
                    self.func = func

                def __call__(self, *args, **kwargs):
                    self.calls += 1
                    print("Call %s to %s" % (self.calls, self.func.__name__))
                    return self.func(*args, **kwargs)

                def __get__(self, instance, owner):
                    def wrapper(*args, **kwargs):
                        return self(instance, *args, **kwargs)
                    return wrapper

4. 计时调用
    
    对一个装饰的函数的调用进行及时.

        import time

        class timer:
            def __init__(self, func):
                self.func = func
                self.alltime = 0

            def __call__(self, *args, **kwargs):
                start = time.clock()
                result = self.func(*args, **kwargs)
                elapsed = time.clock() - start
                self.alltime += elapsed
                print("%s: %.5f, %.5f" % (self.func.__name__, elapsed, self.alltime))
                return result


        @timer
        def listcomp(N):
            return [x*2 for x in range(N)]


        @timer
        def mapcall(N):
            # map 在 python3 中是一个迭代器, 所以, 用 list 解包
            return list(map((lambda x: x*2), range(N)))


        for i in [5, 50000, 500000, 1000000]:
            listcomp(i)
            mapcall(i)
            print("-" * 20)


5. 添加装饰器参数 : 让装饰器可配置.
    
    以下代码把最初的 Timer类 嵌入了一个封闭的函数中, 以便创建一个作用域以保持装饰器参数. 外围的 timer 函数在装饰发生前调用, 并且它只是返回 Timer类 作为实际的装饰器. 在装饰时, 创建了一个 Timer类的实例来记录装饰函数自身, 而且访问了位于封闭函数作用于中的装饰器参数.

        import time

        def timer(label="",  trace=True):
            class Timer:
                def __init__(self, func):
                    self.func = func
                    self.alltime = 0

                def __call__(self, *args, **kwargs):
                    start = time.clock()
                    result = self.func(*args, **kwargs)
                    elapsed = time.clock() - start
                    self.alltime += elapsed

                    if  trace:
                        format = "%s %s: %.5f, %.5f"
                        values = (label, self.func.__name__, elapsed, self.alltime)
                        print(format % values)

                    return result
            return Timer


        @timer(label="[CCC]==>")
        def listcomp(N):
            return [x*2 for x in range(N)]


        @timer(label="[MMM]==>", trace=False)
        def mapcall(N):
            return list(map((lambda x: x*2), range(N)))


        for i in [5, 50000, 500000, 1000000]:
            listcomp(i)
            mapcall(i)
            print("-" * 20)


### 类装饰器
Python 2.6 和 Python 3 扩展了装饰器, 使其也能在类上有效.
类装饰器是管理类的一种方式, 或者用管理或扩展类所创建的实例的额外逻辑来包装实例构建调用.

类装饰器的结果是当随后创建一个实例的时候才运行.

    @decorator
    class C:
        ...
    x = C(99)

    # 等同于
    class C:
        ...
    C = decorator(C)
    x = C(99)

示例: 插入一个对象来拦截一个类实例的未定义的属性. 装饰器把类的名称调用重新绑定到另一个类, 这个类在一个封闭的作用域中保持了最初的类, 并且当调用它的时候, 创建并嵌入了最初的类的一个实例. 当随后从该实例获取一个属性的时候, 包装器的 `__getattr__` 拦截了他, 并且将其委托给最初的类的嵌入的实例. 此外, 每个被装饰的类都创建一个新的作用域, 他记住了最初的类.
    
    def decorator(cls):
        class Wrapper:
            def __init__(self, *args):
                self.wrapped = cls(*args)

            def __getattr__(self, name):
                return getattr(self.wrapped, name)

        return Wrapper

    @decorator
    class C:
        def __init__(self, x, y):
            self.attr = "spam"

    x = C(6, 7)
    print(x.attr)   # spam

#### 单体类: 管理类的所有实例
由于类装饰器可以拦截实例创建调用, 所以他们可以用来管理一个类的所有实例, 或者扩展这些实例的接口.

管理一个类的所有实例:

1. 使用全局属性

        instances = {}

        def getInstance(aClass, *args):
            if aClass not in instances:
                instances[aClass] = aClass(*args)
            return instances[aClass]


        def singleton(aClass):
            """ 使用全局表"""
            def onCall(*args):
                return getInstance(aClass, *args)
            return onCall 

2. 使用封闭作用域

        def singleton(aClass):
            """不依赖于装饰器之外的全局作用域中的名称. 只用于 python3 ."""
            instance = None
            def onCall(*args):
                nonlocal instance
                if instance == None:
                    instance = aClass(*args)
                return instance
            return onCall

3. 使用类

        class singleton:
            """ 对每个类使用一个实例.  """
            def __init__(self, aClass):
                self.aClass = aClass
                self.instance = None

            def __call__(self, *args):
                if self.instance == None:
                    self.instance = self.aClass(*args)
                return self.instance

4. 调用装饰器结果

        @singleton
        class Person:
            def __init__(self, name, hours, rate):
                self.name = name
                self.hours = hours
                self.rate = rate

            def pay(self):
                return self.hours * self.rate


        @singleton
        class Spam:
            def __init__(self, val):
                self.attr = val


        bob = Person("bob", 40, 10)
        print(bob.name, bob.pay())      # bob 400

        sue = Person("Sue", 50, 20)
        print(sue.name, sue.pay())      # bob 400

        x = Spam(42)
        y = Spam(99)
        print(x.attr, y.attr)           # 42 42


#### 跟踪对象接口: 
类装饰器的另一个场景是每个产生实例的接口. 类装饰器基本上可以在实例上安装一个包装器逻辑层, 来以某种方式管理对其接口的访问.

`__getattr__` 运算符重载方法作为包装嵌入的实例的整个对象接口的一种方法, 以便实现委托编码模式.

    class Wrapper:
        """ __getattr__ 拦截一个控制器类中的方法调用 """
        def __init__(self, obj):
            self.wrapped = obj

        def __getattr__(self, attrname):
            print("Trace:", attrname)
            return getattr(self.wrapped, attrname)


    x = Wrapper([1,2,3])
    x.append(4)             # Trace: append
    print(x.wrapped)        # [1, 2, 3, 4]

拦截实例创建调用, 下面的类装饰器可以实现跟踪整个对象接口.

    def Tracer(aClass):
        class Wrapper:
            def __init__(self, *args, **kwargs):
                self.fetches = 0
                self.wrapped = aClass(*args, **kwargs)

            def __getattr__(self, attrname):
                print("Trace: " + attrname)
                self.fetches += 1
                return getattr(self.wrapped, attrname)

        return Wrapper 


    @Tracer
    class Spam:
        def display(self):
            print("Spam!" * 8)


    @Tracer
    class Person:
        def __init__(self, name, hours, rate):
            self.name = name
            self.hours = hours
            self.rate = rate

        def pay(self):
            return self.hours * self.rate

    food = Spam()
    food.display()
    print([food.fetches])

    bob = Person("bob", 40, 50)
    print(bob.name)
    print(bob.pay())

    sue = Person("Sue", rate=100, hours=60)
    print(sue.name)
    print(sue.pay())

    print(bob.name)
    print(bob.pay())

    print([bob.fetches, sue.fetches])

手动示例, 这中装饰器方法允许我们把实例创建移动到装饰器自身之中, 而不是要求传入一个预先生成的对象, 即他允许我们保留常规的实例创建语法并且通常实现装饰器的所有有限. 我们只需要用装饰器语法来扩展类, 而不是要求所有的实例创建调用都通过一个包装器来手动的指向对象.

    def Tracer(aClass):
        class Wrapper:
            def __init__(self, *args, **kwargs):
                self.fetches = 0
                self.wrapped = aClass(*args, **kwargs)

            def __getattr__(self, attrname):
                print("Trace: " + attrname)
                self.fetches += 1
                return getattr(self.wrapped, attrname)

        return Wrapper 

    @Tracer
    class MyList(list):
        pass

    l = MyList([1,2,3])
    l.append(4)             # Trace: append
    print(l.wrapped)        # [1, 2, 3, 4]

    WrapList = Tracer(list)
    x = WrapList([4,5,6])
    x.append(7)             # Trace: append
    print(x.wrapped)        # [4, 5, 6, 7]

#### 类错误之二: 保护多个实例
如下示例, 可能看上去类似上面的实例, 但他对于一个给定多个实例并不是很有效: 每个实例创建都会触发 `__call__`, 这会覆盖前面的实例. 直接效果是 Tracer 只保留了一个实例, 即最后创建的一个实例. 

我们为每个类装饰器创建了一个装饰器实例, 但是不是针对每个类实例 --> 解决方法: 放弃基于类的装饰器.

    class Tracer:
        def __init__(self, aClass):
            self.aClass = aClass

        def __call__(self, *args):
            self.wrapped = self.aClass(*args)
            return self

        def __getattr__(self, attrname):
            print("Trace: ", attrname)
            return getattr(self.wrapped, attrname)

    @Tracer
    class Person:
        def __init__(self, name):
            self.name = name

    bob = Person("bob")
    print(bob.name)         # Trace: name\bbob

    sue = Person("sue")
    print(sue.name)         # Trace: name\bsue
    print(bob.name)         # Trace: name\bsue, 只保留最后一个实例.

### 装饰器嵌套
    
    @spam
    @eggs
    class C:
        pass

    X = C()

    # 等同于
    class C:
        pass

    C = spam(eggs(C))
    X = C()

示例: 

    def d1(F):
        print("d1")
        return lambda: "X" + F()

    def d2(F):
        print("d2")
        return lambda: "Y" + F()

    def d3(F):
        print("d3")
        return lambda: "Z" + F()

    @d1
    @d2
    @d3
    def func():
        return "Spam"

    print(func())   # XYZSpam

### 装饰器参数

装饰器参数在装饰发生之前就解析了, 并且他们通常用来**保持状态信息**供随后的调用使用.

装饰器参数往往意味着可调用对象的 3 个层级: 接受装饰器参数的一个可调用对象, 他返回一个可调用对象以作为装饰器, 该装饰器返回一个可调用对象来处理对最初的函数或类调用. 这三个层级的每一个都可能是一个函数或类, 并且可能一作用域或类属性的形式保存了状态.

    @decorator(A, B)
    def F(arg):
        ...
    F(99)

    # 等同于
    def F(arg):
        ...
    F = decorator(A, B)(F)
    F(99)

    # 装饰器函数
    def decorator(A, B):
        # Save or use A, B
        def actualDecorator(F:
            # Save or use function F
            # return a callable : nested def, class with __call__ , etc.
            return callable
        
        return actualDecorator

### 装饰器直接管理函数和类
装饰器通过装饰器代码来运行新的函数和类, 从而有效的工作, 他们也可以用来管理函数和类对象自身.


    registry = {}

    def register(obj):
        registry[obj.__name__] = obj
        return obj

    @register
    def spam(x):
        return(x**2)

    @register
    def ham(x):
        return(x**3)

    @register
    class Eggs:
        def __init__(self, x):
            self.data = x**4

        def __str__(self):
            return str(self.data)

    print("-" * 30)
    for name in registry:
        print(name, "=>", registry[name], type(registry[name]))

    print(spam(2))
    print(ham(2))
    x = Eggs(2)
    print(x)

    for name in registry:
        print(name, "=>", registry[name](2))

例如, 一个用户界面可能使用这样的技术, 为用户动作注册回调处理程序, 处理程序可能通过函数或类名来注册. 或者使用装饰器参数来指定主体事件; 包含装饰器的一条额外的 def 语句可能会用来保持这样的参数以便在装饰时使用.


如下装饰器把函数属性分配给记录信息, 以便随后供一个 API 使用, 但他没有插入一个包含器层来拦截随后的调用.

    def decorate(func):
        func.marked = True
        return func

    @decorate
    def spam(a, b):
        return a + b

    print(spam.marked)  # True


    def annotate(text):
        def decorate(func):
            func.label = text
            return func
        return decorate

    @annotate("spam data")
    def spam(a, b):
        return a+b
     
    print(spam.label, " | " , spam(1,2), " | " , spam.label)    # spam data  |  3  |  spam data

### 装饰器利弊:
潜在缺陷:

- 类型修改:
    
    当插入包装器的时候, 一个装饰器函数或类不会保持其最初的类型, 其名称重新绑定到一个包装器对象, 在使用对象名称或测试对象类型的程序中, 这可能很重要.

    在单体的例子中, 装饰器和管理函数的方法都为实例保持了最初的类类型; 在跟踪器的代码中, 没有一种方法这么做, 因为需要有包装器.

- 额外调用:
    
    通过装饰添加一个包装层, 在每次调用装饰对象的时候, 会引发一次额外调用所需的额外性能成本(调用相对消耗时间的操作), 因此装饰包装器可能会使程序变慢.

    在跟踪器代码中, 两种方法都需要每个属性通过一个包装器层来指向; 单体的示例通过保持最初的类类型而避免了额外调用.

类似的问题也适用于函数装饰器: 装饰和管理器函数都会导致额外调用, 并且当装饰的时候通常会发生类型变化(不装饰的时候就没有).


优点:
- 明确的语法
    
    装饰器使得扩展明确而显然, 即容易识别.

    此外, 装饰器允许函数和示例创建调用使用所有 Python 程序员所熟悉的常规语法.

- 代码可维护性
    
    装饰器避免了在每个函数或类调用中重复扩展代码.

- 一致性


### 装饰器案例

装饰器实现的私有属性, 使用**委托**, 即在一个对象中嵌入一个对象, 这种模式使得区分主题对象的内部访问和外部访问容易多了, 对主体对象的来自外部的属性访问, 由包装器层的重载方法拦截, 如果合法则委托给类; 类自身内部的访问则没有拦截且允许不经检查而运行.

如下的类装饰器接受任意多个参数, 以命名私有属性.

    """
    Privacy for attributest fetched from class instances.
    See self-test code at end of file for a usage example.
    Decorator same as : Doubles = Private("date", "size")(Doubler).
    Private returns onDecorator , onDecorator returns on Instance, and each onInstance instance embeds a Doubler instance.
    """

    traceMe = False

    def trace(*args):
        if traceMe:
            print("[" + "".join(map(str, args)) + "]")

    def private(*privates):
        def onDecorator(aClass):
            class onInstance:
                def __init__(self, *args, **kwargs):
                    self.wrapped = aClass(*args, **kwargs)

                def __getattr__(self, attr):
                    trace("get: ", attr)
                    if attr in privates:
                        raise TypeError("private attribute fetch: " + attr)
                    else:
                        return getattr(self.wrapped, attr)

                def __setattr__(self, attr, value):
                    trace("set: ", attr, ' | ', value)
                    if attr == "wrapped":
                        self.__dict__[attr] = value
                    elif attr in privates:
                        raise TypeError("private attribute change: " + attr)
                    else:
                        setattr(self.wrapped, attr, value)
            return onInstance
        return onDecorator

    if __name__ == "__main__":
        traceMe = True

        @private("data", "size")
        class Doubler:
            def __init__(self, label, start):
                self.label = label
                self.data = start

            def size(self):
                return len(self.data)

            def double(self):
                for i in range(self.size()):
                    self.data[i] = self.data[i] * 2

            def display(self):
                print("%s => %s" % (self.label, self.data))

        x = Doubler("X is", [1, 2, 3])
        y = Doubler("y is", [-10, -20, -30])
        
        print("-" * 40)
        print(x.label)
        x.display()
        x.double()
        x.display()
        
        print("-" * 40)
        print(y.label)
        y.display()
        y.double()
        y.display()
        y.label = "Spam"
        y.display()

泛化的私有属性及公开属性控制


    """
    Class decorator with Private and Public attribute declarations.
    Controls accesss to attributes stored on an instance, or inherited by it from its classes.
    Private declares all the names that can. Caveat: this works in 3.0 for normally named attributes only:
    __X__ operator overloading methods implicitly run for built-in operations do not trigger either __getattr__
    or __getattribute__ in new-style classes. And __X__ methods here to intercept and delegate built-ins.
    """

    traceME = False
    def trace(*args):
        if traceME:
            print("[" + " ".join(map(str, args)) + "]")

    def accessControl(failIf):
        def onDecorator(aClass):
            class onInstance:
                def __init__(self, *args, **kwargs):
                    self.__wrapped = aClass(*args, **kwargs)

                def __getattr__(self, attr):
                    trace("Get: ", attr)
                    if failIf(attr):
                        raise TypeError("private attribute fetch: " + attr)
                    else:
                        return getattr(self.__wrapped, attr)

                def __setattr__(self, attr, value):
                    trace("Set: ", attr)
                    if attr == "_onInstance__wrapped":
                        self.__dict__[attr] = value
                    elif failIf(attr):
                        raise TypeError("private attribute change: " + attr)
                    else:
                        setattr(self.__wrapped, attr, value)

            return onInstance 
        return onDecorator

    def private(*attribute):
        return accessControl(failIf=(lambda attr: attr in attribute))

    def public(*attribute):
        return accessControl(failIf=(lambda attr: attr not in attribute))


    @private('age')
    class Person:
        """
        private("age")(Person)
        accesssControl(failIf(lambda attr: attr in attribute))(Person)
        """
        def __init__(self, name, age):
            self.name = name
            self.age = age

    x = Person("bob", 12)
    print(x.name)
    x.name = "sue"
    print(x.name)
    # print(x.age)          # 出错

    @public("name")
    class PersonB:
        def __init__(self, name, age):
            self.name = name
            self.age = age

    y = PersonB("bob", 23)
    print(y.name)
    y.name = "Sue"
    print(y.name)
    # print(y.age)          # 出错
    # y.age = 34            # 出错


验证函数参数: 该函数装饰器自动测试传递给一个函数或方法的参数是否在有效的数值范围内.

    def rangetest(*argchecks):
        def onDecorator(func):
            if not __debug__:
                """ __debug__ 是内置变量, Python 将其设置为 True, 
                除非他将以 -0 优化命令行标识运行. 如 python -0 main.py .
                """
                return func
            else:
                def onCall(*args):
                    for (ix, low, high) in argchecks:
                        if args[ix] < low or args[ix] > high:
                            errmsg = "Argument %s not in %s..%s" % (args[ix], low, high)
                            raise TypeError(errmsg)
                    return func(*args)
                return onCall
        return onDecorator



    @rangetest((1, 0 , 120))
    def persinfo(name, age):
        print("%s is %s years old" % (name, age))

    @rangetest([0, 1, 12], [1, 1, 31], [2, 0, 2009])
    def birthday(M, D, Y):
        print("birthday = {0}/{1}/{2}".format(M, D, Y))


    class Person:
        def __init__(self, name, job, pay):
            self.job = job
            self.pay = pay

        @rangetest([1, 0.0, 1.0])
        def giveRaise(self, percent):
            self.pay = int(self.pay * (1+percent))


    persinfo("Bob Smith", 45)
    birthday(5, 31, 1963)

    sue = Person("Sue Jones", "dev", 100)
    sue.giveRaise(0.1)
    print(sue.pay)

针对关键字和默认泛化

    """
    function decorator that performs range-test validation for passed arguments.
    Arguments are specified by keyword to the decorator. In the actual call, arguments
    may be passed by position or keyword, and defaults may be omitted.
    """

    trace = True

    def rangetest(**argchecks):
        def onDecorator(func):
            if not __debug__:
                return func
            else:
                import sys
                code = func.__code__
                allargs = code.co_varnames[:code.co_argcount]
                funcname = func.__name__

                def onCall(*pargs, **kwargs):
                    # All pargs match first N expected args by position
                    # The rest must be in kargs or be omitted defaults
                    positionals = list(allargs)
                    positionals = positionals[:len(pargs)]

                    for (argname, (low, high)) in argchecks.items():
                        # For all args to be checked
                        if argname in kwargs:
                            # Was passed by name
                            if kwargs[argname] < low or kwargs[argname] > high:
                                errmsg = "{0} argument '{1}' not in {2} .. {3}".format(
                                        funcname, argname, low, high
                                    )
                        elif argname in positionals:
                            # Was passed by position
                            position = positionals.index(argname)
                            if pargs[position] < low or pargs[position] > high:
                                errmsg = "{0} argument '{1}' not in {2} .. {3}".format(
                                        funcname, argname, low, high
                                    )
                                raise TypeError(errmsg)
                        else:
                            # Assume not passed: default
                            if trace:
                                print("Argument '{0}' defaulted".format(argname))

                        return func(*pargs, **kwargs)       # OK: run original call

                return onCall
        return onDecorator


**装饰器的代码依赖于内省 API 和 对参数传递的细微限制**

    def func(a, b, c, d):
        x = 1
        y =2

    code = func.__code__
    print(code, type(code))     # <code object func at 0x03237700, file "D:\VBoxShare\Work\Documents\PyProject\PyCookbook\test2.py", line 3> <class 'code'>
    print(code.co_nlocals)      # 6
    print(code.co_argcount)     # 4
    print(code.co_varnames)     # ('a', 'b', 'c', 'd', 'x', 'y')
    print(code.co_varnames[:code.co_argcount])  # ('a', 'b', 'c', 'd')

    import sys
    print(sys.version_info)     # sys.version_info(major=3, minor=6, micro=2, releaselevel='final', serial=0)

    code = func.__code__ if sys.version_info[0] == 3 else func.func_code

# 元类 : 
元类只是扩展了装饰器的代码插入模式. 元类允许我们拦截并扩展类创建, 他提供了一个 API 以插入在一条 class 语句结束时运行的额外逻辑, 尽管是以与装饰器不同的方式. 同样, 他提供了一种通用的协议来管理程序中的类对象.

元类允许我们获得更高层级的控制, 来控制一组类如何工作. 通过声明一个元类, 告诉解释器, 把类对象的创建路由到指定的类.

另一方面, 元类为各种没有它而难以实现或不可能实现的编码模式打开了大门.


允许我们以广泛的方式控制 Python 的行为, 并与 Python 的内部与工具构建有更多关系的编程方法/工具, 这些工具为我们提供了在各种环境中插入逻辑的方法--在运算符计算时, 属性访问时, 函数调用时, 类实例创建时, 类对象创建时: 

- 内省属性
    
    像 `__class__` 和 `__dict__` 这样的特殊属性允许我们查看 Python 对象的内部实现方式, 以便更广泛的处理他们.

- 运算符重载
    
    像 `__str__` 和 `__add__` 这样的特殊命名方法, 在类中编写来拦截并提供应用于类实例的内置操作行为. 他们自动运行作为内置操作的响应, 并且允许类符合期望的接口.

- 属性拦截方法
    
    一类特殊的运算符重载方法提供了一种方法在实例上广泛的拦截属性访问: __getattr__, __setattr__, __getattribute__ 允许包装的类插入自动运行的代码, 这些代码可以验证属性请求并且将他们委托给嵌入的对象. 他们允许一个对象的任意数目的属性--要么是选取的属性, 要么是所有的属性--在访问的时候计算.

- 类特性
    
    内置函数 property 允许吧代码和特殊的类属性关联起来, 当获取/赋值/删除该属性的时候自动运行代码. 

    特性考虑到了访问特定属性时候的自动代码调用.

- 类属性描述符
    
    特性只是定义根据访问自动运行函数的属性描述的一种简介的方式.

    描述符允许我们在单独的类中编写 __get__, __set__, __delete__ 处理程序的方法, 当分配给该类的一个实例的属性被访问的时候自动运行他们.

    他们提供了一种通用的方式, 来插入当访问一个特定的属性时自动运行的代码, 并且在一个属性的常规查找之后触发他们.

- 函数和类装饰器
    
    装饰器允许我们添加当调用一个函数或创建一个类实例的时候自动运行的逻辑.

    装饰器语法插入名称重新绑定逻辑, 在函数或类定义语句的末尾自动运行该逻辑--装饰的函数和类名重新绑定到拦截了随后调用的可调用对象.

- 元类
    
    元类允许在一条 class 语句的末尾, 插入当创建一个类对象的时候自动运行的逻辑. 这个逻辑**不会**吧类名重新绑定到一个装饰器可调用对象, 而是把类自身的创建指向特定的逻辑.



### 元类模型
1. 类是类型的实例

    - python 3 : 用户定义的类对象是名为 type 的对象的实例, type 本身是一个类.
        
        在 Python 3 中, 类型的概念与类的概念合并了, 实际上, 这两者基本上时同义词: 类是类型, 类型也是类:
        - 类型有派生自 type 的类定义 
        - 用户定义的类是类型类的实例
        - 用户定义的类是产生他们自己的实例的类型.

    - python 2.6 : 新式类继承自 object, 他是 type 的一个子集; 传统类是 type 的一个实例, 并且并不创建自一个类.


2. 元类是 `type` 的子类
    
    在 Python3 及 Python2.6 的新式类中:
    - type 是产生用户定义的类的一个类
    - 元类是 type 类的一个子类
    - 类对象是 type 类的一个实例, 或一个子类
    - 实例对象产生自一个类.

    为了控制创建类以及扩展其行为的方式, 所需要做的只是指定一个用户定义和的类川谷关键字一个用户定义的元类, 而不是常规的 type 类.

3. `Class` 语句协议
    
    class 语句的工作原理: 当 Python 遇到一条 class 语句, 他会运行其嵌套的代码块以创建其属性, 所有在嵌套的代码块的顶层分配的名称都产生结果的类对象中的属性. 这些名称通常是嵌套的 def 所创建的方法函数. 但是, 他们也可以是分配来创建有所有实例共享的类数据的任意属性. 从技术上讲, Python 遵从一个标准的协议来使这发生:

    1. 在一条 class 语句的末尾, 并且在运行了一个命名空间词典中的所有嵌套代码之后, 他调用 type 对象发来创建 class 对象.

            class = type(class_name, super_classes, attribute_dict)

    2. type 对象反过来定义了一个 __call__ 运算符重载方法, 当调用 type 对象的时候, 该方法运行两个其他的方法:

            type.__new__(type_class, class_name, super_classes, attribute_dict)
            type.__init__(class, class_name, super_classes, attribute_dict)

        __new__ 方法创建并返回了新的 class 对象, 并且随后 __init__ 方法初始化了新创建的对象. 这是 type 元类子类通常用来定制类的钩子.

    示例: 如下所示类定义:

        class Spam(eggs):
            data = 1
            def meth(self, arg):
                pass

    - python 将从内部运行嵌套的代码块来创建该类的两个属性(data 和 meth)
    - 在 class 语句的末尾调用 type 对象, 产生 class 对象:

            Spam=type("Spam", (Eggs,), {"data": 1, "meth": meth, '__module__': "__main__"})

        由于这个类在 class 语句的末尾运行, 他是用来扩展和处理的一个类的理想的钩子. 技巧在于, 用将要拦截这个调用的一个订制子类来替代类型.

### 声明与编写元类
#### 1. 声明元类

- Python 3.0 中: 在类标题中吧想要的元类作为一个关键字参数列出来.

        class Spam(Eggs, metaclass=Meta):     # 3.0 and later
            pass

    继承的超类要在元类之前.

- Python 2.6 中: 使用一个类属性而不是一个关键字参数. -- 需要继承自 object.

        class Spam(object):
            __metaclass__ = Meta

当以这些方式声明的时候, 创建类对象的调用在 class 语句的底部运行, 修改为调用元类而不是默认的 type.

    class = Meta(class_name, super_classes, attribute_dict)

由于元类是 type 的一个子类, 所有 type 类的 __call__ 把创建和初始化新的类对象的调用委托给元类, 如果他定义了这些方法的订制版本:

    Meta.__new__(Meta, class_name, super_classes, attribute_dict)
    Meta.__init__(class, class_name, super_classes, attribute_dict)

示例: 

    class Spam(Eggs, metaclass=Meta):
        data = 1
        def meth(self, arg):
            pass

    # 在这条语句的末尾, Python 内部运行如下的代码来创建 class 对象.

    Spam = Meta("Spam", (Eggs,), {"data": 1, "meth": meth, "__module": "__main__"})

    # 如果元类定义了 __new__ 或 __init__ 的自己版本, 在此处的调用期间, 他们将依次由继承的 type 类的 __call__ 方法调用, 以创建并初始化新类.

#### 2. 编写元类.
    
1. 基本元类
    
    如下的实例中, 是一个最简单的元类, 他是只带有一个 __new__ 方法的 type 的子类, 该方法通过运行 type 的默认版本创建类对象. 他通常执行所需的任何订制并且调用 type 的 超类的 __new__ 方法来创建并运行新的类对象: 

        class MetaOne(type):
            def __new__(meta, classname, supers, classdict):
                print("In MetaOne.new", classname, supers, classdict, sep="\n...")
                return type.__new__(meta, classname, supers, classdict)

        class Eggs:
            pass

        print("making class")

        class Spam(Eggs, metaclass=MetaOne):
            data = 1
            def meth(self, arg):
                pass

        print("Making instance")
        X = Spam()
        print("data", X.data)

        # 输出
        # making class
        # In MetaOne.new
        # ...Spam
        # ...(<class '__main__.Eggs'>,)
        # ...{'__module__': '__main__', '__qualname__': 'Spam', 'data': 1, 'meth': <function Spam.meth at 0x03B18738>}
        # Making instance
        # data 1

2. 订制构建和初始化
    
    元类也可以介入 __init__ 协议, 有 type 对象的 __call__ 调用: 通常, __new__ 创建并返回了类对象, __init__ 初始化了以及创建的类. 类初始化方法在类构建方法之后运行, 但是, 两者都在 class 语句最后运行, 并且在创建任何实例之前运行. 元类也可以用作在创建时管理类的钩子:

        class MetaOne(type):
            def __new__(meta, classname, supers, classdict):
                print("In MetaOne.new", classname, supers, classdict, sep="\n...")
                return type.__new__(meta, classname, supers, classdict)

            def __init__(Class, classname, supers, classdict):
                print("In MetaOne init:", classname, supers, classdict, sep="\n...")
                print("... init class object:", list(Class.__dict__.keys()))

        class Eggs:
            pass

        print("making class")

        class Spam(Eggs, metaclass=MetaOne):
            data = 1
            def meth(self, arg):
                pass

        print("Making instance")
        X = Spam()
        print("data", X.data)

        # 输出
        # making class
        # In MetaOne.new
        # ...Spam
        # ...(<class '__main__.Eggs'>,)
        # ...{'__module__': '__main__', '__qualname__': 'Spam', 'data': 1, 'meth': <function Spam.meth at 0x02C58738>}
        # In MetaOne init:
        # ...Spam
        # ...(<class '__main__.Eggs'>,)
        # ...{'__module__': '__main__', '__qualname__': 'Spam', 'data': 1, 'meth': <function Spam.meth at 0x02C58738>}
        # ... init class object: ['__module__', 'data', 'meth', '__doc__']
        # Making instance
        # data 1

3. 其他元类编写技巧
    
    - 使用简单的工厂函数

        例如, 元类根本不是真的需要类. 正如我们所学的, class 语句发布了一条简单的调用, 在其处理的最后创建了一个类. 因此, 实际上任何可调用对象都可以用作一个元类, 只要他接受传递的参数并且返回与目标类兼容的一个对象. 实际上, 一个简单的对象工厂函数, 就像一个类一样工作:

            def MetaFunc(classname, supers, classdict):
                print("In MetaFunc", classname, supers, classdict, sep="\n...")
                return type(classname, supers, classdict)


            class Eggs:
                pass

            print("making class")

            class Spam(Eggs, metaclass=MetaFunc):
                data = 1
                def meth(self, arg):
                    pass

            print("Making instance")
            X = Spam()
            print("data", X.data)

            # 输出
            # making class
            # In MetaFunc
            # ...Spam
            # ...(<class '__main__.Eggs'>,)
            # ...{'__module__': '__main__', '__qualname__': 'Spam', 'data': 1, 'meth': <function Spam.meth at 0x038486F0>}
            # Making instance
            # data 1

        运行时, 在 class 语句的末尾调用 MetaFunc 函数, 并且他返回期待的新的类对象. 函数直接捕获 type 对象的 __call__ 通常会默认拦截的调用.

    - 用元类重载类创建调用

        由于他设计常规的 OOP 机制, 所以, 对于元类来说, 也可能直接在一条 class 语句的末尾捕获创建调用, 通过订制的 __call__ , 如下也创建了一个元类的实例 : 

            class SuperMeta(type):
                def __call__(meta, classname, supers, classdict):
                    print("In SuperMeta.call", classname, supers, classdict, sep="\n...")
                    return type.__call__(meta, classname, supers, classdict)

            class SubMeta(type, metaclass=SuperMeta):
                def __new__(meta, classname, supers, classdict):
                    print("In SubMeta.new: ", classname, supers, classdict, sep="\n...")
                    return type.__new__(meta, classname, supers, classdict)

                def __init__(Class, classname, supers, classdict):
                    print("In SubMeta init:", classname, supers, classdict, sep="\n...")
                    print("... init class object:", list(Class.__dict__.keys()))

            class Eggs:
                pass

            print("making class")

            class Spam(Eggs, metaclass=SubMeta):
                data = 1
                def meth(self, arg):
                    pass

            print("Making instance")
            X = Spam()
            print("data", X.data)

            # 输出
            # making class
            # In SuperMeta.call
            # ...Spam
            # ...(<class '__main__.Eggs'>,)
            # ...{'__module__': '__main__', '__qualname__': 'Spam', 'data': 1, 'meth': <function Spam.meth at 0x02F18780>}
            # In SubMeta.new: 
            # ...Spam
            # ...(<class '__main__.Eggs'>,)
            # ...{'__module__': '__main__', '__qualname__': 'Spam', 'data': 1, 'meth': <function Spam.meth at 0x02F18780>}
            # In SubMeta init:
            # ...Spam
            # ...(<class '__main__.Eggs'>,)
            # ...{'__module__': '__main__', '__qualname__': 'Spam', 'data': 1, 'meth': <function Spam.meth at 0x02F18780>}
            # ... init class object: ['__module__', 'data', 'meth', '__doc__']
            # Making instance
            # data 1

        元类名查找规则与我们所习惯的方式有所不同, 如, __call__ 方法在一个对象的类中查找; 对于元类, 这意味着一个元类的元素.

    - 用常规类重载类创建调用

        要使用常规的基于继承的名称查找, 可以用常规类和实例实现相同的效果. 注意下面的示例中, __new__ 和 __init__ 必须有不同的名称, 否则, 当创建 SubMeta 实例的时候, 他们会自动运行, 而不是随后作为一个元类调用:

            class SuperMeta:
                def __call__(self, classname, supers, classdict):
                    print("In SuperMeta.call", classname, supers, classdict, sep="\n...")
                    Class = self.__New__(classname, supers, classdict)
                    self.__Init__(Class, classname, supers, classdict)
                    return Class

            class SubMeta(SuperMeta):
                def __New__(self, classname, supers, classdict):
                    print("In SubMeta.new: ", classname, supers, classdict, sep="\n...")
                    return type(classname, supers, classdict)

                def __Init__(self, Class, classname, supers, classdict):
                    print("In SubMeta init:", classname, supers, classdict, sep="\n...")
                    print("... init class object:", list(Class.__dict__.keys()))

            class Eggs:
                pass

            print("making class")

            class Spam(Eggs, metaclass=SubMeta()):
                data = 1
                def meth(self, arg):
                    pass

                def __init__(self):
                    self.page = 12

            print("Making instance")
            X = Spam()
            print("data", X.data)
            print("page", X.page)

            # 输出
            # making class
            # In SuperMeta.call
            # ...Spam
            # ...(<class '__main__.Eggs'>,)
            # ...{'__module__': '__main__', '__qualname__': 'Spam', 'data': 1, 'meth': <function Spam.meth at 0x035987C8>, '__init__': <function Spam.__init__ at 0x03598780>}
            # In SubMeta.new: 
            # ...Spam
            # ...(<class '__main__.Eggs'>,)
            # ...{'__module__': '__main__', '__qualname__': 'Spam', 'data': 1, 'meth': <function Spam.meth at 0x035987C8>, '__init__': <function Spam.__init__ at 0x03598780>}
            # In SubMeta init:
            # ...Spam
            # ...(<class '__main__.Eggs'>,)
            # ...{'__module__': '__main__', '__qualname__': 'Spam', 'data': 1, 'meth': <function Spam.meth at 0x035987C8>, '__init__': <function Spam.__init__ at 0x03598780>}
            # ... init class object: ['__module__', 'data', 'meth', '__init__', '__doc__']
            # Making instance
            # data 1
            # page 12

4. 实例与继承的关系.
    
    由于元类以类似于继承超类的方式来定会, 因此, 他们看上去有点容易令人混淆, 一些关键点有助于概括和澄清这一模型:

    - 元类继承自 type 类.

        尽管他们有一种特殊的角色元类, 但元类是用 class 语句编写的, 并且遵从 Python 中有用的 OOP 模型. 例如, 就像 type 的子类一样, 他们可以重新定义 type 对象的方法, 需要的时候重载或定制他们. 元类通常重新定义 type 类的 __new__ 和 __init__ , 以定制类常见和初始化, 但是, 如果他们希望直接捕获类末尾的创建调用的话, 他们也可以重新定义 __call__. 尽管元类不常见, 他们甚至是返回任意对象而不是 type 子类的简单函数.

    - 元类声明由 子类 继承.

        在用户定义的类中, metaclass=M 声明由该类的子类继承, 因此, 对于在超类链中继承了这一声明的每个类的构建, 该元类都将运行.

    - 元类属性没有由类实例继承.

        元类声明指定了一个实例关系, 他和继承不同. 由于类是元类的实例, 所以, 元类中定义的行为应用于类, 而不是类随后的实例. 实例从他们的类和超类中获取行为, 但是, 不是从任何元类获取行为. 

        从技术上讲, 实例属性查找通常只是搜索实例及其所有类的 __dict__ 字典; 元类不包含在实例查找中.

    为声明最后两点, 示例如下:

        class MetaOne(type):
            def __new__(meta, classname, supers, classdict):
                print("In MetaOne.new : ", classname)
                return type.__new__(meta, classname, supers, classdict)

            def toast(self):
                print("toast")


        class Super(metaclass=MetaOne):
            def spam(self):
                print("Spam")

        class C(Super):
            def eggs(self):
                print("eggs")

        X = C()
        X.eggs()
        X.spam()
        X.toast()

        # 输出
        # In MetaOne.new :  Super
        # In MetaOne.new :  C
        # eggs
        # Spam

### 3. 元类示例
1. 向一个类添加方法
    
    比较了类扩展和实例包装的基于元类和基于装饰器的实现.

    手动扩展类方法:

        class Client1:
            def __init__(self, value):
                self.value = value

            def spam(self):
                return self.value * 2

        class Client2:
            value = "ni?"


        def eggsfunc(obj):
            return obj.value * 4

        def hamfunc(obj, value):
            return value + "ham"

        Client1.eggs = eggsfunc
        Client1.ham = hamfunc

        Client2.eggs = eggsfunc
        Client2.ham = hamfunc

        X = Client1("Ni")
        print(X.spam())
        print(X.eggs())
        print(X.ham("bacon"))

        Y = Client2()
        print(Y.eggs())
        print(Y.ham("bacon"))

    通过元类添加类方法

        def eggsfunc(obj):
            return obj.value * 4

        def hamfunc(obj, value):
            return value + "ham"

        class Extender(type):
            def __new__(meta, classname, supers, classdict):
                classdict["eggs"] = eggsfunc
                classdict["ham"] = hamfunc
                return type.__new__(meta, classname, supers, classdict)


        class Client1(metaclass=Extender):
            def __init__(self, value):
                self.value = value

            def spam(self):
                return self.value * 2

        class Client2(metaclass=Extender):
            value = "ni?"

        X = Client1("Ni")
        print(X.spam())
        print(X.eggs())
        print(X.ham("bacon"))

        Y = Client2()
        print(Y.eggs())
        print(Y.ham("bacon"))


    实际上, 元类结构支持更多的动态行为.例如, 主体类可以基于运行时的任意逻辑配置.

        class Extender(type):
            def __new__(meta, classname, supers, classdict):
                if sometest():
                    classdict["eggs"] = eggsfunc
                else:
                    classdict["eggs"] = eggsfunc2

                if someothertest():
                    classdict["ham"] = hamfunc
                else:
                    classdict["ham"] = lambda *args: "Not supported"

                return type.__new__(meta, classname, supers, classdict)

    基于装饰器的扩展

        def eggsfunc(obj):
            return obj.value * 4

        def hamfunc(obj, value):
            return value + "ham"

        def Extender(aClass):
            aClass.eggs = eggsfunc
            aClass.ham = hamfunc
            return aClass

        @Extender
        class Client1:
            def __init__(self, value):
                self.value = value

            def spam(self):
                return self.value * 2

        @Extender
        class Client2:
            value = "ni?"

    使用元类来管理实例: 如下示例依赖于两个技巧, 首先, 他必须使用一个简单的函数而不是类, 因为 type 子类必须附加给对象创建协议; 其次, 必须通过手动调用 type 来手动创建主题类, 他需要返回一个实例包装器, 但是元类也负责创建和返回主体类.

        def Tracer(classname, supers, classdict):
            aClass = type(classname, supers, classdict)

            class Wrapper:
                def __init__(self, *args, **kwargs):
                    self.wrapped = aClass(*args, **kwargs)

                def __getattr__(self, attrname):
                    print("Tracer", attrname)
                    return getattr(self.wrapped, attrname)

            return Wrapper

        class Person(metaclass=Tracer):
            def __init__(self, name, hours, rate):
                self.name = name
                self.hours = hours
                self.rate = rate

            def pay(self):
                return self.hours * self.rate

        bob = Person("bob", 40, 50)
        print(bob.name)
        print(bob.pay())

2. 自动装饰所有方法
    
    使用元类追踪:

        def tracer(func):
            calls = 0

            def onCall(*args, **kwargs):
                nonlocal calls
                calls += 1
                print("Call %s to %s" % (calls, func.__name__))
                return func(*args, *kwargs)

            return onCall

        from types import FunctionType

        class MetaTrace(type):
            def __new__(meta, classname, supers, classdict):
                for attr, attrval in classdict.items():
                    if type(attrval) is FunctionType:
                        # 在类创建的时候, 元类自动把函数装饰器应用于每个方法.
                        # 并且, 函数装饰器自动拦截方法调用.
                        classdict[attr] = tracer(attrval) 
                return type.__new__(meta, classname, supers, classdict)

        class Person(metaclass=MetaTrace):
            def __init__(self, name, pay):
                self.name = name
                self.pay = pay

            def giveRaise(self, percent):
                self.pay *= (1.0 + percent)

            def lastName(self):
                return self.name.split()[-1]


        bob = Person("Bob Smith", 500)
        sue = Person("Sue Jones", 100)
        print(bob.name, sue.name)
        sue.giveRaise(0.2)
        print(sue.pay)
        print(bob.lastName(), sue.lastName())

        # 输出
        # Call 1 to __init__
        # Call 2 to __init__
        # Bob Smith Sue Jones
        # Call 1 to giveRaise
        # 120.0
        # Call 1 to lastName
        # Call 2 to lastName
        # Smith Jones

    把任何装饰器应用于方法: 上一个示例的泛化.

        def tracer(func):
            calls = 0

            def onCall(*args, **kwargs):
                nonlocal calls
                calls += 1
                print("Call %s to %s" % (calls, func.__name__))
                return func(*args, *kwargs)

            return onCall

        from types import FunctionType

        def decorateAll(decorator):
            class MetaDecorate(type):
                def __new__(meta, classname, supers, classdict):
                    for attr, attrval in classdict.items():
                        if type(attrval) is FunctionType:
                            classdict[attr] = tracer(attrval)
                    return type.__new__(meta, classname, supers, classdict)

            return MetaDecorate


        class Person(metaclass=decorateAll(tracer)):
            def __init__(self, name, pay):
                self.name = name
                self.pay = pay

            def giveRaise(self, percent):
                self.pay *= (1.0 + percent)

            def lastName(self):
                return self.name.split()[-1]


        bob = Person("Bob Smith", 500)
        sue = Person("Sue Jones", 100)
        print(bob.name, sue.name)
        sue.giveRaise(0.2)
        print(sue.pay)
        print(bob.lastName(), sue.lastName())

        # 输出
        # Call 1 to __init__
        # Call 2 to __init__
        # Bob Smith Sue Jones
        # Call 1 to giveRaise
        # 120.0
        # Call 1 to lastName
        # Call 2 to lastName
        # Smith Jones

    把任何装饰器应用于方法: 使用类装饰器实现.

        def tracer(func):
            calls = 0

            def onCall(*args, **kwargs):
                nonlocal calls
                calls += 1
                print("Call %s to %s" % (calls, func.__name__))
                return func(*args, *kwargs)

            return onCall

        from types import FunctionType

        def decorateAll(decorator):
            def DecoDecorate(aClass):
                for attr, attrval in aClass.__dict__.items():
                    if type(attrval) is FunctionType:
                        setattr(aClass, attr, decorator(attrval))
                return aClass
            return DecoDecorate

        @decorateAll(tracer)
        class Person:
            def __init__(self, name, pay):
                self.name = name
                self.pay = pay

            def giveRaise(self, percent):
                self.pay *= (1.0 + percent)

            def lastName(self):
                return self.name.split()[-1]


        bob = Person("Bob Smith", 500)
        sue = Person("Sue Jones", 100)
        print(bob.name, sue.name)
        sue.giveRaise(0.2)
        print(sue.pay)
        print(bob.lastName(), sue.lastName())
        
---------------------------------------------------

装饰器分类
1. 函数装饰器
2. 类装饰器

1. 函数实现的装饰器
2. 类实现的装饰器 __call__

1. 返回 包装器的装饰器
2. 返回 函数/类 本身的装饰器

---------------------------------------------------

### contextlib
contextlib 提供了一个装饰器和一些实用工具函数, 用于创建与 with 语句结合使用的上下文管理器.

- `contextmanager(func)`: 一个装饰器, 根据生成器函数func 创建一个上下文管理器.
        
        @contextmanager
        def foo(args):
            statements
            try:
                yield value
            except Exception as e:
                error handling (if any)

            statements

    当语句 `with foo(args) as value` 出现时, 使用所提供的参数执行生成器函数, 知道到达第一条 yield 语句. yield 的返回值放在变量 value 中. 此时执行 with 语句体. 完成之后, 生成器函数将继续执行. 如果 with 语句体内, 出现任何异常, 生成器函数内会抛出该异常并可以被适当处理.

- `nested(mrg1, mrg2m, ..., mrgN)` : 此函数在一个操作中调用多个上下文管理器(mrg1, mrg2 ...) 返回一个数组, 其中包含 with 语句的不同返回值.
    
    语句

        with nested(m1, m2) as (x, y): 
            statements
    与语句 

        with m1 as x: 
            with m2 as y: 
                statements

    含义相同.

    **注意**: 如果内部上下文管理器捕获并禁止了异常, 将不会被外部管理器传送任何异常信息.

- `closing(object)` : 创建上下文管理器, 在执行过程中离开 `with` 语句体时, 自动执行 `object.close()`. `with`语句体返回的值与 `object` 相同.


---------------------------------------------------
## 几个重要的库

collection, operator, contextlib, functools,

## 数据类型, 数据结构
list, tuple, dict, set
collection.namedtuple, collection.deque, collection.OrderedDict, collection.Defaultdict

Queue.Queue

```
比较 : 

persons = {}

class Person(object):
    def __init__(self, name):
        self.name = name

    def __hash__(self):
        return hash(self.name)

persons[Person("kehan")] = 1
print(Person("kehan") in persons) #False

----------------------------------------
persons = {}

class Person(object):
    def __init__(self, name):
        self.name = name

    def __hash__(self):
        return hash(self.name)

    def __eq__(self, r):
        return True if r.name == self.name else False


persons[Person("kehan")] = 1
print(Person("kehan") in persons) #True
```

## 推导式 与 函数式
```
t_columns = filter(lambda x: x.endswith("_time"),
        model.FIELDS)

t_columns = [f for f in model.FIELDS
            if f.endswith("_time")]

# 小于0置为0
ages = [-1, 10, 20]

sum([age if age >=0 else 0 for age in ages ])

sum(age if age >=0 else 0 for age in ages)  # 生成器

sum(map(lambda age: age if age >=0 else 0, ages))
```
## 算法, 算法复杂度, 基本算法实现(排序)
### 排序
```Python
peoples = [
    {"age": 1, "name": "kehan"},
    {"age": 24, "name": "lwy"},
    {"age": 25, "name": "skycrab"},
]
# age从小到大,
sorted(peoples, key=lambda p:p["age"])
# 从大到小
sorted(peoples, key=operator.itemgetter("age"),
    reverse=True)

operator.attrgetter     # 属性
operator.itemgetter     #元素
operator.methodcaller   #方法

#最大age
max(peoples, key=operator.itemgetter("age"))
{'age': 25, 'name': 'skycrab'}

min(peoples, key=operator.itemgetter("age"))
{'age': 25, 'name': 'skycrab'}

# operator模块是一个宝藏
a = [1, 2, 3]
reduce(operator.imul, a)  # 6

reduce(lambda x, y: x+y, a)  # 6
```
### 二分查找
前提: 已排序数列
```
a=[1, 5, 10, 15,20]

# bisect.bisect_right(a, x) 返回a中插入x的序号
bisect.bisect_right(a, 11)
Out[11]: 3

bisect.insort_right(a,11)

In [13]: a
Out[13]: [1, 5, 10, 11, 15, 20]
```

### 堆排序 : 解决 TOP N 问题
```
# heapq是最小堆
a=[1]
heapq.heappush(a, 10) # a=[1, 10]
heapq.heappop(a)      #弹出1
heapq.nlargest(2, peoples,
    key=operator.itemgetter("age"))
[{'age': 25, 'name': 'skycrab'}, {'age': 24, 'name': 'lwy'}]
```
## 反射(自省)

- `getattr, setattr, hasattr, dir`
- `__dict__, __slots__` :   有 `__slots__`, 无 `__dict__`
- `callable, isinstance` : 
    ```
        class FunCall(object):
            def __call__(self, *args, **kwargs):
                print(*args, **kwargs)
    ```
- `traceback` : 
    ```
        try:
            1/0
        except Exception:
            print('-' * 30)
            print(traceback.format_exc())
             
        ------------------------------
        Traceback (most recent call last):
          File "<ipython-input-40-507b353d716b>", line 2, in <module>
            1/0
        ZeroDivisionError: integer division or modulo by zero
    ```
- `inspect` : 

好处是什么: `orm`


## 属性拦截
```
class Merge(object):
    ""获取django多个结果""
    def __init__(self, query_set):
        self.query_set = query_set
    def __getattr__(self, name):
        return sum(getattr(q, name)
            for q in self.query_set)

class ObjectDict(dict):
    """字典当做对象使用"""
    def __getattr__(self, name):
        try:
            return self[name]
        except KeyError:
            raise AttributeError(name)
    def __setattr__(self, name, value):
        self[name] = value

class PermWrapper(object):
    def __init__(self, user):
        self.user = user
        self.superuser = user.is_superuser
        self.perms = set(["101", "102"])

    def __getitem__(self, module_name):
        if hasattr(self, module_name):
            return getattr(self, module_name)

        return module_name in self.perms

perm = PermWrapper()
perm["superuser"]
perm["101"]
```
## 装饰器

- 闭包
- 好处: 解耦
- 面向切面编程(aop)
- 用处 : 日志记录, 权限控制, 事务处理等
- 分类: 不带参数, 带参数, 类装饰器

```
def decor(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        # before hook
        return func(*args, **kwargs)
        # after hook


def super_required(view_func):
    """超级用户控制"""
    @wraps(view_func)
    def decorator(request, *args, **kwargs):
        if request.user.is_authenticated() and request.user.is_superuser:
            return view_func(request, *args, **kwargs)
        else:
            return HttpReesponseRedirect("/login/?next={0}".format(request.path))
    return decorator

## 使用 torndb 记录执行 SQL 语句和执行时间 : 属性拦截和装饰器结合
def log(level):
    """记录日志"""
    assert level in ("debug", "info", "warn", "error")
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            start = time.time()
            result = func(*args, **kwargs)
            write = getattr(logger, level)
            write("sql: %s\nrun time: %s seconds", args, time.time() - start)
            return result
        return wrapper
    return decorator

class Connection(object):
    def __init__(self):
        self.conn = torndb.Connection(HOST, DB, USER, PASSWORED)
    def __getattr__(self, name):
        func = getattr(self.conn, name)
        return log("info")(func)

conn = Connection()
conn.get("select * from users whrer id=3")
conn.execute("delete *from users")

> sql: select * from users whrer id=3
> run time: 0.5111111 seconds

```
## 描述符和属性

### 作用: 覆盖默认属性查找方式

a.x --> a.__dict__['x'] --> type(a).__dict__["x"] --> baseclass(type(a)).__dict__["x"]

### __get__, __set__, __delete__
数据描述符: __get__, __set__ (描述符优先)
```    
    class descriptor(object):
        def __init__(self, value):
            self.value = value
        def __get__(self, obj, type=None):
            return self.value
        def __set__(self, obj, value):
            pass

    class Test(object):
        def __init__(self):
            self.age = 100
        age = descriptor(200)

    t = Test()
    print t.age     # 200
```
非数据描述符: __get__(__dict__ 优先)
```  
    class descriptor(object):
        def __init__(self, value):
            self.value = value

        def __get__(self, obj, type=None):
            print obj, type
            return self.value

    class Test(object):
        def __init__(self):
            self.age = 100

        age = descriptor(200)

    t = Test()
    print(t.age)    # 100
```

### 只支持 new style objects
描述符有 `__getattribute__` 调用, 只有在新式类中才有.

properties, methods, statis methods, class methods, super

### classmethod 实现原理
```
    class ClassMethod(object):
        """ Emulate PyClassMethod_Type() in Objects/funcobject.c """

        def __init__(self, f):
            self.f = f

        def __get__(self, obj, klass=None):
            if klass is NOne:
                klass = type(obj)
            
            def newfunc(*args):
                return self.f(klass, *args)

            return newfunc

    class class_property(object):
        """ Aproperty can decorator class or instance class.
        class Foo(object):
            @class_property
            def foo(cls):
                return 2

        print Foo.foo   # 42
        print Foo().foo # 42
        """
        def __init__(self, func, name=Noen, doc=None):
            self.__name__ = name or func.__name__
            self.__module__ = func.__module__
            self.__doc__ = doc or func.__doc__
            self.func = func

        def __get__(self, obj, type=None):
            value = self.func(type)
            return value


    class cached_property(object):
        """ A property that is only computed once per instance and
        then replaces itself with an ordinary attribute.
        Deleting the attribute resets the property.
        class Foo(object):
            @cached_property
            def foo(self):
                return 42*10
        print(Foo().foo)        # 420
        """
        def __init__(self, func):
            self.__doc__ = getattr(func, '__doc__')
            self.func = func

        def __get__(self, obj, cls):
            if obj is None: return slef
            value = obj.__dict__[self.func.__name__] = self.func(obj)
            return value

    class class_cached_property(object):
        def __init__(self, func):
            self.__doc__ = getattr(func, "__doc__")
            self.func = func

        def __get__(self, obj, cls):
            if cls is None:
                return self

            value = self.func(cls)
            setattr(cls, slef.func.__name__, vlaue)
            return value
```

## 生成器
```
def task():
    begin = yield
    print("begin", begin)
    yield
    for x in range(begin):
        yield x

t = task()
t.send(None)
t.send(2)               # ("begin", 2)
print([x for x in t])   # [1, 2]
```

模拟线程并发
```
def thread1():
    for x in range(4):
        yield  x

def thread2():
    for x in range(4,8):
        yield  x

threads=[]
threads.append(thread1())
threads.append(thread2())

def run(threads): #写这个函数，模拟线程并发
    for t in threads:
        try:
            print t.next()
        except StopIteration:
            pass
        else:
            threads.append(t)

run(threads)

结果：
0
4
1
5
2
6
3
7

```

```
class Task(object):
    def __init__(self):
        self._queue = collections.deque()
        self.work = 0
    def add(self, gen):
        self._queue.append(gen)
        self.work += 1
    def finish(self):
        return self.work <= 0
    def run(self):
        while not self.finish():
            try:
                gen = self._queue.popleft()
                gen.send(None)
            except StopIteration:
                self.work -= 1
            else:
                self._queue.append(gen)
t=Task()
t.add(thread1())  t.add(thread2())
t.run()
```

### 上下文管理器

```
import os

class cd(object):
    def __init__(self, path):
        self.src = os.getcwd()
        self.dest = path

    def __enter__(self):
        os.chdir(self.dest)

    def __exit__(self, exc_type, exc_val, exc_tb):
        os.chdir(self.src)


from contextlib import contextmanager

@contextmanager
def cd(path):
    cwd = os.getcwd()
    try:
        os.chdir(path)
        yield
    finally:
        os.chdir(cwd)
```

## 元类
### type
```
In [98]: class A(object):
    ...:     pass
    ...: 

In [99]: type(A)
Out[99]: type

In [100]: B = type("B", (object, ), {"name": "BNBB"})

In [101]: B
Out[101]: __main__.B

In [102]: A
Out[102]: __main__.A

In [103]: type(B)
Out[103]: type

In [104]: B.name
Out[104]: 'BNBB'
```

### __new__ && __init__
`__new__(cls, classname, bases, dict_attr)` : __new__ 的 cls 参数是元类自己
`__init__(cls, classname, bases, dict_attr)` : __init__ 的 cls 参数是元类创建的那个类.

```
# coding: utf-8

import re
_extract = {}
_site = re.compile(r".*\.(?P<site>.+?)\.com")

def parse(url):
    """ 解析视频真实地址 """
    site = _site.search(url).group("site")
    parser = _extract[site]

    return = parser.parse(url)

parse("http://www.letv.com/ptv/vplay/1111.html")

class VideoMeta(type):
    def __init__(cls, classname, base, dict_attr):
        assert hasattr(cls, "parse")
        assert hasattr(cls, "NAME")
        _extract[dict_attr["NAME"]] = cls()

        return type.__init__(cls, classname, bases, dict_attr)

class Video(object):
    __metaclass__ = VideoMeta
    NAME = "BASE"

    def parse(self, url):
        raise NotImplementedError

class LeTV(Video):
    NAME = "letv"
    def parse(self, url):
        pass

class UpperMeta(type):
    def __new__(cls, classname, bases, dict_attr):
        attr = {k.upper() if not k.startswith("__") else k:v for k,v in dict_attr.items()}
        return type.__new__(cls, classname, bases, attr)

class Person(object):
    __metaclass__ = Uppercase
    name = "lwy"
    age = 24

print("name" in Person.__dict__)
print("NAME" in Person.__dict__)
```
## 垃圾回收
- 引用计数为主
    
    优点: 简单, 实用
    缺点: 吞吐量不高, 循环引用.

- 标记-清除 和 分代收集为辅.
    ```
    gc.set_debug(gc.DEBUG_STATS)

    a = []
    b = []
    a.append(b)
    b.append(a)
    del a
    del b
    print("unreachable:", gc.collect())

    gc: collecting generation 2...
    gc: objects in each generation: 504 3398 0
    gc: done, 2 unreachable, 0 uncollectable, 0.0010s elapsed.
    ('unreachable:', 2)
    ```

    没有不可达对象, 靠引用计数就可以.
    ```
    gc.set_debug(gc.DEBUG_STATS)

    a = []
    b = []
    a.append(b)
    b.append(a)
    del a
    print("unreachable:", gc.collect())

    gc: collecting generation 2...
    gc: objects in each generation: 504 3398 0
    gc: done, 0.0010s elapsed.
    ('unreachable:', 0)
    ```

    gc.enabld()
    gc.disable()
    gc.get_threshold()      # (700, 10, 10)
    gc.collect([generation])    # 返回不可达对象数量.
    gc.is_tracked()
    
## 多线程, 多进程

## 其他





