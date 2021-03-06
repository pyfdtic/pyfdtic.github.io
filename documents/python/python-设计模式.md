## 零. 设计模式
设计模式是可复用的且有点语言相关的解决方案. 根据 `Design Patterns: elements of Reusable Object-Oriented Software` 对设计模式的分类, 有如下几种:

- **创建型模式(creational patterns)** : 用于生成具有特定行为的对象.
- **结构型模式(structural patterns)** : 有助于为特定用例构建代码
- **行为模式(behavioral patterns)** : 有助于分配责任和封装行为.

## 一. 创建型模式

创建型模式处理对象创建相关问题, 目标是当直接创建对象不方便时, 提供更好的方式.

### 1. 工厂模式

Python 的类和类型是内置工厂, 可以创建新对象, 并利用元类与类和对象生产进行交互.

在工厂模式中, 客户端(调用者)可以请求一个对象, 而无需知道这个对象使用哪个类生成. 工厂背后的思想是**简化对象的创建**.

与客户端(调用者)自己基于类实例化直接创建对象相比, 基于一个中心化函数来实现, 更易于追踪创建了那些对象. 通过创建对象的代码和使用对象的代码解耦, 工厂能够降低应用维护的复杂度.

工厂有两种形式:

- **工厂方法**: 一个方法(函数)对于不同的输入参数返回不同的对象.
- **抽象工厂**: 是一组用于创建一系列相关事物对象的工厂方法.

#### (1) 工厂方法
在工厂方法模式中, 传入一个参数, 执行单个函数, 但不要求知道任何关于对象如何实现以及对象来自哪里的细节.

如 Django 框架中使用工厂方法模式创建表单字段. Django 的 `forms` 模块支持不同种类字段(charField, EmailField)的创建和订制(max_length, required).

使用场景:

1. 应用创建对象的代码分布在多个不同的地方, 而不是仅在一个函数/方法中, 并且无法跟踪这些对象. 工厂方法集中地在一个地方创建对象, 使对象跟踪变得更容易. 创建多个工厂方法也完全没有问题, 实践中常常对相似的对象创建进行逻辑分组, 每个工厂方法负责一个分组.
2. 将对象的创建和使用解耦. 创建对象时, 并没有与某个特定类耦合/绑定到一起, 而只是通过调用某个函数来提供关于我们想要什么的部分信息. 这意味修改这个函数比较容易, 不需要同时修改使用这个函数的代码.
3. 应用案例与应用性能及内存使用相关. 工厂方法可以在必要时创建新的对象, 从而提高性能和内存使用率.

示例代码:

```Python
import xml.etree.ElementTree as etree
import json

## JSONConnector 和 XMLConnector 类有相同的接口.

class JSONConnector:
    """ 解析 json 格式文件的类"""

    def __init__(self, filepath):
        self.data = dict()
        with open(filepath, mode='r', encoding='utf-8') as f:
            self.data = json.load(f)

    @property
    def parsed_data(self):
        return self.data

class XMLConnector:
    """ 解析 XML 格式文件的类"""

    def __init__(self, filepath):
        self.tree = etree.parse(filepath)

    @property
    def parsed_data(self):
        return self.tree

def connection_factory(filepath):
    """ 一个工厂方法, 基于输入文件路径的扩展名返回一个 JSONConnector 或 XMLConnector 的实例. """

    if filepath.endswith('json'):
        connector = JSONConnector
    elif filepath.endswith('xml'):
        connector = XMLConnector
    else:
        raise ValueError('Cannot connect to {}'.format(filepath))
    return connector(filepath)

def connect_to(filepath):
    """ 对 connection_factory 方法进行包装, 并添加异常处理 """
    factory = None
    try:
        factory = connection_factory(filepath)
    except ValueError as ve:
        print(ve)
    return factory

def main():
    """ 使用工厂方法设计模式 """

    # 确认异常处理是否有效.
    sqlite_factory = connect_to('data/person.sq3')
    print()
    
    # 使用 工厂方法 处理 XML 文件
    xml_factory = connect_to('data/person.xml')
    xml_data = xml_factory.parsed_data
    liars = xml_data.findall(".//{}[{}='{}']".format('person',
                                                     'lastName', 'Liar'))
    print('found: {} persons'.format(len(liars)))
    for liar in liars:
        print('first name: {}'.format(liar.find('firstName').text))
        print('last name: {}'.format(liar.find('lastName').text))
        [print('phone number ({})'.format(p.attrib['type']),
               p.text) for p in liar.find('phoneNumbers')]

    print()
    
    # 使用工厂方法 处理 JSON 文件.
    json_factory = connect_to('data/donut.json')
    json_data = json_factory.parsed_data
    print('found: {} donuts'.format(len(json_data)))
    for donut in json_data:
        print('name: {}'.format(donut['name']))
        print('price: ${}'.format(donut['ppu']))
        [print('topping: {} {}'.format(t['id'], t['type'])) for t in donut['topping']]

if __name__ == '__main__':
    main()
```

#### (2) 抽象工厂
抽象工厂设计模式是抽象方法的一种泛化, 具体来说, 一个抽象工厂是(逻辑上的) 一组工厂方法, 其中的每个工厂方法负责产生不同种类的对象. 因此, 他能提供相同的好处: 让对象的创建更容易追踪; 将对象创建与使用解耦; 提供优化内存占用和应用性能的潜力.

通常一开始使用工厂方法, 因为他更简单. 如果后来发现应用需要许多工厂方法, 那么僵创建一系列对象的过程合并在一起更合理, 从而最终引入抽象工厂.

抽象工厂的一个优点, 在使用工厂方法时, 从用户角度通常是看不到的, 那就是抽象工厂能够通过改变激活的工厂方法动态的(运行时)改变应用行为.

django_factory 是一个用于在测试中创建 Django 模型的抽象工厂实现, 可用来为支持测试专有属性的模型创建实例. 这能让测试代码的可读性更高, 且避免共享不必要的代码.

示例代码: 以下代码演示了一个根据用户输入年龄, 来区分运行不同游戏(青蛙吃虫子 和 巫师打怪兽).

```Python
class Frog:

    def __init__(self, name):
        self.name = name

    def __str__(self):
        return self.name

    def interact_with(self, obstacle):
        print('{} the Frog encounters {} and {}!'.format(self,
                                                         obstacle, obstacle.action()))

class Bug:

    def __str__(self):
        return 'a bug'

    def action(self):
        return 'eats it'


class FrogWorld:
    """ 一个抽象工厂, 主要职责就是创建游戏的主人公和障碍物. 区分创建方法并使其名字通用, 和可以实现动态修改当前激活的工厂, 而无需进行代码变更"""

    def __init__(self, name):
        print(self)
        self.player_name = name

    def __str__(self):
        return '\n\n\t------ Frog World ———'

    def make_character(self):
        return Frog(self.player_name)

    def make_obstacle(self):
        return Bug()


class Wizard:

    def __init__(self, name):
        self.name = name

    def __str__(self):
        return self.name

    def interact_with(self, obstacle):
        print('{} the Wizard battles against {} and {}!'.format(self, obstacle, obstacle.action()))


class Ork:

    def __str__(self):
        return 'an evil ork'

    def action(self):
        return 'kills it'


class WizardWorld:
    """ 抽象工厂, 同 FrogWorld. """

    def __init__(self, name):
        print(self)
        self.player_name = name

    def __str__(self):
        return '\n\n\t------ Wizard World ———'

    def make_character(self):
        return Wizard(self.player_name)

    def make_obstacle(self):
        return Ork()


class GameEnvironment:
    """ 游戏的主入口, 接收 factory 作为输入. """
    def __init__(self, factory):
        self.hero = factory.make_character()
        self.obstacle = factory.make_obstacle()

    def play(self):
        self.hero.interact_with(self.obstacle)


def validate_age(name):
    """验证年龄的有效性"""
    try:
        age = input('Welcome {}. How old are you? '.format(name))
        age = int(age)
    except ValueError as err:
        print("Age {} is invalid, please try \
        again…".format(age))
        return (False, age)
    return (True, age)


def main():
    """ 根据用户输入的年龄, 区分运行不同的游戏"""

    name = input("Hello. What's your name? ")
    valid_input = False
    while not valid_input:
        valid_input, age = validate_age(name)
    game = FrogWorld if age < 18 else WizardWorld
    environment = GameEnvironment(game(name))
    environment.play()

if __name__ == '__main__':
    main()
```    

### 2. 建造者模式
可用于细粒度控制复杂对象的创建过程.

我们想要创建一个由多个部分构成的对象, 而且他的构成需要一步接一步的完成, 只有当各个部分都创建好, 这个对象才完整. 此时, 需要使用 建造者模式.

**建造者模式**将一个复杂对象构建过程预期表现分离, 这样, 同一个构造过程可用于创建多个不同的表现. 该模式有两个参与者: **建造者** 和 **指挥者**. 
- **建造者**: 负责创建复杂对象的各个组成部分.
- **指挥者**: 使用一个建造者实例控制建造过程.

