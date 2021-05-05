---
title: PyStdLib--multiprocessing
date: 2018-03-19 18:35:16
categories:
- Python
tags:
- python 标准库
---
**multiprocessing 与 threading.Thread 类似** 

## multiprocessing.Process  创建进程, 该进程可以运行用 python 编写的函数.
```
    multiprocessing.Process.start()
    multiprocessing.Process.run()
    multiprocessing.Process.join() 

    Process.PID 保存有 PID, 如果进程还没有 start() , 则 PID 为 None.
```

**注意**

- 在 UNIX 平台上, 当某一个进程终止之后, 该进程需要被其父进程调用 wait , 否则进程就成为 僵尸进程. 所以, 需要对每个 Process 对象调用 join() 方法(等同于 wait), 对于多线程来说, 由于只有一个进程, 所以不存在次必要性.

- multiprocessing 提供了 threading 中没有的 IPC (比如 Queue,Pipe), 效率上更高. 应有限考虑 Pipe 和 Queue, 避免使用 Lock/Event/Semaphore/Condition 等同步方式(应为他们占据的不是用户进程的资源).

- 多进程应该避免共享资源. 在多线程中, 我们可以比较容易的共享资源, 比如使用全局变量或传递参数. 在多进程情况下, 由于每个进程有自己独立的内存空间, 以上方法并不合适. 此时我们可以通过共享内存和 Manager 的方法来共享资源. 但这样做提高了程序的复杂度, 并因为同步的需要而降低了程序的效率.

### 示例代码
```
#!/usr/local/bin/env python
#

import os
import threading
import multiprocessing

def worker(sign,lock):
    lock.acquire()
    print(sign,os.getpid())
    lock.release()

print("main:",os.getpid())

# multi-thread
record=[]

lock = threading.Lock()
for i in range(5):
    thread = threading.Thread(target=worker,args=('thread',lock))
    thread.start()
    record.append(thread)

for thread in record:
    thread.join()

# multi-process
record = []
lock = multiprocessing.Lock()

for i in range(5):
    process = multiprocessing.Process(target=worker,args=('process',lock))
    process.start()
    record.append(process)

for process in record:
    process.join()

输出 : 所有 Thread 的 PID 都与主程序相同, 而每个 Process都有一个不同的 PID.

    ('main:', 105748)
    ('thread', 105748)
    ('thread', 105748)
    ('thread', 105748)
    ('thread', 105748)
    ('thread', 105748)
    ('process', 105754)
    ('process', 105756)
    ('process', 105758)
    ('process', 105755)
    ('process', 105757)    
```
## multiprocessing.Lock
## multiprocessing.Event
## multiprocessing.Semaphore
## multiprocessing.Condition 

