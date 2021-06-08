---
title: redis 汇总
date: 2018-03-15 18:24:36
categories:
- Middleware
tags:
- redis
- 缓存
---

## 1. Redis 介绍

### 1.1 使用场景
Redis是远程字典服务器 的缩写, 适用于如下场景:

1. 数据库
2. 缓存
3. 队列系统

### 1.2 Redis所支持的数据类型

1. 字符串类型

    当存储的字符串类型是整数形式时, 可以对其进行递增操作, 比如：set age 1, incr age, 返回递增后的值, 递增操作是原子操作. 

2. 散列类型
3. 列表类型
4. 集合类型
5. 有序集合类型

## 2. 安装配置与优化

### 2.1 源码编译安装
    
    # 安装依赖, 编译工具
    $ yum groupinstall "Development Tools" -y

    # 编译安装
    $ wget http://usl/redis-stable.tgz
    $ tar xf redis-stable.tgz
    $ cd redis-stable
    $ make PREFIX=/usr/loca/redis
    $ make install PREFIX=/usr/local/redis

    # 配置启动
    $ mkdir /usr/local/redis/{logs,data,conf}
    $ cp *.conf /usr/local/redis/conf/
    $ sed -i 's/^daemonize no/daemonize yes/g' /usr/local/redis/conf/redis.conf
    $ cat >/etc/profile.d/redis.sh <<EOF
      #!/bin/bash
      #
      export PATH=$PATH:/usr/local/redis/bin
      EOF
    $ source /etc/profile.d/redis.sh

    # 启动测试
    $ redis-server /usr/local/redis/conf/redis.conf
    $ redis-cli -p REDIS_PORT
    > info

make install命令执行完成后, 会在/usr/local/redis 目录下生成 6 个可执行文件, 分别是`redis-server`、`redis-cli`、`redis-benchmark`、`redis-check-aof` 、`redis-check-dump`, 它们的作用如下：

1. `redis-server` : Redis服务器的daemon启动程序

2. `redis-cli`    ：Redis命令行操作工具. 也可以用telnet根据其纯文本协议来操作

3. `redis-benchmark` : Redis性能测试工具, 测试Redis在当前系统下的读写性能

4. `redis-check-aof` : 数据修复,AOF文件修复工具

5. `redis-check-dump` : 检查导出工具,RDB文件检查工具

6. `redis-sentinel` : sentinel 服务器 ,哨兵

### 2.2 redis 配置参数
#### 2.2.1 redis.conf 配置文件参数

    daemonize ：是否以后台daemon方式运行

    pidfile ：pid文件位置

    port ：监听的端口号

    timeout ：请求超时时间

    loglevel ：log信息级别

    logfile ：log文件位置

    databases ：开启数据库的数量

    save * * ：保存快照的频率, 第一个*表示多长时间, 第二个*表示执行多少次写操作. 在一定时间内执行一定数量的写操作时, 自动保存快照. 可设置多个条件. 

    rdbcompression ：是否使用压缩

    dbfilename ：数据快照文件名(只是文件名, 不包括目录)

    dir：数据快照的保存目录(这个是目录) -- 持久化存储保存位置.

    appendonly ：是否开启appendonlylog, 开启的话每次写操作会记一条log, 这会提高数据抗风险能力, 但影响效率. 

    appendfsync ：appendonlylog如何同步到磁盘(三个选项, 分别是每次写都强制调用fsync、每秒启用一次fsync、不调用fsync等待系统自己同步)

#### 2.2.2 命令行 config 配置

还可以在 redis 运行中通过 CONFIG SET 命令在不重新启动redis的情况下,动态修改部分 redis 配置.

    redis> CONFIG SET loglevel warning
    redis> CONFIG GET loglevel

支持的配置修改项:

    save
    rdbcompression
    rdbchekcsum
    dbfilename
    masterauth
    slave-server-stale-data
    sleva-read-only 
    maxmemory
    maxmemory-policy
    maxmemory-samples
    appendonly
    appendfsync
    auto-aof-rewrite-percentage
    auto-aof-rewrite-min-size
    lua-time-limit
    slowlog-log-slower-than
    slowlog-max-len
    hash-max-ziplist-entries
    hash-max-ziplist-value
    list-max-ziplist-entries
    list-max-ziplist-value
    set-max-intset-entries
    zset-max-ziplist-entries
    zset-max-ziplist-value

**使用 config 命令配置 redis server 时, 应当同时手动修改配置文件, 保证 redis-server 的配置与配置文件中一致, 否则容易采坑**.

#### 2.2.3 系统优化参数
修改系统配置文件, 执行命令

    $ echo vm.overcommit_memory=1 >> /etc/sysctl.conf

    $ sysctl vm.overcommit_memory=1 或执行echo vm.overcommit_memory=1 >>/proc/sys/vm/overcommit_memory

    使用数字含义：

    0, 表示内核将检查是否有足够的可用内存供应用进程使用；如果有足够的可用内存, 内存申请允许；否则, 内存申请失败, 并把错误返回给应用进程. 

    1, 表示内核允许分配所有的物理内存, 而不管当前的内存状态如何. 

    2, 表示内核允许分配超过所有物理内存和交换空间总和的内存

### 2.3 启动与关闭
#### 2.3.1 启动
1. 前台启动

        # 以开发模式启动redis-server,并指定端口,默认为6379
        $ redis-server [--port=6380]         

2. 后台启动

        $ vim redis.conf
          daemonize yes

        $ redis-server /etc/redis.conf 

    当配置文件后跟参数时, 参数会覆盖配置文件中的该选项. **此种启动方式应当仅限于测试, 生产勿用**.

        $ redis-server /etc/redis.conf  --loglevel warning     

3. 检测是否启动成功
    
    $ redis-cli info

#### 2.3.2 关闭
    
    # redis 会先断开所有客户端连接,然后根据配置执行持久化,最后完成退出.
    $ redis-cli shutdown    

    # redis 可以妥善处理 SIGTERM 信号, 效果与发送 shutdown 命令一样.
    $ kill redis_PID        


## 3. redis 命令
### 3.1 redis 执行命令方式

方式一 : 将命令作为 **redis-cli 的参数**执行

    $ redis-cli -h HOST -p PORT CMD

    或

    $ echo "REDIS_CMD" | redis-cli -h HOST -p PORT

方式二 : **交互式模式**

    $ redis-cli  -h HOST -p PORT 
    > CMD

### 3.2 命令返回值

1. 状态回复 : 直接显示状态信息

        redis> PING
        PONG


2. 错误回复 : 当出现命令不存在或命令格式有错误等情况时 Redis 会返回错误回复(error reply). 错误回复以`error`开头, 并在后面跟上错误信息. 

3. 整数回复 : 整数回复(integer reply)以(integer)开头, 并在后面跟上整数数据
        
        # 递增键值返回以整数形式返回递增后的键值.
        redis> INCR foo      

        # 返回数据库中键的数量
        redis> DBSIZE        

4. 字符串回复 : 当请求一个字符串类型键的键值或一个其他类型键中的某个元素时就会得到一个字符串回复. 字符串回复以**双引号**包裹

        redis> GET foo

5. 多行字符回复 : 多行字符串回复中的每行字符串都以一个序号开头.
        
        # 返回符合指定规则的键名.
        redis> KEYS *      


## 4. redis 多数据库

redis 是一个字典结构的存储服务器,实际上一个redis实例提供了多个用来存储数据的字典,可以加将每个字典理解成一个独立的数据库. 

每个数据库对外都是以一个从0开始的递增数字命名,redis 默认支持16个数据库. 

客户端与redis建立链接之后,自动连接 0号 数据库,不过可以随时使用 SELECT 命令更换数据库,

但这种数据库更像是一种命名空间,而*不适宜*存储不同应用程序的数据 ,可以启动多个redis实例,存储数据. 但是可以用 数据库0 存储应用A的线上数据, 数据库1 存储应用A的测试数据.

    redis> SELECT 1
    OK
    redis[1]> GET foo

注意:

1. 这种数据库更像是一种命名空间,而*不适宜*存储不同应用程序的数据.
2. redis 不支持自定义数据库的名字,每个数据库都以编号命名. 开发者必须自己记录那些数据库存储了那些数据
3. redis 不支持为每个数据库设置不同的访问密码,
4. redis 多个数据库之间并不是完全隔离的. 如 `FLASHALL` 会清空一个redis实例中所有数据库中的数据.

## 5. redis 数据类型: 
**所有 redis 命令都是原子操作.**

Redis中每个键都属于一个明确的数据类型,如通过HSET建立的键是散列类型,通过SET建立的键是字符串类型.   使用一种数据类型的命令操作另一种数据类型的键会提示错误.

### 5.0 基础命令

#### 5.0.1. 获取符合规则的键名列表 : `KEYS pattern`

    redis> KEYS glob_pattern

    ?  : 匹配一个字符
    *  : 匹配任意个字符,包括0个
    [] : 匹配括号内的任一字符, "-" 表示范围,[0-9]
    \x : 转义

#### 5.0.2. 判断一个键是否存在

    # 有返回1, 没有返回0
    redis> EXISTS key      

#### 5.0.3. 删除键

    # 可以删除多个keys, 返回删除的键的个数.
    redis> DEL key [key ...]  

    # 一次删除多个键 : 删除所有以 "user:*" 开头的键.

    $ redis-cli KEYS 'user:*' | xargs redis-cli DEL

    或
    # 性能更好.
    $ redis-cli DEL `redis-cli KEYS "user:*"`       
   
#### 5.0.4. 获得键值的数据类型:

    # 返回 string(字符串),hash(散列),list(列表),set(集合),zset(有序集合)
    redis> TYPE key     

    # 向指定的列表类型键中增加一个元素,如果键不存在则创建它.
    > LPUSH key value     

#### 5.0.5. 键命名规范:

`对象类型:对象ID:对象属性`

如 :

    post:articleID:page.view  -- 文章访问量

#### 5.0.6. 过期时间

1. 设置过期时间
    
    返回值 : `1` 表示甚至成功 ; `0` 表示键不存在或设置失败.

    **对键多次使用 EXPIRE 会重新设置键的过期时间**.

        # seconds 表示过期时间,必须为整数.
        > EXPIRE key seconds 
        
        # 设置过期时间,时间单位是毫秒
        > PEXPIRE key milliseconds 
            PEXPIRE key 10000 == EXPIRE key 1 
        
        # 第二个参数表示键的过期时间.使用UNIX时间戳. 表示到 UNIX_TIME 时过期.
        > EXPIREAT key UNIX_TIME

        # 同上,但单位为毫秒.
        > PEXPIREAT key UNIX_TIME_MS

2. 查看过期时间
    
    返回值 : 剩余时间,单位秒 ; 当键不存在时,返回 -2 ; 没有为键设置过期时间 ,返回 -1 .

        # 查看一个键还有多久时间会被删除,
        > TTL key 
        
        # 以毫秒为单位返回键的剩余时间.
        > PTTL key 

3. 取消过期时间设置

    注意 : 使用 SET 或 GETSET 命令为键赋值也会**同时清除键的过期时间**. 其他只对键值进行操作的命令(如 INCR,LPUSH,HSET,ZREN) 均不会影响键的过期时间.

        # 取消键的过期时间设置,即将键恢复成永不过期.
        > PERSIST key 

4. 实现缓存.

    实际开发中会发现很难为缓存键设置合理的过期时间, 为此可以限制 Redis 能够使用的最大内存,并让Redis按照一定的规则淘汰不需要的缓存键,这种方式在只将Redis用作缓存系统时非常实用.

        $ vim redis.conf

         # 限制Redis最大可用内存大小,单位字节.
         maxmemory = 12345
         # 在超出maxmemory大小时,指定策略删除不需要的键,直到Redis占用的内存小于指定内存.
         maxmemory-policy = volatile-lru

    `maxmemory-policy` 策略 : LRU (Least Recently Used),最近最少使用

    - `volatile-lru`    : 使用LRU算法删除一个键(只对设置了过期时间的键)
    - `allkeys-lru`     : 使用LRU算法删除一个键
    - `volatile-random` : 随机删除一个键(只对设置了过期时间的键)
    - `allkeys-random`  : 随机删除一个键
    - `volatile-ttl`    : 删除过期时间最近的一个键
    - `noeviction`      : 不删除键,只返回错误.

    volatile : 易变的,不稳定的,

### 5.1 字符串类型 : 

最基本的数据类型, 能存储任何形式的字符串,包括二进制数据. 可以存储 用户邮箱/JSON化的对象/图片等.  

**字符串类型是其他4种数据类型的基础,其他数据类型和字符串的差别从某种角度来说只是组织字符串的形式不同**. 如 列表类型是以列表的形式组织字符产,集合是以集合的形式组织字符串.

单个字符串类型键允许存储的数据的**最大容量**是512MB.

#### 5.1.1 赋值与取值 :

    > SET key value
    > GET key

    # 为程序设置分布式锁时, 非常有用.
    > set(key, value, ex=None, px=None, nx=False, xx=False)
        ex : 设置过期时间, 单位 秒
        px : 设置过期时间, 单位 毫秒
        nx : nx=True, 当 key 不存在时, 设置其值为 value.
        xx : xx=True, 当 key 存在时, 设置其值为 value

#### 5.1.2 递增数字:
当存储的字符串类型是**整数形式**时, 可以对其进行**递增**操作, 

    # 让当前键值递增,并返回递增后的值
    > INCR key    

    # 对 key 进行 100 次递增操作
    $ redis-cli -r 100 incr key 

用途 : 
1. 文章访问量统计
2. 生成自增ID
3. 存储文章数据

#### 5.1.3 增加指定的整数 : 
    
    # 指定当前 key 增加 increment 个数
    > INCRBY key increment     

    # 指定 bar 增加 2
    redis> INCRBY bar 2 
    
#### 5.1.4 减少指定的整数 :
    
    # 让键值递减
    > DECR key    

    # 指定减少个数
    > DECRBY key decrement    
    
#### 5.1.5 增加指定浮点数:
    
    # 指定增加一个双精度浮点数.
    > INCRBYFLOAT key increment    
    
#### 5.1.6 向尾部追加值 :
    
    # 向键值的末尾追加value, 如果键不存在则将该键的值设置为 value, 返回值是追加后字符串的总长度.
    > APPEND key value    
    
#### 5.1.7 获取字符串长度 : 
    
    # 返回键值的长度,如果键不存在则返回0 .
    > STRLEN key     

#### 5.1.8 同时获取/设置多个键值

    > MGET key [key ...]
    > MSET key value [key value ...]

#### 5.1.9 位操作 : 
一个字节由8个二进制位组成, Redis提供了 4 个命令可以直接对**二进制位**进行操作.

位操作符可以非常紧凑的**存储布尔值**,并且 `GETBIT` 和 `SETBIT` 的时间复杂度是O(1)的,性能很高.

