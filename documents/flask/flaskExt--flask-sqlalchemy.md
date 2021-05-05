---
title: Fask 扩展之--flask-sqlalchemy
date: 2018-03-19 18:49:18
categories:
- Python
tags:
- Flask
- Flask 扩展
---

## 一. 安装

    $ pip install flask-sqlalchemy

## 二. 配置
配置选项列表 :

| 选项 | 说明 |
| ---  | ---  |
| SQLALCHEMY_DATABASE_URI  | 用于连接的数据库 URI 。例如:sqlite:////tmp/test.db 或 mysql://username:password@server/db |
| SQLALCHEMY_BINDS   |   一个映射 binds 到连接 URI 的字典。更多 binds 的信息见 用 Binds 操作多个数据库 。 |
| SQLALCHEMY_ECHO    |   如果设置为 Ture ， SQLAlchemy 会记录所有 发给 stderr 的语句，这对调试有用。 |
| SQLALCHEMY_RECORD_QUERIES   |  可以用于显式地禁用或启用查询记录。查询记录 在调试或测试模式自动启用。更多信息见 get_debug_queries() 。 |
SQLALCHEMY_NATIVE_UNICODE   |  可以用于显式禁用原生 unicode 支持。当使用 不合适的指定无编码的数据库默认值时，这对于 一些数据库适配器是必须的（比如 Ubuntu 上某些版本的 PostgreSQL ）。|
| SQLALCHEMY_POOL_SIZE   |   数据库连接池的大小。默认是引擎默认值（通常 是 5 ） |
| SQLALCHEMY_POOL_TIMEOUT |  设定连接池的连接超时时间。默认是 10 。 |
| SQLALCHEMY_POOL_RECYCLE |  多少秒后自动回收连接。这对 MySQL 是必要的， 它默认移除闲置多于 8 小时的连接。注意如果 使用了 MySQL ， Flask-SQLALchemy 自动设定这个值为 2 小时。|


    app.config["SQLALCHEMY_DATABASE_URI"] = DATABASE_URI
    app.config["SQLALCHEMY_COMMIT_ON_TEARDOWN"] = True/False  # 每次请求结束后都会自动提交数据库中的变动.

    app.config[""] = 
    app.config[""] = 
    app.config[""] = 
    app.config[""] = 

    DATABASE_URI :
        mysql : mysql://username:password@hostname/database

        pgsql : postgresql://username:password@hostname/database

        sqlite(linux)  : sqlite:////absolute/path/to/database

        sqlite(windows) : sqlite:///c:/absolute/path/to/database

## 三. 初始化示例

    from flask import Flask
    from flask_sqlalchemy import SQLAlchemy
    base_dir = os.path.abspath(os.path.dirname(__file__))

    app = Flask(__name__)

    app.config["SQLALCHEMY_DATABASE_URI"] = 'sqlite:///' + os.path.join(base_dir, 'data.sqlite')
    app.config["SQLALCHEMY_COMMIT_ON_TEARDOWN"] = True

    db = SQLAlchemy(app)


## 四. 定义模型 
模型 表示程序使用的持久化实体. 在 ORM 中, 模型一般是一个 Python 类, 类中的属性对应数据库中的表.

Flaks-SQLAlchemy 创建的数据库实例为模型提供了一个基类以及一些列辅助类和辅助函数, 可用于定义模型的结构.
    
    db.Model    # 创建模型,
    db.Column   # 创建模型属性.

模型属性类型 : 

| 类型名 | Python类型 | 说明 | 
| ---    | ---        | ---  |
| Integer | int  | 普通整数，一般是 32 位 |
| SmallInteger | int | 取值范围小的整数，一般是 16 位 |
| Big Integer | int 或 long | 不限制精度的整数 | 
| Float | float |  浮点数 |
| Numeric | decimal.Decimal | 定点数 |
| String | str |  变长字符串 | 
| Text | str | 变长字符串，对较长或不限长度的字符串做了优化 |
| Unicode | unicode |变长 Unicode 字符串 |
| Unicode Text | unicode | 变长 Unicode 字符串，对较长或不限长度的字符串做了优化 |
| Boolean | bool | 布尔值 |
| Date | datetime.date | 日期 |
| Time | datetime.time | 时间 |
| DateTime | datetime.datetime| 日期和时间 |
| Interval | datetime.timedelta| 时间间隔 |
| Enum | str | 一组字符串 | 
| PickleType | 任何 Python 对象 |自动使用 Pickle 序列化 |
| LargeBinary | str | 二进制文件 | 

