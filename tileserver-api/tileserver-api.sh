#!/bin/bash

echo "DOMAIN_NAME=${DOMAIN_NAME}" > /tileserver/tileserver.src

crontab -l | { cat; echo "* * * * * /usr/bin/flock /var/tmp/actions.lock /usr/bin/actions.sh 2>&1 > /var/log/actions.log"; } | crontab -
echo "Start cron task" && crontab -l && /usr/sbin/cron -l 8
cat /usr/bin/actions.sh

cat /etc/caddy/Caddyfile | envsubst > /tmp/Caddyfile
cat /tmp/Caddyfile
mv  /tmp/Caddyfile              /etc/caddy/Caddyfile

# (caddy run --watch --config /etc/caddy/Caddyfile & fcgiwrap -f -s unix:/var/run/fcgiwrap.socket)
nohup /usr/src/app/run.sh --public_url "https://${DOMAIN_NAME}/tileserver/" --verbose -c /tileserver/config.json &

(caddy run --watch --config /etc/caddy/Caddyfile & fcgiwrap -f -s unix:/var/run/fcgiwrap.socket)
