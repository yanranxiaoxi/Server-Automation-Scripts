#!/bin/bash

# FirstInstallation - AlmaLinux9Workstation
#
# 操作系统初始化配置：AlmaLinux 9 Workstation
#
# Author:	XiaoXi<admin@soraharu.com>
# Website:	https://sh.soraharu.com/
# License:	MIT License

# 检测操作系统版本
if [ ! "$(grep -c ' release 9.' '/etc/redhat-release')" -eq '1' ]; then
	echo "错误：操作系统版本非 RHEL 9 like"
	exit 1
fi

# 确保是 root 用户
# sudo -i

# 安装依赖程序
dnf clean all
dnf makecache
dnf update -y
dnf install -y epel-release
dnf config-manager --enable crb
dnf install -y glibc-common langpacks-zh_CN dnf-plugins-core dnf-utils dnf-automatic kpatch kpatch-dnf passwd wget net-tools firewalld git git-lfs cockpit cockpit-packagekit cockpit-storaged cockpit-podman zsh util-linux-user ntfs-3g ibus ibus-libpinyin gvim gnome-tweaks gnome-extensions-app thunderbird darktable libreoffice-calc libreoffice-impress libreoffice-writer libreoffice-draw remmina kleopatra vlc qemu-kvm libvirt virt-manager virt-install bridge-utils filezilla firefox

# 设置系统语言为简体中文
localectl set-locale "zh_CN.utf8"

# 启用服务
systemctl enable --now podman.socket
systemctl enable --now cockpit.socket

# 设置主机名
hostnamectl set-hostname --pretty "XiaoXi's Workstation"
hostnamectl set-hostname --static "xiaoxis-workstation"

# 配置防火墙规则
systemctl enable --now firewalld.service
firewall-cmd --permanent --zone=public --add-service=cockpit
firewall-cmd --permanent --zone=public --add-service=http
firewall-cmd --permanent --zone=public --add-service=https
firewall-cmd --permanent --zone=public --add-service=http3
firewall-cmd --permanent --zone=public --add-service=libvirt
firewall-cmd --permanent --zone=public --new-service=podman-container
firewall-cmd --permanent --service=podman-container --add-port=51300-51399/tcp --add-port=51300-51399/udp
firewall-cmd --permanent --zone=public --add-service=podman-container
firewall-cmd --permanent --service=ssh --add-port=51200/tcp
firewall-cmd --permanent --service=ssh --remove-port=22/tcp
firewall-cmd --permanent --service=cockpit --add-port=51201/tcp
firewall-cmd --permanent --service=cockpit --remove-port=9090/tcp
firewall-cmd --reload

# 禁止 root 用户登录 Cockpit
echo "# List of users which are not allowed to login to Cockpit" >/etc/cockpit/disallowed-users
echo "root" >>/etc/cockpit/disallowed-users

# 修改 Cockpit 端口
mkdir -p /etc/systemd/system/cockpit.socket.d/
echo "[Socket]" >/etc/systemd/system/cockpit.socket.d/override.conf
echo "ListenStream=" >>/etc/systemd/system/cockpit.socket.d/override.conf
echo "ListenStream=51201" >>/etc/systemd/system/cockpit.socket.d/override.conf
systemctl daemon-reload
systemctl restart cockpit.socket

# 修改 SSH 端口
sed -i 's/#Port 22/Port 51200/g' /etc/ssh/sshd_config
sed -i 's/Port 22/Port 51200/g' /etc/ssh/sshd_config

