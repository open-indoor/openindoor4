#!/bin/bash

export CADDYPATH=/data/caddy
export APP_URL=${APP_URL:-"https://${APP_DOMAIN_NAME}"}
export API_URL=${API_URL:-"https://${API_DOMAIN_NAME}"}
env
cp -r /map-app/www /data/

cat /tmp/Caddyfile | envsubst | tee /etc/caddy/Caddyfile

cd /data/www
for f in `find . -name "*.html"`; do
    cat ${f} | envsubst > /tmp/${f}
    cat /tmp/${f}
    mv  /tmp/${f}            ./${f}
done

# cat ./style/defaultStyle_template.json | envsubst > ./style/defaultStyle.json

caddy run --watch --config /etc/caddy/Caddyfile
