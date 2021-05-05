---
title: django-模板原理及扩展
date: 2018-03-16 16:48:12
categories:
- Python
tags:
- web development
- django
---
模板可以使用模板标签和模板变量.

1. 模板标签

    模板标签是在一个模板中起作用的标记.
    - 区块标签 '{ % TAG % }'

2. 变量 : 一个在模板里用来输出值的标记
    
    - `{ { TAG } }`

3. context : 是一个传递给模板的名称到值的映射(类似Python字典)

4. 渲染: 通过从 contex 获取值来替换模板中的变量, 并执行所有的模板标签.

## 1. RequestContext 和 Context 处理器
### 1.1 Context
一段解析模板的 context 是 `django.template.Context` 的实例.

### 1.2 RequestContext 
`django.template.RequestContext` 默认在模板 context 中加入一些变量. 如 `HttpRequest`对象或者当前登录用户的相关信息.

创建 RequestContext  和 Context 处理器就是为了解决这个问题. Context 处理器允许设置一些变量, 他们会在每个 context 中自动被设置好, 而不必每次调用 render_to_response() 时都指定. 要点就是, 当你渲染模板时, 使用 RequestContext 而不是 Context . 最直接的做法就是用 context 处理器来创建一些处理器并传递给 RequestContext. 

RequestContext 的第一个参数需要传递一个 HttpRequest 对象，就是传递给视图函数的第一个参数（ request ）. RequestContext 有一个可选的参数 processors ，这是一个包含context处理器函数的列表或者元组.

    # 原始视图: 使用手动载入模板
    from django.template import loader, Context

    def view_1(request):
        # ... 
        t = loader.get_template('template1.html')
        c = Context({
            'app': 'My app',
            'user': request.user,
            'ip_address': request.META["REMOTE_ADDR"],
            'message': "I am view1"
        })
        return t.render(c)

    def view_2(request):
        # ...
        t = loader.get_template('template2.html')
        c = Context({
            'app': 'My app',
            'user': request.user,
            'ip_address': request.META["REMOTE_ADDR"],
            'message': "I am the second view."
        })     

        return t.render(c)

    # 使用处理器: 用 context 处理器创建一些处理器, 并传递给 RequestContext.
    from django.template import loader, RequestContext

    def custom_proc(request):
        "A context processor that provides 'app', 'user', and 'ip_address'"
        return {
            'app': 'My app',
            'user': request.user,
            'ip_address': request.META["REMOTE_ADDR"]
        }

    def view_1(request):
        # ...
        t = loader.get_template('template1.html')
        c = RequestContext(request, {"message": "I am view 1."}, processors=[custom_proc])
        return t.render(c)

    def view_2(request):
        # ...
        t = loader.get_template('template2.html')
        c = RequestContext(request, {"message": "I am the second view."}, processors=[custom_proc])
        return t.render(c)

render_to_response() 可以简化调用 loader.get_template() , 然后创建一个 Context 对象, 最后再调用模板对象的 render() 过程. 使用 render_to_response() 作为 context 的处理器, 就需要使用 `context_instance` 参数.
    
    from django.shortcuts import render_to_response
    from django.template import RequestContext

    def custom_proc(request):
        "A context processor that provides 'app', 'user', and 'ip_address'"

        return {
            'app': "My app",
            'user': request.user,
            'ip_address': request.META["REMOTE_ADDR"]
        }

    def view_1(request):
        # ...
        return render_to_response('template1.html', {'message': 'I am view 1.'}, context_instance=RequestContext(request, processors=[custom_proc]))

    def view_2(request):
        # ...
        return render_to_response('template2.html', {'message': 'I am view 2.'}, context_instance=RequestContext(request, processor=[custom_proc]))

全局 context 处理器支持. `TEMPLATE_CONTEXT_PROCESSORS` 指定了哪些 context processors 总是默认被使用. 这样就省去了每次使用 RequestContext 都指定 processors 的麻烦.
    
    # 默认 TEMPLATE_CONTEXT_PROCESSORS 设置:

    TEMPLATE_CONTEXT_PROCESSORS = (
        'django.core.context_processors.auth',
        'django.core.context_processors.debug',
        'django.core.context_processors.i18n',
        'django.core.context_processors.media',
    )