## multiprocessing.Pipe() 
```
    multiprocessing.Pipe()  # 默认创建双向管道, 该对象返回一个包含两个元素的表, 每个元素代表 Pipe 的一端(Connection对象). 可以在一端调用 send() 方法, 另一端调用 recv() 方法, 实现通信.
    multiprocessing.Pipe(duplex=False)    # 创建单向管道
    multiprocessing.Pipe().send()
    multiprocessing.Pipe().recv()
```
### 示例代码:
```
    #!/usr/local/bin/env python
    #

    import multiprocessing as mul

    def proc1(pipe):
        pipe.send('hello')
        print('proc1 rec:',pipe.recv())

    def proc2(pipe):
        print('proc2 rec:',pipe.recv())
        pipe.send('hello, too')

    # Build a pipe
    pipe = mul.Pipe()

    # Pass an end of the pipe to process 1
    p1   = mul.Process(target=proc1, args=(pipe[0],))
    # Pass the other end of the pipe to process 2
    p2   = mul.Process(target=proc2, args=(pipe[1],))
    p1.start()
    p2.start()
    p1.join()
    p2.join()    
    
    输出:
        ('proc2 rec:', 'hello')
        ('proc1 rec:', 'hello ,too!')
```
## multiprocessing.Queue 是先进先出的结构. Queue 允许多个进程放入, 多个进程从队列取出对象. 
```
    mutiprocessing.Queue(maxsize)   创建队列, maxsize 表示队列中可以存放对象的最大数量.
    
    mutiprocessing.Queue(maxsize).put()
    mutiprocessing.Queue(maxsize).get()
```
### 示例代码
```
    #!/usr/local/bin/env python
    #


    import os
    import multiprocessing
    import time

    # input worker
    def inputQ(queue):
        info = str(os.getpid()) + '(put):' + str(time.time())
        queue.put(info)

    # output worker
    def outputQ(queue,lock):
        info = queue.get()
        lock.acquire()
        print (str(os.getpid()) + '(get):' + info)
        lock.release()

    # Main
    record1 = []   # store input processes
    record2 = []   # store output processes
    lock  = multiprocessing.Lock()    # To prevent messy print
    queue = multiprocessing.Queue(3)

    # input processes
    for i in range(10):
        process = multiprocessing.Process(target=inputQ,args=(queue,))
        process.start()
        record1.append(process)

    # output processes
    for i in range(10):
        process = multiprocessing.Process(target=outputQ,args=(queue,lock))
        process.start()
        record2.append(process)

    for p in record1:
        p.join()

    queue.close()  # No more object will come, close the queue

    for p in record2:
        p.join()
    
    输出:
        105880(get):105865(put):1488439837.07
        105883(get):105866(put):1488439837.07
        105879(get):105867(put):1488439837.08
        105884(get):105870(put):1488439837.08
        105877(get):105873(put):1488439837.08
        105885(get):105871(put):1488439837.08
        105886(get):105874(put):1488439837.09
        105878(get):105872(put):1488439837.08
        105881(get):105868(put):1488439837.08
        105887(get):105876(put):1488439837.09
```
## multiprocessing.Pool(num)   # num 表示创建的进程数.
```
    multiprocessing.Pool(num)       # 创建进程池, 
    multiprocessing.Pool(num).map()     # 与 map() 函数类似.
    multiprocessing.Pool(num).apply_async(func,args)   # 从进程池中取出一个进程执行 func, args 为 func 的参数. 他将返回一个 AsyncResult 的对象, 可以对该对象调用 get() 方法, 获取结果.
    multiprocessing.Pool(num).apply_async(func,args).get()
    multiprocessing.Pool(num).close()   # 进程池不再创建新的进程
    multiprocessing.Pool(num).join()    # wait 进程池的全部进程, 必须对 Pool 先调用 close() 方法, 才能 join.
```
### 示例代码:
```
        import multiprocessing as mul
        
        def f(x):
            return x**2
        
        pool = mul.Pool(5)
        rel  = pool.map(f,[1,2,3,4,5,6,7,8,9,10])
        print(rel)
        
        输出:
            [1, 4, 9, 16, 25, 36, 49, 64, 81, 100]
```
## 共享内存
```
    multiprocessing.Value(key,value)    # 双精度数数字
    multiprocessing.Array(key,value_list)   # 数组
```
### 代码示例
```
    import multiprocessing
    
    def f(n, a):
        n.value   = 3.14
        a[0]      = 5
    
    num   = multiprocessing.Value('d', 0.0)
    arr   = multiprocessing.Array('i', range(10))
    
    p = multiprocessing.Process(target=f, args=(num, arr))
    p.start()
    p.join()
    
    print num.value
    print arr[:]

    输出:
        3.14
        [5, 1, 2, 3, 4, 5, 6, 7, 8, 9]
```
## Manager
```
    s = multiprocessing.Manager()

    s.address          s.dict             s.list             s.register        s.Value            
    s.Array            s.Event            s.Lock             s.RLock                               
    s.BoundedSemaphore s.get_server       s.Namespace        s.Semaphore                           
    s.Condition        s.join             s.Pool             s.shutdown                            
    s.connect          s.JoinableQueue    s.Queue            s.start
```
### 代码示例
```
    import multiprocessing
    
    def f(x, arr, l):
        x.value = 3.14
        arr[0] = 5
        l.append('Hello')
    
    server = multiprocessing.Manager()
    x    = server.Value('d', 0.0)
    arr  = server.Array('i', range(10))
    l    = server.list()
    
    proc = multiprocessing.Process(target=f, args=(x, arr, l))
    proc.start()
    proc.join()
    
    print(x.value)
    print(arr)
    print(l)
    
    输出结果:
        3.14
        array('i', [5, 1, 2, 3, 4, 5, 6, 7, 8, 9])
        ['Hello']
```