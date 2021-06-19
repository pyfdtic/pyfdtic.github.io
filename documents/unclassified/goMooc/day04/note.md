## 系统调用

系统调用: 同步的.

sys call 最多 6 个.

ring0 ring3 体现在 寄存器的切换.


## 观察系统调用
strace for Linux
dtruss for Mac

## VDSO

混沌测试: 需要修改时间

## 源码分析

Tips:
- go spec 

## QA

https://shimo.im/docs/vjYP3WkRGyd9R9P9


```
ring0-ring3在os代码中是怎么体现的
ring3 -> ring0: syscall(硬件指令)
ring0 -> ring3: sysret(硬件指令)
函数传参的时候是不是只要在六个之内，就会通过寄存器操作
Go 应用层代码函数调用没有寄存器一说，都是通过栈传参的
C 语言：6 个以内寄存器，超过 6 个的话，超过部分会放到栈上
系统调用：专有的调用规约
后面会讲网络编程吗？(netpoller,epoll）这种
web 部分讲 netpoll 实现
是所有的syscall，都会发生M+G独立出来吗？ 比如getpid这种syscall，感觉是很轻的系统调用行为。
先区分 sys(阻塞的系统调用)、sysnb(非阻塞)，非阻塞系统调用不会独立出去；阻塞的系统调用，运行时间超过一定界限才会有独立。
还是sysmon在做监控的吗：是的


汇编中的SB是什么意思，比如：runtime.exitsyscall(SB)，怎么确定值是什么
静态基地址寄存器，全局变量、函数声明的时候都需要用
call runtime.exitsyscall
 6. 曹大简单生动地讲下中断以及应用
     a. The Linux Programming interface
     b. low level programming
7. 是否可以通过CGO创建线程？
     a. cgo 创建线程理论上是可以的
8.syscall是不是很耗cpu，cpu需要等待syscall 返回吗
     a. 上下文切换成本比较高，阻塞在 syscall 上的线程是不消耗 CPU
     b. 
9.go 应该有办法获取ring0权限吧？
     a. 用户不能随便切换到 ring0，只能通过 syscall、int 80、sysenter
10.select 是使用epoll吗？是一种是同步io吗？
     a. select {} 和 epoll 没关系
     b. select 系统调用 epoll 两套东西
11 陷入系统调用期间的M，它不可用了，被剥离的P，是被新创建的M持有继续执行吗？
     a. sysmon -> retake -> handoffp -> mstart
12.虚拟寄存器与CPU其他寄存器有什么区别，比如作用或实现
     a. Go 伪寄存器
     b. AX -> rax, BX -> rbx
     c. AX -> eax

```



