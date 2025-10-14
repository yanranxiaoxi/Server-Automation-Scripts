#!/bin/bash

# Podman - removeAutoUpdateContainer
#
# 移除被 systemd 接管的 Podman 容器
#
# Author:	XiaoXi<admin@soraharu.com>
# Website:	https://sh.soraharu.com/
# License:	MIT License

# 外部输入容器名称
containerName=$1

# 检查变量
if [[ -z "${containerName}" ]]; then
	echo "错误：输入变量不正确"
	exit 1
fi

# 禁用服务
systemctl disable container-"${containerName}"

# 删除 systemd 目录下的对应 .service 文件
rm -f /etc/systemd/system/container-"${containerName}".service

# 重载 systemd
systemctl daemon-reload

# 删除容器
podman container rm -f "${containerName}"

# 清理镜像
# 清理镜像时还会同时清理掉已停止的其他容器及其镜像，这在正常情况下并不会导致问题
podman system prune --external -f