`django-widgy` 是一个 Django 的第三方树编辑器扩展, 可用作内容管理系统. 它包含一个网页构建器, 用来创建具有不同布局的 HTML 页面.

`django-query-builder` 是另一个基于建造者模式的 Django 第三方扩展, 该扩展可用于动态的创建 SQL 查询. 使用他, 我们能够控制一个查询的方方面面, 并能创建不同种类的查询, 从简单的到复杂的都可以.

示例代码:
```Python
from enum import Enum
import time

PizzaProgress = Enum('PizzaProgress', 'queued preparation baking ready')
PizzaDough = Enum('PizzaDough', 'thin thick')
PizzaSauce = Enum('PizzaSauce', 'tomato creme_fraiche')
PizzaTopping = Enum('PizzaTopping', 'mozzarella double_mozzarella bacon ham mushrooms red_onion oregano')
STEP_DELAY = 3          # 考虑是示例，单位为秒


class Pizza:
    """ 最终产品类, 不支持直接实例化. """
    def __init__(self, name):
        self.name = name
        self.dough = None
        self.sauce = None
        self.topping = []

    def __str__(self):
        return self.name

    def prepare_dough(self, dough):
        self.dough = dough
        print('preparing the {} dough of your {}...'.format(self.dough.name, self))
        time.sleep(STEP_DELAY)
        print('done with the {} dough'.format(self.dough.name))


class MargaritaBuilder:
    """ 建造者, 创建 Pizza 示例, 并包含遵从 Pizza 制作流程方法. """
    def __init__(self):
        self.pizza = Pizza('margarita')
        self.progress = PizzaProgress.queued
        self.baking_time = 5        # 考虑是示例，单位为秒

    def prepare_dough(self):
        self.progress = PizzaProgress.preparation
        self.pizza.prepare_dough(PizzaDough.thin)

    def add_sauce(self):
        print('adding the tomato sauce to your margarita...')
        self.pizza.sauce = PizzaSauce.tomato
        time.sleep(STEP_DELAY)
        print('done with the tomato sauce')

    def add_topping(self):
        print('adding the topping (double mozzarella, oregano) to your margarita')
        self.pizza.topping.append([i for i in
                                   (PizzaTopping.double_mozzarella, PizzaTopping.oregano)])
        time.sleep(STEP_DELAY)
        print('done with the topping (double mozzarrella, oregano)')

    def bake(self):
        self.progress = PizzaProgress.baking
        print('baking your margarita for {} seconds'.format(self.baking_time))
        time.sleep(self.baking_time)
        self.progress = PizzaProgress.ready
        print('your margarita is ready')


class CreamyBaconBuilder:
    """ 建造者, 创建 Pizza 示例, 并包含遵从 Pizza 制作流程方法. """
    def __init__(self):
        self.pizza = Pizza('creamy bacon')
        self.progress = PizzaProgress.queued
        self.baking_time = 7        # 考虑是示例，单位为秒

    def prepare_dough(self):
        self.progress = PizzaProgress.preparation
        self.pizza.prepare_dough(PizzaDough.thick)

    def add_sauce(self):
        print('adding the crème fraîche sauce to your creamy bacon')
        self.pizza.sauce = PizzaSauce.creme_fraiche
        time.sleep(STEP_DELAY)
        print('done with the crème fraîche sauce')

    def add_topping(self):
        print('adding the topping (mozzarella, bacon, ham, mushrooms, red onion, oregano) to your creamy bacon')
        self.pizza.topping.append([t for t in
                                   (PizzaTopping.mozzarella, PizzaTopping.bacon,
                                    PizzaTopping.ham, PizzaTopping.mushrooms,
                                    PizzaTopping.red_onion, PizzaTopping.oregano)])
        time.sleep(STEP_DELAY)
        print('done with the topping (mozzarella, bacon, ham, mushrooms, red onion, oregano)')

    def bake(self):
        self.progress = PizzaProgress.baking
        print('baking your creamy bacon for {} seconds'.format(self.baking_time))
        time.sleep(self.baking_time)
        self.progress = PizzaProgress.ready
        print('your creamy bacon is ready')


class Waiter:
    """指挥者, 接受一个建造者作为参数, 并以正确的顺序执行 Pizza 的所有准备步骤.  选择恰当的建造者, 无需修改指挥者代码, 即可实现制作不同的 Pizza."""
    def __init__(self):
        self.builder = None

    def construct_pizza(self, builder):
        self.builder = builder
        [step() for step in (builder.prepare_dough,
                             builder.add_sauce, builder.add_topping, builder.bake)]

    @property
    def pizza(self):
        return self.builder.pizza


def validate_style(builders):
    """ 输入有效性检查."""
    try:
        pizza_style = input('What pizza would you like, [m]argarita or [c]reamy bacon? ')
        builder = builders[pizza_style]()
        valid_input = True
    except KeyError as err:
        print('Sorry, only margarita (key m) and creamy bacon (key c) are available')
        return (False, None)
    return (True, builder)


def main():
    """ 实例化一个建造者, 然后指挥者使用建造者创建 Pizza,完成交付给用户. """
    builders = dict(m=MargaritaBuilder, c=CreamyBaconBuilder)
    valid_input = False
    while not valid_input:
        valid_input, builder = validate_style(builders)
    print()
    waiter = Waiter()
    waiter.construct_pizza(builder)
    pizza = waiter.pizza
    print()
    print('Enjoy your {}!'.format(pizza))

if __name__ == '__main__':
    main()
```

#### 2.2 流利的建造者: 链式调用建造者方法, 一个建造者的变体.
**流利的建造者** 是一种建造者模式的变体, 该变体会链式地调用建造者方法, 通过将建造者本身定义为内部类并从其每个设置器方法返回自身来实现. `builder()` 方法返回最终的对象.
    
```Python
class Pizza:

    def __init__(self, builder):
        self.garlic = builder.garlic
        self.extra_cheese = builder.extra_cheese

    def __str__(self):
        garlic = 'yes' if self.garlic else 'no'
        cheese = 'yes' if self.extra_cheese else 'no'
        info = ('Garlic: {}'.format(garlic), 'Extra cheese: {}'.format(cheese))
        return '\n'.join(info)

    class PizzaBuilder:

        def __init__(self):
            self.extra_cheese = False
            self.garlic = False

        def add_garlic(self):
            self.garlic = True
            return self

        def add_extra_cheese(self):
            self.extra_cheese = True
            return self

        def build(self):
            return Pizza(self)      # 注意此处的实例化.

if __name__ == '__main__':
    pizza = Pizza.PizzaBuilder().add_garlic().add_extra_cheese().build()
    print(pizza)
```

### 3. 原型模式
用于克隆对象.

**原型设计模式(Prototype design pattern)** 用于创建对象的克隆, 其最简单的形式就是一个 `clone()` 函数, 结构一个对象作为输入参数, 返回输入对象的一个副本. 在 Python 可以用 `copy.deepcopy()` 函数来完成.

很多 Python 应用都使用了原型模式, 但几乎都不称之为原型模式, 因为对象克隆是编程语言的一个内置特性.

**引用与副本**引用可以理解为执行对象的一个指针. 副本可以进一步分为深副本与浅副本. 深副本即原始对象的所有数据都被简单的复制到克隆对象中, 没有例外. 浅副本则依赖引用. 可以引入数据共享和写时复制一类的技术来优化性能和内存使用. 如果可用资源有限或性能至关重要, 那么使用浅副本可能更佳. 

Python 中的浅副本(`copy.copy()`)及深副本(`copy.deepcopy()`):

- 浅副本(`copy.copy()`) : 浅副本构造一个新的复合对象后, (会尽可能的)将在原始对象中找到的对象的引用插入新对象中.
- 深副本(`copy.deepcopy()`) : 深副本构造一个新的复合对象后, 会递归的将在原始对象中找到的对象的副本插入新对象中.

代码实例:
```Python
import copy
from collections import OrderedDict

class Book:

    def __init__(self, name, authors, price, **rest):
        '''rest的例子有：出版商，长度，标签，出版日期'''
        self.name = name
        self.authors = authors
        self.price = price      # 单位为美元
        self.__dict__.update(rest)

    def __str__(self):
        mylist = []
        # OrderedDict : 保证元素有序.
        ordered = OrderedDict(sorted(self.__dict__.items()))
        for i in ordered.keys():
            mylist.append('{}: {}'.format(i, ordered[i]))
            if i == 'price':
                mylist.append('$')
            mylist.append('\n')
        return ''.join(mylist)


class Prototype:
    """ 实现了原型设计模式. 其核心为 clone() 方法. """
    def __init__(self):
        self.objects = dict()

    def register(self, identifier, obj):
        """ 用于在一个字典中, 追踪被克隆的对象 """
        self.objects[identifier] = obj

    def unregister(self, identifier):
        """ 用于在一个字典中, 追踪被克隆的对象 """
        del self.objects[identifier]

    def clone(self, identifier, **attr):
        """ attr 可以仅传递那些在克隆了一个对象时真正需要变更的属性变量. """
        found = self.objects.get(identifier)
        if not found:
            raise ValueError('Incorrect object identifier: {}'.format(identifier))
        obj = copy.deepcopy(found)
        obj.__dict__.update(attr)
        return obj


def main():
    """ 克隆书籍的多个版本 """
    b1 = Book('The C Programming Language', ('Brian W. Kernighan', 'Dennis M.Ritchie'), price=118, publisher='Prentice Hall',
              length=228, publication_date='1978-02-22', tags=('C', 'programming', 'algorithms', 'data structures'))

    prototype = Prototype()
    cid = 'k&r-first'
    prototype.register(cid, b1)
    b2 = prototype.clone(cid, name='The C Programming Language(ANSI)', price=48.99,
                         length=274, publication_date='1988-04-01', edition=2)

    for i in (b1, b2):
        print(i)
    print('ID b1 : {} != ID b2 : {}'.format(id(b1), id(b2)))

if __name__ == '__main__':
    main()
```

