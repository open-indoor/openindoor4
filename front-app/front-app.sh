#!/bin/bash

export CADDYPATH=/data/caddy


cp -r /front-app/www /data/

cd /etc/caddy
cat ./Caddyfile | envsubst > ./Caddyfile_tmp
cat ./Caddyfile_tmp
mv  ./Caddyfile_tmp              ./Caddyfile

cd /data/www
cat ./index.html | envsubst > /tmp/index.html
cat /tmp/index.html
mv  /tmp/index.html              ./index.html

caddy run --watch --config /etc/caddy/Caddyfile