##### GETBIT

    # 获取一个字符串类型键指定位置的二进制位的值. 
    # 如果需要获取的二进制位的索引超出了键值的二进制位的长度,则默认位值是 0 .
    > GETBIT key offset          

    # bar 的3个字母,的ASCII码为 98,97,114 ,转换为二进制后分别为 : 1100010,1100001,1110010 存储结构为 011000100110000101110010 .
    redis> SET foo bar    
    OK

    > GETBIT foo 0
    (integer) 0
    > GETBIT foo 6
    (integet) 1

##### SETBIT
    
    # 设置字符串类型键指定位置的二进制位的值, 返回值是该位置的旧值. 
    # 如果设置的位值超过了键值的二进制位的长度,SETBIT命令会自动将中间的二进制位设置为0 
    # 如果设置一个不存在的键的指定二进制位的值会自动将其前面的位赋值为 0 .

    > SETBIT key offset value    

##### BITCOUNT

    # 获得字符串类型键中值是 1 的二进制位个数. start 和 end 限制统计的字节范围.
    > BITCOUNT key [start] [end]  

##### BITOP
    
    # 可以对多个字符串类型键进行位运算,并将结果存储在 destkey 参数指定的键中, BITOP的支持的运算操作有 AND,OR,XOR,NOT .

    > BITOP operation destkey key [key ...]  
    
    #示例 : 对 bar 和 aar 进行OR运算;
    > SET foo1 bar
    > SET foo2 aar
    > BITOP OR res foo1 foo2
    (integer)3
    > GET res
    "car"

##### BITPOS
    
    # 可以获取指定键的第一位值是0 或 1 的位置. start end 指定起始字节 , 但返回的偏移量任然从开头算起. 
    # redis_version > 2.8.7 
    > BITPOS key [0|1] [start] [end]   

        > SET foo bar
        > BITPOS foo 1
        (integer)1

##### BITFIELD

    # Perform arbitrary bitfield integer operations on strings. VER > 3.2.0
    > BITFIELD key [GET type offset] [SET type offset value] [INCRBY type offset increment] [OVERFLOW WRAP|SAT|FAIL]
  
### 5.2 hash 散列类型 :  

1 个散列类型**最多**能容纳 `2**32 - 1` 个元素.

hash 的键值也是一种**字典结构**,其存储了字段(field)和字段值得映射,但**字段值只能是字符串**,不支持其他类型.
散列值类型不能嵌套其他的数据类型. ( **Redis 的其他数据类型同样不支持数据类型嵌套**. )

适合存储对象 : 使用对象类别和ID构成键名,使用字段表示对象的属性,而字段值则存储属性值. `对象类别:ID:字段属性` -- `字段值`

    例如 : 存储ID为2的汽车对象,
        CAR:2:color  -- 白色
        CAR:2:name   -- 奥迪
        CAr:2:price  -- 900k

#### 5.2.1 赋值与取值 : HSET, HMSET, HGET, HMGET, HGETALL
    
    # 设置 key 中指定 filed 的值
    > HSET key field value      

    HSET 不区分插入和更新操作. 即修改数据时不用事先判断字段是否存在来决定是插入还是更新操作.
    1. 当执行的是 插入 操作时,HSET返回 1 ; 
    2. 当执行的是 更新 操作时,HSET返回 0 ;
    3. 当键本身 不存在 时,HSET会自动创建它.

    
    
    # 获取 key 中指定 field 的值.
    > HGET key field            
    
    # 设置一个 key 中的多个 field
    > HMSET key field value [field value ...]

        > HMSET car:3 name baoma color black price 900k

    # 获取一个 key 中的多个 field
    > HMGET key field [field ...]

        > HMGET car:3 name color price

    # 获取键中所有字段和字段值.
    > HGETALL key   

        > HGETALL car:3

#### 5.2.2 判断字段是否存在
    
    # 存在返回 1 ,不存在返回 0 ;
    > HEXISTS key field    
        > HEXISTS car:3 name

#### 5.2.3 当字段不存在时赋值 : 

    # 如果字段已存在,则不执行任何操作. 且HSETNX是原子操作,不必担心竞态条件. 
    > HSETNX key field value   
    
#### 5.2.4 增加数字 : 
    # 使字段增加指定的整数 . 
    # 如果键不存在,则 HINCRBY 命令会自动建立该键,并默认新建字段的值为'0' . 
    # 命令返回值为增值后的字段值.
    > HINCRBY key field increment   

#### 5.2.5 删除字段 : 
    # 可以删除一个或多个字段,返回值为被删除的字段的个数.
    > HDEL key field [field ...]    
    
#### 5.2.6 获取所有 字段名(field) 或 字段值 :

    # 获取字段名字
    > HKEYS key  

    # 获取字段值.
    > HVALS key     
    
#### 5.2.7 获得字段数量

    > HLEN key
    
### 5.3 列表类型 :  -- 队列  , 1 个列表类型最多能容纳 2**32 - 1 个元素.

存储一个有序的字符串列表, 常用操作时向列表两端添加元素,或者后的列表的某一个片段.

列表类型内部是使用**双向链表(double linked list)**实现的 ,所以向列表两端增加元素的时间复杂度是 O(1) ,**获取越接近两端的元素速度越快**. 但代价是**通过索引访问元素比较慢**.

使用场景:

- 记录新鲜事儿, 最新记录
- top 10 
- 记录日志等

#### 5.3.1 向列表两端增加元素.
    
    # 向列表左端增加元素,返回增加元素后列表的长度,
    > LPUSH key value [value ...]    

    # 向列表右端增加元素,返回增加元素后列表的长度.
    > RPUSH key value [value ...]    
    
#### 5.3.2 从列表两端弹出数据

    # 从列表左边弹出一个元素,返回被移除的元素值.
    > LPOP key     

    # 从列表右边弹出一个元素,返回被移除的元素值.
    > RPOP key     

    ** 模拟 栈 : 后进先出
        LPUSH -- LPOP 
        ROUSH -- RPOP 

    ** 模拟 队列 : 先进先出
        LPUSH -- RPOP
        RPUSH -- LPOP

#### 5.3.3 获取列表中元素的个数
    
    # LLEN时间复杂度为 O(1) ,使用redis会直接读取现成的值,而不需要遍历一遍数据表来完成统计.
    > LLEN key
    
#### 5.3.4 获得列表片段
    
    # 起始索引值为 0 .并且 LRANGE 返回的值包含最右边的元素. 支持负索引.
    > LRANGE key start stop  
        
    1. 如果 strat > stop ,则返回空列表
    2. 如果 start > LLEN(key) ,返回列表最右边的元素.

#### 5.3.5 删除列表中指定的值
    
    # 删除列表中前 count 个值为 value 的元素, 返回值为实际删除的元素个数.
    > LREM key count value  

    1. 当 count > 0 ,LREM 从列表 左边 开始删除前 count 个值为 value 的元素
    2. 当 count < 0 ,LREM 从列表 右边 开始删除前 |count| 个值为 value 的元素.
    3. 当 count = 0 ,LREM 删除 所有值 为 value 的元素.

    
#### 5.3.6 获取/设置指定索引的元素值
    
    # 返回指定索引的元素. 索引从 0 开始.
    # 当index 为负数时,从右边开始计算索引,最右边的元素索引为 -1 .
    > LINDEX key index     

    # 将索引为 index 的元素, 赋值为 value.
    > LSET key index value 
    
#### 5.3.7 只保留列表指定片段
    
    # 删除指定范围之外的所有元素.
    > LTRIM key start end  

#### 5.3.8 向列表中插入元素
    
    # LINSERT首先会在列表中从左向右查找职位 pivot 的元素,然后 BEFORE|AFTER 插入 value . 
    # LINSERT 返回值为插入后列表的元素个数.
    > LINSERT key [ BEFORE | AFTER ] pivot value  
    
#### 5.3.9 将元素弓一个列表转到另一个列表. 
把列表类型作为队列使用时,RPOPLPUSH命令可以很直观的在**多个队列中传递数据**.

当 source 和 destination 相同时, RPOPLPUSH 会不断**将对尾的元素转移到队首**,借助这个特性,可以实现一个网站监控系统: 使用一个队列存储需要监控的网址,然后监控程序不断的使用 RPOPLPUSH 命令循环去除一个网址来检测可用性. 另外,在检测过程中,可以不断的向队列中增加新的元素, 而且整个系统容易扩展,允许多个客户端同时处理队列.

    # 从 source RPOP 一个元素, LPUSH 到 destination ,并返回改变的元素值. 
    # 整个操作过程是原子的.
    > RPOPLPUSH source destination  
   
### 5.4 集合类型 

集合中的每个元素都是**不同**的, 且**没有顺序** . 一个集合类型最多可以存储 `2**32-1` 个字符串.

集合类型在Redis内部是通过使用**值为空的 散列表(hash table)**实现的, 故操作的时间复杂度是O(1)的.

多个集合类型键之间可以进行**并集/交集/差集**运算.

#### 5.4.1 增加/删除元素
    
    # 向集合中增加一个或多个元素,如果键不存在则会自动创建. 如果元素已经存在,则会忽略. 
    # 命令返回值为加入的元素的个数.
    > SADD key member [member ...]   

    # 从集合中删除一个或多个元素,并返回删除成功的元素的个数.
    > SREM key member [member ...]   

#### 5.4.2 获取集合中所有的元素
    # 返回集合中的所有元素.
    > SMEMBERS key  

#### 5.4.3 判断元素是否在集合中
    
    # 判断一个元素是否在集合中是一个事件复杂度为O(1)的操作,无论集合中有多少元素. 
    # 当值存在是返回 1 ,当值不存在是返回 0 .
    > SISMEMBER key member  

#### 5.4.4 集合间运算

**集合运算**

    # 差集运算.
    # 集合A 与 集合B 的差集表示 A - B, 代表所有属于A 且 不属于B的元素构成的集合.
    > SDIFF key [key ...]  

        # 先计算 setA - setB ,再计算结果与 setC 的差集.
        > SDIFF setA setB setC    

    # 交集运算. 
    # 集合A 和 集合B 的交集表示 A ∩ B,代表所有属于A 且 属于B的元素构成的集合.
    > SINTER key [key ...]      
    
    # 并集计算. 
    # 集合A 和 集合B 的并集表示 A ∪ B, 代表所有属于A 或 属于B的元素构成的集合.
    > SUNION key [key ...]      

进行**集合运算**,并**将结果存储**. 常用于需要多次运算的场合.

    # SDIFF操作之后,将结果存储在 destination 中
    > SDIFFSTORE destination key [key ...]  

    # SINTER操作之后,将结果存储在 destination 中
    > SINTERSTORE destination key [key ...] 

    # SUNION操作之后,将结果存储在 destination 中
    > SUNIONSTORE destination key [key ...] 

#### 5.4.5 获取元素的个数

    > SCARD key
        
#### 5.4.6 随机获取集合中的元素 
    
    # 用来随机集合中获取 count 个元素.
    > SRANDMEMBER key [count]  

    当 count > 0 , SRANDMEMBER 会随机从集合里获得count个不重复的元素. 当 count 的值大于集合中全部的元素的个数时,返回集合中的全部元素.

    当 count < 0 , SRANDMEMBER 随机从集合中获取 |count| 个元素.这些元素有可能相同.

#### 5.4.7 从集合中弹出一个元素 
    
    # 从集合中随机弹出一个元素.
    > SPOP key   
                    
### 5.5 有序集合类型 : sorted set

有序集合是在集合的基础上,为集合中的每个元素都关联了一个分数,这使得我们不仅可以完成插入/删除和判断元素是否存在等集合类型操作 ,还可以获得分数最高(或最低)的前N个元素、获得指定分数范围内的元素等与分数有关的操作. 虽然集合中每个元素都是不同的, 但是它们的分数却可以相同. 

有序集合使用散列表和跳跃表实现,所以即使读取列表中间部分的数据也很快(时间发咋读O(log(N)))
有序集合可以调整集合中某个元素的位置(通过修改这个元素的分数).
有序集合比列表类型更耗费内存.

有序集合算得上是 Redis的5种数据类型中最高级的类型了,可以与列表类型和集合类型对照理解.

#### 5.5.1 增加元素

    # 向有序集合中添加一个元素和该元素的分数,如果该元素已经存在,则会用新的分数替换原有的分数. 
    # 命令返回值 : 新加入到集合中的元素的个数.  
    # 分数可以为双精度浮点数.
    > ZADD key score member [score member]   
        
    # +inf 正无穷
    > ZADD testboard +inf haha   

    # -inf 负无穷
    > ZADD testboard -inf hehe   

#### 5.5.2 获得元素的分数

    > ZSCORE key member  
    
#### 5.5.3 获得排名在某个范围的元素列表
    # 按元素分数从小到大顺序返回 索引 从start 到 stop 之间的所有元素(包含两端的元素). 
    # 索引从 0 开始, 负数代表从后向前查找. 
    # [WITHSCORES] 表示在获得 元素 值的同时,展示元素的分数. 
    > ZRANGE key start stop [WITHSCORES]     
        时间复杂度 : O(log n+m) , n 为有序集合的基数, m为返回的元素的个数.
        当两个元素分数相同时,Redis按照字典书序来进行排序.

    > ZREVRANGE key start stop [WITHSCORES]  # 元素从大到小排序.
    
#### 5.5.4 获得指定分数范围的元素
按照元素分数从小到大的顺序返回分数在min 和 max之间(包含min,max)的元素.

如果希望分数范围不包含端点值,可以在分数前加上 "(" 符号,可以单独加. 

min ,max 支持 +inf 和 -inf .

    > ZRANGEBYSCORE key min max [WITHSCORES] [LIMIT offset count]  
        LIMIT offset count : 在获得的元素列表的基础上,向后偏移 offset 个元素,并只获取钱 count 个元素.

    > ZREVRANGEBYSCORE key max min [WITHSCORES] [LIMIT offset count]  # 元素从大到小.

#### 5.5.5 增加某个元素的分数
    
    # 增加一个元素的分数,返回值是更改后的分数. increment 支持负数.
    > ZINCRBY key increment member  
    
#### 5.5.6 获得集合中元素的数量
    > ZCARD key
    
#### 5.5.7 获得指定分数范围内的元素的个数
    > ZCOUNT key min max   
    
#### 5.5.8 删除一个或多个元素
    > ZREM key member [member ...]

#### 5.5.9 按照排名范围删除元素.
    
    # 按照元素分数从小到大的顺序(即索引0表示最小的值)删除处在指定排名范围内的所有元素, 并返回删除的元素数量.
    > ZREMRANGEBYRANK key start stop  

#### 5.5.10 按照分数范围删除元素
    # 删除指定分数范围内的所有元素,min max 的特定和 ZRANGEBUSCORE 命令中的一样. 返回值是删除的元素数量.
    > ZREMRANGEBYSCORE key min max    
    
#### 5.5.11 获得元素的排名
    # 安装元素分数从小到大的顺序获得指定的元素的排名(从0开始,即分数最小的元素排名为0) 
    > ZRANK key member   

    # 分数最大的元素排名为0 
    > ZREVRANK key member  
    
