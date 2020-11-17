#!/bin/bash

set -x
set -e
source /mbtiles/mbtiles.src

uuid=$(uuidgen)

geojsonApiUrl="http://geojson-api/geojson"

# pipeFile="/tmp/mbtilesPipe/${country}/${id}.cksum"

mkdir -p /tmp/mbtilesPipe

for idFile in $(find /tmp/mbtilesPipe -name "*.cksum"); do
  cksum=$(cat ${idFile})
  country=$(basename $(dirname "${idFile}"))
  filename="$(basename ${idFile})"
  id="${filename%.*}"
  mbtilesFileTmp="/tmp/${id}_${uuid}_tmp.mbtiles"
  geojsonFile="/tmp/${id}_${uuid}_tmp.geojson"
  mbtilesFile="/tmp/mbtiles/${country}/${id}_${cksum}.mbtiles"
  mkdir -p $(dirname "${mbtilesFile}")

  if [ -f "${mbtilesFile}" ]; then
    rm -rf ${idFile}
    continue
  fi
  # curl -k -L \
  #   -o "${geojsonFile}" \
  #   "${geojsonApiUrl}/data/${country}/${id}" \
  # && ogr2ogr -f MBTILES "${mbtilesFileTmp}" \
  #   "${geojsonFile}" \
  #   -dsco MAXZOOM=20 \
  #   -lco ENCODING=UTF-8 \
  #   -nln "osm-indoor" \
  # && mv "${mbtilesFileTmp}" "${mbtilesFile}" \
  # && rm -rf "${geojsonFile}" \
  # && find $(dirname "${mbtilesFile}") -name $(basename ${mbtilesFile}) -size 16384c | xargs rm -rf

# ogr2ogr -f MBTILES /tmp/FranceToulouseUniversiteToulouseJeanJaures_9926d8bf-ee4d-40d6-beb1-c8a645ba9014_tmp.mbtiles /tmp/FranceToulouseUniversiteToulouseJeanJaures_9926d8bf-ee4d-40d6-beb1-c8a645ba9014_tmp.geojson -dsco MAXZOOM=20 -lco ENCODING=UTF-8 -nln osm-indoor
  curl -k -L \
    -o "${geojsonFile}" \
    "${geojsonApiUrl}/data/${country}/${id}" \
  && tippecanoe \
    --output="${mbtilesFileTmp}" \
    --layer="osm-indoor" \
    --drop-rate=1 \
    --no-feature-limit \
    --no-tile-size-limit \
    --use-source-polygon-winding \
    --minimum-zoom=13 \
    --maximum-zoom 20 \
    --generate-ids \
    "${geojsonFile}" \
  && mv "${mbtilesFileTmp}" "${mbtilesFile}" \
  && rm -rf "${geojsonFile}" \
  && find $(dirname "${mbtilesFile}") -name $(basename ${mbtilesFile}) -size 16384c | xargs rm -rf

done
