#!/bin/bash

# Model - installTorBrowser
#
# 安装 Tor 浏览器
#
# Author:	XiaoXi<admin@soraharu.com>
# Website:	https://sh.soraharu.com/
# License:	MIT License

# 安装 Tor 浏览器

# 添加 EPEL 仓库
dnf install -y epel-release

# 添加 Tor 仓库
cat > /etc/yum.repos.d/tor.repo << 'EOF'
[tor]
name=Tor for Enterprise Linux $releasever - $basearch
baseurl=https://rpm.torproject.org/centos/$releasever/$basearch
enabled=1
gpgcheck=1
gpgkey=https://rpm.torproject.org/centos/public_gpg.key
cost=100
EOF

# 导入 GPG Key
rpm --import https://rpm.torproject.org/centos/public_gpg.key

# 安装 Tor 浏览器
dnf install tor -y