### 4. 单例模式
单例(Singletom)模式限制 类的实例化, 只能实例化一个对象. 通常有以下集中实现方法:

**单例不应该有几个层级的继承, 标记为单例的类已经是特定的**.

1. 重写 `__new__()` 方法
    
    这种实现方法比较危险, 因为 重写 `__new__()` 方法后, 在子类的继承中, 将会出现难以调试的 bug : 类实例的创建顺序, 将影响类本身.

    ```Python
    class Singleton:
        _instance = None

        def __new__(cls, *args, **kwargs):
            if cls._instance is None:
                cls._instance = super().__new__(cls, *args, **kwargs)

            return cls._instance

    ins_a = Singleton()
    ins_b = Singleton()

    print(id(ins_a) == id(ins_b))   # True
    print(ins_a == ins_b)           # True

    # 类的创建顺序将影响类实例本身: 

    class ConcreteClass(Singleton):
        pass

    print(Singleton())      # <__main__.Singleton object at 0x055B4570>
    print(ConcreteClass())  # <__main__.Singleton object at 0x055B4570>

    print(ConcreteClass())  # <__main__.ConcreteClass object at 0x05504570>
    print(Singleton())      # <__main__.Singleton object at 0x05504530>
    ```

2. 通过元类实现, 通过重写 `__call__()` 方法, 可以影响自定义类的创建.
    
    可以创建一个可重用的单实例, 可以安全子类化, 并且与实例创建顺序无关.

    ```Python
    class Singleton:
        _instances = {}

        def __call__(cls, *args, **kwargs):
            if cls not in cls._instances:
                cls._instances[cls] = super().__call__(*args, **kwargs)

            return cls._instances[cls]

    class ConcreteClass(Singleton):
        pass

    class ConcreteSubClass(ConcreteClass):
        pass

    print(Singleton()) # <__main__.Singleton object at 0x051C4570>
    print(ConcreteClass())  # <__main__.ConcreteClass object at 0x051C4570>
    print(ConcreteSubClass())  # <__main__.ConcreteSubClass object at 0x051C4570>
    ```

3. 使用装饰器实现

    ```Python
    def singleton(cls, *args, **kw):  
        instances = {}  
        def _singleton():  
            if cls not in instances:  
                instances[cls] = cls(*args, **kw)  
            return instances[cls]  
        return _singleton  
     
    @singleton  
    class MyClass4(object):  
        """ 单例类本身根本不知道自己是单例的,因为他本身(自己的代码)并不是单例的 """
        a = 1  
        def __init__(self, x=0):  
            self.x = x  
      
    one = MyClass4()  
    two = MyClass4()  
      
    two.a = 3  
    print one.a  
    #3  
    print id(one)  
    #29660784  
    print id(two)  
    #29660784  
    print one == two  
    #True  
    print one is two  
    #True  
    one.x = 1  
    print one.x  
    #1  
    print two.x  
    #1 
    ```

## 二. 结构型模式

结构型设计模式处理一个系统中不同实体之间的关系, 关注的是提供一种简单的对象组合方式来创造新功能.
结构型模式在大型应用中非常重要, 他决定代码的组织方式, 并告诉开发人员如何与应用程序的每个部分进行交互.

### 1. 适配器模式

**适配器模式(Adapter pattern)**是一种结构型设计模式, 帮助我们实现两个不兼容接口之间的兼容. 例如, 我们可以编写一个额外的代码层, 该代码层实现新老两个接口之间能够通信的所有修改. 这个代码层即为适配器. 这种模式在无法修改新老接口源码的情况下, 尤其有用.

Grok 是一个 Python 框架, 运行在 Zope3 之上, 专注于敏捷开发. Grok 框架使用适配器, 让已有对象无需变更就能符合指定 API 的标准.

**开放/封闭原则**是面向对象设计的基本原则之一, 声明一个软件实体应该对扩展是开放的, 对修改则是封闭的.本质上, 这意味着我们应该无需修改一个软件实体的源代码就能扩展其行为. 适配器模式遵从开放/封闭原则.

示例代码一, 使用**更新字典**方式实现:
```Python
class Synthesizer:

    def __init__(self, name):
        self.name = name

    def __str__(self):
        return 'the {} synthesizer'.format(self.name)

    def play(self):
        return 'is playing an electronic song'

class Human:

    def __init__(self, name):
        self.name = name

    def __str__(self):
        return '{} the human'.format(self.name)

    def speak(self):
        return 'says hello'

class Computer:

    def __init__(self, name):
        self.name = name

    def __str__(self):
        return 'the {} computer'.format(self.name)

    def execute(self):
        return 'executes a program'

class Adapter:
    """ 适配器类, 将一些带不同接口的对象适配到一个统一接口中. """
    def __init__(self, obj, adapted_methods):
        """ obj 为需要适配的对象, adapted_methods 是一个字典, 键值对中的键是客户端要调用的方法(execute), 值是应该被调用的方法."""
        self.obj = obj
        self.__dict__.update(adapted_methods)

    def __str__(self):
        return str(self.obj)

def main():
    """ 使用适配器模式. """
    objects = [Computer('Asus')]
    synth = Synthesizer('moog')
    objects.append(Adapter(synth, dict(execute=synth.play)))
    human = Human('Bob')
    objects.append(Adapter(human, dict(execute=human.speak)))

    for i in objects:
        print('{} {}'.format(str(i), i.execute()))

if __name__ == "__main__":
    main()
```

示例代码二, 使用**子类(继承)**方式实现:

#### 抽象基类(Abstract Base Classes, ABC)
抽象基类是 Python 支持构建轻量级替代**接口**的核心. ABC 是一个不需要提供具体实现的类, 而是定义了可用于**检查类型兼容性**的蓝图类.

抽象基类用于两个目的:

- 检查实现完整性
- 检查隐式接口兼容性

使用特殊的 **ABCMeta 元类** 和 **abstractmethod()装饰器** 可以创建新的抽象基类.

```Python
from abc import ABCMeta, abstractmethod

class Pushable(metaclass=ABCMeta):
    @abstractmethod
    def push(self, x):
        """ 推入任意参数 """
        pass

    @classmethod
    def __subclasshook__(cls, C):
        """ 该方法可以实现将自己的逻辑注入到已确定对象是否是给定类的实例的过程中.
        这样, 隐式实现接口的实例也会被视为接口的实例.
        """
        if cls is Pushable:
            if any("push" in B.__dict__ for B in C.__mro__):
                return True
        return NotImplemented

class DummyPushable(Pushable):
    """ 是 Pushable 的子类 """
    def push(self, x):
        return True

class IncompletePushable(Pushable):
    """ 该类在实例化时, 将会出错, 因为没有实现 push() 方法.
    """
    pass

class SomethingWithPush:
    """ 不是 Pushable 的子类 """
    def push(self, x):
        pass

isinstance(DummyPushable(), Pushable)

# Pushable 没实现 __subclasshook__ 方法时, 返回 False
# 实现后, 返回 True
print(isinstance(SomethingWithPush(), Pushable))
```

`collections.abc` 模块提供了许多预定义的 抽象基类(ABC), 这些基类可以验证许多基本的 Python 类型的接口兼容性. 结合 `isinstance()` 函数使用它们比基于 Python 类型的比较更好.

- `Container` : 对象支持 `in` 运算符, 并实现 `__contains__()` 方法.
- `Iterable` : 对象支持迭代, 并实现 `__iter__()`
- `Callable` : 对象可以像一个函数一样被调用, 并实现了 `__call__()` 方法.
- `Hashable` : 对象是可哈希的(可以包含在集合中, 作为字典的键), 并实现 `__hash__()` 方法.
- `Sized` : 对象具有大小(可以是函数 len() 的主体), 并实现 `__len__()` 方法.

### 2. 修饰器模式
给一个对象添加额外的功能, 有以下几种不同的方法:

- 直接将功能添加到对象所属的类.
- 使用组合
- 使用继承.
- 修饰器

**修饰器(Decorator)模式**能够以透明的方式不影响其他对象, 动态地将功能添加到一个对象中. 在 Python 中, 可以使用内置的修饰器特性.

