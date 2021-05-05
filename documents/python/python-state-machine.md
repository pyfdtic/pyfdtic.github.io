---
title: python state_machine 文档及源码分析
date: 2018-03-27 18:53:05
categories:
- Python
tags:
- 状态机
- 设计模式
- PyPi
---

## 一. 安装
    
    $ pip install state_machine

## 二. 使用方法

### 0. 示例代码

    from state_machine import acts_as_state_machine, State, Event, before, after

    @acts_as_state_machine
    class Person(object):
        name = "Billy"

        sleeping = State(initial=True)
        running = State()
        cleaning = State()

        run = Event(from_states=sleeping, to_state=running)
        cleanup = Event(from_states=running, to_state=cleaning)
        sleep = Event(from_states=(running, cleaning), to_state=sleeping)

        @before("sleep")
        def do_one_things(self):
            print("{} is sleepy.".format(self.name))
        
        @before("sleep")
        def do_another_thing(self):
            print("{} is REALLY sleepy.".format(self.name))
        
        @after("sleep")
        def snore(self):
            print("Zzzzzzzz")
        
        @after("sleep")
        def big_snore(self):
            print("Zzzzzzzz")

    person = Person()
    print(person.current_state)     # sleeping
    print(person.is_sleeping)       # True
    print(person.is_running)        # False

    person.run()                    # 执行状态转换
    print(person.is_running)        # True
    print(person.is_sleeping)       # False

    person.sleep()      # 执行状态转换 : Billy is sleepy.\nBilly is REALLY sleepy.\nZzzzzzzz\nZzzzzzzz
    print(person.current_state)     # sleeping

### 1. 基础使用: State,Event, acts_as_state_machine

    from state_machine import State, Event, acts_as_state_machine

一个状态机类, 需要首先使用 `acts_as_state_machine` 装饰. 一个状态机类的实例, 会具有 `current_state` 属性用于判断当前实例的状态. 同时, 会有 `is_STATE` 属性, 返回布尔值, 用于判断当前实例是否处于某种状态.

一个 `State()` 类实例, 代表一种状态. `State(initial=True)` 表示该状态位于**初始状态**.

一个 `Event()` 类实例, 代表一种状态转换. `from_states` 为单个状态或一个状态元组, 是对象在一个状态转换中的起始状态(或之一). `to_state` 为对象在一个状态装换中的目标状态. 每种`Event()` 实例, 都是状态机实例的可调用方法, 用于实现状态装换.

### 2. before/after 装饰器回调

    from state_machine import after, before

`after` 和 `before` 是一个接受参数的装饰器, 其参数为一个状态转换(Event)实例, 表示在状态转换之前/后 执行的一个或一组操作.

如果一个 `before` 钩子函数产生一个异常, 或返回 `False`, 那么该钩子装饰的状态转换(`Event()`) 将不会发生, 装饰该状态转换的 `after` 钩子函数也不会被执行.

### 3. Exception

    from state_machine import InvalidStateTransition

当尝试做一个非法的转换时(即 没有定义对应的状态转换 Event), 一个 `InvalidStateTransition` 异常会被抛出.

### 4. ORM 支持
`state_machine` 有对 `mongoengine` 和 `SQLAlchemy` 的基础支持.

#### 4.1 mongoengine
自定义类只需继承 `mongoengine.Document` , `state_machine` 会自动添加一个 `StringFiled` for state.

**必须明确调用 `save()` 方法, 才能把对象的状态持久化**.

    @acts_as_state_machine
    class Person(mongoengine.Document):
        name = mongoengine.StringField(default="Billy")

        sleeping = State(initial=True)
        running = State()
        cleaning = State()

        run = Event(from_states=sleeping, to_state=running)
        cleanup = Event(from_states=running, to_state=cleaning)
        sleep = Event(from_states=(running, cleaning), to_state=sleeping)

        @before("sleep")
        def do_one_things(self):
            print("{} is sleepy.".format(self.name))
        
        @before("sleep")
        def do_another_thing(self):
            print("{} is REALLY sleepy.".format(self.name))
        
        @after("sleep")
        def snore(self):
            print("Zzzzzzzz")
        
        @after("sleep")
        def big_snore(self):
            print("Zzzzzzzzzzzzzzzzzz")

    person = Person()
    person.save()
    eq_(person.current_state, Person.sleeping)
    assert person.is_sleeping
    assert not person.is_sleeping

    person.run()
    assert person.is_running

    person.sleep()
    assert person.is_sleeping

    person.run()
    person.save()

    person2 = Person.objects(id=person.id).first()
    assert person2.is_running

#### 4.2 SQLAlchemy

All you need to do is have sqlalchemy manage your object.

    from sqlalchemy.ext.declarative import declarative_base

    Base = declarative_base()

    @acts_as_state_machine
    class Puppy(Base):
        pass

