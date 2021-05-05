---
title: Flask-学习总结
date: 2018-03-14 23:27:11
categories:
- Python
tags:
- web development
- Flask
top: 3
---

Flask是一个简洁的 Python_web 框架. 

## 零. virtualenv 虚拟环境配置.

    $ easy_install pip
    $ pip install virtualenv
    $ virtualenv venv        # 创建名称为 venv 的虚拟环境
    $ source venv/bin/active     # 进入 venv 虚拟环境
    (venv) $ pip install flask   # 在虚拟环境中安装 flask 包
    (venv) $ deactivate          # 从虚拟环境退出

## 一. 基本配置

### 1. 创建并启动程序实例

示例 :

    from flask import Flask
    app = Flask(__name__)       # Flask 类的构造函数只有一个必须制定的参数, 即程序主模块或包的名字. 

    # route here

    if __name__ == "__main__":      # 程序启动后进入轮训, 等待并处理请求.
        app.run(debug=True)         # 启动服务器,并启用调试模式, 激活调试器和重载程序.

### 2. 配置 

app.config 字典用来存储框架, 扩展和程序本身的配置变量. 使用标准的字典语法就可把配置值添加到 app.config 对象中. 

示例代码 : 
    
    from flask import Flask
    app = Flask(app)
    app.config["SECRET_KEY"] = "hard to guess string"

该对象还提供了一些其他方法, 可以从文件或环境中导入配置值.

### 3. 路由 = 装饰器 + 视图函数.

处理URL 和 视图函数 之间映射关系的程序成为路由.

1.*生成路由映射*
    
    1. app.route 装饰器
        最简单方式是使用 app.route 装饰器.

        示例代码 : 
         
            @app.route("/", methods=["GET", "POST"])    # methods 为请求方法.
            def index():             # 视图函数.
                return "<h1>Hello World</h1>"

            @app.route("/user/<name>")      # 尖括号中的就是动态内容, 任何能匹配静态部分的 URL 都会映射到这个路由上. 调用视图函数时, Flaks 会将动态部分作为参数传入函数.
            def user(name):
                return "<h1>Hello , %s</h1>" % name

        动态视图函数类型定义 : 
            
            int : 匹配动态片id 为整数的 URL. `/user/<ind:id>`
            float : 浮点数
            path : path 类型也是字符串, 但不把斜线视作分隔符, 而将其视为动态片段的一部分. `/user/<path:dir_path>`        

    2. app.add_url_rule()

    3. app.errorhandler() 错误页面

        示例代码 : 

            @app.errorhandler(404)
            def page_not_found(e):
                return render_template('404.html'), 404

            @app.errorhandler(500)
            def internal_server_error(e):
                return render_template('500.html'), 500

2.*查看路由映射*

    >> from hello import app
    >> app.url_map
        Map([<Rule '/' (HEAD, POST, OPTIONS, GET) -> main.index>,
         <Rule '/static/bootstrap/<filename>' (HEAD, OPTIONS, GET) -> bootstrap.static>,
         <Rule '/static/<filename>' (HEAD, OPTIONS, GET) -> static>])    

## 二. 请求-响应模型.

HTTP 协议的基本模型即 **请求 <---> 响应**.

### 1. 上下文
Flask 使用上下文, 让特定的变量在一个线程中全局可访问, 而不会干扰其他线程.

Flask 中的上下文包含 **程序上下文** 和 **请求上下文** . 

Flask 在分发请求之前激活(或推送)程序和请求上下文, 请求处理完成后将其删除. 

程序上下文本推送后, 就可以在线程中使用 current_app 和 g 变量. 请求上下文本推送后, 就可以使用 request 和 session 变量. 

如果使用这些变量时, 没有激活程序上下文或请求上下文, 就会导致错误.


**很多 Flask 扩展都假设已经存在激活的程序上下文和请求上下文, 所以 使用不同线程执行 Flask 扩展时, 需要手动激活上下文.**

*1. 程序上下文*

