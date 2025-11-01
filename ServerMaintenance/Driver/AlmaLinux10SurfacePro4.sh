#!/bin/bash

# Driver - AlmaLinux10SurfacePro4
#
# 驱动配置：AlmaLinux 10 + Microsoft Surface Pro 4
#
# Author:	XiaoXi<admin@soraharu.com>
# Website:	https://sh.soraharu.com/
# License:	MIT License

# 检测操作系统版本
if [ ! "$(grep -c ' release 10.' '/etc/redhat-release')" -eq '1' ]; then
	echo "错误：操作系统版本非 RHEL 10 like"
	exit 1
fi

# 添加 EPEL 仓库
dnf install -y epel-release

# 添加 Linux Surface 仓库
cat > /etc/yum.repos.d/linux-surface.repo << 'EOF'
[linux-surface]
name=linux-surface
baseurl=https://pkg.surfacelinux.com/fedora/f40/
enabled=1
skip_if_unavailable=1
gpgkey=https://raw.githubusercontent.com/linux-surface/linux-surface/master/pkg/keys/surface.asc
gpgcheck=1
enabled_metadata=1
type=rpm-md
repo_gpgcheck=0
EOF

# 添加 Fedora 仓库
cat > /etc/yum.repos.d/fedora.repo << 'EOF'
[fedora]
name=Fedora 40 - $basearch
baseurl=https://mirrors.tuna.tsinghua.edu.cn/fedora/releases/40/Everything/$basearch/os/
#metalink=https://mirrors.fedoraproject.org/metalink?repo=fedora-40&arch=$basearch
enabled=1
countme=1
metadata_expire=7d
repo_gpgcheck=0
type=rpm
gpgcheck=0
skip_if_unavailable=False
EOF

# 添加 Fedora Updates 仓库
cat > /etc/yum.repos.d/fedora-updates.repo << 'EOF'
[fedora-updates]
name=Fedora 40 - $basearch - Updates
baseurl=https://mirrors.tuna.tsinghua.edu.cn/fedora/updates/40/Everything/$basearch/
#metalink=https://mirrors.fedoraproject.org/metalink?repo=updates-released-f40&arch=$basearch
enabled=1
countme=1
repo_gpgcheck=0
type=rpm
gpgcheck=0
metadata_expire=6h
skip_if_unavailable=False
EOF

# 安装 Surface 内核
dnf install -y --allowerasing kernel-surface kernel-surface-modules-extra iptsd libwacom-surface

# 安装 Surface 内核的安全启动支持
dnf install -y surface-secureboot

# 启用 Surface 内核看门狗
systemctl enable --now linux-surface-default-watchdog.path

# 禁用 Fedora 仓库
dnf config-manager --set-disabled fedora fedora-updates

echo "请重启系统以应用 Surface 内核，在重启过程中使用密码 surface 导入内核证书"

# 在 设置 -> 无障碍 -> 始终显示无障碍菜单 -> 开
# 在 设置 -> 电源 -> 常规 -> 电源按钮行为 -> 电源关闭
# 在 设置 -> 电源 -> 节电 -> 自动屏幕亮度/屏幕变暗/自动节电 -> 开
# 在 设置 -> 电源 -> 节电 -> 息屏 -> 从不
# 在 设置 -> 电源 -> 节电 -> 自动挂起 -> 关
