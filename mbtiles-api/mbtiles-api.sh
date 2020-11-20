#!/bin/bash
set -x
set -e

export API_URL=${API_URL:-"https://${API_DOMAIN_NAME}"}

cat << EOF > /mbtiles/mbtiles.src
API_DOMAIN_NAME="${API_DOMAIN_NAME}"
APP_DOMAIN_NAME="${APP_DOMAIN_NAME}"
APP_URL="${APP_URL}"
API_URL="${API_URL}"
EOF

chmod +x /mbtiles/mbtiles
chmod +x /usr/bin/action
chmod +x /usr/bin/tic

crontab -l | { cat; echo "* * * * * /usr/bin/tic > /dev/stdout 2> /dev/stderr"; } | crontab -
echo "Start cron task" && crontab -l && /usr/sbin/crond -l 8
cat /usr/bin/action

cat /tmp/Caddyfile | envsubst | tee /etc/caddy/Caddyfile

(caddy run --watch --config /etc/caddy/Caddyfile & fcgiwrap -f -s unix:/var/run/fcgiwrap.socket)
