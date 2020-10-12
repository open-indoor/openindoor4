#!/bin/bash

export CADDYPATH=/data/caddy


cp -r /sprite-app/www /data/

cd /etc/caddy
cat ./Caddyfile | envsubst > ./Caddyfile_tmp
cat ./Caddyfile_tmp
mv  ./Caddyfile_tmp              ./Caddyfile

caddy run --watch --config /etc/caddy/Caddyfile
