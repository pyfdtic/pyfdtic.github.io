---
title: fdisk 非交互式创建分区
date: 2018-03-19 16:03:37
categories:
- 计算机原理与操作系统
tags:
- Linux
- 磁盘管理
- fdisk
---
## 一. key

1. 非交互式创建分区, 与 交互式创建分区区别不大.
2. 使用 fdisk 的默认选项, 使用`空行`即可, 不用回车.
3. 创建 主分区 和 扩展分区时, 需要注意 `分区号`

## 二. 创建主分区

    fdisk /dev/xvdk <<EOF
    n
    p
    1   # 注意分区号


    p
    w
    EOF

## 三. 创建扩展分区

    # make Extended Partition, use all space.
    fdisk /dev/xvdk <<EOF
    n
    e
    4   # 注意分区号


    p
    w
    EOF

## 四. 创建逻辑分区

    # make 5G logical Partition for /tmp
    fdisk /dev/xvdk <<EOF
    n
    l

    +3G
    p
    w
    EOF