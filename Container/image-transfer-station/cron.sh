echo "5 * * * * root podman exec -t image-transfer-station php /var/www/cron.php" >/etc/cron.d/container.image-transfer-station.cron
systemctl restart crond
