#!/bin/bash

set -x
set -e
source /mbtiles/mbtiles.src

uuid=$(uuidgen)

geojsonApiUrl="https://${DOMAIN_NAME}/geojson"


# pipeFile="/tmp/mbtilesPipe/${country}/${id}.cksum"


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
  curl -k -L \
    -o "${geojsonFile}" \
    "${geojsonApiUrl}/data/${country}/${id}" \
  && ogr2ogr -f MBTILES "${mbtilesFileTmp}" \
    "${geojsonFile}" \
    -dsco MAXZOOM=20 \
    -nln "osm-indoor" \
  && mv "${mbtilesFileTmp}" "${mbtilesFile}" \
  && rm -rf "${geojsonFile}" \
  && find $(dirname "${mbtilesFile}") -name $(basename ${mbtilesFile}) -size 16384c | xargs rm -rf

done
