#!/bin/bash

# Model - installMicrosoftEdge
#
# 安装 Microsoft Edge 浏览器
#
# Author:	XiaoXi<admin@soraharu.com>
# Website:	https://sh.soraharu.com/
# License:	MIT License

# 安装 Microsoft Edge
dnf config-manager --add-repo https://packages.microsoft.com/yumrepos/edge/config.repo
mv /etc/yum.repos.d/config.repo /etc/yum.repos.d/microsoft-edge.repo
rpm --import https://packages.microsoft.com/yumrepos/edge/repodata/repomd.xml.key
dnf install microsoft-edge-stable -y
