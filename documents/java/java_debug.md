# java debug

## java 性能监测工具

Java自带的性能监测工具用法简介——jstack、jconsole、jinfo、jmap、jdb、jsta、jvisualvm

- jps (Java Virtual Machine Process Status Tool)  主要用来输出JVM中运行的进程状态信息, 
    ```
    $ jsp [options] [hostid]
        -q : 不输出类名, jar名和传入main方法的参数
        -m : 输出传入的main方法的参数
        -l : 输出main类或jar的全限名
        -v : 输出传入jvm的参数
        [hostid] : 默认为当前主机或服务器
    ```
- jconsole

- jinfo

- jmap (Memory Map)查看堆内存使用情况, 一般结合jhat使用
    ```
    $ jmap [option] pid
    $ jmap [option] executable core
    $ jmap [option] [service@]remote-hostname-or-ip
        -j-d64 : 64位jvm上, 可能需要改参数
    
    $ jmap -permstat pid 
      打印进程的类加载器和类加载器加载的持久代对象信息, 输出: 类加载器名称、对象是否存活(不可靠)、对象地址、父类加载器、已加载的类大小等信息

    $ jmap -heap pid
      查看进程堆内存使用情况, 包括使用GC算法, 对配置参数和各代中堆内存使用情况. 

    $ jmap -histo[:live] pid
      查看堆内存中的对象数目、大小统计直方图, 如果带上live则只统计活对象, 
      class name : 对象类型
        B : byte
        C : char
        D : double
        F : float
        I : int
        J : long
        Z : boolean
        [ : 数组, 如[I表示int[]
        [L+类名 : 其他对象

    $ jmap -dump:format=b,file=dumpFileName pid 
      jmap把进程内存使用情况dump到文件中, 再用jhat分析查看. dump出来的文件可以用MAT、VisualVM等工具查看, 这里用jhat查看: 
        $ jhat -port 9998 /tmp/dump.dat
      如果Dump文件太大, 可能需要加上-J-Xmx512m这种参数指定最大堆内存,例如: 
        $ jhat -J-Xmx512m -port 9998 /tmp/dump.dat
      然后就可以在浏览器中输入 host_ip:9998 查看了: 
    ```
- jhat : 见上面的

- jdb

- jstat : jvm统计监测工具
    ```
    $ jstat [ generalOption | outputOptions vmid [interval[s|ms] [count]] ]
        vmid : Java虚拟机ID, 在Linux/Unix系统上一般就是进程ID. 
        interval : 采样时间间隔
        count : 采样数目

    $ jstat -gc 21711 250 4
      输出含义: 
        S0C、S1C、S0U、S1U: Survivor 0/1区容量(Capacity)和使用量(Used)
        EC、EU: Eden区容量和使用量
        OC、OU: 年老代容量和使用量
        PC、PU: 永久代容量和使用量
        YGC、YGT: 年轻代GC次数和GC耗时
        FGC、FGCT: Full GC次数和Full GC耗时
        GCT: GC总耗时        
    jvm堆内存布局: http://static.oschina.net/uploads/space/2014/0128/181847_dAR9_111708.jpg
      堆内存=年轻代+年老代+永久代
      年轻代=Eden区+两个survivor区(From+To)
    ```
- jvisualvm

- hprof (Heap/CPU Profiling Tool)展现CPU使用率, 统计堆内存使用情况
    
    ```
    $ java -agentlib:hprof[=options] ToBeProfiledClass
    $ java -Xrunprof[:options] ToBeProfiledClass
    $ javac -J-agentlib:hprof[=options] ToBeProfiledClass
      完整的命令与选项: 
        Option Name and Value  Description                    Default
        ---------------------  -----------                    -------
        heap=dump|sites|all    heap profiling                 all
        cpu=samples|times|old  CPU usage                      off
        monitor=y|n            monitor contention             n
        format=a|b             text(txt) or binary output     a
        file=<file>            write data to file             java.hprof[.txt]
        net=<host>:<port>      send data over a socket        off
        depth=<size>           stack trace depth              4
        interval=<ms>          sample interval in ms          10
        cutoff=<value>         output cutoff point            0.0001
        lineno=y|n             line number in traces?         y
        thread=y|n             thread in traces?              n
        doe=y|n                dump on exit?                  y
        msa=y|n                Solaris micro state accounting n
        force=y|n              force output to <file>         y
        verbose=y|n            print messages about dumps     y
    $ java -agentlib:hprof=cpu=samples,interval=20,depth=3 Hello
      每隔20毫秒采样CPU消耗信息, 堆栈深度为3, 生成的profile文件名称是java.hprof.txt, 在当前目录. 

    $ javac -J-agentlib:hprof=cpu=times Hello.java
      CPU Usage Times Profiling(cpu=times)的例子, 它相对于CPU Usage Sampling Profile能够获得更加细粒度的CPU消耗信息, 能够细到每个方法调用的开始和结束, 它的实现使用了字节码注入技术(BCI): 

    $ javac -J-agentlib:hprof=heap=sites Hello.java
      Heap Allocation Profiling(heap=sites)的例子

    $ javac -J-agentlib:hprof=heap=dump Hello.java
      Heap Dump(heap=dump)的例子, 它比上面的Heap Allocation Profiling能生成更详细的Heap Dump信息: 

    *** 虽然在JVM启动参数中加入-Xrunprof:heap=sites参数可以生成CPU/Heap Profile文件, 但对JVM性能影响非常大, 不建议在线上服务器环境使用. 
    ```
