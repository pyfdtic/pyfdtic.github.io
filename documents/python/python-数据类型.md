
## 一. int

    n1 + n2 --> n1.__add__(n2)
    int.bit_length()  # 返回二进制长度, 最少.

    # 定义 int
        n = 123
        n = int(3)
        n = int.__init__(123)

    -5 ~ 257 内存优化数字.

    int 范围 : 与计算机类型有关
        32bit : 
        64bit : 

## 二. str

    str.center(width, fillchar=None)  : 居中, 总长度, 填充字符.
    str.zfill(width) : 返回指定长度的额字符串, 原字符串右对齐, 前面填充 0 

    str.count(sub,start=None,end=None)  : 子序列个数.

    str.decode(encoding=None, error=None) : 解码
    str.encode(encoding=None, error=None) : 编码, 针对 unicode

    str.endswith(suffix, start=None, end=None) : 是否已 suffix 结尾.
    str.startswith(prefix, start=None, end=None) : 

    str.expandtabs(tabsize=None) : 将 tab 转换为 空格, 默认一个 tab 转换为 8 个空格.

    str.find(sub, start=None, end=None) : 寻找子字符串的位置. 返回字符串索引, 没有找到返回 -1 
    str.rfind(sub, start=None, end=None)

    str.index(sub, start=None, end=None)  : 寻找子字符串的位置. 返回字符串索引, 没有找到返回 报错.
    str.rindex(sub, start=None, end=None)

    str.format(*args, **kwargs)
        字符串格式化, 动态参数
    
    str.isalnum()
    str.isalpha()
    str.isdigit()

    str.islower()
    str.isspace()
    str.istitle()
    str.isupper()

    str.join()

    str.ljust(width, fillchar=None)  : 内容左对齐，右侧填充
    str.rjust(width, fillchar=None)  : 


    str.lower()
    str.upper()
    str.title()
    str.capitalize()
    str.swapcase() : 大写变小写，小写变大写
    str.translate(table, deletechars=None) : 转换，需要先做一个对应表，最后一个表示删除字符集合

    str.lstrip()  : 移除左侧空白
    str.rstrip()  : 移除右侧空白
    str.strip()   : 移除两侧空白

    str.partition(sep) : 分割，前，中，后三部分
    str.rpartition(sep) : 从右侧索引开始

    str.replace(old, new, count=None)

    str.split(sep=None, maxsplit=None)  : 字符串切割, 结果为 list
    str.rsplit(sep=None, maxsplit=None) : 字符串切割, 结果为 list
    str.splitlines(keepends=False) : 字符串切割, 以换行符为依据, 结果为 list    


## 三. list

    l.sort(cmp=None, key=None, reverse=False)  : 同时包含数字,字母,中文等的列表, 无法排序, 会报错.
    l.reverse()  : 倒序
    
    l.remove(value)
    l.pop(index=None) : 默认删除末尾元素

    # 删除指定索引, 
        del l[INDEX]
    
    l.extend(iterable)  : 扩展列表
        l1 = [1,2,3]
        l2 = [4,5,6]
        l1.extend(l2) 
    l.append(p_object)  : 添加元素
        l1 = [1,2,3]
        l1.append(4)
    l.insert(index, p_obj)

    l.count(value)  : 统计出现的次数.
    l.index(value, start=None, stop=None)


## 四. tuple
    t.count(index)  
    t.index(value, start=None, stop=None)

## 五. dict
    d.clear() : 清理所有的元素
    d.copy()  : 浅拷贝
    d.get(k, d=None)   : 依据 key 获取值.
    d.has_key(k) : 判断元素是否存在 

    d.pop(k, d=None) : 获取并在字典中移除
    d.popitem() : 随机删除元素

    d.setdefault(k,d=None) : 如果 key 不存在, 则创建, 存在则返回原有的值.
    d.update(E=None, **f) : 

    d.items() : 所有元素的列表形式
    d.iteritems() : 可迭代 items
    d.iterkeys() : 可迭代 keys
    d.itervalues() : 可迭代 values
    
    d.keys() : keys, 列表
    d.values() : value , 列表

    d.viewitems()
    d.viewkeys()
    d.viewvalues()

    dict.fromkeys(key_list,default_value)   # 从字典 d 中遍历 寻找key_list对应的 key, 返回 key和 default_value 组成的字典. 用于创建字典, 是一个类方法.

    a = dict(a=123,b=234)    
