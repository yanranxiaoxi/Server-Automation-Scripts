#!/bin/bash

# caddy2 - autoSyncNiceCaddyfile
#
# 自动同步 Nice Caddyfile 中的复用块
#
# Author:	XiaoXi<admin@soraharu.com>
# Website:	https://sh.soraharu.com/
# License:	MIT License

# 容器类型，'podman' 或是 'docker'
containerType=$1
# 是否首次安装，是则填写 'firstRun'，将会自动注册到 crontab
firstRun=$2

# 检查变量
if [[ -z "${containerType}" ]]; then
	echo "错误：输入变量不正确"
	exit
fi

dnf install -y git

if [ ! -f "/${containerType}directory/caddy2/config/reuse/README.md" ]; then
	git clone --depth=1 https://gitlab.soraharu.com/XiaoXi/Nice-Caddyfile.git /"${containerType}"directory/caddy2/config/reuse/
else
	cd /"${containerType}"directory/caddy2/config/reuse/ || exit
	git reset --hard
	git pull
fi
systemctl restart container-caddy2

# 创建系统定时任务
if [[ ${firstRun} =~ "firstRun" ]]; then
	cron="0 1 * * * root wget -O ~/autoSyncNiceCaddyfile.sh https://sh.soraharu.com/Container/caddy2/autoSyncNiceCaddyfile.sh && sh ~/autoSyncNiceCaddyfile.sh ${containerType} && rm -f ~/autoSyncNiceCaddyfile.sh"
	sed -i -e $'$a\\\n'"${cron}" /etc/crontab
	systemctl restart crond
fi
