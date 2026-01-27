#!/bin/bash

# Cert - getCertWithCloudflareInContainer
#
# 在 acme.sh 容器内获取证书：Cloudflare DNS API
#
# Author:	XiaoXi<admin@soraharu.com>
# Website:	https://sh.soraharu.com/
# License:	MIT License

# 域名（支持逗号分隔的多个域名）
domainName=$1
# Container Type
containerType=${2:-podman}
# Container Name or ID
containerNameOrID=${3:-acme-sh}

# 检查变量
if [[ -z "${domainName}" ]]; then
	echo "错误：输入变量不正确"
	exit 1
fi

if [[ "${containerType}" != "podman" && "${containerType}" != "docker" ]]; then
	echo "错误：containerType 必须是 podman 或 docker"
	exit 1
fi

# 将逗号分隔的域名转换为 -d 参数
domainArgs=""
IFS=',' read -ra DOMAINS <<< "${domainName}"
for domain in "${DOMAINS[@]}"; do
	# 去除空格
	domain=$(echo "${domain}" | xargs)
	if [[ -n "${domain}" ]]; then
		domainArgs="${domainArgs} -d ${domain}"
	fi
done

# 获取证书
"${containerType}" exec "${containerNameOrID}" --issue --dns dns_cf "${domainArgs}"