这个设置项是一个可调用函数的元组, 其中的每个函数使用了和上文中 `custom_proc` 相同的接口, 他们都以 request 对象作为参数, 返回一个会被合并传给 context 的字典: 接受一个 request 对象作为参数, 返回一个包含了将被合并到 context 中的项的字典.

每个处理器竟会按照顺序应用, 也就是说如果在第一个处理器中向 context 添加了一个变量, 而第二个处理器添加了同样名字的变量, 那么第二个将会覆盖第一个.

- `django.core.context_processors.auth`
    
    如果 `TEMPLATE_CONTEXT_PROCESSORS` 包含该处理器, 则每个 RequestContext 将包含这些变量:
    - user: 一个 `django.contrib.auth.models.User` 实例, 描述当前登录用户(或 AnonymousUser )
    - messages: 一个当前登录用户的消息列表(字符串). 在后台对每个请求, 这个变量都调用 `request.user.get_and_delete_messages()` 方法. 这个方法收集用户的消息然后把他们从数据库中删除.
    - perms: `django.core.context_processors.PermWrapper` 实例, 包含了当前登录用户的所有权限.

- `django.core.context_processors.debug`
    
    该处理器把 调试信息发送到模板层. 如果 `TEMPLATE_CONTEXT_PROCESSORS` 包含该处理器, 则每个 RequestContext 将包含这些变量:
    - debug : 设置的 DEBUG 的值(True/False). 可以在模板里调用该变量, 测试是否在 debug 模式.
    - sql_queries : 包含类似于 "{'sql': ..., 'time': ...}" 的字典的一个列表, 记录了该请求期间的每个 SQL 查询以及查询所消耗的时间. 该列表按请求顺序排列.

    该 Context 处理器只有当同时满足一下两个条件时, 才有效:
    - DEBUG : 设置为 True;
    - 请求的 IP 包含在 `INTERNAL_IPS`的设置里面.

    DEBUG 模板变量的值, 永远不可能是 False, 因为如果 DEBUG 是 False, 那么 debug 模板变量一开始就不会被 RequestContext 所包含.

- `django.core.context_processors.i18n'
    如果 `TEMPLATE_CONTEXT_PROCESSORS` 包含该处理器, 则每个 RequestContext 将包含这些变量:
    - LANGUAGES : LANGUAGES 选项的值.
    - LANGUAGE_CODE : 如果 LANGUAGE_CODE存在, 就等于它 , 否则 等同于 LANGUAGE_COde 设置.

- `django.core.context_processors.request'
    
    如果启用这个处理器，每个 RequestContext 将包含变量 request ， 也就是当前的 HttpRequest 对象。 注意这个处理器默认是不启用的，你需要激活它。

        # 在模板中使用
        { { request.REMOTE_ADDR } }

**写 Context 处理器的一些建议**:

1. 使 每个 context 处理器完成尽可能小的功能. 使用多个处理器是很容易的, 所以, 可以根据逻辑块来分解功能以便将来复用.

2. 要注意 `TEMPLATE_CONTEXT_PROCESSORS` 里的 context processor 将会在基于这个 settings.py 的每个模板中有效, 所以变量的命名不要和模板的变量冲突. 变量名是大小写敏感的, 所以 processor 的变量全用大写是个好主意.

3. 不论他们存放在哪个路径下, 只要在 python 的搜索路径中, 就可以在`TEMPLATE_CONTEXT_PROCESSORS`  设置里指向他们. 建议吧他们放在应用或者工程目录下名为 context_processors.py 的文件里.



## 2. 模板加载器
### 2.1 加载模板相关变量

- `TEMPLATE_DIRS` : 模板存放目录
- `TEMPLATE_LOADERS` : 是一个字符串的元组, 其中每个字符都表示一个模板加载器. 这些模板加载器岁 Django 一起发布. **Django按照 TEMPLATE_LOADERS 设置中的顺序使用模板加载器. 它逐个使用每个加载器直到找到一个匹配的模板**

### 2.2 默认加载模板方法

- `django.template.loader.get_template(template_name)`
    
    `get_template` 根据给定的模板名称返回一个已编译的模板(一个 Template对象). 如果模板不存在, 就触发 `TemplateDoesNotExist` 异常.

- `django.template.loader.select_template(template_name_list)`
    
    `select_template` 以模板名称的列表作为参数, 他会返回列表中存在的第一个模板, 如果模板都不存在, 将会触发 `TemplateDoesNotExist` 异常.

