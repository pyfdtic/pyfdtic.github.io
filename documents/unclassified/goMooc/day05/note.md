
## 垃圾回收
书:
- 垃圾回收的算法与实现: 图比较多. 只看算法部分即可
- 垃圾回收算法手册: 理论全. 只看章节: 标记清扫, 并发标记, 三色抽象.

内存从哪里来? 到哪里去?

标记对象从哪里来? 到哪里去?

垃圾从哪里来? 到哪里去?


栈分配: 成本小. 轻量.
堆分配: 重.

逃逸分析: 吧局部变量分配到堆.
    ```
    go build -gcflags="-m -m -m" escape.go
    ...
    make([]int, 10240) escapes to heap
    ```

逃逸分析探究:
```
# 编译器代码
cmd/compile/internal/gc/escape.go

# 主库测试代码.
golang/go/tree/master/test/escape*.go
```

自动内存回收技术 = 垃圾回收技术

内存分配:
- 自动 allocator
- 手工分配 : go 没有

内存回收:
- 自动 collector
- 手工回收: 

内存管理重的三个角色:
- Mutator: 开发的应用
- Allocator: 分配内存
    - malloc
    - tcmalloc: 多进程.
- collector: 回收
    - marker
    - sleeper

### 进程虚拟内存布局

### Allocator 基础
分类:
- bump/sequential allocator 线性分配: 不会重用空的内存块
- free list allocator 空闲链分配: 有限使用空闲内存空.

Free list allocator 算法:
- First-Fit: 
- Next-Fit: 环形
- Best-Fit: 
- Segregated-Fit: 分级. 业界最常用. Go 即使用这个.

### malloc 实现
Go 的栈内存管理.

malloc: mallopt
- brk: 
- mmap:

悬垂指针: dangling pointer

### GO 内存分配
#### 内存分配
老版本: 连续堆 --> 与 CGO 配和时, 会有冲突.

新版本: 稀疏堆 --> 
    申请 稀疏堆 时, 使用 mmap 调用, 而不是 brk.

分配:
- Tiny: 
- Small: 
- Large:

spanClass 分配: 


内存分配器 维护多级结构:
- mcache: 不加锁
- mcentral: 有锁
- mheap: 全局锁.
  - arena:

Refill:

Bitmap & allocCache

### 垃圾回收基础

垃圾分类:
- 语义垃圾, 内存泄漏. --> 垃圾回收器对此无能为力.

- 语法垃圾, 主要收集目标.


常用垃圾回收算法:
- 引用计数
- 标记压缩
- 标记清扫: --> go 使用(+分级内存分配).

### Go 语言垃圾回收
 


### GC 标记流程


## 参考
