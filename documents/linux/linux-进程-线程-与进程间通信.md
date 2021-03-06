
## 进程如何使用内存.
当程序文件运行为进程时, 进程在内存中获得空间.

![进程内存空间结构](/imgs/linux//%E8%BF%9B%E7%A8%8B%E5%86%85%E5%AD%98%E7%A9%BA%E9%97%B4%E7%BB%93%E6%9E%84.jpg)

    1) Text : 固定大小
        存储指令(instruction), 说明每一步的操作.        

    2) Global Data : 固定大小
        存放全局变量      

    3) Stack
        存放局部变量.
        以帧(stack frame) 为单位, 当程序调用函数的时候, stack 向下增长一帧. 帧中存储该函数的参数和局部变量, 以及该函数的返回地址(return address). 此时, 计算机控制权转移到被调用的函数, 该函数处于激活状态(active).
        
        位于栈最下方的帧, 和全局变量一起, 构成了当前的环境(context) 上下文. 激活的函数可以从环境中调用需要的变量. 典型的编程语言都只允许你使用位于 stack 最下方的帧, 而不允许你调用其他的帧(这也符合 stack 先进先出的特征).
        
        当函数又进一步调用另一个函数的时候, 一个新的帧会继续增加到帧的下方, 控制权移交到新的函数当中.
        
        当激活函数返回的时候, 会从栈中弹出(pop, 读取并从占中删除)该帧, 并根据帧中记录的返回地址, 将控制权交给返回地址所指定的指令.
    
        在进程运行的过程中, 通过调用和返回函数, 控制权不断在函数间转移. 进程可以在调用函数的时候, 原函数的帧中保存有在我们离开时的状态, 并为新的函数开辟所需的帧空间. 在调用函数返回时, 该函数的帧所占据的空间随着帧的弹出而清空. 进程再次回到原函数的帧中保存的状态, 并根据返回地址所指向的指令继续执行. 

        上面的过程不断继续, 栈不断增长或减小, 主函数返回的时候, 栈全部清空, 进程结束.

    4) Heap
        存放动态变量(dynamic variable). 程序利用 malloc 系统调用, 直接从内存中为 dynamic variable 开辟空间.

        当程序总使用 malloc 的时候, 堆(heap)会向上增长, 其增长的部分就成为 malloc 从内存中分配的空间. malloc 开辟的空间会一直存在, 知道我们调用 free系统调用来释放, 或者进程结束. 一个经典的错误的 内存泄露(memory leakage), 就是指我们没有释放不再使用的堆空间, 导致堆不断增长, 而内存不可用空间不断减少.

    堆和栈的大小则会随着进程的运行增大或变小. 当栈和堆增长到两者相遇的时候, 再无内存可用. 进程会出现 栈溢出(stack overflow) 的错误, 导致进程终止.

## 进程附加信息 : task_struct
每个进程还要包括一些进程附加信息, 包括 PID,PPID,PGID等, 用来说明程序的身份,进程关系,以及其他统计信息. 

这些信息*并不保存在*进程自己的内存空间中.  **内核** 为每个进程在内核自己的空间中分配一个变量(**task_struct 结构体**)以保存上述信息. 

内核可以通过查看自己空间中的各个进程的附加信息就能知道进程的概况, 而不用进入到进程自身的空间. 每个进程的附加信息中都有位置专门用于保存接受到的信息.

## fork && exec     

**fork** : 当程序调用 fork 的时候, 实际上就是讲上面的内存空间, 包括 text,global data, heap,stack, 又赋值出来一个, 构成新的进程, 并在内核中为该进程创建新的附加信息(如pid等), 此后, 两个进程分别地继续运行下去, 新的进程和原有的进程有相同的进程状态(相同的变量值, 相同的 instruction), 我们会只能通过进程的附加信息来区分两者.

**exec** : 程序调用 exec 的时候, 进程清空自身内存空间 text, global data,heap,stack. 并根据新的程序文件重建 text,glabal data ,heap,stack (此时 heap 和 stack 大小都为 0), 并开始运行.


## 多线程
多线程就是允许一个进程内存在多个控制权, 以便让多个函数同时处于激活状态, 从而让多个函数的操作同时运行. 即使是单cpu 的计算机,也可以通过不停的在不同线程的指令键切换, 从而造成多线程同事运行的效果.

