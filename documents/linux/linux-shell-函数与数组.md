
# 一. 数组

bash Shell只支持一维数组，数组从0开始标号，以array[x]表示数组元素，那么，array[0]就表示array数组的第1个元素、array[1]表示array数组的第2个元素、array[x]表示array数组的第x+1个元素
bash Shell取得数组值（即引用一个数组元素）的命令格式是：
    
    ${array[x]}              #引用array数组标号为x的值

    ** $符号后面的 {大括号} 必不可少

示例:

    city=(Nanjing Beijing Melbourne NewYork)
    city=(Nanjing [10]=Atlanta Massachusetts Marseilles)                # 下标前面的有效 如 ${city[0]}, ${city[10]}; 后面的无效,无法调用.
    city=([2]=Nanjing [10]=Atlanta [1]=Massachusetts [5]=Marseilles)    # 指定下标.

**`array[@]`和`array[\*]`都表示了array数组的所有元素**

    value_0=(net.ipv4.ip_forward 
        net.ipv4.conf.all.send_redirects 
        net.ipv4.conf.default.send_redirects
        net.ipv4.conf.all.accept_source_route
        net.ipv4.conf.default.accept_source_route 
        net.ipv4.conf.all.accept_redirects
        net.ipv4.conf.default.accept_redirects
        net.ipv4.conf.all.secure_redirects 
        net.ipv4.conf.default.secure_redirects
        net.ipv6.conf.all.accept_ra
        net.ipv6.conf.default.accept_ra
        net.ipv6.conf.all.accept_redirects
        net.ipv6.conf.default.accept_redirects)

    value_1=(net.ipv4.conf.all.log_martians
             net.ipv4.conf.default.log_martians
             net.ipv4.icmp_echo_ignore_broadcasts
             net.ipv4.icmp_ignore_bogus_error_responses
             net.ipv4.conf.all.rp_filter
             net.ipv4.conf.default.rp_filter
             net.ipv4.tcp_syncookies)

    for i in ${value_0[*]};do
        sysctl -w $i=0

        grep $i /etc/sysctl.conf &>/dev/null
        if [ $? -ne 0 ];then
            echo "$i = 0" >> /etc/sysctl.conf
        else
            sed -i "s/$i = \*/$i = 0/" >> /etc/sysctl.conf
        fi
    done    

    for i in ${value_1[@]};do
        sysctl -w $i=1

        grep $i /etc/sysctl.conf &>/dev/null
        if [ $? -ne 0 ];then
            echo "$i = 0" >> /etc/sysctl.conf
        else
            sed -i "s/$i = \*/$i = 0/" >> /etc/sysctl.conf
        fi
    done 

**`read -a array`可以将读到的值存储到array数组**

# 二. 函数    

    function addlvm(){
            local devname=$1
            local lvmname=$2
            local sname=$3
            local mountdir=$4
            pvcreate /dev/$devname
            vgcreate $lvmname /dev/$devname
            lvcreate -l 100%VG -n $sname $lvmname
            sleep 10
            if [ "$lvmname" = "LVMSWAP" ]; then
                    mkswap /dev/$lvmname/$sname
                    [ $? -ne 0 ] && { echo "create swap -$lvmname-$sname- error"; exit; }
                    echo "/dev/$lvmname/$sname      swap                    swap    defaults        0 0" >> /etc/fstab
            else
                    mkfs.ext4 /dev/$lvmname/$sname
                    [ $? -ne 0 ] && { echo "mkefs -$lvmname-$sname- error"; exit; }
                    echo "/dev/$lvmname/$sname $mountdir     ext4    defaults        0 0" >> /etc/fstab
            fi
    }