#!/bin/bash

id="$(basename $PATH_INFO)"
geojsonFile="/tmp/${id}.geojson"
CksumFile="/tmp/${id}.cksum"
# cksumFile="/tmp/${id}.cksum"
# mbtileFile="/tmp/${id}.mbtiles"
mbtileFileTmp="/tmp/${id}_$(uuidgen).mbtiles"
geojsonApiUrl="https://${DOMAIN_NAME}/geojson"
osmApiUrl="https://${DOMAIN_NAME}/osm"

######################
# STEP 1 : use cache #
######################
codeLastCksum=$(curl \
  -k \
  -L \
  -o "${CksumFile}" \
  -s \
  -w "%{http_code}" \
  "${osmApiUrl}/cksum/${id}")

cksum=$(cat "${CksumFile}")
mbtileFile="/tmp/${id}_${cksum}.mbtiles"
if [ "$?" -eq "0" ] && [ "${codeLastCksum}" -lt "400" ] && [ -f "${mbtileFile}" ]; then
  echo "Content-type: application/octet-stream"
  echo ""
  echo $(cat "${mbtileFile}")
  exit 0
fi

######################
# STEP 2 : generate  #
######################
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

if ogr2ogr -f MBTILES ${mbtileFileTmp} \
  "$geojsonFile" \
  -dsco MAXZOOM=20 \
  -nln "osm-indoor" \
  > /dev/null 2>&1 ; then
  mv ${mbtileFileTmp} ${mbtileFile} \
  && echo "Content-type: application/octet-stream" \
  && echo "" \
  && echo $(cat "${mbtileFile}") \
  && exit 0
else
  echo "HTTP/1.1 400 Bad Request" \
  && echo "Content-type: application/octet-stream" \
  && echo "" \
  && exit 0
fi