常用 SQLAlchemy 列选项

| 选项名 | 说明 |
| ---    | ---  |
| primary_key | 如果设为 True，这列就是表的主键 | 
| unique | 如果设为 True，这列不允许出现重复的值 |
| index | 如果设为 True，为这列创建索引，提升查询效率 |
| nullable | 如果设为 True，这列允许使用空值；如果设为 False，这列不允许使用空值 | 
| default | 为这列定义默认值 | 


**Flask-SQLAlchemy 要求每个模型都要定义主键, 这一列通常命名为 id .**

示例 : 

    class Role(db.Model):
        __tablename__ = "roles"
        id = db.Column(db.Integer, primary_key=True)
        name = db.Column(db.String(64), unique=True)

        def __repr__(self):
            """非必须, 用于在调试或测试时, 返回一个具有可读性的字符串表示模型."""
            return '<Role %r>' % self.name

    class User(db.Model):
        __tablename__ = 'users'
        id = db.Column(db.Integer, primary_key=True)
        username = db.Column(db.String(64), unique=True, index=True)

        def __repr__(self):          
            """非必须, 用于在调试或测试时, 返回一个具有可读性的字符串表示模型."""
            return '<Role %r>' % self.username

## 五. 关系
关系型数据库使用关系把不同表中的行联系起来.


常用 SQLAlchemy 关系选项 : 

| 选项名 | 说明 |
| ---    | ---  |
| backref | 在关系的另一个模型中添加反向引用 |
| primaryjoin | 明确指定两个模型之间使用的联结条件。只在模棱两可的关系中需要指定. |
| lazy | 指定如何加载相关记录。可选值如下 : |
| |  select（首次访问时按需加载）|
| | immediate（源对象加载后就加载）| 
| | joined（加载记录，但使用联结）|
| | subquery（立即加载，但使用子查询） |
| | noload（永不加载） | 
| | dynamic（不加载记录，但提供加载记录的查询） |
| uselist | 如果设为 Fales，不使用列表，而使用标量值 |
| order_by | 指定关系中记录的排序方式 |
| secondary | 指定多对多关系中关系表的名字 |
| secondaryjoin | SQLAlchemy 无法自行决定时，指定多对多关系中的二级联结条件 |


### 1) 一对多
原理 : 在 "多" 这一侧加入一个外键, 指定 "一" 这一侧联结的记录.

示例代码 : 一个角色可属于多个用户, 而每个用户只能有一个角色.
    
    class Role(db.Model):
        # ...
        users = db.relationship('User', backref='role')

    class User(db.Model):
        # ...
        role_id = db.Column(db.Integer, db.ForeignKey('roles.id'))  # 外键关系.
        
    
    ###############
    db.ForeignKey('roles.id') : 外键关系,

    Role.users = db.relationship('User', backref='role') : 代表 外键关系的 面向对象视角. 对于一个 Role 类的实例, 其 users 属性将返回与角色相关联的用户组成的列表. 
        db.relationship() 第一个参数表示这个关系的另一端是哪个模型. 
        backref 参数, 向 User 模型添加了一个 role 数据属性, 从而定义反向关系.  这一属性可替代 role_id 访问 Role 模型, 此时获取的是模型对象, 而不是外键的值.

### 2) 多对多
最复杂的关系类型, 需要用到第三章表, 即 *关联表* , 这样多对多关系可以分解成原表和关联表之间的两个一对多关系.

查询多对多关系分两步 : 遍历两个关系来获取查询结果.

代码示例:

    registrations = db.Table("registrations",
                             db.Column("student_id", db.Integer, db.ForeignKey("students.id")),
                             db.Column("class_id", db.Integer, db.ForeignKey("classes.id"))
                             )

    class Student(db.Model):
        __tablename__ = "students"
        id = db.Column(db.Integer, primary_key=True)
        name = db.Column(db.String)
        classes = db.relationship("Class",
                                  secondary=registrations,
                                  backref=db.backref("students", lazy="dynamic"),
                                  lazy="dynamic")

    class Class(db.Model):
        __tablename__ = "classes"
        id = db.Column(db.Integer, primary_key=True)
        name = db.Column(db.String)
 
