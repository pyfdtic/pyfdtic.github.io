---
title: django之三--模型篇
date: 2018-03-16 17:00:02
categories:
- Python
tags:
- web development
- django
---
## 1. MTV
Django 的 MVC 含义:
- M , 数据存取部分, 有 Django 数据库层处理.
- V, 选择显示哪些要显示以及怎样显示的部分, 由视图和模板处理;
- C, 根据用户输入委派视图的部分, 有 django 框架根据 URLconf 设置, 对给定 URL 调用适当的 Python 函数.

由于 C 由框架自行处理, 而 Django 里更关注的是模型(Model), 模板(Template), 视图(view), Django 也被称为 MTV 框架.
- M : 代表模型(Model), 即数据存取层. 该层处理与数据相关的所有事务: 如何存取, 如何验证有效性, 包含哪些行为以及数据之间的关系灯.
- T : 代表模板(Template). 表现层, 该层处理与表现相关的决定: 如何在页面或其他类型文档中显示.
- V : 代表视图(View). 即业务逻辑. 该层包含存取模型及调用恰当模板的相关逻辑. 可以视作 模型与模板之间的桥梁.

## 2. 数据库配置
- DATABASE_ENGINE = '[postgresql_psycopg2|mysql|sqlite3|oracle]'
- DATABASE_NAME = ''
- DATABASE_USER = ''
- DATABASE_PASSWORD = ''
- DATABASE_HOST = ''
- DATABASE_PORT = ''


**测试数据库配置**

    >>> from django.db import connection
    >>> cursor = connection.cursor()

## 3. django models & app : 
**app** 一个包含模型,视图和 django 代码, 并且形式为独立的 Python 包的完整 Django 应用.

project 和 app 区别: 一个是配置, 一个是代码;
- 一个 project 包含许多个 django app 以及对他们的配置
- 技术上, project 的作用是提供配置文件.
- 一个 app 是一套 Django 功能的集合, 通常包含模型和视图, 按 Python 的包结构的方式存在.
- Django 本身内建一些 app, 例如注释系统和自动管理界面, app 的一个关键点是他们很容易移植到其他 project 和 被多个 project 复用.
- 系统对 app  有一个约定: **如果使用了 django 的数据库层(模型), 就必须创建一个 django app. 模型必须放在 apps 中**. 

Django 模型使用 Python 代码形式表述的数据在数据库中的定义.对数据库层来说他等同于 `CREATE TABLE` 语句, 只不过执行的是 python 代码而不是 SQL, 而且还包含了比数据字段定义更多的含义. Django 用模型在后台执行 SQL 代码并把结果用 Python 的数据结构来描述. Django 也是用模型来呈现 SQL 无法处理的高级概念.

**Django 提供了使用工具来从现有的数据库表中自动扫描生成模型.这对已有的数据库来说是非常快捷有用的**

    $ cd mysite
    $ python manage.py startapp books   # 创建 app
    $ cd books 
    $ vim models.py

        class Publisher(models.Model):
            name = models.CharField(max_length=30)
            address = models.CharField(max_length=35)
            city = models.CharField(max_length=60)
            state_province = models.CharField(max_length=30)
            country = models.CharField(max_length=50)
            website = models.URLField()

            # 添加模块的字符串表现. 返回一个unicode对象.
            def __unicode__(self):
                return self.name

            # 指定缺省排序方式.附录B 中有 Meta 中所有可选项的完整参考
            class Meta:
                ordering = ['name']

        class Author(models.Model):
            first_name = models.CharField(max_length=30)
            last_name = models.CharField(max_length=40)
            email = models.EmailField()

            # 添加模块的字符串表现. 返回一个unicode对象.
            def __unicode__(self):
                return u'%s %s' % (self.first_name, self.last_name)

        class Book(models.Model):
            title = models.CharField(max_length=100)
            authors = models.ManyToManyField(Author)
            publisher = models.ForeignKey(Publisher)
            publication_date = models.DateField()    

            # 添加模块的字符串表现. 返回一个unicode对象.
            def __unicode__(self):
                return self.title

每个数据模型都是 `django.db.models.Model` 的子类. 它的父类 Model 包含了所有必要的和数据库交互的方法, 并提供了一个简洁的定义数据库字段的方法.

每个模型相当于单个数据库表, 每个属性也是这个表中的一个字段. 属性名就是字段名, 它的类型相当于数据库的字段类型.

