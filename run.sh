#!/bin/sh

set -x

echo "WEB_SITE: $WEB_SITE"
echo "CADDYFILE: $CADDYFILE"

cat /openindoor/style/defaultStyle_template.json | envsubst  > /openindoor/style/defaultStyle.json

cat /etc/caddy/Caddyfiles/${CADDYFILE}

caddy run --watch --config /etc/caddy/Caddyfiles/${CADDYFILE}