#### 5.5.12 计算有序集合的交集
    
计算多个有序集合的交集,并将结果存储在 destination 键中(同样以有序集合类型存储), 返回值为 destination 键中元素的个数.

    > ZINTERSTORE destination numkeys key [key...] [WEIGHTS weight [weight ...]] [AGGREGATE SUM|MIN|MAX ]   

        destination 键中元素的分数是由 AGGREGATE 参数决定的.
            - 当 AGGREGATE 是 SUM 时(默认值),  destination键中元素的分数是每个参与计算的集合中该元素分数的和.
    
            - 当 AGGREGATE 是 MIN 时,  destination键中元素的分数是每个参与计算的集合中该元素分数的最小值. 
    
            - 当AGGREGATE是MAX时, destination键中元素的分数是每个参与计算的集合中该元素分数的最大值. 

        ZINTERSTORE命令还能够通过WEIGHTS参数设置每个集合的权重, 每个集合在参与计算时元素的分数会被乘上该集合的权重

## 6. redis 事务 transction

数据库原理中很重要的一个概念是**事务**, 简单来说就是把一系列动作看做一个整体, 如果其中一个出了问题, 应该把状态恢复到执行该整体之前的状态. 在 Redis 中, `MULTI`、`EXEC`、`DISCARD`、`WATCH` 这四个指令是事务处理的基础. 

    - MULTI     : 用来 组装 一个事务；
    - EXEC      : 用来 执行 一个事务；
    - DISCARD   : 用来 取消 一个事务；
    - WATCH     : 用来 监视 一些key, 一旦这些key在事务执行之前被改变, 则取消事务的执行. 

用 `MULTI` 组装事务时, 每一个命令都会进入到内存队列中缓存起来, 如果出现 QUEUED 则表示我们这个命令成功插入了缓存队列, 在将来执行 EXEC 时, 这些被 QUEUED 的命令都会被组装成一个事务来执行. 

对于事务的执行来说, 如果 redis 开启了 AOF 持久化的话, 那么一旦事务被成功执行, 事务中的命令就会通过 write 命令一次性写到磁盘中去, 如果在向磁盘中写的过程中恰好出现断电、硬件故障等问题, 那么就可能出现只有部分命令进行了 AOF 持久化, 这时 AOF 文件就会出现不完整的情况, 这时, 我们可以使用 `redis-check-aof` 工具来修复这一问题, 这个工具会**将 AOF 文件中不完整的信息移除**, 确保 AOF 文件完整可用. 

然后我们来说说 `WATCH` 这个指令, 它可以帮我们实现类似于“乐观锁”的效果, 即CAS(check and set). WATCH本身的作用是“监视key是否被改动过”, 而且支持同时监视多个key, 只要还没真正触发事务, WATCH都会尽职尽责的监视, 一旦发现某个key被修改了, 在执行EXEC时就会返回nil, 表示事务无法触发.

### 6.1 MULTI & EXEC        
事务同命令一样是Redis的**最小执行单位**, 一个事务要么都执行,要么都不执行.
事务的原理是先将属于一个事务的命令发送给Redis,然后再让Redis一次执行这些命令.

    > MULTI
    > CMD_1    # 返回值,QUEUED
    > CMD_2    # 返回值,QUEUED
    > EXEC     # 返回这些命令的返回值组成的列表.

如果在发送 EXEC 命令前,客户端断开链接,则Redis会清空事务队列.

Redis的事务还能保证一个事务内的命令一次执行而**不被其他命令插入**.

**错误处理** : 

1. 语法错误 : 只要有一个命令有语法错误,执行EXEC命令之后Redis就会直接返回错误,连语法争取的命令也不会执行.
    redis 2.6.5 之前的版本会忽略有语法错误的命令,而执行事务中其他语法正确的命令.

2. 运行错误 : 指在命令执行时出现的错误,比如使用散列类型的命令操作集合类型的键,这种错误在实际执行之前是无法发现的,所以事务里的这样的命令是会被执行的. 如果事务里的一条命令出现了运行错误,事务里的其他命令依然会继续执行(包括出错之后的命令).

Redis的事务没有回滚功能,为此开发者必须自己将数据库复原回事务执行前的状态. Redis不支持回滚功能,也使得Redis 在事务上可以保值简洁和快速.

### 6.2 WATCH & UNWATCH
`Watch` 命令 : 用于监控一个或多个键, 一旦其中有一个键被修改(或删除), 之后的事务就不会执行. 监控将一直持续到 EXEC命令结束.

事务中的命令是在EXEC之后才执行的,所以在MULTI命令之后可以修改WATCH监控的键值.
        
示例 :

    redis> SET key 1
    redis> WATCH key
    redis> SET key 2
    redis> MULTI
    redis> SET key 3
    redis> EXEC
    (nil)
    redis> GET key
    "2"

    该例子中,在执行WATCH命令后, 事务执行只玩修改了 key 的值(SET key 2),所以最后事务中的命令 SET key 3 没有执行,EXEC返回空结果.

WATCH 命令的作用只是当被监控的键值被修改后阻止之后的一个事务执行,而不能保证其他客户端不修改这一键值,所以我们需要在EXEC执行失败后重新执行整个函数.

执行EXEC命令后会取消对所有键的监控,如果不想执行事务中的命令也可以使用 UNWATCH 命令来取消监控.

## 7. 排序

1. 有序集合的集合操作

    有序集合的常见的使用场景是大数据排序.

        ZINTERSTORE
        ZUNIONSTORE

        MULTI 
        ZINTERSTORE tempKey
        ZRANGE tempKey
        DEL tempKey
        EXEC

2. SORT命令 : 
    
    可以对列表类型,集合类型和有序集合类型键进行排序, 并且可以完成与关系数据库中的联结查询类似的任务.

3. BY 参数

4. GTE 参数

5. STORE 参数

6. 性能优化 : 
    
    `SORT` 是Redis中最强大最复杂的命令之一,如果使用不好很容易成为性能瓶颈.

    `SORT` 的时间复杂度是 O(n+mlog(m)) , n 为排序的列表(或集合或有序集合)中元素的个数.

    注意:
    - 尽可能减少待排序键中元素的数量,使 n 尽可能小.
    - 使用 LIMIT 参数,只获取需要的数据, 是 m 尽可能小.
    - 如果要排序的数据数量很大,尽可能使用 STORE 参数将结果缓存.

## 8. 消息通知
### 8.1 任务队列 : 传递任务的队列

与任务队列进行交互的实体有两类 :
- 生产者 : producer, 生产者会将需要处理的任务放在任务队列中,
- 消费者 : comsumer, 消费这不断地从任务队列中读入任务信息并执行.

任务队列的优点 :
- 松耦合 : 生产者和消费者无需知道彼此的实现细节,只需要约定好任务的描述格式.
- 易于扩展 : 消费者可以有多个,而且可以分布在不同的服务器中,借此可以降低单台服务器的负载.

使用 Redis 实现任务队列

    生产者 : LPUSH 
    消费者 : RPOP

- BRPOP : 当列表中没有元素时, BRPOP 命令会一直阻塞住链接, 直到有新元素加入.

    `BRPOP` 接受连个参数,第一个是键名, 第二个是超时时间; 当超过了超时时间任然没有获得新元素的话,就返回 nil. 0 表示不显示等待时间,即 如果没有新元素加入,就会一直阻塞下去.

        当获得一个元素后, BRPOP 命令返回两个值, 第一个是键名,第二个是超时时间(单位s).
        BRPOP key [key ...] timeout

- `BLPOOP` : 从队列左边获取元素.

### 8.2 优先级队列

### 8.3 '发布/订阅' 模式 : pulish/subscribe ,可以实现进程间的消息传递.
#### 8.3.1 基础订阅

模式 :
- 发布者 : 可以向指定的频道发布消息, 所有订阅此频道的订阅者都会收到此消息.
- 订阅者 : 可以订阅一个或若干个频道(channel).

**发布者不会 : 发出的消息**不会**持久化.

    > PUBLISH channel message     # 返回值表示接受到这条消息的订阅者数量.
    
    

**订阅者** : 处于订阅状态下的客户端, **不能**使用 SUBSCRIBE,UNSUBSCRIBE,PUNSUBSCRIBE 这四个属于'发布/订阅'模式的命令之外的命令, 否则会报错.

    > SUBSCRIBE channel [channel ...]
  
    进入订阅状态后客户端可能收到 3 种类型的回复,每种类型的回复都包含 3 个值, 第一个值是消息的类型, 依据消息了类型的不同,第二,第三个值的含义也不同. 

消息类型 :
1. subscribe   : 表示订阅成功的返回消息,
    
    第二个值是订阅成功的频道名称,第三个值是当前客户端订阅的频道数量.

2. message     : 表示收到的消息.
    
    第二个值是产生消息的频道名称,第三个消息是消息的内容.

3. unsubscribe : 表示成功取消订阅某个频道.
    
    第二个值是对应的频道名称,第三个值是当前客户端订阅的频道数量, 当此值为 0 时,客户端会推出订阅状态.

`UNSUBSCRIBE` : 取消订阅指定的频道. 没有指定频道的情况下,将退订所有频道.

    > UNSUBSCRIBE [channel [channel ...]]

#### 8.3.2 按照规则订阅.

`PSUBSCRIBE` : 订阅指定的规则, 规则支持 glob 风格的通配符.

使用 PSUBSCRIBE 可以重复订阅一个频道. PSUBSCRIBE channel.? channel.?* 则 当 channel.2 发布消息后,该客户端会收到两条消息.

    > PSUBSCRIBE channel.?*
        1) "pmessage"           # 表示通过 PSUBSCRIBE 命令订阅
        2) "channel.?*"         # 订阅时使用的通配符
        3) "channel.1"          # 实际收到消息的频道的名称
        4) "hi!"                # 消息的内容.

`PUNSBUSCRIBE [pattern [pattern ...]]` : 退订指定的规则. 如果没有指定会退订所有规则.

- 使用 PUNSUBSCRIBE 命令只能退订通过 PSUBSCRIBE命令订阅的规则, 不会影响直接通过 SUBSCRIBE 命令订阅的频道；
- 同样 UNSUBSCRIBE 命令也不会影响通过PSUBSCRIBE命令订阅的规则. 
- 使用 PUNSUBSCRIBE 命令退订某个规则时不会将其中的通配符展开, 而是进行严格的字符串匹配, 所以PUNSUBSCRIBE \* 无法退订 channel.\* 规则, 而是必须使用 PUNSUBSCRIBE channel.\* 才能退订. 

## 9. 管道

**往返时延** : 网络传输中,往返消息的总耗时.

**在执行多条命令时,每条命令都需要等待上一条命令执行完(即受到Redis返回的结果)才能执行, 即使命令并不需要上一条命令的执行结果**.

Redis 的底层通信协议对管道(pipelining)提供了支持. 通过管道可以**一次性发送多条命令**并在执行完后**一次性将结果返回**, 当一组命令中每条命令都不依赖于之前命令的执行结果时就可以将这组命令一起通过管道发出. 管道通过减少客户端与 Redis 的通信次数来实现降低往返时延累计值的目的

Redis 通过监听一个 TCP 端口或者 Unix socket 的方式来接收来自客户端的连接, 当一个连接建立后, Redis 内部会进行以下一些操作：

1. 客户端 socket 会被设置为非阻塞模式, 因为 Redis 在网络事件处理上采用的是**非阻塞多路复用模型**. 
2. 为这个 socket 设置 `TCP_NODELAY` 属性, 禁用 Nagle 算法. Nagle 算法实际就是当需要发送的数据攒到一定程度时才真正进行发包, 通过这种方式来减少 header 数据占比的问题. 不过在高互动的环境下是不必要的, 一般来说, 在客户端/服务器模型中会禁用. 
3. 创建一个可读的文件事件用于监听这个客户端 socket 的数据发送 Redis 管道技术可以在服务端未响应时, 客户端可以继续向服务端发送请求, 并最终一次性读取所有服务端的响应. 管道技术最显著的优势是提高了 redis 服务的性能. 

## 10. 内存优化 

### 10.1. redisObject 对象

