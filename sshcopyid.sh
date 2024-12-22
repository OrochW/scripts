#!/bin/bash
# 脚本功能: ssh秘钥免交互批量分发

# 定义 IP 地址前缀和数组
Ip_up="172.31.7."
Ip_arr=("11" "12" "13" "14" "15" "16")
# 定义密码
Pass_true="123456"
# 定义公钥和私钥文件路径
Pub_file="/root/.ssh/id_rsa.pub"
Priv_file="/root/.ssh/id_rsa"

# 检查私钥文件是否存在，如果不存在则生成
if [ ! -f "$Priv_file" ]; then
    echo "生成 SSH 私钥..."
    ssh-keygen -t rsa -f "$Priv_file" -N ""
    if [ $? -ne 0 ]; then
        echo "生成 SSH 私钥失败。"
        exit 1
    fi
    echo "SSH 私钥生成成功。"
fi

# 检查 sshpass 命令是否存在，如果不存在则安装
if ! command -v sshpass &> /dev/null; then
    echo "安装 sshpass..."
    # 根据您的系统类型安装 sshpass
    sudo apt-get install -y sshpass
fi

# 分发公钥到指定 IP 地址列表
for Ip_down in "${Ip_arr[@]}"; do
    # 使用 sshpass 和 ssh-copy-id 分发公钥
    sshpass -p "$Pass_true" ssh-copy-id -i "$Pub_file" -o StrictHostKeyChecking=no "$Ip_up$Ip_down" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "免交互分发ssh秘钥到 $Ip_up$Ip_down - 成功"
    else
        echo "免交互分发ssh秘钥到 $Ip_up$Ip_down - 失败"
    fi
done
