# Lua 学习笔记

Lua 是一种高性能, 解释型, 面向对象的语句, 广泛用于各种项目的内嵌语言, 如 redis, nginx, scrapy, 愤怒的小鸟, 魔兽世界等等.

本文主要介绍 Lua 的语法.

## 1. 数据类型
lua 是一个动态类型语言,一个变量可以存储类型的值.
Lua 常用数据类型:

- 空(nil):    空类型只包含一个值,即nil . nil表示空, 没有赋值的变量或标的字段都是 nil.
- 布尔(boolean):     布尔类型包含 True 和 False 两个值.
- 数字(number):  整数合浮点数是都是使用数字类型存储.
- 字符串(string):     字符串类型可以存储字符串,且与Redis的键值一样都是二进制安全的.字符串可以使用单引号或双引号表示,两个符号是相同的. 字符串可以包含转义字符,如 '\n','\r' 等.
- 表(table):        表类型是Lua 语言中唯一的数据结构,既可以当数组,又可以当字典,十分灵活.
- 函数(function):    函数是Lua中的一等值(first-class value),可以存储在变量中,作为函数的参数或返回结果.

## 2. 变量

Lua 变量分为全局变量和局部变量. 全局变量无需声明就可以直接使用,默认值是 nil .

    > print(b)

    a = 1　　 -- 为全局变量a赋值
    a = nil   -- 删除全局变量的方法是将其复制为 nil . 全局变量没有声明与未声明之分,只有非 nil 和 nil 的区别.
    print(b)　-- 无需声明即可使用，默认值是nil


声明局部变量的方式为 "local 变量名" :

    local c　　--声明一个局部变量c，默认值是nil
    local d = 1　--声明一个局部变量d并赋值为1
    local e, f　--可以同时声明多个局部变量           

    * 局部变量的作用域为从声明开始到所在层的语句块的结尾.

声明一个存储函数的局部变量的方法为 :

    local say_hi = function ()
        print 'hi'
    end     

变量名必须是**非数字开头**,只能包含**字母**,**数字**和**下划线**,**区分大小写**. 变量名不能与Lua的保留关键字相同, 保留关键字如下:

    and break do else elseif end false for function if in local nil not or repeat return then true until while 

## 3. 注释

- 单行: `--` 开始, 到行尾结束.
- 多行:  `--[[ ... ]]` .

## 4. 赋值

多重赋值 : 

    local a, b = 1, 2　   -- a的值是1，b的值是2
    local c, d = 1, 2, 3　-- c的值是1，d的值是2，3被舍弃了
    local e, f = 1　　      -- e的值是1，f的值是nil

在执行多重赋值时,Lua会先计算所有表达式的值,比如: 

    local a = {1, 2, 3}
    local i = 1
    i, a[i] = i + 1, 5      -- i = 2 ; a = {5,2,3} , lua 索引从 1 开始.

lua 中的函数也可以返回多个值

## 5. 操作符

### 5.1 数学操作符 : 

常见的+、-、*、/、%（取模）、-（一元操作符，取负）和幂运算符号^。

数学操作符的操作数如果是字符串,则会自动转换为数字.

    print('1' + 1)　　-- 2
    print('10' * 2)　　-- 20          

### 5.2 比较操作符 : 
- `==` : 比较两个操作数的类型和值是否相等
- `~=` : 与 == 结果相反
- `<,>,<=,>=` : 大于,小于,小于等于,大于等于.

1. 比较操作符的结果一定是**布尔类型** ;
2. 比较操作符,**不会**对两边的操作数进行**自动类型转换**.

### 5.3 逻辑操作符 :

- `not` : 根据操作数的真和假返回false 和 true
- `and` : a and b, 如果a 是真,则返回 b , 否则返回 a .
- `or`  : a or b , 如果a 是假,则返回 a , 否则返回 b .

1. 只要操作数不是 nil 或 false ,逻辑操作符都认为操作数是真. 特别**注意 0 或 空字符串也被当做真**.

2. Lua 逻辑操作符支持**短路**，也就是说对于 false and foo() ，lua 不会调用foo函数，or 类似。

### 5.4 连接操作符. 

`...` 用来连接两个字符串. **连接操作符会自动把数字类型的抓换成字符串类型**.