**每个数据库表对应一个类**, 这条规则的例外情况是多对多关系. 如上示例中, Book 有一个多对多字段叫做 authors. 该字段表明一本书籍有一个或多个作者, 但 Book 数据表并没有 authors 字段. 相反, Django 创建了一个额外的表(多对多链接表)来处理书籍和作者之间的映射关系.

**主键**: 除非单独指明, 否则 Django 会自动为每个模型生成一个自增长的整数主键字段, 每个 Django 模型都要求有单独的主键, id.

## 4. 模型安装与基本使用
### 4.1. 在 Django 项目中激活这些模型: 将 books app 添加到配置文件的已安装应用列表中即可.
    
    $ vim settings.py
        MIDDLEWARE_CLASSES = (
            # 'django.middleware.common.CommonMiddleware',
            # 'django.contrib.sessions.middleware.SessionMiddleware',
            # 'django.contrib.auth.middleware.AuthenticationMiddleware',
        )

        INSTALLED_APPS = (
            # 'django.contrib.auth',
            # 'django.contrib.contenttypes',
            # 'django.contrib.sessions',
            # 'django.contrib.sites',
            'mysite.books',
        )    

### 4.2. 验证模型的有效性

    # 检查模型的语法和逻辑是否正确.
    $ python manage.py validate 

### 4.3. 生成数据库
    
    $ python manage.py sqlall books     # 该命令只是打印创建数据库的sql语句.
    $ python manage.py syncdb           # 同步数据模型到数据库. 如果表不存在,则会创建表. 但 syncdb 不能讲模型的修改或删除同步到数据库.如果修改或删除了一个模型, 并向把他提交到数据库, syncdb 不会做任何处理.

- 生成的表名为 **app名称和模型的小写名称**, 如 books_authors.
- 每个表自动添加 id 主键
- Django 添加 `_id` 后缀到外键字段名.
- `syncdb` 是幂等的, 他不会重复执行 SQL 语句.
- 可以使用 `python manage.py dbshell` 作为数据库客户端连接到数据库查看.

### 4.4. 基本数据访问

    >>> from books.models import Publisher

    # 创建对象与保存对象到数据库.
    >>> p1 = Publisher(name='Apress', address='2855 Telegraph Avenue',
    ...     city='Berkeley', state_province='CA', country='U.S.A.',
    ...     website='http://www.apress.com/')
    >>> p1.save()

    >>> p2 = Publisher(name="O'Reilly", address='10 Fawcett St.',
    ...     city='Cambridge', state_province='MA', country='U.S.A.',
    ...     website='http://www.oreilly.com/')
    >>> p2.save()

    >>> publisher_list = Publisher.objects.all()
    >>> publisher_list
    [<Publisher: Publisher object>, <Publisher: Publisher object>]

    # 一次性完成对象的创建与存储
    >>> p1 = Publisher.objects.create(name='Apress',
    ...     address='2855 Telegraph Avenue',
    ...     city='Berkeley', state_province='CA', country='U.S.A.',
    ...     website='http://www.apress.com/')        

- `p.save()`
- `Publisher.objects.all()`

    - `objects` 属性, 被称为**管理器**, 他管理者所有针对**数据包含, 及数据查询的表格级操作**.
    - `all()` : 返回数据库中所有的记录, 他是一个 **QuerySet** 对象, 是数据库中一些记录的集合.
- `Publisher.objects.filter(name="Apress"[, country="U.S.A."])` : 过滤器.

    和 Python 一样, Django 使用**双下划线**来表明会进行一些**魔法操作**:
    - `contains` : 被翻译成 `LIKE` 语句.

            >> Publisher.objects.fileer(name__contains="press")
    - `icontains` : 大小写无关的 `LIKE` 语句.
    - `startswith` : 
    - `endswith` : 
    - `range` : SQL `BETWEEN` 查询.
