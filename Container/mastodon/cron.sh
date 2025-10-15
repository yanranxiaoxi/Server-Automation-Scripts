#!/bin/bash

echo "10 2 * * * root podman exec -t mastodon-web tootctl preview_cards remove --days 14" >/etc/cron.d/container.mastodon.cron
echo "30 2 * * * root podman exec -t mastodon-web tootctl media remove --days 7" >>/etc/cron.d/container.mastodon.cron
echo "0 2 * * * root podman exec -t mastodon-web tootctl cache clear" >>/etc/cron.d/container.mastodon.cron
echo "0 3 1 * * root podman exec -t mastodon-web tootctl media remove-orphans" >>/etc/cron.d/container.mastodon.cron
systemctl restart crond