| 变量名称  | 上下文   | 说明 |
| ---       | ---      | --- |
| current_app | 程序上下文 | 当前激活程序的程序实例 |
| g     | 程序上下文 | 处理请求时做临时存储的对象. 每次请求都会重设这个变量 |


*2. 请求上下文*

| 变量名称  | 上下文   | 说明 |
| ---       | ---      | --- |
| request  | 请求上下文 | 请求对象, 封装了客户端发出的 HTTP 请求中的内容 |
| session  | 请求上下文 | 用户会话, 用于存储请求之间需要 "记住" 的值的字典 |


示例 : 在视图函数中使用上下文

    from flask import request

    @app.route('/')
    def index():
        user_agent = request.headers.get("User-Agent")
        return "<p>Your browser is  %s</p>" % user_agent

示例 : 在 shell 中使用上下文(手动推送上下文). 

    >> from hello import app  # hello 为程序主文件
    >> from flask import current_app
    >> current_app.name                 # 未激活程序上下文就调用 current_app 导致错误.
        Traceback (most recent call last):
        ...
        RuntimeError : working outside of application context.
    >> app_ctx = app.app_context()      # 获取程序上下文
    >> app_ctx.push()                   # 推送上下文
    >> current_app.name
        "hello"

### 2. 请求钩子(注册通用函数)
Flask 提供了注册通用函数的功能, 注册的函数可在请求被分发到视图函数之前或之后调用.

| 请求钩子函数  | 说明 |
| ---           | ---  |
| before_first_request | 注册一个函数, 在处理第一个请求之前运行. |
| before_request | 注册一个函数, 在每次请求之前运行. |
| after_request | 注册一个函数, 如果没有未处理的异常抛出, 在每次请求之后运行. |
| teardown_request | 注册一个函数, 即使有未处理的异常抛出, 在每次请求之后运行. |


**在请求钩子函数和视图函数之间共享数据, 一般使用上下文全局变量 g .**

before_request 钩子在应用到蓝本时, 只能对应到针对蓝本的请求上; 如想在蓝本中使用针对程序全局请求的钩子, 必须使用 before_app_request .

示例代码 :

    @auth.before_app_request
    def before_request():
        if current_user.is_authenticated() and not current_user.confirmed and \
                        request.endpoint[:5] != 'auth.' and \
                        request.endpoint != 'static':
            return redirect(url_for("auth.unconfirmed"))

### 3. 响应 : 响应内容, 响应码, 响应首部.

Flask 返回响应有 4 种方式:

1. return : 在视图函数中返回响应.
    
    return "响应内容或模板", 响应码, {响应首部字典}

2. Response 对象 : flaks.make_response() 

    make_response() 函数接受 1个, 2个, 或 3个参数, 并返回一个 Response 对象.

    示例代码 :

        from flask import make_response

        @app.route("/")
        def index():
            response = make_response("<p>This Document carries a cookie !</p>")
            response.set_cookie("answer", "42")
            return response

3. 重定向 .

    重定向是一种特殊的响应类型, 这种响应没有页面文档, 只会告诉浏览器一个新地址, 浏览器在得到新地址之后, 自动重新请求加载新地址.

    重定向可以使用 3个 值形式的返回值生成, 可在 Response 对象中设定. 但是 Flask 提供了 redirect() 辅助函数, 用于生成这种响应.

    示例代码 : 
        
        from flask import redirect

        @app.route("/")
        def index():
            return redirect("http://www.example.com")

4. abort() : 

    abort() 处理错误. 

    示例代码 : 
        
        from flask import abort

        @app.route("/user/<id>")
        def get_user(id):
            user = load_user(id)
            if not user:
                abort(404)
            return "<h1>Hello , %s !</h1>" % user.name

    **注意 : abort 不会把控制权交给调用它的函数, 而是抛出异常把控制权交给 web 服务器.**

## 三. 大型程序组织结构
Flaks 并不强制要求大型项目使用特定的组织方式, 程序的结构组织方式完全有开发者自己决定. 

