---
title: Flask 扩展之--flask-login
date: 2018-03-19 18:49:27
categories:
- Python
tags:
- Flask
- Flask 扩展
---
# 一. 使用 Werkzeug 实现密码散列.

## generate_password_hash(password, method=pbkdf2:sha1, salt_length=8)
将原始密码作为输入, 以字符串形式输出密码散列值, 输出的值可保存在用户数据库中. method 和 salt_length 的默认值就能满足大多数需求.


## check_password_hash(hash, password)
这个函数的参数是从数据库中取回的密码散列值和用户输入的密码. 返回值为 True, 表明密码正确.


示例代码 : 

    from werkzeug.security import generate_password_hash, check_password_hash

    class User(db.Model):
        
        # ... 

        password_hash = db.Column(db.String(128))

        @property
        def password(self):         # 设置属性不可读.
            raise AttributeError("Password is not a readable attribute.")

        @password.setter
        def password(self, password):   # 写入密码
            self.password_hash = generate_password_hash(password)

        def verify_password(self, password):    # 认证密码
            return check_password_hash(self.password_hash, password)

# 二. 使用 Flask-Login 认证用户.

用户登录程序后, 他们的认证状态要被记录下来, 这样浏览不同的页面时, 才能记住这个状态.

Flask-Login 是专门用来管理用户认证系统中的认证状态, 并且不依赖特定的认证机制.

## 1. 安装 

    $ pip install flask-loging

## 2. 初始化

    from flask_login import LoginManager

    login_manager = LoginManager(app)
    login_manager.session_protection = 'strong'
    login_manager.login_view = 'auth.login'

**session_protection** : 属性可以设为 None, 'basic', 'strong' , 已提供不同的安全等级防止用户篡改会话.
    strong : Flask-Login 会记录客户端IP地址和浏览器的用户代理信息, 如果发现异常就登出用户.

**login_view** : 设置登录页面的端点.

## 3. 使用方法

### 1) 模型实现

#### 方法一 : 实现4个模型方法
使用 Flask-Login 扩展, 程序的 模型必须实现几个方法 : 

**Flask-Login 要求实现的用户方法**

| 方法  | 说明  |
| ---   | ---   |
| is_authenticated() | 如果用户一登录, 返回 True, 否则返回 False |
| is_active()   |  如果允许用户登录, 返回 True, 否则返回 False. 如果要禁用账户, 可以返回 False  |
| is_anonymous()   |   对普通用户必须返回 False |
| get_id()  |  必须返回用户的唯一标识符, 使用 Unicode 编码字符串 |
**这四个方法可以在模型类中作为方法直接实现.**

#### 方法二 : UserMixin 类
Flask-Login 提供了一个 UserMixin 类, 其中包含以上方法的默认实现, 且能满足大多数需求.

示例代码 : 

    from flask_login import UserMixin

    class User(UserMixin, db.Model):
        pass

#### 回调函数 : 使用指定的标识符加载用户. 定义在用户模型中.

加载用户的回调函数, 接受已 Unicode 字符串形式表示的用户标识符. 如果能找到用户, 这个函数必须返回用户对象, 否则返回 None.

示例代码 : 

    from . import login_manager


    @login_manager.user_loader
    def load_user(user_id):
        return User.query.get(int(user_id))

### 2) 保护路由 : login_required 装饰器
为了保护路由只让认证用户访问, Flask-Login 提供了一个 login_required 装饰器.

示例代码 :
    
    from flask_login import login_required

    @app.route('/secret')
    @login_required
    def secret():
        return "Only authenticated users are allowed!"

### 3) 模板调用

Flask-Login 变量提供 current_user 变量, 且在视图函数和模板中自动可用, 该变量的值是当前登录的用户, 如果用户尚未登录, 则是一个匿名用户代理对象.

