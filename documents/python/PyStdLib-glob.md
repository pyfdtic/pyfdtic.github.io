---
title: PyStdLib--glob
date: 2018-03-19 18:28:47
categories:
- Python
tags:
- python 标准库
---
## glob
#### glob.glob()
    import glob
    l = glob.glob("/root/*")    # 返回列表
    print l     # 输出如下
    ['/root/databases',
     '/root/install.log',
     '/root/anaconda-ks.cfg',
     '/root/install',
     '/root/install.log.syslog',
     '/root/requirements.txt',
     '/root/test']