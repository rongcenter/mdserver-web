# -*- coding: utf-8 -*-
#!/bin/bash

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#https://dev.mysql.com/downloads/mysql/5.7.html
#https://dev.mysql.com/downloads/file/?id=489855

curPath=`pwd`
rootPath=$(dirname "$curPath")
serverPath=$(dirname "$rootPath")
sysName=`uname`


install_tmp=${rootPath}/tmp/mw_install.pl
mysqlDir=${serverPath}/source/mysql


_os=`uname`
if [ ${_os} == "Darwin" ]; then
    OSNAME='macos'
elif grep -Eqi "CentOS" /etc/issue || grep -Eq "CentOS" /etc/*-release; then
    OSNAME='centos'
elif grep -Eqi "Rocky" /etc/issue || grep -Eq "Rocky" /etc/*-release; then
    OSNAME='rocky'
elif grep -Eqi "Red Hat Enterprise Linux Server" /etc/issue || grep -Eq "Red Hat Enterprise Linux Server" /etc/*-release; then
    OSNAME='rhel'
elif grep -Eqi "Aliyun" /etc/issue || grep -Eq "Aliyun" /etc/*-release; then
    OSNAME='aliyun'
elif grep -Eqi "Fedora" /etc/issue || grep -Eq "Fedora" /etc/*-release; then
    OSNAME='fedora'
elif grep -Eqi "Amazon Linux AMI" /etc/issue || grep -Eq "Amazon Linux AMI" /etc/*-release; then
    OSNAME='amazon'
elif grep -Eqi "Debian" /etc/issue || grep -Eq "Debian" /etc/*-release; then
    OSNAME='debian'
elif grep -Eqi "Ubuntu" /etc/issue || grep -Eq "Ubuntu" /etc/*-release; then
    OSNAME='ubuntu'
elif grep -Eqi "Raspbian" /etc/issue || grep -Eq "Raspbian" /etc/*-release; then
    OSNAME='raspbian'
elif grep -Eqi "Deepin" /etc/issue || grep -Eq "Deepin" /etc/*-release; then
    OSNAME='deepin'
else
    OSNAME='unknow'
fi

VERSION_ID=`cat /etc/*-release | grep VERSION_ID | awk -F = '{print $2}' | awk -F "\"" '{print $2}'`



YUM_INSTALL()
{
#######

if [ "${OSNAME}" == "centos" ];then
	wget -O /tmp/mysql80-community-release.rpm http://repo.mysql.com/mysql80-community-release-el${VERSION}.rpm
else
	wget -O /tmp/mysql80-community-release.rpm http://repo.mysql.com/mysql80-community-release-el8.rpm
fi
rpm -ivh /tmp/mysql80-community-release.rpm
yum -y install mysql-server

rm -rf  /tmp/mysql80-community-release.rpm
#######
}

YUM_UNINSTALL()
{
### YUM卸载 START ########
yum -y remove mysql-server
### YUM卸载 END   ########
}


APT_INSTALL()
{
########
wget -O /tmp/mysql-apt-config_0.8.22-1_all.deb https://repo.mysql.com/mysql-apt-config_0.8.22-1_all.deb
dpkg -i /tmp/mysql-apt-config_0.8.22-1_all.deb

apt update -y
apt install -y mysql-server

rm -rf  /tmp/mysql-apt-config_0.8.22-1_all.deb
#######
}

APT_UNINSTALL()
{
###
apt remove -y mysql-server
###
}


Install_mysql()
{

	echo '正在安装脚本文件...' > $install_tmp

	if id mysql &> /dev/null ;then 
	    echo "mysql UID is `id -u mysql`"
	    echo "mysql Shell is `grep "^mysql:" /etc/passwd |cut -d':' -f7 `"
	else
	    groupadd mysql
		useradd -g mysql mysql
	fi

	isYum=`which yum`
	if [ "$isYum" != "" ];then
		YUM_INSTALL
	fi

	isApt=`which apt`
	if [ "$isApt" != "" ];then
		APT_INSTALL
	fi

	if [ "$?" == "0" ];then
		mkdir -p $serverPath/mysql-ya
		echo '8.0' > $serverPath/mysql-ya/version.pl
		echo '安装完成' > $install_tmp
	else
		echo "暂时不支持该系统" > $install_tmp
	fi
}

Uninstall_mysql()
{
	isYum=`which yum`
	if [ "$isYum" != "" ];then
		YUM_UNINSTALL
	fi

	isApt=`which apt`
	if [ "$isApt" != "" ];then
		APT_UNINSTALL
	fi

	rm -rf $serverPath/mysql-ya
	echo '卸载完成' > $install_tmp
}

action=$1
if [ "${1}" == 'install' ];then
	Install_mysql
else
	Uninstall_mysql
fi
