#!/bin/bash

cd /etc/caddy
cat ./Caddyfile | envsubst > ./Caddyfile_tmp
cat ./Caddyfile_tmp
mv  ./Caddyfile_tmp              ./Caddyfile

caddy run --watch --config /etc/caddy/Caddyfile &
fcgiwrap -f -s tcp:127.0.0.1:8999