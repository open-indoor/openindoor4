#!/bin/bash

echo "DOMAIN_NAME=${DOMAIN_NAME}" > /tileserver/tileserver.src

chmod +x /tileserver/tileserver
chmod +x /usr/bin/actions.sh
chmod +x /usr/bin/tic


crontab -l | { cat; echo "* * * * * /usr/bin/tic"; } | crontab -
echo "Start cron task" && crontab -l && /usr/sbin/cron -l 8
cat /usr/bin/actions.sh

cat /etc/caddy/Caddyfile | envsubst > /tmp/Caddyfile
cat /tmp/Caddyfile
mv  /tmp/Caddyfile              /etc/caddy/Caddyfile

# (caddy run --watch --config /etc/caddy/Caddyfile & fcgiwrap -f -s unix:/var/run/fcgiwrap.socket)
nohup /usr/src/app/run.sh --public_url "https://${DOMAIN_NAME}/tileserver/" --verbose -c /tileserver/config.json &

(caddy run --watch --config /etc/caddy/Caddyfile & fcgiwrap -f -s unix:/var/run/fcgiwrap.socket)
