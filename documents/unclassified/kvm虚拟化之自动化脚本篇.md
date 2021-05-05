---
title: kvm虚拟化之自动化脚本篇
date: 2018-03-16 16:49:19
categories:
- 云计算与虚拟化
tags:
- kvm
- guestfish
- libvirsh
---

## 一. 环境准备
### 1. 基本原理
1. 使用 nmap 等网络工具, 获取局域网内未使用IP地址, 使用 [guestfish](http://www.cnblogs.com/yanjingnan/p/7081605.html) 工具编辑 镜像内的网关网络配置文件.
2. 使用自定义的 centos 镜像, 以及 镜像配置 xml 配置, 创建虚拟机.
3. 虚拟机网络环境使用**桥接**.
4. 虚拟机内部启用 vnc , 用于在 ssh 无法使用时的替代品.

### 2. 基本环境.
1. 所有虚拟机及配置都位于 `/data` 目录下, 可以修改.
2. `/data/base` 下存放的是基础文件, 包含相关脚本, 虚拟机模板文件, 虚拟机镜像文件等.
    ```Bash
    base/
    ├── bin
    │   ├── kvm_add_vm.sh
    │   └── kvm_auto_install.sh
    ├── centos6-BASE.qcow2
    ├── centos7-BASE.qcow2
    ├── ip_pool
    │   ├── gen_ip_list.sh
    │   ├── unused_ip.list
    │   └── used_ip.list
    └── template.xml
    ```
3. 虚拟机的管理使用 `virsh` 管理名利集.

4. 配置完成的虚拟宿主机, 可以使用 `virsh` 工具实现远程管理.

5. 虚拟网段使用 192.169 开头的网段.

## 二. 系统环境初始化

参考代码: [kvm-base script](https://github.com/pyfdtic/scripts/tree/master/kvm-base)

### 1. 脚本示例
```Bash
$ cat kvm_auto_install.sh

# 所有相关的镜像,脚本,模板 从局域网可以访问的一台文件服务器上下载到本地.
set -e
KVM_IMG_DIR=/data/kvm_img
BASE_IMG=http://myftp.example.com/iso/base-img.tar.gz

LOCAL_INTERFACE=`ls /etc/sysconfig/network-scripts/ |grep ifcfg-e |head -1  |sed s/ifcfg-//g`

# 判断系统是否支持kvm, 是否有kvm相关模块.
lsmod | grep kvm &>/dev/null && lsmod |grep -E '(kvm_intel|kvm_amd)' &>/dev/null
if [ $? -ne 0 ];then
    exit 2 && echo 'KVM mode is not loaded!'
fi

# 判断 cpu 是否支持 kvm 虚拟化.
grep -E "(vmx|svm)" /proc/cpuinfo &>/dev/null
if [ $? -ne 0 ];then
    exit 3 && echo 'You computer is not SUPPORT Virtual Tech OR the VT is NOT OPEN!'
fi

# 虚拟宿主机是否可以联网, 主要用于 BASE_IMG 的下载, 如果在局域网, 可以注释掉.
ping 114.114.114.114 -c 2
if [ $? -ne 0 ];then
    exit 4 && echo 'Cannot connect to Internet,PLZ check you Network!'
fi

# 安装相关镜像管理工具, 网络管理工具, 虚拟机管理工具, 及 BASE_IMG.
function GET_KVM_PACKAGES(){
    yum -y install qemu-kvm qemu-kvm-tools && ln -sv /usr/libexec/qemu-kvm /usr/bin/qemu-kvm
    yum -y install libvirt libvirt-client virt-install virt-manager virt-viewer && service libvirtd start
    yum -y install libguest* libvirt* wget tigervnc tigervnc-server bridge-utils nmap
    # grep 192.168.1.211 /etc/hosts || echo "192.168.1.211    myftp.example.com" >>/etc/hosts
    mkdir -pv $KVM_IMG_DIR
    cd /tmp && wget $BASE_IMG && tar xf /tmp/base-img.tar.gz -C $KVM_IMG_DIR && chown -R qemu:qemu $KVM_IMG_DIR 
}

# 创建网桥
function ADD_NET_BRIDGE() {
  yum -y install bridge-utils
  virsh iface-bridge $LOCAL_INTERFACE br0
} 

GET_KVM_PACKAGES
ADD_NET_BRIDGE
```

### 2. 脚本使用方法
```Bash
$ bash kvm_auto_install.sh
```
## 三. kvm 镜像模板
### 1. 模板示例
```Bash
<domain type='kvm'>
  <name>%VM_NAME%</name>
  <uuid>%VM_UUID%</uuid>
  <memory unit='KiB'>4194304</memory>
  <currentMemory unit='KiB'>%VM_MEM_NOW%</currentMemory>
  <vcpu placement='static' current='%VM_VCPU%'>6</vcpu>
  
  <os>
    <type arch='x86_64' machine='%VM_MACHINE%'>hvm</type>
  </os>
  <features>
    <acpi/>
    <apic/>
  </features>
  <cpu match='exact'>
    <model fallback='allow'>kvm64</model>
    <feature policy='require' name='vmx'/>
  </cpu>
  <clock offset='localtime'/>
  <on_poweroff>destroy</on_poweroff>
  <on_reboot>restart</on_reboot>
  <on_crash>restart</on_crash>

  <pm>
    <suspend-to-mem enabled='no'/>
    <suspend-to-disk enabled='no'/>
  </pm>
  
  <devices>
    <emulator>/usr/libexec/qemu-kvm</emulator>
    <disk type='file' device='disk' >
      <driver name='qemu' type='qcow2' cache='none'/>
      <source file='%VM_DISK_PATH%'/>
      <target dev='vda' bus='virtio'/>
      <boot order='1'/>
    </disk>

    <controller type='virtio-serial' index='0'>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x04' function='0x0'/>
    </controller>

    <interface type='bridge'>
      <mac address='%VM_NET_MAC%'/>
      <source bridge='br0'/>
      <model type='virtio'/>
      <target dev='vnet0'/>
      <alias name='net0'/>
    </interface>
    <interface type='bridge'>
      <mac address='%VM_NET_MAC2%'/>
      <source bridge='virbr0'/>
      <model type='virtio'/>
      <target dev='vnet1'/>
      <alias name='net1'/>
    </interface>
    <serial type='pty'> 
      <target port='0'/>
    </serial>
    <console type='pty'>
      <target type='serial' port='0'/>
    </console>
    <input type='tablet' bus='usb'/>
    <input type='mouse' bus='ps2'/>

    <graphics type='vnc' port='5900' autoport='yes' listen='0.0.0.0' keymap='en-us'>  
      <listen type='address' address='0.0.0.0'/>
    </graphics>
    <video>
      <model type='vga' vram='9216' heads='1'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x02' function='0x0'/>
    </video>
    <memballoon model='virtio'>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x05' function='0x0'/>
    </memballoon>
  </devices>
</domain>
```
### 2. 说明
1. 类似 `%XXX%` 格式的为变量, 在 创建虚拟机 即运行 `kvm_add_vm.sh` 脚本时, 会自动替换为相关参数.
2. 模板中的系统相关配置根据需要修改, 如平台类型等.
3. 虚拟机默认开始 vnc , 用于创建 console 连接到虚拟机, 作为 ssh 无法使用或不支持时的替代方案.
4. 网络,磁盘 等IO设备, 默认使用`virtio`方式增强性能.
5. 虚拟机会有两张网卡.
6. 同时支持 centos6 和 centos7.

## 四. 自动添加 kvm 虚拟机脚本

### 1. 脚本示例
```Bash
$ cat kvm_add_vm.sh

set -e
SYS_KVMIMG_DIR=/data/kvm_img
SYS_REMOTE_IMGURL=http://myftp.example.com/iso/Base-Img.tar.gz
SYS_LOCAL_NETINTERFACE=`ls /etc/sysconfig/network-scripts/ |grep ifcfg-e |head -1  |sed s/ifcfg-//g`
NET_PREFIX='192.168'
NET_POOL=`ip addr |grep -A 3 '\<br0:' |awk -F'.'  '/inet\>/{print $3}'`

# 脚本使用语法格式
if [ $# -ne 3 ] ;then
  echo -e "Usage : $0 VM_CPU VM_MEM(Gb) [ centos6|centos7 ]\nExample : $0 2 4 centos7 " && exit 5
fi 

# 获取虚拟机IP地址(私网)
function GET_VM_IP() {
  mkdir -pv $SYS_KVMIMG_DIR/base/ip_pool/
  UNUSED_IP_LIST=$SYS_KVMIMG_DIR/base/ip_pool/unused_ip.list
  USED_IP_LIST=$SYS_KVMIMG_DIR/base/ip_pool/used_ip.list
  :> $UNUSED_IP_LIST
  :> $USED_IP_LIST

  for i in {19..253} ;do echo $NET_PREFIX.$NET_POOL.$i >>$UNUSED_IP_LIST ;done
  nmap -n -sP -PI -PT $NET_PREFIX.$NET_POOL.0/24 |awk '/^Nmap/{print $5}' |grep $NET_PREFIX > $USED_IP_LIST
  for m in `cat ${USED_IP_LIST}`;do sed -i "/$m/d"  $UNUSED_IP_LIST ;done
}

GET_VM_IP

VM_NET_IP=$(head -$((`echo $RANDOM`%`cat $SYS_KVMIMG_DIR/base/ip_pool/unused_ip.list |wc -l`)) $SYS_KVMIMG_DIR/base/ip_pool/unused_ip.list |tail -1)

# 虚拟机 CPU,MEM,OS_Version, MAC, GATEWAY 等配置.
VM_VCPU=$1
VM_MEM_NOW=$(($2*1024*1024))
VM_VERSION=`echo $3 |tr A-Z a-z`
VM_NAME=$VM_VERSION-$VM_NET_IP
VM_UUID=`uuidgen`
VM_MACHINE=`qemu-kvm -machine ? |grep default |awk '{print $1}'`
VM_DISK_PATH=$SYS_KVMIMG_DIR/$VM_NET_IP/${VM_NAME}.qcow2
VM_NET_MAC=52:54:00:b0:0$NET_POOL:`echo $VM_NET_IP |awk -F'.' '{print $4}' |xargs printf %x`
VM_NET_MAC2=52:54:00:b1:0$NET_POOL:`echo $VM_NET_IP |awk -F'.' '{print $4}' |xargs printf %x`
VM_NET_GATEWAY=`echo $VM_NET_IP |awk -F'.' '{print $1"."$2"."$3"."1}'`

function CONFIG_TEMPLATE() {
  mkdir $SYS_KVMIMG_DIR/$VM_NET_IP && cp $SYS_KVMIMG_DIR/base/$VM_VERSION-BASE.qcow2 $SYS_KVMIMG_DIR/$VM_NET_IP/${VM_NAME}.qcow2 && cp $SYS_KVMIMG_DIR/base/template.xml $SYS_KVMIMG_DIR/$VM_NET_IP/${VM_NAME}.xml && chown -R qemu:qemu $SYS_KVMIMG_DIR/$VM_NET_IP/
  sed -i "s/%VM_NAME%/$VM_NAME/g"  $SYS_KVMIMG_DIR/$VM_NET_IP/${VM_NAME}.xml
  sed -i "s/%VM_UUID%/$VM_UUID/g"  $SYS_KVMIMG_DIR/$VM_NET_IP/${VM_NAME}.xml
  sed -i "s/%VM_MEM_NOW%/$VM_MEM_NOW/g"  $SYS_KVMIMG_DIR/$VM_NET_IP/${VM_NAME}.xml
  sed -i "s/%VM_VCPU%/$VM_VCPU/g"  $SYS_KVMIMG_DIR/$VM_NET_IP/${VM_NAME}.xml
  sed -i "s/%VM_MACHINE%/$VM_MACHINE/g"  $SYS_KVMIMG_DIR/$VM_NET_IP/${VM_NAME}.xml
  sed -i "s@%VM_DISK_PATH%@$VM_DISK_PATH@g"  $SYS_KVMIMG_DIR/$VM_NET_IP/${VM_NAME}.xml
  sed -i "s@%VM_NET_MAC%@$VM_NET_MAC@g"  $SYS_KVMIMG_DIR/$VM_NET_IP/${VM_NAME}.xml
  sed -i "s@%VM_NET_MAC2%@$VM_NET_MAC2@g"  $SYS_KVMIMG_DIR/$VM_NET_IP/${VM_NAME}.xml
}

# 修改镜像中的网络配置.
function PUT_IP_IN() {
#  if [ $VM_VERSION = 'centos6'  ];then
#   VM_NET_CONFIG=eth1
#  else 
    VM_NET_CONFIG=`virt-ls -a $SYS_KVMIMG_DIR/$VM_NET_IP/${VM_NAME}.qcow2 /etc/sysconfig/network-scripts/ |awk -F'-' '/ifcfg-eth0/{print $2}'`
#  fi

  cat <<EOF >> $SYS_KVMIMG_DIR/$VM_NET_IP/ifcfg-$VM_NET_CONFIG
TYPE=Ethernet
BOOTPROTO=static
DEVICE=$VM_NET_CONFIG
ONBOOT=yes  
IPADDR=$VM_NET_IP
NETMASK=255.255.255.0
GATEWAY=$VM_NET_GATEWAY
DNS1=114.114.114.114
EOF

  virt-copy-in -a $VM_DISK_PATH $SYS_KVMIMG_DIR/$VM_NET_IP/ifcfg-$VM_NET_CONFIG  /etc/sysconfig/network-scripts/

}

# 创建虚拟机, 并展示创建结果.
function START_VM() {
  virsh define $SYS_KVMIMG_DIR/$VM_NET_IP/${VM_NAME}.xml && virsh start $VM_NAME && echo -e "\nVM IPADDRESS:   $VM_NET_IP" && virsh dominfo $VM_NAME 

}

CONFIG_TEMPLATE
PUT_IP_IN
START_VM
```

### 2. 使用方法
```Bash
$ kvm_add_vm.sh VM_CPU VM_MEM(Gb) [ centos6|centos7 ]
```
### 3. 查看
生成虚拟机名称格式为 `VM_NAME=$VM_VERSION-$VM_NET_IP`, 如 `centos6_192.168.1.1`.

生成虚拟机之后, 可以使用 `virsh` 相关命令实现本机或远程虚拟主机管理.
```Bash
$ virsh list
$ virsh dominfo centos6_192.168.1.1
```

## 五. 虚拟镜像管理利器: guestfish && virsh
guestfish 是一套虚拟机镜像管理的利器，提供一系列对镜像管理的工具，也提供对外的API。
guestfish主要包含以下工具：

- guestfish interactive shell  挂载镜像，并提供一个交互的shell。
- guestmount mount guest filesystem in host 将镜像挂载到指定的目录。
- guestumount unmount guest filesystem 卸载镜像目录。

![libvirsh 架构图](/imgs/virtualization/libvirsh.png)

命令行说明:

| 命令 | 说明 |
| --- | --- |
|virt-alignment-scan         |镜像块对齐扫描。|
|virt-builder                |quick image builder 快速镜像创建。|
|virt-cat(1)                 |display a file 显示镜像中文件内容。|
|virt-copy-in(1)             |copy files and directories into a VM 拷贝文件到镜像内部。|
|virt-copy-out(1)            |copy files and directories out of a VM 拷贝镜像文件出来。|
|virt-customize(1)           |customize virtual machines 定制虚拟机镜像|
|virt-df(1)                  |free space 查看虚拟机镜像空间使用情况。|
|virt-diff(1)                |differences 不启动虚拟机的情况下，比较虚拟机内部两份文件差别。|
|virt-edit(1)                |edit a file 编辑虚拟机内部文件。|
|virt-filesystems(1)         |display information about filesystems, devices, LVM 显示镜像文件系统信息。|
|virt-format(1)              |erase and make blank disks 格式化镜像内部磁盘。|
|virt-inspector(1)           |inspect VM images 镜像信息测试。|
|virt-list-filesystems(1)    |list filesystems 列出镜像文件系统。|
|virt-list-partitions(1)     |list partitions 列出镜像分区信息。|
|virt-log(1)                 |display log files 显示镜像日志。|
|virt-ls(1)                  |list files 列出镜像文件。|
|virt-make-fs(1)             |make a filesystem 镜像中创建文件系统。|
|virt-p2v(1)                 |convert physical machine to run on KVM 物理机转虚拟机。|
|virt-p2v-make-disk(1)       |make P2V ISO 创建物理机转虚拟机ISO光盘。|
|virt-p2v-make-kickstart(1)  |make P2V kickstart 创建物理机转虚拟机kickstart文件。|
|virt-rescue(1)              |rescue shell 进去虚拟机救援模式。|
|virt-resize(1)              |resize virtual machines 虚拟机分区大小修改。|
|virt-sparsify(1)            |make virtual machines sparse (thin-provisioned) 镜像稀疏空洞消除。|
|virt-sysprep(1)             |unconfigure a virtual machine before cloning 镜像初始化。|
|virt-tar(1)                 |archive and upload files 文件打包并传入传出镜像。|
|virt-tar-in(1)              |archive and upload files 文件打包并传入镜像。|
|virt-tar-out(1)             |archive and download files 文件打包并传出镜像。|
|virt-v2v(1)                 |convert guest to run on KVM 其他格式虚拟机镜像转KVM镜像。|
|virt-win-reg(1)             |export and merge Windows Registry keys windows注册表导入镜像。|
|libguestfs-test-tool(1)     |test libguestfs 测试libguestfs|
|libguestfs-make-fixed-appliance(1)          |make libguestfs fixed appliance|
|hivex(3)                    |extract Windows Registry hive 解压windows注册表文件。|
|hivexregedit(1)             |merge and export Registry changes from regedit-format files 合并、并导出注册表文件内容。|
|hivexsh(1)                  |Windows Registry hive shell window注册表修改交互的shell。|
|hivexml(1)                  |convert Windows Registry hive to XML 将window注册表转化为xml|
|hivexget(1)                 |extract data from Windows Registry hive 得到注册表键值。|
|guestfsd(8)                 |guestfs daemon guestfs服务。|