- `Publisher.objects.get(name="Apress")` : 获取单个对象. 如果结果是多个对象, 会抛出异常. 没有返回结果也抛出异常.
- `Publisher.objects.order_by("[-]name"[, "address"])` : 数据排序. 减号表示逆序.
- 限制返回的数据 : `Publisher.objects.order_by('name')[0:2]`, 不支持负索引.
- 链式查询: `Publisher.objects.filter(country="U.S.A.").order_by("-name")`
- 更改某一指定的列 : ` Publisher.objects.filter(id=52).update(name='Apress Publishing')`, update()方法对于任何结果集（QuerySet）均有效，这意味着你可以**同时更新多条记录**。
- 删除对象:
    - 调用对象的 `delete` 方法:

            > p = Publisher.objects.get(name="O'Reilly")
            > p.delete()
    - 只删除部分数据

            > Publisher.objects.filter(country='USA').delete()

    - 删除某表内的所有数据:

            > Publisher.objects.all().delete()  # 必须显示调用 all() 方法.

## 补充: 数据模型:
    
    from django.db import models

    class Publisher(models.Model):
        name = models.CharField(max_length=30)
        address = models.CharField(max_length=50)
        city = models.CharField(max_length=60)
        state_province = models.CharField(max_length=30)
        country = models.CharField(max_length=50)
        website = models.URLField()

        def __unicode__(self):
            return self.name

    class Author(models.Model):
        first_name = models.CharField(max_length=30)
        last_name = models.CharField(max_length=40)
        email = models.EmailField()

        def __unicode__(self):
            return u"%s %s" % (self.first_name, self.last_name)

    class Book(models.Model):
        title = models.CharField(max_length=100)
        authors = models.ManyToManyField(Author)
        publiser = models.ForeignKey(Publisher)
        publication_date = models.DateFie()

        def __unicode__(self):
            return self.title

## 5. 外键与多对多关系
### 5.1 外键
#### 5.1.1 从多的一端查询一, 返回相关的数据模型对象.

    >> b = Book.objects.get(id=50)
    >> b.publisher
    <Publisher: Apress Publisheing>
    >> b.publisher.website
    u"http://www.appress.com/"

#### 5.1.2 从一的一端查询多, 需要使用 QuerySet 对象
    
    >> p = Publisher.objects.get(name="Apress Publishing")
    >> p.book_set.all()
    [<Book: The Django Book>, <Book: Dive Into Python>, ...]

`boot_set` 只是一个 `QuerySet`, 他可以实现数据的过滤分切.

    >> p = Publisher.objects.gte(name="Apress Publisher")
    >> p.book_set.filter(name__icontains="django")
    [<Book: The Django Book>, <Book: Pro Django>]

属性名称 `book_set` 是由模型名称的小写(肉 book)加 `_set` 组成的.

### 5.2 多对多关系

