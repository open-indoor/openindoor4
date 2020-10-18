#!/bin/bash

# Locally: wget http://localhost://mapbox-gl-openindoor.umd.min.js
# From front-app: wget http://mapbox-gl-openindoor/mapbox-gl-openindoor.umd.min.js
# wget https://app.openindoor.io/mapbox-gl-openindoor/dist/mapbox-gl-openindoor.umd.min.js

export CADDYPATH=/data/caddy

cd /etc/caddy
cat ./Caddyfile | envsubst > ./Caddyfile_tmp
cat ./Caddyfile_tmp
mv  ./Caddyfile_tmp              ./Caddyfile

caddy run --watch --config /etc/caddy/Caddyfile