redis 存储的所有值对象, 在内部定义为 redisObeject 结构体, 内部结构如下图:
![redisObject 结构图](http://oluv2yxz6.bkt.clouddn.com/redisObject.png)

Redis 存储的数据都使用 redisObject 来封装, 包括 string, hash, list, set, zset 在内的所有数据类型. 理解 redisObject 对内存优化非常有帮助, 下面介绍每个字段

    1. type 字段
        表示当前对象使用的数据类型, redis 主要支持 5 种数据类型 : string,hash,list,set,zset .

        可以使用 type {key} 命令查看对象所属类型, type 返回的是值对象类型, 键都是 string 类型.

    2. encoding 字段
        表示 redis 内部编码类型, encoding 在 redis 内存不使用, 代表当前对象内部使用哪种数据结构实现. 

        同一个对象采用不同的编码实现内存占用存在明显差异, 具体实现细节见 之后的编码部分.
            
    3. lru 字段
        记录对象最后一次被访问的时间, 当配置了 maxmemory 和 maxmemory-policy=volatile-lru | allkeys-lru 时, 用于辅助 LRU 算法删除键数据.

        使用 objectidletime {key} 命令在不更新 lru 字段情况下查看当前键的空闲时间.
        **开发提示：可以使用scan + object idletime  命令批量查询哪些键长时间未被访问, 找出长时间不访问的键进行清理降低内存占用**

    4. refcount 字段
        记录当前对象被引用的次数, 用于通过引用次数回收内存, 当 refcount=0 时, 可以安全回收当前对象空间. 

        使用 objectrefcount {key} 获取当前对象引用. 

        当对象为整数且范围在 0-9999 时, redis 可以使用共享对象的方式来节省内存.

    5. *ptr 字段
        与对象的数据内容有关, 如果是整数直接存储数据, 否则表示指向数据的指针. 
        Redis 在 3.0 之后对值对象是字符串且长度 <= 39 字节的数据, 内部编码为 embstr 类型, 字符串 sds 和 redisObject 一起分配, 从而只要一次内存操作.

        **高并发写入场景中, 在条件允许的情况下建议字符串长度控制在39字节以内, 减少创建redisObject内存分配次数从而提高性能. **

### 10.2. 缩减键值对象 
    降低 Redis 内存使用最直接的方式就是缩减键和值的长度.
        - key 长度 : 如在设计键时, 在完整描述业务情况下, 键值越短越好.
        - value 长度 : 值对象缩减比较复杂, 常见需求是把业务对象序列化成二进制数组放入 redis. 
            - 首先, 应该在业务上精简业务对象, 去掉不必要的属性避免存储无效数据.
            - 其次, 在序列化工具选择上, 应该选择更高效的序列化工具来降低字节数组大小.
            ![常见 java 序列化工具空间压缩对比](http://i2.itc.cn/20170216/3084_8e427aa5_bf49_c714_45f8_692fccf2cd6b_1.png)
            - 值对象除了存储二进制数据之外, 通常还会使用通用格式存储数据 比如 JSON, xml 等作为字符串存储在 redis 中. 这种方式的有点是方便调试和跨语言, 但是同样的数据相比字节数组所需的空间更大, 在内存紧张的情况下, 可使用通用压缩算法压缩 json,xml 后再存入 redis, 从而降低内存使用率, 例如 使用 GZIP 压缩后的 json 可以降低 60% 的空间.

            **当频繁压缩解压json等文本数据时, 开发人员需要考虑压缩速度和计算开销成本, 这里推荐使用google的Snappy压缩工具, 在特定的压缩率情况下效率远远高于GZIP等传统压缩工具, 且支持所有主流语言环境. **


### 10.3. 共享对象池
    对象共享池指 redis 内存维护 0-9999 的整数对象池, 创建大量的整数类型 redisObject 存在内存开销, 每个 redisObject 内部结构至少占 16字节, 甚至超过了证书自身空间开销. 

    除了整数值对象, 其他类型如 list,hash,set,zset 内部元素也可以使用整数对象池, 因此开发中, 在满足需求的前提下, 尽量使用整数对象以节省内存.

    整数对象池在Redis中通过变量 REDIS_SHARED_INTEGERS 定义, 不能通过配置修改. 可以通过object refcount 命令查看对象引用数验证是否启用整数对象池技术, 
        redis> set foo 100

        redis> object refcount foo
        (integer) 2
        redis> set bar 100
        redis> object refcount bar
        (integer) 3
        ![共享对象池图示](http://i0.itc.cn/20170216/3084_ffd40aaf_b79c_0c62_9751_650a6b0ccc53_1.png)

    **当设置maxmemory并启用LRU相关淘汰策略如:volatile-lru, allkeys-lru时, Redis禁止使用共享对象池, 即 共享对象池与maxmemory+LRU策略冲突 **

    LRU算法需要获取对象最后被访问时间, 以便淘汰最长未访问数据, 每个对象最后访问时间存储在redisObject对象的lru字段. 对象共享意味着多个引用共享同一个redisObject, 这时lru字段也会被共享, 导致无法获取每个对象的最后访问时间. 如果没有设置maxmemory, 直到内存被用尽Redis也不会触发内存回收, 所以共享对象池可以正常工作. 


### 10.4. 字符串优化
    0. 在 redis 内部, 所有的键都是字符串类型, 值对象数据除了整数之外都使用字符串存储.

    1. 字符串结构
        Redis 自己实现了字符串结构, 内部简单动态字符串(Simple dynamic string), SDS.
        ![SDS 结构图](http://i2.itc.cn/20170216/3084_54bb9bb0_a89d_8e7e_2edb_11fcfc6ee5f1_1.png)

        SDS 特点
            - O(1) 的时间复杂度获取 : 字符串长度,已用长度, 未用长度
            - 可用于保存字节数组, 支持安全的二进制数据存储
            - 内部实现空间预分配机制, 降低内存再分配次数.
            - 惰性删除机制, 字符串缩减后的空间不释放, 作为预分配空间保留.

    2. 预分配机制.
        因为 字符串SDS 存在预分配jizhi,日常开发中要小心预分配带来的内存浪费.

        空间预分配规则 :
            - 第一次创建len属性等于数据实际大小, free等于0, 不做预分配. 
            - 修改后如果已有free空间不够且数据小于1M, 每次预分配一倍容量. 如原有len=60byte, free=0, 再追加60byte, 预分配120byte, 总占用空间:60byte+60byte+120byte+1byte. 
            - 修改后如果已有free空间不够且数据大于1MB, 每次预分配1MB数据. 如原有len=30MB, free=0, 当再追加100byte ,预分配1MB, 总占用空间:1MB+100byte+1MB+1byte. 

            ** 尽量减少字符串频繁修改操作如append, setrange, 改为直接使用set修改字符串, 降低预分配带来的内存浪费和内存碎片化 **

    3. 字符串重构 : 
        不一定吧每份数据作为字符串整体存储, 像 json 这样的数据可以使用 hash 结构, 使用二级结构存储也能帮助我们节省内存. 同时可以使用hmget,hmset命令支持字段的部分读取修改, 而不用每次整体存取. 

### 10.5. 编码优化

#### 10.5.1. 编码

Redis对外提供了string,list,hash,set,zet等类型, 但是Redis内部针对不同类型存在编码的概念, 所谓编码就是具体使用哪种底层数据结构来实现. 编码不同将直接影响数据的内存占用和读写效率. 使用object encoding {key}命令获取编码类型. 

Redis 为每种数据类型都提供了两种内部编码方式,

查看key 的内部编码方式:

    > OBJECT ENCODING key

数据类型与编码方式

    数据类型        内部编码方式                OBJECT_ENCODING命令结果     数据结构 

    字符串类型      REDIS_ENCODING_RAM          'raw'                       动态字符串编码
                    REDIS_ENCODING_INT          'int'                       整数编码
                    REDIS_ENCODING_EMBSTR       'embstr'                    优化内存分配的字符串编码

    散列类型        REDIS_ENCODING_HT           'hashtable'                 散列表编码
                    REDIS_ENCODING_ZIPLIST      'ziplist'                   压缩列表编码

    列表类型        REDIS_ENCODING_LINKEDLIST   'linkedlist'                双向链表编码
                    REDIS_ENCODING_ZIPLIST      'ziplist'                   压缩列表编码
                    REDIS_ENCODING_QUICKLIST    'quicklist'                 3.2 版本新的列表编码

    集合类型        REDIS_ENCODING_HT           'hashtable'                 散列表编码
                    REDIS_ENCODING_INTSET       'intset'                    整数集合编码

    有序集合类型    REDIS_ENCODING_SKIPLIST     'skiplist'                  跳跃表编码
                    REDIS_ENCODING_ZIPLIST      'ziplist'                   压缩列表编码    

#### 10.5.2. type 和 encoding 对应关系

| 类型 | 编码方式 | 数据结构 |  转换条件 |
| ---  |  ---     | ---      |  ---      |
| string | raw    | 动态字符串编码 | |
| string | embstr | 优化内存分配的字符串编码 | | 
| string | int  | 整数编码 |  | 
| hash  | hashtable     | 散列表编码     | 满足任意条件 : ① value 最大空间(字节) > hash-max-ziplist-value ; ② field 个数 > hash-max-ziplist-entries |
| hash  | ziplist   | 压缩列表编码    | 满足所有条件 : ① value 最大空间(字节) <= hash-max-ziplist-value ; ② field 个数 <= hash-max-ziplist-entries |
| list  | linkedlist| 双向链表编码    | 满足任意条件 : ① value 最大空间(字节) > list-max-ziplist-value ; ② 链表长度 > list-max-ziplist-entries | 
| list  | ziplist   | 压缩列表编码    | 满足所有条件 : ① value 最大空间(字节) <= list-max-ziplist-value ; ② 链表长度 <= list-max-ziplist-entries |
| list  | quicklist | 3.2 版本新的列表编码 | 废弃 list-max-ziplist-entries 配置, 新配置 : ① list-max-ziplist-size 表示最大压缩空间或长度, 最大空间使用 [-5-1]范围配置, 默认 -2 表示 8KB , 正整数表示最大压缩长度;② list-compress-depth 表示最大压缩深度, 默认 0 不压缩 ; |
| set   | hashtable | 散列表编码   | 满足任意条件 : ① 元素必须为非整数类型 ; ② 集合长度 > hash-max-ziplist-entries | 
| set   | intset    | 整数集合编码 | 满足所有条件 : ① 元素必须为整数 ; ② 集合长度 <= hash-max-ziplist-entries |
| zset  | skiplist  | 跳跃列表编码 | 满足任意条件 : ① value最大空间(字节) > zset-max-ziplist-value ; ② 有序集合长度 > zset-max-ziplist-entries |
| zset  | ziplist   | 压缩列表编码 | 满足所有条件 : ① value最大空间(字节) <= zset-max-ziplist-value ; ② 有序集合长度 <= zset-max-ziplist-entries |

#### 10.5.3. 控制编码类型

**编码类型转换**在 redis 写入数据时 **自动完成**, 这个转换**过程不可逆.**
转换规则只能**从小内存编码向大内存编码**转换.

转换示例 : 

    redis> lpush list:1 a b c d
    (integer) 4 //存储4个元素
    redis> object encoding list:1
    "ziplist" //采用ziplist压缩列表编码
    redis> config set list-max-ziplist-entries 4
    OK //设置列表类型ziplist编码最大允许4个元素
    redis> lpush list:1 e
    (integer) 5 //写入第5个元素e
    redis> object encoding list:1
    "linkedlist" //编码类型转换为链表
    redis> rpop list:1
    "a" //弹出元素a
    redis> llen list:1
    (integer) 4 // 列表此时有4个元素
    redis> object encoding list:1
    "linkedlist" //编码类型依然为链表, 未做编码回退, 因为回退非常消耗 cpu, 得不偿失.

转换规则 见 10.5.2 表 : 
- 可以使用 `config set` 命令设置编码相关参数来满足使用压缩编码的条件.
- 对于采用非压缩编码类型的数据, 如 hashtable, linkedlist 等, 设置参数后即使数据满足压缩编码的条件, redis 也不会做转换, 需要**重启** redis 重新加载数据才能完成转换.

#### 10.5.4. ziplist 编码

主要为节约内存, 因此所有数据都采用线性连续的内存结构.

应用最广泛, 可以作为 hash, list, zset 类型的底层数据结构实现.

![ziplist 内部结构](http://oluv2yxz6.bkt.clouddn.com/ziplist_%E5%86%85%E9%83%A8%E7%BB%93%E6%9E%84.png)

字段含义 : 

- zlbytes : 记录整个压缩列表所占字节长度, 方便重新调整 ziplist 空间, 类型是 int-32, 长度为 4 字节.
- zltail : 记录距离尾节点的偏移量, 方便尾节点弹出操作, 类型 int-32, 长度 4 字节.
- zllen : 记录压缩链表节点数量, 当长度超过 216-2 时需要遍历整个列表获取长度, 一般很少见, 类型 int-16 , 长度为 2 字节.
- entry-1 : 记录具体的节点, 长度根据实际存储的数据而定.
    entry 
    - prev_entry_butes_length : 记录前一个节点所占空间, 用于快速定位上一个节点, 可实现列表反向迭代.
    - encoding : 表示当前节点的编码和长度, 前两位表示编码类型: 字符串/整数, 其余位表示数据长度.
    - contents : 保存节点值, 针对实际数据长度做内存占用优化.
- entry-2 :
    entry 
    - prev_entry_butes_length : 
    - encoding : 
    - contents : 
- zlend :

ziplist 数据结构特点 :
- 内部表现为数据紧凑排列的一块连续内存数组.
- 可以模拟双向链表结构, 以 O(1) 时间复杂度入队和出队,
- 新增删除操作设计内存重新分配或释放, 加大了操作的复杂性.
- 读写操作设计复杂的指针移动, 最坏的时间复杂度为 O(n2)
- 适合存储小对象和长度有限的数据.

注意:
1. **ziplist压缩编码的性能表现跟值长度和元素个数密切相关.**
2. **这对性能要求较高的场景使用 ziplist , 建议 长度不要超过 1000, 每个元素大小控制在 512 字节以内.**
3. **命令平均消耗时间使用 info Commandstats 命令获取, 包含每个命令调用次数, 总耗时, 平均耗时, 单位 微秒**
    redis> info Commandstats

#### 10.5.5. intset 编码

intset 是集合(set)类型编码的一种, 内部表现为存储有序, 不重复的整数集.
当集合只包含 整数, 且 长度不超过 set-max-intset-entries 配置时, 被启用.

    127.0.0.1:6379> sadd set:test 3 4 2 6 8 9 2
    (integer) 6
    127.0.0.1:6379> OBJECT encoding set:test
    "intset"
    127.0.0.1:6379> SMEMBERS set:test
    1) "2"
    2) "3"
    3) "4"
    4) "6"
    5) "8"
    6) "9"
    127.0.0.1:6379> CONFIG SET set-max-intset-entries 6
    OK
    127.0.0.1:6379> sadd set:test 5
    (integer) 1
    127.0.0.1:6379> SMEMBERS set:test
    1) "6"
    2) "3"
    3) "8"
    4) "4"
    5) "9"
    6) "2"
    7) "5"
    127.0.0.1:6379> OBJECT encoding set:test
    "hashtable"
    127.0.0.1:6379> SMEMBERS set:test
    1) "6"
    2) "3"
    3) "8"
    4) "4"
    5) "9"
    6) "2"
    7) "5"

**intset 对写入证书进行排序, 通过 O(log(n)) 时间复杂度实现查找和去重操作**

