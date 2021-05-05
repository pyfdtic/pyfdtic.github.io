---
title: Ansible-模块
date: 2018-03-15 15:47:42
categories:
- DevOps
tags:
- ansible
---
1. Ansible 常用模块使用方法
2. 自定义 Ansible 模块

<!-- more -->

[Ansible 学习总结](https://pyfdtic.github.io/2018/03/14/Ansible-%E5%AD%A6%E4%B9%A0%E6%80%BB%E7%BB%93/)

## 一. 内置模块
是由 ansible 包装后, 在主机上执行一系列操作的脚本.

### 1. 查看模块帮助
    
    $ ansible-doc MOD_NAME

### 2. 查找第三方模块
    
    $ ansible-galaxy search MOD_NAME

### 3. 常用模块
[Ansible 模块索引](http://docs.ansible.com/ansible/latest/modules/list_of_all_modules.html)
#### apt
    
- update_cache=yes 

    在安装软件之前, 首先更新 repo 缓存.
- cache_valid_time=3600

    上次 repo 缓存的有效时间.
- upgrade=yes

#### pip

Ansible 的 pip 模块支持向 virtualenv 中安装软件包, 并且还支持在没有可用的 virtualenv 时, 自动创建一个.

    - name: install required python packages
      pip: name={{ item }} virtualenv={{ venv_path }}
      with_items:
        - gunicorn
        - django
        - django-compressor

支持 requirements 文件

    - name: install required python pkg
      pip: requirements={{ proj_path }}/{{ reqs_file }} virtualenv={{ venv_path }}

Options :

- chdir
        cd into this directory before running the command
        [Default: None]
- editable
        Pass the editable flag for versioning URLs.
        [Default: True]
- executable
        The explicit executable or a pathname to the executable to be used to run pip for a specific
        version of Python installed in the system. For example `pip-3.3', if there are both Python 2.7
        and 3.3 installations in the system and you want to run pip for the Python 3.3 installation. It
        cannot be specified together with the 'virtualenv' parameter (added in 2.1). By default, it
        will take the appropriate version for the python interpreter use by ansible, e.g. pip3 on
        python 3, and pip2 or pip on python 2.
        [Default: None]
- extra_args
        Extra arguments passed to pip.
        [Default: None]
- name
        The name of a Python library to install or the url of the remote package.
        As of 2.2 you can supply a list of names.
        [Default: None]
- requirements
        The path to a pip requirements file, which should be local to the remote system. File can be
        specified as a relative path if using the chdir option.
        [Default: None]
- state
        The state of module
        The 'forcereinstall' option is only available in Ansible 2.1 and above.
        (Choices: present, absent, latest, forcereinstall)[Default: present]
- umask
        The system umask to apply before installing the pip package. This is useful, for example, when
        installing on systems that have a very restrictive umask by default (e.g., 0077) and you want
        to pip install packages which are to be used by all users. Note that this requires you to
        specify desired umask mode in octal, with a leading 0 (e.g., 0077).
        [Default: None]
- version
        The version number to install of the Python library specified in the `name' parameter
        [Default: None]
- virtualenv
        An optional path to a `virtualenv' directory to install into. It cannot be specified together
        with the 'executable' parameter (added in 2.1). If the virtualenv does not exist, it will be
        created before installing packages. The optional virtualenv_site_packages, virtualenv_command,
        and virtualenv_python options affect the creation of the virtualenv.
        [Default: None]
- virtualenv_command
        The command or a pathname to the command to create the virtual environment with. For example
        `pyvenv', `virtualenv', `virtualenv2', `~/bin/virtualenv', `/usr/local/bin/virtualenv'.
        [Default: virtualenv]
- virtualenv_python
        The Python executable used for creating the virtual environment. For example `python3.5',
        `python2.7'. When not specified, the Python version used to run the ansible module is used.
        [Default: None]
- virtualenv_site_packages
        Whether the virtual environment will inherit packages from the global site-packages directory.
        Note that if this setting is changed on an already existing virtual environment it will not
        have any effect, the environment must be deleted and newly created.
        (Choices: yes, no)[Default: no]

#### copy
#### file
#### service
#### template 
#### setup
    
实现 fact 收集的模块. 一般无需再 playbook 中调用该模块, Ansible 会在采集 fact 时, 自动调用.

`$ ansible server_name -m setup -a 'filter=ansible_eth*'` 

其返回值为一个字典, 字典的 key 是 ansible_fact, 他的 value 是一个有实际 fact 的名字与值组成的字典.

setup 模块支持 filter 参数, 可以实现 shell 通配符的匹配过滤.

    - name: gather facts
      setup:

#### set_fact
    
使用 set_fact 模块在 task 中设置 fact(与定义一个新变量是一样的). 可以在 register 关键字后, 立即使用 set_fact , 这样使得变量引用更简单.

    - name: get snapshot id
      shell: >
        aws ec2 describe-snapshot --filters Name=tag:Name, Valuse=my-snapshot | jq --raw-outpuy ".Snapshots[].SnapshtId"
      register: snap_result
    - set_fact: snap={{ snap_result.stdout }}

    - name: delete old snapshot
      command: aws ec2 delete-snapshot --snapshot-id "{{ snap }}"

#### command

在 command 中保持幂等性的方法: 指定 creates 参数.

    # 当 Vagrantfile 存在, 则表示已经处于正确状态, 而且不需要再次执行命令, 从而实现幂等性.
    - name: create a vagrantfile
      command: vagrant init {{ box }} creates=Vagrantfile

官方文档:

    - creates
            a filename or (since 2.0) glob pattern, when it already exists, this step
            will *not* be run.
            [Default: None]

    - removes
            a filename or (since 2.0) glob pattern, when it does not exist, this step
            will *not* be run.
            [Default: None]
#### script
    
实现幂等性方法: creates 和 removes 参数.

官方文档:

    - creates
            a filename, when it already exists, this step will *not* be run.
            [Default: None]

    - removes
            a filename, when it does not exist, this step will *not* be run.
            [Default: None]
#### debug

    > DEBUG    (/opt/virtualEnv/ansibleEnv/lib/python2.7/site-packages/ansible/modules/utilities/logic/debug.py)

      This module prints statements during execution and can be useful for debugging variables or
      expressions without necessarily halting the playbook. Useful for debugging together with the 'when:'
      directive.

      * note: This module has a corresponding action plugin.

    Options (= is mandatory):

    - msg
            The customized message that is printed. If omitted, prints a generic message.
            [Default: Hello world!]
    - var
            A variable name to debug.  Mutually exclusive with the 'msg' option.
            [Default: (null)]
    - verbosity
            A number that controls when the debug is run, if you set to 3 it will only run debug when -vvv
            or above
            [Default: 0]

    EXAMPLES:

    # Example that prints the loopback address and gateway for each host
    - debug:
        msg: "System {{ inventory_hostname }} has uuid {{ ansible_product_uuid }}"

    - debug:
        msg: "System {{ inventory_hostname }} has gateway {{ ansible_default_ipv4.gateway }}"
        when: ansible_default_ipv4.gateway is defined

    - shell: /usr/bin/uptime
      register: result

    - debug:
        var: result
        verbosity: 2

    - name: Display all variables/facts known for a host
      debug:
        var: hostvars[inventory_hostname]
        verbosity: 4
#### postgresql_user
#### postgresql_db
#### django_manage
#### cron
        
    # 安装 cron job, 注意 name 参数, 该参数必须要有, 该参数将用于删除计划任务时所使用的名称.
    - name: install poll twitter cron job
      cron: name="Poll twitter" minute="*/5" user={{ user }} job="{{ manage }} poll_twitter"

    # 删除计划任务, 基于 name 参数, 在删除时, 会连带注释一起删掉.
    - name: remote cron job
      cron: name="Poll twitter" state=absent

#### git
    
    - name: check out the repository on the host
      git: repo={{ repo_url }} dest={{ proj_path }} accept_host_key=yes

#### wait_for

You can wait for a set amount of time `timeout', this is the default if nothing is specified. Waiting for a port to become available is useful for when services are not immediately available after their init scripts return which is true of certain Java application servers. It is also useful when starting guests with the [virt] module and needing to pause until they are ready. This module can also be used to wait for a regex match a string to be present in a file. 

In 1.6 and later, this module can also be used to wait for a file to be available or absent on the filesystem. 

In 1.8 and later, this module can also be used to wait for active connections to be closed before continuing,useful if a node is being rotated out of a load balancer pool.

Options: 
- active_connection_states
        The list of tcp connection states which are counted as active connections
        [Default: [u'ESTABLISHED', u'SYN_SENT', u'SYN_RECV', u'FIN_WAIT1', u'FIN_WAIT2', u'TIME_WAIT']]
- connect_timeout
        maximum number of seconds to wait for a connection to happen before closing and retrying
        [Default: 5]
- delay
        number of seconds to wait before starting to poll
        [Default: 0]
- exclude_hosts
        list of hosts or IPs to ignore when looking for active TCP connections for `drained' state
        [Default: None]
- host
        A resolvable hostname or IP address to wait for
        [Default: 127.0.0.1]
- path
        path to a file on the filesytem that must exist before continuing
        [Default: None]
- port
        port number to poll
        [Default: None]
- search_regex
        Can be used to match a string in either a file or a socket connection. Defaults to a multiline
        regex.
        [Default: None]
- sleep
        Number of seconds to sleep between checks, before 2.3 this was hardcoded to 1 second.
        [Default: 1]
- state
        either `present', `started', or `stopped', `absent', or `drained'
        When checking a port `started' will ensure the port is open, `stopped' will check that it is
        closed, `drained' will check for active connections
        When checking for a file or a search string `present' or `started' will ensure that the file or
        string is present before continuing, `absent' will check that file is absent or removed
        (Choices: present, started, stopped, absent, drained)[Default: started]
- timeout
        maximum number of seconds to wait for
        [Default: 300]


- `wait_for_connection` : 默认超时时间 600s
    
    Waits until remote system is reachable/usable
    
    等待目标主机可以成为 reachable/usable 状态, 即 ssh 22 端口可以连通.

        - name: Wait 300 seconds, but only start checking after 60 seconds
          wait_for_connection:
            delay: 60               # 等待 60s 之后执行 本task
            timeout: 300            # 超时时间, 默认300s
            sleep: 2                # 在检查期间, 每次检查之间的间隔时间, 默认为 1s

        - name: Wait 600 seconds for target connection to become reachable/usable
          wait_for_connection: 

-  `wait_for` : Waits for a condition before continuing
    
    等待某个主机或端口可用, 适用范围比 wait_for_connection 更加广泛. 可以在本机或目标主机检查其他或本地主机的端口,.

        - name: Wait 300 seconds for port 22 to become open
          wait_for: 
             port: 22
             sleep: 3
             
             # A resolvable hostname or IP address to wait for.
             host: '{{ (ansible_ssh_host|default(ansible_host))|default(inventory_hostname) }}'

             # Can be used to match a string in either a file or a socket connection.
             search_regex: OpenSSH

             timeout: 300

             # This overrides the normal error message from a failure to meet the required conditions.
             msg: Timeout to connect through OpenSSH

             # Either present, started, or stopped, absent, or drained.
             # When checking a port started will ensure the port is open, stopped will check that it is closed, drained will check for active connections.
             # When checking for a file or a search string present or started will ensure that the file or string is present before continuing, absent will check that file is absent or removed.
             state: drained

             # List of hosts or IPs to ignore when looking for active TCP connections for drained state.
             exclude_hosts: 10.2.1.2,10.2.1.3   

          delegate_to: localhost


        - name: Wait until the process is finished and pid was destroyed
          wait_for:
            # Path to a file on the filesystem that must exist before continuing.
            path: /proc/3466/status
            state: absent

#### lineinfile

#### stat

收集关于文件路径状态的各种信息, 返回一个字典, 该字典包含一个 `stat` 字段. 部分字段返回值表:

| 字段 | 描述 |
| --- | --- |
| dev | inode 所在设备 ID 编号 |
| gid |  路径的所属组 ID 编号 |
| inode | inode 号 |
| mode | 字符串格式的八进制文件模式,如 1777 |
| atime | 路径的最后访问时间, 使用 UNIX 时间戳 |
| ctime | 路径的创建时间, 使用 UNIX 时间戳, 文件元数据变更时间 |
| mtime | 路径的最后修改时间, 使用 UNIX 时间戳 , 文件内容修改时间.|
| nlink | 文件硬链接的数量 |
| pw_name | 文件所属者的登录名 |
| size | 如果是文件, 返回字节单位的文件大小 |
| uid | 路径所属者的 uid |
| isblk | 如果路径为指定块设备文件, 返回 true |
| ischr | 如果路径为指定字符设备文件,返回 true |
| isdir | 如果路径为目录, 返回 true |
| isfifo | 如果路径为 FIFO(管道), 返回 true |
| isgid | 如果文件设置了 setgid , 返回 true |
| isuid | 如果文件设置了 setuid , 返回 true |
| islnk | 如果文件时符号链接, 返回 true |
| isreg | 如果路径是常规文件, 返回 true |
| issock | 如果路径是UNIX 域socket, 返回 true |
| rgrp | 如果设置所属组可读权限, 返回 true |
| roth | 如果设置其他人可读权限, 返回 true |
| rusr | 如果设置了属主可读权限, 返回 true |
| wgrp |  如果设置所属组可写权限, 返回 true |
| woth |  如果设置所属组可写权限, 返回 true |
| wusr |  如果设置所属组可写权限, 返回 true |
| xgrp |  如果设置所属组可执行权限, 返回 true |
| xoth |  如果设置所属组可执行权限, 返回 true |
| xusr |  如果设置所属组可执行权限, 返回 true |
| exists | 如果存在, 返回 true |
| md5 | 文件的 md5 值 |
| checksum | 文件的hash 值, 可以设置 sha 算法. |

#### assert
    
assert 模块在指定的条件**不符合**是,返回错误, 并失败退出. 主要用于调试. 
`that` : 后跟计算表达式
`msg` : 失败后的提示信息.

    - name: stat /opt/foo
      stat: path=/opt/foo
      register: st

    - name: assert that /opt/foo is a directory
      assert:
        that: st.stat.isdir

    -------

    - assert:
        that:
          - "my_param <= 100"
          - "my_param >= 0"
        msg: "'my_param' must be between 0 and 100"


## 二. 自定义模块
自定义模块存放路径: playbooks/library

### 1. 使用 script 自定义 模块

### 2. 使用 Python 自定义模块.
