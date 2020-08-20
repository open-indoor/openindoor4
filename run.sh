#!/bin/sh

set -x

echo "WEB_SITE: $WEB_SITE"
echo "CADDYFILE: $CADDYFILE"
echo "OVERPASS_API: $OVERPASS_API"

cat /openindoor/style/defaultStyle_template.json | envsubst '${WEB_SITE}' > /openindoor/style/defaultStyle.json
cat /openindoor/index_template.html              | envsubst '${OVERPASS_API}' > /openindoor/index.html

cat /etc/caddy/Caddyfiles/${CADDYFILE}

caddy run --watch --config /etc/caddy/Caddyfiles/${CADDYFILE}

