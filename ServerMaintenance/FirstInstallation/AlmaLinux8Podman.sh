#!/bin/bash

# FirstInstallation - AlmaLinux8Podman
#
# 初始化配置：AlmaLinux 8 + Podman
#
# Author:	XiaoXi<admin@soraharu.com>
# Website:	https://sh.soraharu.com/
# License:	MIT License

# SSH 公钥
sshPublicKey=$1

# 取得 root 权限
sudo -i

# 安装依赖程序
dnf update -y
dnf install -y passwd wget net-tools firewalld git cockpit cockpit-packagekit cockpit-storaged cockpit-podman netavark

# 启用服务
systemctl enable --now firewalld
systemctl enable --now cockpit.socket

# 配置防火墙规则
firewall-cmd --permanent --zone=public --add-service=cockpit && firewall-cmd --reload
firewall-cmd --permanent --zone=public --add-service=http && firewall-cmd --reload
firewall-cmd --permanent --zone=public --add-service=https && firewall-cmd --reload
firewall-cmd --permanent --new-service=http3
firewall-cmd --permanent --service=http3 --add-port=443/udp
firewall-cmd --permanent --new-service=podman-container
firewall-cmd --permanent --service=podman-container --add-port=51300-51399/tcp --add-port=51300-51399/udp
firewall-cmd --permanent --service=ssh --add-port=51200/tcp
firewall-cmd --permanent --service=ssh --remove-port=22/tcp
firewall-cmd --permanent --service=cockpit --add-port=51201/tcp
firewall-cmd --permanent --service=cockpit --remove-port=9090/tcp
firewall-cmd --reload

# 修改 SSH 端口
sed -i 's/#Port 22/Port 51200/g' /etc/ssh/sshd_config
sed -i 's/Port 22/Port 51200/g' /etc/ssh/sshd_config
systemctl restart sshd

# 修改 Cockpit 端口
mkdir -p /etc/systemd/system/cockpit.socket.d/
echo "[Socket]" >/etc/systemd/system/cockpit.socket.d/override.conf
echo "ListenStream=" >>/etc/systemd/system/cockpit.socket.d/override.conf
echo "ListenStream=51201" >>/etc/systemd/system/cockpit.socket.d/override.conf
systemctl daemon-reload
systemctl restart cockpit.socket

# 配置 SSH 公钥
echo "${sshPublicKey}" >/root/.ssh/authorized_keys

# 关闭 SELinux
setenforce 0
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

# 新建 Podman 默认目录
mkdir -p /podmandirectory/

# 移除 Cockpit Web Console 提示
rm -rf /etc/motd.d/cockpit

# 设置时区
timedatectl set-timezone 'Asia/Shanghai'

# 将 Podman Network 移交给 Netavark 管理
cp /usr/share/containers/containers.conf /etc/containers/containers.conf
sed -i 's/network_backend = "cni"/network_backend = "netavark"/g' /etc/containers/containers.conf
podman network reload

# Podman 新建 IPv6 网关
podman network create --ipv6 --gateway fd00::1:8:1 --subnet fd00::1:8:0/112 --gateway 10.90.0.1 --subnet 10.90.0.0/16 podman1
