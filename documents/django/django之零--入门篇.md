---
title: django之零--入门篇
date: 2018-03-16 17:02:52
categories:
- Python
tags:
- web development
- django
---
本质上来说， Django 只不过是用 Python 编写的一组类库。 用 Django 开发站点就是使用这些类库编写 Python 代码。 因此，学习 Django 的关键就是学习如何进行 Python 编程并理解 Django 类库的运作方式。

学习Django就是学习她的命名规则和API。

Django 的可选 GIS(地理信息系统) 支持需要 Python 2.4 到 2.6 .

Django 支持的数据库:
    
- pgsql (Django的可选GIS支持，它为PostgreSQL提供了强大的功能)
    
    安装 psycopg2 

- SQLite3

- Mysql

    安装 MySQLdb 

- Oracle

    安装 cx_Oracle

## 一. 安装 django
    $ pip install django
        (env)$ python
    >> import django
    >> django.VERSION
    >> django.get_version()

## 二.开始一个项目

**项目**是 django 实例的一系列设置的集合, 它包括数据库配置, Django 特定选项以及应用程序的特定设置.
    
    $ django-admin.py startproject mysite

    $ python manage.py help

    $ tree mysite
        mysite/
        ├── manage.py       # 命令行工具, 允许以多种方式与该 Django 项目交互
        └── mysite
            ├── __init__.py     # 将该目录当成一个 包.
            ├── settings.py     # 该 Django 项目的设置或配置.
            ├── urls.py         # Django 项目的 URL 设置.
            └── wsgi.py

        # For the full list of settings and their values, see
        # https://docs.djangoproject.com/en/1.10/ref/settings/

    $ python manage.py runserver 8000   # 启动服务器.

**文件职责介绍**:

- `urls.py` : 网址入口,关联到对应的 views.py 的中的一个函数(或generic类),访问网址对应一个函数.

- `views.py` : 处理用户发出的请求, 从 urls.py 中对应过来, 通过渲染 templates 中的网页可以将显示的内容.

- `models.py` : 与数据库操作有关,存入或存取数据时使用,可以不用.

- `forms.py` : 表单,用户在浏览器上输入数据提交,对数据的验证工作以及输入框的生成等工作,可以不用.

- `templates` 文件夹 : views.py 中的函数渲染 templates 中的html模板,得到动态内容网页,可用缓存来提升速度.

- `admin.py` : 后台,可以用少量的代码,拥有一个强大的后台.

- `settings.py` : Django的设置,配置文件,比如 DEBUG 开关,静态文件的位置等.

每个视图函数至少需要一个参数, 通常叫做 request , 这是一个触发这个视图, 包含当前 web 请求信息的对象, 是类 django.http.HttpRequest 的一个实例.

一个视图就是 Python 的一个函数, 这个函数第一个参数的类型是 HttpRequest, 它返回一个 HttpResponse 实例, 为了使一个 Python 的函数成为一个 Django 可识别的函数, 它必须满足这两个条件.

## 三. urls 
The `urlpatterns` list routes URLs to views. For more information please see:    
    https://docs.djangoproject.com/en/1.10/topics/http/urls/                     
Examples:                                                                        

1. Function views                                                                   

    1. Add an import:  `from my_app import views`
    2. Add a URL to urlpatterns:  `url(r'^$', views.home, name='home')`            

2. Class-based views                                                                
    
    1. Add an import:  `from other_app.views import Home`                          
    2. Add a URL to urlpatterns:  `url(r'^$', Home.as_view(), name='home')`        

3. Including another URLconf   

    1. Import the include() function: `from django.conf.urls import url, include`  
    2. Add a URL to urlpatterns:  `url(r'^blog/', include('blog.urls'))` 

将代码放置在文档根目录之外的某些目录中.

运行 开发服务器

    $ python manage.py runserver [0.0.0.0:8080]

    $ python manage.py runserver --help

    $ vim mysite/mysite/settings.py
        ALLOWED_HOSTS = ['192.168.100.128']     # 配置 开发服务器 IP.

开发服务器会自动监测代码改动并自动重新载入，所以不需要手工重启

## 四. 命令汇总

    # 新建一个 django project
        $ django-admin.py startproject PROJECT_NAME
    
    # 新建 app
        $ python manage.py startapp APP_NAME 
        $ django-admin.py startapp APP_NAME     # 同上 
        
        ** 一般一个项目有多个app,当然通用的app也可以在多个项目中使用

    # 同步数据库
    
        $ python manage.py syncdb

        ** 当 Django 1.7.1 及以上版本需使用以下命令:
            $ python manage.py makemigrations
            $ python manage.py migrate

        ** 这种方法可以创建表,当你在 models.py 中新增了类时,运行它就可以自动在数据库中创建表了,不用手动创建.

        ** 对已有的 models 进行修改，Django 1.7 之前的版本的Django都是无法自动更改表结构的, 不过有第三方工具 south

    # 使用开发服务器 :

        开发服务器，即开发时使用，一般修改代码后会自动重启，方便调试和开发，但是由于性能问题，建议只用来测试，不要用在生产环境。

        $ python manage.py runserver
        $ python manage.py runserver 8001
        $ python manage.py runserver 0.0.0.0:8000


    # 清空数据库 :
        $ python manage.py flush    # 会询问 yes 还是 no. yes 会把数据全部清空,只留下空表.

    # 创建超级管理员 :
        $ python manage.py createsuperuser  # 用户名,密码必填,邮箱可留空.

        $ python manage.py changepassword username  # 修改用户密码.


    # 导入导出数据
        
        $ python manage.py dumpdata appname > appname.json

        $ python manage.py loaddata appname.json

    # Django 项目环境终端.

        $ python manage.py shell        # 如果你安装了 bpython 或 ipython 会自动用它们的界面，推荐安装 bpython。

        ** 这个命令和 直接运行 python 或 bpython 进入 shell 的区别是：你可以在这个 shell 里面调用当前项目的 models.py 中的 API，对于操作数据，还有一些小测试非常方便。


    # 数据库命令行
        $ python manage.py dbshell 

        Django 会自动进入在settings.py中设置的数据库，如果是 MySQL 或 postgreSQL,会要求输入数据库用户密码。

        在这个终端可以执行数据库的SQL语句。

    # 更多命令 :
        $ python manage.py    # 查看命令列表.
        $ python manage.py help <subcommand> 

    # 获取帮助 : 
        $ python manage.py --help
        $ python manage.py help [SUB_CMD]

    # 后台管理密码
        $ python manage.py createsuperuser 
            user : admin
            password : 123456

        $ curl http://example.com/admin