![intset 内部结构](http://i1.itc.cn/20170216/3084_5417a9b7_6050_0614_09f1_ce8565f04eca_1.png)
字段含义 :
- encoding : 整数表示类型, 格局集合内最长整数值确定类型, 证书类型划分三种 : int-16, int-32, int-64 .
- length : 表示集合元素个数.
- contents : 整数数组, 按从小到大顺序保存.

intset 保存的整数类型根据长度划分, 当保存的证书超出当前类型时, 将会触发自动升级操作, 且升级后不能做回退. 升级操作会导致重新申请内存空间, 把原有数据安装转换类型后拷贝到新数组.

**使用intset编码的集合时, 尽量保持整数范围一致, 如都在int-16范围内. 防止个别大整数触发集合升级操作, 产生内存浪费. **

### 10.6. 控制 key 的数量

当使用 redis 存储大量数据时, 通常会存在大量键, 过多的键同样会消耗大量内存.

Redis本质是一个数据结构服务器, 它为我们提供多种数据结构, 如hash, list, set, zset 等结构. 

### 10.7 系统优化

#### 10.7.1. 内存
##### 10.7.1.1 vm.overcommit_memory
Linux 操作系统对大部分申请内存的请求都恢复 yes, 以便能运行更多的程序, 应为申请内存之后, 并不会马上使用内存, 这种技术叫做**overcommit**.

`vm.overcommit_memory` 用来设置内存分配策略, 他有三个可选值:

- `0` : 表示内核将检查是否有足够的可用内存. 如果有足够的可用内存, 内存申请通过, 否则内存申请失败, 并把错误返回给应用进程.
- `1` : 表示内核允许超量使用内存直到用完为止.
- `2` : 表示内存绝不过量的使用内存("never overcommit"), 即系统整个内存地址空间不能超过 **swap + 50% RAM** 的值, 50% 是 overcommit_ratio 的默认值, 此参数同样支持修改.


报错信息:
    
    # WARNING overcommit_memory is set to 0! Background save may fail under low memory condition. To fix this issue add 'vm.overcommit_memory = 1' to /etc/sysctl.conf and then reboot or run the 
    command 'sysctl vm.overcommit_memory=1' for this to take effect.

报错中的 `Background save` 代表的是 bgsave 和 bgrewritaof, 如果当前内存不足, 操作系统应该如何处理 fork. 

如果`vm.overcommit_memory=0`, 代表如果没有可用内存, 就申请内存失败, 对应到 redis 就是 fork 执行失败, Redis 报错 `Cannot allocate memory`.


推荐配置:
    
    vm.overcommit_memory = 1

配置方法:
    
    # 查看当前配置
    $ cat /proc/sys/vm/overcommit_memory

    # 设置
    $ echo "vm.overcommit_memory" >> /etc/sysctl.conf
    $ sysctl vm.overcommit_memory=1

最佳实践:
1. Redis 设置合理的 maxmemory, 保证机器有 20% ~ 30% 的闲置内存.
2. 集中化管理 aof 重写 和 rdb 的 bgsave.
3. 设置 vm.overcommit_memory=1, 防止极端情况下, 会造成 forl 失败.


##### 10.7.1.2 swappiness

swap 对于操作系统来说比较重要, 当物理内存不足时, 可以 swap out 一部分内存页, 以解燃眉之急. 但是, swap 空间由硬盘提供, 对于需要高并发, 高吞吐的应用来说, 磁盘 IO 通常会成为系统瓶颈.

在 Linux 中, 并不是要等到所有物理内存都使用完才会使用 swap, 系统参数 swappiness 会决定操作系统使用 swap 的倾向程度.

swappiness 的取值范围是 0 ~ 100, swappiness 的值越大, 说明操作系统可能使用 swap 的概率越高. swappiness 值越低, 表示操作系统更加倾向于使用武力内存. swap 的默认值为 60.

| swappiness | 策略 |
| --- | --- |
| 0   | Linux 3.5 及以上: 宁愿 OOM , 也不用 swap; Linux 3.4 及以下 : 宁愿 swap 也不要 OOM|
| 1   | Linux 3.5 及以上 : 宁愿 swap 也不要 OOM. |
| 60   | 默认值 |
| 100   | 操作系统主动使用 swap |

设置方法:
    
    echo VALUE > /proc/sys/vm/swappiness
    echo "vm.swappiness=VALUE" >> /etc/sysctl.conf

查看 redis 进程 swap 使用情况:
    
    cat /proc/REDIS_ID/smaps | grep Swap

最佳实践:
    
    如果 Linux > 3.5 , vm.swappiness=1 ;
    否则 vm.swappiness=0, 从而实现如下两个目标:

    - 物理内存充足时, redis 足够快
    - 物理内存不足时, 避免 redis 死掉. 
    - 如果 redis 为高可用, 死掉比阻塞好.

##### 10.7.1.3 Transparent Huge Pages

Linux kernel 在 2.6.38 内核增加了 Transparent Huge Pages(THP) 特性, 支持大内存页(2M)分配,  **默认开启**. 

1. 当开启时可以降低 fork 子进程的速度, 但 fork 之后, 每个内存页从原来 4KB 变为 2MB, 会大幅着呢个件重写期间父进程内存消耗. 

2. 同时每次写命令引起的复制内存页单位放大了 512倍, 会拖慢写操作的执行时间, 导致大量写操作慢查询. 

因此, redis 建议禁止THP 特性:
    
    $ echo never > /sys/kernel/mm/transparent_hugepage/enabled
    
    $ echo "echo never > /sys/kernel/mm/transparent_hugepage/enabled" >> /etc/rc.local

    注意有些发行版将 THP 放在 /sys/kernel/mm/redhat_transparent_hugepage/enabled 中:

    $ echo never > /sys/kernel/mm/redhat_transparent_hugepage/enabled


##### 10.7.1.4 OOM killer

OOM killer 会在可用内存不足时, 选择性的杀掉用户进程. OOM killer 进程会为每个用户进程设置一个权值, 这个权值越高, 被杀掉的概率越高, 反之, 越低. 

每个进程的权值存放在 `/proc/PID/oom_score` 中, 这个值收到 `/proc/PID/oom_adj` 的控制, oom_adj 在不同的 Linux 版本中最小值不同, 可以参考 Linux
源码中 oom.h (从 -15 到 -17). 当 oom_adj 设置为最小时, 该进程将不会被 OOM killer 杀掉.

对于 redis 所在的服务器来说, 可以将所有 Redis 的 oom_adj 设置为最低值或者稍小的值, 降低被 OOM killer 杀掉的概率.
    
    $ echo VALUE > /proc/POD/oom_adj

**提示**:
- oom_adj 参数只起到**辅助作用**, 合理的规划内存更为重要;
- 在高可用的情况下, 被杀掉比僵死更好, 因此不要过多依赖 oom_adj 配置.

#### 10.7.2. 系统优化
##### 10.7.2.1 使用 NTP

我们知道像Redis Sentinel和Redis Cluster这两种需要多个Redis实例的类型, 可能会涉及多台服务器. 虽然Redis并没有对多个服务器的时钟有严格的要求, 但是假如多个Redis实例所在的服务器时钟不一致, 对于一些异常情况的日志排查是非常困难的, 

##### 10.7.2.2 ulimit
在 Linux 中, 可以通过 ulimit 查看和设置系统的当前用户进程的资源数. 其中 `open files` 参数, 是单个用户同时打开的最大文件个数.

Redis 允许同时有多个客户端通过网络进行连接, 可以通过设置 `maxclients` 来限制最大客户端连接数. 对 Linux 操作系统来说这些网络连接都是文件句柄.

`ulimit open files` 的限制优先级比 `maxclients` 大. redis 建议把 `open files` 至少设置成 10032 , 因为 `maxclients` 的默认值是 10000, 这些用来处理客户端连接, 除此之外, Redis 内部会使用最多 32 个文件描述符, 所以 10032 = 10000 + 32.

#### 10.7.3. 网络
##### 10.7.3.1 TCP backlog

Redis 默认的 tcp-backlog 为 511, 可以通过修改配置 tcp-backlog 进行调整. 如果 Linux 的 tcp-backlog 小于 redis 设置的 tcp-backlog, 那么启动时会报错:

    # WARNING: The TCP backlog setting of 511 cannot be enforced because /proc/sys/net/core/somaxconn is set to the lower value of 128.

修改 TCP backlog :
    
    $ cat /proc/sys/net/core/somaxconn

    $ echo 511 > /proc/sys/net/core/somaxconn


## 11. python与redis

        $ pip install redis

        # 创建链接:
        import redis
        r = redis.StrictRedis(host='127.0.0.1',port='6379',db=0)
        r.set('foo','bar')
        r.get('foo')

        # 字典 HMSET/HGETALL

            HMSET : 将字典作为参数存储
            HGETALL : 返回值为字典.

        # 管道和事务
          
          * 事务
            pipe = r.pipeline()
            pipe.set('foo', 'bar')
            pipe.get('foo')
            result = pipe.execute()
            print result        # [True, 'bar']

          * 管道  : 管道的使用方式和事务相同, 只不过需要在创建时加上参数transaction=False：
            pipe = r.pipeline(transaction=False)

          * 链式调用 : 事务和管道还支持链式调用：

            result = r.pipeline().set('foo', 'bar').get('foo').execute()    # [True, 'bar']

## 12. redis 与 lua : Lua 语法简介
### 12.1. 数据类型 :

lua 是一个动态类型语言,一个变量可以存储类型的值.
Lua 常用数据类型:

空(nil)      空类型只包含一个值,即nil . nil表示空, 没有赋值的变量或标的字段都是 nil.
布尔(boolean)     布尔类型包含 True 和 False 两个值.
数字(number)  整数合浮点数是都是使用数字类型存储.
字符串(string)     字符串类型可以存储字符串,且与Redis的键值一样都是二进制安全的.字符串可以使用单引号或双引号表示,两个符号是相同的. 字符串可以包含转义字符,如 '\n','\r' 等.
表(table)        表类型是Lua 语言中唯一的数据结构,既可以当数组,又可以当字典,十分灵活.
函数(function)    函数是Lua中的一等值(first-class value),可以存储在变量中,作为函数的参数或返回结果.

### 12.2. 变量:

Lua 变量分为全局变量和局部变量. 全局变量无需声明就可以直接使用,默认值是 nil .
    > print(b)

a = 1　　 --为全局变量a赋值
a = nil   -- 删除全局变量的方法是将其复制为 nil . 全局变量没有声明与未声明之分,只有非 nil 和 nil 的区别.
print(b)　--无需声明即可使用, 默认值是nil

* 在Redis脚本中不能使用全局变量,只允许使用局部变量,以防止脚本之间相互影响.

声明局部变量的方式为 "local 变量名" :
    local c　　--声明一个局部变量c, 默认值是nil
    local d = 1　--声明一个局部变量d并赋值为1
    local e, f　--可以同时声明多个局部变量           

    * 局部变量的作用域为从声明开始到所在层的语句块的结尾.

声明一个存储函数的局部变量的方法为 :
    local say_hi = function ()
        print 'hi'
    end     

* 变量名必须是非数字开头,只能包含字母,数字和下划线,区分大小写. 变量名不能与Lua的保留关键字相同, 保留关键字如下:
    and break do else elseif end false for function if in local nil not or repeat return then true until while 

### 12.3. 注释 : 
单行 : 以 -- 开始,到行尾结束.
多行 : 以 --[[ 开始 ,到 ]] 结束.

### 12.4. 赋值 :
多重赋值 : 
    local a, b = 1, 2　   -- a的值是1, b的值是2
    local c, d = 1, 2, 3　-- c的值是1, d的值是2, 3被舍弃了
    local e, f = 1　　      -- e的值是1, f的值是nil

在执行多重赋值时,Lua会先计算所有表达式的值,比如: 
    local a = {1, 2, 3}
    local i = 1
    i, a[i] = i + 1, 5      -- i = 2 ; a = {5,2,3} , lua 索引从 1 开始.

lua 中的函数也可以返回多个值

### 12.5. 操作符
#### 12.5.1. 数学操作符 : 

常见的+、-、*、/、%(取模)、-(一元操作符, 取负)和幂运算符号^. 

数学操作符的操作数如果是字符串,则会自动转换为数字.

    print('1' + 1)　　-- 2
    print('10' * 2)　　-- 20          

#### 12.5.2. 比较操作符 : 

比较操作符的结果一定是布尔类型 ;
比较操作符,不会对两边的操作数进行自动类型转换.

    == : 比较两个操作数的类型和值是否相等
    ~= : 与 == 结果相反
    <,>,<=,>= : 大于,小于,小于等于,大于等于.   

#### 12.5.3. 逻辑操作符 :
只要操作数不是 nil 或 false ,逻辑操作符都认为操作数是真. 特别注意 0 或 空字符串也被当做真. 

Lua 逻辑操作符支持短路, 也就是说对于 false and foo() , lua 不会调用foo函数, or类似. 

    not : 根据操作数的真和假返回false 和 true
    and : a and b, 如果a 是真,则返回 b , 否则返回 a .
    or  : a or b , 如果a 是假,则返回 a , 否则返回 b .
    
    

#### 12.5.4. 连接操作符. "..." 用来连接两个字符串.

连接操作符会自动把**数字类型**的转换成**字符串类型**.

#### 12.5.5. 取长度操作符. 是lua5.1 新增的操作符, "#" ,用来获取字符串或表的长度.

    > print(#'hello')  -- 5

#### 12.5.6. 运算符的优先级:

    ^
    not # -(一元)
    * / %
    + -
    ..
    < > <= >= ~= ==
    and 
    or

### 12.6. if 语句
语法 :

    if 条件表达式 then
        语句块
    elseif 条件表达式 then
        语句块
    else
        语句块
    end

注意 : Lua 中只有 nil 和 false 才是假, 其余值,包括0 和空字符串,都被认为是真值. **在 Redis 的EXISTS命令返回值 1 和 0 分别表示存在或不存在,但无论如何,两个值在Lua 中都是真值**.

Lua 每个语句都可以 `;` 结尾 ,但是一般来说编写 Lua 是会省略 `;` ,

Lua 并不强制要求缩进,所有语句也可以写在一行中, 但为了增强可读性,建议在注意缩进.

    > a = 1 b = 2 if a then b = 3 else b = 4 end


### 12.7. 循环语句

1. while 循环

        while 条件表达式 do
            语句块
        end

2. repeat 循环

        repeat 
        语句块
        until 条件表达式

3. for 循环

    形式一 :

        for 变量=初值,终值,步长 do  -- 步长可省略,默认为 1
            语句块
        end

        # 计算 1 ~ 100 之和
        local sum = 0
        for i = 1 ,100 do
            sum = sum + 1
        end

        // for 循环中的 i 是**局部变量**, 作用域为 for 循环体内. 虽然没有使用 local 声明,但它不是全局变量.

    形式二 : 

        for 变量1 ,变量2, ... , 变量N in 迭代器 do
            语句块
        end

    在编写Redis脚本时,我们常用通用形式的for 语句遍历表的值.

### 12.8. 表类型

表是Lua中唯一的数据结构,可以理解为关联数组,任何类型的值(除了空类型)都可以作为表的索引.

    a = {}　　　　        --将变量a赋值为一个空表
    a['field'] = 'value'　--将field字段赋值value
    print(a.field)　　    --打印内容为'value', a.field是a['field']的语法糖.       


    people = {　　　--也可以这样定义
        name = 'Bob',
        age = 29
    }

**当索引为整数的时候表和传统的数组一样**, 例如：
    a = {}
    a[1] = 'Bob'
    a[2] = 'Jeff'
    可以写成下面这样：
    a = {'Bob', 'Jeff'}
    print(a[1])　　　　--打印的内容为'Bob'        

**可以使用通用形式的for语句遍历数组**,例如:

    for index,value in ipairs(a) do     -- index 迭代数组a 的索引 ; value 迭代数组a 的值.
        print(index)
        print(value)
    end

    ** ipairs 是Lua 内置的函数,实现类似迭代器的功能.

**数字形式的for语句**

    for i=1,#a do
        print(i)
        print(a[i])
    end

**pair : 迭代器,用来遍历非数组的表值**

    person = {
        name = 'bob',
        age = 29
    }
    for index,value in pairs(person) do
        print(index)
        print(value)
    end

`pairs` 与 `ipairs` 的**区别**在于前者会办理所有值不为 nil 的索引, 而后者只会从索引 1 开始递增遍历到最后一个值不为 nil 的整数索引.

### 12.9. 函数   
函数的一般格式:

    function(参数列表)
        函数体
    end

示例:

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

可以将函数**赋值**给一个局部变量, 比如:

    local square = function(num)
        return num*num
    end

    // 因为在赋值前声明了局部变量 square, 所以可以在函数内部引用自身(实现递归).

**函数参数** :
- 如果实参的个数小于形参的个数,则没有匹配到的形参的值为 nil . 
- 相对应的,如果实参的个数大于形参的个数,则多出的实参会被忽略. 
- 如果希望捕获多出的参数(即实现可变参数个数),可以让最后一个形参为 '...' . 

### 12.10. return & break
在 Lua 中 `return` 和 `break` (用于跳出循环) 语句**必须**是语句块中的**最后一条语句**, 简单的说在这两条语句之后只能是 `end`,`else` 或 `until` 三者之一. 

如果希望在语句块中间使用这两条语句,可以人为的使用 `do` 和 `end` 将其包围 .

### 12.11. [标准库](http://www.lua.org/manual/5.1/manual.html#5)

Lua 的标准库中提供了很多使用的函数, 比如 `ipairs`,`pairs`,`tonumber`,`tostring`,`unpack` 都属于标准库中的**Base库**.

Redis 支持大部分Lua标准库,如下所示:

| 库名 | 说明 |
| --- | --- |
| Base |   一些基础函数 |
| String | 用于字符串操作的函数 |
| Table |  用于表操作的函数 |
| Math |   数学计算函数 |
| Debug |  调试函数 |

#### 12.11.1 String库 : 可以通过字符串类型的变量以面向对象的形式访问, 如 string.len(string_var) 可以写成 string_var:len()

获取字符串长度 : string.len(string) 作用与操作符 "#" 类似
    
    > print(string.len('hello'))  -- 5
    > print(#'hello')   -- 5

转换大小写 

    string.upper(string)
    string.lower(string)

获取子字符串

    string.sub(string start[,end ])    -- end 默认为 -1.

string.sub() 可以获取一个字符串从索引 start 开始到 end 结束的子字符串,索引从1 开始. 索引也可以是负数, -1 代表最后一个元素 . 

    > print(string.sub('hello',1))     -- hello
    > print(string.sub('hello',2))     -- ello
    > print(string.sub('hello',2,-2))  -- ell

#### 12.11.2 Table库 : 其中大部分函数都需要表的形式是数组形式.

将数组转换为字符串
    
    table.concat(table [,sep [,i [,j]]])
        - sep : 以 sep 指定的参数分割, 默认为空.
        - i , j : 用来限制要转换的表元素的索引范围. 默认分别为 1 和 表的长度. 不支持负索引.

    > print(table.concat({1,2,3}))     --123
    > print(table.concat({1,2,3},',',2))  --2,3
    > print(table.concat({1,2,3},',',2,2)) --2

向数组中插入元素 :
    
    # 在指定索引位置 pos 插入元素 value, 并将后面的元素顺序后移. 默认 pos 值是数组长度加 1 , 即在数组尾部插入.
    table.insert(table ,[pos,] value)   

    > a = {1,2,4}
    > table.insert(a,3,3)  # {1,2,3,4}
    > table.insert(a,5)    # {1,2,3,4,5}
    > print(table.concat(a,','))
    1,2,3,4,5

从数组中弹出一个元素
    
    # 从指定的索引删除一个元素,并将后面的元素前移,返回删除元素值. 默认 pos 的值是数组的长度,即从数组尾部弹出一个元素.
    table.remove(table,[,pos])  

    > table.remove(a)     --{1,2,3,4}
    > table.remove(a,1)   --{2,3,4}
    > print(table.caoncat(a,','))
    2,3,4
    

#### 12.11.3 Math库 : 提供常用的数学运算函数, 如果参数是字符串会自动尝试转换成数字.

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
        
### 12.12. 其他库

Redis 还通过 **cjson库** 和 **cmsgpack库** 提供了对 `JSON` 和 `MessagePack`的支持. Redis自动加载了这两个库,在脚本中可以分别通过 `cjson` 和 `cmsgpack` 两个全局变量来访问对应的库.

    local people = {
        name = 'bob',
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

### 12.13. Redis 与 Lua

1. 在脚本中调用redis命令：

        redis.call('set', 'foo', 'bar')
        local value = redis.call('get', 'foo')　-- value的值为bar       

2. 脚本相关命令

        redis> EVAL 脚本内容 key参数数量 [key...] [arg...]

## 13. 持久化

### 13.1. RDB方式 : 存数据. 快照式. 根据指定的规则“定时”将内存中的数据存储在硬盘上

RDB 方式的持久化是通过快照(snapshotting)完成的, 当符合一定条件时Redis会自动将内存中的所有数据生成一份副本并存储在硬盘上, 这个过程即为**快照**.

#### 13.1.1 实现方式及原理:

1. Redis 在进行数据持久化的过程中, 会先**将数据写入到一个临时文件中**, 待持久化过程都结束了, 才会**用这个临时文件替换上次持久化好的文件**. 正是这种特性, 让我们可以随时来进行备份, 因为**快照文件总是完整可用的**.

2. 对于 RDB 方式, redis 会单独创建 (fork) 一个**子进程**来进行持久化, 而主进程是不会进行任何IO操作的, 这样就确保了redis 极高的性能. 

3. 如果需要进行大规模数据的恢复, 且对于数据恢复的完整性不是非常敏感, 那 RDB 方式要比 AOF 方式更加的高效. 

4. 虽然 RDB 有不少优点, 但它的缺点也是不容忽视的. 如果你对数据的完整性非常敏感, 那么 RDB 方式就不太适合你, 因为即使你每 5 分钟都持久化一次, 当 redis 故障时, 仍然会有近 5 分钟的数据丢失. 

5. 在执行 fork 的时候操作系统(类 Unix 操作系统)会使用写时复制(copy-on-write)策略, 即fork函数发生的一刻父子进程共享同一内存数据, 当父进程要更改其中某片数据时(如执行一个写命令), 操作系统会将该片数据复制一份以保证子进程的数据不受影响, 所以**新的RDB文件存储的是执行 fork 一刻的内存数据**.

6. 另外需要注意的是, 当进行快照的过程中, 如果写入操作较多, 造成 fork 前后数据差异较大, 是会使得内存使用量显著超过实际数据大小的, 因为内存中不仅保存了当前的数据库数据, 而且还保存着 fork 时刻的内存数据. 进行内存用量估算时很容易忽略这一问题, 造成内存用量超限. 

7. 任何时候 RDB 文件都是完整的. 这使得我们可以通过定时备份 RDB 文件来实现 Redis 数据库备份. 

8. RDB 文件是经过**压缩**(可以配置rdbcompression参数以禁用压缩节省CPU占用) 的二进制格式, 所以占用的空间会小于内存中的数据大小, 更加利于传输. 

9. Redis启动后会读取RDB快照文件, 将数据从硬盘载入到内存. 根据数据量大小与结构和服务器性能不同, 这个时间也不同. 通常将一个记录1000万个字符串类型键、大小为1 GB 的快照文件载入到内存中需要花费20～30秒. 

10. 通过RDB方式实现持久化, 一旦Redis异常退出, 就会丢失最后一次快照以后更改的所有数据. 这就需要开发者根据具体的应用场合, 通过组合设置自动快照条件的方式来将可能发生的数据损失控制在能够接受的范围. 


**快照过程**:

1. Redis使用fork函数复制一份当前进程(父进程)的副本(子进程)；

2. 父进程继续接收并处理客户端发来的命令, 而子进程开始将内存中的数据写入硬盘中的临时文件；

3. 当子进程写入完所有数据后会用该临时文件替换旧的 RDB 文件, 至此一次快照操作完成.


#### 13.1.2 Redis对数据进行快照情况/场景:

1. 根据配置规则进行自动快照 : `redis.conf`
    
    **时间窗口** M 和 **改动键的个数** N : 每当时间 M 内被改动的键的个数大于 N 时,即自动快照.

        save 900 1
        save 300 10
        save 60 10000               

    - 同时可以存在多个条件, 条件之间是**或**的关系.
    - 时间单位是 秒 .

2. 用户指定 `SAVA` 或 `BGSAVE` 命令

    当进行服务重启、手动迁移以及备份时我们也会需要手动执行快照操作. 

    - `SAVE` : 

        当执行`SAVE`命令时, Redis**同步**地进行快照操作, 在快照执行的过程中会**阻塞所有来自客户端的请求**. 当数据库中的数据比较多时, 这一过程会导致 Redis 较长时间不响应, 所以要**尽量避免在生产环境中使用**这一命令. 

    - `BGSAVE` : 

        需要手动执行快照时推荐使用 `BGSAVE` 命令. 

        `BGSAVE` 命令可以在后台**异步**地进行快照操作, 快照的同时服务器还可以继续响应来自客户端的请求. 

        执行 BGSAVE后Redis会立即返回 OK 表示开始执行快照操作, 

        如果想知道快照是否完成, 可以通过 `LASTSAVE`命令获取**最近一次成功执行快照的时间**, 返回结果是一个Unix时间戳. 

3. 执行 `FLUSHALL` 命令

    当执行 FLUSHALL 命令时, Redis 会清除数据库中的所有数据. 需要注意的是, **不论清空数据库的过程是否触发了自动快照条件, 只要自动快照条件不为空**, Redis就会执行一次快照操作. 

    **当没有定义自动快照条件时, 执行FLUSHALL则不会进行快照**.

4. 执行复制(replication) 时.

    当设置了**主从模式**时, Redis 会在**复制初始化**时进行自动快照. 

    当使用复制操作时, 即使没有定义自动快照条件, 并且没有手动执行过快照操作, 也会生成RDB快照文件. 

#### 13.1.3 快照保存 : 

Redis默认会将快照文件存储在Redis **当前进程的工作目录**中的`dump.rdb`文件中, 

也可以通过修改如下 `redis.conf` 中的参数, 指定快照文件的保存位置:

- `dir` : 指定快照文件的 **存放路径**;
- `dbfilename` : 指定 **rdb 文件名**. 


#### 13.1.4 关闭 RDB :

    redis > CONFIG SET save ""

### 13.2. AOF方式 : 存操作. 在每次执行命令后将命令本身记录下来, Append Only File.

#### 13.2.1. 原理

只允许**追加**不允许改写的文件.  AOF 方式是将执行过的**写指令**记录下来, 在数据恢复时按照从前到后的顺序再将指令都执行一遍, 就这么简单. 


AOF可以将Redis执行的每一条写命令追加到硬盘文件中, 这一过程显然会降低Redis 的性能, 但是大部分情况下这个影响是可以接受的, 另外使用较快的硬盘可以提高AOF的性能. 

原理 : 以纯文本方式实现.

    AOF文件的内容正是 Redis 客户端向 Redis 发送的原始通信协议的内容.

    在启动时Redis会逐个执行AOF文件中的命令来将硬盘中的数据载入到内存中, 载入的速度相较RDB会慢一些. 

AOF 重写的内部运行**原理** : 

1. 在重写即将开始之际, redis 会创建(fork)一个**重写子进程**, 这个子进程会首先读取现有的 AOF 文件, 并将其包含的指令进行分析压缩并写入到一个临时文件中. 

2. 与此同时, 主工作进程会将新接收到的写指令一边累积到*内存缓冲区*中, 一边继续写入到原有的 AOF 文件中, 这样做是保证原有的 AOF 文件的可用性, 避免在重写过程中出现意外. 

3. 当**重写子进程**完成重写工作后, 它会给父进程发一个信号, 父进程收到信号后就会将内存中缓存的写指令追加到新 AOF 文件中. 

4. 当追加结束后, redis 就会用新 AOF 文件来代替旧 AOF 文件, 之后再有新的写指令, 就都会追加到新的 AOF 文件中了. 

**重写机制**

因为采用了追加方式, 如果不做任何处理的话, AOF 文件会变得越来越大, 为此, redis 提供了 **AOF 文件重写(rewrite)机制**, 即当 AOF 文件的大小超过所设定的阈值时, redis 就会启动 AOF 文件的内容压缩, 只**保留可以恢复数据的最小指令集**. 举个例子或许更形象, 假如我们调用了 100 次INCR指令, 在 AOF 文件中就要存储 100 条指令, 但这明显是很低效的, 完全可以把这 100 条指令合并成一条 SET 指令, 这就是重写机制的原理. 

在进行 AOF 重写时, 仍然是采用先写临时文件, 全部完成后再替换的流程, 所以断电、磁盘满等问题都不会影响 AOF 文件的可用性.

在同样数据规模的情况下, AOF 文件要比 RDB 文件的体积大. 而且, AOF 方式的恢复速度也要慢于 RDB 方式. 

重写机制相关配置: 

自动重写 AOF 文件 : 取消redis命令执行中的冗余.
    
    # 当目前的AOF文件大小超过上一次重写时的AOF文件大小的百分之多少时会再次进行重写, 如果之前没有重写过, 则以启动时的AOF文件大小为依据
    auto-aof-rewrite-percentage 100  

    # 限制了允许重写的最小AOF文件大小, 通常在AOF文件很小的情况下即使其中有很多冗余的命令我们也并不太关心
    auto-aof-rewrite-min-size 64mb   

    重写的过程只和内存中的数据有关, 和之前的 AOF文件无关, 

手动执行AOF文件重写 :
    
    # redis 会生成一个全新的 AOF 文件, 其中便包括了可以恢复现有数据的最少的命令集. 
    > BGREWRITEAOF

同步磁盘缓存到硬盘频率 :
    
    # 每秒执行一次同步操作.
    appendfsync everysec   

    # 表示每次执行写入都会执行同步, 这是最安全也是最慢的方式.  
    appendfsync always     

    # 表示不主动进行同步操作, 而是完全交由操作系统来做(即每30秒一次), 这是最快但最不安全的方式. 
    appendfsync no          


#### 13.2.2. 配置

开启AOF : 默认 AOF 没有开启. 编辑 redis.conf

    appendonly yes

文件保存位置 :

    dir : 设置路径
    appendfilename appendonly.aof : 设置文件名称.


默认的 AOF 持久化策略是每秒钟 fsync 一次(fsync 是指把缓存中的写指令记录到磁盘中), 因为在这种情况下, redis 仍然可以保持很好的处理性能, 即使 redis 故障, 也只会丢失最近 1 秒钟的数据. 

如果在追加日志时, 恰好遇到磁盘空间满、inode 满或断电等情况导致日志写入不完整, 也没有关系, redis 提供了 redis-check-aof 工具, 可以用来进行日志修复. 


#### 13.2.3. 修复 AOF 文件.

如果运气比较差, AOF 文件出现了被写坏的情况, 也不必过分担忧, redis 并不会贸然加载这个有问题的 AOF 文件, 而是报错退出. 

可以通过以下步骤来修复出错的文件: 

- 备份被写坏的 AOF 文件;
- 运行 `redis-check-aof –fix` 进行修复;
- 用 `diff -u` 来看下两个文件的差异, 确认问题点;
- 重启 redis, 加载修复后的 AOF 文件.

### 13.3. AOF + RDB

Redis 允许同时开启 AOF 和 RDB, 既保证了数据安全又使得进行备份等操作十分容易. 此时重新启动Redis后Redis会使用**AOF**文件来恢复数据, 因为AOF方式的持久化可能丢失的数据更少. 

### 13.4. 备份与恢复

#### 13.4.1. 备份 :  

对于RDB和AOF, 都是**直接拷贝文件**即可, 可以设定crontab进行定时备份 .

#### 13.4.2. 恢复 : 
##### 13.4.2.1. RDB

将备份文件拷到 data 目录,并给 redis-server 访问权限, 并重启 redis-server

##### 13.4.2.2. AOF

重启时加载AOF文件恢复数据.  

##### 13.4.2.3. RDB + AOF

1. 只需要将aof文件放入data目录, 启动redis-server, 查看是否恢复, 

2. 如无法恢复则应该将**aof关闭**后重启, redis就会从rdb进行恢复了, 

3. 随后调用命令BGREWRITEAOF进行AOF文件写入, 在info的aof_rewrite_in_progress为0后一个新的aof文件就生成了, 

4. 此时再将配置文件的 aof 打开, 再次重启redis-server就可以恢复了. 

注意: 先不要将dump.rdb放入data目录, 否则会因为aof文件万一不可用, 则 rdb 也不会被恢复进内存, 此时如果有新的请求进来后则原先的 rdb 文件被重写.   

## 14. 集群
### 14.1. 复制

复制场景下数据库分为两中角色, 
- 主数据库(master),  可以进行**读写操作**, 当写操作导致数据变化时会自动将数据同步给从数据库. 
- 从数据库(slave), 一般是只读的, 并接受主数据库同步过来的数据. 

一个主数据库可以拥有多个从数据库, 而一个从数据库只能拥有一个主数据库, 


redis 是支持主从同步的, 而且也支持一主多从以及多级从结构. 主从结构, 一是为了纯粹的冗余备份, 二是为了提升读性能, 比如很消耗性能的 SORT 就可以由从服务器来承担. 在具体的实践中, 可能还需要考虑到具体的法律法规原因, 单纯的主从结构没有办法应对多机房跨国可能带来的数据存储问题, 这里需要特别注意一下

redis 的主从同步是异步进行的, 这意味着主从同步不会影响主逻辑, 也不会降低 redis 的处理性能. 主从架构中, 可以考虑关闭主服务器的数据持久化功能, 只让从服务器进行持久化, 这样可以提高主服务器的处理性能. 

在主从架构中, 从服务器通常被设置为只读模式, 这样可以避免从服务器的数据被误修改. 但是从服务器仍然可以接受 CONFIG 等指令, 所以还是不应该将从服务器直接暴露到不安全的网络环境中. 如果必须如此, 那可以考虑给重要指令进行重命名, 来避免命令被外人误执行. 


#### 14.1.1 配置 :

1. 配置文件配置方式 --> 推荐生产环境

    从数据库的配置文件中添加 :

        slaveof master_ip master_port

    主数据库无需配置 .

2. 命令行形式 : 

        $ redis-server --port 6380 --slaveof 127.0.0.1 6379

3. 在运行时设置 :

        redis> SLAVEOF 127.0.0.1 6379

4. SLAVEOF NO ONE :
    
        # 使当前数据库停止接收其他数据库的同步并转换成为主数据库. 
        redis> SLAVEOF NO ONE   

5. 查看主从状态

        redis SALV> INFO replication
            role:master
            connected_slaves:1
            slave0:ip=127.0.0.1,port=6380,state=online,offset=1,lag=1
            master_repl_offset:1

        redis MAST> INFO replication
            role:slave
            master_host:127.0.0.1
            master_port:6379

#### 14.1.2 原理及过程

- 复制初始化

    1. 当一个从数据库启动后, 会向主数据库发送 `SYNC` 命令.

    2. 同时主数据库接收到`SYNC`命令后会开始在后台保存**快照(即RDB持久化的过程)**, 并将保存快照期间接收到的命令缓存起来. 

        即使有多个从服务器同时发来 SYNC 指令, 主服务器也只会执行一次BGSAVE, 然后把持久化好的 RDB 文件发给多个下游.

    3. 当快照完成后, Redis会将快照文件和所有缓存的命令发送给从数据库. 

    4. 从数据库收到后, 会载入快照文件并执行收到的缓存的命令. 

- 复制同步阶段. 异步.

    主数据库每当收到写命令时就会将命令同步给从数据库, 从而保证主从数据库数据一致. 

    在同步的过程中从数据库并不会阻塞, 而是可以继续处理客户端发来的命令. 

    默认情况下, 从数据库会用**同步前的数据**对命令进行响应. 可以配置 `slave-serve-stale-data no` 来使从数据库在同步完成前对所有命令(除了INFO和SLAVEOF)都**回复错误："SYNC with master in progress. "**

- 断线重连 : 

    redis_version < 2.6

        重新进行 复制初始化(即主数据库重新保存快照并传送给从数据库), 即使从数据库可能仅有几条命令没有收到, 主数据库也必须要将数据库里的所有数据重新传送给从数据库. 

    redis_version > 2.8

        断线重连能够支持 有条件的增量数据传输 , 当从数据库重新连接上主数据库后, 主数据库只需要将断线期间执行的命令传送给从数据库, 从而大大提高Redis复制的实用性. 

#### 14.1.3 乐观复制策略

Redis采用了**乐观复制(optimistic replication)**的复制策略, 容忍在一定时间内主从数据库的内容是不同的, 但是两者的数据会**最终同步**. 

限制只有当数据至少同步给指定数量的从数据库时, 主数据库才是可写的：
    
    # 只有当3个或3个以上的从数据库连接到主数据库时, 主数据库才是可写的, 否则会返回错误.
    min-slaves-to-write 3       

    # 允许从数据库最长失去连接的时间, 如果从数据库最后与主数据库联系(即发送 REPLCONF ACK命令)的时间小于这个值, 则认为从数据库还在保持与主数据库的连接. 
    min-slaves-max-lag 10       

#### 14.1.4 图结构(级联结构)

**从数据库也可以有从数据库**.

#### 14.1.5 从数据库持久化 :

持久化是相对耗时的.

为了提高性能, 可以通过复制功能建立一个(或若干个)从数据库, 并在从数据库中启用持久化, 同时在主数据库禁用持久化. 

当主数据库崩溃时,恢复步骤 :
- 在从数据库中使用 SLAVEOF NO ONE 命令将从数据库提升成主数据库继续服务 ;
- 启动之前崩溃的主数据库, 然后使用SLAVEOF命令将其设置成新的主数据库的从数据库, 即可将数据同步回来 .

当开启复制且主数据库关闭持久化功能时, 一定**不要使用Supervisor 以及类似的进程管理工具**令主数据库崩溃后自动重启. 同样当主数据库所在的服务器因故关闭时, 也要避免直接重新启动. 这是因为当主数据库重新启动后, 因为没有开启持久化功能, 所以数据库中所有数据都被清空, 这时从数据库依然会从主数据库中接收数据, 使得所有从数据库也被清空, 导致从数据库的持久化失去意义. 

#### 14.1.6 无硬盘复制 : redis > 2.8.18 

Redis引入了无硬盘复制选项, 开启该选项时, Redis在与从数据库进行复制初始化时将**不会将快照内容存储到硬盘上**, 而是**直接通过网络发送给从数据库**, 避免了硬盘的性能瓶颈.

目前无硬盘复制的功能还在**试验阶段**, 可以在配置文件中使用如下配置来开启该功能：

    repl-diskless-sync yes

#### 14.1.7 增量复制

- 基础 :

    1. 从数据库会存储主数据库的运行ID(run id). 每个Redis 运行实例均会拥有一个唯一的运行ID, 每当实例重启后, 就会自动生成一个新的运行ID.

    2. 在复制同步阶段, 主数据库每将一个命令传送给从数据库时, 都会同时把该命令存放到一个积压队列(backlog)中, 并记录下当前积压队列中存放的命令的偏移量范围. 

    3. 同时, 从数据库接收到主数据库传来的命令时, 会记录下该命令的偏移量. 

- 过程 :

    当主从连接准备就绪后, 从数据库会发送一条 SYNC 命令来告诉主数据库可以开始把所有数据同步过来了. 而 2.8 版之后, 不再发送 SYNC命令, 取而代之的是发送 PSYNC, 格式为`PSYNC主数据库的运行ID 断开前最新的命令偏移量`. 主数据库收到 PSYNC命令后, 会执行以下判断来决定此次重连是否可以执行增量复制. 

    a. 首先主数据库会判断从数据库传送来的运行ID是否和自己的运行ID相同. 这一步骤的意义在于确保从数据库之前确实是和自己同步的, 以免从数据库拿到错误的数据(比如主数据库在断线期间重启过, 会造成数据的不一致). 

    b. 然后判断从数据库最后同步成功的命令偏移量是否在积压队列中, 如果在则可以执行增量复制, 并将积压队列中相应的命令发送给从数据库. 

    c. 如果此次重连不满足增量复制的条件, 主数据库会进行一次全部同步


    大部分情况下, 增量复制的过程对开发者来说是完全透明的, 开发者不需要关心增量复制的具体细节. 

    2.8 版本的主数据库也可以正常地和旧版本的从数据库同步(通过接收SYNC 命令), 同样 2.8 版本的从数据库也可以与旧版本的主数据库同步(通过发送 SYNC命令). 唯一需要开发者设置的就是积压队列的大小了. 

- 积压队列

    1 .`repl-backlog-size` : 积压队列的大小,积压队列越大,允许主从断线的时间越长.

        积压队列在本质上是一个固定长度的循环队列, **默认情况下积压队列的大小为 1 MB**, 可以通过配置文件的repl-backlog-size选项来调整. 很容易理解的是, 积压队列越大, 其允许的主从数据库断线的时间就越长. 

        根据主从数据库之间的网络状态, 设置一个合理的积压队列很重要. 因为**积压队列存储的内容是命令本身**, 如 `SET foo bar`, 所以估算积压队列的大小只需要**估计主从数据库断线的时间中主数据库可能执行的命令的大小即可**. 

    2. `repl-backlog-ttl` : 当主从连接断开之后,经过多久可以释放积压队列的内存空间,**默认1h**.
        
        与积压队列相关的另一个配置选项是repl-backlog-ttl, 即当所有从数据库与主数据库断开连接后, 经过多久时间可以释放积压队列的内存空间. 默认时间是1小时. 

### 14.2. 哨兵 : 

#### 14.2.0. 作用

1. 监控主数据库和从数据库是否正常运行
2. 主数据库出现故障时,自动主从切换. 
3. 需要客户端也能实现自动的主从切换, 或者在 redis 集群前端配置负载均衡或者自动切换.

#### 14.2.1. 配置过程
一个哨兵可以监控多个集群, 一个集群也可以配置多个哨兵进行监控.

配置哨兵监控一个系统时,只需要配置其**监控主数据库**即可,哨兵会自动发现所有复制该主数据库的从数据库. 

`quorum` : 表示最低通过票数. 执行故障恢复(切换)前,至少需要几个哨兵点同意.

    # 基本配置
    $  vim /etc/redis/sentinel.conf
        # sentinel monitor master_name ip redis-port quorum
        + sentinel monitor mymaster 127.0.0.1 6379 1

        # mymaster : 表示要监控的主数据库的名字
        # 127.0.0.1 6379 : 表示主数据库的地址和端口号, 
        

    # 启动
    $ redis-server /etc/redis/sentinel.conf --sentinel

        14641:X 28 Sep 14:59:14.771 # Sentinel runid is 22c9d5b569313d6140806a12ccdc9792df3299c7
        14641:X 28 Sep 14:59:14.771 # +monitor master mymaster 127.0.0.1 6379 quorum 1
        14641:X 28 Sep 14:59:14.772 * +slave slave 127.0.0.1:6380 127.0.0.1 6380 @ mymaster 127.0.0.1 6379
        14641:X 28 Sep 14:59:14.774 * +slave slave 127.0.0.1:6381 127.0.0.1 6381 @ mymaster 127.0.0.1 6379

#### 14.2.2. 其他配置

0. 一个哨兵节点可以同时监控多个Redis主从系统, 只需要提供多个sentinel monitor配置即可. 同时,多个哨兵节点也可以同时监控同一个 Redis 主从系统, 从而形成网状结构.      
    
        # 一个哨兵监控多个集群
        sentinel monitor mymaster 127.0.0.1 6379 2
        sentinel monitor othermaster 192.168.1.3 6380 4

2. 配置文件中还可以定义其他监控相关的参数, 每个配置选项都包含主数据库的名字使得**监控不同主数据库时可以使用不同的配置参数**. 例如

        sentinel down-after-milliseconds mymaster 60000
        sentinel down-after-milliseconds othermaster 10000

3. 其他配置.

        sentinel failover-timeout mymaster 180000
        sentinel parallel-syncs mymaster 1

### 14.3. 集群

### 14.4. [分区](http://www.runoob.com/redis/redis-partitioning.html)

分区是分割数据到多个 Redis 实例的处理过程, 因此每个实例只保存 key 的一个子集. 分区主要用于扩充容量, 而不是提高redis 的可用性.

- 通过利用多台计算机内存的和值, 允许我们构造更大的数据库
- 通过多核和多台计算机, 允许我们扩展计算能力
- 通过多台计算机和网络适配器, 允许我们扩展网络带宽

分区实际上把数据进行了隔离, 如果原本应该在同一分区的数据被放在了不同分区, 或者原本没有太多关系的数据因为新的业务产生了关系, 就会遇到一些问题：

- 涉及多个 key 的操作通常是不被支持的. 举例来说, 当两个 set 映射到不同的 redis 实例上时, 你就不能对这两个 set 执行交集操作
- 涉及多个 key 的 redis 事务不能使用
- 当使用分区时, 数据处理较为复杂, 比如你需要处理多个 rdb/aof 文件, 并且从多个实例和主机备份持久化文件
- 增加或删除容量也比较复杂. redis 集群大多数支持在运行时增加, 删除节点的透明数据平衡的能力, 但是类似于客户端分区、代理等其他系统则不支持这项特性. 然而, 一种叫做 **presharding** 的技术对此是有帮助的. 

Redis 有两种类型分区.  假设有 4 个 Redis实例 R0, R1, R2, R3, 和类似 user:1, user:2 这样的表示用户的多个 key, 对既定的 key 有多种不同方式来选择这个 key 存放在哪个实例中. 也就是说, 有不同的系统来映射某个 key 到某个 Redis 服务. 

1. 范围分区

    最简单的分区方式是按范围分区, 就是映射一定范围的对象到特定的 Redis 实例. 

    比如, ID 从 0 到 10000 的用户会保存到实例 R0, ID 从 10001 到 20000 的用户会保存到 R1, 以此类推. 这种方式的不足之处是要有一个区间范围到实例的映射表, 同时还需要各种对象的映射表, 通常对 Redis 来说并非是好的方法. 

2. 哈希分区

    另外一种分区方法是 hash 分区. 这对任何 key 都适用, 也无需是 object_name: 这种形式, 只需要确定统一的哈希函数, 然后通过取模确定应该保存在哪个分区即可. 

## 15. 管理
### 15.1. 安全

Redis 安全问题 : redis 是一个弱安全的组件,只有一个简单的明文密码.

1. 使用redis单独用户和组进行安全部署, 并且在OS层面禁止此用户ssh登陆, 这就从根本上防止了root用户启停redis带来的风险. 

2. 修改默认端口, 降低网络简单扫描危害. 

3. 修改绑定地址, 如果是本地访问要求绑定本地回环. 

4. 要求设置密码, 并对配置文件访问权限进行控制, 因为密码在其中是明文. 

    设置密码:

        $ config set requirepass [PASSWD]

    认证密码 :

        redis-cli > auth PASSWD

5. HA环境下主从均要求设置密码.  

6. 建议在网络防火墙层面进行保护, 杜绝任何部署在外网直接可以访问的redis的出现. 

7. **危险命令重命名**.
    
    redis 的危险命令有:
    
    - flushdb
    - flushall
    - config
    - keys

    在服务端, 通常需要禁用以上命令来使服务器更加安全. 具体做法为, 修改服务器的配置文件 `redis.conf`, 在 `SECURITY` 这一区块中, 添加如下命令:

        $ vim redis.conf        # 以下方式, 二选一.

            # 保留这些命令, 但是修改为复杂的, 不易猜测的其他字符, 以便需要的时候使用.
            rename-command FLUSHALL joYAPNXRPmcarcR4ZDgC81TbdkSmLAzRPmcarcR  
            rename-command FLUSHDB  qf69aZbLAX3cf3ednHM3SOlbpH71yEXLAX3cf3e  
            rename-command CONFIG   FRaqbC8wSA1XvpFVjCRGryWtIIZS2TRvpFVjCRG  
            rename-command KEYS     eIiGXix4A2DreBBsQwY6YHkidcDjoYA2DreBBsQ 

            # 完全禁用这些命令.
            rename-command FLUSHALL ""  
            rename-command FLUSHDB  ""  
            rename-command CONFIG   ""  
            rename-command KEYS     "" 

### 15.2. 通信协议

### 15.3. 管理工具

## 16. 监控

### 16.1 redis-cli info

1. 内存使用 `info memory`
  
    ** 如果 Redis 使用的内存超出了可用的物理内存大小, 那么 Redis 很可能系统会被 OOM Killer 杀掉. 为使用内存量设定阈值, 并设定相应的报警机制. 

        used_memory
        used_memory_peak

2. 持久化 `info Persistence`

        rdb_last_save_time : 进行监控, 了解你最近一次 dump 数据操作的时间, 
        rdb_changes_since_last_save : 进行监控来知道如果这时候出现故障, 你会丢失多少数据. 

3. 主从复制 `info replication`

        master_link_status : 进行监控, 如果这个值是 up, 那么说明同步正常, 如果是 down, 

4. fork 性能 `info stats`

    当 Redis 持久化数据到磁盘上时, 它会进行一次 fork 操作, 通过 fork 对内存的 copy on write 机制最廉价的实现内存镜像. 但是虽然内存是 copy on write 的, 但是虚拟内存表是在 fork 的瞬间就需要分配, 所以 fork 会造成主线程短时间的卡顿(停止所有读写操作), 这个卡顿时间和当前 Redis 的内存使用量有关. 通常 GB 量级的 Redis 进行 fork 操作的时间在毫秒级.

        latest_fork_usec : 监控最近一次fork操作使用时间.

### 16.2 慢日志

Redis 的慢查询日志功能用于记录执行时间超过给定时长的命令请求,  用户可以通过这个功能产生的日志来监视和优化查询速度. 

Redis 提供了 `SLOWLOG` 指令来获取最近的慢日志, Redis 的慢日志是直接存在内存中的, 所以它的慢日志开销并不大, 在实际应用中, 我们通过 crontab 任务执行 SLOWLOG 命令来获取慢日志, 然后将慢日志存到文件中, 并用 Kibana 生成实时的性能图表来实现性能监控. 

Redis 的慢日志记录的时间, 仅仅包括 Redis 自身对一条命令的执行时间, 不包括 IO 的时间, 比如接收客户端数据和发送客户端数据这些时间. 

Redis 的慢日志和其它数据库的慢日志有一点不同, 其它数据库偶尔出现 100ms 的慢日志可能都比较正常, 因为一般数据库都是多线程并发执行, 某个线程执行某个命令的性能可能并不能代表整体性能, 但是对 Redis 来说, 它是单线程的, 一旦出现慢日志, 可能就需要马上得到重视, 最好去查一下具体是什么原因了. 

0. 配置 
    
        # 选项指定执行时间超过多少微秒(1 秒等于 1,000,000 微秒)的命令请求会被记录到日志上. 设置的单位是微妙, 默认是10000微妙, 也就是10ms 
        slowlog-log-slower-than

        # 选项指定服务器最多保存多少条慢查询日志. 服务器使用先进先出的方式保存多条慢查询日志： 当服务器储存的慢查询日志数量等于 slowlog-max-len 选项的值时,  服务器在添加一条新的慢查询日志之前,  会先将最旧的一条慢查询日志删除. 
        slowlog-max-len

1. slowlog 格式详解

        > SLOWLOG GET 10

        1) 1) (integer) 4               # 日志的唯一标识符(uid)
           2) (integer) 1378781447      # 命令执行时的 UNIX 时间戳
           3) (integer) 13              # 命令执行的时长, 以微秒计算
           4) 1) "SET"                  # 命令以及命令参数
              2) "database"
              3) "Redis"
          
    - 结果为查询ID、发生时间、运行时长 和 原命令,
    - 默认10毫秒, 默认只保留最后的128条. 单线程的模型下, 一个请求占掉10毫秒是件大事情, 
    - 注意设置和显示的单位为 **微秒**, 
    - 注意这个时间是**不包含网络延迟**的. 

