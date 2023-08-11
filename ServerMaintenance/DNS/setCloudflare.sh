#!/bin/bash

# DNS - setCloudflare
#
# 配置 DNS：Cloudflare
#
# Author:	XiaoXi<admin@soraharu.com>
# Website:	https://sh.soraharu.com/
# License:	MIT License

chattr -i /etc/resolv.conf
echo "nameserver 1.1.1.1" >/etc/resolv.conf
echo "nameserver 1.0.0.1" >>/etc/resolv.conf
echo "nameserver 2606:4700:4700::1111" >>/etc/resolv.conf
echo "nameserver 2606:4700:4700::1001" >>/etc/resolv.conf
echo "options single-request-reopen" >>/etc/resolv.conf
chattr +i /etc/resolv.conf

mkdir -p /etc/NetworkManager/conf.d/
echo "[main]" >/etc/NetworkManager/conf.d/01-dns.conf
echo "dns=none" >>/etc/NetworkManager/conf.d/01-dns.conf