一个 Python 修饰器就是对 Python 语法的一个特定改变, 用于扩展一个类, 方法 或 函数的行为, 而无需使用继承. 从实现的角度来说, Python 修饰器是一个可调用对象(函数, 方法, 类), 接受一个函数对象作为输入, 并返回另一个函数对象. 这意味着可以将任何具有这些属性的可调用对象当做一个修饰器.

修饰器模式和 Python 修饰器**不是**一对一的等价关系. Python 修饰器能做的实际上比修饰器模式多得多, 其中之一就是实现修饰器模式.

Django 框架大量的使用修饰器, 例如视图修饰器 可以限制某些 HTTP 请求对视图的访问, 控制特定视图上的缓存行为, 按单个视图控制压缩, 基于特定 HTTP 请求头控制缓存.

#### 使用场景: 实现横切关注点
一般来说, 应用中有些部件时通用的, 可应用于其他部件, 这样的部件可以被看做横切关注点. 以下是横切关注点的例子:

- 数据校验
- 事务处理(类似数据库事务)
- 缓存
- 日志
- 监控
- 调试
- 业务规划
- 压缩
- 加密

代码示例: memoization 装饰器, 所有递归函数都能因 memoization 而提速.
```Python
import functools

def memoize(fn):
    known = dict()

    @functools.wraps(fn)
    def memoizer(*args):
        if args not in known:
            known[args] = fn(*args)
        return known[args]

    return memoizer


@memoize
def nsum(n):
    '''返回前n个数字的和'''
    assert(n >= 0), 'n must be >= 0'
    return 0 if n == 0 else n + nsum(n-1)


@memoize
def fibonacci(n):
    '''返回斐波那契数列的第n个数'''
    assert(n >= 0), 'n must be >= 0'
    return n if n in (0, 1) else fibonacci(n-1) + fibonacci(n-2)

if __name__ == '__main__':
    from timeit import Timer
    measure = [{'exec': 'fibonacci(100)', 'import': 'fibonacci',
                'func': fibonacci}, {'exec': 'nsum(200)', 'import': 'nsum',
                                     'func': nsum}]
    for m in measure:
        t = Timer('{}'.format(m['exec']), 'from __main__ import \
            {}'.format(m['import']))
        print('name: {}, doc: {}, executing: {}, time: \
            {}'.format(m['func'].__name__, m['func'].__doc__,
                       m['exec'], t.timeit()))

```
代码示例: 可接受参数的装饰器, 实现运行时决定是否执行装饰器.
```Python
def memoize(use=True):

    def wrap(fn):
        known = dict()

        @functools.wraps(fn)
        def memoizer(*args):
            if not use:
                return fn(*args)
            if args not in known:
                known[args] = fn(*args)
            return known[args]

        return memoizer
    return wrap

@memoize(use=True)
def fibonacci(n):
    '''返回斐波那契数列的第n个数'''
    assert(n >= 0), 'n must be >= 0'
    return n if n in (0, 1) else fibonacci(n-1) + fibonacci(n-2)
```

### 3. 外观模式
外观设计模式有助于隐藏系统的内部复杂性, 并通过一个简化的接口向客户端暴露必要的部分. 本质上, **外观(Facade)**是在已有复杂系统之上实现的一个抽象层. 例如, 现实生活中, 公司的客服部门在顾客和公司内部业务部门之间充当一个外观的角色.

外观模式有点:

1. 为一个复杂系统提供单个简单的入口点. 引入外观之后, 客户端代码通过简单地调用一个方法/函数就能使用一个系统.
2. 系统内部的改变不会影响客户端使用, 客户端无需关心这个改变, 也不受这个改变影响.
3. 当系统包含多层时, 为每一层引入一个外观入口点, 并让所有层级通过他们的外观相互通信. 可以提高层级之间的松耦合性, 尽可能保持层级独立.

示例代码:

```Python
from enum import Enum
from abc import ABCMeta, abstractmethod

# Enum 类型描述一个服务进程的不同状态.
State = Enum('State', 'new running sleeping restart zombie')

class User:
    pass


class Process:
    pass


class File:
    pass


class Server(metaclass=ABCMeta):
    """ 使用 abc 模块来禁止对 Server 接口直接进行初始化, 并强制子类实现 boot() 和 kill() 方法.
    """

    @abstractmethod
    def __init__(self):
        """ abstractmethod 装饰的方法, 子类都必须实现该方法.
        """
        pass

    def __str__(self):
        return self.name

    @abstractmethod
    def boot(self):
        pass

    @abstractmethod
    def kill(self, restart=True):
        pass


class FileServer(Server):

    def __init__(self):
        '''初始化文件服务进程要求的操作'''
        self.name = 'FileServer'
        self.state = State.new

    def boot(self):
        print('booting the {}'.format(self))
        '''启动文件服务进程要求的操作'''
        self.state = State.running

    def kill(self, restart=True):
        print('Killing {}'.format(self))
        '''杀死文件服务进程要求的操作'''
        self.state = State.restart if restart else State.zombie

    def create_file(self, user, name, permissions):
        '''自定义方法, 检查访问权限的有效性、用户权限，等等'''

        print("trying to create the file '{}' for user '{}' with permissions {}".format(name, user, permissions))


class ProcessServer(Server):

    def __init__(self):
        '''初始化进程服务进程要求的操作'''
        self.name = 'ProcessServer'
        self.state = State.new

    def boot(self):
        print('booting the {}'.format(self))
        '''启动进程服务进程要求的操作'''
        self.state = State.running

    def kill(self, restart=True):
        print('Killing {}'.format(self))
        '''杀死进程服务进程要求的操作'''
        self.state = State.restart if restart else State.zombie

    def create_process(self, user, name):
        '''自定义方法, 检查用户权限、生成PID，等等'''

        print("trying to create the process '{}' for user '{}'".format(name, user))


class WindowServer:
    pass


class NetworkServer:
    pass


class OperatingSystem:

    '''外观'''

    def __init__(self):
        """ 创建所有需要的 服务进程实例 """
        self.fs = FileServer()
        self.ps = ProcessServer()

    def start(self):
        """ 系统入口点, 供 客户端代码使用. """
        [i.boot() for i in (self.fs, self.ps)]

    def create_file(self, user, name, permissions):
        return self.fs.create_file(user, name, permissions)

    def create_process(self, user, name):
        return self.ps.create_process(user, name)


def main():
    os = OperatingSystem()
    os.start()

    # 客户端可以调用方法创建文件和进程, 但它们是模拟的.
    os.create_file('foo', 'hello', '-rw-r-r')
    os.create_process('bar', 'ls /tmp')

if __name__ == '__main__':
    main()
```

### 4. 享元模式
享元设计模式通过相似对象引入数据共享来最小化内存使用, 提升性能. 一个**享元(Flyweight)**就是一个包含状态独立的不可变(又称固有的)数据的共享对象. 依赖状态的可变(又称非固有的)数据不应是享元的一部分, 因为每个对象的这种信息都不同, 无法共享. 如果享元需要非固有的数据, 应该有客户端代码显式的提供.

享元模式是一个用于优化的设计模式. 旨在优化性能和内存使用. 所有嵌入式系统和性能关键的应用 都能从中受益. **重点在 将不可变(可共享)的属性和可变的属性区分开**

享元模式有效的几个前提条件:

- 应用需要使用大量的对象;
- 对象太多, 存储/渲染他们的代价太大.一旦移除对象中的可变状态, 多组不同的对象可被相对更少的共享状态所替代.
- 对象 ID 对于 应用不重要. 对象共享会造成 ID 比较的失败, 所以不能依赖对象 ID .

**memoization 与 享元模式之间的区别**

- memoization 是一种优化技术, 使用一个缓存来避免重复计算那些在更早的执行步骤中已经计算好的结果. memoization 并不只能应用于某种特定的编程方式, 如 OOP. 也可以用于方法和简单的函数.
- 享元是一种特定于面向对象编程优化的设计模式, 关注的共享对象数据.

在 Python 中, 享元可以以多种方式实现.

示例代码: 使用元类实现

