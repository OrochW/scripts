#!/bin/bash
#脚本功能:ssh秘钥免交互批量分发
#要点提示:ssh-keygen -f和-n参数免交互生成秘钥;sshpass命令免交互输入密码;ssh -o参数取消提示语句
. /etc/init.d/functions
Ip_up=192.168.234.
Ip_arr="31 32 33 41 42 43"
Pass_true=centos
Pass_false=abcdef
Pub_file=/root/.ssh/id_rsa.pub
#1.检查公钥文件是否存放,不存在则免交互生成
if [ ! -f /root/.ssh/id_dsa ];then
  ssh-keygen -t rsa -f /root/.ssh/id_rsa -N ""  >/dev/null 2>&1
fi
#2.检查sshpass命令是否存在,不存在则yum安装
if [ ! -f /usr/bin/sshpass ];then
  yum install -y sshpass  >/dev/null 2>&1
fi
#3.for循环分发秘钥,如果已经可以免秘钥的,则跳过,免秘钥后,检查并输出检查结果
for Ip_down in $Ip_arr
do
    sshpass -p$Pass_true ssh-copy-id  -o StrictHostKeyChecking=no $Ip_up$Ip_down >/dev/null 2>&1
    if [ $? -eq 0 ];then
       action "免交互分发ssh秘钥到 $Ip_up$Ip_down" /bin/true
    else
       action "免交互分发ssh秘钥到 $Ip_up$Ip_down" /bin/false
    fi
#  fi
done