示例代码 : 
    
    # 视图函数中调用
    from flask-login import current_user

    @auth.route("/confirm/<token>")
    @login_required
    def confirm(token):
        if current_user.confirmed:
            return redirect(url_for("main.index"))
        if current_user.confirm(token):
            flash("You have confirmed you account. Thanks!")
        else:
            flash("You confirmation link is invalid or has expired.")
        return redirect(url_for("main.index"))

    # 模板中调用
    <ul class="nav navbar-nav navbar-right">
        {% if current_user.is_authenticated %}
        <li><a href="{{ url_for('auth.logout') }}">Sign Out</a></li>
        {% else %}
        <li><a href="{{ url_for('auth.login') }}">Sign In</a></li>
        {% endif %}
    </ul>

### 4) 登入用户: login_user(user, BOOLEAN)
Flask-Login 提供 login_user() 函数, 在用户会话中把用户标记为已登录.

login_user() 函数的参数是要登录的用户, 以及可选的 "记住我" 布尔值, "记住我" 也可在表单中实现. 如果布尔值为 True, 那么 关闭浏览器后用户会话就会过期, 下次访问时要重新登录; 如果为 False, 那么会在用户浏览器中写入一个长期有效的 cookie, 使用这个 cookie 可以复现用户会话.

示例代码 : 

    from flask import render_template, redirect, request, url_for, flash
    from flask_login import login_user

    from . import auth
    from ..models import User
    from .forms import LoginForm


    @auth.route("/login", methods=["GET", "POST"])
    def login():
        form = LoginForm()
        if form.validate_on_submit():
            user = User.query.filter_by(email=form.email.data).first()
            if user is not None and user.verify_password(form.password.data):
                login_user(user, form.remember_me)
                return redirect(request.args.get('next') or url_for('main.index'))
            flash("Invalid Username or Password")
        return render_template('auth/login.html', form=form)

用户访问未授权的 URL 时, 会显示登录表单. Flask-Login 会把原地址保存在查询的 next 参数中, 这个参数可从 request.args 字典读取. 如果查询字符串没有 next 参数, 则重定向到首页. 

### 5) 登出用户: logout_user()

Flask-Login 提供 logout_user() 函数, 删除并重设用户会话.

示例代码 : 

    from flask_login import logout_user, login_required

    @auth.route("/logout")
    @login_required
    def logout():
        logout_user()
        flash("You have been logged out.")
        return redirect(url_for("main.index"))

# 三. 使用 itsdangerours 生成确认令牌

对于某些特定类型的程序, 有必要确认注册时用户提供的信息是否正确. 常见要求是能通过提供的调子邮件地址与用户取得联系.

    In [1]: from itsdangerous import TimedJSONWebSignatureSerializer as Serializer

    In [2]: s = Serializer(app.config['SECRET_KEY'],expires_in=3600)

    In [3]: token = s.dumps({'confirm':23})

    In [4]: token
    Out[4]: 'eyJhbGciOiJIUzI1NiIsImV4cCI6MTQ4OTgyMDY4MiwiaWF0IjoxNDg5ODE3MDgyfQ.eyJjb25maXJtIjoyM30.Fg9uyyOMtJ7Mk_LhycSaJgI5tIkkK1tbfswTxZ7qaEk'

    In [5]: data=s.loads(token)

    In [6]: data
    Out[6]: {'confirm': 23}

itsdangerous 提供多种生成令牌的方法. 其中 TimedJSONWebSignatureSerializer 类生成具有过期时间的 JSON web 签名(JSON Web Signatures, JWS). 这个类的构造函数接受的参数是一个密钥, 在 Flask 程序中可使用 SECRET_KEY 设置.

**dumps()** 方法为指定的数据生成一个加密签名, 然后在对数据和签名进行序列化, 生成令牌字符串. expires_in 参数设置令牌的过期时间, 单位为 秒.

**loads()** 用于解码令牌. 其唯一的参数是令牌字符串. 这个方法会检查签名和过期时间, 如果通过, 返回原始数据. 如果令牌不正确或过期, 抛出异常.