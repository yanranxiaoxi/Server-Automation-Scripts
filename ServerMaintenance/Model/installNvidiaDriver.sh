#!/bin/bash

# Model - installNvidiaDriver
#
# 安装 NVIDIA 驱动程序
#
# Author:	XiaoXi<admin@soraharu.com>
# Website:	https://sh.soraharu.com/
# License:	MIT License

# 检查操作系统版本
if [[ -f /etc/os-release ]]; then
	source /etc/os-release
	if [[ "${ID}" != "almalinux" ]]; then
		echo "错误：此脚本仅支持 AlmaLinux 操作系统"
		exit 1
	fi
	
	# 提取主版本号
	VERSION_MAJOR=$(echo "${VERSION_ID}" | cut -d. -f1)
	
	if [[ "${VERSION_MAJOR}" -lt 9 ]]; then
		echo "错误：此脚本仅支持 AlmaLinux 9 及以上版本"
		echo "当前版本：AlmaLinux ${VERSION_ID}"
		exit 1
	fi
	
	echo "检测到 AlmaLinux ${VERSION_ID}，开始安装 NVIDIA 驱动..."
else
	echo "错误：无法检测操作系统版本"
	exit 1
fi

# 更新系统
dnf update -y

# 启用仓库
dnf install -y almalinux-release-nvidia-driver

# 安装驱动程序
dnf install -y nvidia-open-kmod nvidia-driver
dnf install -y nvidia-open

# 安装 nvidia-smi
dnf install -y nvidia-driver-cuda

# 安装 CUDA 组件
dnf install -y cuda

# 如若未更新内核（已运行在最新内核），可以直接加载内核模块
# modprobe nvidia_drm

# 重启以加载内核模块
echo "NVIDIA 驱动安装完成，请重启服务器以加载内核模块"