### 2.3 其他模板加载器

- `django.template.loader.filesystem.load_template_source`: 
    
    该加载器根据`TEMPLATE_DIRS` 的设置从问加你系统加载模板. 该加载器默认可用.

- `django.template.loaders.app_directories.load_template_source`
    
    该加载器从文件系统上的 Django 应用中加载模板. 对 `INSTALLED_APPS` 中的每个应用, 这个加载器会查找 `templates` 子目录. 如果该目录存在, Django 就在那里寻找模板. 这意味着可以把模板和应用一起保存, 从而使得 Django 应用更容易和默认模板一起发布.

    加载器在首次被导入的时候, 会执行一个优化: 它会缓存一个列表, 这个列表包含了 `INSTALLED_APPS` 中的带有 `templates` 子目录的包.

    该加载器默认启用.

- `django.template.loaders.eggs.load_template_source`
    
    该加载器类似 `app_directories`, 只不过他从 Python eggs 而不是文件系统中加载模板. 这个加载器默认禁用. Python eggs 可以将 Python 代码压缩到一个文件中.

## 3. 扩展模板系统
绝大部分的模板定制是以**自定义标签/过滤器**的方式来完成的.

### 3.1 创建模板库(Django 能够导入的基本结构)

#### 3.1.1 决定模板库应该放在哪个 Django 应用下. 
    
可以将模板库放在某个应用下, 也可以为模板库单独创建一个应用(推荐, filter 可能在后来的工程中有用).

#### 3.1.2 在适当的 Django 应用包里创建一个 `templatetags` 目录.

   该目录应该和 `models.py` , `views.py`等处于同一层次.

#### 3.1.3 在 `templatetags` 中创建两个空文件:

- `__init__`

    一旦创建了 Python 模块, 只需根据要编写过滤器还是标签来响应的编写一些 Python 代码即可.

- 该文件名稍后用来加载标签. 

    如, 自定义标签/过滤器 存放在一个名为 `poll_extras.py` 的文件中. 需要在模板中写入如下内容:

        { % load poll_extras % }

    `{ % load % }` 标签检查 `INSTALL_APPS` 中的设置, 仅允许加载已安装的 Django 应用程序的模板库. 它可以让你在一台电脑上部署很多的模板库的代码, 而不用吧他们暴露给每一个 Django 安装.

对于在 `templatetags` 包中放置多少个模块没有做任何的限制. 需要了解的是: `{ % load % }` 语句时通过指定的 Python 模块名而不是应用名来加载标签/过滤器的.

Django 默认的过滤器和标签源码: `django/template/defaultfilters.py` 和 `django/template/defaulttags.py`


作为合法的标签库, 模块需要包含一个名为 `register` 的模块级变量. 这个变量时 `template.Library` 的实例, 时所有注册标签和过滤器的数据结构.

    from django import template

    register = template.Library()

创建 register 变量后，你就可以使用它来创建模板的过滤器和标签了。

#### 3.1.4 自定义模板过滤器

自定义过滤器上就是有一个或者两个参数的 Python 函数: 输入变量的值, 参数的值(可以是默认值或者留空).

例如, 在过滤器 { { var|foo:"bar" } } 中 ，过滤器 foo 会被传入变量 var 和默认参数 bar。

过滤器函数应该总有返回值. 而且不能触发异常, 他们都应该静静的失败, 如果出现错误, 应该返回一个原始输入或者空字符串, 这回更有意义.

    # 1. 定义过滤器
    def cut(value, args):
        "remove all values of arg from the given string"
        return value.replace(arg, '')
    
    # 使用方法: { { somevariable | cut:" " } }

    def lower(value):
        "Converts a strings into all lovercase"
        return value.lower()

    # 2. 使用 Library 注册过滤器
    register.filter('cut', cut)
    register.filter('lower', lower)

    # Library.filter() 本身需要两个参数: 过滤器名称 和 过滤器函数本身.

    # 使用装饰器的注册过滤器
    
    @register.filter(name='cut')    # name 指定过滤器名称, 不指定为函数名.
    def cut(value, arg):
        return value.replace(arg, '')

    @register.filter
    def lower(value):
        return value.lower()

完成的模板库例子, 包含一个 cut 过滤器:

    from django import template

    register = template.Library()

    @register.filter(name='cut')
    def cut(value, arg):
        return value.replace(arg, '')

