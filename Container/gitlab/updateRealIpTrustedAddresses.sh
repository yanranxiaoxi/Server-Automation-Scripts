#!/bin/bash

# gitlab - updateRealIpTrustedAddresses
#
# 更新 GitLab cdn_ip_ranges 配置
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
CONFIG_KEY="cdn_ip_ranges"

if [ ! -f "$GITLAB_RB" ]; then
	echo "错误：未找到配置文件 $GITLAB_RB"
	exit 1
fi

if ! grep -q "^${CONFIG_KEY} = " "$GITLAB_RB"; then
	echo "错误：配置文件中未找到 ${CONFIG_KEY} 配置项，配置未做任何修改"
	exit 1
fi

echo "正在从 API 获取 IP 地址列表..."
# -f 使 HTTP 错误码直接返回非零退出码，避免将错误页当作数据
if ! IP_ADDRESSES=$(curl -fsS "$API_URL"); then
	echo "错误：无法从 API 获取 IP 地址列表，配置未做任何修改"
	exit 1
fi

IP_ADDRESSES=$(printf '%s' "$IP_ADDRESSES" | tr -d '\r')

if [ -z "$IP_ADDRESSES" ]; then
	echo "错误：API 返回内容为空，配置未做任何修改"
	exit 1
fi

# 校验返回内容必须是单行的、单引号逗号分隔的 IP 地址或网段，否则视为获取失败
case "$IP_ADDRESSES" in
*$'\n'* | *$'\t'*)
	echo "错误：API 返回的内容不是单行数据，配置未做任何修改"
	exit 1
	;;
esac

if ! printf '%s' "$IP_ADDRESSES" | grep -Eq "^'[0-9A-Fa-f:.]+(/[0-9]{1,3})?'(,'[0-9A-Fa-f:.]+(/[0-9]{1,3})?')*$"; then
	echo "错误：API 返回的内容格式不正确，配置未做任何修改"
	echo "返回内容：$IP_ADDRESSES"
	exit 1
fi

echo "获取成功，正在更新 gitlab.rb..."

# 构建新的配置行
NEW_CONFIG="${CONFIG_KEY} = [ $IP_ADDRESSES ]"

# 使用 sed 替换配置
sed -i "/^${CONFIG_KEY} = /c\\$NEW_CONFIG" "$GITLAB_RB"

# 移除可能引入的 Windows 换行符
sed -i 's/\r$//' "$GITLAB_RB"

if ! grep -qxF "$NEW_CONFIG" "$GITLAB_RB"; then
	echo "错误：写入配置失败，请检查 $GITLAB_RB"
	exit 1
fi

echo "配置已更新"
echo "新配置为："
grep "^${CONFIG_KEY} = " "$GITLAB_RB"

# 重新配置 GitLab 使配置生效
# "${containerType}" exec -t gitlab gitlab-ctl reconfigure

# 创建系统定时任务
echo "0 1 * * * root curl -fsSL https://sh.soraharu.com/Container/gitlab/updateRealIpTrustedAddresses.sh | bash -s -- \"${providers}\" \"${containerType}\"" >/etc/cron.d/updateRealIpTrustedAddresses.cron
systemctl restart crond
