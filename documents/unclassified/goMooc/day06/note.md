## 并发内置数据结构
- sync.Once
- sync.Pool
- semaphore: 锁结构的基础.
- sync.Mutex: 互斥锁
- sync.RWMutex
- sync.Map
- sync.Waitgroup

## 并发变成模式举例
### CSP 和 传统并发模式

### Fan-in(扇入)  合并多个 channel 操作

### Or channel, 任意 channel 返回, 全部返回
### pipeline, 串在一起的 channel
### 并发同时保序


## 常见并发 bug


## 内存模型

显式同步即可保证正确性.


## 参考
- https://shimo.im/docs/JwCr8CwCRdRQJ8G8
- pprof