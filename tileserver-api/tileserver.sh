#!/bin/bash

# PATH_INFO=/tileserver/info /tileserver/tileserver

# actionDirname="$(dirname $PATH_INFO)"
action="$(basename ${PATH_INFO})"

case $action in
  info)
    reply='{"api":"tileserver", "country":"xxx"}'
    echo "Content-type: application/json"
    echo ""
    echo "${reply}"
    exit 0
    ;;
    # https://api.openindoor.io/mbtiles/country/status/france
  *)              
esac 