多对多关系和外键工作方式相同, 只不过处理的是`QuerySet`而不是模型实例.

    # 查看书籍作者.
    >> b = Book.objects.get(id=50)
    >> b.authors.all()
    [<Author: Adrian Holovaty>, <Author: Jacob Kaplan-Moss>]
    >> b.authors.filter(first_name="Adrian")
    [<Author: Adrian Holovaty>]

    # 查看一个作者的所有书籍, 使用 author.book_set
    >> a = Author.objects.get(first_name="Adrian", last_name='Holovaty')
    >> a.book_set.all()
    [<Book: The Django Book>, <Book: Adrian's Other Book>]

## 6. 更改数据库模式( Database Schema)
`syncdb` 仅仅创建数据库里还没有的表, 他并不对数据模型的修改进行同步, 也不处理数据模型的删除. 当新增或者修改数据模型里的字段, 或者删除了一个数据模型, 需要手动在数据库中做相应的修改.

当处理模型修改的时候, Django 的数据库层的工作流程:

- 如果模型包含一个未曾在数据库里建立的字段, Django 会报错. 当第一次用 Django 的数据库 API 请求表中不存在的字段时会导致报错(在运行时报错).
- Django 并不关心数据库表中是否存在未在模型中定义的列.
- Django 并不关系数据库中是否存在未被模型表示的表格.

改变模型的模式架构意味着需要按照顺序更改 Python 代码和数据库.

### 6.1. 添加字段
利用 Django 不关心表里是否包含 model 里所没有的列的特性.

**策略** : 先在数据库里添加字段, 然后同步 Django 的模型以包含新的字段. 

首先在测试环境实现变化,步骤如下:

1. 进入开发环境, 
2. 在模型里添加子弹
3. 运行`manage.py sqlall YOUR_APP`来测试模型新的 `CREATE TABLE`语句.注意为新字段的列定义.
4. 开启 数据库交互命令行界面. 执行 `ALTER TABLE`语句来添加新列.
5. 使用 Python 的 `manage.py shell`, 通过导入模型和选中表单, 来验证新的字段是否被正确的添加(如, MyModel.objects.all()[:5]), 
6. 如果一切顺利, 所有的语句都不会报错.

然后, 在产品服务器上实施步骤:

1. 启动数据库的命令行界面;
2. 执行在开发环境步骤中, 第三步的 `ALTER TABLE`语句;
3. 将新的字段加入到模型中. 然后在生产环境更新代码.
4. 重新启动 Web server, 使修改生效

### 6.2. 删除字段
步骤如下:

1. 从模型中删除字段, 然后重新启动 web 服务器.
2. 用一下命令从数据库中删除字段
    `ALTER TABLE books_book DROP COLUMN num_pages;`

### 6.3. 删除多对多关联字段
步骤如下:

1. 从模型中删除`ManyToManyField`, 然后重启 web 服务器.
2. 用下面的命令从数据库中删除关联表.
    `DROP TABLE books_book_authors;`

### 6.4. 删除模型
步骤如下:

1. 从模型文件中删除你想要删除的模型, 然后重启 web 服务器.
2. 用一下命令从数据库中删除表
    `DROP TABLE books_book;`
3. 当需要从数据库中删除任何有依赖的表时要注意(既任何与表 books_book 有外键的表).

## 7. Managers : 模型对象的行级别功能
在语句 `Book.objects.all()` 中, `objects` 时一个特殊的属性, 需要通过他来查询数据库. 这就是模块的**manager**.

**模块manager** 是一个对象, Django 模块通过他进行数据库查询. 每个 Django 模块至少有一个 manager , 可以创建自定义的 manager 以定制数据库访问.

### 7.1 增加额外的 Manager 方法
增加额外的 manager 方法是为模块添加**表级功能**的首选办法.

    # 为 Book 模型定义一个 title_count() 方法, 返回包含指定关键字的书的数量.
    # models.py

    from django.db import models

    # ... Author and Publisher models here ...

    class BookManager(models.Manager):
        def title_count(self, keyword):
            return self.filter(title__icontains=keyword).count()

    class Book(models.Model):
        title = models.CharField(max_length=100)
        authors = models.ManyToManyField(Author)
        publisher = models.ForeignKey(Publisher)
        publication_date = models.DateField()
        num_pages = models.IntegerField(blank=True, null=True)
        objects = BookManager()

        def __unicode__(self):
            return self.title

    # 使用方法
    >> Book.objects.title_count('django')
    4
    >> Book.objects.title_count("python")
    19

说明:

- 创建的 BookManager 类, 继承自 `django.db.models.Manager`, 这个类只有一个`title_count()`方法, 用来做统计. 该方法使用了 `self.filter()` , 此处 self 指 manager 本身

- 将 BookManager() 赋值给模型的 objects 属性, 它将取代模型的默认 manager(objects, 如果没有特别定义, 将被自动创建). 将他命名为 objects 是为了与自动创建的 Manager 保持一致.

### 7.2 修改初始 Manager QuerySet
manager 的基本 QuerySet 返回系统中的所有对象. 可以通过覆盖 `Manager.get_query_set()` 方法重写 manager 的基本 QuerySet, 返回一个自定义的 QuerySet.

`get_query_set()` 返回的是一个 QuerySet 对象, 所以可以使用 `filter()`,`exclude()` 和其他一些 QuerySet 的方法.

    # 模型有两个 manager, 返回不同的值.
    from django.db import models

    # First, define the Manager subclass.
    class DahlBookManager(models.Manager):
        def get_query_set(self):
            return super(DahlBookManager, self).get_query_set().filter(author='Roald Dahl')

    # then hook it into the Book model explicitly.
    class Book(models.Model):
        title = Model.CharField(max_length=100)
        author = Model.CharField(max_length=50)
        # ...
        objects = models.Manager()  # the default manager
        dahl_objects = DahlBookManager() # the Dahl-specific manager

以上模型中, `Book.objects.all()` 返回数据库中的所有书本, 而 `Book.dahl_objects.all()` 只返回作者是 Roald Dahl 的书.

以上示例中, 也指出了其他有趣的技术: 在一个模型中使用多个 Manager, 这是为模型添加通用过滤器的简单方法.

使用自定义 Manager 对象, 需要注意, **Django 会把第一个 Manger 定义为默认 Manager**, Django 的许多部分(不包括 admin 应用)将会明确的为模型使用这个 Manager, 所以需要小心的选择默认的 Manager.


## 8. 模型方法: 模型对象的行级别功能
给对象添加行级功能, 需要一个自定义方法, 有鉴于 manager 疆场被用来用一些整表操作, 模型方法应该只针对特殊模型实例起作用.

这是一项在模型的一个地方集中业务逻辑的技术.

    # 模型自定义方法
    from django.contrib.localflavor.us.models import USStateField
    from django.db import models

    class Person(models.Model):
        first_name = models.CharField(max_length=50)
        last_name = models.CharField(max_length=50)
        birth_date = models.DateField()
        address = models.CharField(max_length=100)
        city = models.CharField(max_length=50)
        state = USStateField()  

        def bady_boomer_status(self):
            "Return the person's bady-boomer status"
            import datetime
            if datetime.date(1945,8,1) <= self.birth_date <= datetime.date(1964,12,31):
                return "Baby boomer"
            if self.birth_date < datetime.date(1945,8,1):
                return "Pre-boomer"

            return "Post-boomer"

        def is_midwestern(self):
            "Return True if this person is from the Midwest"

            return self.state in ("IL", "WI","MI","IN","OH","IA","MO")

        def _get_full_name(self):
            "Return the persion's full name"
            return u"%s %s" % (self.first_name, self.last_name)

        full_name = property(_get_full_name)

    # 使用方法
        >> p = Person.objects.get(first_name="Barack", last_name="Obama")
        >> p.birth_date
        datetime.date(1962,8,4)
        >> p.baby_boomer_status()
        "Boby boomer"
        >> p.is_midwestern()
        True
        >> p.full_name
        u"Barack Obama"

## 9. 执行原始 SQL 查询
通过导入`django.db.connection` 对象来实现, 他代表当前数据库连接.  要使用 `connection.cursor()` 得到一个游标对象; `connection.execute(sql,[params])`, 来执行SQL 语句; 使用 `cursor.fetchone()` 或 `cursor.fetchall()` 来返回记录集.

    >> from django.db import connection
    >> cursor = connection.cursor()
    >> cursor.execute("""
        SELECT DISTINCT first_name FROM people_person WHERE last_name = %s
    """, ["Lennon"])
    >> row = cursor.fetchone()
    >> print row
    ["John"]

**不要把视图代码和 `django.db.connection.cursor` 语句混杂在一起, 推荐把他们放在自定义模型或者自定义 manager 方法中**.

    # 定义代码
    from django.db import connection, models

    class PersonManager(models.Manager):
        def first_names(self, last_name):
            cursor = connection.cursor()
            cursor.execute("""
                SELECT DISTINCT first_name FROM people_person WHERE last_name = %s""", [last_name])
            return (row[0] for row in cursor.fetchone())

    class Person(models.Model):
        first_name = models.CharField(max_length=50)
        last_name = models.CharField(max_length=50)
        objects = PersonManager()

    # 使用示例
    >> Person.objects.first_name('Lennon')
    ['John', "Cynthia"]


## 补充: Unicode
> 普通的python字符串是经过编码的，意思就是它们使用了某种编码方式（如ASCII，ISO-8859-1或者UTF-8）来编码。 如果你把奇特的字符（其它任何超出标准128个如0-9和A-Z之类的ASCII字符）保存在一个普通的Python字符串里，你一定要跟踪你的字符串是用什么编码的，否则这些奇特的字符可能会在显示或者打印的时候出现乱码。 当你尝试要将用某种编码保存的数据结合到另外一种编码的数据中，或者你想要把它显示在已经假定了某种编码的程序中的时候，问题就会发生。 我们都已经见到过网页和邮件被???弄得乱七八糟。 ?????? 或者其它出现在奇怪位置的字符：这一般来说就是存在编码问题了。1
> 但是Unicode对象并没有编码。它们使用Unicode，一个一致的，通用的字符编码集。 当你在Python中处理Unicode对象的时候，你可以直接将它们混合使用和互相匹配而不必去考虑编码细节。
> Django 在其内部的各个方面都使用到了 Unicode 对象。 模型 对象中，检索匹配方面的操作使用的是 Unicode 对象，视图 函数之间的交互使用的是 Unicode 对象，模板的渲染也是用的 Unicode 对象。 通常，我们不必担心编码是否正确，后台会处理的很好。