#!/bin/bash

set -x

id="$(basename $PATH_INFO)"
geojsonFile="/tmp/${id}.geojson"
lastCksumFile="/tmp/${id}.cksum.last"
cksumFile="/tmp/${id}.cksum"
# mbtileFile="/tmp/${id}.mbtiles"
geojsonApiUrl="https://${DOMAIN_NAME}/geojson"
osmApiUrl="https://${DOMAIN_NAME}/osm"

######################
# STEP 1 : use cache #
######################
codeLastCksum=$(curl \
  -k \
  -L \
  -o "${lastCksumFile}" \
  -s \
  -w "%{http_code}" \
  "${osmApiUrl}/cksum/${id}")

lastCksum=$(cat "${lastCksumFile}")
mbtileFile="/tmp/${id}_${lastCksum}.mbtiles"
if [ "$?" -eq "0" ] && [ "${codeLastCksum}" -lt "400" ] && [ -f "${mbtileFile}" ]; then
  echo "Content-type: application/octet-stream"
  echo ""
  echo $(cat "${mbtileFile}")
  exit 0
fi

code=$(curl \
    -k \
    -L \
    -o "${geojsonFile}" \
    -s \
    -w "%{http_code}" \
    "${geojsonApiUrl}/${id}")

if [ "$?" -ne "0" ] && [ "${code}" -ge "400" ]; then
    echo "HTTP/1.1 404 Not Found" \
    && echo "Content-type: application/octet-stream" \
    && echo "" \
    && exit 0
fi

ogr2ogr -f MBTILES ${mbtileFile} \
  "$geojsonFile" \
  -dsco MAXZOOM=20 \
  -nln "osm-indoor" \
  >/dev/null 2>&1 \
  || \
  echo "HTTP/1.1 400 Bad Request" \
  && echo "Content-type: application/octet-stream" \
  && echo "" \
  && exit 0

echo "Content-type: application/octet-stream"
echo ""
echo $(cat "${mbtileFile}")
exit 0
