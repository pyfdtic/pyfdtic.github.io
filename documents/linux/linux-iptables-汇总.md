
# 一. 背景知识
## 1. 相关网络背景知识

### (1) Linux 主机内部路由
Linux 在 内核中维护由一个路由表, 报文进入本机后, 由该路由表判断目标地址; 报文离开本机之前, 判断经由那个接口发出.

### (2) TCP 报文格式

    erg : 紧急指针是否有效.
    ack : 确认号是否有效.
    psh : 不再缓冲中停留, 直接发往内核.
    rst : reset, 重置.
    syn : 同步, 请求建立连接. 
    fin : 结束, 请求关闭连接.

### (3) TCP 协议的三次握手和四次断开

### (4) TCP 的有限状态机

## 2. iptables 简介

iptables 是 Linux 主机上的防火墙软件, 由两部分构成:
1. iptables : 命令行工具, 用于编写 规则, 并可以实现规则的语法检查.
2. netfilter : 网络过滤器, 内核中工作为 TCP/IP 协议栈上的框架.

## 3. netfilter 的四表五链
### (0) 表与链

每个钩子函数上可以防止 n 条规则, 数据包在每条规则上依次匹配, 对应于每个钩子上的多条规则成为一个 **链(CHAIN)**;

每个功能(表)有多个链, 所以成为 **表**

### (1) 四表

- filter : 包过滤
    `input --> forward --> output`

- NAT : 地址转换
    `prerouting --> output --> postrouting`

- mangle : 修改报文首部中的某些信息;
    `prerouting --> input --> forward --> output --> postrouting`

- raw : 关闭 nat 表上启动的链接追踪功能.
    `prerouting --> output`     

### (2) 五链(5 个 hooks functions)
- prerouting : 进入本机后, 路由功能发生之前
- input : 到达本机内部
- output : 由本机发出
- forward : 由本机转发
- postrouting : 路由功能发生之后, 即将离开本机之前.


### (3) 报文流向经由的位置
- 到本机内部
    `prerouting --> input`

- 由本机发出
    `output --> postrouting`

- 由本机转发
    `prerouting --> forward --> postrouting`

### (4) 链上规则的检查次序

匹配的`内部机制` : 检查 IP 首部, 检查 TCP,UDP,ICMP 首部; 同时, 基于扩展机制, 可以进行额外的检查, 例如做链接追踪等.

- 每个 链 上的规则检查为`依次检查`; 
- 当某个链上的某个规则被匹配之后, 则执行该规则的 target, 该链上的其他规则不再执行;
- 钩子函数(表)的优先级
    在每个钩子(链)上, 规则是按不同的功能(表), 分别存放的. 每个数据包到来之后, 按表的优先级, 依次检查每一个链, 完成之后, 转到下一个链.

    优先级 : **raw > mangle > nat > filter**

![数据包过滤优先级表]()

### (5) 规则编写最佳实践
写作规则的**最佳实践**:
- 同类规则 : 匹配范围`小`的放在最前面;
- 同类规则, 如果能`合并`, 则尽量合并;
- 不同类规则 : 匹配范围几率较大的放前面;
- 应该为每个链, 设置`默认规则`;


# 二. iptables 规则编写
## 1. 添加规则时的考量点
1. 要实现的功能 --> 判断添加到哪个表上;
2. 报文流向及经由路径 --> 判断添加到哪个链上;

## 2. 规则和链的计数器
- pkts: 由规则或链匹配到的报文的个数；
- bytes：由规则或链匹配到的所有报文大小之和；
![iptables 计数器]()

