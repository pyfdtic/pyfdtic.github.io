---
title: Linux 特殊用户权限 suid sgid sticky
date: 2018-03-19 17:44:17
categories:
- 计算机原理与操作系统
tags:
- Linux
- 权限管理
- 用户管理
---

每个进程会维护有如下6个ID:

    真实身份 : real UID, readl GID --> 登录 shell 使用的身份

    有效身份 : effective UID, effective GID --> 当进程真正去操作文件是所检查的身份,

    存储身份 : saved UID, saved GID --> 当将一个程序文件执行为进程的时候, 该程序文件本身的属主和属组可以被存储为存储身份, 在随后进程运行的过程中, 进程就可以选择将 真实身份或存储身份 复制到有效身份, 以拥有真实身份或存储身份的权限. 但并不是所有的程序文件在执行的过程中都会设置存储身份的, 需要这么做的程序文件会在其 9 位权限的执行位的 x 改为 s, 这时, 这一位叫做 set UID bit 或 set GID bit.

        $ chmod 4799 file  ** 必须要在有 x 位的基础上, 才能设置 s 位.

        这里的chmod后面不再只是三位的数字。最前面一位用于处理set-UID bit/set-GID bit，它可以被设置成为4/2/1以及或者上面数字的和。4表示为set UID bit, 2表示为set GID bit，1表示为sticky bit .

    当 进程 fork 的时候, 真实身份和有效身份都会复制给子进程. 大部分情况下, 真实身份和有效身份都相同. 

### setuid, setgid,sticky

1. setuid :
 
        在一个程序或命令上添加setuid以后（u+s）,这样属主有了s权限，意味着任何用户在执行此程序时,其进程的属主不再是发起者本人,而是这个程序的属主。最典型的一个例子就是passwd这个命令；

        普通用户运执行passwd命令来修改自己的密码，其实最终更改的是/etc/passwd这个文件。
            $ll /etc/passwd
            -rw-r--r-- 1 root root 2597 11月 12 15:36 /etc/passwd
        但是 /etc/passwd 文件只有 root 才有权限更改, 再看下 passwd 命令的权限:  
            ll /usr/bin/passwd
            -rwsr-xr-x 1 root root 54256 3月  29  2016 /usr/bin/passwd*
        passwd 命名运行时, 进程的属主是程序的属主, 即 root, 这样普通用户就有了修改自己账号密码的权限了.
        
        设置 setuid 方法 : 
            $ chmod u(+|-)s /path/to/file
            $ chmod 4644 /path/to/file
    
2. setgid :

        数组有 s 权限, 即 执行此程序时, 次进程的属组不是运行程序的用户, 而是此程序文件的属组. 
        如果 setgid 赋值给 文件, 则运行次文件的其他用户具有该文件的属组特权;
        如果 setgid 赋值为 目录, 则任何用户在该目录下创建的文件,该文件属组都和目录的属组一直.
        
        $ chmod g+s /tmp/test

3. sticky

        在有权限的情况下,可以添加和修改其他用户的文件，就是不能删除其他用户的文件，自己可以删除自己创建的文件。

        $ chmod o(+|-)t /path/somefile

4. 三个权限用 八进制表示 : 

        suid : 4 
        sgid : 2 
        sticky : 1