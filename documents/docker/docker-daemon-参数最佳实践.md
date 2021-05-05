---
title: docker-daemon-参数最佳实践.md
date: 2018-03-16 17:15:59
categories:
- 容器
tags:
- docker
- docker daemon
---
## 一. Docker Daemon 配置参数

1. 限制容器之间网络通信
    在同一台主机上若不限制容器之间通信，容器之间就会暴露些隐私的信息，所以推荐关闭

        docker daemon –icc=false



2. 使用安全模式访问镜像仓库

    Docker Daemon支持安全模式（默认）和非安全模式（–insecure-registry）访问镜像仓库，推荐镜像仓库配置CA证书，Docker Daemon配置安全访问模式，采用TLS安全传输协议；

3. 使用Docker Registry v2版本
    
    v2版本在性能与安全性方面比v1都增强了很多，如安全性上的镜像签名等.

        docker daemon –disable-legacy-registry;

4. 为Docker Daemon配置TLS认证

    推荐指定Docker Daemon的监听IP、端口及unix socket，并配置TLS认证，通过Docker Daemon的IP+端口访问

        –tlsverify
        –tlscacert
        –tlscert
        –tlskey

5. 为Docker Daemon开启用户空间支持
    
    Docker Daemon支持Linux内核的user namespace，为Docker宿主机提供了额外的安全，容器使用有root权限的用户，则这个用户亦拥有其宿主机的root权限，外部可以通过容器反向来操控宿主机，

        docker daemon –userns-remap=default

6. 为Docker Daemon配置默认的CGroup

    某个程序可能会出现占用主机上所有的资源，导致其他程序无法正常运行，或者造成系统假死无法维护，这时候用 cgroups 就可以很好地控制进程的资源占用

        docker daemon –cgroup-parent=/foobar

7. 日志级别
    日志级别设置为info：这样除了debug信息外，可以捕获所有的信息

        docker daemon –iptables=true
8. 为Docker配置集中的远程日志收集系统
    
    Docker支持很多种日志驱动，配置集中的远程日志系统用来存储Docker日志是非常有必要的.

        docker run –log-driver=syslog –log-opt syslog-address=tcp://ip;

    Docker 支持的日志驱动, [官方文档](https://docs.docker.com/engine/admin/logging/overview/#supported-logging-drivers)


| Driver      | Desc  |
| ---         | ---   |  
| none        | No logs will be available for the container and `docker logs` will not return any output. |
| json-file   | The logs are formatted as `JSON`, The default logging driver for docker |
| syslog      | Writes logging messages to the `syslog` facility. The syslog daemon must be running on the host machine.  |
| journald    | Writes log messages to the `journald`. The `journald` daemon must be running on the host machine.  |
| gelf        | Write log messages to the `Graylog Extended Log Format (GELF)` endpoint such as Graylog or Logstash. |
| fluentd     | Write log messages to `fluentd (forward input)`. The fluentd deamon must be running on the host machine. |
| awslogs     | Write log messages to `Amazon CloudWatch Logs`. |
| splunk      | Writes log messages to `splunk` using the HTTP Event Collector. |
| etwlogs     | Wrtites log message as `Event Tracing for Windows (ETW)`. Only available on Windows platforms. |
| gcplogs     | Write log messages to `Google Cloud Platform (GCP)` Logging. |    
    
9. 存储驱动

    推荐使用Overlayfs作为Docker的存储驱动：Docker支持很多种储存驱动，CentOS默认的Docker存储驱动为devicemapper，Ubuntu默认的Docker存储驱动为aufs，


| # | 特点 | 优点 | 缺点 | 适用场景 |
| --- | --- | --- | --- | --- |
| Aufs | 联合文件系统, 未并入内核主线文件级存储 | 作为 docker 的第一个存储驱动, 历史较久, 比较稳定,且在生产中大量实践过, 有较强的社区支持 | 有很多层, 在做写时复制操作时, 如果文件比较大,且存在比较低的层, 可能会慢一些 | 大并发但少IO 的场景 |
| OverlayFS | 联合文件系统, 并入内核主线文件级存储 | 只有两层 | 不管修改的内容大小都会复制整个文件, 对大文件进行修改显示比小文件要消耗更多的时间 | 大并发但少IO的场景 | 
| DeviceMapper | 并入内核主线文件级存储 | 块级别, 无论是大文件还是小文件都只复制需要修改的块, 而不是整个文件 | 支持共享存储, 表示当有多个容器读同一个文件时, 需要生成多个复本, 在很多容器启停的情况下, 可能会导致磁盘溢出 | 适合IO密集的场景 |
| Btrfs | 并入内核主线文件级存储 | 可以向 DeviceMapper 直接操作底层设备, 支持动态添加设备 | 不支持共享存储, 表示当有多个容器读同一个文件时, 需要生成多个复本 | 不适合在高密度容器的 PaaS 平台上使用 | 
| ZFS | 把所有设备集中到奥一个存储池中来进行管理 | 支持多个容器共享一个缓存块, 适合内存大的场景 | COW 使碎片化问题更加严重, 文件在硬件上的物理地址变得不再连续, 顺序读会变得性能比较差 | 适合 PassS 和 高密度场景 |

## 二. Docker Daemon权限
Docker Daemon相关文件和目录的属性及其权限关系到整个Docker运行时的安全.
设置Docker Daemon一些相关配置文件的属性及其权限
        
| 配置文件 | 属性设置 | 权限设置 | 备注信息 |
| --- | --- | --- | --- |
| docker.service | root:root | 644 | |
| docker.sock | root:root |  660 | |
| docker.json | root:root |  644 | |
| docker | root:root |  644 | |
| TLS CA certificate | root:root |  444 | 通过 --tlscacert 参数传递生成的文件属性 |
| Docker server certificate | root:root |  444 | 通过 --tlscert 参数传递生成的文件属性 |
| Docker server certificate key | root:root |  400 | 通过 --tlskey 参数传递生成的文件属性 |
| /etc/docker | root:root |  755 | 容器认证及key信息 |
| /etc/docker/certs.d/ | root:root |  444 | registry 证书相关的文件 |