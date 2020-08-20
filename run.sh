#!/bin/sh

echo "WEB_SITE: $WEB_SITE"
echo "CADDYFILE: $CADDYFILE"

cat /style/defaultStyle_template.json | envsubst  > /style/defaultStyle.json

caddy run --watch --config ${CADDYFILE}

