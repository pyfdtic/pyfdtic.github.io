---
title: django之二--模板篇
date: 2018-03-16 17:01:22
categories:
- Python
tags:
- web development
- django
---
## 一. 概述
模板系统是一个 Python 库, 你可以在任何地方使用它, 而不仅仅是在Django 的视图中.

**模板**是一个文本, 用于分离文档的表现形式和内容. 模板定义了占位符以及各种用于规范文档如何显示的各部分基本逻辑(模板标签). 模板通常用于产生 HTML, 但是 Django 的模板也能产生任何基于文本格式的文档.


在 Python 代码中**使用 Django 模板的最基本方式**: 写模板 --> 创建 Template 对象 --> 创建 Context --> 调用 render() 方法.
1. 使用原始的**模板代码字符串**创建一个`Template`对象, Django 同样支持用指定**模板文件路径**的方式来创建 Template 对象.
2. 调用模板对象的 `render` 方法, 并且传入一套变量 `context`, 它将返回一个基于模板的展现字符串, 模板中的变量和标签会被 `context` 值替换.

        $ python manage.py shell    
        >> from django import template

        # 当创建一个 Template 对象, 模板系统在内部编译这个模板到内部格式, 并做优化, 做好渲染准备.
        >> t = template.Template("My name is { { name } }")
        
        # 使用 context 来传递数据, 一个 context 是一系列变量和值的结合.
        # context 在 Django 里表现为 Context 类, 在 django.Template 模块里. 他的构造函数有一个可选参数: 一个字典映射变量和他的值.
        >> c = template.Context({"name":"tom"})
        
        # 调用 Template.render() 方法并传递 context 的值来填充模板.
        # t.render(c) 返回的值是一个 Unicode 对象, 不是普通的 Python 字符串.
        >> print t.render(c)
        My name is tom


`python manage.py shell` : 在启动解释器之前,它告诉Django 使用哪个设置文件. Django 框架大部分子系统, 包括模板系统, 都依赖于配置文件; 如果 Django 不知道使用哪个配置文件, 这些系统将不能工作. Django 搜索 `DJANGO_SETTINGS_MODULE` 环境变量, 它被设置在 settings.py 文件中. 执行命令 `python manage.py shell` , 他将自动帮你处理 `DJANGO_SETTINGS_MODULE` 环境变量.

Django 模板解析非常快捷. 大部分的解析工作都是在后台通过对简短正则表达式一次性调用来完成.


## 二. 变量
`{ { VAR } }` : 变量的值将在页面渲染的时候, 被取代.

默认情况下, 如果一个**变量不存在**, 模板系统会把他展示位一个**空字符串**, 不做任何事情来表示失败.

## 三. 模板中的复杂数据类型

在 Django 模板中遍历复杂数据结构的关键是 **句点字符(.) **.

**句点查找规则** : 字典>属性>方法>索引 和 短路逻辑(系统使用找到的第一个有效类型)

1. 字典类型查找, 如 `foo["bar"]`
2. 属性查找, 如 `foo.bar`
3. 方法调用, 如 `foo.bar()`
4. 列表类型索引查找, 如 `foo[1]`

- **列表索引**
    
    **不允许使用负数列表索引**

        >>> from django.template import Template, Context
        >>> t = Template('Item 2 is { { items.2 } }.')
        >>> c = Context({'items': ['apples', 'bananas', 'carrots']})
        >>> t.render(c)
        u'Item 2 is carrots.'

- **字典**

        >>> from django.template import Template, Context
        >>> person = {'name': 'Sally', 'age': '43'}
        >>> t = Template('{ { person.name } } is { { person.age } } years old.')
        >>> c = Context({'person': person})
        >>> t.render(c)
        u'Sally is 43 years old.'

- **属性**

        >>> from django.template import Template, Context
        >>> import datetime
        >>> d = datetime.date(1993, 5, 2)
        >>> d.year
        1993
        >>> d.month
        5
        >>> d.day
        2
        >>> t = Template('The month is { { date.month } } and the year is { { date.year } }.')
        >>> c = Context({'date': d})
        >>> t.render(c)
        u'The month is 5 and the year is 1993.'

    使用自定义的类, 如下方法使用与任意的对象.

        >>> from django.template import Template, Context
        >>> class Person(object):
        ...     def __init__(self, first_name, last_name):
        ...         self.first_name, self.last_name = first_name, last_name
        >>> t = Template('Hello, { { person.first_name } } { { person.last_name } }.')
        >>> c = Context({'person': Person('John', 'Smith')})
        >>> t.render(c)
        u'Hello, John Smith.'    
