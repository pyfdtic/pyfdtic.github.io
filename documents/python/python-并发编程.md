---
title: python-并发编程
date: 2018-06-16 17:31:58
categories:
- Python
tags:
---
[参考地址](http://mp.weixin.qq.com/s?__biz=MzA3NDk1NjI0OQ==&mid=2247483845&idx=1&sn=4a72462403a9f5dd58dd8ca3833786ee&chksm=9f76ad73a801246593ad2c8b6c4f0805b034f2436450d8337b4fbb71a836fc9d2e941598e162&scene=21#wechat_redirect)

[参考地址](http://mp.weixin.qq.com/s?__biz=MzA3NDk1NjI0OQ==&mid=2247483847&idx=1&sn=fc5428db537f5abe9bb71dc54eb64a1e&chksm=9f76ad71a8012467ff7fee2c1c945b2c8fa2e5eb147e51a5565c4d9bc79187b9d1dad762043a&scene=21#wechat_redirect)

[参考地址](http://mp.weixin.qq.com/s?__biz=MzA3NDk1NjI0OQ==&mid=2247483864&idx=1&sn=9ce1061040a4ada28c1518b76e74ad54&chksm=9f76ad6ea8012478349e0a6b6b05080cbdd811943f859edc29c721d97221e502a5c7fed604d6&scene=21#wechat_redirect)

Python 2 时代, 高性能的网络编程主要是使用 Twisted, Tornado, Gevent 这三个库. 但是他们的异步代码相互之间不兼容也不能移植. 

python 3.4 引入 `asyncio` 到标准库.

Python 3.5 
- 添加了 `async` 和 `await` 两个关键字 , 替换 `asyncio.coroutine` 和 `yield from`. 
	协程成为新的语法, 而不再是一种生成器类型了. 事件循环与协程的引入, 可以极大提高高负载下程序的 IO 性能. 
- `async with(异步山下文管理)` 
- `asyncfor(异步迭代器)`

*在新发布的 Python 3.6 里面终于可以使用 异步生成器了*

`sanic/aiohttp`

## asyncio 
**asyncio 使用单线程, 单个进程的方式进行切换** 通常程序等待读或者写数据时, 就是切换上下文的时机.


## 同步机制

### Semaphore (信号量)
### Lock (锁)
### Condition (条件)
### Event (事件)
### Queue (队列)
  - LifoQueue
  - PriorityQueue

### Task
### 事件循环