示例代码

    from sqlalchemy.ext.declarative import declarative_base
    from sqlalchemy.orm import sessionmaker

    Base = declarative_base()

    @acts_as_state_machine
    class Penguin(Base):
        __tablename__ = 'penguins'
        id = sqlalchemy.Column(sqlalchemy.Integer, primary_key=True)
        name = sqlalchemy.Column(sqlalchemy.String)

        sleeping = State(initial=True)
        running = State()
        cleaning = State()

        run = Event(from_states=sleeping, to_state=running)
        cleanup = Event(from_states=running, to_state=cleaning)
        sleep = Event(from_states=(running, cleaning), to_state=sleeping)

    Base.metadata.create_all(engine)

    Session = sessionmaker(bind=engine)
    session = Session()

    # Note: No state transition occurs between the initial state and when it's saved to the database.
    penguin = Penguin(name='Tux')
    eq_(penguin.current_state, Penguin.sleeping)
    assert penguin.is_sleeping

    session.add(penguin)
    session.commit()

    penguin2 = session.query(Penguin).filter_by(id=penguin.id)[0]

    assert penguin2.is_sleeping

## 三. state_machine 源码解析

### 0. `acts_as_state_machine`

使用状态机的第一步是, 使用 `acts_as_state_machine` 装饰器, 装饰状态机类.

    def acts_as_state_machine(original_class):
        # get_adaptor 是一个适配器, 
        # 其后是 BaseAdaptor, NullAdaptor(默认), MongoAdaptor, SqlAlchemyAdaptor
        adaptor = get_adaptor(original_class)
        global _temp_callback_cache
        modified_class = adaptor.modifed_class(original_class, _temp_callback_cache)
        _temp_callback_cache = None
        return modified_class

`get_adaptor` 是一个适配器调用函数, 其后分别是使用[**适配器设计模式**](https://www.pyfdtic.com/2018/03/20/python-%E8%AE%BE%E8%AE%A1%E6%A8%A1%E5%BC%8F/)实现的几个类. 

- `BaseAdaptor` : 基类.
- `NullAdaptor` : 默认适配器实现.
- `MongoAdaptor` : 适用与 Mongodb 的适配器.
- `SqlAlchemyAdaptor` : 适用于 SQLAlchemy 的适配器.

各适配器的方法的 `modified_class()` 方法, 返回重载过的类(使用 `inspect.getmembers()` 解析), 添加 `current_state` 和 `aasm_state` 属性(两者相等)和 `is_STATE` 属性, 用于返回当前状态和判断是否处于某种状态.
    
    # is_STATE 属性的实现 : 通过为 State 实例添加 property 来实现.
    # state_machine/orm/base.py BaseAdaptor.process_states()

        is_method_string = "is_" + member   # member 是一个 State 实例

        def is_method_builder(member):
            def f(self):
                return self.aasm_state == str(member)

            return property(f)      # 添加 is_STATE 属性.

        is_method_dict[is_method_string] = is_method_builder(member)

### 1. `Event` && `State`

`Event` 和 `State` 只是普通的继承自 `object` 的类, 

- `State` 
    
    实现了一个 `__eq__` 和 `__ne__` 方法, 

    添加了一个 `initial=False` 的参数, 用于定位初始`State`. 

        # state_machine/orm/base.py BaseAdaptor.process_states() : L14
        # 其中的 value 是一个 State 类的实例
        # 最终 BaseAdaptor.process_states 返回该 initial_state.

        if isinstance(value, State):
            if value.initial:
                if initial_state is not None:
                    raise ValueError("multiple initial states!")
                initial_state = value 

        # BaseAdaptor.modifed_class()
        # 其中, extra_class_members() 需要各 Adapter 自实现.
        state_method_dict, initial_state = self.process_states(original_class)
        class_dict.update(self.extra_class_members(initial_state))

        # NullAdaptor
        class NullAdaptor(BaseAdaptor):
            def extra_class_members(self, initial_state):
                return {"aasm_state": initial_state.name}

        # SqlAlchemyAdaptor
        class SqlAlchemyAdaptor(BaseAdaptor):
            def extra_class_members(self, initial_state):
                return {'aasm_state': sqlalchemy.Column(sqlalchemy.String)}                

        # MongoAdaptor
        class MongoAdaptor(BaseAdaptor):
            def extra_class_members(self, initial_state):
                return {'aasm_state': mongoengine.StringField(default=initial_state.name)}

- `Event` 
    
    实时实现了 `__init__()` 方法, 添加了 `from_states` 属性, 是一个数组. 添加了 `to_state` 是一个 State 类实例.
    
### 2. `after` & `before`
用于为状态机类添加 `{'before': {STATE: []}, 'after': {STATE: []}}` 属性. 用于在之前后之后添加钩子函数.

        


