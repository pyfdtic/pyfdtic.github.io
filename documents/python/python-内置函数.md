---
title: python-内置函数
date: 2018-03-16 17:31:00
categories:
- Python
tags:
- python 标准库
---
## 循环设计与循环对象
    range()
    enumerate()
    zip()
    iter()

## 函数对象
    map()
    filter()
    reduce()

## 序列操作
    all([True, 1, "hello!"])         # 是否所有的元素都相当于True值
    any(["", 0, False, [], None])    # 是否有任意一个元素相当于True值
    sorted([1,5,3])                  # 返回正序的序列，也就是[1,3,5]
    reversed([1,5,3])                # 返回反序的序列，也就是[3,5,1]   

## 类, 对象, 属性
    # define class
    class Me(object):
        def test(self):
            print "Hello!"
    def new_test():
        print "New Hello!"
    me = Me()   
    -----------------------

    hasattr(me, "test")               # 检查me对象是否有test属性
    getattr(me, "test")               # 返回test属性
    setattr(me, "test", new_test)     # 将test属性设置为new_test
    delattr(me, "test")               # 删除test属性

    isinstance(me, Me)                # me对象是否为Me类生成的对象 (一个instance)
    issubclass(Me, object)            # Me类是否为object类的子类

    globals()       # 返回全局命名空间, 比如全局变量名, 全局函数名
    locals()        # 返回局部命名空间.
    
## 编译,执行
    repr(me)                          # 返回对象的字符串表达
    compile("print('Hello')",'test.py','exec')       # 编译字符串成为code对象
    eval("1 + 1")                     # 解释字符串表达式。参数也可以是compile()返回的code对象
    exec("print('Hello')")            # 解释并执行字符串，print('Hello')。参数也可以是compile()返回的code对象