多对多关系仍然使用定义一对多关系的 db.relationship() 方法进行定义, 但在多对多关系中, 必须把 secondary 参数设为 关联表. 

多对多关系可以在任何一个类中定义, backref 参数会处理好关系的另一侧. 

关联表就是一个简单的表, 不是模型, SQLAlchemy 会自动接管这个表.

classes 关系使用列表语义, 这样处理多对多关系比较简单.

Class 模型的 students 关系有 参数 db.backref() 定义. 这个关系还指定了 lazy 参数, 所以, 关系两侧返回的查询都可接受额外的过滤器.

**自引用关系**
自引用关系可以理解为 多对多关系的特殊形式 : 多对多关系的两边由两个实体变为 一个实体.

**高级多对多关系**
使用多对多关系时, 往往需要存储所联两个实体之间的额外信息. 这种信息只能存储在关联表中. 对用户之间的关注来说, 可以存储用户关注另一个用户的日期, 这样就能按照时间顺序列出所有关注者. 

为了能在关系中处理自定义的数据, 必须提升关联表的地位, 使其变成程序可访问的模型.

关注关联表模型实现:

    class Follow(db.Model):
        __tablename__ = "follows"
        follower_id = db.Column(db.Integer, db.ForeignKey("users.id"), primary_key=True)
        followed_id = db.Column(db.Integer, db.ForeignKey("users.id"), primary_key=True)
        timestamp = db.Column(db.DateTime, default=datetime.utcnow)

    # SQLAlchemy 不能直接使用这个关联表, 因为如果这个做程序就无法访问其中的自定义字段. 相反的, 要把这个多对多关系的左右两侧拆分成两个基本的一对多关系, 而且要定义成标准的关系.


使用两个一对多关系实现的多对多关系:

```
    class User(UserMixin, db.Model):
        # ...
        followd = db.relationship("Follow",
                                  foreign_keys=[Follow.follower_id],
                                  backref=db.backref("follower", lazy="joined"),
                                  lazy="dynamic",
                                  cascade="all, delete-orphan")
        followrs = db.relationship("Follow",
                                  foreign_keys=[Follow.followed_id],
                                  backref=db.backref("followed", lazy="joined"),
                                  lazy="dynamic",
                                  cascade="all, delete-orphan")

    # 这段代码中, followed 和 follower 关系都定义为 单独的 一对多关系. 
    # 注意: 为了消除外键歧义, 定义关系是必须使用可选参数 foreign_keys 指定的外键. 而且 db.backref() 参数并不是指定这两个关系之间的引用关系, 而是回引 Follow 模型. 回引中的 lazy="joined" , 该模式可以实现立即从连接查询中加载相关对象.
    # 这两个关系中, user 一侧设定的 lazy 参数作用不一样. lazy 参数都在 "一" 这一侧设定, 返回的结果是 "多" 这一侧中的记录. dynamic 参数, 返回的是查询对象.
    # cascade 参数配置在父对象上执行的操作相关对象的影响. 比如, 层叠对象可设定为: 将用户添加到数据库会话后, 要自定把所有关系的对象都添加到会话中. 删除对象时, 默认的层叠行为是把对象联结的所有相关对象的外键设为空值. 但在关联表中, 删除记录后正确的行为是把执行该记录的实体也删除, 因为这样才能有效销毁联结. 这就是 层叠选项值 delete-orphan 的作用. 设为 all, delete-orphan 的意思是启动所有默认层叠选项, 并且还要删除孤儿记录.
```
### 3) 一对一
可以看做特殊的 一对多 关系. 但调用 db.relationship() 时 要把 uselist 设置 False, 把 多变为 一 .

### 4) 多对一
将 一对多 关系,反过来即可, 也是 一对多关系.


## 六. 数据库操作
### 1) 创建数据库及数据表

**创建数据库**

    db.create_all()

示例 :
    $ python myflask.py shell
    > from myflask import db
    > db.create_all()

如果使用 sqlite , 会在 SQLALCHEMY_DATABASE_URI 指定的目录下 多一个文件, 文件名为该配置中的文件名.

如果数据库表已经存在于数据库中, 那么 db.create_all() 不会创建或更新这个表.

**更新数据库**
方法一 : 
先删除, 在创建 --> 原有数据库中的数据, 都会消失.

    > db.drop_all()
    > db.create_all()

