#!/bin/bash

# 检查依赖程序包
mkdir -p /eda-server/package/
if [ ! -f "/eda-server/package/*-pro-*" ]; then
    echo "请将程序包放置于 \"/eda-server/package/\" 目录，并确保该目录下仅存在该单独程序包"
    exit
fi

echo "请输入访问域名或 IP（默认：127.0.0.1）："
read readDomainName

echo "请提供 .ecrt 文件路径以启用 HTTPS 访问（不提供则不启用 HTTPS）："
read readEcrtPath

echo "请提供数据目录（默认：/eda-server/data/）："
read readDataUri

# 安装前提示
echo "本自动化脚本将会为您安装嘉立创 EDA 专业版私有化部署版本及其依赖组件，请确认是否开始安装？ (y/n)"
read isReadyToInstall
if [ ! [ ${isReadyToInstall} =~ "y" ]]; then
    if [[ ${isReadyToInstall} =~ "n" ]]; then
        exit
    fi
    # 重新提示或退出
    exit
fi

# 安装依赖程序
dnf clean all
dnf makecache
dnf update -y
dnf install -y firewalld unzip

# 设置系统语言为简体中文
dnf install -y langpacks-zh_CN
localectl set-locale "zh_CN.utf8"

# 设置时区
timedatectl set-timezone 'Asia/Shanghai'

# 配置防火墙规则
systemctl enable --now firewalld.service
firewall-cmd --permanent --zone=public --add-service=http
firewall-cmd --permanent --zone=public --add-service=https
firewall-cmd --permanent --zone=public --add-service=http3
firewall-cmd --reload

# 关闭 SELinux
setenforce 0
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

# 安装 MySQL
dnf install -y mysql mysql-server
systemctl enable --now mysqld
systemctl start mysqld

# 安装 NodeJS
dnf install -y nodejs

# 安装 pm2
npm install pm2 -g
