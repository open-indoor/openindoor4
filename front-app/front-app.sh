#!/bin/bash

export CADDYPATH=/data/caddy


cp -r /front-app/www /data/

cd /etc/caddy
cat ./Caddyfile | envsubst > ./Caddyfile_tmp
cat ./Caddyfile_tmp
mv  -f ./Caddyfile_tmp              ./Caddyfile

cd /data/www
cat ./index.html | envsubst > ./index_tmp.html
cat ./index_tmp.html
mv -f ./index_tmp.html ./index.html

caddy run --watch --config /etc/caddy/Caddyfile