## 3. 规则的编写.
**如果同时指定多个匹配条件, 则默认多个条件需要同时被满足.**


    iptables [-t TABLE] SUBCOMMAND CHAIN CRETERIA -j TARGET

        -t TABLE:
            默认为filter, 共有filter, nat, mangle, raw四个可用；

        SUBCOMMAND：
            链：
                -F：flush，清空指定表的指定链上所有规则；省略链名时，清空表中的所有链；
                
                -N：new, 新建一个用户自定义的链；自定义链只能作为默认链上的跳转对象，即在默认链通过引用来生效自定义链；
                
                -X：drop，删除用户自定义的空链；非空自定义链和内置链无法删除；
                
                -Z：zero，将规则的计数器置0；
                
                -P：policy，设置链的默认处理机制；当所有都无法匹配或有匹配有无法做出有效处理机制时，默认策略即生效；
                    filter表的可用策略：ACCEPT, DROP, REJECT
                
                -E：rename，重命名自定义链；

                注意：被引用中的链，无法删除和改名

            规则：
                -A：append，在链尾追加一条规则；
                
                -I：insert，在指定位置插入一条规则；
                
                -D：delete，删除指定的规则；rule or rulenum
                
                -R：replace，替换指定的规则；
                
                    $ iptable -t filter -R INPUT 1 -s 172.16.100.2 -d 172.16.100.11 -p tcp -i eth0 -j ACCEPT

            查看：
                -L：list，列出指定链上的所有规则；
                    -n: numeric，以数字格式显示地址和端口号，即不反解；
                    
                    -v: verbose，详细格式，显示规则的详细信息，包括规则计数器等；
                    
                    -vv:
                    
                    -vvv:
                    
                    --line-numbers: 显示规则编号；
                    
                    -x: exactly，显示计数器的精确值；


                pkts bytes target     prot opt in     out     source               destination
                    pkts: 被本规则所匹配到的包个数；
                    bytes：被本规则所匹配到的所包的大小之和；
                    target: 处理目标 （目标可以为用户自定义的链）
                    prot: 协议 {tcp, udp, icmp}
                    opt: 可选项
                    in: 数据包流入接口
                    out: 数据包流出接口
                    source: 源地址
                    destination: 目标地址；
        CHAIN :
            指定要添加规则的链;

            可以是自定义链. 注意：报文不可能经由自定义链(不再内核中)，只有在被内置链上的引用才能生效（即做为自定义目标）

        CRETERIA :
            指定匹配条件.

            1. 通用匹配

                -s, --src, --source  IP|Network：检查报文中的源IP地址；

                -d, --dst, --destination：检查报文中的目标IP地址/网段

                -p, --protocol：检查报文中的协议，即ip首部中的protocols所标识的协议；tcp、udp或icmp三者之一；

                -i, --in-interface：数据报文的流入接口；通常只用于PREROUTING, INPUT, FORWARD链上的规则；

                -o, --out-interface：检查报文的流出接口；通常只用于FORWARD, OUTPUT, POSTROUTING链上的规则；

            2. 扩展匹配: 使用 iptables 的模块实现扩展检查机制.
                (1) 隐式扩展 : 
                    ** 如果在通用匹配上使用 -p 选项指明了协议的话，则使用-m选项指明对其协议的扩展就变得可有可无了；

                    1) tcp: -m tcp
                        --dport PORT[-PORT]     # 必须是连续的端口
                        --sport
                        --tcp-flags LIST1 LIST2
                            LIST1: 要检查的标志位；
                            LIST2：在LIST1中出现过的，且必须为1标记位；而余下的则必须为0; 
                            例如：--tcp-flags syn,ack,fin,rst syn # 表示 三次握手的第一次. 等同 --syn 
                        --syn：用于匹配tcp会话三次握手的第一次；新建连接.

                        $ iptable -A INPUT 1 -s 172.16.100.2 -d 172.16.100.11 -p tcp [-m tcp] --dport 80 -j REJECT  # -m tcp 可省略, 因为 -p tcp 指明了协议.

                    2) udp: -m udp
                        --sport
                        --dport

                    3) icmp: -m icmp
                        --icmp[-type]  # ICMP TYPE CODE 表
                            8: echo request, ping 请求
                            0：echo reply, ping 响应

                            # 允许自己 ping 别人. 本机地址 为 172.16.100.11 .
                            $ iptables -A OUTPUT -s 172.16.100.11 -p icmp --icmp-type 8 -j ACCEPT
                            $ iptables -A INPUT -d 172.16.100.11 -p icmp --icmp-type 0 -j ACCEPT

                (2) 显式扩展: 必须指明使用的扩展机制.

                    0) 通用语法格式:

                        -m 模块名称
                            每个模块会引入新的匹配机制；

                    查看可用模块:

                        小写字母，以.so结尾；
                        大写通常指 处理方式.

                    1) multiport扩展：以离散定义多端口匹配；最多指定15个端口；
                    
                        专用选项：
                            --source-ports, --sports PORT[,PORT,...]
                            --destination-ports, --dports PORT[,PORT,...]
                            --ports PORT[,PORT,...]     # 源和目标端口.

                        例子：
                            $ iptables -I INPUT 1 -d 172.16.100.11 -p tcp -m multiport --dports 22,80,443 -j ACCEPT
                            $ iptables -I OUTPUT 1 -s 172.16.100.11 -p tcp -m multiport --sports 22,80,443 -j ACCEPT

                    2) iprange扩展：指定连续的ip地址范围；在匹配非整个网络地址时使用；

                        专用选项：
                            [!] --src-range IP[-IP]     # 也支持单个 ip
                            [!] --dst-range IP[-IP]     # 也支持单个 ip

                        示例：
                            $ iptables -A INPUT -d 172.16.100.11 -p tcp --dport 23 -m iprange --src-range 172.16.100.1-172.16.100.100 -j ACCEPT
                            $ iptables -A OUTPUT -s 172.16.100.11 -p tcp --sport 23 -m iprange --dst-range 172.16.100.1-172.16.100.100 -j ACCEPT

                    3) string扩展：对应用层首部和数据进行检查. 检查报文中出现的字符串，与给定的字符串作匹配；

                        字符串匹配检查算法：实现高效匹配. 两者相近.
                            kmp :  
                            bm : 

                        专用选项：
                            --algo {kmp|bm}
                            --string "STRING"
                            --hex-string "HEX_STRING"：HEX_STRING为编码成16进制格式的字串；


                        示例：
                            $ iptables -I OUTPUT 1 -s 172.16.100.11 -p tcp --sport 80 -m string --string "sex" --algo kmp -j REJECT

                    4) time扩展：基于时间区间做访问控制

                        专用选项：
                            --datestart YYYY[-MM][-DD][hh[:mm[:ss]]]
                            --dattestop YYYY[-MM][-DD][hh[:mm[:ss]]]

                            --timestart 
                            --timestop

                            --weekdays DAY1[,DAY2,...]

                        示例：
                            $ iptables -R INPUT 1 -d 172.16.100.11 -p tcp --dport 80 -m time --timestart 08:30 --timestop 18:30 --weekdays Mon,Tue,Thu,Fri -j REJECT

                    5) connlimit扩展：基于连接数作限制；对每个IP能够发起的并发连接数作限制；

                        专用选项：
                            --connlimit-above [n]   # 包含 n .

                        $ iptables -I INPUT 2 -d 172.16.100.11 -p tcp --dport 22 -m connlimit --connlimit-above 5 -j REJECT

                    6) limit扩展：基于令牌桶算法实现的.基于发包速率作限制；

                        专用选项：令牌桶算法
                            --limit  n[/second|/min|/hour|/day]
                            --limit-burst n  # 突发速率时, 最大速率. 

                        $ iptables -R INPUT 3 -d 172.16.100.11 -p icmp --icmp-type 8 -m limit --limit 10/minute --limit-burst 5 -j ACCEPT   

                        ** limit 仅按一定速率匹配数据, 若限制, 先放过一定速率的数据, 然后阻断.  
                            $ iptables -A FORWARD -p icmp -s 172.16.11.0/24 -m limit --limit 10/s -j ACCEPT
                            $ iptables -A FORWARD -p icmp -s 172.16.11.0/24 -j DROP                       

                    7) state扩展：启用连接追踪模板记录连接，并根据连接匹配连接状态的扩展；
                        启用连接追踪功能之前：简单包过滤防火墙；
                        启用连接追踪功能：带状态检测的包过滤防火墙；
                            # 反弹式木马: 木马可以探测主机开放的端口, 并使用该端口作为客户端,想外发送请求, 从而出入的连接成为 ESTABLISHED 状态.

                        专用选项：
                            --state STATE

                        $ iptables -I INPUT 1 -d 172.16.100.11 -p tcp -m multiport --dport 22,80 -m state --state NEW,ESTABLISHED -j ACCEPT

                        $ iptables -I OUTPUT 1 -d 172.16.100.11 -m state --state ESTABLISHED -j ACCEPT 

                        调整连接追踪功能所能容纳的连接的最大数目：

                            $cat /proc/sys/net/nf_conntrack_max

                            $ lsmod | grep nf_conntrack  # 查看是否打开连接追踪功能.
                            $ modprobe -r nf_conntrack 
                            $ modprobe -r nf_conntrack_ipv4

                        当前追踪的所有连接：

                            /proc/net/nf_conntrack

                        不同协议或连接类型追踪时的时长属性：
                        
                            /proc/sys/net/netfilter/

                        如何放行被动模式下的ftp服务：
                        
                            (1) 装载模块：
                                # modprobe nf_conntrack_ftp

                            (2) 放行请求报文
                                放行入站请求端口为21的请求报文；
                                放行所有状态为ESTABLISHED和RELATED状态的入站报文；

                            (3) 放行出站响应报文
                                放行所有状态为ESTABLISHED的出站报文；

                    8) recent 扩展 : 利用iptables的recent模块来抵御DOS攻击.
                        示例: 
                            iptables -I INPUT  -p tcp --dport 22 -m state --state NEW -m recent --set --name SSH # SSH 只是个名字, 用于日志记录 /var/log/messages .

                            iptables -I INPUT  -p tcp --dport 22 -m state --state NEW -m recent --update --seconds 300 --hitcount 3 --name SSH -j LOG --log-prefix "SSH Attack: "

                            iptables -I INPUT  -p tcp --dport 22 -m state --state NEW -m recent --update --seconds 300 --hitcount 3 --name SSH -j DROP

                            1.利用connlimit模块将单IP的并发设置为3；会误杀使用NAT上网的用户，可以根据实际情况增大该值；

                            2.利用recent和state模块限制单IP在300s内只能与本机建立2个新连接。被限制五分钟后即可恢复访问。

                            下面对最后两句做一个说明：

                            1.第二句是记录访问tcp 22端口的新连接，记录名称为SSH
                            --set 记录数据包的来源IP，如果IP已经存在将更新已经存在的条目

                            2.第三句是指SSH记录中的IP，300s内发起超过3次连接则拒绝此IP的连接。
                            --update 是指每次建立连接都更新列表；
                            --seconds必须与--rcheck或者--update同时使用
                            --hitcount必须与--rcheck或者--update同时使用

                            3.iptables的记录：/proc/net/xt_recent/SSH

                        # 防止被探测 SSH 密码
                            $ iptables -A INPUT -p tcp --dport 22 -m state --state NEW -m recent --set --name SSH --rsource -m recent --name SSH --update --seconds 10 --hitcount 4 --rsource -j DROP


        TARGET：

            -j: jump，跳转目标

                内置目标：

                    ACCEPT : 接受
                    DROP : 丢弃
                    REJECT : 拒绝

                    SNAT
                    DNAT
                    MASQUERADE

                    LOG：日志
                    REDIRECT：端口重定向；
                    RETURN: 返回至调用者；
                    MARK：防火墙标记, 用于 mangle 表中. 见 LVS.