方法二 : 
数据库迁移框架 : 可以跟自动数据库模式的变化, 然后增量式的把变化应用到数据库中.

SQLAlchemy 的主力开发人员编写了一个 迁移框架 Alembic, 除了直接使用 Alembic wait, Flask 程序还可使用 Flask-Migrate 扩展, 该扩展对 Alembic 做了轻量级包装, 并集成到 Flask-Script 中, 所有操作都通过 Flaks-Script 命令完成.

① 安装 Flask-Migrate 
    $ pip install flask-migrate

② 配置
    
    from flask_migrate import Migrate, MigrateCommand

    # ...
    migrate = Migrate(app, db)
    manager.add_command('db', MigrateCommand)

③ 数据库迁移
    a. 使用 init 自命令创建迁移仓库.
        $ python myflask.py db init     # 该命令会创建 migrations 文件夹, 所有迁移脚本都存在其中.

    b. 创建数据路迁移脚本.
        $ python myflask.py db revision     # 手动创建 Alemic 迁移
            创建的迁移只是一个骨架, upgrade() 和 downgrade() 函数都是空的. 开发者需要使用 Alembic 提供的 Operations 对象指令实现具体操作.

        $ python myflask.py db migrate -m COMMONT    # 自动创建迁移.
            自动创建的迁移会根据模型定义和数据库当前的状态之间的差异生成 upgrade() 和 downgrade() 函数的内容.

            ** 自动创建的迁移不一定总是正确的, 有可能漏掉一些细节, 自动生成迁移脚本后一定要进行检查.


    c. 更新数据库
        $ python myflask.py db upgrade      # 将迁移应用到数据库中.

### 2) 插入行
模型的构造函数, 接收的参数是使用关键字参数指定的模型属性初始值. 注意, role 属性也可使用, 虽然他不是真正的数据库列, 但却是一对多关系的高级表示. 这些新建对象的 id 属性并没有明确设定, 因为主键是由 Flask-SQLAlchemy 管理的. 现在这些对象只存在于 Python 解释器中, 尚未写入数据库.
```
    >> from myflask import db, User, Role

    >> db.create_all()

    >> admin_role = Role(name="Admin")

    >> mod_role = Role(name="Moderator")

    >> user_role = Role(name="User")

    >> user_john = User(username="john", role=admin_role)

    >> user_susan = User(username="susan", role=mod_role)

    >> user_david = User(username="david", role=user_role)

    >> admin_role.name
    'Admin'

    >> admin_role.id
    None

    ---------

    >> db.session.add_all([admin_role, mod_role, user_role, user_john, user_susan, user_david])   # 把对象添加到会话中.
    >> db.session.commit()      # 把对象写入数据库, 使用 commit() 提交会话.
```
### 3) 修改行

    >> admin_role = "Administrator"
    >> db.session.add(admin_role)
    >> db.session.commit()

### 4) 删除行
    
    >> db.session.delete(mod_role)
    >> db.session.commit()

### 5) 查询行
Flask-SQLAlchemy 为每个模型类都提供了 query 对象.

*获取表中的所有记录*

    >> Role.query.all()
      [<Role u'Admin'>, <Role u'Moderator'>, <Role u'User'>]
    >> User.query.all()
      [<Role u'john'>, <Role u'susan'>, <Role u'david'>]

*查询过滤器* 

filter_by() 等过滤器在 query 对象上调用, 返回一个更精确的 query 对象. 多个过滤器可以一起调用, 直到获取到所需的结果.

    >> User.query.filter_by(role=user_role).all()   # 以列表形式,返回所有结果,
    >> User.query.filter_by(role=user_role).first() # 返回结果中的第一个.

filter()  对查询结果过滤，比”filter_by()”方法更强大，参数是布尔表达式

    # WHERE age<20
    users = User.query.filter(User.age<20)
    # WHERE name LIKE 'J%' AND age<20
    users = User.query.filter(User.name.startswith('J'), User.age<20)

查询过滤器 : 

| 过滤器 | 说明 |
| ---    | ---  |
| filter() | 把过滤器添加到原查询上, 返回一个新查询 |
| filter_by() | 把等值过滤器添加到原查询上, 返回一个新查询 |
| limit() | 使用是zing的值限制原查询返回的结果数量, 返回一个新查询 |
| offset() | 偏移原查询返回的结果, 返回一个新查询 | 
| order_by() | 根据指定条件对原查询结果进行排序, 返回一个新查询 |
| group_by() | 根据指定条件对原查询结果进行分组, 返回一个新查询 |

