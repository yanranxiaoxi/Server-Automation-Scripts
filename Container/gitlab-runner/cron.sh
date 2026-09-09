#!/bin/bash

echo "40 2 * * * root echo y | podman system prune --all" >/etc/cron.d/container.gitlab-runner.cron
systemctl restart crond
