#!/bin/bash

# Model - installAcme
#
# 安装 acme.sh
#
# Author:	XiaoXi<admin@soraharu.com>
# Website:	https://sh.soraharu.com/
# License:	MIT License

# 电子邮箱（用于注册 acme.sh 账号）
acmeEmail=$1
# 是否处于中国大陆网络环境（true/false）
chinaNet=$2

cloneUrl="https://github.com/acmesh-official/acme.sh.git"
if [[ "${chinaNet}" == "true" ]]; then
	cloneUrl="https://gitee.com/neilpang/acme.sh.git"
fi

# 安装 acme.sh
rm -rf /root/acme.sh/
rm -rf /root/.acme.sh/
cd ~ || exit
git clone "${cloneUrl}"
cd acme.sh || exit
./acme.sh --install --accountemail "${acmeEmail}"
rm -rf /root/acme.sh/