### 1. 项目结构示例

    ├── app
    │   ├── __init__.py
    │   ├── email.py
    │   ├── models.py
    │   ├── main /
    │   │   ├── __init__.py
    │   │   ├── errors.py
    │   │   ├── forms.py
    │   │   ├── views.py
    │   ├── static / 
    │   └── templates / 
    ├── config.py
    ├── manage.py
    ├── venv /
    ├── migrations /
    ├── requirements.txt
    └── tests /
        ├── __init__.py
        ├── test_*.py
    
    文件夹类 : 
        app : Flask 程序
        migrations : 数据库迁移脚本
        tests : 单元测试脚本
        venv : 虚拟环境

    文件类 : 
        requirements.txt : 程序依赖包
        config.py  : 存储配置
        manage.py : 启动脚本及程序任务.


### 2. 配置选项 : 层次的配置类.

    import os
    basedir = os.path.abspath(os.path.dirname(__file__))

    class Config:
        SECRET_KEY = os.environ.get('SECRET_KEY') or 'hard to guess string'
        SQLALCHEMY_COMMIT_ON_TEARDOWN = True
        
        FLASKY_MAIL_SUBJECT_PREFIX = '[Flasky]'
        FLASKY_MAIL_SENDER = 'Flasky Admin <flasky@example.com>'
        FLASKY_ADMIN = os.environ.get('FLASKY_ADMIN')
        
        @staticmethod
        def init_app(app):
            pass

    class DevelopmentConfig(Config):
        DEBUG = True
        
        MAIL_SERVER = 'smtp.googlemail.com'
        MAIL_PORT = 587
        MAIL_USE_TLS = True
        MAIL_USERNAME = os.environ.get('MAIL_USERNAME')
        MAIL_PASSWORD = os.environ.get('MAIL_PASSWORD')

        SQLALCHEMY_DATABASE_URI = os.environ.get('DEV_DATABASE_URL') or \
            'sqlite:///' + os.path.join(basedir, 'data-dev.sqlite')


    class TestingConfig(Config):
        TESTING = True
        SQLALCHEMY_DATABASE_URI = os.environ.get('TEST_DATABASE_URL') or \
            'sqlite:///' + os.path.join(basedir, 'data-test.sqlite')


    class ProductionConfig(Config):
        SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL') or \
            'sqlite:///' + os.path.join(basedir, 'data.sqlite')

    config = {
        'development': DevelopmentConfig,
        'testing': TestingConfig,
        'production': ProductionConfig,

        'default': DevelopmentConfig
    }

基类 Config 中包含通用配置, 子类分别定义专用的配置. 如果需要还可以添加其他的配置类.

配置类可以定义 init_app() 类方法, 其参数是程序实例. 在这个方法中, 可以执行对当前环境的配置初始化. 现在 , 基类 Confifg 中的 init_app() 方法为空.

config 字典中注册了不同的配置环境, 而且还注册了一个默认配置(开发环境).

### 3. 程序包 
程序包用来保存程序的所有代码,模板和静态文件. 

#### 1) 程序工厂函数
在单个文件中开发程序很方便, 但却有个很大的缺点, 因为程序在全局作用域中创建, 所以无法动态修改配置. 运行脚本时, 程序实例已经创建完毕, 再修改配置为时已晚. 这一点对单元测试尤其重要, 因为有事为了提高测试覆盖度, 必须在不同的配置环境中运行程序.

解决办法就是 : 延迟创建程序实例, 把创建过程移到可现实调用的工厂函数中. 这种方法不仅可以给脚本流出配置程序的时间, 还能够创建多个程序实例, 这些实例有时在测试中非常有用.

构造文件示例 : 

    # app/__init__.py

    from flask import Flask
    from flask_bootstrap import Bootstrap
    from flask_moment import Moment
    from flask_mail import Mail
    from flask_sqlalchemy import SQLAlchemy

    from config import config

    bootstrap = Bootstrap()
    mail = Mail()
    moment = Moment()
    db = SQLAlchemy()

    def create_app(config_name):
        app = Flask(__name__)
        app.config.from_object(config[config_name])
        config[config_name].init_app(app)

        bootstrap.init_app(app)
        mail.init_app(app)
        moment.init_app(app)
        db.init_app(app)

        # 附加路由和自定义的错误页面

        return app

