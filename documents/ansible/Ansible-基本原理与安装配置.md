---
title: Ansible-基本原理与安装配置
date: 2018-03-15 15:51:53
categories:
- DevOps
tags:
- ansible
---
Ansible 基本原理, 安装配置与命令行工具的使用.
<!-- more -->

[Ansible 学习总结](https://pyfdtic.github.io/2018/03/14/Ansible-%E5%AD%A6%E4%B9%A0%E6%80%BB%E7%BB%93/)

## 一. Ansible 简介
Ansible 是使用 Python 开发的, 基于 SSH 协议的, Agentless 的配置管理工具. 其源代码存放于 githb 上, 分隔成 三部分 分别存放在不同的代码仓库上.

- 主仓库 : https://github.com/ansible/ansible
- 核心模块 : https://github.com/ansible/ansible-modules-core
- 其他模块 : https://github.com/ansible/ansible-modules-extras

### 1. 架构

核心引擎： Ansible 核心

核心模块（Core Module）：和大多数运维工具一样，将系统和应用提供的能力模块化，一个模块有点像编程中一个功能接口，要使用的时候调用接口并传参就可以了。比如Ansible的service模块，你要保证名为nginx的service处于启动状态，只需要调用service模块，并配置参数name: nginx，state: started即可。

自定义模块（Custom Modules）:显而易见，如果Ansible的核心模块满足不了你的需求，你可以添加自定义化的模块。

插件（Plugins）：模块功能的补充，如循环插件、变量插件、过滤插件等，也和模块一样支持自定义，这个功能不常用（我没用到过），就不做细说了。

剧本（playbooks）：说到这个，先说说Ansible完成任务的两种方式，一种是Ad-Hoc，就是ansible命令，另一种就是Ansible-playbook，也就是ansible-playbook命令。他们的区别就像是Command命令行和Shell Scripts。 

连接插件（connectior plugins）:Ansible默认是基于SSH连接到目标机器上执行操作的。但是同样的Ansible支持不同的连接方法，要是这样的话就需要连接插件来帮助我们完成连接了。

主机清单（host inventory）:为Ansible定义了管理主机的策略。一般小型环境下我们只需要在host文件中写入主机的IP地址即可，但是到了中大型环境我们有可能需要使用动态主机清单来生成我们所需要执行的目标主机（需要云环境支持动态生成Ansible host inventory）。
### 2. task 执行逻辑
每个 playbook 包含多个 task. 每个 task 按次序在所有匹配主机执行, 当所有主机执行完当前 task 之后, 则执行下一个 task.

当某台主机在 playbook 中的某个 task 执行失败之后, 该 playbook 的剩余 task 将不会再在该主机执行, 因此, 可以在修正之后, 重新在该主机执行 playbook.

模块应该是**幂等性**的, 多次执行的结果应该是相同的. 幂等性的其中一种实现方式时: 提供一个用于检查的模块, 判断模块的执行对象是否达到需要实现的状态, 如果达到状态, 则跳过 task 的执行.

command 和 shell 模块在执行某些操作时可能是非幂等性的, 因此, 可以使用 `creates` 标志辅助实现幂等性.

## 二. Ansible 任务的执行细节原理

### 1. 角色与依赖:
- 被管理主机 : 需要 ssh 和 python2.5 或者更高版本.
- 管理主机 : 需要 Python2.6 或者更高的版本.
- 有些模块需要额外的依赖, 如 ec2模块 依赖 boto模块, docker 模块依赖 docker-py 等.

### 2. 工作机制
Ansible 默认采用**推送模式**, 但是也支持 拉取模式, 使用 `ansible-pull` 命令.

### 3. 工作原理
示例代码:

    - name: install nginx
      apt: name=nginx

ansible 操作如下:
1. 在管理主机生成安装 nginx 软件包的 python 程序
2. 将该程序复制到 目标服务器.
3. 在目标服务器上完成操作, 执行 程序
4. 等待改程序在所有主机上完成.

ansible 执行模块指令的注意事项:
1. 对于每一个任务, ansible 都是并行执行的.
2. 在开始下一个任务之前, ansible 会等待所有主机都完成上一个任务.
3. ansible 任务的执行顺序, 为管理员定义的执行顺序.
4. 幂等性

## 三. 安装配置

### 1. 安装
```bash
$ yum install python-pip
$ pip install ansible
```
### 2. 配置文件
- 配置段
    
    ansible.cfg 有 defaults, ssh_connection, paramiko, accelerate 四个配置段, 其具体配置项见[ansible 番外篇之 ansible.cfg 配置参数](http://www.cnblogs.com/yanjingnan/p/7241888.html)

- 配置文件及优先级

    ansible 配置文件 : ansible.cfg, ansible 使用如下位置和顺序来查找 ansible.cfg 文件
    - ANSIBLE_CONFIG 环境变量指向的文件
    - ./ansible.cfg 
    - ~/.ansible.cfg
    - /etc/ansible/ansible.cfg

- 基础示例:
    
        [defaults]
        hostfile = hosts
        remote_user = ec2-user
        private_key_file = /path/to/my_private_key
        host_key_checking = False                   # 关闭 host key 检查.


## 四 Ansible 抽象实体
### 1. [inventory]()
    
Ansible 执行的目标主机的配置文件. 

Ansible 支持静态 Inventory 文件 和 动态 Inventory , 默认的 静态 Inventory 文件为 `/etc/ansible/hosts`, 同时支持 Cobbler Inventory , AWS ec2.py 等动态 Inventory.

### 2. 变量与fact
    
Ansible 支持如下变量类型及定义, 可以提高 task 的可复用性和适用性:
- 自定义变量
- 注册变量
- 内置变量
- fact 变量

### 3. 模块

模块定义 Ansible 可以在目标主机执行的具体操作, 是由 Ansible 包装好后在这几上执行一系列操作的脚本, 是 Ansible 执行操作的最小粒度.
Ansible 支持如下模块类型: 
- 内置模块
- 自定义模块: 支持多种编程语言, 如 shell, python, ruby 等.

### 4. task/play/role/playbook
    
![playbook实体关系图](/imgs/ansible/ansible实体关系图.PNG)

- task : 由模块定义的具体操作.
- play : 多个包含 host, task 等多个字段部分的任务定义集合. 是一个 YAML 字典结构.
- playbook : 多个 play 组成的列表
- role : 是将 playbook 分割为多个文件的主要机制, 用于简化 playbook 的编写, 并提高 playbook 的复用性.

## 五 Ansible 命令行

### 1. ansible

```bash
$ ansible -i INVENTORY HOST_GROUP [ -s ] -m MODEL -a ARGS [-vvvv]
    -i INVENTORY : 指定 INVENTORY 
    -s : sudo 为 root 执行
    -m MODEL : 模块
    -a ARGS : 模块参数
    -vvvv : 输出详细信息.

# 检测是否可以连接到服务器.
$ ansible testserver -i hosts -m ping [-vvvv]

# 查看服务器运行时间
$ ansible testserver -i hosts -m command -a uptime

# 参数中包含空格, 应该使用 引号 引起来.
$ ansible testserver -i hosts -m command -a "tail /var/log/messages"

# 安装 nginx 包
$ ansible testserver -s -m apt -a name=nginx

# 重启 nginx 服务
$ ansible testserver -s -m service -a name=nginx state=restarted
```

### 2. ansible-doc
Ansible 模块的帮助文档.

```bash
# 列出所有可用模块
$ ansible-doc --list 

# 查看指定 模块的帮助
$ ansible-doc MOD_NAME

# 查看模块的示例
$ ansible-doc MOD_NAME -s

```
### 3. ansible-galaxy
ansible-galaxy : 创建 role 初始文件和目录

#### 3.1 创建初始 role 文件和目录

    $ ansible-galaxy init -p playbook/roles web
        -p /path/to/roles : 指定 roles 的目录, 未指定则为当前目录.

#### 3.2 从 role 仓库中检索, 安装,删除 role.
``` bash
    ansible-galaxy [delete|import|info|init|install|list|login|remove|search|setup] [--help] [options]

    # 检索
    $ ansible-galaxy search ntp

    # 安装
    $ ansible-galaxy install -p ./roles bennojoy.ntp

    # 列出
    $ ansible-galaxy list

    # 删除
    $ ansible-galaxy remove bennojoy.ntp
```
### 4 ansible-vault
ansible-vault 用于创建和编辑加密文件, ansible-playbook 可以自动识别并使用密码解密这些文件.

#### 4.1 ansible-vault 命令
``` bash
    $ ansible-vault [create|decrypt|edit|encrypt|encrypt_string|rekey|view] [--help] [options] vaultfile.yml
        
        SubCmd: 
        - encrypt : 加密
        - decrypt : 解密
        - create  : 创建
        - edit    : 编辑
        - view    : 查看
        - rekey   : 修改密码

        Options:
        --ask-vault-pass  :    ask for vault password
        --new-vault-password-file=NEW_VAULT_PASSWORD_FILE  : new vault password file for rekey
        --output=OUTPUT_FILE  : output file name for encrypt or decrypt; use - for stdout
        --vault-password-file=VAULT_PASSWORD_FILE : vault password file
        -v, --verbose    :     verbose mode (-vvv for more, -vvvv to enable connection debugging)
        --version        :     show program's version number and exit
```
#### 4.2 与playbook 结合的使用

1. 在 playbook 中引用 vault 文件:

    可以在 vars_file 区段像一般文件一样易用  vault 加密的文件. 
    即, 如果加密了一个 file 文件, 在 playbook 中也无需修改.

2. ansible-playbook 使用用 `--ask-value-pass` 或 `--vault-password-file` 参数
    
        $ ansible-playbook myplay.yml --ask-value-pass

        # password.file 可以为文本文件, 如果该为文件可执行脚本, 则 ansible 使用它的标准输出内容作为密码
        $ ansible-playbook myplay.yml --vault-password-file /path/to/password.file

### 5. ansible-playbook
#### 5.1 命令行参数
```bash
    Usage: ansible-playbook playbook.yml

    Options:
      --ask-vault-pass      ask for vault password
      -C, --check           don't make any changes; instead, try to predict some
                            of the changes that may occur
      -D, --diff            when changing (small) files and templates, show the
                            differences in those files; works great with --check
      -e EXTRA_VARS, --extra-vars=EXTRA_VARS
                            set additional variables as key=value or YAML/JSON
      --flush-cache         clear the fact cache
      --force-handlers      run handlers even if a task fails
      -f FORKS, --forks=FORKS
                            specify number of parallel processes to use
                            (default=5)
      -i INVENTORY, --inventory-file=INVENTORY
                            specify inventory host path (default=./hosts) or comma
                            separated host list.
      -l SUBSET, --limit=SUBSET
                            further limit selected hosts to an additional pattern
      --list-hosts          outputs a list of matching hosts; does not execute
                            anything else
      --list-tags           list all available tags
      --list-tasks          list all tasks that would be executed
      -M MODULE_PATH, --module-path=MODULE_PATH
                            specify path(s) to module library (default=None)
      --new-vault-password-file=NEW_VAULT_PASSWORD_FILE
                            new vault password file for rekey
      --output=OUTPUT_FILE  output file name for encrypt or decrypt; use - for
                            stdout
      --skip-tags=SKIP_TAGS
                            only run plays and tasks whose tags do not match these
                            values
      --start-at-task=START_AT_TASK
                            start the playbook at the task matching this name
      --step                one-step-at-a-time: confirm each task before running
      --syntax-check        perform a syntax check on the playbook, but do not
                            execute it
      -t TAGS, --tags=TAGS  only run plays and tasks tagged with these values
      --vault-password-file=VAULT_PASSWORD_FILE
                            vault password file
      -v, --verbose         verbose mode (-vvv for more, -vvvv to enable
                            connection debugging)


    Connection Options:  control as whom and how to connect to hosts

        -k, --ask-pass      ask for connection password
        --private-key=PRIVATE_KEY_FILE, --key-file=PRIVATE_KEY_FILE
                            use this file to authenticate the connection
        -u REMOTE_USER, --user=REMOTE_USER
                            connect as this user (default=root)
        -c CONNECTION, --connection=CONNECTION
                            connection type to use (default=smart)
        -T TIMEOUT, --timeout=TIMEOUT
                            override the connection timeout in seconds
                            (default=10)
        --ssh-common-args=SSH_COMMON_ARGS
                            specify common arguments to pass to sftp/scp/ssh (e.g.
                            ProxyCommand)
        --sftp-extra-args=SFTP_EXTRA_ARGS
                            specify extra arguments to pass to sftp only (e.g. -f,
                            -l)
        --scp-extra-args=SCP_EXTRA_ARGS
                            specify extra arguments to pass to scp only (e.g. -l)
        --ssh-extra-args=SSH_EXTRA_ARGS
                            specify extra arguments to pass to ssh only (e.g. -R)

    Privilege Escalation Options: control how and which user you become as on target hosts

        -s, --sudo          run operations with sudo (nopasswd) (deprecated, use
                            become)
        -U SUDO_USER, --sudo-user=SUDO_USER
                            desired sudo user (default=root) (deprecated, use
                            become)
        -S, --su            run operations with su (deprecated, use become)
        -R SU_USER, --su-user=SU_USER
                            run operations with su as this user (default=root)
                            (deprecated, use become)
        -b, --become        run operations with become (does not imply password
                            prompting)
        --become-method=BECOME_METHOD
                            privilege escalation method to use (default=sudo),
                            valid choices: [ sudo | su | pbrun | pfexec | doas |
                            dzdo | ksu | runas ]
        --become-user=BECOME_USER
                            run operations as this user (default=root)
        --ask-sudo-pass     ask for sudo password (deprecated, use become)
        --ask-su-pass       ask for su password (deprecated, use become)
        -K, --ask-become-pass
                            ask for privilege escalation password
```
部分示例

    -e var=valur : 传递变量给 playbook 

    # 列出主机, 但不会执行 playbook 
    $ ansible-playbook -i hosts --list-hosts web-tls.yml

    # 语法检查
    $ ansible-playbook --syntax-check  web-tls.yml

    # 列出 task, 但不会执行 playbook 
    $ ansible-playbook -i hosts --list-tasks web-tls.yml

    # 检查模式, 会检测 playbook 中的每个任务是否会修改主机的状态, 但并不会对主机执行任何实际操作. 
    # 需要注意 playbook 中的 task 中的依赖关系, 可能会报错.
    $ ansible-playbook [ -C | --check ] web-tls.yml

    # diff 将会为任何变更远程主机状态的文件输出差异信息. 与 --check 结合尤其好用.
    $ ansible-playbook [ -D | --diff ] playbook.yml


#### 5.2 ansible-playbook 控制 task 的执行

- step
    `--step` 参数会在执行每个 task 之前都做提示. 

        $ ansible-playbook --step playbook.yml
        Perform task: install package (y/n/c) :
            y : 执行
            n : 不执行, 跳过
            c : 继续执行剩下 playbook , 并不再提示.

- start-at-task
    
    `--start-at-task` 用于让 ansible 从指定 task 开始运行 playbook, 而不是从头开始. 

    常用于 playbook 中存在 bug , 修复之后, 从bug处再次重新运行.

- tags
    
    ansible 允许对一个 task 或者 play 添加一个或多个 tags, 如:

        - hosts: myservers
          tags: 
            - foo
          tasks:
            - name: install packages
              apt: name={{ item }}
              with_items:
                - vim
                - emacs
                - nano
            - name: run arbitrary command
              command: /opt/myprog
              tags:
                - bar
                - quux

    `-t TAG_NAME` 或 `--tags TAG_NAME` 告诉 ansible 仅允许具有指定 tags 的 task 或 play.

    `--skip-tags TAG_NAME` 告诉 ansible 跳过具有指定 tags 的 task 或者 play.

        # 仅允许指定 tags 的 task/play
        $ ansible-playbook -t foo,bar playbook.yml
        $ ansible-playbook --tags=foo,bar playbook.yml

        # 跳过指定 tags 的 task/play
        $ ansible-playbook --skip-tags=baz,quux playbook.yml 

### 6. ansible-console
REPL console for executing Ansible tasks

    $ ansible-console [<host-pattern>] [options]

### 7. ansible-config 
View, edit and manage ansible configuratin

    $ ansible-config [view|dump|list] [--help] [options] [ansible.cfg]

### 8. ansible-inventory 
used to display or dump the configured inventory as Ansible sees it.

    $ ansible-inventory [options] [host|group]

### 9. ansible-pull
pulls playbooks from a VCS repo and executes them for the local host.

    $ ansible-pull -U <repository> [options] [<playbook.yml>]

### 10. ansible 连接内网机器与跳板机设置
**原理** : 借用 ssh ProxyCommand 实现.

```bash
$ vim ~/.ssh/config

    Host bastion
        User ansible    # 修改为实际用户
        HostName  10.6.17.110   # 配置当前主机到该主机(跳板机)的 ssh-key 认证.
        ProxyCommand none
        BatchMode yes

    Host 172.16.10.*
        ServerAliveInterval 60
        TCPKeepAlive        yes
        ProxyCommand        ssh -qaY bastion 'nc -w 14400 %h %p'  #or ProxyCommand ssh -W %h:%p bastion 
        ControlMaster       auto
```            
## 六. ansible 优化加速
### 1. SSH Multiplexing (ControlPersist)
    
**原理** : 
- 第一次尝试 SSH 连接到远程主机时, OpenSSH 创建一个主链接
- OpenSSH 创建一个 UNIX 域套接字(控制套接字), 通过主链接与远程主机相连接
- 在 ControlPersist 超时时间之内, 再次连接到该远程主机, OpenSSH 将使用控制套接字与远程主机通信, 而不创建新的 TCP 连接, 省去了 TCP 三次握手的时间.

Ansible 支持的 SSH Multiplexing 选项列表:

| 选项 | 值 | 说明 | 
| --- | --- | --- |
| ControlMaster | auto | 开启 ControlPersist | 
| ControlPath | `$HOME/.ansible/cp/ansible-ssh-%h-%p-%r` | UNIX 套接字文件存放路径, 操作系统对 套接字 的最大长度有限制, 所以太长的套接字, 则 ControlPersist 将不工作, 并且 Ansible 不会报错提醒. | 
| ControlPersist | 60s | SSH 套接字连接空闲时间, 之后关闭 |

如果启用了 SSH Multiplexing 设置, 并且变更了 SSH 连接的配置, 如修改了 ssh_args 配置项, 那么, 新配置对于之前连接打开的未超时的控制套接字不会生效.

### 2. fact 缓存
    
#### 2.1 关闭 fact 缓存

    # ansible.cfg 
    [defaults]
    gathering=explicit
#### 2.2 开启 fact 缓存

请确保, playbook 中**没有**指定 `gather_facts: True` 或 `gather_facts: False` 配置项.

    # ansible.cfg
    [defaults]
    gathering=smart
    # 缓存过期时间, 单位 秒
    fact_cache_timeout=86400
    # 缓存实现机制.
    fact_caching=...

##### 2.2.1 JSON

ansible 将fact 缓存写入到 JSON 文件中, Ansible 使用**文件修改时间**来决定fact 缓存是否过期.

    # ansible.cfg
    [defaults]
    gathering=smart
    # 缓存过期时间, 单位 秒
    fact_cache_timeout=86400

    fact_caching = jsonfile
    # 指定 fact 缓存文件保存目录
    fact_caching_connection = /tmp/ansible_fact/cache

##### 2.2.2 redis
    
需要安装 redis 包, `$ pip install redis`;
需要本机提供 redis 服务.

    # ansible.cfg
    [defaults]
    gathering=smart
    # 缓存过期时间, 单位 秒
    fact_cache_timeout=86400

    fact_caching = redis

##### 2.2.3 memcache

需要安装 python-memcached 包, `$ pip install python-memcached`;
需要本机提供 memcached 服务.

    # ansible.cfg
    [defaults]
    gathering=smart
    # 缓存过期时间, 单位 秒
    fact_cache_timeout=86400

    fact_caching = memcached

#### 2.3 希望在 playbook 运行之前清除 fact 缓存, 使用 `--flush-cache` 参数

### 3. pipeline
**原理**:
- 默认执行 task 步骤: 首先, 基于调用的 module 生成一个 python 脚本; 将 Python 脚本复制到远程主机; 最后, 执行 Python 脚本. 将产生两个 SSH 会话.
- pipeline 模式 : Ansible 执行 Python 脚本时, 并不复制他, 而是通过管道传递给 SSH 会话, 从而减少了 SSH 会话的数目, 节省时间.

配置:

1. 控制主机开启 pipeline

        # ansible.cfg
        [defaults]
        pipeline=True

2. 远程主机 `/etc/sudoers` 中的 `requiretty` 没有启用.
    `Defaults:{{ ansible_ssh_user }} !requiretty`

### 4. 并发

- 设置 `ANSIBLE_FORKS` 环境变量
- 修改 ansible.cfg 配置文件, `forks = 20`.