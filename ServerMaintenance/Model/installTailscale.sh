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
advertiseTags="tag:server"
if [[ "${isJumpServer}" == "true" ]]; then
		acceptDNS=true
		acceptRoutes=true
		advertiseTags="tag:jump-server"
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
echo 'net.ipv4.ip_forward = 1' >/etc/sysctl.d/99-tailscale.conf
echo 'net.ipv6.conf.all.forwarding = 1' >>/etc/sysctl.d/99-tailscale.conf
sysctl -p /etc/sysctl.d/99-tailscale.conf

# 检查并修改 GCE 网络安全配置以兼容 Tailscale
if [[ -f "/etc/sysctl.d/60-gce-network-security.conf" ]]; then
	if grep -q "net.ipv4.conf.all.rp_filter = 1" "/etc/sysctl.d/60-gce-network-security.conf"; then
		echo "检测到 GCE 网络安全配置，正在修改 rp_filter 设置以兼容 Tailscale"
		sed -i 's/net.ipv4.conf.all.rp_filter = 1/net.ipv4.conf.all.rp_filter = 2/g' /etc/sysctl.d/60-gce-network-security.conf
		sysctl -p /etc/sysctl.d/60-gce-network-security.conf
	fi
fi

# 配置 UDP 性能优化（仅 RHEL 10）
if [[ "${RHEL_MAJOR}" == "10" ]]; then
	echo "检测到 RHEL 10，配置 UDP 传输层卸载以提升性能"
	tee /etc/NetworkManager/dispatcher.d/50-tailscale-udp-optimization > /dev/null <<'EOF'
#!/bin/bash

NETDEV=$(ip -o route get 8.8.8.8 | cut -f 5 -d " ")
ethtool -K $NETDEV rx-udp-gro-forwarding on rx-gro-list off
EOF
	chmod 755 /etc/NetworkManager/dispatcher.d/50-tailscale-udp-optimization
	# 立即应用设置
	/etc/NetworkManager/dispatcher.d/50-tailscale-udp-optimization
fi

# 配置防火墙，启用 EasyNAT
firewall-cmd --permanent --add-masquerade
firewall-cmd --permanent --zone=public --new-service=tailscale
firewall-cmd --permanent --service=tailscale --add-port=41641/udp
firewall-cmd --permanent --zone=public --add-service=tailscale
firewall-cmd --reload

# Run!
tailscale up \
	--login-server="${loginServer}" \
	--authkey="${authKey}" \
	--advertise-exit-node \
	--advertise-tags="${advertiseTags}" \
	--accept-dns="${acceptDNS}" \
	--accept-routes="${acceptRoutes}"

# 配置防火墙，仅允许 Tailscale 网段访问 SSH 和 Cockpit
firewall-cmd --permanent --new-zone=tailscale
firewall-cmd --permanent --zone=tailscale --set-description="Tailscale trusted network"
firewall-cmd --permanent --zone=tailscale --set-target=ACCEPT
firewall-cmd --permanent --zone=tailscale --add-interface=tailscale0
# firewall-cmd --permanent --zone=public --remove-service=ssh
firewall-cmd --permanent --zone=public --remove-service=cockpit
firewall-cmd --reload

echo "请注意在外部防火墙放行 41641/udp 端口，并在测试完成后移除 SSH 的公网访问权限"
