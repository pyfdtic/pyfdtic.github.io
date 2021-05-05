---
title: Ansible-变量
date: 2018-03-15 15:46:20
categories:
- DevOps
tags:
- ansible
---
摘要
<!-- more -->

[Ansible 学习总结](https://pyfdtic.github.io/2018/03/14/Ansible-%E5%AD%A6%E4%B9%A0%E6%80%BB%E7%BB%93/)


在 Ansible 中, 变量的作用域是按照主机划分的, 只有针对特定主机讨论变量的值才有意义.

## 一. 变量
### 1. 定义变量

vars : 定义变量的列表或字典
vars_file : 指定 定义变量的文件列表

vars 区段的定义, 实际上是在 当前 play 中针对一组主机定义了变量, 但 Ansible 实际做法其实时, 对这个群组的每一个主机创建一个变量的副本.

ansible 允许定义于主机或群组有关的变量, 这些变量可以定义在 inventory 文件中, 也可以定义在与 inventory 文件放在一起的独立文件中.

**Ansible 变量定义位置**

| 变量标识 | 描述 |
| --- | --- |
| vars | playbook 区段, 为字典列表 |
| vars_file | playbook 区段, 为指向文件的列表 | 
| host_vars | 目录, 主机变量 |
| group_vars | 目录, 群组变量 |
| 主机变量 | inventory中, 单独针对主机的变量 |
| 群组变量 | inventory中, 单独针对单个群组的变量 |

### 2. 显示变量: debug 模块
    
    - debug: var=myvarname

### 3. register 注册变量: 基于 task 的执行结果, 设置变量的值.
示例:
    
    - name: Run MyProg
      command: /opt/myprog
      register: result
      ignore_errors: True

    - debug: var=result

`ignore_errors` 语句, 可以实现, 在 task 失败的时候, 是否忽略错误, 继续执行下面的 task, 默认为 False.

访问变量中字典的key, 有两种方式:
- `{ { login.stdout } }` 
- `{ { ansible_eth1["ipv4"]["address"] } }`

当 task 在目标主机, 没有执行命令时, 即当目标主机已经符合目标结果时, 输出中没有 stdout,stderr,stdout_lines 三个键值.

如果在 playbook 中使用了注册变量, 那么无论模块是否改变了主机的状态, **请确保你了解变量的内容**, 否则, 当你的 playbook 尝试访问注册变量中不存的 key时, 可能会导致失败.

```ansible
# 注册变量, 并判断变量的值
- hosts: testservers
    remote_user: root
    tasks:
    - name: ls /nono
        shell: /bin/ls /nono
        register: result
        ignore_errors: True
    - name: test result
        copy: content="ok" dest=/tmp/test
        when: result.rc == 0
    - name: test no result
        copy: content="no ok" dest=/tmp/test
        when: result.rc != 0

# jinja2 过滤器格式
tasks:
    - command: /bin/false
    register: result
    ignore_errors: True

    - command: /bin/something
    when: result|failed

    - command: /bin/something_else
    when: result|succeeded

    - command: /bin/still/something_else
    when: result|skipped

# 字符串转换为数字之后, 再去判断
tasks:
    - shell: echo "only on Red Hat 6, derivatives, and later"
    when: ansible_os_family == "RedHat" and ansible_lsb.major_release|int >= 6

# 判断变量是否定义
tasks:
    - shell: echo "I've got '{{ foo }}' and am not afraid to use it!"
        when: foo is defined

    - fail: msg="Bailing out. this play requires 'bar'"
        when: bar is undefined

# 与循环结合使用
tasks:
    - command: echo {{ item }}
        with_items: [ 0, 2, 4, 6, 8, 10 ]
        when: item > 5

- command: echo {{ item }}
    with_items: "{{ mylist|default([]) }}"
    when: item > 5
- command: echo {{ item.key }}
    with_dict: "{{ mydict|default({}) }}"
    when: item.value > 5

# roles 包含 when
- include: tasks/sometasks.yml
    when: "'reticulating splines' in output"
- hosts: webservers
    roles:
        - { role: debian_stock_config, when: ansible_os_family == 'Debian' }

# 基于变量选择文件和模板
- name: template a file
    template: src={{ item }} dest=/etc/myapp/foo.conf
    with_first_found:
    - files:
        - {{ ansible_distribution }}.conf
        - default.conf
        paths:
        - search_location_one/somedir/
        - /opt/other_location/somedir/

# 使用注册变量
- name: test play
    hosts: all
    tasks:
    - shell: cat /etc/motd
        register: motd_contents
    - shell: echo "motd contains the word hi"
        when: motd_contents.stdout.find('hi') != -1

# 满足条件时, 任务失败
tasks:
    - command: echo faild.
        register: command_result
        failed_when: "'faild' in command_result.stdout"
    - debug: msg="echo test"


- name: Test the plabybook API.
  hosts: all
  remote_user: root
  gather_facts: yes
  tasks:
   - name: exec uptime
     shell: free -b -o | awk '/Mem/ {print $2}'
     register: f_mem
     failed_when: f_mem['stderr'] != ""
   - debug: msg={{ f_mem }}
   - name: add task
     shell: which pip
     register: pip_installed
   - debug: msg={{pip_installed}
   
```

### 4. set_fact 定义新变量

使用 set_fact 模块在 task 中设置 fact(与定义一个新变量是一样的). 可以在 register 关键字后, 立即使用 set_fact , 这样使得变量引用更简单.

    - name: get snapshot id
      shell: >
        aws ec2 describe-snapshot --filters Name=tag:Name, Valuse=my-snapshot | jq --raw-outpuy ".Snapshots[].SnapshtId"
      register: snap_result
    - set_fact: snap={ { snap_result.stdout } }

    - name: delete old snapshot
      command: aws ec2 delete-snapshot --snapshot-id "{ { snap } }"

### 5. 内置变量
    
| 参数 | 说明 | 
| --- | --- |
| hostvars | 字典, key 为 Ansible 主机的名字, value 为所有变量名与相应变量值映射组成的字典 |
| inventory_hostname | 当前主机被 Ansible 识别的名字, 如果定义了别名, 则为别名. |
| group_names | 列表, 由当前主机所属的所有群组组成 |
| groups | 字典, key 为 ansible 群组名, value 为群组成员的主机名所组成的列表. 包括 all 分组和 ungrouped 分组 |
| play_hosts | 列表, 成员是当前 play 涉及的主机的 inventory 主机名. |
| ansible_version | 字典, 由 Ansible 版本信息组成. | 

- hostvars : 
    
    在 Ansible 中, 变量的作用域是按照主机划分的, 只有针对特定主机讨论变量的值才有意义.

    有时候 , 针对一组主机定义的变量, 该变量实际始于特定的主机相关联的.
    例如 vars 区段的定义, 实际上是在 当前 play 中针对一组主机定义了变量, 但 Ansible 实际做法其实时, 对这个群组的每一个主机创建一个变量的副本.

    **hostvars**变量包含了在所有主机上定义的所有变量, 并以 ansible 识别的主机名作为 key. 如果 Ansible 还未对主机采集 fact, 那么除非启动 fact 缓存, 否则无法使用 hostvars 访问fact.

    有时, 在某一个主机上运行的 task 可能会需要在另一台主机上定义的变量. 例如, web 服务器, 可能需要 数据库服务器的 ansible_eth1.ipv4.address 这个 fact. 如果 数据库服务器为 db.example.com, 那么, 其变量引用为: 

            { { hostvars['db.example.com'].ansible_eth1.ipv4.address } }

    `- debug: var=hostvars[inventory_hostname]` : 输出与当前主机相关联的所有变量.

- groups : 

    代表当前 inventory 所定义的所有组的集合, 为一个字典.

    示例: web 负载均衡配置文件

        backend web-backend
        {% for host in groups.web %}
            server { { host.inventory_hostname } } { { host.ansible_default_ipv4.address } }:80
        {% endfor %}
    
    示例二:

        {% for h in groups['web'] -%}
            {% if h == inventory_hostname %}
                OPTIONS="-x {{ hostvars[h]['ansible_default_ipv4']['address'] }}  -X 11212"
            {% endif %}
        {% endfor %}

### 6. 在命令行设置变量
    
向 ansible-playbook 传入 `-e var=value` 参数设置变量或传递参数, 有最高优先级. 可以覆盖已定义的变量值. 

    $ ansible-playbook example.yml -e token=123456

希望在变量中出现空格, 需要使用引号:

    $ ansible-playbook playbooks/greeting.yml -e 'greeting="Oops you have another hello world"'

`@filename.yml` 传递参数:

    $ cat greetvars.yml
      greeting: "ops you have another hello world"

    $ ansible-playbook playbooks/greeting.yml -e @greetvars.yml


## 二. fact
当 Ansible 采集 fact 的时候, 他会连接到目标主机收集各种详细信息: CPU 架构,操作系统,IP地址,内存信息,磁盘信息等. 这些信息保存在被称为 fact 的变量中. fact 与其他变量的行为一模一样.

### 1. setup 模块
    
    实现 fact 收集的模块. 一般无需再 playbook 中调用该模块, Ansible 会在采集 fact 时, 自动调用.
    
    `$ ansible server_name -m setup -a 'filter=ansible_eth*'` 

    其返回值为一个字典, 字典的 key 是 ansible_fact, 他的 value 是一个有实际 fact 的名字与值组成的字典.

    setup 模块支持 filter 参数, 可以实现 shell 通配符的匹配过滤.

### 2. 模块返回 fact

    如果一个模块返回一个字典且包含名为 ansible_facts 的key, 那么 ansible 将会根据对应的 value 创建响应的变量, 并分配给相对应的主机. 对于返回 fact 的模块, 并不需要使用注册变量, 因为 ansible 会自动创建.

    可以自动返回 fact 的模块: $ ansible-doc --list |grep facts
    - ec2_facts
    - docker_image_facts 

### 3. 本地 fact

    可将一个或者多个文件放置在目标主机的 /etc/ansible/facts.d/ 目录下, 如果该目录下的文件以 init格式, JSON格式 或者输出JSON格式的可执行文件(无需参数), 以这种形式加载的 fact 是 ansible_local 的特殊变量.

    示例:

        # 目标主机
        $ /etc/ansible/facts.d/books.fact
        [book]
        title=Ansible: Up and Running
        author=Lorin Hochstein
        publisher=P'Reilly Media

        # ansible 主机
        $ cat playbooks/local.yml

        - name: get local variables
          hosts: host_c
          gather_facts: True
          tasks:
            - name: print local variables;
              debug: var=ansible_local
            - name: print book title
              debug: msg="The Book Title is { { ansible_local.books.book.title  } }"

    注意 ansible_local 变量值的结构, 因为 fact 文件的名称为 books, 所以 ansible_local 变量是一个字典, 且包含一个名为 "books" 的 key.

## 三. 变量优先级: 
以下优先级**依次降低**:

1. 命令行参数
2. 其他
3. 通过 inventory 文件或 YAML 文件定义的主机变量或群组变量
4. Fact
5. 在 role 的 defaults/mail.yml 文件中的变量.

## 四. 过滤器: 变量加工处理
Ansible 除了使用 Jinja2 作为模板之外, 还将其用于变量求值. 即, 可以在 playbook 中在 `{ {} }` 内使用过滤器.
除了可以用 Jinja2 的内置过滤器外, Ansible 还有一些自己扩展的过滤器.

有些参数, 需要参数, 有些则不需要.

[Jinja2 内置过滤器](http://docs.jinkan.org/docs/jinja2/templates.html#builtin-filters)
[Ansible 过滤器](http://docs.ansible.com/ansible/latest/playbooks_variables.html#jinja2-filters)

### 1. default : 设置默认值.
        
    # 设置 HOST 变量的默认值, 如果 database 没有被定义, 则使用 localhost .
    "HOST": "{ { database | default('localhost') } }"

### 2. 用于注册变量的过滤器

对注册变量状态检查状态的过滤器

| 名称 | 描述 |
| --- | --- |
| failed | 如果注册变量的值是任务 failed , 则返回 True |
| changed | 如果注册变量的值是任务 changed , 则返回 True |
| success | 如果注册变量的值是任务 success , 则返回 True |
| skipped | 如果注册变量的值是任务 skipped , 则返回 True |

示例:

    - name: Run myprog
      command: /opt/myprog
      register: result
      ignore_errors: True
    - debug: var=result
    - debug: msg="Stop Running the playbook if myprog failed"
      failed_when: result|failed

### 3. 用于文件路径的过滤器
    
用于处理包含控制主机文件系统的路径的变量.

| 过滤器 | 描述 |
| --- | --- |
| basename | 文件路径中的目录 |
| dirname | 文件路径中的目录 |
| expanduser | 将文件路径中的 ~ 替换为用户家目录 |
| realpath | 处理符号链接后的文件实际路径 |

示例:

    vars:
      homepages: /usr/share/nginx/html/index.html
    tasks:
      - name: copy home page
        copy: src=files/{ { homepages| basename } } desc={ { homepages } }

### 4. 自定义过滤器
    
Ansible 会在存放 playbook 的目录下的 filter_plugins 目录中寻找自定义过滤器. 也可以放在 `/usr/share/ansible_plugins/filter_plugins/` 目录下, 或者 环境变量`ANSIBLE_FILTER_PLUGINS` 环境变量设置的目录.

    # filter_plugins/surround_by_quotes.py
    def surround_by_quote(a_list):
        return ['"%S"' % an_element for an_element in a_list]

    class FilterModule(object):
        def filters(self):
            return {'surround_by_quote': surround_by_quote}

`surround_by_quote` 函数定义了 Jinja2 过滤器.
`FilterModule` 类定义了一个 filter 方法, 该方法返回由过滤器名称和函数本身组成的字典. FilterModule 是 Ansible 相关代码, 他使得 Jinja2 过滤器可以再 Ansible 中使用.


## 五. lookup: 从多种来源读取配置数据.
[lookup 官方文档说明](http://docs.ansible.com/ansible/latest/playbooks_lookups.html)
**Ansible 所有的 lookup 插件都是在控制主机, 而不是远程主机上执行的**

支持的数据来源表:

| 名称 | 描述 |
| --- | --- |
| file | 文件的内容 |
| password | 随机生成密码 |
| pipe | 本地命令执行的输出 |
| env | 环境变量 |
| template | Jinja2 模板渲染的结果 |
| csvfile | .csv 文件中的条目 |
| dnstxt | DNS 的 TXT 记录 |
| redis_ke | 对 Redis 的key 进行查询 |
| etcd | 对 etcd 中的key 进行查询 |

- file
    
    示例: 在 playbook 中调用 lookup 
         
        - name: Add my public key as an EC2 key
          ec2_key: name=mykey key_material="{ { lookup('file', '/home/me/.ssh/id_rsa.pub') } }"

    示例: 使用 Jinja2 模板

        # authorized_keys.j2
        { { lookup('file', '/home/me/.ssh/id_rsa.pub') } }

        # playbook
        - name: copy authorized_host file
          template: src=authorized_keys.j2 desc=/home/deploy/.ssh/authorized_keys

- pipe
    
    在控制主机上调用一个外部程序, 并将这个程序的输出打印到标准输出上.

    示例: 得到最新的 git commit 使用的 SHA-1 算法的值.

        - name: get SHA of most recent commit
          debug: msg="{ { lookup('pipe', 'git rev-parse HEAD') } }"

- env
    
    获取在控制主机上的某个环境变量的值.

    示例:

        - name: get the current shell
          debug: msg="{ { lookup('env', 'SHELL') } }"

- password
    
    随机生成一个密码, 并将这个密码写入到参数指定的(控制主机)文件中.

    示例: 生成 deploy 的 Postgre 用户和密码, 并将密码写入到 deploy-password.txt 中:

        - name: create deploy postgre user
          postgresql_user:
            name: deploy
            password: "{ { lookup('password', 'deploy-password.txt') } }"

- template 
    
    指定一个 Jinji2 模板文件, 并返回这个模板渲染的结果.

        # message.j2
        This host runs { { ansible_distribution } }

        # task
        - name: output message from template
          debug: msg="{ { lookup('template', 'message.j2') } }"

- csvfile
    
    从 csv 文件中读取一个条目.

        # users.csv
        username, email
        lorin, lorin@example.com
        john, john@example.com
        sue, sue@example.com

        # 调用 : 查看名为 users.csv 的文件, 使用逗号作为分隔符来定位区域, 寻找第一列的值是 sue 的那一行, 返回第二列(索引从 0 开始)的值.
        lookup('csvfile', 'sue file=users.csv delimiter=, col=1') --> sue@example.com

        # 用户名被存储在 username 变量中, 可以用 "+" 连接其他参数, 构建完整的参数字符串.
        lookup('csvfile', username + 'file=users.csv delimiter=, col=1')


- dnstxt
    
    需要安装 dnspython 包, `$ pip install dnspython`

    TXT 记录是 DNS 中一个可以附加在主机名上的任意字符串, 一旦为主机名关联了一条 TXT 记录, 则任何人都可以使用 DNS 客户端获取这段文本.

        # 使用 dig 查看 TXT 记录
        $ dig +short ansiblebook.com TXT
        "isbn=97801491915325"

        # task 
        - name: look up TXT record
          debug: msg="{ { lookup('dnstxt', 'ansiblebook.com') } }"

- redis-kv
    
    需要安装 redis 包: `$ pip install pip`
    可以使用 redis-kv 获取一个 key 的value, key 必须为字符串.

        # 设置一个值:
        $ redis-cli SET weather sunny

        # task
        - name: look up value in redis
          debug: msg="{ { lookup('redis_kv', 'redis://localhost:6379,weather') } }"
- etcd 
    
    etcd lookup 默认在 http://127.0.0.1:4001 上查找 etcd 服务器, 可以在执行 ansible-playbook 之前, 通过设置 `ANSIBLE_ETCD_URL` 改变这个值.

        # 设置测试值
        $ curl -L http://127.0.0.1:4001/v2/keys/weather -XPUT -d value=cloudy

        # task
        - name: loop up value in etcd
          debug: msg="{ { lookup('etcd', 'weather') } }"