## 4. NAT : Network Address Translation

### (1) 分类:

NAT : 工作于 3 和 4 层. 并非是用户空间运行的进程完成转换功能，靠的是内核中地址转换规则；

仅从请求报文判断，地址转换：

- 源地址转换：SNAT
    SNAT: CIP --> SIP: CIP --> SNAT(PIP) --> SIP
        CIP: 本地客户端地址

- 目标地址转换：DNAT
    DNAT：RemoteIP --> PIP: RemoteIP --> DNAT(SIP) --> SIP
        RemoteIP：远程客户端地址；

- 端口转换：PNAT
    通常在 DNAT 中实现.


### (2) SNAT：主要用于实现让内网客户端访问外部主机时使用； 

**注意**：
- 要定义在`POSTROUTING`链；也可以在OUTPUT上使用(较少)；
- 需要打开网络间转发:

        echo 1 > /proc/sys/net /ipv4/ip_forward

定义方法：

    $ iptables -t nat -A POSTROUTING -s 内网网络或主机地址 -j SNAT --to-source NAT服务器上的某外网地址

    另一个TARGET：
        MASQUERADE：地址伪装；
            能自行判断该转为哪个源地址；

        iptables -t nat -A POSTROUTING -s 内网网络或主机地址 -j MASQUERADE

