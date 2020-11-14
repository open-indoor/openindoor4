#!/bin/sh

#varnishd -F -f /etc/varnish/default.vcl
/usr/sbin/varnishd -s malloc,128M -a :80 -f /etc/varnish/default.vcl