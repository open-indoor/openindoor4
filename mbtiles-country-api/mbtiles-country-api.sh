#!/bin/bash
set -x
set -e

export API_URL=${API_URL:-"https://${API_DOMAIN_NAME}"}

cat << EOF > /mbtiles-country/mbtiles-country.src
API_DOMAIN_NAME="${API_DOMAIN_NAME}"
API_URL="${API_URL}"
EOF

chmod +x /mbtiles-country/mbtiles-country
chmod +x /usr/bin/action
chmod +x /usr/bin/tic

crontab -l | { cat; echo "* * * * * /usr/bin/tic >/dev/stdout 2>/dev/stderr"; } | crontab -
crontab -l | { cat; echo "45 6 * * * /usr/bin/curl https://mbtiles-country-api/mbtiles-country/trigger/world"; } | crontab -

echo "Start cron task" && crontab -l && /usr/sbin/crond -l 8

cat /usr/bin/tic
cat /usr/bin/action

cat /tmp/Caddyfile | envsubst | tee /etc/caddy/Caddyfile

# (caddy run --watch --config /etc/caddy/Caddyfile & fcgiwrap -f -s tcp:127.0.0.1:8999)
(caddy run --watch --config /etc/caddy/Caddyfile & fcgiwrap -f -s unix:/var/run/fcgiwrap.socket)
