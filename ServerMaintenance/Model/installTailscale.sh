#!/bin/bash

# Model - installTailscale
#
# 安装 Tailscale
#
# Author:	XiaoXi<admin@soraharu.com>
# Website:	https://sh.soraharu.com/
# License:	MIT License

# Tailscale 认证密钥
authKey=$1
# Tailscale 登录服务器地址
loginServer=$2
# 是否为跳板机（true/false/空）
isJumpServer=$3

# 检查变量
if [[ -z "${authKey}" ]]; then
	echo "错误：输入变量不正确"
	echo "正确语法：$0 <authKey(必填)> <loginServer(可空)> <isJumpServer(可空|true|false)>"
	exit 1
fi
if [[ -z "${loginServer}" ]]; then
	loginServer="https://controlplane.tailscale.com:443"
fi

case "${isJumpServer}" in
	""|true|false)
		;;
	*)
		echo "错误：isJumpServer 仅允许 true、false 或留空"
		exit 1
		;;
esac

acceptDNS=false
acceptRoutes=false
if [[ "${isJumpServer}" == "true" ]]; then
		acceptDNS=true
		acceptRoutes=true
fi

# 检测 RHEL 主版本
RHEL_MAJOR=""
if command -v rpm >/dev/null 2>&1; then
	RHEL_MAJOR=$(rpm -E %rhel 2>/dev/null | tr -dc '0-9')
fi
if [[ -z "${RHEL_MAJOR}" ]] && [[ -r /etc/os-release ]]; then
	. /etc/os-release
	case "${ID}" in
		rhel|almalinux|rocky|centos|centos-stream)
			RHEL_MAJOR="${VERSION_ID%%.*}"
			;;
	esac
fi
if [[ -z "${RHEL_MAJOR}" ]]; then
	echo "错误：无法检测 RHEL 主版本（仅支持 RHEL/AlmaLinux/Rocky/CentOS）。"
	exit 1
fi
if ! [[ "${RHEL_MAJOR}" =~ ^(8|9|10)$ ]]; then
	echo "错误：不支持的 RHEL 主版本：${RHEL_MAJOR}（仅支持 8/9/10）"
	exit 1
fi

# 安装 Tailscale
dnf -y install dnf-plugins-core
dnf config-manager --add-repo "https://pkgs.tailscale.com/stable/rhel/${RHEL_MAJOR}/tailscale.repo"
rpm --import "https://pkgs.tailscale.com/stable/rhel/${RHEL_MAJOR}/repo.gpg"
dnf install tailscale -y
systemctl enable --now tailscaled.service

# 允许 resolv.conf 的修改
chattr -i /etc/resolv.conf

# 启用端口转发
echo 'net.ipv4.ip_forward = 1' | tee -a /etc/sysctl.d/99-tailscale.conf
echo 'net.ipv6.conf.all.forwarding = 1' | tee -a /etc/sysctl.d/99-tailscale.conf
sysctl -p /etc/sysctl.d/99-tailscale.conf

# 配置防火墙，启用 EasyNAT
firewall-cmd --permanent --add-masquerade
firewall-cmd --permanent --zone=public --new-service=tailscale
firewall-cmd --permanent --service=tailscale --add-port=41641/udp
firewall-cmd --reload

tailscale up \
	--login-server="${loginServer}" \
	--authkey="${authKey}" \
	--advertise-exit-node \
	--accept-dns="${acceptDNS}" \
	--accept-routes="${acceptRoutes}"

echo "请注意在外部防火墙放行 41641/udp 端口"
