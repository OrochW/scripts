#!/bin/bash
if [ `getenforce` == "Enforcing" ];then
    sed -i s/SELINUX=enforcing/SELINUX=disabled/g /etc/sysconfig/selinux /etc/selinux/config
    sed -i s/ONBOOT=no/ONBOOT=yes/g /etc/sysconfig/network-scripts/ifcfg-ens34
    systemctl disable firewalld
    systemctl stop firewalld
    cat >> /etc/sysctl.conf << EOF
vm.overcommit_memory = 1
net.ipv4.ip_local_port_range = 1024 65536
net.ipv4.tcp_fin_timeout = 1
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.tcp_mem = 94500000 915000000 927000000
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_synack_retries = 1
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_abort_on_overflow = 0
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.core.netdev_max_backlog = 262144
net.core.somaxconn = 262144
net.ipv4.tcp_max_orphans = 3276800
net.ipv4.tcp_max_syn_backlog = 262144
net.core.wmem_default = 8388608
net.core.rmem_default = 8388608
net.ipv4.netfilter.ip_conntrack_max = 2097152
net.nf_conntrack_max = 655360
net.netfilter.nf_conntrack_tcp_timeout_established = 1200
EOF
bash /sbin/sysctl -p
echo "ulimit -SHn 102400" >> /etc/rc.local
cat >> /etc/security/limits.conf << EOF
*           soft   nofile       655350
*           hard   nofile       655350
EOF
yum -y install net-tools tree lrzsz unzip telnet vim gcc cmake wget git ntpdate bash-completion
    line=`grep -o "swap" /etc/fstab|uniq `
    if [ $line != "" ];then
    sed -i '$d' /etc/fstab
    fi
fi

function Sethostname {
    read -p "请输入主机名：" DEFINDHOST
    # 设置机器名
    hostnamectl set-hostname $DEFINDHOST
    echo -n "主机名为："  && hostname
}
function Setip {
        ifs=(`ifconfig | grep "^e" | awk -F: '{print $1}'`)
        for i in `echo ${ifs[@]}`;do
            echo -e "${i}\t`ifconfig ${i} | awk 'NR==2{print $2}'`"
        done
    read -p "请输入要定义的网卡(输入ens后面的即可)：" DEFINDENS
    # 设置静态 IP，网络请根据自己的网卡来配置,ip addr 或 ifconfig 查看，笔者这里是ens33
    read -p "请输入要定义的ip：" DEFINDIP
    sed -i "s/dhcp/static/g" /etc/sysconfig/network-scripts/ifcfg-ens$DEFINDENS
    sed -i "s/ONBOOT=no/ONBOOT=yes/g" /etc/sysconfig/network-scripts/ifcfg-ens$DEFINDENS
    echo "BOARDCAST=192.168.0.255
    IPADDR=$DEFINDIP
    NETMASK=255.255.255.0
    GATEWAY=192.168.0.1" >> /etc/sysconfig/network-scripts/ifcfg-ens$DEFINDENS
    # 重启网络服务
    systemctl restart network
    echo 'nameserver $DEFINDIP' >> /etc/resolv.conf
    echo "ip已生效"
}
echo "1.设置hostname主机名"
echo "2.设置ip"
Sethostname
bash
read -p "是否继续？(y/n):" ANSWER
    if [ $ANSWER == "y" ];then
        Setip
    fi
