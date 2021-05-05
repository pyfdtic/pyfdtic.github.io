---
title: Ansible-API
date: 2018-03-15 15:48:38
categories:
- DevOps
tags:
- ansible
---
ansible api 开发篇
<!-- more -->
[Ansible 学习总结](https://pyfdtic.github.io/2018/03/14/Ansible-%E5%AD%A6%E4%B9%A0%E6%80%BB%E7%BB%93/)

ansible api
```
Callbacks
Inventory

Playbook
Script
```

https://segmentfault.com/a/1190000008009639

https://serversforhackers.com/c/running-ansible-2-programmatically


Ansible Runner 
==============

[ansible runner doc](https://ansible-runner.readthedocs.io/en/latest/index.html)

Ansible Runner 是 Ansible Tower/AWX 模块化的一个代表. 可用于运行 ansible 或 ansible-playbook 任务, 并收集运行结果. Ansible Runner 提供一个通用的接口, 并且承诺该接口不发生改变, 即使 Ansible 本身发生进化.

Ansible Runner 可以以灵活的方式收集 playbook 的 输入/输出 或 其他数据信息.

与 Ansible Runner 交互有三种方式:
- 命令行工具 `ansible-runner` 可以在前台或者后台以**异步**的方式运行.
- 容器方式 , Ansible Runner 提供一个 基础镜像接口, 可以作为一个单独的容器运行在 Opernshift 或者 Kubernetes 集群中.
- python 模块, 作为一个 Python 库接口.
- Ansible Runner 可以配置一个插件接口, 用于发送状态和事件信息到其他第三方系统. 参考 [Sending Status and Event to Externel System](https://ansible-runner.readthedocs.io/en/latest/external_interface.html#externalintf)

### 1. 简介与安装配置
#### 1.1 介绍
大多数 Ansible 命令行参数都可以被 Ansible Runner 命令行使用, 同时, Ansible Runner 可以使用一个 目录结构作为输入接口([示例](https://github.com/ansible/ansible-runner/tree/master/demo)).

##### 1.1.1 Ansible Runner 输入目录层级结构
并非所有的参数/文件都是必须的, 有一些有默认值. 如下为一个示例:
```
# 该目录也称为 Ansible Runner 的 private_data_dir.
.
├── env
│   ├── envvars
│   ├── extravars
│   ├── passwords
│   ├── cmdline
│   ├── settings
│   └── ssh_key
├── inventory
│   └── hosts
├── project
│   └── test.yml
└── roles
    └── testrole
        ├── defaults
        ├── handlers
        ├── meta
        ├── README.md
        ├── tasks
        ├── tests
        └── vars
```

- `env` 目录
	
	`env` 目录包含 配置 及 其他敏感信息, 每个文件用于 Ansible 运行时的不同时期与作用.

	每个文件都可以通过一个 加密的命名管道 来展现.

	每个文件的格式和表达方式根据其作用, 略有不同.

	- `env/envvars` 环境变量, Ansible Runner 默认继承当前 shell 的环境变量, `env/envvars` 中定义的变量, 会被添加到 Ansible Runner 的运行时变量当中.
		```
		---
		TESTVAR: exampleval
		```

	- `env/extravars` 其他Ansible 变量, Ansible Runner 从该文件中收集 Task 运行时使用的变量, 该文件可以为 json 或者 yaml 格式.
		```
		---
		ansible_connection: local
		test: val
		```

	- `env/passwords` 匹配特定的提示字符, 并输入密码, 该文件为 json 或者 yaml 格式. 其表达式 为 正则表达式.
		```
		---
		"^SSH [pP]assword:$": "some_password"
		"^BECOME [pP]assword:$": "become_password"
		```

	- `env/cmdline` 用于包含 Ansible Runner 的命令行参数. 但是, 这种方式提供的参数优先级低于 playbook 提供的同一个参数的优先级.
		```
		--tags one,two --skip-tags three -u ansible --become
		```

	- `env/ssh_key` ssh 私钥文件, 用于 ssh 链接其他主机. 当前只支持一个ssh key文件.

	- `env/settings` Ansible Runner 本身的配置文件.
	
		- `idle_timeout`: 默认 600s, 如果超过 `idle_timeout` 任然没有输出, 则报错.
		- `job_timeout`: 默认 3600s, 单个任务的最长运行时间, 超时后, 任务被终止.
		- `pexpect_timeout`: 默认 10s, 等待输入的空闲时间.
		- `pexpect_use_poll`: 使用的进程 fork 方式. `True` 为 `poll()` 方式, `False`为 `select()`方式, `select()` 方式有最大 1024 个文件描述符的限制.
		- `suppress_ansible_output`: 默认 `False`, 是否允许 Ansible 将其输出打印到 屏幕.
		- `fact_cache`: 默认 'fact_cache', Ansible fact 缓存保存目录, 只有 `fact_cache_type: jsonfile` 时, 有效; 否则, 该参数会被自动忽略.
		- `fact_cache_type`: 默认 'jsonfile', Ansible fact 缓存的保存文件格式.


- `inventory` 目录 
	
	与 Ansible 原生的 inventory 目录相同, 可以包含单个文件/脚本或者包含多个文件/脚本的目录. 该目录中的文件会被自动调用.

	该目录中提供的 hosts 优先级**低于**命令行参数或者环境变量.

- `project` 目录 

	是 playbook 的根本目录, 可以包含 playbook 或者 roles. 

	也会被设置为 Ansible 执行时的 current working directory.

- `Modules` 目录 
	
	Runner 可以使用 Ansible ad-doc 模式 直接执行 modules.

- `roles` 目录, 包含需要执行的 roles
	
	Runner 可以直接执行 roles, 而无需使用一个 playbook 预先调用 role. 这种场景下, Ansible Runner 会自动生成一个 playbook 并调用 roles.

- `artifacts` 目录, 使用 **标识符** 作为目录区分的 roles 调用详细结果. 标识符 可以自己提供 `-i IDENT`, 默认则为 UUID.
	
	```
	.
	├── artifacts
	│   └── 37f639a3-1f4f-4acb-abee-ea1898013a25
	│       ├── job_events
	│       │   ├── 1-34437b34-addd-45ae-819a-4d8c9711e191.json
	│       │   ├── 2-8c164553-8573-b1e0-76e1-000000000006.json
	│       │   ├── 3-8c164553-8573-b1e0-76e1-00000000000d.json
	│       │   ├── 4-f16be0cd-99e1-4568-a599-546ab80b2799.json
	│       │   ├── 5-8c164553-8573-b1e0-76e1-000000000008.json
	│       │   ├── 6-981fd563-ec25-45cb-84f6-e9dc4e6449cb.json
	│       │   └── 7-01c7090a-e202-4fb4-9ac7-079965729c86.json
	│       ├── rc
	│       ├── status
	│       └── stdout
	├── env
	├── inventory
	├── project
	└── roles
	```

	- `rc`: Ansible 进程的返回码.
	- `status`: contains one of three status suitable for displaying.
		- `success`: Ansible 进程执行成功
		- `failed`: Ansible 进程执行失败
		- `timeout`: Ansible 进程执行超时.

	- `stdout`: 输出信息.
	- `job_events`: Host and Playbook Event. Ansible 收集 Ansible 运行在中产生的单个 task 和 playbook 的事件. 这在不想要收集 Ansible 运行中产生的详细输出信息的场景尤其适用. 与此同时, Runner 会收集与 事件 关联的 stdout. 

		```
		{
		  "uuid": "8c164553-8573-b1e0-76e1-000000000008",
		  "counter": 5,
		  "stdout": "\r\nTASK [debug] *******************************************************************",
		  "start_line": 5,
		  "end_line": 7,
		  "event": "playbook_on_task_start",
		  "event_data": {
		    "playbook": "test.yml",
		    "playbook_uuid": "34437b34-addd-45ae-819a-4d8c9711e191",
		    "play": "all",
		    "play_uuid": "8c164553-8573-b1e0-76e1-000000000006",
		    "play_pattern": "all",
		    "task": "debug",
		    "task_uuid": "8c164553-8573-b1e0-76e1-000000000008",
		    "task_action": "debug",
		    "task_path": "\/home\/mjones\/ansible\/ansible-runner\/demo\/project\/test.yml:3",
		    "task_args": "msg=Test!",
		    "name": "debug",
		    "is_conditional": false,
		    "pid": 10640
		  },
		  "pid": 10640,
		  "created": "2018-06-07T14:54:58.410605"
		}

		```

		如果 playbook 运行过程中, 没有被强制停止/杀死, 则最后的一个事件一定是`playbook_on_stats` 事件, 包含整个 playbook 的运行汇总信息. 如下所示:

		```
		{
		  "uuid": "01c7090a-e202-4fb4-9ac7-079965729c86",
		  "counter": 7,
		  "stdout": "\r\nPLAY RECAP *********************************************************************\r\n\u001b[0;32mlocalhost,\u001b[0m                 : \u001b[0;32mok=2   \u001b[0m changed=0    unreachable=0    failed=0   \r\n",
		  "start_line": 10,
		  "end_line": 14,
		  "event": "playbook_on_stats",
		  "event_data": {
		    "playbook": "test.yml",
		    "playbook_uuid": "34437b34-addd-45ae-819a-4d8c9711e191",
		    "changed": {

		    },
		    "dark": {

		    },
		    "failures": {

		    },
		    "ok": {
		      "localhost,": 2
		    },
		    "processed": {
		      "localhost,": 1
		    },
		    "skipped": {

		    },
		    "artifact_data": {

		    },
		    "pid": 10640
		  },
		  "pid": 10640,
		  "created": "2018-06-07T14:54:58.424603"
		}

		```

#### 1.2 安装
pip 安装
```
$ pip install ansible-runner ansible
```

源码安装
```
$ git clone git://github.com/ansible/ansible-runner
$ python setup.py install 

或者 

$ pip install .
```

编译 pyhton 分发版本
```
# 生成一个 wheel 安装包
$ make dist 

# 生成 tarball 分发包
$ make sdist
```

编译 docker 镜像
```
# 基于 centos
$ make image
```

编译 rpm 包, 依赖 docker-compose
```
$ make rpm
```

### 2. 发送 Runner 状态与事件到第三方系统
#### 2.0 事件信息的数据结构

Ansible Runner 可以存储事件和状态数据在本地, 也可以将这些信息发送到远端接口.

状态信息: 状态信息在 Ansible Runner 的状态发生改变时([Runner.status_handler](https://ansible-runner.readthedocs.io/en/latest/python_interface.html#runnerstatushandler)), 发送如下格式信息.

```
{"status": "running", "runner_ident": "XXXX" }
```

ansible event : 在 Playbook 运行过程中, 每次从 Ansible 收到 Event [Playbook and Host Events](https://ansible-runner.readthedocs.io/en/latest/intro.html#artifactevents)时, 发送如下格式信息:
```
{"runner_ident": "XXXX", <rest of event structure }
```

#### 2.1 [ansible-runner-http](https://github.com/ansible/ansible-runner-http) 通过 HTTP 发送状态及事件信息

通过 http POST json 格式数据到一个远程的 URL.

安装
```
$ pip install ansible-runner-http
```

配置, 可以参考 [env/setting - Settings for Runner itself](https://ansible-runner.readthedocs.io/en/latest/intro.html#runnersettings)
- `runner_http_url`: 接受 POST 数据的 URL
- `runner_http_headers`: POST 数据时的 请求头.

ansible-runner-http 支持unix socket 的配置方式
- `runner_http_url`: unix socket 路径.
- `runner_http_path`: The path that will be included as part of the request to the socket

如下变量支持使用*环境变量*的配置方式
- `RUNNER_HTTP_URL`
- `RUNNER_HTTP_PATH`


#### 2.2 ZeroMQ Status/Evcent Emitter Plugin
TODO

#### 2.3 自定义 数据和事件 接受插件
在编写插件接口, 并 picked 成能被 Ansible Runner 的数据时, 需要首先完成如下步骤:

- 在插件中, 声明模块作为一个 Ansible Runner 的入口
	
	```
	# 可以参考 ansible-runner-http 作为参考
	entry_points=('ansible_runner.plugins': 'modname = your_python_package_name')
	```

- 在 插件 包的顶层实现 `status_handler()` 和 `event_handler()` 方法.  可以参考 [ansible-runner-http envet.py](https://github.com/ansible/ansible-runner-http/blob/master/ansible_runner_http/events.py) 和 [ansible-runner-http __init__.py](https://github.com/ansible/ansible-runner-http/blob/master/ansible_runner_http/__init__.py)

### 3. Ansible Runner 使用指南
#### 3.1 命令行使用
```
usage: ansible-runner [-h] [--version] [-m MODULE | -p PLAYBOOK | -r ROLE]
                      [-b BINARY] [--hosts HOSTS] [-i IDENT]
                      [--rotate-artifacts ROTATE_ARTIFACTS]
                      [--roles-path ROLES_PATH] [--role-vars ROLE_VARS]
                      [--role-skip-facts] [--artifact-dir ARTIFACT_DIR]
                      [--inventory INVENTORY] [-j] [-v] [-q]
                      [--cmdline CMDLINE] [--debug] [--logfile LOGFILE]
                      [-a MODULE_ARGS] [--process-isolation]
                      [--process-isolation-executable PROCESS_ISOLATION_EXECUTABLE]
                      [--process-isolation-path PROCESS_ISOLATION_PATH]
                      [--process-isolation-hide-paths PROCESS_ISOLATION_HIDE_PATHS]
                      [--process-isolation-show-paths PROCESS_ISOLATION_SHOW_PATHS]
                      [--process-isolation-ro-paths PROCESS_ISOLATION_RO_PATHS]
                      {run,start,stop,is-alive} private_data_dir
```

ansible-runner 子命令
- `run` : 作为前台进程运行, 直到 Ansible 结束. 在前台运行时, 其结果与 ansible 产生的结果一样.
- `start` : 作为后台进程运行, 并生成 pid 文件 和 daemon.log 
- `stop` : 终止在后台运行的 ansible-runner 进程.
- `is-alive` : 检查在后台运行的 ansible-runner 的进程状态.

在 ansible-runner 开始运行之后, 无论在前台/后台运行, 否会产生 `artifacts` 目录, 保存运行时产生的相关信息及结果.

示例:
```
# 执行完成之后, 可以查看 demo/artifacts 下生成的文件.
$ git clone git://github.com/ansible/ansible-runner
$ ansible-runner -p test.yaml run ./demo

```

- 运行 playbook
	
	```
	$ ansible-runner --playbook test.yml run demo
	```

- 运行 ansible 模块
	
	```
	$ ansible-runner -m debug --hosts localhost -a msg=hello run demo
	```

- 直接运行 roles 
	
	```
	$ ansible-runner --role testrole --role-vars SOME_VARS --hosts localhost run demo
	```

- 运行时进程隔离

	Ansible-Runner 支持进程隔离. 进程隔离会使用 tmpfs 作为根目录, 并创建新的名称空间, 以区别于宿主机的名称空间, 同时, 会在进程执行结束后, 自动删除名称空间.

	支持的相关参数:
	```
	--process-isolation-executable PROCESS_ISOLATION_EXECUTABLE 	# 默认使用 bubblewrap.
	--process-isolation-path PROCESS_ISOLATION_PATH
	--process-isolation-hide-paths PROCESS_ISOLATION_HIDE_PATHS
	--process-isolation-show-paths PROCESS_ISOLATION_SHOW_PATHS
	--process-isolation-ro-paths PROCESS_ISOLATION_RO_PATHS
	```

- 使用 `-j` 参数, 输出 json 格式 Event 数据到标准输出, 而不是默认的 文本格式.

- `--runner-artifacts=NUM`, 保存 aritifact 运行结果的数据, 可以清除 旧的 artifact 目录.


#### 3.2 作为 一个 Python 库使用
整个 Ansible Runner 包围绕 `Runner` 对象来运行, helper 方法会返回一个 Runner 对象的实例, 该实例提供一个 返回ansible 执行结果的接口.

Ansible Runner 本身 封装了 Ansible 的执行, 并且添加 插件 和 接口 到 Ansible 的生态系统中, 这些插件和接口主要用于收集额外信息, 存储/处理 结果和事件信息.

##### 3.2.1 Helper 接口
Helper 接口提供一个快速的方式用于提供 运行 Ansible Runner 进程所需的输入参数.

- `run()` : `ansible_runner.interface.run()`
	
	获取输入参数并执行 同步执行 Ansible. `run()` 接口在前台执行 Ansible 命令, 并在执行结束后, 返回 `Runner 对象`.

	输入参数可以通过 函数参数传入, 或者 在 `private_data_dir` 中提供.

- `run_async()` : `ansible_runner.interface.run_async()`
	
	异步执行 Ansible, 返回一个 包含 thread 对象和 Runner 对象的 元祖. 返回的 Runner 对象可以在执行中被访问.

##### 3.2.2 Runner 对象 
Runner 对象是 Ansible 执行本身, 它封装了 Ansible 的执行和输出结果. 

- `rc`: Ansible 进程的返回码
- `status` : Ansible 进程的当前状态, 为下列标志 之一:
	- `unstarted`: Runner 任务已经开始被创建, 但尚未开始执行.
	- `successful`: Ansible 进程执行成功.
	- `failed`: Ansible 进程执行失败.

- `ansible_runner.runner.Runner.stdout`: 返回一个 打开的文件描述符, 包含 Ansible 进程执行的输出结果.
- `ansible_runner.runner.Runner.events`: 是一个生成器, 返回字典形式的 Playbook 和 Host 事件信息.
- `ansible_runner.runner.Runner.stats` : 属性, 以 字典 形式返回 the final Playbook stats event from Ansibe. 
- `Runner.event_handler` 传递给 `Runner.__init__`, 每次接收到 Ansible 事件的时候, 都会调用该方法. 可以使用该方法 `inspect/process/handle` 这些 Ansible 事件.
- `Runner.cancel_callback` 传递给 `Runner.__init__` 和 `ansible_runner.interface.run()`.  该方法会在每次执行 `ansible_runner.interface.run()` 事件循环迭代的时候调用. 返回 `True` 表明 Runner 取消或者被停止; 返回 `False` 表示 允许继续执行 Runner.
- `Runner.finished_callback` 传给 `Runner.__init__` 和 `ansible_runner.interface.run()` 接口. 一旦 Ansible 进程被停止, 在 Runner 事件循环结束之前, 该方法会被马上调用.
- `Runner.status_handler` 传递给 `Runner.__init__` 和 `ansible_runner.interface.run()` 接口函数. 该函数可以在每次 `status` 变化时, 被调用. 适用于如下 `status`:
	- `starting` : 准备开始执行, 但尚未开始执行.
	- `running` : Ansible Task 正在运行中.
	- `canceled` : Task 被手动取消, 无论是通过 回调函数, 还是 命令行.
	- `timeout` : `env/settings` 中的超时时间被触发.
	- `failed` : Ansible 进程失败.


使用示例: 执行 playbook
```
import ansible_runner

r = ansible_runner.run(private_data_dir="/tmp/demo", playbook="test.yaml")
print("{}.{}".format(r.status, r.rc))

### successful: 0
for each_host_event in r.events:
    print(each_host_event["event"])

print("Final Status: ")
print(r.stats)
```

使用示例: 执行单个 Ansible 模块
```
import ansible_runner
r = ansible_runner.run(private_data_dir='/tmp/demo', host_pattern='localhost', module='shell', module_args='whoami')
print("{}: {}".format(r.status, r.rc))
# successful: 0
for each_host_event in r.events:
    print(each_host_event['event'])
print("Final status:")
print(r.stats)
```

#### 3.3 作为一个容器使用
```
$ docker run --rm -e RUNNER_PLAYBOOK=test.yml ansible/ansible-runner:latest
```