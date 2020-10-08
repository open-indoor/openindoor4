#!/bin/bash

# Locally: wget http://localhost://fonts-app.umd.min.js
# From front-app: wget http://fonts-app/fonts-app.umd.min.js
# wget https://app.openindoor.io/fonts-app/dist/fonts-app.umd.min.js

export CADDYPATH=/data/caddy

cd /etc/caddy
cat ./Caddyfile | envsubst > ./Caddyfile_tmp
cat ./Caddyfile_tmp
mv  ./Caddyfile_tmp              ./Caddyfile

caddy run --watch --config /etc/caddy/Caddyfile