查询执行函数 : 

| 方法 | 说明 |
| --- | --- |
| all() | 以列表形式返回查询的所有结果 |
| first() | 返回查询的第一个结果，如果没有结果，则返回 None |
first_or_404() | 返回查询的第一个结果，如果没有结果，则终止请求，返回 404 错误响应 | |
| get() | 返回指定主键对应的行，如果没有对应的行，则返回 None |
get_or_404() | 返回指定主键对应的行，如果没找到指定的主键，则终止请求，返回 404  | |错误响应
| count() | 返回查询结果的数量 |
| paginate() | 返回一个 Paginate 对象，它包含指定范围内的结果 |

### 6) 会话管理, 事务管理
*单个提交*

    >> db.session.add(ONE)
    >> db.session.commit()

*多个提交*

    >> db.session.add_all([LIST_OF_MEMBER])
    >> db.session.commit()

*删除会话*

    >> db.session.delete(mod_role)
    >> db.session.commit()

*事务回滚* : 添加到数据库会话中的所有对象都会还原到他们在数据库时的状态.

    >> db.session.rollback()

## 七. 视图函数中操作数据库
```
@app.route('/', methods=['GET', 'POST'])
def index():
    form = NameForm()
    if form.validate_on_submit():
        user = User.query.filter_by(username=form.name.data).first()
        if user is None:
            user = User(username=form.name.data)
            db.session.add(user)
            session["known"] = False
        else:
            session["known"] = True

        session["name"] = form.name.data
        form.name.data = ""             # why empty it ?
        return redirect(url_for("index"))
    return render_template("index.html", current_time=datetime.utcnow(), form=form, name=session.get("name"), known=session.get("known"))
```
## 八. 分页对象 Pagination        

### 1. paginate() 方法

paginate() 方法的返回值是一个 Pagination 类对象, 该类在 Flask-SQLAlchemy 中定义, 用于在模板中生成分页链接.

    paginate(页数[,per_page=20, error_out=True])
        页数 : 唯一必须指定的参数,
        per_page : 指定每页现实的记录数量, 默认 20.
        error_out : True 如果请求的页数超出了返回, 返回 404 错误; False 页数超出范围时返回一个,空列表.

示例代码:
```
@main.route("/", methods=["GET", "POST"])
def index():
    # ...
    page = request.args.get('page', 1, type=int)    # 渲染的页数, 默认第一页, type=int 保证参数无法转换成整数时, 返回默认值.
    pagination = Post.query.order_by(Post.timestamp.desc()).paginate(page, per_page=current_app.config["FLASKY_POSTS_PER_PAGE"], error_out=False)

    posts = pagination.items
    return render_template('index.html', form=form, posts=posts,pagination=pagination)
```


### 2. 分页对象的属性及方法:

Flask_SQLAlchemy 分页对象的属性:

| 属性 |  说明  |
| ---  | ---    |
| items |  当前分页中的记录 |
| query  | 分页的源查询 |
| page  |  当前页数 |
| prev_num  |  上一页的页数 |
| next_num  |  下一页的页数 |
| has_next  |  如果有下一页, 返回 True |
| has_prev  |  如果有上一页, 返回 True |
| pages  |     查询得到的总页数 |
| per_page |   每页显示的记录数量 |
| total   |    查询返回的记录总数 |

在分页对象可调用的方法:

| 方法 | 说明 |
| ---  | ---  |
| iter_pages(left_edge=2,left_current=2,right_current=5,right_edge=2) | 一个迭代器, 返回一个在分页导航中显示的页数列表. 这个列表的最左边显示 left_edge 页, 当前页的左边显式 left_current 页, 当前页的右边显示 right_currnt 页, 最右边显示 right_edge 页. 如 在一个 100 页的列表中, 当前页为 50 页, 使用默认配置, 该方法返回以下页数 : 1, 2, None, 48,49,50,51,52,53,54,55, None, 99 ,100. None 表示页数之间的间隔. |
| prev() | 上一页的分页对象 |
| next() | 下一页的分页对象 |

### 3. 在模板中与 BootStrap 结合使用示例

