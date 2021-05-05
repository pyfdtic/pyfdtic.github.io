---
title: PyStdLib--threading
date: 2018-03-19 18:28:47
categories:
- Python
tags:
- python 标准库
---
### threading : 提高对网络端口的读写效率. 
```
    threading.Thread.start()   执行线程操作
    threading.Thread.run()     执行线程操作
    threading.Thread.join()     调用该方法的线程将等待, 直到该 Thread 对象完成, 再回复运行. 这与进程间调用 wait() 函数类似.
```
下面对象用于处理多线程同步, 对象一旦被建立,可以被多个线程共享, 并根据情况阻塞某些进程.
```
    threading.Lock              互斥锁, mutex,
        threading.Lock.acquire() 
        threading.Lock.release()

    threading.Condition         condition variable, 建立该对象时, 包含一个 Lock 对象, 因为 condition variable 总是和 mutex 一起使用. 可以对 condition 对象调用acquire() 和 release() 方法, 以控制潜在的Lock 对象.
        threading.Condition.acquire()       
        threading.Condition.release()       
        threading.Condition.wait()          相当于 cond_wait()
        threading.Condition.notify_all()    相当于 cond_broadcase()
        threading.Condition.notify()        与 notify_all() 功能类似, 但置唤醒一个等待的线程, 而不是全部.

    threading.Semaphore         计数锁,(Semaphore)传统上是一种进程间同步工具. 创建对象的时候,可以传递一个整数作为计数上限(sema= threading.Semaphore(5)). 与 Lock 类似, 也有 Lock 的两个方法.
        threading.Semaphore.acquire()
        threading.Semaphore.release()

    threading.Event             与 threading.Condition 类似, 相当于没有潜在 Lock 保护的 condition variable. 对象有 True 和 False 两个状态 . 可以多个线程使用 wait() 等待, 直到某个线程调用该对象的 set() 方法, 将对象设置为 True. 线程可以调用对象的 clear() 方法来重置对象为 False 状态.
        threading.Event.wait()      等待
        threading.Event.set()       将对象设置为 True 状态.
        threading.Event.clear()     将对象重置为 False 状态.
```
#### 线程 threading.Thread.start() + 过程式编程示例
```
    #!/usr/local/bin/env python
    #

    import threading 
    import time
    import os

    def doChore():
        time.sleep(1)

    def booth(tid):
        global i
        global lock
        while True:
            lock.acquire()
            if i != 0:
                i = i - 1
                print(tid,': now left :',i)
                doChore()
            else:
                print("Thread_id",tid," no more tickets.")
                os._exit(0)
            lock.release()
            doChore()

    i = 100
    lock = threading.Lock()

    for k in range(10):
        new_thread = threading.Thread(target=booth,args=(k,))
        new_thread.start()
```    
#### 线程 threading.Thread.run() + 面向对象 示例
```
    #!/usr/local/bin/env python
    #

    import threading
    import time
    import os

    def doChore():
        time.sleep(1)

    class BoothThread(threading.Thread):
        def __init__(self,tid,monitor):
            self.tid = tid
            self.monitor = monitor
            threading.Thread.__init__(self)
        def run(self):
            while True:
                monitor["lock"].acquire()
                if monitor['tick'] != 0:
                    monitor['tick'] = monitor['tick'] - 1
                    print(self.tid,'now left:',monitor['tick'])
                    doChore()
                else:
                    print('Thread_id', self.tid,"No more ticket.")
                    os._exit(0)
                monitor['lock'].release()
                doChore()

    monitor = {'tick':100, 'lock':threading.Lock()}

    for k in range(10):
        new_thread = BoothThread(k,monitor)
        new_thread.start()
```