构造文件导入了大多数正在使用的 Flask 扩展. 由于尚未初始化所需的程序实例, 所以没有初始化扩展, 创建扩展类时, 没有向构造函数传入参数. 

create_app() 函数就是程序的工厂函数, 接受一个 参数, 就是程序使用的配置名称. 配置类在 config.py 文件中定义, 其中保存的配置可以使用 Flaks app.config 配置对象提供的 from_object() 方法直接导入程序. 至于配置对象, 则可以通过名字从 config 字典中选择. 程序创建并配置好后, 就能初始化扩展了. 在之前创建的扩展对象上调用 init_app() 可以完成初始化过程.

工厂函数返回创建的程序示例, 不过,现在工厂函数创建的程序还不完整, 因为没有路由和自定义的错误页面处理程序.

#### 2) 蓝本

转换成程序工厂函数的操作让定义路由变复杂了. 在当脚本程序中, 程序实例存在于全局作用域中, 路由可以直接使用 app.route 装饰器定义. 但现在程序在运行时创建, 只有调用 create_app() 之后才能使用 app.route 装饰器, 这是定义路由就太晚了. 错误页面处理程序使用 app.errorhandler 装饰器, 也面临同样的困难.

解决方法 : **蓝本**

1. 创建蓝本
    
    蓝本中可以定义路由, 不同的是, 在蓝本中定义的路由处于休眠状态, 直到蓝本注册到程序上后, 路由才真正成为程序的一部分. 使用位于全局作用域中的蓝本时, 定义路由的方法几乎和单脚本程序一样.

    蓝本可以在单个文件中定义, 也可使用更结构化的方式在包中的多个模块中创建.

    为了获取更大的灵活性, 程序包中创建了一个子包, 用于保存蓝本.

    示例 : 
        
        # app/main/__init__.py

        from flask import Blueprint     

        main = Blueprint('main', __name__)    # 通过实例化一个 Blueprint 类对象创建蓝本, 该构造函数必须制定两个参数 : 蓝本名称 , 蓝本所在的包或模块(__name__即可).

        from . import views, errors     # views 模块保存程序路由, errors 模块保存页面错误处理程序. 导入这两个模块,可以路由和错误处理程序与蓝本关联起来.

        ** views 和 errors 在 __init__.py 脚本的末尾导入, 是为了避免循环导入依赖 ,因为在 两个模块中, 还有导入 蓝本 main.

2. 注册蓝本

    蓝本在 工厂函数 create_app() 中注册到程序上.

    示例 :

        # app/__init__.py

        #... 
        from .main import main as main_blueprint
        app.register_blueprint(main_blueprint)
        
        from .auth import auth as auth_blueprint
        app.register_blueprint(auth_blueprint, url_prefix="/auth")         # url_prefix 使得蓝本中定义的路由都会加上指定前缀.
        
        return app


3. 蓝本中的错误处理程序
    
    在蓝本中编写错误处理程序, 如果使用 errorhandler 装饰器, 那么只有蓝本中的错误才能触发处理程序; 要想注册程序全局的错误处理程序, 必须使用 app_errorhandler .

    示例 : 

        # app/main/errors.py

        from flask import render_template
        from . import main

        @main.app_errorhandler(404)
        def page_not_fount(e):
            return render_template('404.html'), 404
            
        @main.app_errorhandler(500)
        def page_not_fount(e):
            return render_template('500.html'), 500

