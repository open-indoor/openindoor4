#!/bin/bash
set -x
set -e

export GEOJSON_API_LOCAL_PORT=${GEOJSON_API_LOCAL_PORT:-80}

cat /tmp/Caddyfile_template | envsubst > /etc/caddy/Caddyfile
cat /etc/caddy/Caddyfile

(caddy run --watch --config /etc/caddy/Caddyfile & fcgiwrap -f -s unix:/var/run/fcgiwrap.socket)
