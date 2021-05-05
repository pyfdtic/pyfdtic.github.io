---
title: PyStdLib--os
date: 2018-03-19 18:28:47
categories:
- Python
tags:
- python 标准库
---
### os
#### os.getcwd()
    os.getcwd()     # 获取当前工作目录
#### os.listdir(path)
    os.listdir('/tmp')      # 列出指定目录下的文件和目录
#### os.mkdir(path [, mode=0777])
    os.mkdir('/tmp/newtest')    #  创建新目录
    os.mkdir('/tmp/ntest/test/test')    # 无法递归创建.  

#### os.rmdir(path)
    os.rmdir('/tmp/newtest')    # 删除**空**目录  

#### os.remove(path)
    os.remove('/tmp/newtest/readne.md')     # 删除指定*文件* ,而非目录

#### os.rename(src,dst)
    os.rename("/tmp/newtest/readme.txt", '/tmp/newtest/readme.md')  # 给文件重命名

#### os.chmod(path,mod)
    os.chmod('/tmp/newtest/readme.md', 0700) # 修改文件的权限, mod 为 4 位数字.

#### os.chown(path,uid,gid)
    os.chown('/tmp/20170223/new',502,502)   # 修改文件的属主和属组

#### os.stat(path)
    os.stat('/tmp/20170223/new')  # 查看文件的附加信息, 相当于 `$ls -l`
    # 返回结果 : 
    # posix.stat_result(st_mode=33261, st_ino=141209, st_dev=64768, st_nlink=1, st_uid=502, st_gid=502, st_size=0, st_atime=1487818970, st_mtime=1487818970, st_ctime=1487819520)

    os.stat('/tmp/20170223/new').uid
    os.stat('/tmp/20170223/new').gid
    os.stat('/tmp/20170223/new').mode
    os.stat('/tmp/20170223/new').ino
    os.stat('/tmp/20170223/new').dev
    os.stat('/tmp/20170223/new').nlink
    os.stat('/tmp/20170223/new').size
    os.stat('/tmp/20170223/new').ctime
    os.stat('/tmp/20170223/new').mtime
    os.stat('/tmp/20170223/new').atime  

#### os.symlink(src,dst)
    os.symlink('/tmp/20170223/new','/tmp/new')  # 为文件 dst 创建软连接, src 为软连接文件的路径.

### os.path
    import os.path
    path = '/var/run/supervisord/supervisor.sock'
#### os.path.basename()
    os.path.basename(path)      # 返回路径中的文件名 
#### os.path.dirname()
    os.path.dirname(path)       # 返回路径中的目录
#### os.path.split()
    print os.path.split(path)       # 将路径分割为文件名和路径两部分,放在一个元组中返回,  ('/var/run/supervisord', 'supervisor.sock')
    path='/var/run/supervisord'     # 为目录
    print os.path.split(path)       # ('/var/run', 'supervisord')
#### os.path.join()
    os.path.join('/', 'home', 'tom', 'scripts', 'init.sh')  # '/home/tom/scripts/init.sh'
    os.path.join('home', 'tom', 'scripts', 'init.sh')       # 'home/tom/scripts/init.sh'

#### os.path.commonprefix()
    path = '/home/tom/scripts/init.sh'
    path2 = '/home/tom/scripts/status.sh'
    path3 = 'home/tom/scripts/init.sh'
    
    os.path.commonprefix([path,path2])      # '/home/tom/scripts/' 
    os.path.commonprefix([path,path3])      # ''
#### os.path.normpath() 
    去除路径中的冗余

    path = '/home/tom/../.'
    os.path.normpath(path)      # '/home'

#### os.path.exists(path) 
    判断路径是否存在, 返回 布尔值

#### os.path.getsize() 
    返回文件大小, 单位字节
#### os.path.getatime() 
    返回文件上一次的读取时间, unix 时间戳
#### os.path.getmtime() 
    返回文件上一次的修改时间, unix 时间戳

#### os.path.isfile() 
    路径存在, 且是文件
#### os.path.isdir() 
    路径存在, 且是目录

### 获取进程相关信息

    os.uname()     # 操作系统先关信息
    os.umask()     # umask 权限码
    os.get*()
        uid,euid,resuid,gid,egid,resgid : 权限相关, resuid 返回 saved UID.
        pid,pgid,ppod,sid : 进程相关
    os.put*() 
        edid,egid : 更改 euid,egid
        uid, gid : 改变进程的 uid,gid. 只用 super user 才有权限.( $sudo python )
        pgid,sid : 改变进程所在的进程组和会话.

    os.getenviron() : 获得进程的环境变量
    os.setenviron() : 更改进程的环境变量