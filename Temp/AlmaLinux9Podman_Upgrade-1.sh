#!/bin/bash

# 检测操作系统版本
if [ ! "$(grep -c ' release 9.' '/etc/redhat-release')" -eq '1' ]; then
	echo "错误：操作系统版本非 RHEL 9 like"
	exit
fi

if [[ "$(grep -c 'PasswordAuthentication ' '/etc/ssh/sshd_config')" -eq '1' && "$(grep -c '#PasswordAuthentication yes' '/etc/ssh/sshd_config')" -eq '1' ]]; then
	sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
else
	sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
fi
systemctl restart sshd.service

cp /usr/share/containers/containers.conf /etc/containers/containers.conf
sed -i 's/#log_size_max = -1/log_size_max = 10485760/g' /etc/containers/containers.conf
systemctl restart podman.socket

if [ "$(grep -c 'export PS1=' '/root/.bash_profile')" -eq '0' ]; then
	# echo "export PS1=\"\$PS1\\[\\e]1337;CurrentDir=\"'\$(pwd)\\a\\]'" >>/root/.bash_profile
	printf "export PS1=\"\$PS1\\[\\\e]1337;CurrentDir=\"'\$(pwd)\\\a\\]'" >>/root/.bash_profile
fi
