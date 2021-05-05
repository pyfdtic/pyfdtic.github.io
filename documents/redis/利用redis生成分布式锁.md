---
title: 利用redis生成分布式锁
date: 2018-03-15 18:27:36
categories:
- Middleware
tags:
- redis
- 分布式锁
---

使用 redis 命令 set(self, name, value, ex=None, px=None, nx=False, xx=False) 生成分布式锁.
使用 `setnx(key, value) + expire(key, sec)`  生成分布式锁.
<!-- more -->
**指令与原理**: 

`set(self, name, value, ex=None, px=None, nx=False, xx=False)`  --> **推荐**, 更加原子性
- ex : 设置过期时间, 单位 秒
- px : 设置过期时间, 单位 毫秒
- nx : nx=True, 当 name 不存在时, 设置其值为 value.
- xx : xx=True, 当 name 存在时, 设置其值为 value.


`setnx(key, value) + expire(key, sec)` 

- 当 key 存在时, 忽略 set key 值, 并返回 False; 
- 当 key 不存在时, set key 值, 并返回 True



**示例代码**:

    import redis
    
    def redis_conn(host="127.0.0.1", port=6379, db=0):
        return redis.StrictRedis(host=host, port=port, db=db)

    myredis = redis_conn()


    # 设置锁, 并获取锁.
    def redis_lock(key, value):
        
        k = str(key).lower().strip()
        while True:
            if dredis.set(k, value, ex=3600, nx=True):
                break
            else:
                time.sleep(5)

    # 释放锁
    def redis_unlock(key):
        uuid_key = str(key).lower().strip()
        pipe = dredis.pipeline()
        pipe.get(uuid_key)
        pipe.delete(uuid_key)
        res = pipe.execute()
        return res[0]