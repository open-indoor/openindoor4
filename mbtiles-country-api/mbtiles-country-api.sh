#!/bin/bash

echo "DOMAIN_NAME=${DOMAIN_NAME}" > /mbtiles-country/mbtiles-country.src
crontab -l | { cat; echo "* * * * * /usr/bin/tic"; } | crontab -
echo "Start cron task" && crontab -l && /usr/sbin/crond -l 8

cat /usr/bin/tic
cat /usr/bin/actions.sh

cat /etc/caddy/Caddyfile | envsubst > /tmp/Caddyfile
cat /tmp/Caddyfile
mv  /tmp/Caddyfile              /etc/caddy/Caddyfile

# (caddy run --watch --config /etc/caddy/Caddyfile & fcgiwrap -f -s tcp:127.0.0.1:8999)
(caddy run --watch --config /etc/caddy/Caddyfile & fcgiwrap -f -s unix:/var/run/fcgiwrap.socket)
