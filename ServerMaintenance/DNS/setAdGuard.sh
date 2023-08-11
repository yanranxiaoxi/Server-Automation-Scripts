#!/bin/bash

# DNS - setAdGuard
#
# 配置 DNS：AdGuard
#
# Author:	XiaoXi<admin@soraharu.com>
# Website:	https://sh.soraharu.com/
# License:	MIT License

chattr -i /etc/resolv.conf
echo "nameserver 94.140.14.140" >/etc/resolv.conf
echo "nameserver 94.140.14.141" >>/etc/resolv.conf
echo "nameserver 2a10:50c0::bad1:ff" >>/etc/resolv.conf
echo "nameserver 2a10:50c0::bad2:ff" >>/etc/resolv.conf
echo "options edns0 single-request-reopen" >>/etc/resolv.conf
chattr +i /etc/resolv.conf

mkdir -p /etc/NetworkManager/conf.d/
echo "[main]" >/etc/NetworkManager/conf.d/01-dns.conf
echo "dns=none" >>/etc/NetworkManager/conf.d/01-dns.conf
