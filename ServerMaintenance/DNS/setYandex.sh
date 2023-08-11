#!/bin/bash

# DNS - setYandex
#
# 配置 DNS：Yandex
#
# Author:	XiaoXi<admin@soraharu.com>
# Website:	https://sh.soraharu.com/
# License:	MIT License

chattr -i /etc/resolv.conf
echo "nameserver 77.88.8.8" >/etc/resolv.conf
echo "nameserver 77.88.8.1" >>/etc/resolv.conf
echo "nameserver 2a02:6b8::feed:0ff" >>/etc/resolv.conf
echo "nameserver 2a02:6b8:0:1::feed:0ff" >>/etc/resolv.conf
echo "options single-request-reopen" >>/etc/resolv.conf
chattr +i /etc/resolv.conf

mkdir -p /etc/NetworkManager/conf.d/
echo "[main]" >/etc/NetworkManager/conf.d/01-dns.conf
echo "dns=none" >>/etc/NetworkManager/conf.d/01-dns.conf