- **方法**
    
    在调用方法时, 并**没有**使用**圆括号**, 你只能调用不需要参数的方法.

        >>> from django.template import Template, Context
        >>> t = Template('{ { var } } -- { { var.upper } } -- { { var.isdigit } }')
        >>> t.render(Context({'var': 'hello'}))
        u'hello -- HELLO -- False'
        >>> t.render(Context({'var': '123'}))
        u'123 -- 123 -- True'

    在方法查找过程中, 如果某方法抛出一个异常, 除非该异常有一个 `silent_variable_failure=True` 设置, 否则的话他将被传播. 如果异常被被传播, 模板里的指定变量会被设置为空字符串.

        >>> t = Template("My name is { { person.first_name } }.")
        >>> class PersonClass3:
        ...     def first_name(self):
        ...         raise AssertionError, "foo"
        >>> p = PersonClass3()
        >>> t.render(Context({"person": p}))
        Traceback (most recent call last):
        ...
        AssertionError: foo

        >>> class SilentAssertionError(AssertionError):
        ...     silent_variable_failure = True
        >>> class PersonClass4:
        ...     def first_name(self):
        ...         raise SilentAssertionError
        >>> p = PersonClass4()
        >>> t.render(Context({"person": p}))
        u'My name is .'    

- **深层嵌套**

    在下面这个例子中 `{ {person.name.upper} }` 会转换成字典类型查找（ `person['name']` ) 然后是方法调用（ `upper()` ):

        >>> from django.template import Template, Context
        >>> person = {'name': 'Sally', 'age': '43'}
        >>> t = Template('{ { person.name.upper } } is { { person.age } } years old.')
        >>> c = Context({'person': person})
        >>> t.render(c)
        u'SALLY is 43 years old.'

**`context`对象** : 可以通过传递一个完全填充(full populater)的字典给 Context() 来初始化上下文(context). 初始化之后, 可以使用标准的 Python 字典语法给 context 对象添加或删除条目.

    >>> from django.template import Context
    >>> c = Context({"foo": "bar"})
    >>> c['foo']
    'bar'
    >>> del c['foo']
    >>> c['foo']
    Traceback (most recent call last):
      ...
    KeyError: 'foo'
    >>> c['newvariable'] = 'hello'
    >>> c['newvariable']
    'hello'

## 四. 标签
1. `if/else`

        { % if today_is_weekend % }
            <p>Welcome to the weekend!</p>
        { % else % }
            <p>Get back to work.</p>
        { % endif % }

    在 Python 和 Django 模板系统中, 以下这些对象相当于布尔值的 False.
    - 空列表 : `[]`
    - 空元组 : `()`
    - 空字典 : `{}`
    - 空字符串 : `''`
    - 零值 : `0`
    - 特殊对象 : `None`
    - 对象 : `False`

    `{ % if % }` 标签接受 `and`,`or`,`not` 关键字来对多个变量做判断. 但是, 不允许在同一个标签里同时使用 `and` 和 `or`, 因为逻辑上可能是模糊的.

        { % if athlete_list and coach_list % }
            Both athletes and coaches are available.
        { % endif % }

        { % if not athlete_list % }
            There are no athletes.
        { % endif % }

        { % if athlete_list or coach_list % }
            There are some athletes or some coaches.
        { % endif % }

        { % if not athlete_list or coach_list % }
            There are no athletes or there are some coaches.
        { % endif % }

        { % if athlete_list and not coach_list % }
            There are some athletes and absolutely no coaches.
        { % endif % }    

    一定要使用`{ % endif % }` 来关闭每一个 `{ % if % }` 标签.

