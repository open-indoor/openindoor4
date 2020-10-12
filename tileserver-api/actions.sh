#!/bin/bash

set -x
set -e
source /tileserver/tileserver.src

uuid=$(uuidgen)
mkdir -p /tmp/mbtiles-country
bboxesApiUrl="https://${DOMAIN_NAME}/bboxes"
mbtilesCountryApiUrl="https://${DOMAIN_NAME}/mbtiles/country"

################################
# Get mbtiles and publish them #
################################

# Get countries
countries=$(curl -k -L  "${mbtilesCountryApiUrl}/list")

if [ "X${countries}" = "X[]" ]; then exit 0; fi

# If data locally missing or data not update from remote, check if can be remotely retrieve
while read i; do
  country=$(echo $i | jq -r -c '.country')
  cksum=$(echo $i | jq -r -c '.cksum')
  status=$(echo $i | jq -r -c '.status')
  countryFile="/data/${country}_${cksum}.mbiles"
  if [ -f "${countryFile}" ]; then
    continue
  fi
  countryFileTmp="/tmp/mbtiles-country/${country}_${checksum}_${uuid}.mbiles"
  mkdir -p /tmp/mbtiles-country
  tileServerPID=$(ps x | grep "node /usr/src/app/" | grep -v "grep" | awk '{print $1}')
# "data": {
#   "zurich-vector": {
#     "mbtiles": "zurich.mbtiles"
#   }
# }
  cat /tileserver/config.json | \
    jq --arg content "${country}" --arg mbtiles /data/$(basename -- "${countryFile}") '.data[$content] = {$mbtiles}' \
    > "/tmp/config_${uuid}.json"
  curl -k -L \
    -o "${countryFileTmp}" \
    "${mbtilesCountryApiUrl}/data/${country}" \
  && mv -f "${countryFileTmp}" "${countryFile}" \
  && mv -f "/tmp/config_${uuid}.json" /tileserver/config.json \
  && kill -SIGHUP ${tileServerPID}
done <<<$(echo "${countries}" | jq -c '.[]')
