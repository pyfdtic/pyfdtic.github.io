---
title: Ansible-Inventory
date: 2018-03-15 15:42:58
categories:
- DevOps
tags:
- ansible
---

[Ansible 学习总结](https://pyfdtic.github.io/2018/03/14/Ansible-%E5%AD%A6%E4%B9%A0%E6%80%BB%E7%BB%93/)

**inventory** : Ansible 可管理主机的集合.

## 一. 静态 Inventory
### 1. inventory 行为参数

示例 : 

    [targets]
    localhost              ansible_connection=local
    other1.example.com     ansible_connection=ssh        ansible_ssh_user=mpdehaan   ansible_ssh_pass=123456
    other2.example.com     ansible_connection=ssh        ansible_ssh_user=mdehaan   ansible_ssh_pass=123456

| 名称 | 默认值 | 说明 |
| --- | --- | --- |
| ansible_ssh_host | 主机的名字 |    ssh 目的主机的主机名或IP |
| ansible_ssh_port |22 |ssh 默认端口号|
| ansible_ssh_user  |  root   | ssh 登录使用的用户名|
| ansible_ssh_pass   | none  |  ssh 认证使用的密码(这种方式并不安全,我们强烈建议使用 --ask-pass 或 SSH 密钥)|
| ansible_sudo_pass  | none | sudo 密码(这种方式并不安全,我们强烈建议使用 --ask-sudo-pass) |
| ansible_sudo_exe (new in version 1.8) | none | sudo 命令路径(适用于1.8及以上版本) |
| ansible_connection  | smart   | Ansible 使用何种连接模式连接到目标主机 . 与主机的连接类型.比如:local, ssh 或者 paramiko. Ansible 1.2 以前默认使用 paramiko. 1.2 以后默认使用 'smart','smart' 方式会根据是否支持 ControlPersist, 来判断'ssh' 方式是否可行.|
| ansible_ssh_private_key_file | none | SSH 认证使用的私钥 | 
| ansible_shell_type | sh | 命令所使用的 shell, 除了 sh 外, 还支持 csh,fish,powershell |
| ansible_python_interpreter | /usr/bin/python | 目标主机上的 python 解释器 |
| ansible_*_interperter | none | 与 ansible_python_interpreter 的工作方式相同,可设定如 ruby 或 perl 的路径.... |

### 2. ansible.cfg 设置 Inventory 行为参数默认值

可以在 `[defaults]` 中改变一些行为参数的默认值:

| inventory 行为参数 | ansible.cfg 选项 |
| --- | --- |
| ansible_ssh_port | remote_port |
| ansible_ssh_user | remote_user |
| ansible_ssh_private_key_file | private_key_file |
| ansible_shell_type, shell 的名称 | executable, shell 的绝对路径 |

### 3. 群组
1. all 群组

        ansible 自动定义了一个群组为 `all` 或 `*` , 包括 inventory 中的所有主机.

2. 群组嵌套
    
        [django:children]
        web
        mysql

3. 模式匹配的主机

    **正则表达式永远以 ~ 开头**

    | 匹配行为 | 用法示例 |
    | --- | --- |
    | 所有主机 | `all` |
    | 所有主机 | `*` |
    | 群组的并集 | `dev:staging` |
    | 群组的交集 | `dev:&staging` |
    | 排除 | `dev:!staging` |
    | 通配符 | `*.example.com` |
    | 数字范围 | `web[1:20].example.com`,`web[01:20].example.com` |
    | 字母范围 | `web-[a-z].example.com` |
    | 正则表达式 | `~web\d\.example\.(com` |
    | 多种模式匹配组合使用 | `hosts: dev:staging:&database:!queue` | 

4. 限制某些主机执行: `-l` 或 `--limit` 只针对限定的主机运行.
    
        $ ansible-playbook -l hosts playbook.yml
        $ ansible-playbook --limit hosts playbook.yml

        # 使用模式匹配语法
        $ ansible-playbook -l 'staging:&database' playbook.yml


### 4. 主机与群组变量
1. 主机变量, 在 inventory 文件中: 
    
        a.example.com color=red
        b.example.com color=green

2. 群组变量, 在 inventory 文件中: 
        
        [all:vars]
        ntp_server=ntp.ubuntu.com

        [prod:vars]
        db_primary_host=prod.db.com
        db_primary_port=5432
        db_replica_host=rep.db.com
        db_name=mydb
        db_user=root
        db_pass=123456

        [staging:vars]
        ...

3. 主机变量和群组变量: 在各自的文件中
        
    可以为每个主机和群组创建独立的变量文件. ansible 使用 YAML 格式来解析这些变量文件.

    `host_vars 目录` : 主机变量文件
    `group_vars 目录` : 群组变量文件

    ansible 假设这些目录在包含 playbook 的目录下 或者与 inventory 文件相邻的目录下.

    键值格式 :

        # playbooks/group_vars/production
        db_primary_host: prod.db.com
        db_primary_port: 5432
        db_replica_host: rep.db.com
        db_name: mydb
        db_user: root
        db_pass: 123456

        # 访问方法:
        {{ db_primary_host }}

    字典格式 : 

        # playbooks/group_vars/production
        db:
            user: root
            password: 123456
            name: mydb
            primary:
                host: primary.db.com
                port: 5432
            replica:
                host: replica.db.com
                port: 5432
        rabbitmq:
            host: rabbit.example.com
            port: 6379

        # 访问方法
        {{ db.primary.host }}

    将 group_vars/production/ 定义为目录, 将多个包含变量定义的 YAML 文件存放其中;

        # group_vars/production/db
        db:
            user: root
            password: 123456
            name: mydb
            primary:
                host: primary.db.com
                port: 5432
            replica:
                host: replica.db.com
                port: 5432

        # group_vars/production/rebbitmq
        rabbitmq:
            host: rabbit.example.com
            port: 6379      

## 二. 动态 inventory 
如果 inventory 文件标记为可执行, 那么 Ansible 会假设这是一个动态 inventory 脚本, 并且会执行他, 而不是读取他的内容.

### 1. 动态 inventory 脚本的接口
    
    --list : 列出所有群组. 输出为一个 JSON 对象, 该对象名为群组名, 值为主机的名字组成的数组.

    --host=<host_name> : 输出是一个名为变量名, 值为变量值的 JSON 对象. 包含主机的所有特定变量和行为参数.

### 2. 在运行时添加主机或群组: add_host, group_by
    
- `add_host` : 

    调用方式如下: 当做一个模块使用即可

        # 使用方法:
        add_host  name=hostname groups=web,staging myvar=myval`

        # 示例
        - name: add the vagrant hosts to the inventory
          add_host: name=vagrant ansible_ssh_host=127.0.0.1 ansible_ssh_port=2222 ansible_ssh_user=vagrant

    `add_host` 模块添加主机仅在本次 playbook 执行过程中有效, 他并**不会**修改 inventory 文件.

- `group_by` :

    是一个 模块. 允许在 playbook 执行的时候, 使用 `group_by` 模块创建群组, 他可以基于已经为每台主机自动设定好的变量值(fact)来创建群组, Ansible 将这些变量称为 fact.

        - name: grout hosts by distribution
          hosts: myhosts
          gather_facts: True
          tasks:
            - name: create groups based on Linux distribution
              group_by: key={{ ansible_distribution }}

        - name: do something to CentOS hosts
          hosts: CentOS
          tasks:
            - name: install htop
              yum: name=htop

        - name: do something to Ubuntu hosts
          hosts: Ubuntu
          tasks:
            - name: install htop
              apt: name=htop


### 3. ec2.py & ec2.ini
1. 安装配置

    AWS EC2 External Inventory Script 
    - [ec2.py](https://raw.githubusercontent.com/ansible/ansible/devel/contrib/inventory/ec2.py)  : 动态 Inventory
    - [ec2.ini](https://raw.githubusercontent.com/ansible/ansible/devel/contrib/inventory/ec2.ini) : Inventory 配置文件.

    只支持 Python 2.x

    缓存
    - `\$HOME/.ansible/tmp/ansible-ec2.cache`
    - `\$HOME/.ansible/tmp/ansible-ec2.index`

    缓存过期时间:
    ```
        # ec2.ini
        [ec2]
        cache_max_age = 0   # 默认 300s, 当值为 0 时, 为不使用缓存.

        $ ./ec2.py --refresh-cache      # 强制刷新缓存
    ```

2. 群组
    - 自动生成的群组:
        | 类型 | 示例 | ansible 群组名 |
        | --- | --- | --- |
        | Instance | i-123456 | i-123456 |
        | Instance type | c1.medium | type_c1_medium |
        | Security group | ssh | secutity_group_ssh |
        | Keypair | foo | key_foo |
        | Region | us-east-1 | us-east-1 |
        | Tag | env=staging | tag_env_staging |
        | Availability zone | us-easr-1b | us-easr-1b |
        | VPC | vpc-14dd1b70 | vpc_id_vpc-14dd1b70 |
        | all ec2 instance | N/A | ec2 |

        在群组名中只有字母,连字符,下划线是合法的. 动态 Inventory 脚本会自动将其他的字符(如空格)转换成下划线.如 `Name=My cool name` 变为 `tag_Name_my_cool_server`.

    - 群组操作
        **ec2.py 生成的群组, 支持 Ansible 群组的交集,并集等操作.**
        
        自动生成的群组与 静态 inventory 结合使用:
        假设 ec2.py 生成的群组中有一个从 tag 取名的群组名为 tag_type_web, 则可以在 静态inventory文件中重新定义, 或者组合群组. 必须在 静态 inventory 中定义一个空的名为 tag_type_web 的群组, 如果没有定义, 则ansible 会报错. 示例如下:

            [web:children]
            tag_type_web

            [tag_type_web]

3. 使用方法

        # 简单使用方法       
        $ ansible -i ec2.py -u ubuntu us-east-1 -m ping
        
        # 复杂使用方法.
        $ cp ec2.py /etc/ansible/hosts && chmod +x /etc/ansible/hosts/ec2.py
        $ cp ec2.ini /etc/ansible/ec2.ini 
        
        $ export AWS_ACCESS_KEY_ID='AK123'
        $ export AWS_SECRET_ACCESS_KEY='abc123'

        # just for test, you should see your entire EC2 inventory across all regions in JSON.
        $ ./ec2.py --list [ --profile PROFILE ]  

            --profile : manage multple AWS accounts, 
            a profile example : 

                [profile dev]
                aws_access_key_id = <dev access key>
                aws_secret_access_key = <dev secret key>

                [profile prod]
                aws_access_key_id = <prod access key>
                aws_secret_access_key = <prod secret key>  

            --profile prod, --profile dev

            ec2.ini : is configured for all Amazon cloud services, but you can comment out any features that aren’t applicable.  including cache control and destination variables. 

## 三. 静态 Inventory 与 动态 Inventory 结合使用
配置步骤如下:
1. 将 动态inventory 和 静态inventory 放在同一目录下;
2. 在 ansible.cfg 中将 `hostfile` 的值, 指向该目录即可.