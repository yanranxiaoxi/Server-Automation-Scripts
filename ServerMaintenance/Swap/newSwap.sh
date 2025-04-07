#!/bin/bash

# Swap - newSwap
#
# 新建交换空间
#
# Author:	XiaoXi<admin@soraharu.com>
# Website:	https://sh.soraharu.com/
# License:	MIT License

# 在开始之前，可以检查系统是否已经有一些可用的交换空间，
# 可能有多个交换文件或交换分区，但通常应该是足够的
# swapon --show

# 如果没有任何结果或者没有任何显示，说明系统当前没有可用的交换空间
# free 命令用来查看空闲的内存空间，其中包括交换分区的空间
# free -h

# 为 swap 分配空间的最常见方式是使用专门用于某个具体任务的单独分配，
# 但是，改变分区方案并不是一定可行的，我们只可以轻松地创建驻留在现有分区上的交换文件
# 在开始之前，应该输入以下命令来检查当前磁盘的使用情况：
# df -h

# 交换文件大小
swapSize=$1
# 交换文件位置，例如 '/swapfile'
swapLocation=$2

# 检查变量
if [[ -z "${swapSize}" ]]; then
	echo "错误：输入变量不正确"
	exit
fi
if [[ -z "${swapLocation}" ]]; then
	swapLocation="/swapfile"
fi

# 创建交换文件
fallocate -l "${swapSize}" "${swapLocation}"

# 使用以下命令查看是否正确创建：
# ls -lh "${swapLocation}"
# 结果应该类似于下面这样：
# -rw-r--r-- 1 root root 2.0G Month DD hh:mm /swapfile

# 修改交换文件的权限
chmod 600 "${swapLocation}"

# 查看效果：
# ls -lh "${swapLocation}"
# 结果应该类似于下面这样：
# -rw------- 1 root root 2.0G Month DD hh:mm /swapfile

# 激活交换空间
mkswap "${swapLocation}"
swapon "${swapLocation}"

# 使用以下命令查看是否成功开启交换空间：
# swapon --show
# 结果应该类似于下面这样：
# NAME      TYPE SIZE USED PRIO
# /swapfile file   2G   0B   -1

# 将交换文件添加到 fstab
# 这样每次开机系统就会自动把交换文件挂载为交换空间
cp /etc/fstab /etc/fstab.bak
echo "${swapLocation} none swap sw 0 0" | tee -a /etc/fstab