## 六. dict

## 七. set

### 1. 创建 set
    
        s = set()
        s = set(list)   # list 为可迭代对象的即可
        s = {1,23,4}

### 2. 内建方法
#### 1) 一般方法:

    s.add()             # 为集合添加元素 
    s.clear()           # 清空集合
    a.isdisjoint(b)     # 判断有无交集, 有交集返回 False
    a.issubset(b)       # 是否是子集
    a.issuperset(b)     # 是否是父集

    s.discard(a)        # 移除指定元素, 元素不存在不报错
    s.remove(a)         # 移除指定元素, 元素不存在报错.
    s.pop()             # 随机移除元素, 并返回 被删除的元素.
    
    s.update(b)         # b 可以为 set, 也可以为 list

    
#### 2) 差集:

    a.difference(b)           # 返回 a 与 b 的差集
    a.difference_update(b)    # 用 a 与 b 的 差集更新 a
#### 3) 交集:

    a.intersection(b)         # 返回 a 与 b 的交集, 
    a.intersection_update(b)  # 用 a 与 b 的交集跟新 a
#### 4) 补集:

    a.union(b)
    a.union_update(b)

#### 5) 对称交集:

    a.symmetric_difference(b)        # 返回 a 存在, b 不存在 和 a 不存在 ,b 存在的 元素组成的 set
    a.symmetric_difference_update(b) # a 和 b 的交叉补集 更新 a.
## 八. 序列通用方法

    # s为一个序列

    len(s)         返回： 序列中包含元素的个数

    min(s)         返回： 序列中最小的元素

    max(s)         返回： 序列中最大的元素

    all(s)         返回： True, 如果所有元素都为True的话

    any(s)         返回： True, 如果任一元素为True的话

    s.count(x)     返回： x在s中出现的次数

    s.index(x)     返回： x在s中第一次出现的下标

 
    range(1,10) : 指定范围生成数字列表.
    xrange(1,10) : 指定范围生成数字列表. 可迭代.    

## 九. enumrate() : 可迭代对象添加序号
    
    l = range(6)
    for k,v in enumerate(l):
        print k,v


## 十. 标准库 collections : 容器数据类型

### 1. collections.namedtuple

是一个函数,用来创建自定义的 tuple 对象, 并且规定 tuple 的元素个数,并可以用 **属性** 而不是 索引 来引用 tuple 的某个元素.

    In [1]: from collections import namedtuple

    In [2]: Point = namedtuple('Point',['x','y'])

    In [3]: p = Point(1,2)

    In [4]: p.x
    Out[4]: 1

    In [5]: p.y
    Out[5]: 2

    In [6]: isinstance(p,Point)
    Out[6]: True

    In [7]: isinstance(p,tuple)
    Out[7]: True


** 可以方便的定义一种数据类型, 具备 tuple 元素的不变性, 又可以根据属性来引用.

示例 : 用坐标和半径表示一个圆

    Circle = namedtuple('Circle', ['x','y','z'])

定义 : 各种namedtuple 都由其自己的类表示, 使用namedtuple() 工厂函数来创建. 参数就是新类名和一个包含元素名的字符串.

    import collections
    Person = collections.namedtuple("Person", "name age gender")

    bob = Person(name="bob", age=12, gender="Male")     # 匹配定义使用的元素名字符串, 正好匹配, 不多不少.
    print bob[0]
    print bob.name,bob.age,bob.gender
    print bob._fields   # 打印所有预定义字段.

** 除了使用标准元组的位置索引外, 还可以使用点记法(obj.attr)按名字访问 namedtuple 的字段.
** 元素名字符串不可与 Python 关键字冲突, 不可重复.


    >> engineer = collections.namedtuple("engineer", "name age job", rename=True)
    >> print engineer._field
      # ('name', 'age', 'job')

    >> with_class = collections.namedtuple("Person","name class age gender",rename=True)
    >> with_class._fields
        # ('name', '_1', 'age', 'gender')

    >> two_ages = collections.namedtuple("Person","name age gender age",rename=True)
    >> two_ages._fields
       # ('name', 'age', 'gender', '_3')

** 重命名的字段的新名字取决于他在 tuple 中的索引, 所以名为 class 的字段会变成 _1, 重复的age字段则变成 _3.

### 2. collections.deque : 双端队列

