---
title: django之一--视图篇
date: 2018-03-16 17:02:09
categories:
- Python
tags:
- web development
- django
---
## 一. Django 请求处理流程

**每个 view 函数的第一个参数是一个 HttpRequest 对象**

所有均开始于 `setting.py` 文件. 
    
当运行 `python manage.py runserver` 时, 脚本将会在 manage.py 同一个目录下查找名为 `settings.py` 的文件. 这个文件包含了所有关于这个 Django 项目的配置信息, 均采用大写形式表示 : TEMPLATE_DIRS,DATABASE_NAME 等.

最重要的设置是 `ROOT_URLCONF`, 它将作为 URLconf 告诉 django 在这个站点中那些 Python 的模块将被用到.

    ROOT_URLCONF = 'mysite.urls'

当访问某个 URL 时, Django 根据 `ROOT_URLCONF` 的设置装载 `URLconf`. 然后按顺序逐个匹配 `URLconf` 里的 `URLpattern`, 直到找到一个匹配的. 当找到这个匹配的 `URLpattern` 就调用相关联的 view 函数, 并把 `HttpRequest` 对象作为第一个参数 传给 view 函数.

一个视图函数必须返回一个 `HttpResponse` . 一旦做完, Django 将完成剩余的转换 Python 对象到一个合适的代用 HTTP 头和 body 的 Web Response.

总结如下:

1. 进来的请求转入/hello/.
2. Django通过在ROOT_URLCONF配置来决定根URLconf.
3. Django在URLconf中的所有URL模式中，查找第一个匹配/hello/的条目。
4. 如果找到匹配，将调用相应的视图函数, 并将`HttpRequest`作为第一个参数, 传给被调用的视图函数.
5. 视图函数返回一个HttpResponse
6. Django转换HttpResponse为一个适合的HTTP response， 以Web page显示出来


Django 视图: 默认**时区**为 America/Chicago , 是 Django 的诞生地. 可以修改 `settings.py` 中的 `TIME_ZONE = 'Time/Zone'` 做修改.


## 二. 编写视图函数 :
    
    # views.py

    from django.http import HttpResponse

    def hello(request):
        return HttpResponse("Hello world")

每个视图函数至少要有一个参数, 通常被叫做 request. 这是一个触发这个函数, 包含当前 web 请求信息的对象, 是 类 django.http.HttpRequest 的一个实例. 它必须是视图的第一个参数.

视图函数的名称并不重要. 它只是一个普通的函数, 方便记忆与理解即可.

一个视图就是 Python 的一个函数, 这个函数第一个参数的类型是 HttpRequest; 它返回一个 HttpResponse 实例.

## 三. 配置视图函数: URLconf
URLconf : 即 `urls.py`文件, 本质是 URL 模式以及要为该 URL 模式调用的 视图函数之间的 映射表.
    
    $ cat urls.py

      from django.contrib import admin

      from mysite.views import hello    # 导入视图函数 hello

      urlpatterns = [
        url(r'^admin/', admin.site.urls),
        url('^hello', hello),           # 加入到映射列表中.所有指向 URL /hello/ 的请求都应由 hello 这个视图函数来处理。
        url('^$', my_homepage_view),    # 网站根目录视图函数
      ]

应该注意是 urlpatterns 变量， Django 期望能从 `ROOT_URLCONF` 模块中找到它。 该变量定义了 URL 以及用于处理这些 URL 的代码之间的映射关系。

### 1. URLpattern 语法: 
- Django 在检查 URL 模式之前, 移除每一个申请的 URL 开头的 斜杠(/). 这意味着我们为 `/hello/` 写 URL 模式不用包含开头的斜杠(/).
- 模式包含了一个尖号(^)和一个美元符号($). 这些都是正则表达式符号. 大多数的 URL 模式会以`\^`开始, 以`\$`结束, 但是拥有复杂匹配的灵活性会更好.
- 如果访问 尾部没有斜杠(/) 如 `/hello`, 则该请求会被重定向至尾部包含斜杠(/)的URL(/hello/). 该行为受到 setting 中的 `APPEND_SLASH` 选项的控制. 

### 2. URLpattern 支持的正则表达式
Django URLconfs 允许你使用任意的正则表达式来做强有力的 URL 映射.

