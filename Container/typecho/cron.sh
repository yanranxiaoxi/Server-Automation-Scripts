echo "0 22 * * * root cd /podmandirectory/typecho/usr/themes/Simplecho/ && git pull --force" >/etc/cron.d/container.typecho.cron
systemctl restart crond