```Python
import random
from enum import Enum

TreeType = Enum('TreeType', 'apple_tree cherry_tree peach_tree')


class Tree:

    # pool 类属性, 是一个对象池, 类的所有实例共享该变量.
    pool = dict()

    def __new__(cls, tree_type):
        """ __new__() 在 __init__() 之前调用.
        把 Tree 编程一个元类, 元类支持自引用. 这意味着 cls 引用的是 Tree 类.
        当客户端要创建 Tree 的一个实例时, 会以 tree_type 参数传递数的种类. 
        树的种类用于检查是否创建过相同的树, 如果是, 则返回之前创建的对象, 
        否则将新的树种类添加到池中, 并返回相应的新对象.
        """
        obj = cls.pool.get(tree_type, None)
        if not obj:
            obj = object.__new__(cls)
            cls.pool[tree_type] = obj
            obj.tree_type = tree_type
        return obj

    def render(self, age, x, y):
        """ 用于渲染一颗树. 享元不知道的所有可变信息都由客户端代码显式传递."""
        print('render a tree of type {} and age {} at ({}, {})'.format(self.tree_type, age, x, y))


def main():
    """如何使用 享元模式. """
    rnd = random.Random()
    age_min, age_max = 1, 30    # 单位为年
    min_point, max_point = 0, 100
    tree_counter = 0

    for _ in range(10):
        t1 = Tree(TreeType.apple_tree)
        t1.render(rnd.randint(age_min, age_max),
                  rnd.randint(min_point, max_point),
                  rnd.randint(min_point, max_point))
        tree_counter += 1

    for _ in range(3):
        t2 = Tree(TreeType.cherry_tree)
        t2.render(rnd.randint(age_min, age_max),
                  rnd.randint(min_point, max_point),
                  rnd.randint(min_point, max_point))
        tree_counter += 1

    for _ in range(5):
        t3 = Tree(TreeType.peach_tree)
        t3.render(rnd.randint(age_min, age_max),
                  rnd.randint(min_point, max_point),
                  rnd.randint(min_point, max_point))
        tree_counter += 1

    print('trees rendered: {}'.format(tree_counter))
    print('trees actually created: {}'.format(len(Tree.pool)))

    t4 = Tree(TreeType.cherry_tree)
    t5 = Tree(TreeType.cherry_tree)
    t6 = Tree(TreeType.apple_tree)
    # 享元模式不能依赖对象的 ID.
    print('{} == {}? {}'.format(id(t4), id(t5), id(t4) == id(t5)))
    print('{} == {}? {}'.format(id(t5), id(t6), id(t5) == id(t6)))

if __name__ == '__main__':
    main()
```
### 5. 模型-视图-控制器模式
**关注点分离(Separation of Concerns, SoC)**原则是软件工程相关的设计原则之一. SoC 原则背后的思想是讲一个应用切分成不同的部分, 每个部分解决一个单独的关注点. 分层设计中的层次(数据访问层, 业务逻辑层, 表示层), 即是关注点的例子. 使用 SoC 原则能简化软件应用的开发和维护.

**模型-视图-控制器(Model-View-Controller, MVC)**模式是应用到面向对象编程的 SoC 原则. MVC 被认为是一种架构模式, 而不是一种设计模式. 架构模式和设计模式之间的区别在于前者比后者的范畴更广.

- **模型**是**核心**的部分, 代表着应用的信息本源, 包含和管理(业务)逻辑, 数据和状态以及应用的规则.
- **视图**是模型的可视化表现, 它只展示数据, 并不处理数据.
- **控制器**是模型和视图至今的链接/粘附. 模型和视图之间的所有通信都通过控制器进行.

MVC 是一个非常通用且大有用处的设计模式. 实际上, 所有流行的 Web 框架(Django, Rails, Yii) 和应用框架(iPhone SDK, Android 和 QT) 都使用了 MVC 或者其变种. 如 *模式-视图-适配器(Model-View-Adapter, MVA)*, *模型-视图-演示者(Model-View-Presenter, MVP)*等.

从头开始实现 MVC 时, 请确保创建的**模型很智能**, **控制器很瘦**, **视图很傻瓜**.

1. **智能模型**
    
    - 包含所有的校验/业务规则/逻辑
    - 处理应用的状态
    - 访问应用数据(数据库, 云或其他)
    - 不依赖 UI

2. **瘦控制器**
    
    - 在用户与视图交互时, 更新模型
    - 在模型改变时, 更新视图
    - 如果需要, 在数据传递给模型/视图之前进行处理
    - 不展示数据
    - 不直接访问应用数据
    - 不包含校验/业务规则/逻辑

3. **傻瓜视图**
    
    - 展示数据
    - 允许用户与其交互
    - 仅做最小的数据处理, 通常有一种模板语言提供处理能力
    - 不存储任何数据
    - 不直接访问应用数据
    - 不包含校验/业务规则/逻辑


示例代码
```Python
quotes = ('A man is not complete until he is married. Then he is finished.',
          'As I said before, I never repeat myself.',
          'Behind a successful man is an exhausted woman.',
          'Black holes really suck...', 'Facts are stubborn things.')


class QuoteModel:
    """ 模型"""
    def get_quote(self, n):
        try:
            value = quotes[n]
        except IndexError as err:
            value = 'Not found!'
        return value


class QuoteTerminalView:
    """ 视图 """
    def show(self, quote):
        print('And the quote is: "{}"'.format(quote))

    def error(self, msg):
        print('Error: {}'.format(msg))

    def select_quote(self):
        return input('Which quote number would you like to see?')


class QuoteTerminalController:
    """ 控制器, 负责协调 """
    def __init__(self):
        self.model = QuoteModel()
        self.view = QuoteTerminalView()

    def run(self):
        valid_input = False
        while not valid_input:
            n = self.view.select_quote()
            try:
                n = int(n)
            except ValueError as err:
                self.view.error("Incorrect index '{}'".format(n))
            else:
                valid_input = True
        quote = self.model.get_quote(n)
        self.view.show(quote)


def main():
    """初始化并触发控制器."""
    controller = QuoteTerminalController()
    while True:
        controller.run()

if __name__ == '__main__':
    main()
```

### 6. 代理模式

**代理设计模式(Proxy design pattern)**使用代理对象在访问实际对象之前执行重要操作. 有 4 中不同的代理类型:

1. **远程代理**: 实际存在不同地址空间的对象在本地的代理者.
    
    对象关系映射(Object-Relational Mapping, ORM) API 也是一个如何使用远程代理的例子. 提供类 OOP 的关系型数据库访问. 即 ORM 是关系型数据库的代理, 数据库可以部署在任何地方.

2. **虚拟代理**: 用于懒初始化, 讲一个大计算量对象的创建延迟到真正需要的时候进行.
    
    示例代码:

    ```Python
    class LazyProperty:

        def __init__(self, method):
            self.method = method
            self.method_name = method.__name__
            print('function overriden: {}'.format(self.method))
            print("function's name: {}".format(self.method_name))

        def __get__(self, obj, cls):
            """使用值来替代方法. 这意味着 特性是惰性加载的, 而且仅可以设置一次. """
            if not obj:
                return None
            value = self.method(obj)
            print('value {}'.format(value))
            setattr(obj, self.method_name, value)
            return value

    class Test:

        def __init__(self):
            self.x = 'foo'
            self.y = 'bar'

            self._resource = None   # 希望懒加载的变量

        @LazyProperty
        def resource(self):
            print('initializing self._resource which is: {}'.format(self._resource))
            self._resource = tuple(range(5))    # 代价大的
            return self._resource

    def main():
        t = Test()
        print(t.x)
        print(t.y)
        # 做更多的事情。。。
        print(t.resource)
        print(t.resource)

    if __name__ == '__main__':
        main()
    ```

    在 OOP 中有两种基本的, 不同类型的**懒初始化(懒加载)**:

    - **在实例级** : 这意味着会一个对象的特性进行懒初始化, 但该特性有一个对象作用域. 同一个类的每个实例(对象)都有自己的(不同的)特性副本.
    - **在类级或模块级** : 在这种情况下, 我们不希望每个实例都有一个不同的 特性副本, 而是所有实例共享同一个特性, 而特性是懒初始化的.

3. **保护/防护代理**: 控制对敏感对象的访问.

    示例代码:

    ```Python
    class SensitiveInfo:

        def __init__(self):
            self.users = ['nick', 'tom', 'ben', 'mike']

        def read(self):
            print('There are {} users: {}'.format(len(self.users), ' '.join(self.users)))

        def add(self, user):
            self.users.append(user)
            print('Added user {}'.format(user))

    class Info:

        '''SensitiveInfo的保护代理'''

        def __init__(self):
            self.protected = SensitiveInfo()
            self.secret = '0xdeadbeef'

        def read(self):
            self.protected.read()

        def add(self, user):
            sec = input('what is the secret? ')
            self.protected.add(user) if sec == self.secret else print("That's wrong!")

    def main():
        info = Info()
        while True:
            print('1. read list |==| 2. add user |==| 3. quit')
            key = input('choose option: ')
            if key == '1':
                info.read()
            elif key == '2':
                name = input('choose username: ')
                info.add(name)
            elif key == '3':
                exit()
            else:
                print('unknown option: {}'.format(key))

    if __name__ == '__main__':
        main()
    ```

4. **智能(引用)代理**: 在对象被访问时执行额外的动作.包括引用计数和线程安全检查.
    
    Python 的 `weakref` 模块包含一个 `proxy()` 方法, 该方法接受一个输入对象并将一个智能代理返回给该对象. 弱引用是为对象添加引用计数支持的一种推荐方法.


## 三. 行为型模式

行为型模式通过结构化他们的交互过程来简化类之间的交互.

