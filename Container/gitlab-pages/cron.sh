echo "0 2 * * * root podman exec -t gitlab-pages gitlab-ctl reconfigure" >/etc/cron.d/container.gitlab-pages.cron
systemctl restart crond
