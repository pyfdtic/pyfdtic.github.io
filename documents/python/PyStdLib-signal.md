---
title: PyStdLib--signal
date: 2018-03-19 18:28:47
categories:
- Python
tags:
- python 标准库
---
signal 的核心是, 设置信号处理函数.

### 预定义信号
    signal.SIG_DFL   signal.SIGBUS    signal.SIGFPE    signal.SIGIO     signal.SIGPOLL   signal.SIGRTMAX  signal.SIGSYS    signal.SIGTTIN   signal.SIGUSR2   signal.SIGXFSZ   
    signal.SIG_IGN   signal.SIGCHLD   signal.SIGHUP    signal.SIGIOT    signal.SIGPROF   signal.SIGRTMIN  signal.SIGTERM   signal.SIGTTOU   signal.SIGVTALRM                  
    signal.SIGABRT   signal.SIGCLD    signal.SIGILL    signal.SIGKILL   signal.SIGPWR    signal.SIGSEGV   signal.SIGTRAP   signal.SIGURG    signal.SIGWINCH                   
    signal.SIGALRM   signal.SIGCONT   signal.SIGINT    signal.SIGPIPE   signal.SIGQUIT   signal.SIGSTOP   signal.SIGTSTP   signal.SIGUSR1   signal.SIGXCPU

### signal.signal(signalnum, handler)
为指定的信号, 设置自定义的处理函数.

    import signal
    # Define signal handler function
    def myHandler(signum, frame):
        print('I received: ', signum)
    
    # register signal.SIGTSTP's handler 
    signal.signal(signal.SIGTSTP, myHandler)
    signal.pause()
    print('End of Signal Demo')
    
    # 效果 : 当执行该脚本时, 脚本自身阻塞; 当向脚本发送 SIGTSTP 信号时, 脚本执行 myHandler 函数, 并继续执行之后的 print 语句.

### signal.pause()
当运行到此处时, 进程暂停并等待信号. 代码如上示例.

### signal.alarm(SECONDS)  
被用于在一定时间之后, 向进程自身发送 SIGALRM 信号.
    
    import signal
    # Define signal handler function
    def myHandler(signum, frame):
        print("Now, it's the time")
        exit()
    
    # register signal.SIGALRM's handler 
    signal.signal(signal.SIGALRM, myHandler)
    signal.alarm(5)
    while True:
        print('not yet')

    # 效果 : 脚本无条件循环 打印语句, 在执行 5 秒之后, signal.alarm() 向自身发送 SIGALRM 信号, 执行 myHandler 函数.