#!/bin/bash
/usr/bin/flock -w 1 /var/tmp/action.lock /usr/bin/action.sh