### 1. 责任链模式
**责任链(Chain of Responsibility)** 模式用于让多个对象来处理单个请求时, 或用于预先不知道应该由那个对象(来自某个对象链)来处理某个特定请求. 这一模式的价值在于**解耦**, 客户端与所有处理程序(一个处理程序与其他处理程序之间也是如此)之间不再是多对多的关系, 客户端仅需知道如何与链的起始节点(标头)进行通信.

责任链设计模式有如下**原则**:

- 存在一个对象链(链表, 树或任何其他便捷的数据结构)
- 一开始将请求发送给链中的第一个对象
- 对象决定其是否要处理该请求
- 对象将请求装发给下一个对象.
- 重复该过程, 直到到达链尾.
- 客户端仅知道 对象链中的第一个对象, 而非拥有对所有处理元素的引用; 并且每个元素仅知道其直接的下一个邻居, 而不知道所有其他处理元素. 即对象链通常为一个单项关系.

在基于事件的编程中, 多个对象需要对同一个请求进行处理. 即单个事件可被多个事件监听者捕获.

示例代码: **实现一个简单的事件系统, 使用动态分发来处理请求**.

```Python
class Event:
    """ 描述一个事件 """
    def __init__(self, name):
        self.name = name

    def __str__(self):
        return self.name

class Widget:
    """ 核心类."""
    def __init__(self, parent=None):
        self.parent = parent    # parent 聚合关系表明每个控件都有一个到父对象的引用.

    def handle(self, event):
        """ 动态分发, 事件作为参数传递给方法.
        通过 hasattr() 和 getattr() 决定一个特定请求的处理方法 
        """
        handler = 'handle_{}'.format(event)
        if hasattr(self, handler):
            method = getattr(self, handler)
            method(event)
        elif self.parent:
            # 使用父子关系作为回退机制.
            self.parent.handle(event)
        elif hasattr(self, 'handle_default'):
            # 父子对象中, 父对象必须要有 handle_default 方法.
            self.handle_default(event)

class MainWindow(Widget):

    def handle_close(self, event):
        print('MainWindow: {}'.format(event))

    def handle_default(self, event):
        print('MainWindow Default: {}'.format(event))

class SendDialog(Widget):

    def handle_paint(self, event):
        print('SendDialog: {}'.format(event))

class MsgText(Widget):

    def handle_down(self, event):
        print('MsgText: {}'.format(event))

def main():
    mw = MainWindow()
    sd = SendDialog(mw)     # 注意传入的参数, 父子关系
    msg = MsgText(sd)       # 注意传入的参数, 父子关系

    for e in ('down', 'paint', 'unhandled', 'close'):
        evt = Event(e)
        print('\nSending event -{}- to MainWindow'.format(evt))
        mw.handle(evt)
        print('Sending event -{}- to SendDialog'.format(evt))
        sd.handle(evt)
        print('Sending event -{}- to MsgText'.format(evt))
        msg.handle(evt)

if __name__ == '__main__':
    main()
```

### 2. 命令模式
**命令模式(Command pattern)**可以将一个操作(撤销, 重做, 复制, 粘贴等) 封装成一个对象. 这意味着, 创建一个类, 包含实现该操作所需要的所有逻辑和方法.

**优势**:

- 无需直接执行一个命令.
- 调用命令的对象与指导如何执行命令的对象解耦. 调用者无需知道命令的任何实现细节.
- 如果有意义, 可以把多个命令组织起来, 并按顺序执行. 例如在, 实现一个多层撤销命令时, 这是很有用的.

**使用场景**:

- GUI 按钮和菜单项 : 如 PyQT 使用命令模式实现按钮和菜单项上的动作.
- 其他操作 : 命令模式可用于实现任何操作, 如撤销, 剪切, 赋值, 粘贴, 重做和文本大写.
- 事务性行为和日志记录 : 事务性行为和日志记录对于为变更记录一份持久化日志是非常重要的.
- 宏 : 宏只一个动作序列, 可在任意时间按要求进行录制和执行. 

示例代码: 文件新建, 写入, 读取, 删除操作

```Python
import os

verbose = True  # 一个全局标记, 被激活时向用户反馈执行的操作.

class RenameFile:

    def __init__(self, path_src, path_dest):
        self.src, self.dest = path_src, path_dest

    def execute(self):
        """ 执行操作. """
        if verbose:
            print("[renaming '{}' to '{}']".format(self.src, self.dest))
        os.rename(self.src, self.dest)

    def undo(self):
        """ 撤销操作. """
        if verbose:
            print("[renaming '{}' back to '{}']".format(self.dest, self.src))
        os.rename(self.dest, self.src)

class CreateFile:

    def __init__(self, path, txt='hello world\n'):
        self.path, self.txt = path, txt

    def execute(self):
        if verbose:
            print("[creating file '{}']".format(self.path))
        with open(self.path, mode='w', encoding='utf-8') as out_file:
            out_file.write(self.txt)

    def undo(self):
        delete_file(self.path)

class ReadFile:

    def __init__(self, path):
        self.path = path

    def execute(self):
        if verbose:
            print("[reading file '{}']".format(self.path))
        with open(self.path, mode='r', encoding='utf-8') as in_file:
            print(in_file.read(), end='')

def delete_file(path):
    if verbose:
        print("deleting file '{}'".format(path))
    os.remove(path)

def main():
    orig_name, new_name = 'file1', 'file2'

    commands = []
    for cmd in CreateFile(orig_name), ReadFile(orig_name), RenameFile(orig_name, new_name):
        commands.append(cmd)

    [c.execute() for c in commands]

    answer = input('reverse the executed commands? [y/n] ')

    if answer not in 'yY':
        print("the result is {}".format(new_name))
        exit()

    for c in reversed(commands):
        try:
            c.undo()
        except AttributeError as e:
            pass

if __name__ == '__main__':
    main()
```

### 3. 解释器模式
**解释器模式**可用于创建一种专注于某个特定领域的, 具有有限表达能力的计算机语言. 这种语言被称为**领域特定语言(Domain Specific Language, DSL)**. 解释器模式背后的主要思想是让非初级用户或领域专家使用一门简单的语言来表达想法.

DSL 分为 内部DSL 和 外部 DSL :

- 内部 DSL : 构建在一种宿主编程语言之上. 如 使用 Python 解决线性方程组的一种语言.

    优势: 无需担心创建, 编译及解析语法, 因为这已经被宿主语言解决掉了.
    劣势: 首先于宿主语言的特性.

- 外部 DSL : 不依赖于某种宿主语言. DSL 的创建者可以决定语言的方方面(语法, 句法等). 但也需要为其创建一个解析器和编译器.

**解释器模式仅与内部 DSL 相关**.

解释器根本不处理语言解析, 它假设我们已经有某种便利形式的解析好的数据, 可以是**抽象语法数(Abstract Syntax Tree, AST)** 或任何好友的数据结构, 如 yaml 之于 ansible.

另外, 解释器模式应仅用于实现简单的语言, 其目标是为专家提供恰当的编程抽象, 使其生产力更高, 并且这些专家通常不是程序员. 此外, DSL 的性能通常不是一个重要的关注点, 重点是提供一种语言, 隐藏宿主语言的独特性, 并提供更简洁易读的语法.

实现一种 内部 DSL 有多重方式, 可以使用正则表达式, 字符串处理, 操作符重载的组合以及元编程, 或其他第三方的库或工具.

