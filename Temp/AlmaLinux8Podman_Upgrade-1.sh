#!/bin/bash

dnf install -y fail2ban
systemctl enable --now fail2ban.service

if [[ "$(grep -c 'PasswordAuthentication ' '/etc/ssh/sshd_config')" -eq '1' && "$(grep -c '#PasswordAuthentication yes' '/etc/ssh/sshd_config')" -eq '1' ]]; then
	sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
else
	sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
fi
systemctl restart sshd.service

sed -i 's/#log_size_max = -1/log_size_max = 10485760/g' /etc/containers/containers.conf
systemctl restart podman.socket

if [ "$(grep -c 'export PS1=' '/root/.bash_profile')" -eq '0' ]; then
	# echo "export PS1=\"\$PS1\\[\\e]1337;CurrentDir=\"'\$(pwd)\\a\\]'" >>/root/.bash_profile
	printf "export PS1=\"\$PS1\\[\\\e]1337;CurrentDir=\"'\$(pwd)\\\a\\]'" >>/root/.bash_profile
fi