| 符号 | 匹配 |
| --- | --- |
| `. (dot)` | 任意单一字符 |
| `\d`  |  任意一位数字 |
| `[A-Z]`  |   A 到 Z中任意一个字符（大写） |
| `[a-z]`   |  a 到 z中任意一个字符（小写） |
| `[A-Za-z]`   |   a 到 z中任意一个字符（不区分大小写） |
| `+`   |  匹配一个或更多 (例如, \d+ 匹配一个或 多个数字字符) |
| `[^/]+`   |  一个或多个不为‘/’的字符 |
| `?`  |  零个或一个之前的表达式（例如：\d? 匹配零个或一个数字） |
| `*`   | 匹配0个或更多 (例如, \d* 匹配0个 或更多数字字符) |
| `{1,3}`  |  介于一个和三个（包含）之前的表达式（例如，\d{1,3}匹配一个或两个或三个数字） |


### 3. URL 配置和松耦合

Django 和 URL 配置背后哲学: **松耦合原则**. 简单的说, 松耦合是一个重要的保证互换性的软件开发方法.

Django 的 URL 配置就是一个很好的例子, 在 Django 的应用程序中, URL 定义和视图函数之间是松耦合的, 换句话说, **决定 URL 返回那个视图函数和实现这个视图函数是在两个不同的地方**. 这使得开发人员可以修改一块而不会影响另一块.
    
    urlpatterns = [
        url(r'^admin/', admin.site.urls),
        url('^hello/$', hello),
        url('^time/$', current_datetime),
        url('^another-time/$', current_datetime),        
    ]

## 四. URLconf 高级技巧
### 1. 函数对象方法
    
    from django.contrib import admin
    from mysite.views import hello    # 导入视图函数 hello

    urlpatterns = [
        url(r'^admin/', admin.site.urls),
        url('^hello', hello),           
        url('^$', my_homepage_view),   
    ]

### 2. 字符串方法

#### 2.1 为某个特别的模式指定视图函数: 
    
传入一个包含模块名和函数名的字符串, 而不是函数对象本身. Django 会在第一次需要他时根据字符串所描述的视图函数的名字和路径, 导入合适的视图函数.

    from django.conf.urls.defaults import *

    # 注意视图函数名前后的引号, 
    urlpatterns = patterns('',
        (r'^hello/$', 'mysite.views.hello'),
        (r'^time/$', 'mysite.views.current_datetime'),

    )

#### 2.2 提取公共视图前缀, 仅限于使用字符串视图函数的时候.
    

    from django.conf.urls.defaults import *

    # 注意视图函数名前后的引号, 
    urlpatterns = patterns('mysite.views',
        (r'^hello/$', 'hello'),
        (r'^time/$', 'current_datetime'),

    ) 

#### 2.3 多个视图前缀
    
整个框架关注的是存在一个名为 `urlpatterns` 的模块级别的变量. 该变量可动态生成. patterns() 返回的对象是可相加的.

    from django.conf.urls.defaults import *

    urlpatterns = patterns('mysite.views',
        (r'^hello/$', 'hello'),
        (r'^time/$', 'current_datetime'),
        (r'^time/plus/(\d{1,2})/$', 'hours_ahead'),
    )

    urlpatterns += patterns('weblog.views',
        (r'^tag/(\w+)/$', 'tag'),
    )

### 3. 动态 urlpatterns 与 调试模式
    
    在 django 的调试模式下修改 URLconf 的行为, 只需在运行时检查 DEBUGF 配置项的值即可.

        from django.conf import settings
        from django.conf.urls.defaults import *
        from mysite import views

        urlpatterns = patterns('',
            (r'^$', views.homepage),
            (r'^(\d{4})/([a-z]{3})/$', views.archive_month),    # 
        )

        # URL链接 /debuginfo/ 只在你的 DEBUG 配置项设为 True 时才有效。
        if settings.DEBUG:
            urlpatterns += patterns('',
                (r'^debuginfo/$', views.debug)
            )

### 4. 正则表达式实现的 动态 URL
#### 4.1 使用正则表达式 无命名组
使用 **无命名正则表达式组**，即，在我们想要捕获的URL部分上加上小括号，Django 会将捕获的文本作为位置参数传递给视图函数。

    # urls.py
    urlpatterns = [
        # ...
        url(r'^time/plus/(\d{1,2})/$', hours_ahead),    # (\d{1,2}) 实质是 参数.
        # ...
    ]

    # views.py
     def hours_ahead(request,offset):
        try:
            offset = int(offset)
        except ValueError:
            raise Http404()

        dt = datetime.datetime.now() + datetime.timedelta(hours=offset)
        html="<html><body>In %s hours, it will be %s.</body></html>" % (offset, dt)

        return HttpResponse(html)

#### 4.2 使用正则表达式 命名组
    
使用**命名正则表达式**来捕获 URL, 并将其做为**关键字参数**传给视图.

命名组的**语法**为 `(?P<NAME>PATTERN)`, NAME 是命名组的名称, PATTERN 是 匹配的模式.

