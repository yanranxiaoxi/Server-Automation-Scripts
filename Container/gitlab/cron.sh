#!/bin/bash

echo "0 5 * * * root podman exec -t gitlab gitlab-backup" >/etc/cron.d/container.gitlab.cron
systemctl restart crond
