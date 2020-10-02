#!/bin/bash

set -x
set -e
source /mbtiles/mbtiles.src

uuid=$(uuidgen)
mkdir -p /tmp/geojson
mkdir -p /tmp/mbtiles
for idFile in $(find /tmp/mbtilesPipe -name "*.cksum"); do
  cksum=$(cat ${idFile})
  rm -rf ${idFile}
  filename="$(basename ${idFile})"
  id="${filename%.*}"
  geojsonApiUrl="https://${DOMAIN_NAME}/geojson"
  mbtilesFileTmp="/tmp/${id}_${uuid}.mbtiles"
  geojsonFile="/tmp/${id}_${uuid}.geojson"
  mbtilesFile="/tmp/mbtiles/${id}_${cksum}.mbtiles"
  if [ -f "${mbtilesFile}" ]; then
    continue
  fi
  curl -k -L \
    -o "${geojsonFile}" \
    "${geojsonApiUrl}/${id}" \
  && ogr2ogr -f MBTILES ${mbtilesFile} \
    "${geojsonFile}" \
    -dsco MAXZOOM=20 \
    -nln "osm-indoor" \
  && mv "${mbtilesFileTmp}" "${mbtilesFile}"
done