4. 蓝本中的路由程序

    蓝本中的视图函数,与单脚本中的视图函数有两点不同: 

    - 路由装饰器由蓝本提供.
    - url_for() 的用法不同. 需要加上蓝本的名字. 如下 :

            url_for('main.index')   # 全局通用
            url_for('.index')       # 简写形式, 只在当前蓝本中使用.

    flask 为蓝本中的全部断点加上了一个**命名空间**, 这样在不同蓝本中使用相同的端点名称定义视图函数, 就不会产生冲突了. 命令空间的名称就是蓝本的名称. 这也是 url_for() 写法不同的原因.

            # app/main/views.py
            from datetime import datetime
            from flask import render_template, session, redirect, url_for

            from . import main
            from .forms import NameForm
            from .. import db
            from ..models import User

            @main.route("/", methods=["GET", "POST"])
            def index():
                form = NameForm()

                if form.validate_on_submit():
                    # ...
                    return redirect(url_for(".index"))
                return render_template("index.html",
                                    current_time=datetime.utcnow(),
                                    form=form,
                                    name=session.get("name"),
                                    known=session.get("known"))


### 4. 启动脚本

顶级文件夹中的 manage.py 用于启动程序.

示例 : 

    # manage.py

    import os
    from app import create_app, db
    from app.models import User, Role
    from flask_script import Manager, Shell
    from flask_migrate import Migrate, MigrateCommand

    app = create_app(os.getenv("FLASK_CONFIG" or "default"))    # 创建程序.
    manager = Manager(app)      # 初始化 Flask-Script
    migrate = Migrate(app, db)  # 初始化 Flask-Migrate


    def make_shell_context():
        return dict(app=app, db=db, Role=Role, User=User)

    manager.add_command("shell", Shell(make_context=make_shell_context))
    manager.add_command("db", MigrateCommand)

    if __name__ == "__main__":
        manager.run()

### 5. 需求文件
生成需求文件 : 
    
    $ pip freeze > requirements.txt

依据需求文件创建新的虚拟环境 :
    
    $ pip install -r requirements.txt


**配置文件的导入包含**一般在开发环境中, 可以将 requirements.txt 文件替换为 requirements 文件夹, 其中包含不同环境的配置文件 : 

    common.txt   # 基础包
    prod.txt     # 生产专用包
    demo.txt     # 测试专用包

其中 prod.txt 和 demo.txt 可以从 common.txt 中导入, 而无需重复包名, 格式如下:

    $ cat demo.txt
      -r common.txt
      ForgerPy==0.1

### 6. 创建数据库 
要在新数据库中创建数据表。如果使用 Flask-Migrate 跟踪迁移，可使用如下命令创建数据表或者升级到最新修订版本：
    
    $ python manage.py shell
        > db.create_all()
    $ python manage.py db upgrade

## 四. Flask 模板

### 1. Jinja2

### 2. Mako

## 五. Flask 其他

### 1. url_for()
url_for() 辅助函数 : 使用程序 URL 映射中保存的信息, 生成 URL. 可用于 视图函数中, 或者 Jinja2 模板中.

1. 相对地址
    
    url_for(view_func)

    示例 :

        url_for('index')    

2. 绝对地址
    
        url_for(view_func, exterual=True)

3. 动态地址

        url_for(view_func, key=value)

4. 动态参数

        url_for(view_func, page=2)

5. 静态文件

        url_for('static', filename="filename")

6. 在 蓝本 中
    
        url_for(Blueprint_Name.view_func)

### 2. Flash 消息

消息是 Flask 的核心特性.

#### 1) 在视图函数中使用消息
示例代码 : 

    from flask import flash

    @app.route("/", methods=["GET", "POST"])
    def index():
        form = NameForm()
        if form.validate_on_submit():
            old_name = session.get("name")
            if old_name is not None and old_name != form.name.data :
                flash("Looks lick you have changed your name !")
            session["name"] = form.name.data
            return redirect(url_for('index'))
        return render_template('index.html', form=form, name=session.get("name"))

#### 2) 在模板中渲染消息.
Flask 把 get_flashed_messages() 函数开放给模板, 用来获取并渲染消息.

仅在 视图函数中调用 flash() 函数并不能把消息显示出来, 程序使用的模板需要渲染这些消息. 最好在基模板中渲染 Flash 消息, 因为这样所有的页面都能使用这些消息.

    {% block content %}
        < div class="container">
        {% for message in get_flashed_messages() %}
        < div class="alert alert-warning">
            < button type="button" class="close" data-dismiss="alert" >&times;</button >
            {{ message }}
        < /div >
        {% endfor %}
            {% block page_content %}{% endblock %}
        </div >
    {% endblock %}


