---
title: fpm 制作 rpm 包
date: 2018-03-15 17:24:44
categories:
- 计算机原理与操作系统
tags:
- Linux
- rpm
- fpm
---
使用 fpm 打包 rpm 包.
<!-- more -->

## 一. 使用 fpm 打包 rpm 包

1. 支持的 源类型包

        ① dir       : 将目录打包成所需要的类型, 可用于源码编译安装软件包
        ② rpm       : 对 rpm 包进行转换
        ③ gem       : 对 rubygem 包进行转换
        ④ python    : 将 python 模块打包成响应的类型

2. 支持的 目标类型包

        ① rpm       : 转换为 rpm 包
        ② deb       : 转换为 deb 包
        ③ solaris   : 转换为 solaris 包
        ④ puppet    : 转换为 puppet 模块

3. FPM 安装 及 使用帮助 : FPM 基于 ruby , 需要首先安装 ruby 环境.

        ruby > 1.8.5

        $ yum install ruby rubygems ruby-devel gcc make libffi-devel -y 
        $ yum install rpm-build -y      # fpm 依赖 rpmbuild
        $ gem sources list
        $ gem sources --remove https://rubygems.org/
        $ gem sources --add https://ruby.taobao.org

        $ gem install fpm   # for centos7

        $ gem install json -v 1.8.3  # for centos6
        $ gem install fpm -v 1.3.3   # for centos6

        $ fpm --help
            -s          指定源类型
            -t          指定目标类型，即想要制作为什么包
            -n          指定包的名字
            -v          指定包的版本号
            -C          指定打包的相对路径  Change directory to here before searching forfiles
            -d          指定依赖于哪些包
            -f          第二次打包时目录下如果有同名安装包存在，则覆盖它
            -p          输出的安装包的目录，不想放在当前目录下就需要指定
            --post-install      软件包安装完成之后所要运行的脚本；同--after-install
            --pre-install       软件包安装完成之前所要运行的脚本；同--before-install
            --post-uninstall    软件包卸载完成之后所要运行的脚本；同--after-remove
            --pre-uninstall     软件包卸载完成之前所要运行的脚本；同--before-remove

            --description 

4. 示例: 定制 nginx rpm 包
    
        $ yum -y install pcre-devel openssl-devel libzip
        $ useradd nginx -M -s /sbin/nologin
        $ tar xf nginx_1.10.tar.gz
        
        $ cd nginx_1.10
        $ ./configure --prefix=/opt/nginx --user=nginx --group=nginx --with-http_ssl_module --with-http_stub_status_module
        $ make && make install 
        $ echo "nginx-1.10.2" > /opt/nginx/version

        $ vim /tmp/nginx_rpm.sh
            #!/bin/bash
            useradd nginx -M -s /sbin/nologin
            
        $  fpm -s dir -t rpm -n nginx -v 1.10.2 -d 'pcre-devel,openssl-devel,libzip' --post-install /tmp/nginx_rpm.sh -f /opt/nginx     # 注意此处的 绝对路径.

        $  rpm -qpl nginx-1.6.2-1.x86_64.rpm    # 查看软件包内容.

## 二. 有用的命令.

    $ yum provides *bin/prove
        provides       Find what package provides the given value
        resolvedep     Determine which package provides the given dependency

    $ tar -tvf new.tgz      # 查看包的内容, 不解压包.


    $ make install DESTDIR=/tmp/installdir/ 

    $ getent passwd root    # 查看手否存在用户root
        root:x:0:0:root:/root:/bin/bash

    $ rpm -qp --scripts tengine-2.1.0-1.el6.x86_64.rpm  # 查看 rpm 保存的脚本信息