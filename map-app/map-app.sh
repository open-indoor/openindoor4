#!/bin/bash

export CADDYPATH=/data/caddy


cp -r /map-app/www /data/

cd /etc/caddy
cat ./Caddyfile | envsubst > ./Caddyfile_tmp
cat ./Caddyfile_tmp
mv  ./Caddyfile_tmp              ./Caddyfile

cd /data/www
for f in `find . -name "*.html"`; do
    cat ${f} | envsubst > /tmp/${f}
    cat /tmp/${f}
    mv  /tmp/${f}            ./${f}
done

cat ./style/defaultStyle_template.json | envsubst > ./style/defaultStyle.json

caddy run --watch --config /etc/caddy/Caddyfile
