#!/bin/bash

set -x
set -e

cat << EOF > /style/style.src
API_DOMAIN_NAME="${API_DOMAIN_NAME}"
APP_DOMAIN_NAME="${APP_DOMAIN_NAME}"
EOF


cat /usr/bin/tic
cat /usr/bin/actions.sh

export CADDYPATH=/data/caddy

cd /data/www/style/
cat ./openindoorStyle.json | jq '(.layers[] | select(.=="buildingLayers")) |= '"$(cat ./building/buildingLayers.json | jq -c .[])" > /tmp/openindoorStyle.json
mv -f /tmp/openindoorStyle.json ./openindoorStyle.json

cat ./indoor/indoorLayers.json | envsubst > /tmp/indoorLayers.json \
&& mv -f /tmp/indoorLayers.json ./indoor/indoorLayers.json
cat ./openindoorStyle.json | jq '(.layers[] | select(.=="indoorLayers")) |= '"$(cat ./indoor/indoorLayers.json | jq -c .[])" > /tmp/openindoorStyle.json
mv -f /tmp/openindoorStyle.json ./openindoorStyle.json

/usr/bin/tic

cd /etc/caddy
cat ./Caddyfile | envsubst > ./Caddyfile_tmp
cat ./Caddyfile_tmp
mv  ./Caddyfile_tmp              ./Caddyfile

crontab -l | { cat; echo "* * * * * /usr/bin/tic"; } | crontab -
echo "Start cron task" && crontab -l && /usr/sbin/crond -l 8
caddy run --watch --config /etc/caddy/Caddyfile
