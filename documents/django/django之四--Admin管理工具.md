---
title: django之四--Admin管理工具
date: 2018-03-16 16:58:10
categories:
- Python
tags:
- web development
- django
---
## 一. 概述

### 1. 简介
管理界面是以**网页**和有限的**可信任管理者**为基础的界面.

Django 自动管理界面**工作原理**: **读取模型中的元数据, 然后提供给用户一个强大而且可以使用的界面, 网站管理者可以使用它立即工作**.

### 2. Admin 工作原理
当服务启动时, Django 从 `urls.py` 引导 URLconf, 然后执行 `admin.autodiscover()` 语句. 该函数遍历 `INSTALLED_APPS` 配置, 并且寻找相关的 `admin.py` 文件, 如果在执行的 app 目录下找到 `admin.py` , 他就执行其中的代码.

**模块注册** : 在 books 应用程序的目录下的 `admin.py` 文件中, 每次调用 `admin.site.register()` 都将会将该模块注册到管理工具中, **管理工具只为那些明确注册了的模块显示一个编辑/修改页面**.

应用程序 `django.contrib.auth` 包含自身的 `admin.py`, 所以 Users 和 Groups 能在管理工具中自动显示. 其他的 `django.contrib` 应用程序, 如 `django.contrib.redirects`, 其他从网上下载的第三方 Django 应用程序一样, 都会自行添加到管理工具.

管理工具实际就是一个 Django 应用程序, 包含自己的 模块,模板,视图和 URLpatterns. 需要向添加自己的视图一样, 将它添加到 URLconf 里面. 可以在 Django 基本代码中的 `django/contrib/admin` 目录下查看他的模板,视图和 URLpatterns, 但**不要尝试修改其中的代码**.
如果确实想浏览 django 管理工具的代码, 请谨记他在读取关于模块的元数据过程中做了些不简单的工作, 因此最好花些时间阅读和理解那些代码.



## 二. django.contrib 包

Django 自动管理工具集(admin)是 `django.contrib`的一部分.

`django.contrib` 是一套庞大的功能集, 他是 Django 基本代码的组成部分, Django 框架就是有众多包含附加组件(add-on)的基本代码构成的. 可以把 `django.contrib` 看作是可选的 Python 标准库或普遍模式的实际实现. 他们与 Django 捆绑在一起, 这也就无需开发者重复造轮子了.

`django.contrib` 组成部分:
- `django.contrib.admin` : 自动管理工具.
- `django.contrib.auth` : 用户认证系统.
- `django.contrib.sessions` : 支持匿名会话.
- `django.contrib.comments` : 用户评论系统.

## 三. 激活管理界面
1. 将 `django.contrib.admin`加入 `setting` 的`INSTALLED_APPS`的配置中.
2. 保障`INSTALLED_APPS`中包含 `django.contrib.auth`,`django.contrib.contenttypes`,`django.contrib.sessions` django 管理工具需要这三个包.
3. 确保`MIDDLEWARE_CLASSES`包含`django.middleware.common.CommonMiddleware`,`django.contrib.sessions.middleware.SessionMiddleware`,和`django.contrib.auth.middleware.AuthenticationMiddleware`.

5. 运行 `python manage.py syncdb`, 用于生成管理界面使用的额外数据库表. 首次运行该命令, 会交互式提醒创建一个****. 否则需要使用`python manage.py createsuperuser` 来创建一个 admin 用户账号. **只用当 `INSTALLED_APP` 包含 `django.contrib.auth` 时, `python manage.py createsuperuser` 这个命令才可用**

6. 将`admin`添加到`URLconf`配置中.
        
        # urls.py
        from django.contrib import admin
        admin.autodiscover()

        urlpatterns = patterns('',
            # Uncomment the next line to enable the admin:
            (r'^admin/', include(admin.site.urls)),
        )

## 四. 使用管理工具
### 1. 基本使用
两个默认的管理-编辑模块: 用户组(Group), 用户(User).

在 Django 管理页面中, 每种数据类型都有 `change list` 和 `edit form`. 前者显示数据库中所有的可用对象; 后者可以添加,更改,删除数据库的某条记录.


### 2. 将 Model 添加到 Admin 管理中.
将自定义的 Models 添加到 Admin 管理中.

    $ touch mysite/books/admin.py
    $ cat mysite/books/admin.py
        from django.contrib import admin
        from mysite.books.models import Publisher,Author,Book

        admin.site.register(Publisher)
        admin.site.register(Author)
        admin.site.register(Book)

    $ python manage.py runserver 0.0.0.0:8000


