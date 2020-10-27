#!/bin/sh

cat /etc/varnish/default.vcl | envsubst >   /tmp/default.vcl
cat /tmp/default.vcl
mv -f /tmp/default.vcl              /etc/varnish/default.vcl

#varnishd -F -f /etc/varnish/default.vcl
/usr/sbin/varnishd -s malloc,128M -a :80 -f /etc/varnish/default.vcl