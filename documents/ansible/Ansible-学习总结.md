---
title: Ansible-学习总结
date: 2018-03-14 23:31:01
categories:
- DevOps
tags:
- ansible
- PyPi
---
## [Ansible 原理配置篇](/documents/ansible/Ansible-%E5%9F%BA%E6%9C%AC%E5%8E%9F%E7%90%86%E4%B8%8E%E5%AE%89%E8%A3%85%E9%85%8D%E7%BD%AE)
1. Ansible 简介
2. Ansible 任务的执行细节原理
2.1 角色与依赖:
2.2 工作机制
2.3 工作原理
3. 安装配置
3.1 安装
3.2 配置文件
4. Ansible 抽象实体
4.1 inventory
4.2 变量与fact
4.3 模块
4.4 task/play/role/playbook
5. Ansible 命令
5.1 ansible
5.2 ansible-doc
5.3 ansible-galaxy
5.4 ansible-vault
5.5 ansible-playbook
6. ansible 优化加速
6.1 SSH Multiplexing (ControlPersist)
6.2 fact 缓存
6.3 pipeline
6.4 并发

## [Ansible Inventory篇](/documents/ansible/Ansible-Inventory)
1. 静态 Inventory
1.1 inventory 行为参数
1.2 ansible.cfg 设置 Inventory 行为参数默认值
1.3 群组
1.4 主机与群组变量
2. 动态 inventory
2.1 动态 inventory 脚本的接口
2.2 在运行时添加主机或群组: add_host, group_by
2.3 ec2.py & ec2.ini
3. 静态 Inventory 与 动态 Inventory 结合使用

## [Ansible task/play/role篇](/documents/ansible/Ansible-task-role-playbook)
- task
- play
- role

## [Ansible api 开发篇](/documents/ansible/Ansible-API)

## [Ansible 番外篇之 ansible.cfg 配置](/documents/ansible/Ansible-%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B6)

1. defaults 段
2. ssh_connection 段
3. paramiko 段
4. accelerate 段 (不推荐使用)

## [Ansible 番外篇之模块](/documents/ansible/Ansible-%E6%A8%A1%E5%9D%97)
1. 内置模块
1.1 查看模块帮助
1.2 查找第三方模块
1.3 常用模块
2. 自定义模块
2.1 使用 script 自定义 模块
2.2 使用 Python 自定义模块.

## [Ansible 番外篇之变量与fact](/documents/ansible/Ansible-%E5%8F%98%E9%87%8F)
1. 变量
1.1. 定义变量
1.2. 显示变量: debug 模块
1.3. register 注册变量: 基于 task 的执行结果, 设置变量的值.
1.4. set_fact 定义新变量
1.5. 内置变量
1.6. 在命令行设置变量
2. fact
2.1. setup 模块
2.2. 模块返回 fact
2.3. 本地 fact
3. 变量优先级:
4. 过滤器: 变量加工处理
4.1. default : 设置默认值.
4.2. 用于注册变量的过滤器
4.3. 用于文件路径的过滤器
4.4. 自定义过滤器
5. lookup: 从多种来源读取配置数据.

    - file
    - pipe
    - env
    - password
    - template
    - csvfile
    - dnstxt
    - redis-kv
    - etcd

## [Ansible 番外篇之流程控制](/documents/ansible/Ansible-%E6%B5%81%E7%A8%8B%E6%8E%A7%E5%88%B6)
假如 ansible 是一门开发语言.
- 循环
- 条件
- 函数 与 role