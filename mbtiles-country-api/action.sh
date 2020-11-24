#!/bin/bash

set -x
set -e
source /mbtiles-country/mbtiles-country.src

uuid=$(uuidgen)
mkdir -p /tmp/mbtiles
mbtilesApiUrl="http://mbtiles-api/mbtiles"
allComplete=true
mkdir -p /tmp/mbtilesCountryPipe
for countryBboxesFile in $(find /tmp/mbtilesCountryPipe -name "*.geojson"); do
  bounds=$(cat ${countryBboxesFile})
  filename="$(basename ${countryBboxesFile})"
  country="${filename%.*}"
  complete=true

  while read i; do
    id=$(echo $i | jq -r -c '.properties.id')  

    # cksum=$(echo $i | jq -r -c '.cksum')
    # https://api.openindoor.io/osm/france/FranceParisGareDeLEst.cksum
    cksum=$(curl -k -L "http://osm-api/osm/${country}/${id}.cksum")

    mbtilesFile=/tmp/mbtiles/${country}/${id}_${cksum}.mbtiles
    mkdir -p $(dirname "${mbtilesFile}")

    if ! [ -f "${mbtilesFile}" ]; then
      complete=false
      allComplete=false
      status=$(curl -k -L "${mbtilesApiUrl}/status/${country}/${id}" | jq -r -c ".status")
      if [ "${status}" != "ready" ]; then
      # mbtiles not ready => Trigger mbtiles build
        triggerCode=$(curl -k -L \
          -s -w "%{http_code}" \
          "${mbtilesApiUrl}/trigger/${country}/${id}")
        continue
      else
      # mbtiles ready => Download mbtiles
      # or continue if not available
        mbtilesFileTmp=/tmp/${country}_${id}_${uuid}.mbtiles
        (curl -k -L \
          -o "${mbtilesFileTmp}" \
          "${mbtilesApiUrl}/data/${country}/${id}" \
          && mv -f "${mbtilesFileTmp}" "${mbtilesFile}") \
        || \
          (echo "Not available: ${country}/${id}" \
          && continue)
          
        find $(dirname "${mbtilesFile}") -name $(basename ${mbtilesFile}) -size 16384c | xargs rm -rf

      fi
    fi
  done <<<$(echo "${bounds}" | jq -c '.features[]')
  if [ "X${complete}" = "Xtrue" ]; then
      rm -rf ${countryBboxesFile}
  fi
  # bboxes
    # curl -k -L \
    #   -o "/tmp/${country}_bboxes.mbtiles" \
    #   "${mbtilesApiUrl}/data/bboxes/${country}" \
    # && mv "${mbtilesApiUrl}/data/bboxes" "/tmp/mbtiles/${country}_bboxes.mbtiles"
  # mbtilesFolder="/tmp/mbtiles/${country}"
  if ls /tmp/mbtiles/${country}/*.mbtiles 1> /dev/null 2>&1; then
    cksum=$(ls /tmp/mbtiles/${country}/*.mbtiles |  sed "s/.*_//" | sed "s/.mbtiles//" | cksum | sed "s/\s\d*$//")
    mkdir -p /tmp/mbtiles-country
    tile-join \
      -n ${country} \
      -o /tmp/${country}_${uuid}.mbtiles \
      $(find /tmp/mbtiles/${country} -name "*.mbtiles") \
    && mv \
      /tmp/${country}_${uuid}.mbtiles \
      /tmp/mbtiles-country/${country}.mbtiles \
    && echo -n "$cksum" > /tmp/mbtiles-country/${country}.cksum
  fi
done