# 配置 SSH 公钥
mkdir -p /root/.ssh/
echo "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAgBasS8YVe8pdKEJ2f20Zs+1FQUC6O7OWQbwSkQiE8+WPbI8GGLgbcfjvS2Ua4cvw2wqVXVbAlwf6awsYHLgBDZR6mdYPWVvw+oVmID3rPwvS3you6S0MkPwqaLBmseFU601acsO8xDbVAigMrP9E+zjE4RQRHEQpxeo+quYY/w9Sm8gAxFKsMc10wAlY8jWIwxsvcvR6402RwzXAxGPiIrpS/F+pB8jDUOMn5QKwiLsSvZvaO3y8m04G8pMI31W6ZZe1exkBmjCay/LcWSxriEGg3TZruh9/rzCHYFInbWFLbTwgTKeJU8LhjZYqEL2sH6xiGwHS5Ou5JG6laNLHRZVGShuFBN5n1v2iPzplRiEPEiIqXltgIRCn51ozhMVMbrYAM59U+n1z2vIyA03wt1ivk/g4tfefBsAw6Od716i1+53QAIPzKQiHYNl9b5H0kANmF4e0VYQO8G+cnz6QIq/3vwZNXA1BLF9zTMhRyEC2SLha3kUBY8dHB9mysrnCy8Wff/lNz3CNc6KjaWgOR1D8CS5x0T05btHcHSxWG8Rstub85AjYZRjN8JHvSyLnUViYahb0wctnTuNnMn6zW0c6fzYdyWCr9Z0+FeS9wLaLVh+Tk91Zr2Fwh8KGXgJ8m5gF1QWSfggjsjQtdx8cITGkKYYWUwcOGFrhyEEWxjdhQ== Kokumi XiaoXi" >/root/.ssh/authorized_keys
mkdir -p /home/xiaoxi/.ssh/
echo "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAgBasS8YVe8pdKEJ2f20Zs+1FQUC6O7OWQbwSkQiE8+WPbI8GGLgbcfjvS2Ua4cvw2wqVXVbAlwf6awsYHLgBDZR6mdYPWVvw+oVmID3rPwvS3you6S0MkPwqaLBmseFU601acsO8xDbVAigMrP9E+zjE4RQRHEQpxeo+quYY/w9Sm8gAxFKsMc10wAlY8jWIwxsvcvR6402RwzXAxGPiIrpS/F+pB8jDUOMn5QKwiLsSvZvaO3y8m04G8pMI31W6ZZe1exkBmjCay/LcWSxriEGg3TZruh9/rzCHYFInbWFLbTwgTKeJU8LhjZYqEL2sH6xiGwHS5Ou5JG6laNLHRZVGShuFBN5n1v2iPzplRiEPEiIqXltgIRCn51ozhMVMbrYAM59U+n1z2vIyA03wt1ivk/g4tfefBsAw6Od716i1+53QAIPzKQiHYNl9b5H0kANmF4e0VYQO8G+cnz6QIq/3vwZNXA1BLF9zTMhRyEC2SLha3kUBY8dHB9mysrnCy8Wff/lNz3CNc6KjaWgOR1D8CS5x0T05btHcHSxWG8Rstub85AjYZRjN8JHvSyLnUViYahb0wctnTuNnMn6zW0c6fzYdyWCr9Z0+FeS9wLaLVh+Tk91Zr2Fwh8KGXgJ8m5gF1QWSfggjsjQtdx8cITGkKYYWUwcOGFrhyEEWxjdhQ== Kokumi XiaoXi" >/home/xiaoxi/.ssh/authorized_keys

# 配置 SSH 禁止密码登录
if [[ "$(grep -c 'PasswordAuthentication ' '/etc/ssh/sshd_config')" -eq '1' && "$(grep -c '#PasswordAuthentication yes' '/etc/ssh/sshd_config')" -eq '1' ]]; then
	sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
else
	sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
fi
systemctl restart sshd.service

# 关闭 SELinux
setenforce 0
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

# 新建 Podman 默认目录
mkdir -p /podmandirectory/

# 移除 Cockpit Web Console 提示
rm -f /etc/motd.d/cockpit

# 设置时区
timedatectl set-timezone 'Asia/Shanghai'

# 进行 Podman 设置
cp /usr/share/containers/containers.conf /etc/containers/containers.conf

# 设置 Podman 最大日志大小为 10MiB
sed -i 's/#log_size_max = -1/log_size_max = 10485760/g' /etc/containers/containers.conf
systemctl restart podman.socket

# 启用服务以解决 Podman 运行时丢失网络连接的问题 https://tech.soraharu.com/archives/160/
systemctl enable netavark-firewalld-reload.service

# Podman 新建 IPv6 网关
podman network create --ipv6 --gateway fd00::1:8:1 --subnet fd00::1:8:0/112 --gateway 10.90.0.1 --subnet 10.90.0.0/16 podman1

# 将默认 Shell 设置为 Zsh
chsh -s "$(which zsh)"

# 安装 Oh My Zsh
sh -c "$(wget -O- https://install.ohmyz.sh)" "" --unattended

# 开启 Oh My Zsh 自动更新
sed -i "s/# zstyle ':omz:update' mode auto/zstyle ':omz:update' mode auto/g" /root/.zshrc

# 设置 vi
if [ "$(grep -c '^set ts=4' '/etc/virc')" -eq '0' ]; then
	{
		echo ""
		echo "set ts=4"
	} >>/etc/virc
fi
if [ "$(grep -c '^set ai' '/etc/virc')" -eq '0' ]; then
	{
		echo ""
		echo "set ai"
	} >>/etc/virc
fi

# 使用 OSC 1337 协议向远程 shell 报告 CWD
if [ "$(grep -c 'export PS1=' '/root/.bash_profile')" -eq '0' ]; then
	printf "export PS1=\"\$PS1\\[\\\e]1337;CurrentDir=\"'\$(pwd)\\\a\\]'" >>/root/.bash_profile
fi
if [ "$(grep -c 'precmd () { echo -n "\\x1b]1337;CurrentDir=$(pwd)\\x07" }' '/root/.zshrc')" -eq '0' ]; then
	{
		echo ""
		echo "# 使用 OSC 1337 协议向远程 shell 报告 CWD"
		printf "precmd () { echo -n \"\\\x1b]1337;CurrentDir=\$(pwd)\\\x07\" }"
	} >>/root/.zshrc
