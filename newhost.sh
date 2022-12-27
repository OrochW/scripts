#!/bin/bash
#定义函数:网络主机连通性测试
net_test(){
    echo "请输入要测试的IP地址:"
    read ip
    echo "正在测试，请稍等..."
    ping -c 2 $ip &> /dev/null
    if [ "$?" -eq 0 ];then
        echo "$ip正常"
    else
        echo "$ip不通"
    fi
}
#定义函数:批量添加用户及用户密码
add_user(){
    echo "请输入要添加的用户名:"
    read username
    echo "请输入用户$username的密码:"
    read password
    useradd $username
    echo "$password" | passwd --stdin $username &>/dev/null
    if [ "$?" -eq 0 ];then
    echo "用户$username 添加成功!"
    else
    echo "用户$username 添加失败!"
    fi
}
    # 菜单
while true
do
    echo "===================="
    echo "1.网络主机连通性测试"
    echo "2.批量添加用户及用户密码"
    echo "0.退出程序"
    echo "===================="
    echo "请输入对应的选项"
    read option
    case $option in
        1)
            net_test
        ;;
        2)
            add_user
        ;;
        0)
            exit
        ;;
        *)
            echo "请输入正确的选项！"
    esac
done
