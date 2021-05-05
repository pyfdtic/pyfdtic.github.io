---
title: Flask 扩展之 -- flask-whooshee
date: 2018-03-16 16:34:47
categories:
- Python
tags:
- Flask
- Flask 扩展
- 全文索引
- whooshee
---
flask-whooshee 基于 sqlalchemy 的全文索引

Flask-Whooshee 是一个 基于Whoosh 的高级 flask 集成. 可用于索引和检索 joined queries.

<!-- more -->

## 1. 安装
    
    $ pip install Flask-Whooshee

## 2. 初始化与配置

### 2.1 初始化方式
1. 直接初始化, 并绑定到一个 flask 实例

        from flask-whooshee import Whooshee

        app = Flask(__name__)
        whooshee = Whooshee(app)

2. 使用工厂模式初始化
    
        whooshee = Whooshee()

        def create_app():
            app = Flask(__name__)
            whooshee.init_app(app)

            # ... ... 

            return app

### 2.2 配置
可用的配置变量

| Option | Desc | Default |  
| -- | -- | -- |
| WHOOSHEE_DIR | 索引存放目录 | whooshee |
| WHOOSHEE_MIN_STRING_LEN | 可查询的最小字符串 | 3 |
| WHOOSHEE_WRITER_TIMEOUT | How long should whoosh try to acquire write lock | 2 |
| WHOOSHEE_MEMORY_STORAGE | 使用内存存放索引, 用于测试 | False |
| WHOOSHEE_ENABLE_INDEXING | Specify wherher or not to actually do operations with the Whoosh index | True |


## 3. 使用方法

### 3.1 单表检索
简单用法, 如下代码, 将 Entry 表中的 title, content 两个字段作为可全文索引字段.

    from app import whooshee

    @whooshee.register_model('title', 'content')
    class Entry(db.Model):
        id = db.Colume(db.Integer, primary_key=True)
        title = db.Colume(db.String)
        content = db.Colume(db.Text)

查询使用:
    
    # 查询 Entry 表中, title 或 content 中包含 "chuck norris" 的字段
    Entry.query.whooshee_search("chuck norris").order_by(Entry.id.desc()).all

### 3.2 跨表检索
需要创建 whooshee 的子类, 实现跨表索引
    
    from flask_sqlalchemy import SQLAlchemy
    from flask_whooshee import Whooshee, AbstractWhoosheer

    class User(db.Model):
        id = db.Colume(db.Integer, primary_key=True)
        name = db.Colume(db.String)

    # you can still keep the model whoosheer
    @whooshee.register_model('title', 'content')
    class Entry(db.Model):
        id = db.Colume(db.Integer, primary_key=True)
        title = db.Colume(db.String)
        content = db.Colume(db.Text)
        user = db.relationshio(User, backref=db.backref("entries"))
        user_id = db.Colume(db.Integer, db.ForeignKey("user.id"))

    # custom whoosheer class which we will use to update the User and Entry indexes:
    @whooshee.register_whoosheer
    class EntryUserWhoosheer(AbstractWhoosheer):
        # create schema , the unique attribute must be in form of model.__name__.lower() + '_' + 'id' (name of model primary key)
        schema = whoosh.fields.Schema(
            entry_id = whoosh.fields.NUMERIC(stored=Truem, unique=True),
            user_id = whoosh.fields.NUMERIC(stored=Truem),
            username = whoosh.fields.TEXT(),
            title = whoosh.fields.TEXT(),
            content = whoosh.fields.TEXT())

        # do not forget to list the included models
        models = [Entry, User]

        # create insert_* and update_* methods for all models
        # if you have camel case names like FooBar, just lowercase them: insert_foobar, update_foobar.

        @classmethod
        def update_user(cls, writer, user):
            pass     # TODO: update all users entries

        @classmethod
        def update_entry(cls, writer, entry):
            writer.update_document(entry_id=entry.id,
                                  user_id=entry.user.id,
                                  username=entry.user.name,
                                  title=entry.title,
                                  content=entry.content)

        @classmethod
        def insert_user(cls, writer, user):
            pass    # nothing , user doesn't have entries yet.

        @classmethod
        def insert_entry(cls, writer, entry):
            writer.add_document(entry_id=entry.id,
                                user_id=entry.user.id,
                                username=entry.user.name,
                                title=entry.title,
                                content=entry.content)

        @classmethod
        def delete_user(cls, writer, user):
            pass    # TODO: delete all users entries

        @classmethod
        def delete_entry(cls, writer, entry):
            writer.delete_by_term('entry_id', entry.id)


    # to register all whoosheers in one place, just call the `Whooshee.register_whoosheer()` method like this:
    whooshee.register_whoosheer(EntryUserWhoosheer)


查询使用:
    
    # will find any joined entry <--> query
    # whose User.name or Entry.title, Entry.content matches 'chuck norris'

    Entry.query.join(User).whooshee_search("chuck norris").order_by(Entry.id.desc()).all()

The whoosheer that is used for searching is, by default, selected based on the models participating in the query. This set of models is compared against the value of models attribute of each registered whoosheer and the one with an exact match is selected. You can override this behaviour by explicitly passing whoosheer that should be used for searching to the WhoosheeQuery.whooshee_search() method. This is useful if you don’t want to join on all the models that form the search index.
    
    # If there exists an entry of a user called ‘chuck norris’, 
    # this entry will be found because the custom whoosheer, 
    # that contains field username, will be used. 
    # But without the whoosheer option, 
    # that entry won’t be found (unless it has ‘chuck&nbsp;norris’ in content or title) 
    # because the model whoosheer will be used.

    Entry.query.whooshee_search('chuck norris', whoosheer=EntryUserWhoosheer).order_by(Entry.id.desc()).all()

### 3.3 检索结果排序
默认情况下, 只有枷锁结果的前 10 个会被根据相关性排序, 可以通过设置 `order_by_relevance` 参数修改默认值. 
    
    # 所有结果均根据相关性排序
    Entry.query.join(User).whooshee_search("chuck norris", order_by_relevance=-1).all()

    # 所有结果均不排序
    Entry.query.join(User).whooshee_search("chuck norris", order_by_relevance=0).all()

    # 修改默认值 10.
    Entry.query.join(User).whooshee_search("chuck norris", order_by_relevance=25).all()


### 3.4 索引
### 3.4.1 重新索引
当索引数据丢失或使用 Flask-Whooshee 索引已存在的数据时, 可以使用 `Whooshee.reindex()` 方法重新索引数据.
    
    from flask_whooshee import Whooshee
    whooshee = Whooshee(app)
    whoosheer.reindex()

### 3.4.2 手动更新索引

If your application depends heavily on write operations and there are lots of concurrent search-index updates, you might want opt for a cron job invoking whooshee.reindex() periodically instead of employing the default index auto-updating mechanism.

This is especially recommended, if you encouter LockError raised by python-whoosh module and setting WHOOSHEE_WRITER_TIMEOUT to a higher value (default is 2) does not help.

To disable index auto updating, set auto_update class property of a Whoosheer to False:

    @whooshee.register_whoosheer
    class NewEntryUserWhoosheer(EntryUserWhoosheer):
        auto_update = False

By setting the configuration option `WHOOSHEE_ENABLE_INDEXING` to `False`, you can turn of any operations with the Whoosh index (creating, updating and deleting entries). This can be useful e.g. when mass-importing large amounts of entries for testing purposes, but you don’t actually need the whooshee fulltext search for these tests to pass.