示例代码:
```Python
from pyparsing import Word, OneOrMore, Optional, Group, Suppress, alphanums
# pyparsing 对空格, tab 或 意料之外的输出都是敏感的.

class Gate:

    def __init__(self):
        self.is_open = False

    def __str__(self):
        return 'open' if self.is_open else 'closed'

    def open(self):
        print('opening the gate')
        self.is_open = True

    def close(self):
        print('closing the gate')
        self.is_open = False


class Garage:

    def __init__(self):
        self.is_open = False

    def __str__(self):
        return 'open' if self.is_open else 'closed'

    def open(self):
        print('opening the garage')
        self.is_open = True

    def close(self):
        print('closing the garage')
        self.is_open = False


class Aircondition:

    def __init__(self):
        self.is_on = False

    def __str__(self):
        return 'on' if self.is_on else 'off'

    def turn_on(self):
        print('turning on the aircondition')
        self.is_on = True

    def turn_off(self):
        print('turning off the aircondition')
        self.is_on = False


class Heating:

    def __init__(self):
        self.is_on = False

    def __str__(self):
        return 'on' if self.is_on else 'off'

    def turn_on(self):
        print('turning on the heating')
        self.is_on = True

    def turn_off(self):
        print('turning off the heating')
        self.is_on = False


class Boiler:

    def __init__(self):
        self.temperature = 83  # in celsius

    def __str__(self):
        return 'boiler temperature: {}'.format(self.temperature)

    def increase_temperature(self, amount):
        print("increasing the boiler's temperature by {} degrees".format(amount))
        self.temperature += amount

    def decrease_temperature(self, amount):
        print("decreasing the boiler's temperature by {} degrees".format(amount))
        self.temperature -= amount


class Fridge:

    def __init__(self):
        self.temperature = 2  # 单位为摄氏度

    def __str__(self):
        return 'fridge temperature: {}'.format(self.temperature)

    def increase_temperature(self, amount):
        print("increasing the fridge's temperature by {} degrees".format(amount))
        self.temperature += amount

    def decrease_temperature(self, amount):
        print("decreasing the fridge's temperature by {} degrees".format(amount))
        self.temperature -= amount


def main():
    # 定义语法.
    word = Word(alphanums)
    command = Group(OneOrMore(word))
    token = Suppress("->")
    device = Group(OneOrMore(word))
    argument = Group(OneOrMore(word))
    event = command + token + device + Optional(token + argument)

    gate = Gate()
    garage = Garage()
    airco = Aircondition()
    heating = Heating()
    boiler = Boiler()
    fridge = Fridge()

    tests = ('open -> gate',
             'close -> garage',
             'turn on -> aircondition',
             'turn off -> heating',
             'increase -> boiler temperature -> 5 degrees',
             'decrease -> fridge temperature -> 2 degrees')

    open_actions = {'gate': gate.open,
                    'garage': garage.open,
                    'aircondition': airco.turn_on,
                    'heating': heating.turn_on,
                    'boiler temperature': boiler.increase_temperature,
                    'fridge temperature': fridge.increase_temperature}
                    
    close_actions = {'gate': gate.close,
                     'garage': garage.close,
                     'aircondition': airco.turn_off,
                     'heating': heating.turn_off,
                     'boiler temperature': boiler.decrease_temperature,
                     'fridge temperature': fridge.decrease_temperature}
    
    """
    执行 print(event.parseString("increase -> boiler temperature -> 3 degrees"))
    结果为 : [["increase"], ["boiler", "temperature"], ["3", "degrees"]]
    """
    for t in tests:
        if len(event.parseString(t)) == 2:  # 没有参数
            cmd, dev = event.parseString(t)
            cmd_str, dev_str = ' '.join(cmd), ' '.join(dev)
            if 'open' in cmd_str or 'turn on' in cmd_str:
                open_actions[dev_str]()
            elif 'close' in cmd_str or 'turn off' in cmd_str:
                close_actions[dev_str]()
        elif len(event.parseString(t)) == 3:  # 有参数
            cmd, dev, arg = event.parseString(t)
            cmd_str, dev_str, arg_str = ' '.join(cmd), ' '.join(dev), ' '.join(arg)
            num_arg = 0
            try:
                num_arg = int(arg_str.split()[0])  # 抽取数值部分
            except ValueError as err:
                print("expected number but got: '{}'".format(arg_str[0]))
            if 'increase' in cmd_str and num_arg > 0:
                open_actions[dev_str](num_arg)
            elif 'decrease' in cmd_str and num_arg > 0:
                close_actions[dev_str](num_arg)

if __name__ == '__main__':
    main()
```

### 4. 观察者模式
观察者模式用于在两个或多个对象之间创建一个发布-订阅通信类型.

**观察者模式**描述单个对象(发布者, 又称为主持者或者可观察者)与一个或多个对象(订阅者, 又称为观察者)之间的**发布-订阅关系**.

观察者模式背后的思想等同于 MVC 和 关注点分离原则 背后的思想, 即降低分布者与订阅者之间的耦合度, 从而易于在运行时添加/删除订阅者. 此外, 发布者不关心它的订阅者是谁, 它只是将通知发送给所有订阅者. 观察者的数量以及谁是观察者可能会有所不同, 也可以在运行时动态改变.

拍卖会类似于观察者模式, 每个拍卖出价人都有一些拍牌, 在他们想出价时就可以举起来. 不论出价人在何时举起一块拍牌, 拍卖师都会像主持者那样更新报价, 并将新的价格广播给所有出价人(订阅者).

django-observer 是一个第三方 Django 包, 可用于注册回调函数, 之后在某些 Django 模型字段发生变化时执行. 它支持许多不同类型的模型字段(CharField, IntegerField 等).

RabbitMQ 可用于为应用添加异步消息支持, 支持多种消息协议(如 HTTP, AMQP), 可在 Python 应用中用于实现 发布-订阅 模式, 也就是观察者设计模式.

`Blinker` 为python对象提供快速并且简单的对象到对象以及广播的信号传递.

**事件驱动系统**是使用观察者模式的典型实现. 在这种系统中, 监听者被用于监听特定事件. 监听者正在监听的事件被创建出来时, 就会触发他们. 其关键点是单个事件(发布者)可以关联多个监听者(观察者).

代码示例:
```Python
class Publisher:
    """ 发布者, 基类"""
    def __init__(self):

        self.observers = []     # 观察者保存列表

    def add(self, observer):
        """ 添加观察者 """
        if observer not in self.observers:
            self.observers.append(observer)
        else:
            print('Failed to add: {}'.format(observer))

    def remove(self, observer):
        """ 删除观察者 """
        try:
            self.observers.remove(observer)
        except ValueError:
            print('Failed to remove: {}'.format(observer))

    def notify(self):
        """ 通知所有观察者 """
        [o.notify(self) for o in self.observers]


class DefaultFormatter(Publisher):
    """ 默认格式化程序."""
    def __init__(self, name):
        Publisher.__init__(self)
        self.name = name
        self._data = 0

    def __str__(self):
        """ 默认格式化 """
        return "{}: '{}' has data = {}".format(type(self).__name__, self.name, self._data)

    @property
    def data(self):
        return self._data

    @data.setter
    def data(self, new_value):
        # 核心, 
        try:
            self._data = int(new_value)
        except ValueError as e:
            print('Error: {}'.format(e))
        else:
            self.notify()


class HexFormatter:
    """ 观察者 """
    def notify(self, publisher):
        print("{}: '{}' has now hex data = {}".format(type(self).__name__,
                                                      publisher.name, hex(publisher.data)))


class BinaryFormatter:
    """ 观察者 """
    def notify(self, publisher):
        print("{}: '{}' has now bin data = {}".format(type(self).__name__,
                                                      publisher.name, bin(publisher.data)))


def main():
    df = DefaultFormatter('test1')
    print(df)

    print("-" * 30)
    hf = HexFormatter()
    df.add(hf)
    df.data = 3
    print(df)

    print("-" * 30)
    bf = BinaryFormatter()
    df.add(bf)
    df.data = 21
    print(df)

    print("-" * 30)
    df.remove(hf)
    df.data = 40
    print(df)

    print("-" * 30)
    df.remove(hf)       # 多次删除
    df.add(bf)          # 多次添加
    df.data = 'hello'   # 数据类型错误
    print(df)

    print("-" * 30)
    df.data = 15.8
    print(df)

if __name__ == '__main__':
    main()
```

### 6. 状态模式
面向对象编程着力于在对象交互时改变他们的状态.

状态设计模式可用于实现一个核心的计算机科学概念: **状态机**. 有限状态机(通常名为状态机)是一个非常方便的状态装换建模(并在必要时以数学方式形式化)工具. 

状态设计模式就是应用到一个 特定软件工程问题的状态机. 状态设计模式解决的是一定上下文中无限数量状态的完全封装, 从而实现更好的可维护性和灵活性.

状态设计模式, 通常使用一个父 State 类和许多派生 ConcreteState 类 来实现, 父类包含所有状态共同的功能, 每个派生类则仅包含特定状态要求的功能. 如下代码所示:

```Python
"""
Implementation of the state pattern
This example has a very simple radio. It has an AM/FM toggle switch, and a scan button to scan to the next station.
"""

class State(object):
    """Base state. This is to share functionality"""

    def scan(self):
        """Scan the dial to the next station"""
        self.pos += 1
        if self.pos == len(self.stations):
            self.pos = 0
        print "Scanning… Station is", self.stations[self.pos], self.name

class AmState(State):
    def __init__(self, radio):
        self.radio = radio
        self.stations = ["1250", "1380", "1510"]
        self.pos = 0
        self.name = "AM"

    def toggle_amfm(self):
        print "Switching to FM"
        self.radio.state = self.radio.fmstate

class FmState(State):
    def __init__(self, radio):
        self.radio = radio
        self.stations = ["81.3", "89.1", "103.9"]
        self.pos = 0
        self.name = "FM"

    def toggle_amfm(self):
        print "Switching to AM"
        self.radio.state = self.radio.amstate

class Radio(object):
    """A radio.
    It has a scan button, and an AM/FM toggle switch."""

    def __init__(self):
        """We have an AM state and an FM state"""

        self.amstate = AmState(self)
        self.fmstate = FmState(self)
        self.state = self.amstate

    def toggle_amfm(self):
        self.state.toggle_amfm()
    def scan(self):
        self.state.scan()

# Test our radio out
radio = Radio()
actions = [radio.scan] * 2 + [radio.toggle_amfm] + [radio.scan] * 2
actions = actions * 2
for action in actions:
    action()
```
**状态机**是一个抽象机器, 有两个关键部分,**状态**和**转换**.

- **状态** : 指系统的当前(激活)状态. 一个状态机在一个特定时间只能有一个激活状态.
- **转换** : 指从一个状态切换到另一个状态, 因某个事件或条件的触发而开始. 通常, 在一次转换发生之前或之后会执行一个或一组工作.

