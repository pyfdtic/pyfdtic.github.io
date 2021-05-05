---
title: docker 内部组件结构 docker daemon, container,runC
date: 2018-03-16 12:53:19
categories:
- 容器
tags:
- docker
- docker daemon
- runc
---
Docker, Containerd, RunC :
从 Docker 1.11 开始, docker 容器运行已经不是简单地通过 Docker Daemon 来启动, 而是集成了Container, RunC 等多个组件.

Docker 服务启动之后, 可以看到系统上启动了 Docker, Docker-container 等进程. 以下介绍 docker(1.11 版本之后每个部分的功能和作用.)
### OCI 标准
Linux基金会于2015年6月成立OCI（Open Container Initiative）组织，旨在围绕容器格式和运行时制定一个开放的工业化标准。该组织一成立便得到了包括谷歌、微软、亚马逊、华为等一系列云计算厂商的支持。而runC就是Docker贡献出来的，按照该开放容器格式标准（OCF, Open Container Format）制定的一种具体实现。

### docker 模块结构
从Docker 1.11之后，Docker Daemon被分成了多个模块以适应OCI标准。


![docker_mod_arch_oci](/imgs/docker/docker_%E5%86%85%E9%83%A8%E7%BB%84%E4%BB%B6%E7%BB%93%E6%9E%84.png "docker 组件结构图")

### docker daemon : 独立成单独二进制程序.

docker 1.8 之前, 启动会命令:  

    $ docker -d

docker 1.8 之后, 启动命令变成了 :
 
    $ docker daemon

docker 1.11 开始, 启动命令变成了 :

    $ dockerd

### containerd
containerd 是运用 runC（或者任何与 OCI 兼容的程序）来管理容器，通过 gRPC 暴露功能的简易守护进程。相比于 Docker Engine，暴露容器相关的 CRUD 接口使用成熟的 HTTP API，Docker Engine 不仅能暴露容器，还能暴露镜像、数据卷、网络、构建等。

containerd 是容器技术标准化之后的产物, 为了能够兼容 OCI 标准, 将容器运行时及其管理功能从 Docker Daemon 剥离.

理论上, 即使不运行 dockerd 也能直接通过 containerd 来管理容器.(当然, containerd 本身也只是一个守护进程, 容器的实际运行时由 runC 控制.)

container(已开源), 其主要职责是镜像管理(镜像, 元信息等), 容器执行(调用最终运行时组件执行).

container 向上为 docker daemon 提供了 gRPC 接口, 使得 docker daemon 屏蔽下面的结构变化, 确保原有接口向下兼容. 向下通过 container-shim 结合 runC, 使得引起可以独立升级, 避免之前 docker daemon 升级会导致所有容器不可用的问题.(见上面 docker_mod_arch 图)