管理工具处理外键和多对多关系的方法是: 外键使用一个选择框显示, 多对多关系使用一个多选框显示.



### 3.设置字段可选 : `blank=True`
    
    # mysite/books/models.py

    class Author(models.Model):
        first_name = models.CharField(max_length=30)
        last_name = models.CharField(max_length=40)
        email = models.EmailField(blank=True)


### 4.设置日期型和数字型字段可选 : `blank=True`, `null=True`
Django生成CREATE TABLE语句自动为每个字段显式加上`NOT NULL`.

日期型、时间型和数字型字段不接受空字符串。

如果你想允许一个日期型（DateField、TimeField、DateTimeField）或数字型（IntegerField、DecimalField、FloatField）字段为空，你需要使用null=True 和. blank=True。

    class Book(models.Model):
        title = models.CharField(max_length=100)
        authors = models.ManyToManyField(Author)
        publisher = models.ForeignKey(Publisher)
        publication_date = models.DateField(blank=True, null=True)ssss

**null=True 改变了数据的定义, 即改变了 CREATE TABLE 语句, 把 publication_date 字段上的 NOT NULL 删除了, 要完成这些, 需要更新数据库:
    
    $ python manage.py dbshell

        ALTER TABLE books_book ALTER COLUMN publication_date DROP NOT NULL;

### 5.自定义字段标签 : `verbose_name=NAME`
在编辑页面中, 每个字段的标签都是从模板的字段名称生成的, 规则: 用空格替换下划线, 首字母大写.

    class Author(model.Model):
        first_name = models.CharField(max_length=30)
        last_name = models.CharField(max_length=40)
        email = models.EmailField(blank=True, verbose_name="e-mail")

        # 或者, 如下方式不适用于 ManyToManyField, ForeignKey 字段, 因为他们的第一个参数必须为模块类.
        email = models.EmailField("e-mail", blank=True) 

## 五. 自定义 ModelAdmin 类
django 提供大量选项让你针对特别的模块自定义管理工具, 这些选项都在 `ModelAdmin classes` 里面, 这些类包含了管理工具中针对特别模块的配置.

### 1. 自定义列表 : `list_display`,`search_fields`

在**列表**中可以看到作者的邮箱地址, 并且按姓氏或名字排序. 为了达到这个目的, 将为 Author 模块定义一个 ModelAdmin 类, 该类是自定义管理工具的关键:

    from django.contrib import admin
    from mysite.books.models import Publisher,Author,Book

    class AuthorAdmin(admin.ModelAdmin):
        list_display=("first_name", "last_name", "email")

    admin.site.register(Author, AuthorAdmin)
    admin.site.register(Publisher)
    admin.site.register(Book)

AuthorAdmin 是从 `django.contrib.admin.ModelAdmin` 中派生出来的子类, 保存着一个类的自定义配置, 以供管理工具使用.

`list_display` 是一个字段名称的元组, 用于列表显示. 这些字段名称必须是模块中有的.

`admin.site.register(Author,AuthorAdmin)` 可以理解为 使用 AuthorAdmin 选项注册 Author 模块.

`admin.site.register()` 函数接受一个 ModelAdmin 子类作为第二个参数. 如果没有第二个参数, django 将使用默认选项.

添加一个**快速查询栏**(大小写敏感) : search_fields

    class AuthorAdmin(admin.ModelAdmin):
        list_display = ("first_name", "last_name", "email")
        search_fields = ("first_name", "last_name")

### 2. 字段过滤器
 Django为日期型字段提供了快捷过滤方式，它包含：今天、过往七天、当月和今年。这些是开发人员经常用到的。

    class BookAdmin(admin.ModelAdmin):
        list_display = ("title", "publisher", "publication_date")
        list_filter = ("publication_date")

    admin.site.register(Book, BookAdmin)

过滤器同样适用于其他类型的字段, 而不单是日期型, 请在 布尔型和外键字段上试试. 当有两个以上值时, 过滤器就会显示.

### 3. 日期过滤器 : `date_hierarchy`**

    class BookAdmin(admin.ModelAdmin):
        list_display = ("title", "publisher", "publication_date")
        list_filter = ("publication_date")
        date_hierarchy = "publication_date"

`date_hierarchy` 接受的是**字符串**, 而不是元组, 因为只能对一个日期型字段进行层次划分.

