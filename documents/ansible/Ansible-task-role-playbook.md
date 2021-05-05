---
title: Ansible task/role/playbook
date: 2018-03-15 15:50:13
categories:
- DevOps
tags:
- ansible
---
使用 Ansible task, role, playbook 定义任务, 实现自动化服务器管理.

<!-- more -->

[Ansible 学习总结](https://pyfdtic.github.io/2018/03/14/Ansible-%E5%AD%A6%E4%B9%A0%E6%80%BB%E7%BB%93/)

## 一. task

### 1. name
可选配置, 用于提示task 的功能. 另, ansible-playbook --start-at-task <task_name> 可以调用 name, 从 task 的中间开始执行.
### 2. 模块(功能) 
必选配置, 有模块的名称组成的 key 和 模块参数组成的 value.  
**从 Ansible 前段所使用的 YAML 解析器角度看, 参数将被按照字符串处理, 而不是字典**

    apt: name=nginx update_cache=yes

### 3. 复杂参数:
    
ansible 提供一个将模块调用分隔成多行的选择, 可以传递 key 为变量名的字典, 而不是传递字符串参数. 这种方式, 在调用拥有复杂参数的模块时, 十分有用. 如 ec2 模块.

    - name: install pip pkgs
      pip:
        name: "{{ item.name }}"
        version: "{{ item.version }}"
        virtualenv: "{{ venv_path }}"
      with_items:
        - {name: mazzanine, version: 3.1.10}
        - {name: gunicorn, version: 19.1.1}

### 4. environment : 设置环境变量
    
传入包含变量名与值的字典, 来设置环境变量.

    - name: set the site id
      script: scripts/setsite.py
      environment:
        PATH: "{{ venv_path }}/bin"
        PROJECT_DIR: "{{ proj_path }}"
        ADMIN_PASS: "{{ admin_pass }}"
    
### 5. sudo, sudo_user
切换到 root 或 其他用户执行 task.
### 6. notify

触发 handler 任务.

### 7. when
    
当 when 表达式返回 True 时, 执行该 task , 否则不执行.

### 8. local_action : 运行本地任务
    
在**控制主机**本机上(而目标主机)执行命令.

**如果目标主机为多台, 那么, local_action 执行的task 将执行多次, 可以指定 run_once , 来限制 local_action 的执行次数.**

```
    # 调用 wait_for 模块 : 注: inventory_hostname 的值仍然是远程主机, 因为这些变量的范围仍然是远程主机, 即使 task 在本机执行.
    - name: wait for ssh server to be running
      local_action: wait_for port=22 host="{{ inventory_hostname }}" search_regex=OpenSSH

    # 调用 command 模块   
    - name: run local cmd
      hosts: all
      gather_facts: False
      tasks:
        - name: run local shell cmd
          local_action: command touch /tmp/new.txtxt
```
### 9. delegate_to: 在涉及主机之外的主机上运行 task
  
使用场景:
- 在报警主机中, 启用基于主机的报警, 如 Nagios
- 向负载均衡器中, 添加一台主机, 如 HAProxy

```bash
    # 配置 Nagios 示例, inventory_hostname 仍然指 web 主机, 而非 nagios_server.example.com .
    - name: enable alerts for web servers
      hosts: web
      tasks:
        - name: enable alerts
          nagios: action=enanle_alerts service=web host={{ inventory_hostname }}
          delegate_to: nagios_server.example.com

    ---
    # This playbook does a rolling update for all webservers serially (one at a time).
    # Change the value of serial: to adjust the number of server to be updated.
    #
    # The three roles that apply to the webserver hosts will be applied: common,
    # base-apache, and web. So any changes to configuration, package updates, etc,
    # will be applied as part of the rolling update process.
    #

    # gather facts from monitoring nodes for iptables rules
    - hosts: monitoring
      tasks: []

    - hosts: webservers
      serial: 1

      # These are the tasks to run before applying updates:
      pre_tasks:
      - name: disable nagios alerts for this host webserver service
        nagios: 'action=disable_alerts host={{ inventory_hostname }} services=webserver'
        delegate_to: "{{ item }}"
        with_items: groups.monitoring

      - name: disable the server in haproxy
        haproxy: 'state=disabled backend=myapplb host={{ inventory_hostname }} socket=/var/lib/haproxy/stats'
        delegate_to: "{{ item }}"
        with_items: groups.lbservers

      roles:
      - common
      - base-apache
      - web

      # These tasks run after the roles:
      post_tasks:
      - name: wait for webserver to come up
        wait_for: 'host={{ inventory_hostname }} port=80 state=started timeout=80'

      - name: enable the server in haproxy
        haproxy: 'state=enabled backend=myapplb host={{ inventory_hostname }} socket=/var/lib/haproxy/stats'
        delegate_to: "{{ item }}"
        with_items: groups.lbservers

      - name: re-enable nagios alerts
        nagios: 'action=enable_alerts host={{ inventory_hostname }} services=webserver'
        delegate_to: "{{ item }}"
        with_items: groups.monitoring
```
### 10. run_once : 值为 True/False
    
该 task 是否只运行一次, 与 `local_action` 配合十分好用.

在生产应用发布时比较有用.

### 11. changed_when & failed_when
    
使用 changed_when 和 failed_when 语句改变 Ansible 对 task 是 chenged 状态还是 failed 状态的认定.
**需要了解命令的输出结果**

    - name: initialize the database
      django_manage:
        command: createdb --noinput --nodata
        app_path: "{{ proj_path }}"
        virtualenv: "{{ venv_path }}"
      register: result
      changed_when: not result.failed and "Creating tables" in result.out
      failed_when: result.failed and "Database already created" not in result.msg

### 12. 循环

| 名称 | 输入 | 循环策略 |
| -- | -- | -- |
| with_items | 列表 | 对列表元素进行循环 |
| with_lines | 要执行的命令 | 对命令输出结果进行逐行循环 |
| with_fileglob | glob | 对文件名进行循环 |
| with_first_found | 路径的列表 | 输入中第一个存在的文件 |
| with_dict | 字典 | 对字典元素进行循环 |
| with_flattened | 列表的列表 | 对所有列表的元素顺序循环 |
| with_indexed_items | 列表 | 单次迭代 |
| with_nested | 列表 | 循环嵌套 |
| with_random_choice | 列表 | 单次迭代 |
| with_sequence | 整数数组 | 对数组进行循环 |
| with_subelements | 字典的列表 | 嵌套循环 |
| with_together | 列表的列表 | 对多个列表并行循环 |
| with_inventory_hostname | 主机匹配模式 | 对匹配的主机进行循环 |

#### 12.1 with_items
with_items 用于对列表中的元素进行循环.

```ansible
- name: Send out a slack message
  user:
    name: "{{ item }}"
    state: present
    groups: "wheel"
  with_items:
    - test1
    - test2
    - test3
```
#### 12.2 with_lines
with_lines 循环结构允许在**控制主机**上执行任意命令, 并对命令的输出进行逐行迭代.

```ansible
- name: Send out a slack message
  slack:
    domain: example.slack.com
    token: "{{ slack_token }}"
    msg: "{{ item }} was in the list"
  with_lines:
    - cat /path/to/name.list
```
#### 12.3 with_fileglob
with_fileglob 结构对于迭代**控制主机**上的一系列文件很有用.

```ansible
- name: add public keys to account
  authorized_key: user=deploy key="{{ lookup('file', item) }}"
  with_fileglob:
    - /var/keys/*.pub
    - keys/*.pub
```
#### 12.4 with_dict
with_dict 可以对字典而不是列表进行迭代. 当使用该结构时, `item` 循环变量是一个`{"key": some_key, "value": some_value}` 结构的字典.

```ansible
# ansibel_eth0
{
  "address": "10.0.2.15",
  "netmask": "255.255.255.0",
  "network": "10.0.2.0"
}

# task
- name: iterate over ansible_eth0
  debug: msg={{ item.key }}={{ item.value }}
  with_dict: ansible_etho.ipv4
```

#### 12.5  with_sequence 以递增的数字顺序生成项序列

```
- hosts: all
  tasks:
    ## 创建组
    - group: name=evens state=present
    - group: name=odds state=present

    ## 创建格式为testuser%02x 的0-32 序列的用户
    - user: name={{ item }} state=present groups=evens
      with_sequence: start=0 end=32 format=testuser%02x

    ## 创建4-16之间得偶数命名的文件
    - file: dest=/var/stuff/{{ item }} state=directory
      with_sequence: start=4 end=16 stride=2

    ## 简单实用序列的方法：创建4 个用户组分表是组group1 group2 group3 group4
    - group: name=group{{ item }} state=present
      with_sequence: count=4
```

#### 12.6 with_random_choice 随机选择

```bash
  - debug: msg={{ item }}
    with_random_choice:
        - "go through the door"
        - "drink from the goblet"
        - "press the red button"
        - "do nothing"

```

### 13. tags

用于为 task 做逻辑区分 或功能区分, 提供对 task 细粒度的执行控制.
**特殊 tags**ansible内置的特殊tags：`always`、`tagged`、`untagged`、`all` 是四个系统内置的tag，有自己的特殊意义
- `always` : 指定这个 tag 后，task任务将**永远被执行**，而不用去考虑是否使用了--skip-tags标记
- `tagged` : 当 `--tags` 指定为它时，则只要有tags标记的task都将被执行,`--skip-tags` 效果相反
- `untagged` : 当 `--tags` 指定为它时，则所有没有tag标记的task 将被执行, `--skip-tags`效果相反
- `all`: 默认tag, 无需指定，ansible-playbook 默认执行的时候就是这个标记.所有task都被执行系统中内置的特殊tags：

## 二. play

play 可以想象为连接到主机(host)上执行任务(task)的事务.

选项:

1. hosts : 必选配置, 需要配置的一组主机

    控制主机执行顺序`order`. 

    `order` 可用参数:
    - `inventory`: 默认参数, 按照 inventory 提供的顺序
    - `reverse_inventory`: 逆序 inventory
    - `sorted`: 按字母大小排序
    - `reverse_sorted`: 按字母大小逆序
    - `shuffle`: 随机

    ```
    - hosts: all
      order: sorted
      gather_facts: False
      tasks:
        - debug: var=inventory_hostname
    ```
2. task : 必选配置, 需要在主机上执行的任务

3. name : 可选配置, 一段注释, 用来描述 play 的功能, ansible 在 play 开始执行的时候, 会把 name 打印出来.

4. sudo : 可选配置, 如果为真, ansible 会在运行每个 task 的时候, 都是用 sudo 命令切换为 (默认) root.

5. vars : 可选配置, 变量与其值组成的列表. 任何合法的 YAML 对象都可以作为变量的值. 变量不仅可以在 tasks 中使用, 还可以在 模板文件 中使用.

6. vars_files : 可选, 把变量放到一个或者多个文件中.

7. gather_facts : 是否收集 fact.

8. handlers : 可选, ansible 提供的 **条件机制**, 和 task 类似, 但只有在被 task 通知的时候才会运行. 如果 ansible 识别到 task 改变了系统的状态, task 就会触发通知机制. task 将 handler 的名字作为参数传递, 依此来通知 handler. 
    
    handler 只会在所有任务执行完成之后执行, 而且即使被通知了多次, 也只会执行一次. handler 按照play 中定义的顺序执行, 而不是被通知的顺序.

    handler 常见的用途就是重启服务和重启服务器.

    ansible verion > 2.2 之后, 支持 将多个 handler task 注册为一个组, 从而支持对改组的操作, 如下面示例中的 `restart web service`

    ```ansible
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
    ```
9. serial, max_fail_percentage
    
    默认情况下, Ansible 会并行的在所有相关联主机上执行每一个 task.

    可以使用 serial 限制并行执行 play 的主机数量.

    一般来说, 当 task 失败时, Ansible 会停止执行失败的那台主机上的任务, 但是继续对其他主机执行.  在负载均衡场景中, 可能希望 Ansible 在所有主机都发生失败前让整个 play 停止执行, 否则将会导致, 所有主机都从 负载均衡器上移除, 并且全部执行失败, 最终负载均衡器上没有任何主机的局面. 此时, 可以使用 serial 和 max_fail_percentage 语句来指定, 最大失败主机比例达**超过** max_fail_percentage 时, 让整个 play 失败. 

    如果希望 Ansible 在任何主机出现 task 执行失败的时候, 都放弃执行, 则需要设置`max_fail_percentage=0`.

        - name: upgrade packages on servers behind load balancer
          hosts: myhosts
          serial: 1
          max_fail_percentage: 25
          tasks:
            - name: get the ec2 instance id and elastic load balancer id
              ec2_facts:

            - name: task the out of the elastic load balancer
              local_action: ec2_elb
              args:
                instance_id: "{{ ansible_ec2_instance_id }}"
                state: absent

            - name: upgrade packages
              apt: update_cache=yes upgrade=yes

            - name: put the host back in the elastic load balancer
              local_action: ec2_elb
              args:
                instance_id: "{{ ansible_ec2_instance_id }}"
                state: present
                ec2_elbs: "{{ item }}"
              with_items: ec2_elbs

10. roles : 指定要执行的 role 名称, 可以添加 tags, 变量等参数.
11. pre-task
12. post-task

## 三. role
role 是将 playbook 分隔为多个文件的主要机制, 他大大简化了复杂 playbook 的编写, 同时使得 role 更加易于复用.

### 1. role 的基本构成.
每个 role 都会用一个名字, 如 'database', 与该 role 相关的文件都放在 roles/database 目录下. 其结构如下: **每个单独文件都是可选的**
- `task`
    task 定义
    `roles/database/tasks/main.yml`
- `files`
    需要上传到目标主机的文件:
    `roles/database/files/`
- `templates`
    Jinja2 模板文件. [Jinja2 Doc](http://docs.jinkan.org/docs/jinja2/templates.html)
    `roles/database/templates`
- `handlers`
    handler
    `roles/database/handler/main.yml`
- `vars`
    不应被覆盖的变量
    `roles/database/vars/main.yml`
- `defaults`
    可以被覆盖的默认变量
    `roles/database/default/main.yml`
- `meta`
    role 的依赖信息
    `roles/database/meta/main.yml`

default 变量与 vars 变量:
- default : 希望在 role 中变更变量的值.
- vars : 不希望变量的值变更.

role 中变量命名的一个良好实践: 变量建议以 role 的名称开头, 因为在 Ansible 中不同的 role 之间没有命名空间概念, 这意味着在其他 role 中定义的变量, 或者再 playbook 中其他地方定义的变量, 可以在任何地方被访问到. 如果在两个不同的 role 中使用了同名的变量, 可能导致意外的行为.

### 2. role 的存放位置
1. playbook 并列的 `roles` 目录下;
2. `/etc/ansible/roles/` 下
3. `ansible.cfg` 中 `default` 段 `roles_path` 指向的位置
4. 环境变量 `ANSIBLE_ROLES_PATH` 指向的位置

### 3. 在 playbook 中使用 role
    
    # mezzaning-single-host.yml
    - name: deploy mezzanine on vagrant
      hosts: web
      vars_file:
        - secrets.yml
      roles:
        - role: database
          database_name: "{{ mezzanine_proj_name }}"        # 定义覆盖变量
          database_pass: "{{ mezzanine_proj_name }}"        # 定义覆盖变量

        - role: mezzanine
          live_hostname: 192.168.33.10.xip.io
          domains:
            - 192.168.33.10.xip.io
            - www.192.168.33.10.xip.io

    # mezzaning-across-host.yml
    - name: deploy postgres vagrant
      hosts: db
      vars_files:
        - secrets.yml
      roles:
        - role: database
          database_name: "{{ mezzanine_proj_name }}"        # 定义覆盖变量
          database_pass: "{{ mezzanine_proj_name }}"        # 定义覆盖变量

    - name: deploy mezzanine on vagrant
      hosts: web
      vars_files:
        - secrets.yml
      roles:
        - role: mezzanine
          database_host: "{{ hostvars.db.ansible_eth1.ipv4.address }}"
          live_hostname: 192.168.33.10.xip.io
          domains:
            - 192.168.33.10.xip.io
            - www.192.168.33.10.xip.io        

### 4. pre-task & post-task
pre-task : 定义在 role 执行之前, 执行的 task
post-task : 定义在 role 执行之后, 执行的 task.

    - name: deploy mezzanine on vagrant
      hosts: web
      vars_files:
        - secrets.yml
      pre_tasks:
        - name: update the apt cache
          apt: update_cache=yes

      roles:
        - role: mezzanine
          database_host: "{{ hostvars.db.ansible_eth1.ipv4.address }}"
          live_hostname: 192.168.33.10.xip.io
          domains:
            - 192.168.33.10.xip.io
            - www.192.168.33.10.xip.io 
      
      post_tasks:
        - name: notify Slack that the servers have been updated
          local_action:>
            slack
            domain=acme.slack.com
            token={{ slack_token }}
            msg="web server {{ inventory_hostname }} configured"

### 5. inclued 
用于调用位于同一目录下的其他 定义文件, 可用于 Tasks,Playbook, Vars, Handler, Files 等.
    
    # task example
    ---
    - name: install apt packages
      apt: pkg={{ item }} update_cache=yes cache_valid_time=3600
      sudo: True
      with_items:
        - git
        - libjpeg-dev
        - libpq-dev
        - memcached
        - nginx

    - include: django.yml
    - include: nginx.yml

    # example 2
    ---
    - name: check host environment
      include: check_environment.yml

    - name: include OS family/distribution specific variables
      include_vars: "{{ item }}"
      with_first_found:
        - "../defaults/{{ ansible_distribution | lower }}-{{ ansible_distribution_version | lower }}.yml"
        - "../defaults/{{ ansible_distribution | lower }}.yml"
        - "../defaults/{{ ansible_os_family | lower }}.yml"

    - name: debug variables
      include: debug.yml
      tags:
        - debug    

### 6. ansible-galaxy : 创建 role 初始文件和目录
1. 创建初始 role 文件和目录

        $ ansible-galaxy init -p playbook/roles web
            -p /path/to/roles : 指定 roles 的目录, 未指定则为当前目录.

2. 从 role 仓库中检索, 安装,删除 role.
    `ansible-galaxy [delete|import|info|init|install|list|login|remove|search|setup] [--help] [options]`

    - 检索
            $ ansible-galaxy search ntp

    - 安装

            $ ansible-galaxy install -p ./roles bennojoy.ntp

    - 列出

            $ ansible-galaxy list
    - 删除

            $ ansible-galaxy remove bennojoy.ntp

3. [在线网站 https://galaxy.ansible.com](https://galaxy.ansible.com)

### 7. dependent role:
dependent role 用于指定 role 依赖的其他一个或多个 role, Ansible 会确保被指定依赖的role 一定会优先被执行.

Ansible 允许向 dependent role 传递参数

dependent role 一般在 myrole/meta/main.yml 中指定.
    
    # roles/web/meta/main.yml
    dependencies:
      - { role: ntp, ntp_server=ntp.ubuntu.com }
      - { role: common }
      - { role: memcached }

## 四. playbook : 用于实现 ansible 配置管理的脚本.

playbook 其实就是一个字典组成的列表. 一个 playbook 就是一组 play 组成的列表. 一个 play 由 host 的无序集合与 task 的有序列表组成. 每一个 task 由一个模块构成.

![playbook实体关系图](http://oluv2yxz6.bkt.clouddn.com/ansible%E5%AE%9E%E4%BD%93%E5%85%B3%E7%B3%BB%E5%9B%BE.PNG)


**ansible 中的 True/False 和 yes/no**
模块参数(如 update_cache=yes)对于值的处理, 使用字符串传递:
- 真值
        
        yes,on,1,true
- 假值

        no,off,0,false

其他使用 YAML 解析器来处理:

- 真值
    
        true,True,TRUE,yes,Yes,YES,on,On,ON,y,Y
- 假值
        
        false,False,FALSE,no,No,NO,off,Off,OFF,n,N

推荐做法:

- 模块参数: yes/no
- 其他地方: True,False


playbook 文件的执行方法:
1. 使用 ansible-playbook 命令
    
        $ ansible-playbook myplaybook.yml

2. shebang
        
        $ chmod +x myplaybook.yml
        $ head -n 1 myplaybook.yml
          #!/usr/bin/env ansible-playbook
        $ ./myplaybook.yml


当 Ansible 开始运行 playbook 的时候, 他做的第一件事就是从他连接到的服务器上收集各种信息. 这些信息包括操作系统,主机名,网络接口等.

### 建立 nginx web 服务器
    
    $ cat web-notls.yml
    - name: Configure webserver with nginx and tls
      hosts: webservers
      sudo: true
      vars:
        key_file: /etc/nginx/ssl/nginx.key
        cert_file: /etc/nginx/ssl/nginx.crt
        conf_file: /etc/nginx/sites-available/default
        server_name: localhost
      tasks:
        - name: install nginx
          apt: name=nginx update_cache=yes cache_valid_time=3600

        - name: create directories for ssl certificates
          file: path=/etc/nginx/ssl state=directory

        - name: copy TLS key
          copy: src=files/nginx.key desc={{ key_file }} owner=root mode=06--
          notify: restart nginx

        - name: copy TLS certificate
          copy: src=files/nginx.crt dest={{ cert_file }}
          notify: restart nginx

        - name: copy nginx config file
          copy: src=files/nginx.conf.j2 dest={{ conf_file }}
          notify: restart nginx
        
        - name: enable configuration
          file: dest=/etc/nginx/sites-enabled/default src={{ conf_file }} state=link
          notify: restart nginx
        
        - name: copy index.html
          template: src=templates/index.html.j2 dest=/usr/share/nginx/html/index.html mode=0644

      handlers:
        - name: restart nginx
          service: name=nginx state=restarted

### 内部变量
- ansible_managed : 和模板文件生成时间相关的信息.

### inventory 文件
使用 .ini 格式, 默认为 hosts 文件.
    
    [webservers]
    testserver ansible_ssh_host=127.0.0.1 ansible_ssh_port=22

### YAML 文件格式
- 文件开始.
        
        ---

    如果没有`---`标记, 也不影响 ansible 的运行.

- 注释: `#`
- 字符串 : 即使字符串中有空格, 也无需使用引号.
- 布尔型 : 有多种, 推荐使用 `True/False`
- 列表: 使用`-`作为分隔符
    
    1. 标准列表

            - My Fair Lady
            - Oklahoma
            - The Pirates of Penzance
    2. 内联式列表

            [My Fair Lady, Oklahoma, The Pirates of Penzance]
- 字典: 
    
    1. 标准字典

            name: tom
            age: 12
            job: manager
    2. 内联式字典

            {name: tom, age: 12, job: manager}

- 折行: 使用大于号(>)表示折行
- 支持变量引用:

        admin_name: "amdin"
        admin_email: "{{ admin_name }}@example.com"