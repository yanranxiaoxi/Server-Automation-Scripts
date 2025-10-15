#!/bin/bash

echo '# Adjusted the following settings to get rid of JGroups warnings' >/etc/sysctl.d/47-jgroups.conf
echo '# WARNING: JGRP000015: the send buffer of socket MulticastSocket was set to 1MB, but the OS only allocated 212.99KB. This might lead to performance problems. Please set your max send buffer in the OS correctly (e.g. net.core.wmem_max on Linux)' >>/etc/sysctl.d/47-jgroups.conf
echo '# WARNING: JGRP000015: the receive buffer of socket MulticastSocket was set to 20MB, but the OS only allocated 212.99KB. This might lead to performance problems. Please set your max receive buffer in the OS correctly (e.g. net.core.rmem_max on Linux)' >>/etc/sysctl.d/47-jgroups.conf
echo 'net.core.wmem_max=1024000' >>/etc/sysctl.d/47-jgroups.conf
echo 'net.core.rmem_max=25600000' >>/etc/sysctl.d/47-jgroups.conf
sysctl -p /etc/sysctl.d/47-jgroups.conf
