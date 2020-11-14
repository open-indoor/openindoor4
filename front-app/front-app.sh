#!/bin/bash
set -x
set -e

export CADDYPATH=/data/caddy
export APP_SERVER=${APP_SERVER:-${APP_DOMAIN_NAME}}
export APP_URL=${APP_URL:-https://${APP_DOMAIN_NAME}}
export CADDY_TLS=${CADDY_TLS:-'tls contact@openindoor.io {
    ca ${CERTIFICATE_AUTHORITY}
}'}

env

# cat /tmp/Caddyfile | envsubst | tee /etc/caddy/Caddyfile
cat /tmp/Caddyfile | tee /etc/caddy/Caddyfile

mkdir -p /data/www
cat /tmp/index.html | envsubst | tee /data/www/index.html

caddy run --watch --config /etc/caddy/Caddyfile
