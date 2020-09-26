#!/bin/bash

crontab -l | { cat; echo "* * * * * /usr/bin/flock /var/tmp/getOsmFiles.lock /usr/bin/getOsmFiles.sh > /dev/stdout 2> /dev/stderr"; } | crontab -

# crontab /etc/cron.d/getOsmFiles-cron

echo "Start cron task" && crontab -l && /usr/sbin/crond -l 8

cat /usr/bin/getOsmFiles.sh

caddy run --watch --config /etc/caddy/Caddyfile