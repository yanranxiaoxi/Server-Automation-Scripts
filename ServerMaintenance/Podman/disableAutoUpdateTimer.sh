#!/bin/bash

# Podman - disableAutoUpdateTimer
#
# 禁用 Podman 自动更新定时器单元
#
# Author:	XiaoXi<admin@soraharu.com>
# Website:	https://sh.soraharu.com/
# License:	MIT License

# 禁用 Podman 自动更新定时器单元
systemctl disable --now podman-auto-update.timer
rm -rf /etc/systemd/system/podman-auto-update.timer.d/