#### 3.1.5 自定义模板标签

自定义标签要比过滤器复杂些.

当 Django 编译一个模板时, 它将原始模板分成一个个节点, 每个节点都是 `django.template.Node` 的一个实例, 并且具备 `render()` 方法. 一个已编译的模板就是节点对象的一个列表.

    Hello, { { person.name } }.

    { % ifequal name.birthday today % }
        Happy birthday!
    { % else % }
        Be sure to come back on your birthday
        for a splendid surprise message.
    { % endifequal % }

    被编译的模板表现为节点列表的形式：

    1. 文本节点： "Hello, "

    2. 变量节点： person.name

    3. 文本节点: ".\n\n"

    4. IfEqual节点: name.birthday和today

当调用一个已编译模板的 `render()` 方法时, 模板就会用给定的 context 来调用每个在他的节点列表上的所有节点的 `render()` 方法. 这些渲染的结果合并起来, 形成模板的输出. 因此, 要自定义模板标签, 需要指明原始模板标签如何转换成**节点(编译函数)** 和 节点的 `render()` 方法完成的功能.

`render()` 应当总是返回一个字符串, 即使是空字符串.

##### 3.1.5.1 编写编译函数

当遇到一个模板标签(template tag)时, 模板解析器就会把标签包含的内容, 以及模板解析器自己作为参数调用一个 Python 函数. 这个函数负责返回一个和当前模板标签内容相对应的节点(Node)实例.

使用的标签`<p>The time is { % current_time "%Y-%m-%d %I:%M %p" % }.</p>`

函数的分析器会获取参数并创建一个 Node 对象:

    from django import template

    register = template.Library()

    def do_current_time(parser, token):
        try:
            # split_contents() knows not to split quoted strings.
            tag_name, format_string = token.split_contents()

        except ValueError:
            msg = "%r tag requires a single argument" % token.split_contents()[0]

        return CurrentTimeNode(format_string[1:-1])

- 每个标签编译函数有两个参数: parser 和 token. parser 是模板解析器对象, token 是被解析的语句.
- `token.contents` 是包含有变迁原始内容的字符串. 在本例中为 `current_time "%Y-%m-%d %I:%M %P"`
- `token.split_contents()` 方法按空格拆分参数, 同时保证引号中的字符串不拆分. 应该避免使用, 因为他不够健壮.
- `django.template.TemplateSyntaxError` 异常提供所有语法错误的有用信息.
- `token.split_contents()[0]` 记录标签的名字, 就算标签没有任何参数. 不要把便签名硬编码在错误信息中, 因为这样会把标签名称和函数耦合在一起.
- 函数返回一个`CurrentTimeNode`, 它包含了节点需要知道的关于这个标签的全部信息.
- 模板标签编译函数**必须**返回一个 Node 子类, 返回其他值都是错的.

##### 3.1.5.2 编写模板节点

定义一个拥有 `render()` 方法的 Node 子类. 如上例中的 `CurrentTimeNode`.

两个函数`__init__()` 和 `render()` 与模板处理中的两步(编译与渲染) 直接对应. 这样, 初始化函数仅仅需要存储后要用到的格式字符串, 而 `render()` 函数才做真正的工作.

与模板过滤器一样, 这些渲染函数应该静静的捕获错误, 而不是抛出错误. 模板标签只允许在编译的时候抛出错误.

    import datetime

    class CurrentTimeNode(template.Node):
        def __init__(self, format_string):
            self.format_string  = format_string

        def render(self, context):
            now = datetime.datetime.now()
            return now.strftime(self.format_string)

##### 3.1.5.3 注册标签

只需实例化一个 `template.Library` 实例然后调用它的 `tag(TAG_NAME, TAG_FUNC)` 方法即可.

    # tag()
    register.tag('current_time', do_current_time)

    # 装饰器格式
    @register.tag(name="current_time")
    def do_current_time(parser, token):
        # ...


##### 3.1.5.4 在上下文中设置变量

要在上下文中设置变量, 在 render() 函数的 context 对象上使用字典赋值即可. 

    # 设置上下文变量
    class CurrentTimeNode2(template.Node):
        def __init__(self, format_string):
            self.format_string = format_string

        def render(self, context):
            now = datetime.datetime.now()
            context["current_time"] = now.strftime(self.format_string)
            return ''

    # 在模板中使用标签:
    { % current_time2 "%Y-%m-%d %I:%M %p" % }
    <P>The time is { { current_time } }.</p>

