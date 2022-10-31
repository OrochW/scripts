#!/bin/bash
#if [ `getenforce` == "Enforcing" ];then
#    sed -i s/SELINUX=enforcing/SELINUX=disabled/g /etc/sysconfig/selinux /etc/selinux/config
#    sed -i s/ONBOOT=no/ONBOOT=yes/g /etc/sysconfig/network-scripts/ifcfg-ens34
#    systemctl disable firewalld
#    systemctl stop firewalld
#cat >> /etc/sysctl.conf << EOF
#net.ipv4.ip_nonlocal_bind=1
#EOF
#sysctl -p
#echo "ulimit -SHn 102400" >> /etc/rc.local
#cat >> /etc/security/limits.conf << EOF
#*           soft   nofile       655350
#*           hard   nofile       655350
#EOF
#yum -y install net-tools tree lrzsz unzip telnet vim gcc cmake wget git ntpdate bash-completion
#    line=`grep -o "swap" /etc/fstab|uniq `
#    if [ $line != "" ];then
#    sed -i '$d' /etc/fstab
#    fi
#fi
rm -rf /etc/sysconfig/network-scripts/ifcfg-ens34

cat >> /etc/sysconfig/network-scripts/ifcfg-ens34 << EOF
TYPE=Ethernet
PROXY_METHOD=none
BROWSER_ONLY=no
BOOTPROTO=static
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=yes
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_FAILURE_FATAL=no
IPV6_ADDR_GEN_MODE=stable-privacy
NAME=ens34
UUID=3a676c39-9655-41e5-b60e-b4079b366558
DEVICE=ens34
ONBOOT=yes
EOF

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
echo "BOARDCAST=192.168.234.255
IPADDR=192.168.234.$DEFINDIP
NETMASK=255.255.255.0
GATEWAY=192.168.234.1" >> /etc/sysconfig/network-scripts/ifcfg-ens$DEFINDENS
# 重启网络服务
systemctl restart network
echo 'nameserver $DEFINDIP' >> /etc/resolv.conf
echo "ip已生效"
}
Sethostname
Setip