示例:

    $ iptables -t nat -A POSTROUTING -s 192.168.10.0/24 -j SNAT --to-source 172.16.100.11     # 172.16.100.11 为本机的一个接口.

### (3) DNAT：主要用于发布内部服务器，让内网中的服务器在外网中可以被访问到；

**注意**：
- 要定义在PREROUTING链；

定义方法：

    $ iptables -t nat -A PREROUTING -d NAT服务器的某外网地址 -p 某协议 --dport 某端口 -j DNAT --to-destination 内网某服务器地址[:PORT]

示例:

    $ iptables -t nat -A PREROUTING -d 172.16.100.11 -p tcp --dport 80 -j DNAT --to-destination 192.168.10.7

### (4) FULLNAT: 全地址转换, 见 LVS.

在请求报文到时：既修改源地址，又修改目标地址; 响应报文也是.


## 5. 规则的保存与重载.
保存: 

    service iptables save   # 保存到 /etc/sysconfig/iptables 文件；
        
    iptables-save > /PATH/TO/SOMEFILE   # 自定义保存文件

重载: 

    service iptables reload     # 使用默认保存文件

    iptables-restore < /PATH/FROM/SOMEFILE  # 使用自定义保存文件.

# 三. 其他相关

### 1. REDIRECT 与 DNAT 的区别?   
    
    $ iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 80 -j REDIRECT --to 3128

    $ iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 80 -j DNAT --to-destination 172.16.11.1:3128

    $ iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 3389 -j DNAT --to-destination 172.16.11.250