支持从任意一端增加和删除元素. 更为常用的两种结构, 即栈和队列, 就是双端队列的退化形式, 其输入和输出限制在一端.

为了高效实现插入和删除操作的双向列表, 使用于队列和栈.

    In [8]: from collections import deque
    In [9]: q = deque(['a','b','c'])
    In [10]: q.append('x')
    In [12]: q
    Out[12]: deque(['a', 'b', 'c', 'x'])
    In [16]: q.appendleft('x')
    In [17]: q
    Out[17]: deque(['x', 'a', 'b', 'c', 'x'])           

    deque.append()
    deque.appendleft()
    deque.pop()
    deque.popleft()

deque 是一种序列容器, 因此同样支持 list 的一些操作.

    d = collections.deque("abcdefg")
    print d
    print len(d)
    print d[0]
    print d[-1]
    d.remove('c')

填充 : 可以从任意一端填充, 在 Python 中成为 "左端" 和 "右端"
    
        d1 = collections.deque()
    
    d.extend()  
        d1.extend("abcdefg")
        print d1    # deque(['a', 'b', 'c', 'd', 'e', 'f', 'g'])
    
    d.append()
        d1.append("h")
        print d1    # deque(['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'])
    
    d.extendleft()  : 迭代处理其输入, 对各个元素完成与 appendleft() 同样的处理, 其结果是 deque 将包含逆序的输入序列.

        d1.extendleft(range(5))

    d.appendleft()
        d1.appendleft("10")

    d.pop() : 从右端删除一个元素

    d.popleft() : 从左端删除一个元素

    ** 由于双端队列是线程安全的, 所以甚至可以在不同线程中同时从两端利用队列内容.

    d.rotate() : 旋转, 类似拨号盘.

        d.rotate(NUM)  : 向右旋转, 即从队列右端取元素, 移动到左端
        d.rotate(-NUM) : 向左旋转, 即从队列左端取元素, 移动到右端

        d2 = collections.deque(range(10))
        print d2     # deque([0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
        de.rotate(2) # deque([8, 9, 0, 1, 2, 3, 4, 5, 6, 7])
        de.rotate(-2) # deque([0, 1, 2, 3, 4, 5, 6, 7, 8, 9])

### 3. collections.defaultdict

使用 dict 使, 当 key 不存在时,返回一个默认值.

    In [20]: from collections import defaultdict

    In [21]: dd=defaultdict(lambda: 'xyz')

    In [22]: dd['name']='bob'

    In [23]: dd['age'] = 12

    In [24]: dd
    Out[24]: defaultdict(<function __main__.<lambda>>, {'age': 12, 'name': 'bob'})

    In [25]: dd['name']
    Out[25]: 'bob'

    In [26]: dd['gaga']
    Out[26]: 'xyz'

** 默认值是调用函数返回的, 而函数在创建 defaultdict 对象时传入.

** 除了在 key 不存在时返回默认值, defaultdict 的其他行为跟 dict 是完全一样的.

标准字典 : 
    dict.setdefault()  # 来获取一个值, 如果这个值不存在则建立一个默认值.

defaultdict 初始化时,容器会让调用者提前指定默认值.

        import collections

        def default_factory():
            return "default value"

        d = collections.defaultdict(defaultdict, foo="bar")

        print d["foo"]  # "bar"
        print d["aaa"]  # "default value"
        print d["bar"]  # "default value"

        ** 只要所有键都是相同的默认值并无不妥, 就可以使用这个方法.
        ** 如果默认值是一种用于聚集或者累加值的类型, 如 list,set 甚至是 int, 该方法尤其有用.

### 4. collections.OrderdDict

使得 dict 保持有序.

    >>> from collections import OrderedDict
    >>> d = dict([('a', 1), ('b', 2), ('c', 3)])
    >>> d # dict的Key是无序的
    {'a': 1, 'c': 3, 'b': 2}
    >>> od = OrderedDict([('a', 1), ('b', 2), ('c', 3)])
    >>> od # OrderedDict的Key是有序的
    OrderedDict([('a', 1), ('b', 2), ('c', 3)])

** OrderedDict 是按照插入的顺序排列,而不是 key 本身排序.