- jstack 用来查看某个java进程内的线程堆栈信息. jstack可以定位到线程堆栈, 根据堆栈信息我们可以定位到具体代码, 所以它在JVM性能调优中使用得非常多. 

    jstack工具还可以附属到正在运行的java程序中, 看到当时运行的java程序的java stack和native stack的信息, 如果现在运行的java程序呈现hung的状态, jstack是非常有用的. 

    ```
    $ jstack [option] pid
    $ jstack [option] executable core
    $ jstack [option] [server-id@]remote-hostname-or-ip
        core 将被打印信息的core dump文件
        -l long listings : 会打印出额外的锁信息, 在发生死锁时可以用jstack -l pid观察锁特用情况. 
        -m mixed mode : 不仅输出java堆栈信息, 还输出C/C++堆栈信息,比如Native方法

    找出该进程内最耗费CPU的线程, 可以使用
      $ ps -Lfp pid
      $ ps -mp pid -o THREAD, tid, time
      $ top -Hp pid
    ```
    
    寻找占用资源最多的java进程
    ```
    $ top   # 找出占用资源最多的PID
      15417  release   20   0 8727m 1.5g  16m S 704.8  2.4   7119:13 java                                                                      
      38159 storm     20   0 6596m 596m  16m S  9.6  0.9  11448:30 java                                                                       
      8758 kafka     20   0 5999m 1.1g  13m S  8.3  1.7  19957:54 java

    $ top -p 40274 -H   # 但对该java PID的线程做监控

      linux下, 所有的java内部线程, 其实都对应了一个进程id, 也就是说, linux上的sun jvm将java程序中的线程映射为了操作系统进程；我们看到, 占用CPU资源最高的那个进程id是'15417', 这个进程id对应java线程信息中的'nid'('n' stands for 'native');    

    $ jstack 15417 >jstack.log   # jstack打出当前栈信息到一个文件里,到到底是哪段具体的代码占用了如此多的资源, 

    $ jtgrep 15417 stack.log    # jtgrep为自定义脚本, 使用'jtgrep'脚本把这个进程号为'15417'的java线程在stack.log中抓出来: 

    $ cat jtgrep    # 就是把'15417'转换成16进制后, 直接grep stack.log;可以看到, 被grep出的那个线程的nid=0x3c39, 正好是15417的16进制表示. 
      
      + #!/bin/bash
      + nid=`printf %x $1`
      + grep -i 0x$nid $2   
    ```

## java 故障诊断
    
1. thread dump: 线程  dump

    ```
    $ jstack -F [-l] PID    # 如果无响应, 去掉 -l 参数
        -m : 同时输出 java 调用栈和本地调用栈

    $ top -p PID -H         # 查看线程的 CPU 使用情况
    ```


2. 查看 GC STAT 
    ```
    $ jstat -gcutil PID <间隔时间/ms>

    $ jstat -gcutil 3669 1000
    ```

3. Java 启动参数
    ```
    MaxMetaspaceSize : 从 java8 开始引入, 替代过去的 PermGen 空间(永久代), 用来存放类的元数据信息. 该值用来指定 Metaspace 空间的最大值. 当超过这个值的时候, 将会触发 GC 对该空间进行回收.

    CMSClassUnloadingEnable : 当使用 CMS 算法是, 是否进行类卸载(ClassUnloading). jdk6 和 jdk7 默认为 false, jdk8 默认为 true ,即 默认进行类卸载.

    noclassgc : 这个选项的含义是不对class进行GC, 哪怕这些class已经成为垃圾. 实际等价于不进行类卸载. 
    ```

## jdk
```
JDK 安装
    ① 下载JDK
    ② 解压到目标目录
    ③ 配置环境变量: 
        # vim /etc/profile
          + JAVA_HOME=/path/to/jdk
            PATH=$PATH:$JAVA_HOME/bin
            export PATH JAVA_HOME
        # source /etc/profile
    ④ 测试: 
        # java -version

   $ rpm -ivh  http://nexus.gs.9188.com/nexus/content/repositories/thirdparty/java/jdk/8u65/jdk-8u65-linux-x64.rpm
```

## Tomcat安装
```
    ① 下载tomcat
    ② 解压到目标目录
    ③ 配置环境变量: 
        # vim /etc/profile
          + TOMCAT_PATH=/path/to/Tomcat/
        # source /etc/profile
    ④ 启动服务: 
        # catalina.sh start
    ⑤ 测试: 
        # http://IP: 8080   

```

## jvm 内存模型

内存空间(Runtime Data Area) 可以按照是否线程共享分为两块:
- 线程共享

    方法区(Method Area)
    堆(Heap)

- 线程独享

    Java 栈(Java Stack)
    本地方法栈(Native Method Stack)
    PC寄存器(Program Counter Register)

Java 1.8 中 -XX:PermSize 和 -XX:MaxPermSize 已经失效, 取而代之的是一个新的区域 —— Metaspace(元数据区). 

在 JDK 1.7 及以往的 JDK 版本中, Java 类信息、常量池、静态变量都存储在 Perm(永久代)里. 类的元数据和静态变量在类加载的时候分配到 Perm, 当类被卸载的时候垃圾收集器从 Perm 处理掉类的元数据和静态变量. 当然常量池的东西也会在 Perm 垃圾收集的时候进行处理. 

JDK 1.8 的对 JVM 架构的改造将类元数据放到本地内存中, 另外, 将常量池和静态变量放到 Java 堆里. HotSopt VM 将会为类的元数据明确分配和释放本地内存. 在这种架构下, 类元信息就突破了原来 -XX:MaxPermSize 的限制, 现在可以使用更多的本地内存. 这样就从一定程度上解决了原来在运行时生成大量类的造成经常 Full GC 问题, 如运行时使用反射、代理等. 

