---
title: PyStdLib--subprocess
date: 2018-03-19 18:31:56
categories:
- Python
tags:
- python 标准库
---
## subprocess
*主要功能室执行外部的命令和程序*  

> *一个进程可 fork 一个子进程, 并让这个子进程 exec 另外一个程序. 在 python 中, 可以通过标准库中的 subprocess 包来 fork 一个子进程, 并运行一个外部的程序.*

subprocess
  
- 创建子进程的函数, 这些函数分别用不同的方式创建进程.

    使用 subprocess 包中的函数创建子进程时, 要注意 :  

    - 在创建子进程之后, 父进程是否暂停, 并等待子进程运行,  
    - 函数返回什么  
    - 当 returncode 不为 0 时, 父进程如何处理.  
      
- 管理标准流(standard stream)和管道(pipe)的工具, 从而在进程间使用文本通信.

#### subprocess.call(*popenargs, **kwargs)

    父进程等待子进程完成, 返回退出信息(returncocde, 相当于 exit code)
    
    subprocess.call("ls -l", shell=True)    # 返回值为 命令执行结果返回码
    subprocess.call(["ls","-l"]) 

#### subprocess.check_call(*popenargs, **kwargs)

    父进程等待子进程完成, 返回 0 , 
    检查退出信息, 如果 returncode 不为 0, 则抛出 subprocess.CalledProcessError 错误. 
    
    subprocess.check_call(['ls','-l'])      # 返回值为 命令执行结果返回码

#### subprocess.check_output(*popenargs, **kwargs) 

    父进程等待子进程完成, 返回子进程向标准输出的输出结果. 
    检查退出信息, 如果 returncode 不为 0, 则抛出错误 subprocess.CalledProcessError , 该对象包含有 returncode 属性和 output 属性, output 属性为标准输出的输出结果. 
    
    subprocess.check_output(['ls','-l'])  # 返回值为 命令执行结果.

*如果使用了shell=True这个参数。这个时候，我们使用一整个字符串，而不是一个表来运行子进程。Python将先运行一个shell，再用这个shell来解释这整个字符串。*  
*shell命令中有一些是shell的内建命令，这些命令必须通过shell运行，$cd。shell=True允许我们运行这样一些命令。*
*当使用 shell 的内建命令时, 需要执行的命令及其参数必须为 一个整字符串, 并且加上 shell=True 参数.*
 