**结论**
- REDIRECT 是 DNAT 的一个特例.
- DNAT的功能更强大.

### 2. MASQUEREAD 与 SNAT 的区别?
    $ iptables -t nat -s 172.16.11.0/24 -o eth0 -j MASQUERADE

    $ iptables -t nat -s 172.l6.11.0/24 -o eth0 -j SNAT --to 123.123.123.123
    $ iptables -t nat -s 172.l6.11.0/24 -o eth0 -j SNAT --to 123.123.123.1-123.123.123.10

**结论**:
- MASQUERADE 自动根据路由选择出口;
- SNAT 适用于固定 IP 的环境, 负责小; 例外, 可实现地址面积映射.

### 3. -j 与 -g 的区别

    $ iptables -N TESTA
    $ iptables -N TESTB
    $ iptables -A FORWARD -s 172.16.11.1 -j TESTA
    $ iptables -A FORWARD -s 172.16.11.2 -j TESTB
    $ iptables -A TESTA -j MARK --set-mark 1
    $ iptables -A TESTB -j MARK --set-mark 2
    $ iptables -A FORWARD -m mark --mark 1 -j DROP
    $ iptables -A FORWARD -m mark --mark 2 -j DROP


**结论**
- -j(jump) 相当于调用, 自定链结束后返回
- -g(goto) 一去不复返.

### 4. raw 表的用途

    $ iptables -t raw -A PREROUTING -i eth0 -s 172.16.11.250 -j DROP

**结论**
- raw 表工作于最前端, 在 conntrack 之前 可以明确对某些数据不进行链接追踪;
- raw 可以提前 DROP 数据, 有效降低负载.

### 5. 如何防止被 tracert ?
tracert == TTL 试探

    $ iptables -A INPUT -m ttl --ttl-eq 1 -j DROP
    $ iptables -A INPUT -m ttl --ttl-lt 4 -j DROP
    $ iptables -A FORWARD -m ttl --ttl-lt 6 -j DROP