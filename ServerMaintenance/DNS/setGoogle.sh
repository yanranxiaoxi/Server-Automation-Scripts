#!/bin/bash

# DNS - setAdGuard
#
# 配置 DNS：AdGuard
#
# Author:	XiaoXi<admin@soraharu.com>
# Website:	https://sh.soraharu.com/
# License:	MIT License

chattr -i /etc/resolv.conf
echo "nameserver 8.8.8.8" >/etc/resolv.conf
echo "nameserver 8.8.4.4" >>/etc/resolv.conf
echo "nameserver 2001:4860:4860::8888" >>/etc/resolv.conf
echo "nameserver 2001:4860:4860::8844" >>/etc/resolv.conf
echo "options edns0 single-request-reopen" >>/etc/resolv.conf
chattr +i /etc/resolv.conf

mkdir -p /etc/NetworkManager/conf.d/
echo "[main]" >/etc/NetworkManager/conf.d/01-dns.conf
echo "dns=none" >>/etc/NetworkManager/conf.d/01-dns.conf