2. 获取慢查询日志

        > slowlog get 
        > slowlog get 10    # 获取前10条
        > slowlog get -10   # 获取后10条

3. 获取慢查询日志条数

        > slowlog len

4. 清空慢查询

        > slowlog reset 


### 16.3 监控服务
1. sentinel : 哨兵
    
    是 Redis 自带的工具, 它可以对 Redis 主从复制进行监控, 并实现主挂掉之后的自动故障转移. 在转移的过程中, 它还可以被配置去执行一个用户自定义的脚本, 在脚本中我们就能够实现报警通知等功能. 

2. Redis Live
    
    Redis Live 是一个更通用的 Redis 监控方案, 它的原理是定时在 Redis 上执行 MONITOR 命令, 来获取当前 Redis 当前正在执行的命令, 并通过统计分析, 生成web页面的可视化分析报表

3. Redis Faina

    其原理和 Redis Live 类似, 都是对通过 MONITOR 来做的. 

### 16.4 数据分布 : redis 数据集分析

1. Redis-sampler

    Redis-sampler 是 Redis 作者开发的工具, 它通过采样的方法, 能够让你了解到当前 Redis 中的数据的大致类型, 数据及分布状况. 

2. redis-audit

    Redis-audit 是一个脚本, 通过它, 我们可以知道每一类 key 对内存的使用量. 它可以提供的数据有：某一类 key 值的访问频率如何, 有多少值设置了过期时间, 某一类 key 值使用内存的大小, 这很方便让我们能排查哪些 key 不常用或者压根不用. 