状态机可以用图来表现(称为**状态图**), 其中每个状态都是一个节点, 每个转换都是两个节点之间的边.

![操作系统进程状态图](/imgs/python/process_states.PNG)

`django-fsm` 用途 Django 框架中简化状态机的实现和使用.
[`state_machine`](https://www.pyfdtic.com/2018/03/27/python-state-machine/) 模块也可以方便的创建状态机.

代码示例: 使用 `state_machine` 实现的状态机.

```Python
from state_machine import State, Event, acts_as_state_machine, after, before, InvalidStateTransition

@acts_as_state_machine      # 装饰器. 
class Process:

    # 定义状态机的状态. 
    created = State(initial=True)       # initial 指定状态及的初始状态.
    waiting = State()
    running = State()
    terminated = State()
    blocked = State()
    swapped_out_waiting = State()
    swapped_out_blocked = State()

    # 定义状态转换, 一个状态转换就是一个 Event.
    # from_states 为单个状态或一个状态元组, 是对象的起始状态(或之一).
    # to_state 为对象的目标状态. 
    wait = Event(from_states=(created, running, blocked,
                              swapped_out_waiting), to_state=waiting)
    run = Event(from_states=waiting, to_state=running)
    terminate = Event(from_states=running, to_state=terminated)
    block = Event(from_states=(running, swapped_out_blocked),
                  to_state=blocked)
    swap_wait = Event(from_states=waiting, to_state=swapped_out_waiting)
    swap_block = Event(from_states=blocked, to_state=swapped_out_blocked)

    def __init__(self, name):
        """ 进程元信息"""
        self.name = name

    ## before 和 after 装饰器, 用于在状态转换之前或之后执行工作.
    @after('wait')
    def wait_info(self):
        print('{} entered waiting mode'.format(self.name))

    @after('run')
    def run_info(self):
        print('{} is running'.format(self.name))

    @before('terminate')
    def terminate_info(self):
        print('{} terminated'.format(self.name))

    @after('block')
    def block_info(self):
        print('{} is blocked'.format(self.name))

    @after('swap_wait')
    def swap_wait_info(self):
        print('{} is swapped out and waiting'.format(self.name))

    @after('swap_block')
    def swap_block_info(self):
        print('{} is swapped out and blocked'.format(self.name))


def transition(process, event, event_name):
    """ 状态转换函数, 
    process 是一个 Process 类实例
    event 是一个 Event 类实例
    event_name 是事件名称, 此处需手动输入, 用于在出错时, 输出事件名称.
    """
    try:
        event()
    except InvalidStateTransition as err:
        print('Error: transition of {} from {} to {} failed'.format(process.name,
                                                                    process.current_state, event_name))


def state_info(process):
    """展示进程当前状态的一些基本信息.
    process 是一个 Process 类实例.
    """
    print('state of {}: {}'.format(process.name, process.current_state))


def main():

    # 字符串常量, 作为 event_name 参数值传递.
    RUNNING = 'running'
    WAITING = 'waiting'
    BLOCKED = 'blocked'
    TERMINATED = 'terminated'

    pn = Process("processn")
    print(dir(pn))
    print(pn.current_state)
    print(pn.aasm_state)
    print("-" * 30)

    p1, p2 = Process('process1'), Process('process2')
    [state_info(p) for p in (p1, p2)]

    print()
    transition(p1, p1.wait, WAITING)
    transition(p2, p2.terminate, TERMINATED)
    [state_info(p) for p in (p1, p2)]

    print()
    transition(p1, p1.run, RUNNING)
    transition(p2, p2.wait, WAITING)
    [state_info(p) for p in (p1, p2)]

    print()
    transition(p2, p2.run, RUNNING)
    [state_info(p) for p in (p1, p2)]

    print()
    [transition(p, p.block, BLOCKED) for p in (p1, p2)]
    [state_info(p) for p in (p1, p2)]

    print()
    [transition(p, p.terminate, TERMINATED) for p in (p1, p2)]
    [state_info(p) for p in (p1, p2)]

if __name__ == '__main__':
    main()
```

### 7. 策略模式

使用策略模式实现在(在许多候选算法中)动态地选择算法.

**策略模式(Strategy pattern)**鼓励使用多种算法来解决一个问题, 他能在运行时透明的切换算法(客户端代码对变化无感知).

策略模式是一种非常通用的设计模式, 无论何时希望动态, 透明的应用不同的算法, 策略模式都是可行之路. 此处的不同算法指: 目的相同但实现方案不同的一类算法. 这意味着算法结果应该是完全一致的, 但每种实现都有不同的性能和代码复杂性.

使用场景:

- 创建各种不同的资源过滤器, 如排序问题, 身份验证, 日志记录, 数据压缩和加密.
- 创建不同的样式表现, 为了实现可移植性或动态的改变数据的表现.
- 模拟, 如模拟机器人, 机器人行为中的所有不同之处都可以使用不同的策略来建模.

Python 中的 `sorted()` 和 `list.sort()` 函数是策略模式的例子, 两个函数都接受一个命名参数`key`, 这个参数本质上是实现了一个排序策略的函数的名称.

示例代码:

```Python
import time
SLOW = 3    # 单位为秒
LIMIT = 5   # 字符数
WARNING = 'too bad, you picked the slow algorithm :('


def pairs(seq):
    """ 返回所有相邻字符对的一个序列."""
    n = len(seq)
    for i in range(n):
        yield seq[i], seq[(i + 1) % n]


def allUniqueSort(s):
    if len(s) > LIMIT:
        print(WARNING)
        time.sleep(SLOW)

    srtStr = sorted(s)

    for (c1, c2) in pairs(srtStr):
        if c1 == c2:
            return False
    return True


def allUniqueSet(s):
    if len(s) < LIMIT:
        print(WARNING)
        time.sleep(SLOW)
    return True if len(set(s)) == len(s) else False


def allUnique(s, strategy):
    return strategy(s)


def autoStrate(s):
    if len(s) > LIMIT:
        return allUniqueSet(s)
    else
        return allUniqueSort(s)

def main():
    """ 通常代码使用的策略不应该由用户来选择, 
    策略模式的要点是可以透明的选择使用不同的算法, 
    即程序自动选择最快的算法, 如 autoStrate() .
    """
    while True:
        word = None
        while not word:
            word = input('Insert word (type quit to exit)> ')
            if word == 'quit':
                print('bye')
                return

            strategy_picked = None
            strategies = {'1': allUniqueSet, '2': allUniqueSort}
            while strategy_picked not in strategies.keys():
                strategy_picked = input('Choose strategy: [1] Use a set, [2] Sort and pair> ')

                try:
                    strategy = strategies[strategy_picked]
                    print('allUnique({}): {}'.format(word, allUnique(word, strategy)))
                except KeyError as err:
                    print('Incorrect option: {}'.format(strategy_picked))

if __name__ == '__main__':
    main()
```

### 8. 模板模式

模板模式通过定义抽象步骤来帮助设计一个通用算法, 这些抽象步骤有子类来实现. 这种模式使用**里氏替换原则**, 即:

> 如果 S 是 T 的子类型, 则程序中类型 T 的对象可以用类型 S 的对象替换, 而无需改变该程序的任何期望属性.

换句话说, 抽象类可以通过在具体类中实现的步骤来定义算法如何工作. 抽象类还可以该出算法的基本或部分实现, 并允许开发人员覆写其部分.

模板模式用于抽取一个算法的通用部分, 从而提高代码复用.

模板设计模式(Template Design Pattern) 关注的是消除代码冗余, 其思想是应该无需改变算法结构就能重新定义一个算法的某些部分. 当发现结构相近的(多个)算法中有重复代码, 则可以把算法的不变(通用)部分留在一个模板方法/函数中, 把易变(不同)的部分移到动作/钩子方法/函数中. 

Python 的 `cmd` 模块使用了模板模式, 该模块用于构建面向行的命令解释器. 具体而言, `cmd.Cmd.cmdloop()` 实现了一个算法, 持续的读取输入命令并将命令分发到动作方法. 每次循环之前, 之后做的事情以及命令解释部分使用时相同的, 这即使算法中的不变部分; 变化的是实际的动作方法(易变的部分).

示例代码

```Python
from cowpy import cow


def dots_style(msg):
    msg = msg.capitalize()
    msg = '.' * 10 + msg + '.' * 10
    return msg


def admire_style(msg):
    msg = msg.upper()
    return '!'.join(msg)


def cow_style(msg):
    """ 使用 cowpy 模块生成随机 ASCII 码艺术字符."""
    msg = cow.milk_random_cow(msg)
    return msg


def generate_banner(msg, style=dots_style):
    print('-- start of banner --')
    print(style(msg))
    print('-- end of banner --\n\n')


def main():
    msg = 'happy coding'
    [generate_banner(msg, style) for style in (dots_style, admire_style, cow_style)]

if __name__ == '__main__':
    main()
```
