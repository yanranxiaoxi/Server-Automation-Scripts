#!/bin/bash

# Podman - newAutoUpdateContainer
#
# 使用 systemd 接管 Podman 容器，并启用自动更新
#
# Author:	XiaoXi<admin@soraharu.com>
# Website:	https://sh.soraharu.com/
# License:	MIT License

# 只有包含以下标签的容器才会被允许自动更新
# --label=io.containers.autoupdate=registry
# 随时可以使用以下 bash 命令更新已包含上述标签的容器
# podman auto-update
# 更新将会删除并重建容器，请注意容器数据的持久化保存

# 外部输入容器名称
containerName=$1

# 使用 Podman 生成 systemd 部署的必要文件
# 这将在当前目录中生成文件
podman generate systemd --new --name --files "${containerName}"

# 删除当前容器
podman container rm -f "${containerName}"

# 复制 .service 文件到 systemd 目录
cp container-"${containerName}".service /etc/systemd/system/container-"${containerName}".service

# 重载 systemd
systemctl daemon-reload

# 启用并启动该服务
systemctl enable --now container-"${containerName}"

# 删除临时 .service 文件
rm -f container-"${containerName}".service

# 启用 Podman 自动更新定时器单元
systemctl enable --now podman-auto-update.timer

# 自动更新将于每周一早晨自动运行，可以使用以下命令编辑定时器模块
# systemctl edit podman-auto-update.timer
