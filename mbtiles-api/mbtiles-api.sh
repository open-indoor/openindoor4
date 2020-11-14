#!/bin/bash

export API_URL=${API_URL:-"https://${API_DOMAIN_NAME}"}

cat << EOF > /mbtiles/mbtiles.src
API_DOMAIN_NAME="${API_DOMAIN_NAME}"
APP_DOMAIN_NAME="${APP_DOMAIN_NAME}"
APP_URL="${APP_URL}"
API_URL="${API_URL}"
EOF

chmod +x /mbtiles-country/mbtiles-country
chmod +x /usr/bin/actions.sh
chmod +x /usr/bin/tic

crontab -l | { cat; echo "* * * * * /usr/bin/tic > /dev/stdout 2> /dev/stderr"; } | crontab -
echo "Start cron task" && crontab -l && /usr/sbin/crond -l 8
cat /usr/bin/actions.sh

cat /tmp/Caddyfile | envsubst | tee /etc/caddy/Caddyfile

# ( caddy run --watch --config /etc/caddy/Caddyfile & fcgiwrap -f -s tcp:127.0.0.1:8999)
(caddy run --watch --config /etc/caddy/Caddyfile & fcgiwrap -f -s unix:/var/run/fcgiwrap.socket)