上例中的变量名是硬编码的, 去除硬编码的更简洁的方案如下:

    # 在模板中使用标签
    { % get_current_time "%Y-%M-%d %I:%M %p" as my_current_time % }
    <p>The current time is { { my_current_time } }.</p>

    # 编译函数和 Node 类
    import re

    class CurrentTimeNode3(template.Node):
        def __init__(self, format_string, var_name):
            self.format_string = format_string 
            self.var_name = var_name

        def render(self, context):
            now = datetime.datetime.now()
            context[self.var_name] = now.strftime(self.format_string)
            return ''

    # do_current_time() 把格式字符串和变量名传递给 CurrentTimeNode3
    def do_current_time(parser, token):
        # This version use a regular expression to parser tag contents.
        try:
            # Splitting by None == splitting by spaces.
            tag_name, arg = token.contents.split(None, 1)

        expect ValueError:
            msg = "%r tag requires arguments" $ token.contents[0]
            raise template.TemplateSyntaxError(msg)

        m = re.search(r'(.*?) as (\w+)', arg)
        if m:
            fmt, var_name = m.groups()
        else:
            msg = "%r tag had invalid arguments" % tag_name
            raise template.TemplateSyntaxError(msg)

        if not (fmt[0] == fmt[-1] and fmt[0] in ("'", '"')):
            msg = "%r tag's arguments should be in quotes" % tag_name
            raise template.TemplateSyntaxError(msg)

        return CurrentTimeNode3(fmt[1:-1], var_name)

##### 3.1.5.5 标签对 : 分析直至另一个模板标签

在编译函数中使用 `parser.parser()`

    # 标准的 { % comment % } 标签实现
    def do_comment(parser, token):
        nodelist = parser.parser(('endcommend',))
        parser.delete_first_token()

        return CommentNode()

    class CommentNode(template.Node):
        def render(self, context):
            return ''

`parser.parser()` 接受一个包含了需要分析的模板标签名的元组作为参数. 它返回一个`django.template.NodeList` 实例. 他是一个包含了所有 Node 对象的列表. 这些对象是解析器在解析到任一元组中指定的标签之前遇到的内容.

上面的代码中, `nodelist` 实在 `{ % comment % }` 和 `{ % endcomment % }` 之间所有节点的列表, 不包括 `{ % comment % }` 和 `{ % endcomment % }` 自身.

在 `parser.parser()` 被调用之后, 分析器还没有清除`{ % endcommend % }` 标签, 因此代码需要显式的调用 `parser.delete_first_token()` 来防止该标签被处理两次.

之后 `CommentNode.render()` 只是简单的返回一个空字符串, 在 `{ % comment % }` 和 `{ % endcomment % }` 之间的所有内容被忽略.


修改和利用标签之间的内容:

    # 解析器代码
    def do_upper(parser, token):
        nodelist = parser.parse(('endupper',))
        parser.delete_first_token()
        return UpperNode(nodelist)

    class UpperNode(template.Node):
        def __init__(self, nodelist):
            self.nodelist = nodelist

        def render(self, context):
            # self.nodelist.render(context) 对节点列表中的每个 Node 简单的调用 render()
            output = self.nodelist.render(context)
            return output.upper()

    # 在模板中使用:
    { % upper % }
        This will appear in uppercase, { { user_name } }
    { % endupper % }

##### 3.1.5.6 简单标签的快捷方式: django.template.Library.simple_tag()

许多模板标签接受单一的字符串参数或者一个模板变量引用, 然后独立的根据输入变量和一些其他外部信息进行处理并返回一个字符串. 

为了简化这类标签, Django 提供了一个帮助函数`simple_tag()`. 该函数是 `django.template.Library` 的一个方法. 它接受一个**只有一个参数**的函数作为参数. 把他包装在 render函数 和之前提及过的其他的必要单位中, 然后通过模板系统注册标签.

    # 解析器代码
    def current_time(format_string):
        try:
            return datetime.datetiem.now().strftime(str(format_string))
        except UnicodeEncodeError:
            return ''

    register.simple_tag(current_time)

    # 装饰器实现代码
    @register.simple_tag
    def current_time(token):
        # ...