在模板中使用循环是因为在之前的请求循环中每次调用 flash() 函数都会生成一个消息, 所以可能有很多消息在排队等待显示.

get_flash_messages() 函数获取的消息在下次调用时不会再次返回, 因此 Flash 消息只显示一次, 然后就消失了.

## 六. Flask 扩展

Flask 被设计为可扩展模式, 故而没有提供一些重要的功能, 如数据库和用户认证, 所以开发者可以自由选择最合适程序的包, 或者自行开发.

专为 Flask 开发的扩展都暴露在 flask.ext 命名空间下. 

Flask 扩展的通用初始化方法 : **把程序实例作为参数传给构造函数, 初始化主类的实例. 创建的对象可以在各个扩展中使用.**


0. werkzeug : WSGI 工具集
1. [flask-script](http://www.pyfdtic.com/2018/03/19/flaskExt--flask-script/)
2. [flask-moment](http://www.pyfdtic.com/2018/03/19/flaskExt--flask-moment/)
3. flask-wtf : 表单处理
3. [flask-mail](http://www.pyfdtic.com/2018/03/19/flaskExt--flask-mail/) : 邮件发送
4. [flask-sqlalchemy](http://www.pyfdtic.com/2018/03/19/flaskExt--flask-sqlalchemy/) : SQL ORM 
5. flask-migrate : 数据库迁移
6. [flask-login](http://www.pyfdtic.com/2018/03/19/flaskExt--flask-login/) : 登录用户管理
7. [flask-pagedown](http://www.pyfdtic.com/2018/03/19/flaskExt--flask-pagedown/) : Markdown 支持
8. flask-HTTPAuth : HTTP 认证
9. Flask-Babel : 提供国际化和本地化支持。
10. FLask-RESTful : 开发 REST API 的工具。
11. [Celery](http://www.pyfdtic.com/2018/03/16/python-celery-%E4%BB%BB%E5%8A%A1%E9%98%9F%E5%88%97/) : 处理后台作业的任务队列。
12. Frozen-Flask : 把 Flask 程序转换成静态网站。
13. Flask-Debug Toolbar : 在浏览器中使用的调试工具。
14. Flask-Assets : 用于合并、压缩、编译 CSS 和 Java Script 静态资源文件。
15. Flask-OAuth : 使用 OAuth 服务进行认证。
16. Flask-Open ID : 使用 Open ID 服务进行认证。
17. Flask-Whoosh Alchemy : 使用 Whoosh 实现 Flask-SQLAlchemy 模型的全文搜索。
18. Flask-KVsession : 使用服务器端存储实现的另一种用户会话。
19. [flask-socketio](http://www.pyfdtic.com/2018/03/16/flaskExt--flask-socketio/) : 服务器端与客户端双向通信.实时数据流.
20. [flask-sse](http://www.pyfdtic.com/2018/03/16/flaskExt--flask-sse/) : 服务器端向客户端发送事件.实时数据流.
21. [flask-whooshee](http://www.pyfdtic.com/2018/03/16/flaskExt--flask-whooshee/) : 基于 whooshee 的全文索引flask 插件, 可与 SQLAlchemy 无缝集成.

## 七. Flask 信号

    $ pip search blinker

## 八. 参考链接
[Flask web 开发 : 基于Python的Web应用开发实战](https://www.amazon.cn/Flask-Web%E5%BC%80%E5%8F%91-%E5%9F%BA%E4%BA%8EPython%E7%9A%84Web%E5%BA%94%E7%94%A8%E5%BC%80%E5%8F%91%E5%AE%9E%E6%88%98-%E7%BE%8E-%E6%A0%BC%E6%9E%97%E5%B8%83%E6%88%88/dp/B0153177A6/ref=sr_1_1?ie=UTF8&qid=1490938750&sr=8-1&keywords=flask+web+%E5%BC%80%E5%8F%91)
