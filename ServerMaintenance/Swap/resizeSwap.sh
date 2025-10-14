#!/bin/bash

# Swap - resizeSwap
#
# 调整交换空间大小
#
# Author:	XiaoXi<admin@soraharu.com>
# Website:	https://sh.soraharu.com/
# License:	MIT License

# 交换文件大小
swapSize=$1
# 交换文件位置，例如 '/swapfile'
swapLocation=$2

# 检查变量
if [[ -z "${swapSize}" ]]; then
	echo "错误：输入变量不正确"
	exit 1
fi
if [[ -z "${swapLocation}" ]]; then
	swapLocation="/swapfile"
fi

# 关闭交换空间
swapoff "${swapLocation}"

# 修改交换文件
fallocate -l "${swapSize}" "${swapLocation}"

# 激活交换空间
mkswap "${swapLocation}"
swapon "${swapLocation}"
