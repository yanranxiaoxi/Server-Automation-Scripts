#!/bin/bash

# Model - installTorBrowser
#
# 安装 Tor 浏览器
#
# Author:	XiaoXi<admin@soraharu.com>
# Website:	https://sh.soraharu.com/
# License:	MIT License

# 检测操作系统类型
OS_TYPE=""
OS_VERSION=""

if [ -f /etc/os-release ]; then
	. /etc/os-release
	case "${ID}" in
		rhel|almalinux|rocky|centos|centos-stream)
			OS_TYPE="rhel"
			OS_VERSION="${VERSION_ID%%.*}"
			;;
		fedora)
			OS_TYPE="fedora"
			OS_VERSION="${VERSION_ID}"
			;;
		*)
			echo "错误：不支持的操作系统：${ID}"
			exit 1
			;;
	esac
else
	echo "错误：无法检测操作系统类型"
	exit 1
fi

echo "检测到操作系统：${OS_TYPE} ${OS_VERSION}"

# 安装 Tor 浏览器

# 添加 EPEL 仓库（仅 RHEL 系列需要）
if [ "${OS_TYPE}" = "rhel" ]; then
	dnf install -y epel-release
fi

# 添加 Tor 仓库
if [ "${OS_TYPE}" = "rhel" ]; then
	cat > /etc/yum.repos.d/tor.repo << EOF
[tor]
name=Tor for Enterprise Linux $releasever - $basearch
baseurl=https://tor-rpm.cdn.soraharu.com/centos/$releasever/$basearch
enabled=1
gpgcheck=1
gpgkey=https://tor-rpm.cdn.soraharu.com/centos/public_gpg.key
cost=100
EOF
	rpm --import https://tor-rpm.cdn.soraharu.com/centos/public_gpg.key
elif [ "${OS_TYPE}" = "fedora" ]; then
	cat > /etc/yum.repos.d/tor.repo << EOF
[tor]
name=Tor for Fedora $releasever - $basearch
baseurl=https://tor-rpm.cdn.soraharu.com/fedora/$releasever/$basearch
enabled=1
gpgcheck=1
gpgkey=https://tor-rpm.cdn.soraharu.com/fedora/public_gpg.key
cost=100
EOF
	rpm --import https://tor-rpm.cdn.soraharu.com/fedora/public_gpg.key
fi

# 安装 Tor 浏览器
dnf install tor -y
