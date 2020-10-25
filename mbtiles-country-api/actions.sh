#!/bin/bash

set -x
set -e
source /mbtiles-country/mbtiles-country.src

uuid=$(uuidgen)
mkdir -p /tmp/mbtiles
mbtilesApiUrl="https://${API_DOMAIN_NAME}/mbtiles"
for countryBboxesFile in $(find /tmp/mbtilesCountryPipe -name "*.json"); do
  bboxes=$(cat ${countryBboxesFile})
  filename="$(basename ${countryBboxesFile})"
  country="${filename%.*}"
  complete=true

  while read i; do
    id=$(echo $i | jq -r -c '.id')
    cksum=$(echo $i | jq -r -c '.cksum')
    mbtilesFile=/tmp/mbtiles/${country}_${id}_${cksum}.mbtiles
    if ! [ -f "${mbtilesFile}" ]; then
      complete=false
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
      fi
    fi
  done <<<$(echo "${bboxes}" | jq -c '.[]')
  if [ "X${complete}" = "Xtrue" ]; then
      rm -rf ${countryBboxesFile}
  fi
  # bboxes
    # curl -k -L \
    #   -o "/tmp/${country}_bboxes.mbtiles" \
    #   "${mbtilesApiUrl}/data/bboxes/${country}" \
    # && mv "${mbtilesApiUrl}/data/bboxes" "/tmp/mbtiles/${country}_bboxes.mbtiles"
  if ls /tmp/mbtiles/${country}_*.mbtiles 1> /dev/null 2>&1; then
    cksum=$(ls /tmp/mbtiles/${country}_*.mbtiles |  sed "s/.*_//" | sed "s/.mbtiles//" | cksum | sed "s/\s\d*$//")
    mkdir -p /tmp/mbtiles-country
    tile-join \
      -n ${country} \
      -o /tmp/${country}_${uuid}.mbtiles \
      $(find /tmp/mbtiles -name "${country}_*.mbtiles") \
    && mv \
      /tmp/${country}_${uuid}.mbtiles \
      /tmp/mbtiles-country/${country}.mbtiles \
    && echo -n "$cksum" > /tmp/mbtiles-country/${country}.cksum
  fi  
done
