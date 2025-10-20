#!/bin/bash

# FirstInstallation - AlmaLinux9Podman
#
# 操作系统初始化配置：AlmaLinux 9 + Podman
#
# Author:	XiaoXi<admin@soraharu.com>
# Website:	https://sh.soraharu.com/
# License:	MIT License

# 检测操作系统版本
if [ ! "$(grep -c ' release 9.' '/etc/redhat-release')" -eq '1' ]; then
	echo "错误：操作系统版本非 RHEL 9 like"
	exit 1
fi

# SSH 公钥
sshPublicKey=$1
# Pretty Hostname
prettyHostname=$2
# Static Hostname
staticHostname=$3

# 检查变量
if [[ -z "${sshPublicKey}" || -z "${prettyHostname}" || -z "${staticHostname}" ]]; then
	echo "错误：输入变量不正确"
	exit 1
fi

# 安装依赖程序
dnf clean all
dnf makecache
dnf update -y
dnf install -y glibc-common langpacks-zh_CN dnf-automatic kpatch kpatch-dnf passwd wget net-tools firewalld git cockpit cockpit-packagekit cockpit-storaged cockpit-podman zsh util-linux-user

# 设置系统语言为简体中文
localectl set-locale "zh_CN.utf8"

# 启用服务
systemctl enable --now podman.socket
systemctl enable --now cockpit.socket

# 启用系统自动更新，于每周一凌晨 1:30 执行
systemctl enable --now dnf-automatic-install.timer
mkdir -p /etc/systemd/system/dnf-automatic-install.timer.d/
echo "[Timer]" >/etc/systemd/system/dnf-automatic-install.timer.d/time.conf
echo "OnBootSec=" >>/etc/systemd/system/dnf-automatic-install.timer.d/time.conf
echo "OnCalendar=mon 01:30" >>/etc/systemd/system/dnf-automatic-install.timer.d/time.conf
systemctl daemon-reload

# 启用内核实时补丁
systemctl enable --now kpatch.service
dnf kpatch auto

# 移除 VirtIO-Balloon 驱动
# #TODO# 在 GreenCloud 新版 VirtFusion 面板安装的服务器内执行导致死机，等待缓解
# rmmod virtio_balloon

# 设置主机名
hostnamectl set-hostname --pretty "${prettyHostname}"
hostnamectl set-hostname --static "${staticHostname}"

# 设置 DNS
echo "nameserver 8.8.8.8" >/etc/resolv.conf # 临时 IPv4 DNS 解析服务器
echo "nameserver 2001:4860:4860::8888" >>/etc/resolv.conf # 临时 IPv6 DNS 解析服务器
curl -fsSL https://sh.soraharu.com/ServerMaintenance/DNS/setGoogle.sh | bash

# 配置防火墙规则
systemctl enable --now firewalld.service
firewall-cmd --permanent --zone=public --add-service=cockpit
firewall-cmd --permanent --zone=public --add-service=http
firewall-cmd --permanent --zone=public --add-service=https
firewall-cmd --permanent --zone=public --add-service=http3
firewall-cmd --permanent --zone=public --new-service=podman-container
firewall-cmd --permanent --service=podman-container --add-port=51300-51399/tcp --add-port=51300-51399/udp
firewall-cmd --permanent --zone=public --add-service=podman-container
firewall-cmd --permanent --service=ssh --add-port=51200/tcp
firewall-cmd --permanent --service=ssh --remove-port=22/tcp
firewall-cmd --permanent --service=cockpit --add-port=51201/tcp
firewall-cmd --permanent --service=cockpit --remove-port=9090/tcp
firewall-cmd --reload

# 允许 root 用户登录 Cockpit
echo "# List of users which are not allowed to login to Cockpit" >/etc/cockpit/disallowed-users

# 修改 Cockpit 端口
mkdir -p /etc/systemd/system/cockpit.socket.d/
echo "[Socket]" >/etc/systemd/system/cockpit.socket.d/override.conf
echo "ListenStream=" >>/etc/systemd/system/cockpit.socket.d/override.conf
echo "ListenStream=51201" >>/etc/systemd/system/cockpit.socket.d/override.conf
systemctl daemon-reload
systemctl restart cockpit.socket

# 修改 SSH 端口
sed -i 's/#Port 22/Port 51200/g' /etc/ssh/sshd_config
sed -i 's/Port 22/Port 51200/g' /etc/ssh/sshd_config

# 配置 SSH 公钥
mkdir -p /root/.ssh/
echo "${sshPublicKey}" >/root/.ssh/authorized_keys

# 配置 SSH 禁止密码登录
if [[ "$(grep -c 'PasswordAuthentication ' '/etc/ssh/sshd_config')" -eq '1' && "$(grep -c '#PasswordAuthentication yes' '/etc/ssh/sshd_config')" -eq '1' ]]; then
	sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
else
	sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
fi
systemctl restart sshd.service

# 关闭 SELinux
setenforce 0
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

# 新建 Podman 默认目录
mkdir -p /podmandirectory/

# 移除 Cockpit Web Console 提示
rm -f /etc/motd.d/cockpit

# 设置时区
timedatectl set-timezone 'Asia/Shanghai'

# 进行 Podman 设置
cp /usr/share/containers/containers.conf /etc/containers/containers.conf

# 设置 Podman 最大日志大小为 10MiB
sed -i 's/#log_size_max = -1/log_size_max = 10485760/g' /etc/containers/containers.conf
systemctl restart podman.socket

# 启用服务以解决 Podman 运行时丢失网络连接的问题 https://tech.soraharu.com/archives/160/
systemctl enable netavark-firewalld-reload.service

# Podman 新建 IPv6 网关
podman network create --ipv6 --gateway fd00::1:8:1 --subnet fd00::1:8:0/112 --gateway 10.90.0.1 --subnet 10.90.0.0/16 podman1

# 将默认 Shell 设置为 Zsh
chsh -s "$(which zsh)"

# 安装 Oh My Zsh
sh -c "$(wget -O- https://install.ohmyz.sh)" "" --unattended

# 开启 Oh My Zsh 自动更新
sed -i "s/# zstyle ':omz:update' mode auto/zstyle ':omz:update' mode auto/g" /root/.zshrc

# 设置 vi
if [ "$(grep -c '^set ts=4' '/etc/virc')" -eq '0' ]; then
	{
		echo ""
		echo "set ts=4"
	} >>/etc/virc
fi
if [ "$(grep -c '^set ai' '/etc/virc')" -eq '0' ]; then
	{
		echo ""
		echo "set ai"
	} >>/etc/virc
fi

# 使用 OSC 1337 协议向远程 shell 报告 CWD
if [ "$(grep -c 'export PS1=' '/root/.bash_profile')" -eq '0' ]; then
	printf "export PS1=\"\$PS1\\[\\\e]1337;CurrentDir=\"'\$(pwd)\\\a\\]'" >>/root/.bash_profile
fi
if [ "$(grep -c 'precmd () { echo -n "\\x1b]1337;CurrentDir=$(pwd)\\x07" }' '/root/.zshrc')" -eq '0' ]; then
	{
		echo ""
		echo "# 使用 OSC 1337 协议向远程 shell 报告 CWD"
		printf "precmd () { echo -n \"\\\x1b]1337;CurrentDir=\$(pwd)\\\x07\" }"
	} >>/root/.zshrc
fi

echo "操作已完成，请检查后续步骤并尽快重启以应用所有配置"