命名组可以是 URLconf 更加清晰 ,可读性更强, 减少搞混参数次序的潜在 BUG , 还可以在视图函数中从新定义参数的顺序.

    # 使用无名组 URLconf
    from django.conf.urls.defaults import *
    from mysite import views

    urlpatterns = patterns('',
        (r'^articles/(\d{4})/$', views.year_archive),
        (r'^articles/(\d{4})/(\d{2})/$', views.month_archive),
    )

    # url /articles/2006/03/ 将使用如下调用:
    month_archive(request, '2006', '03')


    # 使用命名组 URLconf
    from django.conf.urls.defaults import *
    from mysite import views

    urlpatterns = patterns('',
        (r'^articles/(?P<year>\d{4})/$', views.year_archive),
        (r'^articles/(?P<year>\d{4})/(?P<month>\d{2})/$', views.month_archive),
    )

    # url /articles/2006/03/ 将使用如下调用:
    month_archive(request, year='2006', month='03')


**命名组和非命名组不能同时出现在一个 URLconf 中**,
URLconf解释器有关正则表达式中命名组和 非命名组所遵循的算法:
- 如果有任何命名组, django 会忽略非命名组, 而直接使用命名组.
- 否则, django 会把所有非命名组 以位置参数的形式传递.
- 在以上的两种情况，Django同时会以关键字参数的方式传递一些额外参数.

### 5 向视图函数传递额外参数.
#### 5.1 URL 中向后端视图函数传入的, 是 纯 Python 字符串, 而无论正则表达式中的匹配格式. 
        
    # 如下 year  参数, 传入到 year_archive 方法的数据类型是字符串, 而不是数字, 在视图函数中需要做一次转换.
    (r'^articles/(?P<year>\d{4})/$', views.year_archive) 

#### 5.2 视图函数传参
URLconf 里面的每一个模式都可以包含第三个参数, 一个关键字参数的字典.

    # url /foo/ 和 /bar/ 除了 使用的模板不同之外, 其他都一样.

    # urls.py
    from django.conf.urls.defaults import *
    from mysite import views

    urlpatterns = patterns('',
        (r'^foo/$', views.foobar_view, {"template_name": "template1.html"}),
        (r'$bar/$', views.foobar_view, {"template_name": "template1.html"}),
    )

    # views.py
    from django.shortcuts import render_to_response
    from mysite.models import MyModel

    def foobar_view(request, template_name):
        m_list = MyModel.objects.filter(is_new=True)
        return render_to_response(template_name, {'m_list': m_list})

伪造捕捉到的 URLconf 值

    # urls.py
    urlpatterns = patterns('',
        (r'^mydata/birthday/$', views.my_view, {'month': 'jan', 'day': '06'}),  # 使用第三参数
        (r'^mydata/(?P<month>\w{3})/(?P<day>\d\d)/$', views.my_view),           # 使用命名组
    )

    # views.py
    def my_view(request, month, day):
        # ....

**当额外参数与正则表达式命名组同时存在的时候, 额外参数具有更高的优先级**

    urlpatterns = patterns('',
        (r'^mydata/(?P<id>\d+)/$', views.my_view, {'id': 3})
    )

#### 5.3 视图函数的缺省参数
    
给视图函数提供默认参数, 这样, 当没有给这个参数赋值的时候, 将会使用默认值.

    # urls.py
    from django.conf.urls.defaults import *
    from mysite import views

    urlpatterns = patterns('',
        (r'^blog/$', views.page),   # 没有参数时, 匹配视图函数的默认值.
        (r'^blog/page(?P<num>\d+/$)', views.page)
    )

    # views.py
    def page(request, num='1'):     # 此处 1 为字符串, 为了和 传入的参数保持一致.
        # ...
        # ...


### 6. URLconf 短路逻辑
    
当两个匹配模式都可以匹配到同一个 URL 时, URLconf 讲采用**自顶向下**的方法顺序解析, 并在匹配过程中采用短路逻辑.

    urlpatterns = patterns('',
        # ...
        ('^auth/user/add/$', views.user_add_stage),
        ('^([^/]+)/([^/]+)/add/$', views.add_stage),
        # ...
    )

### 7. 请求方法与 URL

