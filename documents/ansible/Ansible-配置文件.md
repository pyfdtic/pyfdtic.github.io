---
title: Ansible-配置文件
date: 2018-03-15 15:49:20
categories:
- DevOps
tags:
- ansible
---

[Ansible 学习总结](https://pyfdtic.github.io/2018/03/14/Ansible-%E5%AD%A6%E4%B9%A0%E6%80%BB%E7%BB%93/)

ansible 配置文件 : ansible.cfg, ansible 使用如下位置和顺序来查找 ansible.cfg 文件
- `ANSIBLE_CONFIG` 环境变量指向的文件
- `./ansible.cfg` 
- `~/.ansible.cfg`
- `/etc/ansible/ansible.cfg`

`ansible.cfg` 有 `defaults`, `ssh_connection`, `paramiko`, `accelerate`四个配置段.

## 一. defaults 段

| 配置名称 | 环境变量 | 默认值 |
| --- | --- | ---|
| hostfile |  ANSIBLE_HOSTS |  /etc/ansible/hosts | 
| library  | ANSIBLE_LIBRARY  | (none) | 
| roles_path  | ANSIBLE_ROLES_PATH | /etc/ansible/roles | 
| remote_tmp  | ANSIBLE_REMOTE_TEMP | $HOME/.ansible/tmp | 
| module_name  | (none) | command | 
| pattern  | (none) |  * | 
| forks  | ANSIBLE_FORKS  | 5 | 
| module_args  | ANSIBLE_MODULE_ARGS  | (empty string) | 
| module_lang |  ANSIBLE_MODULE_LANG |  en_US.UTF-8 | 
| timeout  | ANSIBLE_TIMEOUT |  10 | 
| poll_interval  | ANSIBLE_POLL_INTERVAL  | 15 | 
| remote_user  | ANSIBLE_REMOTE_USER current  | user | 
| ask_pass  | ANSIBLE_ASK_PASS |  false | 
| private_key_file  |  ANSIBLE_PRIVATE_KEY_FILE |  (none) | 
| sudo_user  | ANSIBLE_SUDO_USER  | root | 
| ask_sudo_pass  | ANSIBLE_ASK_SUDO_PASS  | false | 
| remote_port  | ANSIBLE_REMOTE_PORT  | (none) | 
| ask_vault_pass  | ANSIBLE_ASK_VAULT_PASS  | false | 
| vault_password_file  | ANSIBLE_VAULT_PASSWORD_FILE  | (none) | 
| ansible_managed  | (none)  | `Ansible managed: { file} modi ed on %Y-%m-%d %H:%M:%S by {uid} on {host}` |
| syslog_facility  | ANSIBLE_SYSLOG_FACILITY |  LOG_USER |
| keep_remote_ les  | ANSIBLE_KEEP_REMOTE_FILES |  true |
| sudo  | ANSIBLE_SUDO  | false |
| sudo_exe | ANSIBLE_SUDO_EXE |  sudo |
| sudo_flags  | ANSIBLE_SUDO_FLAGS |  -H |
| hash_behaviour |  ANSIBLE_HASH_BEHAVIOUR  | replace |
| jinja2_extensions  | ANSIBLE_JINJA2_EXTENSIONS  | (none) |
| su_exe  | ANSIBLE_SU_EXE |  su |
| su  | ANSIBLE_SU  | false |
| su_flags | ANSIBLE_SU_FLAGS  | (empty string) |
| su_user  | ANSIBLE_SU_USER  | root |
| ask_su_pass  | ANSIBLE_ASK_SU_PASS |  false |
| gathering  | ANSIBLE_GATHERING  | implicit |
| action_plugins  | ANSIBLE_ACTION_PLUGINS |  /usr/share/ansible_plugins/action_plugins |
| cache_plugins  | ANSIBLE_CACHE_PLUGINS  | /usr/share/ansible_plugins/cache_plugins |
| callback_plugins |  ANSIBLE_CALLBACK_PLUGINS  | /usr/share/ansible_plugins/callback_plugins |
| connection_plugins  | ANSIBLE_CONNECTION_PLUGINS  | /usr/share/ansible_plugins/connection_plugins |
| lookup_plugins  | ANSIBLE_LOOKUP_PLUGINS |  /usr/share/ansible_plugins/lookup_plugins |
| vars_plugins  | ANSIBLE_VARS_PLUGINS |  /usr/share/ansible_plugins/vars_plugins |
| filter_plugins  | ANSIBLE_FILTER_PLUGINS  | /usr/share/ansible_plugins/ lter_plugins |
| log_path  | ANSIBLE_LOG_PATH |  (empty string) |
| fact_caching |  ANSIBLE_CACHE_PLUGIN | memory |
| fact_caching_connection |  ANSIBLE_CACHE_PLUGIN_CONNECTION  | (none) |
| fact_caching_prefix  | ANSIBLE_CACHE_PLUGIN_PREFIX |  ansible_facts |
| fact_caching_timeout  | ANSIBLE_CACHE_PLUGIN_TIMEOUT  | 86400 (seconds) |
| force_color  | ANSIBLE_FORCE_COLOR |  (none) |
| nocolor  | ANSIBLE_NOCOLOR |  (none) |
| nocows  | ANSIBLE_NOCOWS  | (none) |
| display_skipped_hosts  | DISPLAY_SKIPPED_HOSTS  | true |
| error_on_unde ned_vars  | ANSIBLE_ERROR_ON_UNDEFINED_VARS  | true |
| host_key_checking  | ANSIBLE_HOST_KEY_CHECKING  | true |
| system_warnings  | ANSIBLE_SYSTEM_WARNINGS  | true |
| deprecation_warnings  | ANSIBLE_DEPRECATION_WARNINGS  | true |
| callable_whitelist  | ANSIBLE_CALLABLE_WHITELIST  | (empty list) |
| command_warnings  | ANSIBLE_COMMAND_WARNINGS  | false |
| bin_ansible_callbacks  | ANSIBLE_LOAD_CALLBACK_PLUGINS  | false |

示例:
```
[defaults]
hostfile = hosts
remote_user = ec2-user
private_key_file = /path/to/my_private_key
host_key_checking = False       # 关闭 host key 检查.
forks = 20
```
## 二. ssh_connection 段

| 配置名称 | 环境变量 | 默认值 |
| --- | --- | ---|
| ssh_args | ANSIBLE_SSH_ARGS | `-o ControlMaster=auto -o ControlPersist=60s -o ControlPath="$ANSIBLE_SSH_CONTROL_PATH”` |
| control_path | ANSIBLE_SSH_CONTROL_PATH  | `%(directory)s/ansible-ssh-%%h-%%p-%%r` | 
| pipelining  | ANSIBLE_SSH_PIPELINING  | false | 
| scp_if_ssh  | ANSIBLE_SCP_IF_SSH |  false | 

## 三. paramiko 段

| 配置名称 | 环境变量 | 默认值 |
| --- | --- | ---|
| record_host_keys | ANSIBLE_PARAMIKO_RECORD_HOST_KEYS |  true | 
| pty  | ANSIBLE_PARAMIKO_PTY  | true | 


## 四. accelerate 段
不推荐使用.