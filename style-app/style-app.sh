#!/bin/bash

set -x
set -e

export APP_URL=${APP_URL:-"https://${APP_DOMAIN_NAME}"}
export API_URL=${API_URL:-"https://${API_DOMAIN_NAME}"}

chmod +x /usr/bin/tic
chmod +x /usr/bin/actions.sh
chmod +x /usr/bin/processStyle

cat << EOF > /style/style.src
API_DOMAIN_NAME="${API_DOMAIN_NAME}"
APP_DOMAIN_NAME="${APP_DOMAIN_NAME}"
APP_URL="${APP_URL}"
API_URL="${API_URL}"
EOF

cat /usr/bin/tic
cat /usr/bin/actions.sh

export CADDYPATH=/data/caddy

source /tmp/style/styleValues.sh


# COPY ./style/ /data/www/style/

mkdir -p /data/www/style
cd /tmp

for jsonFile in `find style -type f -name "*.json" | grep -v "styleValues"`; do
    mkdir -p $(dirname /data/www/${jsonFile})
    cat $jsonFile | envsubst > /data/www/${jsonFile}
done

cd /data/www/style

processStyle

/usr/bin/tic

cat /etc/caddy/Caddyfile

crontab -l | { cat; echo "* * * * * /usr/bin/tic"; } | crontab -
echo "Start cron task" && crontab -l && /usr/sbin/crond -l 8
caddy run --watch --config /etc/caddy/Caddyfile