#### subprocess.Popen() 
    上面三个函数(subprocess.call(), subprocess.check_all(), subprocess.check_output() )都是基于 Popen() 的封装. 该类生成的对象来代表子进程.

    class Popen(args, bufsize=0, executable=None,
                stdin=None, stdout=None, stderr=None,
                preexec_fn=None, close_fds=False, shell=False,
                cwd=None, env=None, universal_newlines=False,
                startupinfo=None, creationflags=0)
    
    args should be a string, or a sequence of program arguments.  The
    program to execute is normally the first item in the args sequence or
    string, but can be explicitly set by using the executable argument.

        On UNIX, with shell=False (default): In this case, the Popen class
        uses os.execvp() to execute the child program.  args should normally
        be a sequence.  A string will be treated as a sequence with the string
        as the only item (the program to execute).
        
        On UNIX, with shell=True: If args is a string, it specifies the
        command string to execute through the shell.  If args is a sequence,
        the first item specifies the command string, and any additional items
        will be treated as additional shell arguments.
        
        On Windows: the Popen class uses CreateProcess() to execute the child
        program, which operates on strings.  If args is a sequence, it will be
        converted to a string using the list2cmdline method.  Please note that
        not all MS Windows applications interpret the command line the same
        way: The list2cmdline is designed for applications using the same
        rules as the MS C runtime.

    bufsize, if given, has the same meaning as the corresponding argument
    to the built-in open() function: 0 means unbuffered, 1 means line
    buffered, any other positive value means use a buffer of
    (approximately) that size.  A negative bufsize means to use the system
    default, which usually means fully buffered.  The default value for
    bufsize is 0 (unbuffered).
    
    stdin, stdout and stderr specify the executed programs' standard
    input, standard output and standard error file handles, respectively.
    Valid values are PIPE, an existing file descriptor (a positive
    integer), an existing file object, and None.  PIPE indicates that a
    new pipe to the child should be created.  With None, no redirection
    will occur; the child's file handles will be inherited from the
    parent.  Additionally, stderr can be STDOUT, which indicates that the
    stderr data from the applications should be captured into the same
    file handle as for stdout.
    
    If preexec_fn is set to a callable object, this object will be called
    in the child process just before the child is executed.
    
    If close_fds is true, all file descriptors except 0, 1 and 2 will be
    closed before the child process is executed.
    
    if shell is true, the specified command will be executed through the
    shell.
    
    If cwd is not None, the current directory will be changed to cwd
    before the child is executed.

    If env is not None, it defines the environment variables for the new
    process.
    
    If universal_newlines is true, the file objects stdout and stderr are
    opened as a text files, but lines may be terminated by any of '\n',
    the Unix end-of-line convention, '\r', the Macintosh convention or
    '\r\n', the Windows convention.  All of these external representations
    are seen as '\n' by the Python program.  Note: This feature is only
    available if Python is built with universal newline support (the
    default).  Also, the newlines attribute of the file objects stdout,
    stdin and stderr are not updated by the communicate() method.
    
    The startupinfo and creationflags, if given, will be passed to the
    underlying CreateProcess() function.  They can specify things such as
    appearance of the main window and priority for the new process.
    (Windows only)
    
    Instances of the Popen class have the following methods:
        child.poll()   # 检查进程状态
            Check if child process has terminated. Returns returncode attribute.

        child.wati()
            wait for child process to terminate. Return returncode attribute.,\

        child.commuticate(input=None)  # 阻塞父进程, 直到子进程完成.
            Interact with process : Send data to stdin. Read data from stdout 
                        and stderr, until end-of-file is reached. Wait for process ti terminate. 
                        The optional input argument shout be a string to be sent to the child 
                        process, or None, if no data should be sent to the child . 
            
            communicate() returns a tuple (stdout, stderr).
    
            Note: The data read is buffered in memory, so do not use this
            method if the data size is large or unlimited.

        child.kill()    # 终止进程

        child.send_signal() # 向子进程发送信号

        child.terminate()   # 终止子进程.
    
    attributes
 
        stdin
            If the stdin argument is PIPE, this attribute is a file object
            that provides input to the child process.  Otherwise, it is None.
        
        stdout
            If the stdout argument is PIPE, this attribute is a file object
            that provides output from the child process.  Otherwise, it is
            None.
        
        stderr
            If the stderr argument is PIPE, this attribute is file object that
            provides error output from the child process.  Otherwise, it is
            None.
        
        pid
            The process ID of the child process.
        
        returncode
            The child return code.  A None value indicates that the process
            hasn't terminated yet.  A negative value -N indicates that the
            child was terminated by signal N (UNIX only).


## 子进程的文本流控制 : subprocess.PIPE 
subprocess.PIPE 实际上为文本流提供了一个缓冲区.

子进程的标准输入, 标准输出, 标准错误:

    child.stdin
    child.stdout
    child.stderr

我们可以在 Popen() 建立子进程的时候改变标准输入, 标准输出, 标准错误, 并利用 subprocess.PIPE 将多个子进程的输入和输出链接在一起, 构成管道(pipe) :

    import subprocess
    child1 = subprocess.Popen(["ls","-l"], stdout=subprocess.PIPE)
    child2 = subprocess.Popen(["wc"], stdin=child1.stdout,stdout=subprocess.PIPE)
    out = child2.communicate()
    print(out)

child.communicate() 是 Popen 对象的一个方法, 该方法阻塞父进程, 直到子进程完成.

    使用 communicate() 方法来使用 PIPE 给子进程输入 : 
    import subprocess
    child = subprocess.Popen(['cat'], stdin=subprocess.PIPE)
    child.communicate("hahahah")   # 我们启动子进程之后, cat 会等待输入, 知道 communicate() 输入 "hahahah"
    

[参考](http://www.cnblogs.com/vamei/archive/2012/09/23/2698014.html)