`simple_tag()` 函数注意事项:
- 传递给该函数的只有**单个** 参数
- 在函数被调用的时候, 检查必需参数个数的工作已经完成.
- 参数两边的引号(如果有的话), 已经被截掉, 所有函数接收到一个普通 Unicode 字符串.

##### 3.1.5.7 包含标签: 通过渲染其他模板显示数据.

实现结果:

    # 在模板中调用
    { % books_for_author author % }

    # 输出结构:
    <ul>
        <li>The Cat in Hat</li>
        <li>Hop On Pop</li>
        <li>Green Eggs And Ham</li>
    </ul>

实现过程:
    # 1. 定义函数, 通过给定的参数生成一个字典形式的结果. 只需返回字典类型的结果就行, 无需返回更复杂的东西.
    def books_for_author(author):
        books = Book.objects.filter(authors_id=author.id)
        return {'books': books}

    # 2. 创建用于渲染的模板: 
    <ul>
    { % for book in books % }
        <li> { { book.title } } </li>
    { % endfor % }
    </ul>

    # 3. 通过 Library 对象使用 inclusion_tag() 方法来创建并注册这个包含标签.
    
    register.inclusion_tag('book_snippet.html')(books_for_author)

    @register.inclusion_tag('book_snippet.html')
    def books_for_author(author):
        # ...

Django 为包含标签提供了一个`takes_context` 选项, 用于在包含标签中访问父模板的 context. 如果在创建模板标签时, 指明了这个选项, 这个标签就不需要参数, 并且下面的 Python 函数会带一个参数: 就是当这个标签被调用时的模板 context.

    # 一个包含标签, 该标签包含有指向主页的 home_link 和 home_title 变量.
    @register.inclusion_tag('link.html', tokes_context=True)
    def jump_link(context):
        return {
            'link': context['home_link'],
            'title': context['home_title']
        }
    
    # link.html
    Jump directly to <a href="{ { link } }"> { { title } } </a>

    # 使用自定义标签时, 就可以加载它的库, 然后不带参数的调用它.
    { % jump_link % }


## 4. 编写自定义模板加载器
模板加载器, 也就是`TEMPLATE_LOADERS` 中的每一项, 都有要能被下面这个接口调用:
    
    load_template_source(template_name, template_dirs=None)
    template_name : 所加载模板的名称.
    template_dirs : 一个可选的代替 TEMPLATE_DIRS 的搜索目录列表.

如果加载器能够成功加载一个模板, 他应当返回一个元组`(template_source, template_path)`. `template_source` 就是将被模板引擎编译的模板字符串; `template_path` 是被加载的模板的路径.

如果加载器加载模板失败, 那么就会触发 `django.template.TemplateDoesNotExist` 异常.

每个加载函数都应该有一个 `is_usable` 的函数属性. 这个属性是一个布尔值, 用于告知模板引擎, 这个加载器是否在当前安装的 Python 中可用. 

编写自定义模板加载器分两步:
1. 编写模板加载器代码
2. 将模板加载器名称加入到 `TEMPLATE_LOADERS`


示例: 一个可以从 ZIP 文件中加载模板的模板加载函数. 他使用了自定义的设置 `TEMPLATE_ZIP_FILES` 来取代 `TEMPLATE_DIRS` 用做查找路径, 并且他假设在此路径上的每一个文件都是包含模板的 ZIP 文件.
    
    from django.conf import settings
    from django.template import TemplateDoesNotExist
    import zipfile

    def load_template_source(template_name, template_dirs=None):
        "Template loader that load templates from a ZIP file."

        template_zipfiles = getattr(settings, "TEMPLATE_ZIP_FILES", [])

        # Try each ZIP file in TEMPLATE_ZIP_FILES .
        for fname in template_zipfiles:
            try:
                z = zipfile.ZipFile(fname)
                source = z.read(template_name)
            except (IOError, KeyError):
                continue

            z.close()

            # We found a tmeplate , so return the source.
            template_path = "%s:%s" % (fname, template_name)

            return (source, template_path)

        # If we reach here, the template couldn't be loaded
        raise TemplateDoesNotExist(template_name)

    # This loadder is always usable (since zipfile is included with Python)
    load_template_source.is_usable = True

    # 还需要将上面的代码, 加入到 TEMPLATE_LOADERS 中.
    # 如果代码放在 mysite.zip_loader 的包中, 那么我们要把 mysite.zip_loader.load_template_source 加入到 TEMPLATE_LOADERS 中.