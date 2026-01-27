#!/bin/bash

# Cert - getCertWithCloudflare
#
# 获取证书：Cloudflare DNS API
#
# Author:	XiaoXi<admin@soraharu.com>
# Website:	https://sh.soraharu.com/
# License:	MIT License

# 域名
domainName=$1
# Cloudflare Token
cloudflareToken=$2
# Cloudflare Account ID
cloudflareAccountID=$3

# 检查变量
if [[ -z "${domainName}" ]]; then
	echo "错误：输入变量不正确"
	exit 1
fi

# 如果 cloudflareToken 和 cloudflareAccountID 均存在则设置环境变量
if [[ -n "${cloudflareToken}" ]] && [[ -n "${cloudflareAccountID}" ]]; then
	export CF_Token="${cloudflareToken}"
	export CF_Account_ID="${cloudflareAccountID}"
fi

# 获取证书
~/.acme.sh/acme.sh --issue --dns dns_cf -d "${domainName}"