** OrderedDict 可以实现一个 FIFO 的 dict, 当容量超出限制时, 先删除最早添加的 key.

    from collections import OrderedDict

    class LastUpgradeOrderedDict(OrderedDict):
        def __init__(self, capacity):
            super(LastUpgradeOrderedDict, self).__init__()
            self._capacity = capacity
        
        def __setitem__(self,key,value):
            containsKey = 1 if key in self else 0
            if len(self) - containsKey >= self._capacity:
                last = self.popitem(last=False)
                print 'remove: ', last

            if containKey:
                del self[key]
                print 'set:',(key,value)
            else:
                print 'add',(key,value)

            OrderedDict.__setitem__(self,key,value)

标准字典并不跟踪插入顺序, 迭代处理时会根据键在散列表中存储的顺序来生成值. 在 OrderedDict 中则相反, 他会记住元素插入的顺序, 并在创建迭代器时使用这个顺序.

标准字典在检查相等性时, 会查看其内容; OrderedDict 还会考虑元素增加的顺序.

    od = collections.OrderedDict()
    od["a"] = "A"
    od["b"] = "B"
    od["c"] = "C"
    od["d"] = "D"

    for k,v in od.items():
        print k,v 

### 5. collections.Counter

一个简单的计数器, 例如, 统计字符出现的个数. 可以跟踪相同的值增加了多少次.

    In [35]: from collections import Counter

    In [36]: c = Counter()

    In [37]: for ch in 'programing':
    ...:     c[ch] = c[ch] + 1
    ...:     

    In [38]: c
    Out[38]: Counter({'a': 1, 'g': 2, 'i': 1, 'm': 1, 'n': 1, 'o': 1, 'p': 1, 'r': 2})

初始化 : 三种初始化方法

    print collections.Counter(["a", "b", "c", "a", "b", "b"])   # 元素序列
    print collections.Counter({"a": 2, "b": 3, "c": 1})     # 一个包含键和计数的字典
    print collections.Counter(a=2, b=3, c=1)    # 使用关键字参数,将字符串映射到计数.


不提供任何参数, 构造一个空的 Counter, 然后通过 update() 方法填充.

    import collections 
    c = collections.Counter()
    c.update("abcdaab")
    print c     # Counter({'a': 3, 'b': 2, 'c': 1, 'd': 1})

    c.update({"a":1,"d":5})
    print c     # Counter({'a': 4, 'b': 2, 'c': 1, 'd': 6})

*计数值将根据新数据增加, 替换数据不会改变计数.*

####访问计数 :

1. 使用字典API 获取

        c = collections.Counter("abcdaab")
        for letter in 'abcde':
            print c[letter]     # 打印字符出现的次数.

    ** 未出现的字符, 不会产生 KeyError, 其计数为 0.

2. elements()    : 返回一个迭代器, 将生成 Counter 知道的所有元素.

        c = collections.Counter("extremely")
        c["z"] = 0
        print list(c.elements())  # ['e', 'e', 'e', 'm', 'l', 'r', 't', 'y', 'x']

    ** 不能保证元素的顺序不变, 
    ** 计数小于或者等于0的元素, 不包含在内.

3. most_common() : 生成一个序列, 其中包含 n 个最常遇到的输入值及其相应计数.

    没有参数时, 返回一个列表, 按词频排序

        print c.most_common()   
        [('e', 3), ('m', 1), ('l', 1), ('r', 1), ('t', 1), ('y', 1), ('x', 1)]
    
    

    带参数时, 返回前 3 个词频较大的元素. 当参数大于序列的长度时, 返回所有.

        print c.most_common(3)  
        [('e', 3), ('m', 1), ('l', 1)]

    

4. 算数操作,集合操作

        c1 = Counter(["a","b","c","a","b","b"])
        c2 = Counter('alphabet')
        print c1
        Counter({'a': 2, 'b': 3, 'c': 1})

        print c2
        Counter({'a': 2, 'b': 1, 'e': 1, 'h': 1, 'l': 1, 'p': 1, 't': 1})

        print c1 + c2
        Counter({'a': 4, 'b': 4, 'c': 1, 'e': 1, 'h': 1, 'l': 1, 'p': 1, 't': 1})

        print c1 - c2
        Counter({'b': 2, 'c': 1})

        print c1 & c2
        Counter({'a': 2, 'b': 1})

        print c1 | c2
        Counter({'a': 2, 'b': 3, 'c': 1, 'e': 1, 'h': 1, 'l': 1, 'p': 1, 't': 1})

    *每次通过一个操作生成一个新的 Counter 时, 计数为 0 或负数的元素都会被删除.*