在解析 URLconf 时 , 请求方法(如 GET, POST, HEAD) 并不会被考虑. 换言之, 对于相同的 URL  的所有请求方法将会被导向到相同的函数中, 因此, 根据请求方法来处理分支是视图函数的责任.

    # views.py
    from django.http import Http404, HttpResponseRedirect
    from django.shortcuts import render_to_response

    def method_splitter(request, GET=None, POST=None):
        if request.method == "GET" and GET is not None:
            return GET(request)
        elif request.method == "POST" and POST is not None:
            returnn POST(request)

        raise Http404

    # 另一种写法, 支持更多的参数
    def method_splitter(request, *args, **kwargs):
        get_view = kwargs.pop("GET", None)
        post_view = kwargs.pop("POST", None)

        if request.method == "GET" and get_view is not None:
            return get_view(request, *args, **kwargs)
        elif request.method == "POST" and post_view is not None:
            return post_view(request, *args, **kwargs)
        raise Http404

    def some_page_get(request):
        assert request.method == "GET"
        do_something_for_get()
        return render_to_response("page.html")

    def some_page_post(request):
        assert request.method == "POST"
        return HttpResponseRedirect("/someurl/")

    # urls.py
    from django.conf.urls.defaults import *
    from mysite import views

    urlpatterns = patterns('',
        # ...
        (r'^somepage/$', views.method_splitter, {"GET": views.some_page_get, "POST": views.some_page_post}),
        # ...
    )


### 8. 包装视图函数
    
假如在不同的视图函数中出现了大量的重复代码, 如下, 每个视图都检查 `return.user` 是否已经认证:

    def my_view1(request):
        if not request.user.is_authenticated():
            return HttpResponseRedirect('/accounts/login/')
        # ...
        return render_to_response('template1.html')

    def my_view2(request):
        if not request.user.is_authenticated():
            return HttpResponseRedirect('/accounts/login/')
        # ...
        return render_to_response('template2.html')

    def my_view3(request):
        if not request.user.is_authenticated():
            return HttpResponseRedirect('/accounts/login/')
        # ...
        return render_to_response('template3.html')

可以通过一个**视图包装**, 来实现去除重复代码:

    def requires_login(view):
        def new_view(request, *args, **kwargs):
            if not request.user.is_authenticated():
                return HttpResponseRedirect("/accounts/login/")
            return view(return, *args, **kwargs)
        return new_view

然后再 URLconf 中实现包装:

    from django.conf.urls.defaults import *
    from mysite.views import requires_login, my_view1, my_view2, my_view3

    urlpatterns = patterns('',
        (r'^view1/$', requires_login(my_view1)),
        (r'^view2/$', requires_login(my_view2)),
        (r'^view3/$', requires_login(my_view3)),
    )

### 9. include
#### 9.1 URLconf 可以包含其他 URconf 模块, 
    
    # urls.py
    from django.conf.urls.defaults import *

    urlpatterns = patterns('',
        (r'^weblog/', include("mysite.blog.urls")),
        (r'^photos/', include("mysite.photos.urls")),
        (r'^about/$', 'mysite.views.about')
    )

    # mysite.blog.urls 
    from django.conf.urls.defaults import *
    urlpatterns = patterns('',
        (r'^(\d\d\d\d)/$', 'mysite.blog.views.year_detail'),
        (r'^(\d\d\d\d)/(\d\d)/$', 'mysite.blog.views.month_detail'),
    )

指向 `include()` 的正则表达式并不包含一个 `$`, 但是包含一个 `/`. 每当 django 遇到 `include()`时, 他将截断匹配的 URL, 并把剩余的字符串发往包含的 URLconf 做进一步处理.

#### 9.2 正则表达式参数与 include() 协作
    
一个被包含的 URLconf 接受任何来自 pattern URLconfs 的被捕获的参数. 这个被捕获的参数总是传递到被包含的 URLconf 中的每一行, 不管这些行对应的视图是否需要这些参数. 因此, 这个技巧, 只有在确定需要那个被传递的参数的时候才显得有用.

    # root urls.py
    from django.conf.urls.defaults import *

    urlpatterns = patterns('',
        (r'^(?P<username>\w+)/blog/', include('foo.urls.blog')),
    )

    # foo/urls/blog.py
    from django.conf.urls.defaults import *

    urlpatterns = patterns('',
        (r'^$', 'foo.views.blog_index'),
        (r'^archive/$', 'foo.views.blog_archive')
    )

#### 9.3 额外参数与 include() 协作 
    
可以传递额外的 URLconf 选项到 include(), 就像可以通过字典传递额外的 URLconf 选项到普通的视图, 当使用该技巧时, 被包含 URLconf 的每一行都会受到那些额外的参数, 无论其是否需要.

    # urls.py
    from django.conf.urls.defaults import *

    urlpatterns = patterns("",
        (r'^blog/', include('inner'), {'blogid': 3}),
    )

    # inner.py

    from django.conf.urls.defaults import *

    urlpatterns = patterns('',
        (r'^archive/$', 'mysite.views.archive'),
        (r'^about/$', 'mysite.views.about'),
        (r'^rss/$', 'mysite.views.rss'),
    )