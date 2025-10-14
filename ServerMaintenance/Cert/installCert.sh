#!/bin/bash

# Cert - installCert
#
# 安装证书
#
# Author:	XiaoXi<admin@soraharu.com>
# Website:	https://sh.soraharu.com/
# License:	MIT License

# 域名
domainName=$1
# 全链证书文件路径
fullChainFilePath=$2
# 私钥文件路径
privateKeyFilePath=$3
# 证书更新后的重载命令
reloadCommand=$4

# 检查变量
if [[ -z "${domainName}" ]] || [[ -z "${fullChainFilePath}" ]] || [[ -z "${privateKeyFilePath}" ]]; then
	echo "错误：输入变量不正确"
	exit 1
fi

# 安装证书
if [[ -n "${reloadCommand}" ]]; then
	~/.acme.sh/acme.sh --install-cert -d "${domainName}" \
		--fullchain-file "${fullChainFilePath}" \
		--key-file "${privateKeyFilePath}" \
		--reloadcmd "${reloadCommand}"
else
	~/.acme.sh/acme.sh --install-cert -d "${domainName}" \
		--fullchain-file "${fullChainFilePath}" \
		--key-file "${privateKeyFilePath}"
fi
