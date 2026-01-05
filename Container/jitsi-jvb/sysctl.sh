#!/bin/bash

echo 'net.core.rmem_max = 10485760' >/etc/sysctl.d/99-jitsi-jvb.conf
echo 'net.core.wmem_max = 10485760' >>/etc/sysctl.d/99-jitsi-jvb.conf
echo 'net.core.netdev_max_backlog = 100000' >>/etc/sysctl.d/99-jitsi-jvb.conf
sysctl -p /etc/sysctl.d/99-jitsi-jvb.conf