2. `for`, 关键字 `reversed` 可实现反向迭代.
    
        { % for athlete in athlete_list reversed % }
        ...
        { % endfor % }

    `{ % empty % }` 分句 : 通过该标签, 可以定义当列表为空时输出内容.

        { % for athlete in athlete_list % }
            <p>{ { athlete.name } }</p>
        { % empty % }
            <p>There are no athletes. Only computer programmers.</p>
        { % endfor % }

        # 与上面等价
        { % if athlete_list % }
            { % for athlete in athlete_list % }
                <p>{ { athlete.name } }</p>
            { % endfor % }
        { % else % }
            <p>There are no athletes. Only computer programmers.</p>
        { % endif % }        

    `forloop` 模板变量 : 提供一些提示循环进度信息的属性. **仅能在循环中使用**
    - `forloop.counter` : 表示当前循环的执行次数的整数计数器. 计数器从 1 开始技术.
    - `forloop.counter0` : 同上, 但计数器从 0 开始.
    - `forloop.revcounter` : 表示循环中剩余项的整型变量. 初始值为 序列中项的总数, 最后一次循环执行中, 这个变量为 1.
    - `forloop.revcounter0` : 同上, 但是从 0 计数.
    - `forloop.first` : **布尔值**, 如果该迭代的第一个执行, 则为 True.
    - `forloop.last` : **布尔值**, 在最后一个执行循环时被置为 True.

            { % for link in links % }{ { link } }{ % if not forloop.last % } | { % endif % }{ % endfor % }
            # 输出 : Link1 | Link2 | Link3 | Link4

            { % for p in places % }{ { p } }{ % if not forloop.last % }, { % endif % }{ % endfor % }
            # 输出 : Link1 , Link2 , Link3 , Link4

    - `forloop.parentloop` : 一个指向当前循环的上一级循环的 forloop 对象的引用(在嵌套情况下).

            { % for country in countries % }
                <table>
                { % for city in country.city_list % }
                    <tr>
                    <td>Country #{ { forloop.parentloop.counter } }</td>
                    <td>City #{ { forloop.counter } }</td>
                    <td>{ { city } }</td>
                    </tr>
                { % endfor % }
                </table>
            { % endfor % }    

    Context 和 forloop 变量 : 在一个 `{ % for % }` 块中, 已存在的变量会被移除, 以避免 `forloop` 变量被覆盖. Django 会把这个变量移动到 `forloop.parentloop` 中. 通常我们不用担心这个问题, 但是一旦我们在模板中定义了 `forloop` 这个变量(不推荐这样做), 在 `{ % for % }` 块中他会在 `forloop.parentloop` 被重新命名.

3. `ifequal/ifnotequal` : `{ % ifequal % }` 标签比较两个值, 当他们相等时, 显示在 `{ % ifequal % }` 和 `{ % ifnotequal % }`之中的所有的值.
        
        # 比较两个变量 user, currentuser
        { % ifequal user currentuser % }
            <h1>Welcome!</h1>
        { % endifequal % }        

        # 参数可以是硬编码的字符串
        { % ifequal section 'sitenews' % }
            <h1>Site News</h1>
        { % endifequal % }

        # 支持可选的 { % else % } 标签
        { % ifequal section 'sitenews' % }
            <h1>Site News</h1>
        { % else % }
            <h1>No News Here</h1>
        { % endifequal % }

    只有**模板变量**, **字符串**, **整数**, **小数**可以作为 `{ % ifequal % }` 标签的参数. 其他任何类型, 均不能用在 `{ % ifequal % }` 中.