### 5.5 取长度操作符. 
是lua5.1 新增的操作符, `#` ,用来获取字符串或表的长度.

    > print(#'hello')  -- 5

### 5.6 运算符的优先级:

    ^
    not # -(一元)
    * / %
    + -
    ..
    < > <= >= ~= ==
    and 
    or

## 6. if 语句

语法 :

    if 条件表达式 then
        语句块
    elseif 条件表达式 then
        语句块
    else
        语句块
    end

**注意** : 

1. **Lua 中只有 nil 和 false 才是假, 其余值,包括0 和空字符串,都被认为是真值**. 

2. Lua 每个语句都可以 `;` 结尾 ,但是一般来说编写 Lua 是会省略 `;` ,

3. Lua 并不强制要求缩进,所有语句也可以写在一行中, 但为了增强可读性,建议在注意**缩进**.

        > a = 1 b = 2 if a then b = 3 else b = 4 end

## 7. 循环语句

### 7.1 while 循环

    while 条件表达式 do
        语句块
    end

### 7.2 repeat 循环

    repeat 
    语句块
    until 条件表达式

### 7.3 for 循环

#### 形式一 : 
for 循环中的 i 是**局部变量**, 作用域为 for 循环体内. 虽然没有使用 local 声明,但它**不是全局变量**.

    for 变量=初值,终值,步长 do  -- 步长可省略,默认为 1
        语句块
    end

示例

    # 计算 1 ~ 100 之和
    local sum = 0
    for i = 1 ,100 do
        sum = sum + 1
    end
  
#### 形式二 : 

    for 变量1 ,变量2, ... , 变量N in 迭代器 do
        语句块
    end


## 8. 表类型

表是Lua中**唯一的数据结构**,可以理解为关联数组, **任何类型的值(除了空类型)都可以作为表的索引**.

    a = {}　　　　        --将变量a赋值为一个空表
    a['field'] = 'value'　--将field字段赋值value
    print(a.field)　　    --打印内容为'value'，a.field是a['field']的语法糖。      


    people = {　　　--也可以这样定义
        name = 'tom',
        age = 29
    }

当索引为整数的时候表和传统的数组一样，例如：

    a = {}
    a[1] = 'Tom'
    a[2] = 'Jeff'

可以写成下面这样：

    a = {'Tom', 'Jeff'}
    print(a[1])　　　　--打印的内容为'Tom'        

可以使用通用形式的`for语句`遍历数组,例如:

    for index,value in ipairs(a) do     -- index 迭代数组a 的索引 ; value 迭代数组a 的值.
        print(index)
        print(value)
    end

    -- ipairs 是Lua 内置的函数,实现类似迭代器的功能.

数字形式的for语句

    for i=1,#a do
        print(i)
        print(a[i])
    end

`pair` : 迭代器,用来遍历非数组的表值.

    person = {
        name = 'Tom',
        age = 29
    }
    for index,value in pairs(person) do
        print(index)
        print(value)
    end

`pairs` 与 `ipairs` 的区别在于前者会遍历所有值不为 nil 的索引, 而后者只会从索引 1 开始递增遍历到最后一个值不为 nil 的整数索引.

## 9. 函数   
一般形式:

    function(参数列表)
        函数体
    end

可以将函数赋值给一个局部变量, 比如:

        local square = function(num)
            return num*num
        end

    ** 因为在赋值前声明了局部变量 square, 所以可以在函数内部引用自身(实现递归).

函数参数 :

1. 如果实参的个数**小于**形参的个数,则没有匹配到的形参的值为 `nil` . 
2. 相对应的,如果实参的个数**大于**形参的个数,则多出的实参会**被忽略**. 
3. 如果希望捕获多出的参数(即实现可变参数个数),可以让最后一个形参为 `...` . 

        local function square(...)
            local argv = {...}
            for i = 1,#argv do
                argv[i] = argv[i] * argv[i]
            end
            return unpack(argv)   -- unpack 函数用来返回 表 中的元素. 相当于return argv[1], argv[2], argv[3]
        end
        a,b,c = square(1,2,3)
        print(a)    -- 1
        print(b)    -- 4
        print(c)    -- 9

**在 Lua 中, return 和 break (用于跳出循环) 语句必须是语句块中的最后一条语句, 简单的说在这两条语句之后只能是 end,else 或 until 三者之一**. 

**如果希望在语句块中间使用这两条语句,可以认为的使用 do 和 end 将其包围**.

## 10. 标准库 http://www.lua.org/manual/5.1/manual.html#5

Lua 的标准库中提供了很多使用的函数, 比如 ipairs,pairs,tonumber,tostring,unpack 都属于标准库中的Base库.

Redis 支持大部分Lua标准库,如下所示:

    库名      说明
    Base        一些基础函数
    String      用于字符串操作的函数
    Table       用于表操作的函数
    Math        数学计算函数
    Debug       调试函数

### 10.1 String库 : 可以通过字符串类型的变量以面向对象的形式访问, 如 string.len(string_var) 可以写成 string_var:len()

1. 获取字符串长度 : string.len(string) 作用与操作符 "#" 类似
    
        > print(string.len('hello'))  -- 5
        > print(#'hello')   -- 5

2. 转换大小写 

        string.upper(string)
        string.lower(string)
    
3. 获取子字符串

    ```lua
    string.sub() 可以获取一个字符串从索引 start 开始到 end 结束的子字符串,索引从1 开始. 索引也可以是负数, -1 代表最后一个元素 . 

        string.sub(string start[,end ])    -- end 默认为 -1.

        > print(string.sub('hello',1))  -- hello
        > print(string.sub('hello',2))  -- ello
        > print(string.sub('hello',2,-2))  -- ell
    ```
### 10.2 Table库 : 其中大部分函数都需要表的形式是数组形式.

1. 将数组转换为字符串

    ```lua
    table.concat(table [,sep [,i [,j]]])
        # sep : 以 sep 指定的参数分割, 默认为空.
        # i , j : 用来限制要转换的表元素的索引范围. 默认分别为 1 和 表的长度. 不支持负索引.

    > print(table.concat({1,2,3}))     --123
    > print(table.concat({1,2,3},',',2))  --2,3
    > print(table.concat({1,2,3},',',2,2)) --2
    ```

2. 向数组中插入元素
    ```lua
    table.insert(table ,[pos,] value)   # 在指定索引位置 pos 插入元素 value, 并将后面的元素顺序后移. 默认 pos 值是数组长度加 1 , 即在数组尾部插入.

        > a = {1,2,4}
        > table.insert(a,3,3)  # {1,2,3,4}
        > table.insert(a,5)    # {1,2,3,4,5}
        > print(table.concat(a,','))
        1,2,3,4,5
    ```

3. 从数组中弹出一个元素
    ```lua
    table.remove(table,[,pos])  # 从指定的索引删除一个元素,并将后面的元素前移,返回删除元素值. 默认 pos 的值是数组的长度,即从数组尾部弹出一个元素.

        > table.remove(a)     --{1,2,3,4}
        > table.remove(a,1)   --{2,3,4}
        > print(table.caoncat(a,','))
        2,3,4
    ```

### 10.3 Math库 : 提供常用的数学运算函数, 如果参数是字符串会自动尝试转换成数字.
```lua
math.abs(x)         # 绝对值
math.sin(x)         # 三角函数sin
math.cos(x)         # 三角函数cos
math.tan(x)         # 三角函数tan
math.ceil(x)        # 进一取整, 1.2 取整后是 2
math.floor(x)       # 向下取整, 1.8 取整后是 1
math.max(x,...)     # 获得参数中的最大的值
math.min(x,...)     # 获取参数中的最小的值
math.pow(x,y)       # 获取 xy 的值
math.sqrt(x)        # 获取 x 的平方根
math.random([m,[,n]]) # 生成随机数,没有参数 返回 [0,1]的实数, 参数 m 返回范围在 [1,m] 的整数, 同时提供 m n 返回范围在 [m,n] 的整数.
math.randomseed(x)  # 设置随机数种子, 同一种子生成的随机数相同.
```  
## 11. 其他库
Redis 还通过 cjson库 和 cmsgpack库 提供了对 JSON 和 MessagePack的支持. Redis自动加载了这两个库,在脚本中可以分别通过 cjson 和 cmsgpack 两个全局变量来访问对应的库.

    local people = {
        name = 'Tom',
        age = 29
    }

    -- 使用 cjson 序列化成字符串
    local json_people_str = cjson.encode(people)

    -- 使用 cmsgpack 序列化成字符串
    local msgpack_people_str = cmsgpack.pack(people)

    -- 使用 cjson 将序列化后的字符串还原成表
    local json_people_obj = cjson.decode(people)
    print(json_people_obj.name)

    -- 使用 cmshpack 将序列化后的字符串还原成表
    local msgpack_people_obj = cmsgpack.unpack(people)
    print(msgpack_people_obj.name)