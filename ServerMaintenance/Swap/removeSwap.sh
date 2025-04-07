#!/bin/bash

# Swap - removeSwap
#
# 移除交换空间
#
# Author:	XiaoXi<admin@soraharu.com>
# Website:	https://sh.soraharu.com/
# License:	MIT License

# 交换文件位置，例如 '/swapfile'
swapLocation=$1

# 检查变量
if [[ -z "${swapLocation}" ]]; then
	swapLocation="/swapfile"
fi

# 关闭交换空间
swapoff "${swapLocation}"

# 从 fstab 移除交换文件
cp /etc/fstab /etc/fstab.bak
awk -v loc="${swapLocation}" '!( $1 == loc && $2 == "none" && $3 == "swap" && $4 == "sw" && $5 == "0" && $6 == "0" )' /etc/fstab > /tmp/fstab.tmp && sudo mv /tmp/fstab.tmp /etc/fstab

# 移除交换文件
rm -f "${swapLocation}"
