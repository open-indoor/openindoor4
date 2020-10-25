#!/bin/bash

set -x
set -e
source /mbtiles/mbtiles.src

uuid=$(uuidgen)
mkdir -p /tmp/geojson
mkdir -p /tmp/mbtiles

geojsonApiUrl="https://${DOMAIN_NAME}/geojson"

for idFile in $(find /tmp/mbtilesPipe -name "*.cksum"); do
  cksum=$(cat ${idFile})
  filename="$(basename ${idFile})"
  filename="${filename%.*}"
  country="${filename%_*}"
  id="${filename##*_}"
  mbtilesFileTmp="/tmp/${id}_${uuid}.mbtiles"
  geojsonFile="/tmp/${id}_${uuid}.geojson"
  mbtilesFile="/tmp/mbtiles/${country}/${id}_${cksum}.mbtiles"

  if [ -f "${mbtilesFile}" ]; then
    continue
  fi
  curl -k -L \
    -o "${geojsonFile}" \
    "${geojsonApiUrl}/data/${country}/${id}" \
  && ogr2ogr -f MBTILES "${mbtilesFile}" \
    "${geojsonFile}" \
    -dsco MAXZOOM=20 \
    -nln "osm-indoor"
  # && mv "${mbtilesFileTmp}" "${mbtilesFile}"
  rm -rf ${idFile}
done
