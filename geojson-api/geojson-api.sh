#!/bin/bash
set -x
set -e

cat /tmp/Caddyfile_template | envsubst > /etc/caddy/Caddyfile
cat /etc/caddy/Caddyfile

(caddy run --watch --config /etc/caddy/Caddyfile & fcgiwrap -f -s unix:/var/run/fcgiwrap.socket)
