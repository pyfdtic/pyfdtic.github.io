---
title: linux tcp_wrapper
date: 2018-03-16 17:22:42
categories:
- 计算机原理与操作系统
tags:
- Linux
---
# 一. 简介
tcp_wrapper：tcp包装器, 工作于库中的.
- 访问控制 工具/组件 : 传输层 和 接近于应用层;
- 仅对使用tcp协议且在开发时调用了libwrap相关的服务程序有效.

# 二. 判断服务是否能够由tcp_wrapper进行访问控制：

- 动态编译：ldd命 令查看其链接至的库文件即可；
 
        $ ldd `which sshd` | grep libwrap 

- 静态编译：strings 命令查看其结果中是否包含

        hosts.allow
        hosts.deny

# 三. 配置文件

tcp_wrapper通过读取配置文件中的访问控制规则来判断某服务是否可被访问

    hosts.allow : 先检查, 匹配放行, 则放行; 没有匹配规则, 则使用 hosts.deny
    hosts.deny  : 后检测. 有匹配则拒绝, 没有匹配则, 放行.

**注意**
- 默认规则 是放行.
- 发生修改后立即生效.
- 白名单:

        hosts.allow 放行 白名单.
        hosts.deny 拒绝所有.


# 四. 配置文件语法：

    daemon_list: client_list [:options]

        daemon_list ：
            应用程序的文件名称，而非服务名；
            应用程序的文件列表，使用逗号分隔；
                例如：vsftpd, in.telnetd: 172.16.0.0/255.255.0.0
            ALL: 所有受tcp_wrapper控制的应用程序；

        client_list:
            IP地址 ；
            主机名 ；
            
            网络地址 ：必须使用完整格式掩码，不能使用长度格式的掩码；所以172.16.0.0/16是不合法的；
            简短格式的网络地址 ：172.16. 表示172.16.0.0/255.255.0.0

            ALL : 所有客户端地址；
            
            KNOWN : 所有已知的主机, 即主机名可以被解析的.
            UNKNOWN ：主机名不能被解析的
            PARANOID : 正向解析和反向解析不一致的主机.

        特殊的变量 ：EXCEPT
            in.telnetd: 172.16. EXCEPT 172.16.100.3

        [:options]
            deny: 用于在hosts.allow文件中实现拒绝访问的规则
            allow：用于在hosts.deny文件中实现允许访问的规则
            spawn: 启动一个额外程序；
                in.telnetd: ALL: spawn /bin/echo `date` login attempt from %c to %s, %d >> /var/log/telnet.log  # man hosts.allow

**示例** 
控制vsftpd仅允许172.16.0.0/255.255.0.0网络中的主机访问，但172.16.100.3除外；对所被被拒绝的访问尝试都记录在/var/log/tcp_wrapper.log日志文件中；

    $ cat hosts.allow:
        vsftpd: 172.16. EXCEPT 172.16.100.3

    $ cat hosts.deny: 
        vsftpd: ALL : spawn /bin/echo       # 并非所有都会记录. 如 172.16.100.3