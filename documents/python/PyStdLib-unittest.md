---
title: PyStdLib--unittest
date: 2018-03-19 18:35:18
categories:
- Python
tags:
- python 标准库
---
# 一. unittest 单元测试

### 编写单元测试

示例代码 :

    import unittest
    from flask import current_app
    from app import create_app, db

    class BaseTestCase(unittest.TestCase):
        def setUp(self):
            self.app = create_app('testing')
            self.app_context = self.app.app_context()
            self.app_context.push()
            db.create_all()

        def tearDown(self):
            db.session.remove()
            db.drop_all()
            self.app_context.pop()

        def test_app_exists(self):
            self.assertFalse(current_app is None)

        def test_app_is_testing(self):
            self.assertTrue(current_app.config['TESTING'])




### 单元测试方法汇总 : 

    setUp() 和 tearDown() 方法分别在各测试前后运行.

    以 test_ 开头的函数都作为测试执行.

    self.asserTrue(EXPRESSION)
    self.asserFalse(EXPRESSION)
    self.asserRaise(ERROR_TYPE)


### 调用单元测试

在 manage.py 中添加自定义命令 , 用于测试.: 

    @manager.command
    def test():
        """Run the unit tests."""
        import unittest
        tests = unittest.TestLoader().discover('tests')
        unittest.TextTestRunner(verbosity=2).run(tests)   

装饰函数名就是命令名, 函数的文档字符串会显示在帮助信息中. tests() 函数的定义体重调用了 unittest 包提供的测试运行函数.