---
title: csvn 安装记录
date: 2018-03-19 16:12:04
categories:
- Tools
tags:
- svn
- csvn
- 代码管理
---

## 1. 安装步骤如下
    
    # 确保 java 已安装
    $ java -version
    $ echo $JAVA_HOME
    
    # 解压二进制包
    $ tar xf CollabNetSubversionEdge-5.2.0_linux-x86_64.tar.gz -C /usr/local
    
    # Install the application so that it will start antomatically when the server restarts. This command generally requires root/sudo to execute.
    # 安装 csvn, 使用 csvn 提供的安装工具.
    $ cd csvn
    $ sudo -E bin/csvn install  # this will write JAVA_HOME and username to the file  data/conf/csvn.conf . you can change it bu setting the JAVA_HOME and RUN_AS_USER variables in the file.

## 四. start the server. be sure that you are logged in as your own userid and not running as root.
    
    # 启动 csvn 服务, 确保使用 非root 用户启动.
    $ bin/csvn start

    $ bin/csvn console  # start the server and output the initial startup msg to the console. 

    # you must login to the web-based management consoel and configure the Apache server before it can be run for the  first time.
        URL : http://localhost:3343/csvn
        SSL : https://localhost:4434/csvn   # you can force the user to use it.
        user: admin
        pass: admin

    # 启动 csvn 的 apache 子服务
    # Configure the Apache Subversion server to start automatically when the system boots.
    $ cd csvn
    $ sudo bin/csvn-httpd install

    **you should config the Apache Server on the web-UI before this step.**


## 2. 更新.
    
    csvn 用于内置的自动发现更新及自动更新机制, 用户必须使用该机制更新 csvn 程序, 切忌自主下载和安装更新新版本 csvn 程序
        
    csvn 更新机制, 需要重启 csvn 服务器, 无需手动重启, csvn 将自动重启.
    
## 3. 其他资源

### 1) doc : 
    http://help.collab.net/

### 2) download_page :
    https://www.collab.net/downloads/subversion#tab-1   # you have to register first.

### 3) auto start 

    $ chkconfig csvn on
    $ chkconfig svnserve on

### 4) command line help

    $bin/csvn --help

    Usage: bin/csvn [ console | start | stop | restart | condrestart | status | install | remove | dump ]

    Commands:
      console      Launch in the current console.
      start        Start in the background as a daemon process.
      stop         Stop if running as a daemon or in another console.
      restart      Stop if running and then start.
      condrestart  Restart only if already running.
      status       Query the current status.
      install      Install to start automatically when system boots.
      remove       Uninstall.
      dump         Request a Java thread dump if running.
