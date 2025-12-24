#!/bin/bash

# gitlab - updateRealIpTrustedAddresses
#
# 更新 GitLab nginx real_ip_trusted_addresses 配置
#
# Author:	XiaoXi<admin@soraharu.com>
# Website:	https://sh.soraharu.com/
# License:	MIT License

# CDN 提供商列表，逗号分隔，如 'Private,Cloudflare,EdgeOne'
# https://gitlab.soraharu.com/XiaoXi/cdn-ips#input-parameter
providers=${1:-"Private"}
# 容器类型，'podman' 或是 'docker'
containerType=${2:-"podman"}

GITLAB_RB="/${containerType}directory/gitlab/config/gitlab.rb"
API_URL="https://cdn-ips.api.soraharu.com/?providers=${providers}&format=single-quote-comma"

echo "正在从 API 获取 IP 地址列表..."
IP_ADDRESSES=$(curl -s "$API_URL" | tr -d '\r')

if [ -z "$IP_ADDRESSES" ]; then
	echo "错误：无法从 API 获取 IP 地址列表"
	exit 1
fi

echo "获取成功，正在更新 gitlab.rb..."

# 构建新的配置行
NEW_CONFIG="nginx['real_ip_trusted_addresses'] = [ $IP_ADDRESSES ]"

# 使用 sed 替换配置
sed -i "/^nginx\['real_ip_trusted_addresses'\]/c\\$NEW_CONFIG" "$GITLAB_RB"

# 移除可能引入的 Windows 换行符
sed -i 's/\r$//' "$GITLAB_RB"

echo "配置已更新"
echo "新配置为："
grep "^nginx\['real_ip_trusted_addresses'\]" "$GITLAB_RB"

# 重新配置 GitLab 使配置生效
# "${containerType}" exec -t gitlab gitlab-ctl reconfigure

# 创建系统定时任务
echo "0 1 * * * root curl -fsSL https://sh.soraharu.com/Container/gitlab/updateRealIpTrustedAddresses.sh | bash -s -- \"${providers}\" \"${containerType}\"" >/etc/cron.d/updateRealIpTrustedAddresses.cron
systemctl restart crond
