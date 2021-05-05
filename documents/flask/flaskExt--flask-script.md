---
title: Flask 扩展之--flask-script
date: 2018-03-19 18:49:25
categories:
- Python
tags:
- Flask
- Flask 扩展
---
## 一. 使用 Flask-Script 支持命令行选项

### 1. 安装
    
    $ pip install flask-script

### 2. 配置

    from flask_script import Manager
    manager = Manager(app)

    # ... 

    if __name__ == "__main__":
        manager.run()

### 3. 使用
    
    $ python hello.py
        usage: myflask.py [-h] {shell,runserver} ...

        positional arguments:
          {shell,runserver}
            shell            Runs a Python shell inside Flask application context.
            runserver        Runs the Flask development server i.e. app.run()

        optional arguments:
          -h, --help         show this help message and exit
    
    $ python hello.py shell --help

    $ python hello.py runserver --help

    $ python hello.py runserver --host 0.0.0.0

## 二. 添加自定义命令

### 方法一 : manager.add_command()

使用 Flask-Script 的 shell 命令自动导入特定的对象 : 为 shell 注册一个 make_context 回调函数.

```Python
from flask_script import Shell

def make_shell_conntext():
    """ make_shell_context() 注册了程序, 数据库实例, 以及模型."""
    return dict(app=app, db=db, User=User, Role=Role)

manager.add_command("shell". Shell(make_context=make_shell_context))    # 添加命令.
```

### 方法二 : 继承 Command 的子类

```Python
from flask_script import Command

class Hello(Command):
    "prints hello world"

    def run(self):
        print "hello world"

manager.add_command('hello', Hello()) # 或 manager.run({'hello' : Hello()})

$ python manage.py hello
```

为命令行, 添加参数 : 添加 `option_list` 类属性 或者 添加 `get_options()` 类方法.
```Python
from flask_script import Command, Manager, Option

class Hello1(Command):
    """ 添加 option_list 类属性 """
    option_list = (
        Option('--name', '-n', dest='name'),
    )

    def run(self, name):
        print "hello %s" % name

class Hello2(Command):
    """ 添加 get_options() 类方法 """
    def __init__(self, default_name='Joe'):
        self.default_name=default_name

    def get_options(self):
        return [
            Option('-n', '--name', dest='name', default=self.default_name),
        ]

    def run(self, name):
        print "hello",  name
```

### 方法三 : manager.command 装饰器

manager.command 让自定义命令变得简单. 装饰函数名就是命令名, 安徽省农户的文档字符串会显示在帮助命令中.

```Python
@manager.command
def test():
    """Run the unit tests."""
    import unittest
    tests = unittest.TestLoader().discover('tests')
    unittest.TextTestRunner(verbosity=2).run(tests)

$ python manage.py test

@manager.command
def hello():
    print "Hello world"

$ python manage.py hello
```

为命令行, 添加参数支持.

```Python
@manager.command
def hello(name):
    print "hello", name

$ python manage.py hello Joe
hello Joe
```

### 方法四 : manager.option 装饰器, 本身即支持参数.

```Python
@manager.option('-e', '--email', dest='email', help="Plz input a user's email address !")
def mfareset(email):
    """ Doc String here. """
    user = User.query.filter_by(email=email).first()
    if user is not None:
        user.otp_secret = None
        db.session.add(user)
        db.session.commit()

        print "the MFA of '%s' have been reset, Plz relogin, and scan the QR code." % email

    else:
        print "User is not exist: %s ." % email

$ python manage.py mfareset -h          # 查看帮助信息. 帮助信息同时会显示 doc_string, 作为辅助帮助信息输出.

$ python manage.py mfareset -e test@example.com
$ python manage.py mfareset --email=test@example.com
```

## 三. Sub-Manager
A Sub-Manager is an instance of Manager added as a command to anothor Manager.

创建 Sub-Manager :
```Python
def sub_opts(app, **kwargs):
    pass

user_manager = Manager(sub_opts, usage="User management.")      # usage 将出现在 --help 的说明中.

@user_manager.command
def hello():
    print "hello user!"

@user_manager.option("-n", "--name", dest="name", help="add new user")
def add(name):
    print "Add user : %s" % name

manager = Manager(self.app)
manager.add_command("user", user_manager)

# shell
$ python manage.py user hello
$ python manage.py user add --name='tom'
```
If you attach options to the `user_manager`, the `sub_opts` procedire will reveive their values. Your application is passed in app for convenience.

If `sub_opts` returns a value other than None, this value will replace the app value that's passed on. This way, you can implement a sub-manager which replaces the whole app. One use case is to create a separate administrative application for improved security:

```Python
def gen_admin(app, **kwargs):
    from myweb.admin import MyAdminApp
    ## easiest but possibly incomplete way to copy your settings.
    return MyAdminApp(config=app.config, **kwargs)

sub_manager = Manager(gen_admin)

manager = Manager(MyApp)
manager.add_command("admin", sub_manager)

# shell
$ python manage.py admin SUB_CMD
```

A sub-manager does not get default commands added to itself(by default).


`flaks-migrate.MigrateCommand` 示例参考:
```Python
# lib/python2.7/site-packages/flask_migrate/__init__.py
from alembic import command

MigrateCommand = Manager(usage = 'Perform database migrations')

@MigrateCommand.option('-d', '--directory', dest = 'directory', default = None, help = "migration script directory (de
def init(directory = None):
    "Generates a new migration"
    if directory is None:
        directory = current_app.extensions['migrate'].directory
    config = Config()
    config.set_main_option('script_location', directory)
    config.config_file_name = os.path.join(directory, 'alembic.ini')
    command.init(config, directory, 'flask')

# myapp/manage.py
from flask_migrate import Migrate, MigrateCommand
manager.add_command('db', MigrateCommand)

# shell
$ python manage.py db init

```