3. redis-rdb-tools

    跟 Redis-audit 功能类似, 不同的是它是通过对 rdb 文件进行分析来取得统计数据的. 
    
## 17. 其他管理类
遍历数据库中的键 :      

    > keys *            # 生产环境已禁止,当数据库很大时,会阻塞数据库.

    > SCAN cursor [MATCH pattern] [COUNT count]     # 以渐进的方式,分多次遍历啊整个数据库,并返回匹配给定模式的键.

    > SSCAN key cursor [MATCH pattern] [COUNT count]
    # 代替可能会阻塞服务器的 SMEMBERS 命令,遍历集合包含的各个元素.

    > HSCAN key cursor [MATCH pattern] [COUNT count]
    # 代替肯能会阻塞服务器的 HGETALL 命令,遍历散列包含的各个键值对.

    > ZSCAN key cursor [MATCH pattern] [COUNT count]
    # 代替可能会则色服务器的 ZRANGE 命令,遍历有序集合包含的各个元素.

redis-cli 扫描

    $ redis-cli --scan --pattern 'PATTERN'

管理类

    > exists key
    > del key1
    > type key1
    > randomkey     # 随机返回一个 key 
    > rename OLDKEY NEWKEY
    > renamenx OLDKEY NEWKEY

    # 超时时间
    > expire key second
    > persist key       # 消除设置的超时时间
    > expireat  # 采用绝对超时.
    > ttl key   # 返回key 的剩余过期时间.

    > pexpire key ms    # 毫秒为时间单位
    > pttl key          # 以毫秒返回生命周期.

    > setnx key value   # 仅当 key 不存在时,才set ,存在返回 0 ; nx , not exist .
    # 用来选举 master 或 做分布式锁, 所有 client 不断尝试使用 setnx key value 抢注 master, 成功的那位不断使用 expire 刷新他的过期时间.

    > set key value nx|xx
    # nx : 仅在不存在 key 时 ,进行设置操作.
    # xx : 尽在存在 key 时, 进行设置操作.

    > setget key value 
    # 原子的设置key的值,并返回 key 的旧值. 配合 setnx 可以实现分布式锁.