## 五. 注释: 
- **单行注释** : `{# ... #}`

        {# This is a comment #}

- **多行注释** : `{ % comment % }`

        { % comment % }
        This is a
        multi-line comment.
        { % endcomment % }

## 六. 过滤器 : `|`

过滤器主要是**转换变量输出格式**.

过滤器可以**嵌套**(一个过滤器管道的输出, 可以作为另一个管道的输入).

    { { my_list|first|upper } }   # 寻找列表的第一个元素, 并将其转换为大写.

有些过滤器有参数:
    
    { { bio|truncatewords:"30" } }

**常用过滤器**:
- `addslashes` : 添加反斜杠到任何反斜杠, 单引号, 或者双引号前面. 处理包含 JavaScript 的文本时非常有用.
- `date` : 按指定的格式字符串参数化格式 date 或者 datetime 对象.

        { { pub_date|date:"F j, Y" } }
- `length` : 返回变量的长度. 对于列表或字符串, 则返回其元素或字符的个数.

## 七. 模板加载与模板目录: { % include % }
`django.template.loader.get_template()` 函数手动从文件系统加载模板, 该函数以模板名称为参数, 在文件系统中找出模块的位置, 打开文件并返回一个编译好的 Template 对象.

    $ mkdir templates
    $ vim settings.py
        TEMPLATES = [
            {
                # ...
                'DIRS': [os.path.join(os.path.dirname(__file__), 'templates'),],
                # ...
            },
        ]    

    $ vim views.py
        from django.http import HttpResponse, Http404
        from django.template import Context
        from django.template.loader import get_template

        import datetime

        def current_datetime(request):
            now=datetime.datetime.now()
            t = get_template('time.html')
            html = t.render(Context({'current_date': now}))
            return HttpResponse(html)    

`django.shortcuts.render_to_response()` 一次性加载某个模板, 并一次作为 HttpResponse 对象返回. `render_to_response()` 的第一个参数必须是要使用的模板名称, 如果给定第二个参数, 那么该参数必须是为该模板创建 Context 使用的字典. 如果不使用第二个参数, render_to_response() 使用一个空字典.

    from django.shortcuts import render_to_response
    import datetime

    def current_datetime(request):
        now = datetime.datetime.now()
        return render_to_response('current_datetime.html', {'current_date': now})

**模板子目录**: 把模板放在模板目录的子目录中.
    
    t = get_template('dateapp/current_datetime.html')

    return render_to_response('dateapp/current_datetime.html', {'current_date': now})

**include 模板标签**
` { % include % } ` 允许在(模板中)包含其他的模板的内容. 标签的参数是所要包含的模板名称, 可以是一个变量, 也可以是硬编码的字符串路径. 和 `get_template()` 中的一样, 对模板的文件名进行判断时会在所调取的模板名称之前加上来自`TEMPLATE_DIRS`的模板目录.
    
    { % include 'includes/nav.html' % }

    { % include template_name % }

如果你用一个包含 `current_section` 的上下文去渲染 `mypage.html` 这个模板文件, 这个变量将存在于它所 include 的模板里.

    # mypage.html

    <html>
    <body>
    { % include "includes/nav.html" % }
    <h1>{ { title } }</h1>
    </body>
    </html>

    # includes/nav.html

    <div id="nav">
        You are in: { { current_section } }
    </div>

如果`{ % include % }`标签指定的模板没有找到, Django 的处理方式如下:
- 如果 `DEBUG=True`, 将会在 Django 错误信息页面看到 `TemplateDoesNotExist` 异常.
- 如果 `DEBUG=False`, 该标签不会引发错误信息.

## 八. 模板继承 : { % extends % }
basic.html
    
    <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN">
    <html lang="en">
    <head>
        <title>{ % block title % }{ % endblock % }</title>
    </head>
    <body>
        <h1>My helpful timestamp site</h1>
        { % block content % }{ % endblock % }
        { % block footer % }
        <hr>
        <p>Thanks for visiting my site.</p>
        { % endblock % }
    </body>
    </html>

继承:
    
    # current_datetime.html

    { % extends "base.html" % }

    { % block title % }The current time{ % endblock % }

    { % block content % }
    <p>It is now { { current_date } }.</p>
    { % endblock % }

使用模板继承**注意事项**:
- 如果在模板中使用 `{ % extends % }` 必须保证其为模板中的**第一个模板标记**. 否则, 模板继承将不起作用.
- 一般来讲, 基础模板中的 `{ % block % }` 标签越多越好. 子模板不必定义父模板中所有的代码块, 因此你可以用合理的缺省值对一些代码进行填充, 然后只对子模板所需的代码进行重定义.
- 如果发现自己在多个模板之间拷贝代码, 应该考虑将代码段放置到父模板中的某个 `{ % block % }`中.
- 如果需要访问父模板的块中的内容, 请使用 `{ { block.super } }`, 该变量会展现出父模板中的内容. 如果只想在上级代码块基础上添加内容, 而不是全部重载, 应该使用该标签.
- 不允许在同一个模板中, 定义多个同名的 { % block % } . 存在这样的限制, 是因为 block 标签的工作方式是双向的.
- `{ % extends % }` 对所传入模板名称使用的加载方法和 get_template() 相同.
- `{ % extends % }` 的参数可以是字符串, 也可以是变量.

## 九. html 转义
### 1.1 自动转义默认开启
- `>` --> `&lt;`
- `<` --> `&gt;`
- `'` (单引号) --> `&#39;`
- `"` (双引号) --> `&quot;`
- `&` --> `&amp;`

### 1.2 关闭自动转义

可以基于站点级别, 模板级别或者变量级别来关闭自动转义

#### 1.2.1 变量级别 : 使用 `safe` 过滤器.
    
    This will not be escaped: { { data|safe } }

#### 1.2.2 模板级别 : 用标签 `autoescape` 来包装这个模板或模板中的部分.
autoescape 标签有两个参数on和off 有时,你可能想阻止一部分自动转意,对另一部分自动转意。
    { % autoescape off % }
        Hello { { name } }
    { % endautoescape % }

    Auto-escaping is on by default. Hello { { name } }

    { % autoescape off % }
        This will not be auto-escaped: { { data } }.

        Nor this: { { other_data } }
        { % autoescape on % }
            Auto-escaping applies again: { { name } }
        { % endautoescape % }
    { % endautoescape % }

#### 1.2.3 过滤器参数中的字符串常量的自动转义.
所有字符常量没有经过转义就被插入模板,就如同它们都经过了safe过滤。 这是由于字符常量完全由模板作者决定,因此编写模板的时候他们会确保文本的正确性。
    
    # good
    { { data|default:"3 &lt; 2" } }

    # bad
    { { data|default:"3 < 2" } }