使用 Flaks-SQLAlchemy 的分页对象与 Bootstrap 中的分页 CSS, 可以轻松的构造出一个 分页导航.

分页模板宏 _macros.html : 创建一个 Bootstrap 分页元素, 即一个有特殊样式的无序列表.

```
{% macro pagination_widget(pagination,endpoint) %}
<ul class="pagination">
    <li {% if not pagination.has_prev %} class="disabled" {% endif %}>
        <a href="{% if pagination.has_prev %}{{url_for(endpoint, page=paginatin.page - 1, **kwargs)}}{% else %}#{% endif %}">
            &laquo;
        </a>
    </li>
    {% for p in pagination,.iter_pages() %}
        {% if p %}
            {% if p == pagination.page %}
            <li class="active">
                <a href="{{ url_for(endpoint, page=p, **kwargs) }}">{{p}}</a>
            </li>
            {% else %}
            <li>
                <a href="{{ url_for(endpoint, page = p, **kwargs) }}">{{p}}</a>
            </li>
            {% endif %}
        {% else %}
        <li class="disabled"><a href="#">&hellip;</a> </li>
        {% endif %}
    {% endfor %}
    <li {% if not pagination.has_next %} class="disabled" {% endif%}>
        <a href="{% if paginatin.has_next %}{{ url_for(endpoint, page=pagination.page+1, **kwargs) }}{% else %}#{% endif %}">
            &raquo;
        </a>
    </li>
</ul>
{% endmacro %}
```

导入使用分页导航
```
{% extends "base.html" %}
{% import "_macros.html" as macros %}
...
<div class="pagination">
    {{ macro.pagination_widget(pagination, ".index")}}
</div>
```

## 九. 监听事件
### 1. set 事件

示例代码 : 
```    
from markdown import markdown
import bleach

class Post(db.Model):
    # ...
    body = db.Colume(db.Text)
    body_html = db.Column(db.Text)
    # ...

    @staticmethod
    def on_changeed_body(target, value, oldvalue, initiator):
        allowed_tags = ["a", "abbr", "acronym", "b", "blockquote", "code", "em",
                        "i", "li", "ol", "pre", "strong", "ul", "h1", "h2","h3","h4","p"]
        target.body_html = bleach.linkify(bleach.clean(markdown(value, output_format="html"), tags=allowed_tags, strip=True))

db.event.listen(Post.body, "set", Post.on_changeed_body) 
# on_changed_body 函数注册在 body 字段上, 是 SQLIAlchemy "set" 事件的监听程序, 
# 这意味着只要这个类实例的 body 字段设了新值, 函数就会自动被调用. 
# on_changed_body 函数把 body 字段中的文本渲染成 HTML 格式, 
# 结果保存在 body_html 中, 自动高效的完成 Markdown 文本到 HTML 的转换.
```
## 十. 记录慢查询.

## 十一. Binds 操作多个数据库

## 十二. 其他
### 1. [ORM 在查询时做初始化操作](http://docs.sqlalchemy.org/en/latest/orm/constructors.html)

当 SQLIAlchemy ORM 从数据库查询数据时, 默认不调用`__init__` 方法, 其底层实现了 Python 类的 `__new__()` 方法, 直接实现 对象实例化, 而不是通过 `__init__` 来实例化对象.

如果需要在查询时, 依旧希望实现一些初始化操作, 可以使用 `orm.reconstructor()` 装饰器或 实现 `InstanceEvents.load()` 监听事件.
```
# orm.reconstructor
from sqlalchemy import orm

class MyMappedClass(object):
    def __init__(self, data):
        self.data = data

        # we need stuff on all instances, but not in the database.
        self.stuff = []

    @orm.reconstructor
    def init_on_load(self):
        self.stuff = []

# InstanceEvents.load()
from sqlalchemy import event
## standard decorator style

@event.listens_for(SomeClass, 'load')
def receive_load(target, context):
    "listen for the 'load' event"

    # ... (event handling logic) ...
```
如果只是希望在从数据库查询生成的对象中包含某些属性, 也可以使用 `property` 实现:
```
class AwsRegions(db.Model):
    name=db.Column(db.String(64))
    ...

    @property
    def zabbix_api(self):
        return ZabbixObj(zabbix_url)

    @zabbix_api.setter
    def zabbix_api(self):
        raise ValueError("zabbix can not be setted!")
```