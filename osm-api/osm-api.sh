#!/bin/bash

crontab -l | { cat; echo "* * * * * /usr/bin/flock /var/tmp/osm.lock /usr/bin/osm.sh > /dev/stdout 2> /dev/stderr"; } | crontab -

echo "Start cron task" && crontab -l && /usr/sbin/crond -l 8

cat /usr/bin/osm.sh

caddy run --watch --config /etc/caddy/Caddyfile