![docker_mod_arch](/imgs/docker/docker_container%E5%86%85%E9%83%A8%E7%BB%93%E6%9E%84.png "container 结构图")

    docker , container , container-shim 之间的关系, 可以通过启动一个 docekr 容器观察之间的管理.

    ① 启动一个容器:
        $ docker run -d alpine sleep 1000
    ② 查看docker daemon 的pid
        $ ps aux |grep dockerd  # 1480
    ③ 查看进程之间的父子关系
        $ pstree -l -a -A 1480
            dockerd -H fd://
              |-docker-containe -l unix:///var/run/docker/libcontainerd/docker-containerd.sock --shim docker-containerd-shim --metrics-interval=0 --start-timeout 2m --state-dir /var/run/docker/libcontainerd/containerd --runtime docker-runc
              |   |-docker-containe 2b9251bcc7a4484662c8b69174d92b3183f0f09a59264b412f14341ebb759626 /var/run/docker/libcontainerd/2b9251bcc7a4484662c8b69174d92b3183f0f09a59264b412f14341ebb759626 docker-runc
              |   |   |-sleep 1000
              |   |   `-7*[{docker-containe}]
              |   `-9*[{docker-containe}]
              `-11*[{dockerd}]              

        当 docker daemon 启动之后, docker 和 docker-container 进程一直存在.
        当启动容器之后, docker-container 进程(container 组件)会创建 docker-containerd-shim 进程. 其中 2b9251bcc7a4484662c8b69174d92b3183f0f09a59264b412f14341ebb759626 就是要启动容器的 ID, 最后 docker-containerd-shim 子进程, 液晶是在容器中运行的进程(sleep 1000)

        其中 /var/run/docker/libcontainerd/2b9251bcc7a4484662c8b69174d92b3183f0f09a59264b412f14341ebb759626 里面内容有 : 
            /var/run/docker/libcontainerd/2b9251bcc7a4484662c8b69174d92b3183f0f09a59264b412f14341ebb759626
            ├── config.json         # 容器配置
            ├── init-stderr         # 标准错误输出
            ├── init-stdin          # 标准输入
            └── init-stdout         # 标准输出.     

### RunC
unC 是一种只专注于运行容器的轻量级工具。如果你了解 Docker Engine 的早期历史，你就知道它曾经用 LXC 来启动和管理容器；后来它演变为 “libcontainer”。“libcontainer” 是一段与 cgroup 和 namespace 这些 Linux 内核交互的代码，这些内核是容器构建的基石。

简言之，runC 基本上是一种无需进入 Docker Engine，直接控制 libcontainer 的小型命令行工具，是一种管理和运行 OCI 容器的单机二进制.

OCI 定义了容器运行时标准, runC 是 Docker 按照 开放容器格式标准(OCF, Open Container Format) 制定的一种具体实现.

runC 是从 Docker 的 libcontainer 中迁移而来的, 实现了容器启停,资源隔离等功能. Docker 默认提懂了 docekr-runc 实现, 事实上, 通过 containerd 的疯转, 可以在 Docker daemon 启动的时候指定 runC 的实现.

    可以通过在启动 docker daemon 时, 增加 --add-runtime 参数来选择其他的 runC 实现.
        $ docker daemon --add-runtime "custom=/usr/local/bin/my-runc-replacement"

runC 特征 :

    1. 支持所有的Linux namespaces，包括user namespaces。目前user namespaces尚未包含。
    2. 支持Linux系统上原有的所有安全相关的功能，包括Selinux、 Apparmor、seccomp、cgroups、capability drop、pivot_root、 uid/gid dropping等等。目前已完成上述功能的支持。
    3. 支持容器热迁移，通过CRIU技术实现。目前功能已经实现，但是使用起来还会产生问题。
    4. 支持Windows 10 平台上的容器运行，由微软的工程师开发中。目前只支持Linux平台。
    5. 支持Arm、Power、Sparc硬件架构，将由Arm、Intel、Qualcomm、IBM及整个硬件制造商生态圈提供支持。
    6. 计划支持尖端的硬件功能，如DPDK、sr-iov、tpm、secure enclave等等。
    7. 生产环境下的高性能适配优化，由Google工程师基于他们在生产环境下的容器部署经验而贡献。

### example : 通过 docker 一些命令, 实现不使用 docker daemon 直接运行一个镜像.

    ① 创建容器标准包, 由 container 的 bundle 模块实现, 将 docker 镜像转换成容器标准包
        $ mkdir my_container
        $ cd my_container
        $ mkdir rootfs
        $ docker export $(docker create busybox) | tar -C rootfs -xvf -

        上述命令, 将 busybox 镜像解压缩到指定的 rootfs 目录中. 如果本地不存在 busybox 进香港, containerd 会通过 distribution 模块去远程仓库拉取.

    ② 创建配置文件
        $ docker-runc spec

        # 会生成一个 config.json 的配置文件, 该文件和 docker 容器的配置文件类似, 主要包含容器挂载信息, 平台信息, 进程信息等容器启动以来的所有数据.

    ③ 通过 runc 命令来启动容器
        $ apt install runc -y
        $ runc run busybox

### docker-proxy            
docker 的端口转发工具. 实现容器与主机的端口映射.

示例 : 

    $ docker run -itd -p 8008:80008 busybox /bin/sh 
    
    $ ps aux |grep docker       # 注意查看 docker-proxy 的端口对应.

        root       1498  0.0  0.1 234236 12020 ?        Ssl  3月12   4:56 docker-containerd -l unix:///var/run/docker/libcontainerd/docker-containerd.sock --metrics-interval=0 --start-timeout 2m --state-dir /var/run/docker/libcontainerd/containerd --shim docker-containerd-shim --runtime docker-runc

        root      88902  0.0  0.0  34464  2936 ?        Sl   11:21   0:00 /usr/bin/docker-proxy -proto tcp -host-ip 0.0.0.0 -host-port 8008 -container-ip 172.17.0.3 -container-port 8008

        root      88906  0.0  0.0 198748  2920 ?        Sl   11:21   0:00 docker-containerd-shim 695522643fb8a54ea5d7483ca353c95ed91cba3f2e18ce4b2af286bbc6c3412b /var/run/docker/libcontainerd/695522643fb8a54ea5d7483ca353c95ed91cba3f2e18ce4b2af286bbc6c3412b docker-runc

    docker-proxy 命令行

    $ docker-proxy --help
        Usage of docker-proxy:
          -container-ip string
                container ip
          -container-port int
                container port (default -1)
          -host-ip string
                host ip
          -host-port int
                host port (default -1)
          -proto string
                proxy protocol (default "tcp")