![多线程运行](/imgs/linux//%E5%A4%9A%E7%BA%BF%E7%A8%8B%E8%BF%90%E8%A1%8C.jpg)

    main() 到 func3() 再到 main() 构成一个线程, func1 和 func2 构成另外两个线程. 操作系统一般都有一些系统调用来让你讲一个函数运行成为一个新的线程.

创建一个新的线程时，我们为这个线程建一个新的栈。每个栈对应一个线程。当某个栈执行到全部弹出时，对应线程完成任务，并收工。所以，多线程的进程在内存中有多个栈。多个栈之间以一定的空白区域隔开，以备栈的增长。每个线程可调用自己栈最下方的帧中的参数和变量，并与其它线程共享内存中的Text，heap和global data区域。对应上面的例子，我们的进程空间中需要有3个栈。

## 多线程同步
对于多线程来说, 同步(synchronization) 是指在一定的时间内, 之允许某一个线程来访问某个资源. 可以通过 互斥锁(mutex)/条件变量(condition variable)/读写锁(reader-writer lock)来同步资源.


#### 互斥锁(mutex)
互斥锁是一个特殊变量, 有 锁上(lock) 和 打开(ublock) 两个状态. 互斥锁一般被设置成全局变量. 打开的互斥锁可以由某个线程获得, 一旦获得, 这个互斥锁会锁上, 此后只有该线程有权打开. 其他想要获得互斥锁的线程, 会等待知道互斥锁再次打开的时候. 

(可以将互斥锁想成只能容纳一个人的洗手间,可以从里面将洗手间锁上。其它人只能在互斥锁外面等待那个人出来，才能进去。在外面等候的人并没有排队，谁先看到洗手间空了，就可以首先冲进去。)

#### 条件变量(condition variable)
条件变量时另一种常用的变量, 常常被保存为全局变量,并和互斥锁合作. 

条件变量特别适用于多个线程等待某个条件的发生。如果不使用条件变量，那么每个线程就需要不断尝试获得互斥锁并检查条件是否发生，这样大大浪费了系统的资源。

如 : 有100个工人，每人负责装修一个房间。当有10个房间装修完成的时候，老板就通知相应的十个工人一起去喝啤酒。

#### 读写锁(reader-writer lock)

读写锁与互斥锁非常相似, 有三种状态 : 共享读取锁(shared-read), 互斥写入锁(exclusive-write lock), 打开(unlock). 后两种状态与之前的互斥锁两种状态完全相同. 

一个 unlock 的 RW lock 可以被其他线程继续获得 R 锁, 而不必等待该线程释放 R 锁. 但是, 如果此时有其他线程想要获得 W 所, 必须等待所有持有共享读取锁的线程释放到各自的 R 锁.

如果一个锁被一个线程获得 W 锁, 那么其他线程, 无论是想要获取 R 锁还是 W 锁, 都必须等待该线程释放 W 锁.

这样, 多个线程就可以同时读取共享资源, 而具有危险性的写入操作则得到了互斥锁的保护.

同步并发系统，这为程序员编程带来了难度。但是多线程系统可以很好的解决许多IO瓶颈的问题。


## Linux 进程间通信.

#### 管道(PIPE)

可以使用管道将一个进程的输出和另一个进程的输入连接起来，从而利用文件操作API来管理进程间通信。

管道是由内核管理的一个缓冲区(buffer)，相当于我们放入内存中的一个纸条。管道的一端连接一个进程的输出。这个进程会向管道中放入信息。管道的另一端连接一个进程的输入，这个进程取出被放入管道的信息。一个缓冲区不需要很大，它被设计成为环形的数据结构，以便管道可以被循环利用。当管道中没有信息的话，从管道中读取的进程会等待，直到另一端的进程放入信息。当管道被放满信息的时候，尝试放入信息的进程会等待，直到另一端的进程取出信息。当两个进程都终结的时候，管道也自动消失。

![pipe 原理](/imgs/linux//pipe_%E5%8E%9F%E7%90%86.jpg)
从原理上，管道利用fork机制建立，从而让两个进程可以连接到同一个PIPE上。最开始的时候，上面的两个箭头都连接在同一个进程Process 1上(连接在Process 1上的两个箭头)。当fork复制进程的时候，会将这两个连接也复制到新的进程(Process 2)。随后，每个进程关闭自己不需要的一个连接 (两个黑色的箭头被关闭; Process 1关闭从PIPE来的输入连接，Process 2关闭输出到PIPE的连接)，这样，剩下的红色连接就构成了如上图的PIPE。

由于基于fork机制，所以管道只能用于父进程和子进程之间，或者拥有相同祖先的两个子进程之间 (有亲缘关系的进程之间)。为了解决这一问题，Linux提供了FIFO方式连接进程。FIFO又叫做**命名管道(named PIPE)**。
    
FIFO (First in, First out)为一种特殊的文件类型，它在文件系统中有对应的路径。当一个进程以读(r)的方式打开该文件，而另一个进程以写(w)的方式打开该文件，那么内核就会在这两个进程之间建立管道，所以FIFO实际上也由内核管理，不与硬盘打交道。之所以叫FIFO，是因为管道本质上是一个先进先出的队列数据结构，最早放入的数据被最先读出来(好像是传送带，一头放货，一头取货)，从而保证信息交流的顺序。FIFO只是借用了文件系统(file system)来为管道命名。写模式的进程向FIFO文件中写入，而读模式的进程从FIFO文件中读出。当删除FIFO文件时，管道连接也随之消失。FIFO的好处在于我们可以通过文件的路径来识别管道，从而让没有亲缘关系的进程之间建立连接。

#### 传统 IPC (interprocess communication) : 特点是允许多进程之间共享资源.

    消息队列(message queue)
    信号量(semaphore)
    共享内存(shared memory)

不使用文件操作的API。

对于任何一种IPC来说，你都可以建立多个连接，并使用键值(key)作为识别的方式。我们可以在一个进程中中通过键值来使用的想要那一个连接 (比如多个消息队列，而我们选择使用其中的一个)。键值可以通过某种IPC方式在进程间传递(比如说我们上面说的PIPE，FIFO或者写入文件)，也可以在编程的时候内置于程序中。

- 消息队列(message queue)与PIPE相类似。它也是建立一个队列，先放入队列的消息被最先取出。不同的是，消息队列允许**多个进程**放入消息，也允许**多个进程**取出消息。每个消息可以带有一个**整数识别符**(message_type)。你可以通过识别符对消息分类 (极端的情况是将每个消息设置一个不同的识别符)。某个进程从队列中取出消息的时候，可以按照先进先出的顺序取出，也可以只取出符合某个识别符的消息(有多个这样的消息时，同样按照先进先出的顺序取出)。消息队列与PIPE的另一个不同在于它并不使用文件API。最后，一个队列不会自动消失，它会一直存在于内核中，直到某个进程删除该队列。

- semaphore与mutex类似，用于处理同步问题。我们说mutex像是一个只能容纳一个人的洗手间，那么semaphore就像是一个能容纳N个人的洗手间。其实从意义上来说，semaphore就是一个**计数锁**(我觉得将semaphore翻译成为信号量非常容易让人混淆semaphore与signal)，它允许被N个进程获得。当有更多的进程尝试获得semaphore的时候，就必须等待有前面的进程释放锁。当N等于1的时候，semaphore与mutex实现的功能就完全相同。许多编程语言也使用semaphore处理多线程同步的问题。一个semaphore会一直存在在内核中，直到某个进程删除它。

- 共享内存与多线程共享global data和heap类似。一个进程可以将自己内存空间中的一部分拿出来，允许其它进程读写。当使用共享内存的时候，我们要注意**同步**的问题。我们可以使用semaphore同步，也可以在共享内存中建立mutex或其它的线程同步变量来同步。由于共享内存允许多个进程直接对同一个内存区域直接操作，所以它是**效率最高**的IPC方式。

互联网通信实际上也是一个进程间通信的问题，只不过这多个进程分布于不同的电脑上。网络连接是通过socket实现的。

[参考](http://www.cnblogs.com/vamei/archive/2012/09/20/2694466.html)
[参考](http://www.cnblogs.com/vamei/archive/2012/10/07/2713023.html)
[参考](http://www.cnblogs.com/vamei/archive/2012/10/09/2715388.html)
[参考](http://www.cnblogs.com/vamei/archive/2012/10/09/2715393.html)
[参考](http://www.cnblogs.com/vamei/archive/2012/10/10/2715398.html)