fi

# 加载 KVM 内核模块并启用 libvirtd 服务
CPU_VENDOR=$(lscpu | grep "Vendor ID" | awk '{print $3}')
if [ -z "$CPU_VENDOR" ]; then
	CPU_VENDOR=$(lscpu | grep "厂商 ID" | awk '{print $3}')
fi
modprobe kvm
if [ "$CPU_VENDOR" = "GenuineIntel" ]; then
	echo "检测到 Intel CPU，加载 kvm_intel 模块"
	modprobe kvm_intel
	echo "kvm" >/etc/modules-load.d/kvm.conf
	echo "kvm_intel" >>/etc/modules-load.d/kvm.conf
elif [ "$CPU_VENDOR" = "AuthenticAMD" ]; then
	echo "检测到 AMD CPU，加载 kvm_amd 模块"
	modprobe kvm_amd
	echo "kvm" >/etc/modules-load.d/kvm.conf
	echo "kvm_amd" >>/etc/modules-load.d/kvm.conf
else
	echo "警告：未能识别 CPU 类型（$CPU_VENDOR），跳过 KVM 模块加载"
fi
systemctl enable --now libvirtd

# 加载 KVM 需要的 IOMMU 内核模块
if [ "$CPU_VENDOR" = "GenuineIntel" ]; then
	echo "配置 Intel IOMMU"
	sed -i.bak 's/GRUB_CMDLINE_LINUX="\(.*\)"/GRUB_CMDLINE_LINUX="\1 intel_iommu=on"/' /etc/default/grub
elif [ "$CPU_VENDOR" = "AuthenticAMD" ]; then
	echo "配置 AMD IOMMU"
	sed -i.bak 's/GRUB_CMDLINE_LINUX="\(.*\)"/GRUB_CMDLINE_LINUX="\1 amd_iommu=on"/' /etc/default/grub
fi
grub2-mkconfig -o /boot/grub2/grub.cfg

# 支持 LEGACY GPG 公钥
update-crypto-policies --set LEGACY

# 安装 Enpass
dnf config-manager --add-repo https://yum.enpass.io/enpass-yum.repo
mv /etc/yum.repos.d/enpass-yum.repo /etc/yum.repos.d/enpass.repo
rpm --import https://yum.enpass.io/RPM-GPG-KEY-enpass-signing-key
dnf install enpass -y

# 安装 Visual Studio Code
dnf config-manager --add-repo https://packages.microsoft.com/yumrepos/vscode/config.repo
mv /etc/yum.repos.d/config.repo /etc/yum.repos.d/vscode.repo
rpm --import https://packages.microsoft.com/yumrepos/vscode/repodata/repomd.xml.key
dnf install code -y

# 安装 Tabby
wget "https://packagecloud.io/install/repositories/eugeny/tabby/config_file.repo?os=redhatenterpriseserver&dist=9&source=script" -O /etc/yum.repos.d/tabby.repo
dnf config-manager --disable eugeny_tabby-source
rpm --import https://packagecloud.io/eugeny/tabby/gpgkey
dnf install tabby-terminal -y

# 启用 Flathub
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak remote-modify flathub --url=https://mirror.sjtu.edu.cn/flathub

# 安装 Flathub 应用
flatpak install flathub com.usebottles.bottles -y
flatpak install flathub com.tencent.WeChat -y
flatpak install flathub io.typora.Typora -y
flatpak install flathub org.gimp.GIMP -y
flatpak install flathub org.inkscape.Inkscape -y
flatpak install flathub net.agalwood.Motrix -y
flatpak install flathub org.videolan.VLC -y
flatpak install flathub it.mijorus.gearlever -y
flatpak install flathub dev.deedles.Trayscale -y
flatpak install flathub com.moonlight_stream.Moonlight -y

# 移除应用
dnf remove yelp gnome-user-docs evolution -y

# 在 设置 -> Keyboard -> 添加输入源 -> 汉语 (中国) -> 中文 (智能拼音)
# 在 gnome-tweaks 内进行主题配置 -> 应用程序 -> Adwaita-dark
# 在 设置 -> Keyboard -> 键盘快捷键 -> 截图 -> 复制选区截图到剪贴板 处配置为 Ctrl+Alt+A
# 在 设置 -> 鼠标和触摸板 -> 触摸板 -> 轻拍以点击 -> 开
# 在 代理账户（xiaoxi）配置 oh-my-zsh
# 在 Kleopatra 配置证书
# 在 gnome-tweaks 内配置开机启动程序 -> Thunderbird
# 在 gnome-tweaks 内配置窗口标题栏 -> 标题栏按钮 -> 最大化/最小化 -> 开
# 在 gnome-tweaks 内配置顶栏 -> 电池百分比/工作日/日期/秒/周数 -> 开
