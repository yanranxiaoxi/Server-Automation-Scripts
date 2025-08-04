# 安装 Tailscale
dnf config-manager --add-repo https://pkgs.tailscale.com/stable/rhel/9/tailscale.repo
rpm --import https://pkgs.tailscale.com/stable/rhel/9/repo.gpg
dnf install tailscale -y
systemctl enable --now tailscaled.service

# 配置防火墙，启用 EasyNAT
firewall-cmd --permanent --zone=public --new-service=tailscale
firewall-cmd --permanent --service=tailscale --add-port=41641/udp
firewall-cmd --reload
