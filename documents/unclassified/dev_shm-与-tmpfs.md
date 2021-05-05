---
title: /dev/shm  与 tmpfs
date: 2018-03-16 16:27:16
categories:
- 计算机原理与操作系统
tags:
- Linux
---
### 1./dev/shm 与 tmpfs

/dev/shm/是linux下一个目录，/dev/shm目录不在磁盘上，而是在内存里, 类型为 tmpfs ，因此使用linux /dev/shm/ 的效率非常高，直接写进内存.

tmpfs有以下特点：

- tmpfs 是一个文件系统，而不是块设备。
- 动态文件系统的大小。
- tmpfs 的另一个主要的好处是它闪电般的速度。因为典型的 tmpfs 文件系统会完全驻留在 RAM 中，读写几乎可以是瞬间的。
- tmpfs 数据在重新启动之后不会保留，因为虚拟内存本质上就是易失的。

### 2.linux /dev/shm 默认容量
    
linux下/dev/shm的容量默认最大为内存的一半大小，使用 `df -h` 命令可以看到。但它并不会真正的占用这块内存，如果/dev/shm/下没有任何文件，它占用的内存实际上就是0字节；如果它最大为1G，里头放有100M文件，那剩余的900M仍然可为其它应用程序所使用，但它所占用的100M内存，则不会被系统回收重新划分.

### 3.linux /dev/shm 容量(大小)调整

linux /dev/shm容量(大小)是可以调整，在有些情况下(如oracle数据库)默认的最大一半内存不够用，并且默认的 inode 数量很低一般都要调高些，这时可以用mount命令来管理它。

    mount -o size=1500M -o nr_inodes=1000000 -o noatime,nodiratime -o remount /dev/shm

在2G的机器上，将最大容量调到1.5G，并且inode数量调到1000000，这意味着大致可存入最多一百万个小文件

通过/etc/fstab文件来修改/dev/shm的容量(增加size选项即可),修改后，重新挂载即可.


[参考: linux /dev/shm的用途](http://dbua.iteye.com/blog/1271574)
[参考: kernel tmpfs 文档](https://www.kernel.org/doc/Documentation/filesystems/tmpfs.txt)