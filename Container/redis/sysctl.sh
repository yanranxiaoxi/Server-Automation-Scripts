#!/bin/bash

echo 'vm.overcommit_memory = 1' >/etc/sysctl.d/99-redis.conf
sysctl -p /etc/sysctl.d/99-redis.conf
