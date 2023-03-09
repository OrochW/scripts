#!/bin/bash

func_mkdir(){
    #create mysql group and user
    groupadd mysql
    useradd -g mysql mysql
    #create mysql soft directory
    mkdir /apps
    cd /apps
    #create mysql data directory
    mkdir /data/mysql/{data,log,conf} -p 
    touch /data/mysql/log/mysqld.log
    chown mysql:mysql -R /data/mysql
}

func_mysql_install(){
    #downloads
    VERSION=5.7.38
    wget https://mirrors.aliyun.com/mysql/MySQL-5.7/mysql-$VERSION-linux-glibc2.12-x86_64.tar.gz
    tar xvf mysql-$VERSION-linux-glibc2.12-x86_64.tar.gz
    ln -sv mysql-$VERSION-linux-glibc2.12-x86_64 mysql
    #rely
    yum  -y -q install libaio numactl-libs   libaio
}

func_config(){
cat <<'EOF' > /data/mysql/conf/my.cnf
[client]
socket=/tmp/mysql.sock
[mysqld]
character_set_server=utf8
init_connect='SET NAMES utf8'
basedir=/apps/mysql #目录需要跟安装目录对应
datadir=/data/mysql/data #目录需要跟安装目录对应
socket=/tmp/mysql.sock
#不区分大小写
lower_case_table_names = 1
#不开启sql严格模式
sql_mode = "STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION"
#设置时区
default-time-zone = '+08:00'
[mysqld_safe]
log-error=/data/mysql/log/mysqld.log
pid-file=/data/mysql/data/mysqld.pid
!includedir /etc/my.cnf.d
EOF
}


func_mkdir
func_mysql_install
func_config

cd /apps/mysql
./bin/mysqld --defaults-file=/data/mysql/conf/my.cnf --initialize --user=mysql --basedir=/data/mysql/ --datadir=/data/mysql/data >> /data/mysql/log/mysqld.log
temporarypassword=`awk '/A temporary password/{print $NF}' /data/mysql/log/mysqld.log`
echo $temporarypassword
./bin/mysqld_safe --defaults-file=/data/mysql/conf/my.cnf --user=mysql  &


#enter command line followed by down
#cd bin
#./mysql -uroot -p123456
#set password for 'root'@'localhost' = password('123456');
#flush privileges;
#use mysql;
#update user set Host='%' where User='root';
#flush privileges;
#关闭安全启动的mysql
#./bin/mysqladmin -u root -p shutdown

