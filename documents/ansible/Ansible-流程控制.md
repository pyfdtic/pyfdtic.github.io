---
title: Ansible-流程控制
date: 2018-03-15 15:45:29
categories:
- DevOps
tags:
- ansible
---

Ansible 本身除了配置管理工具外, 也可以说是一门配置管理语言.
## 一. 顺序执行
`serial, max_fail_percentage`

## 二. 循环
各种 `with_*` 循环

Ansible 总是使用 **item** 作为 循环迭代变量的名字.

循环结构汇总: [官方文档](http://docs.ansible.com/ansible/latest/playbooks_loops.html)

## 三. 条件
when : 当 when 表达式返回 True 时, 执行该 Task , 否则跳过该 Task.
changed_when : 
faild_when : 
notify & handlers 触发器 : handler 定义的行为只有在 task 执行结束之后才会被触发, 并且只会被触发一次, 即使被多个 task 触发.

    当 ansible 版本大于 2.2 时, 多个 handlers 可以定义为一个 topic, 方便一次触发多个 handlers, 同时将 名称和 handlers 解耦.

        handlers:
        - name: restart memcached
            service: name=memcached state=restarted
            listen: "restart web services"
        - name: restart apache
            service: name=apache state=restarted
            listen: "restart web service"

        tasks:
        - name: restart everything
            command: echo "this task will restart web service"
            notify: "restart web service"

    handlers 的 name 和 listen 的 topic 是位于全局名称空间的.
run_once : 

## 四. role
类似 其他编程语言中的 函数或类, 可以实现复用. 