开发设计规范 :

    key 设计
        object-type:id:field.conn   # 用 ":" 分割域, 用 "." 做单词间的链接.
        ① 把表名转换为 key 前缀,
        ② 第二段放置用于区分 key 的字段,
        ③ 第三段放置主键
        ④ 第四段写要存储的列名.

性能测试:

    $ redis-benchmark -q -r 100000 -n 100000 -c 50

    $ redis-benchmark -t SET -c 100 -n 10000000 -r 10000000 -d 256
    # 开100条线程(默认50), SET 1千万次(key在0-1千万间随机), key长21字节, value长256字节的数据. -r指的是使用随机key的范围. 

数据库 :

    > select db_index  # 选择数据库

    > flushdb       # 删除当前数据库中的所有 key,

    > flushall      # 删除所有的数据库.

执行 lua 脚本

    $ redis-cli --eval name.lua PARAMETER

数据迁移 :

    1. 将 key 从当前数据库移动到指定数据库 
        > move key db_index

探测服务延迟 :

    $ redis-cli --latency   # 显示的单位是milliseconds, 作为参考, 千兆网一跳一般延迟为0.16ms左右

查看统计信息 :
    
    redis:6379> info
    在cli下执行info. 

    redis:6379> info Replication
    只看其中一部分. 

    redis:6379> config resetstat
    重新统计    

查看客户端 :

    > client list 
    # 列出所有连接

    > client kill 127.0.0.1:43501
    # 杀死某个连接

查看日志 : 默认位于 redis/log 下

    redis.log     # redis 主日志
    sentinel.log  # sentinel 监控日志.

多实例配置 : taskset

    $ taskset -p REDIS_PID
    # 显示进行运行的 cpu, 结果 为 f

    $ taskset -p REDIS_PID -c 3
    # 指定进程运行在某个特定 cpu 上, REDIS_PID 只会运行在 第4个 CPU 上.

    $ taskset -c 1 ./redis-server ./redis-6379.conf  
    # 进程启动时,指定 cpu.

配置文件参数设置技巧 :
    
    Include 如果是多实例的话可以将公共的设置放在一个conf文件中, 然后引用即可： 

    include /redis/conf/redis-common.conf

并发延迟检查 

    1. 检查 cpu 情况
        $ mpstat -P ALL 1

    2. 检查网络情况 : 可以在系统不繁忙或者临时下线前检测客户端和server或者proxy 的带宽：
        1) 在 10.230.48.65 上使用 iperf -s 命令将 Iperf 启动为 server 模式:
            $ iperf –s

        2) 启动客户端, 向IP为10.230.48.65的主机发出TCP测试, 并每2秒返回一次测试结果, 以Mbytes/sec为单位显示测试结果：
            $ iperf -c 10.230.48.65 -f M -i 2

    3. 检查系统情况 :
        探测服务延迟
        监控正在请求执行的命令
        获取慢查询

    4. 检查连接数
        $ redis-cli info Stats | grep total_connections_received
        # 如果该值不断升高, 则需要升级应用,改用连接池方式进行,因为频繁的关闭和创建连接,对redis 开销很大.

    5. 检查持久化
        
        RDB的时间： latest_fork_usec:936  上次导出rdb快照,持久化花费, 微秒.  检查是否有人使用了SAVE. 

    6. 检查命令执行情况 
        > INFO commandstats

        查看命令执行了多少次, 执行命令所耗费的毫秒数(每个命令的总时间和平均时间)

内存检查 

    1. 系统内存查看

    2. 系统swap内存查看
    
    3. info 查看内存
        >  info memory
        used_memory:859192              # 数据结构的空间  
        used_memory_rss:7634944         # 实占空间  
        mem_fragmentation_ratio:8.89    # 前2者的比例, 1.N为佳,如果此值过大,说明redis的内存的碎片化严重,可以导出再导入一次.

    4. dump.rdb 文件生成内存报告(rdb-tools)
        $ rdb -c memory ./dump.rdb > redis_memory_report.csv
        $ sort -t, -k4nr redis_memory_report.csv
    
    5. query 在线分析: redis-faina , redis 版本 > 2.4
        $ cd /opt/test
        $ git clone https://github.com/Instagram/redis-faina.git
        $ cd redis-faina/
        $ redis-cli -p 6379 MONITOR | head -n 100 | ./redis-faina.py --redis-version=2.4


        $ redis-cli MONITOR | head -n 5000 | ./redis-faina.py

    6. 内存抽样分析
        $ /redis/script/redis-sampler.rb 127.0.0.1 6379 0 10000
        $ /redis/script/redis-audit.rb  127.0.0.1 6379 0 10000
    
    7. 统计生产上比较大的 key

        $ redis-cli --bigkeys 
        # 对redis中的key进行采样, 寻找较大的keys. 是用的是scan方式, 不用担心会阻塞redis很长时间不能处理其他的请求. 执行的结果可以用于分析redis的内存的只用状态, 每种类型key的平均大小. 

    8. rss 增加,内存碎片增加

        可以选择时间进行redis服务器的重新启动, 并且注意在rss突然降低观察是否swap被使用, 以确定并非是因为swap而导致的rss降低. 

测试方法 :

    1. 模拟 oom
        $ redis-cli debug oom

        # redis 直接退出

    2. 模拟宕机
        $ redis-cli debug segfault
    
    3. 模拟 hang
        $ redis-cli debug sleep 30
    
    4. 快速产生测试数据
        > debug populate 1000 
        > dbsize

    5. 模拟 RDB load 情形
        > debug reload
        # save当前的rdb文件, 并清空当前数据库, 重新加载rdb, 加载与启动时加载类似, 加载过程中只能服务部分只读请求(比如info、ping等)： rdbSave(); emptyDb(); rdbLoad();

    6. 模拟 AOF 加载情形
        > debug loadaof
        # 清空当前数据库,重新从aof文件里加载数据库 emptyDb(); loadAppendOnlyFile();