### 4. 排序: `ordering`
列表字段默认按照模块 class Meta 中的 ordering 所指的列排序. `ordering` 选项基本像模块中 class Meta 的 ordering 那样工作. 见许仅需在传入的元素或者元组的字段前加上一个减号(-).

    class BookAdmin(admin.ModelAdmin):
        list_display = ("title", "publisher", "publication_date")
        list_filter = ("publication_date")
        date_hierarchy = "publication_date"
        ordering = ("-publication_date")

### 5. 自定义编辑表单
#### 5.1 自定义字段顺序: `fields`

默认的, 表单中的字段顺序是与模块中定义的一致的. 可以使用`ModelAdmin`子类中的`fields`选项来改变他.

    class BookAdmin(admin.ModelAdmin):
        list_display = ("title", "publisher", "publication_date")
        list_filter = ("publication_date")
        date_hierarchy = "publication_date"
        ordering = ("-publication_date")            
        fields = ("title", "authors", "publisher", "publication_date")

完成之后, 编辑表单将按照指定顺序显示各字段.

`fields`选项可以排除一些不想被其他人编辑的 fields. 当 admin 用户只是被信任可以更改某一部分数据时, 或者, 数据被一些外部的程序自动处理而改变了, 可以使用该功能.

`fields = ("title", "authors", "publisher")` 可以实现无法对 publication_date 进行改动. 当一个用户使用后这个不包含完整信息的表单添加一本新书时, Django会简单的将 publication_date 设置为 None, 以确保这个字段满足 `null=True` 的条件.

#### 5.2 多选框 : `filter_horizontal`, `filter_vertical` --> 用于多对多字段.
    
主要用于多对对字段, 它实现了一个简单的搜索框和两个选择区域, 可以将搜索到的多个选项在选择区域之间移动.

    class BookAdmin(admin.ModelAdmin):
        list_display = ("title", "publisher", "publication_date")
        list_filter = ("publication_date")
        date_hierarchy = "publication_date"
        ordering = ("-publication_date")            
        filter_horizontal = ("authors",)        

如上代码, 会在 Author 区中有一个 JavaScript 过滤器, 它允许搜索选项, 然后将选中的 author 从 Available 框移到 Chosen 框,还可以移回来.

`filter_horizontal`, `filter_vertical` 只能用于**多对多字段**, 不能用于 ForeignKey 字段.

#### 5.3 文本框: `raw_id_fields` --> ForeignKey
    
`raw_id_fields` 是一个包含外键字段名称的元组, 他包含的字段将被展现为**文本框**, 而不是默认的
`raw_id_fields` 是一个包含外键字段名称的元组, 他包含的字段将被展现为**文本框**, 而不是默认的****.

    class BookAdmin(admin.ModelAdmin):
        list_display = ("title", "publisher", "publication_date")
        list_filter = ("publication_date")
        date_hierarchy = "publication_date"
        ordering = ("-publication_date")            
        filter_horizontal = ("authors",)  
        raw_id_fields = ('publisher',)    

## 六. 用户,用户组,权限
管理工具有一个用户权限系统, 通过他你可以根据用户的需要来指定他们的权限, 从而达到部分访问系统的目的.

通过管理界面可以变价用户及其许可. 用户对象有标准的用户名,密码,邮箱地址和真实姓名, 同时还有关于使用管理界面的权限定义. 如下三种布尔型标记:

- **活动标志** : 控制用户是否已经激活.
- **成员标识** : 用来控制该用户是否可以登录管理界面. 用用户系统可以被用于控制公众界面(非管理页面)的访问权限, 这个标志可用来区分公众用户和管理用户.
- **超级用户标识** : 赋予用户在管理界面中添加,修改,删除任何项目的权限. 如果一个用户有该标志, 那么所有权限设置都会被忽略.

普通的活跃,非超级用户的管理用户可以根据一套设定好的许可进入. 管理界面中每种可编辑的对象(如 books, author, publishers)都有三种权限: **创建许可**, **编辑许可**, **删除许可**. 给一个用户授权就表明该用户可以进行许可描述的操作.

当创建一个用户时, 他没有任何权限, 该有什么权限由你决定. 这些权限时定义在模块级别上的, 而不是对象级别上的. 如 你可以让 tom 账户修改任何图书, 但不能让他仅仅修改由 机械工业出版社 出版的图书. 后面这种基于对象级别的权限设置比较复杂, 可以查看官方文档.

可以给组中分配用户, **组**简化了组中所有成员应用一套许可的动作. 组在给大量用户特定权限的时候很有用.

管理界面不应当成为一个公众数据访问接口, 也不允许对数据进行复杂的排序和查询. 它仅提供给可信任的管理员.