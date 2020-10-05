#!/bin/bash

# PATH_INFO=/mbtiles/country/data/france DOMAIN_NAME=api-ovh.openindoor.io /mbtiles-country/mbtiles-country
# PATH_INFO=/mbtiles/country/status/france DOMAIN_NAME=api-ovh.openindoor.io /mbtiles-country/mbtiles-country

country="$(basename $PATH_INFO)"
actionDirname="$(dirname $PATH_INFO)"
action="$(basename ${actionDirname})"
uuid=$(uuidgen)
# bboxesApiUrl="http://osm-api/bboxes"
bboxesApiUrl="https://${DOMAIN_NAME}/bboxes"
mbtilesApiUrl="https://${DOMAIN_NAME}/mbtiles"
mbtilesCountryApiUrl="https://${DOMAIN_NAME}/mbtiles"
BBOXES="/tmp/bboxes_${country}.json"
mbtilesCountryFile=/tmp/mbtiles-country/${country}.mbtiles
code=$(curl \
    -k \
    -L \
    -o "${BBOXES}" \
    -s \
    -w "%{http_code}" \
    "${bboxesApiUrl}/country/${country}")

if [ "${code}" -ge "400" ]; then
    echo "HTTP/1.1 404 Not Found"
    echo "Content-type: text/plain"
    echo ""
    exit 0
fi

case  $action  in
  list)
#   [{"country":"france","cksum":xxx},{"country":"brasil","cksum":yyy}]
    list="["
    for countryMbtilesFile in $(find /tmp/mbtiles-country -name "*.mbtiles"); do
      list="${list}{"
      list="${list}\"country\":"
      list="${list}\"$(basename ${countryMbtilesFile%.*})\","
      cksumFile="${countryMbtilesFile%.*}.cksum"
      list="${list}\"cksum\":$(cat ${cksumFile})"
      list="${list}},"
    done
    list=$(echo -n "$list" | sed 's/,$//')
    list="${list}]"
    echo "Content-type: application/json"
    echo ""
    echo "${list}"
    exit 0
    ;;
  data)
    if [ -f "${mbtilesCountryFile}" ]; then
      contentLength=$(wc -c < ${mbtilesCountryFile})
      echo "Content-type: application/octet-stream"
      echo "Content-Length: $contentLength"
      echo "Content-Transfer-Encoding: binary"
      echo 'Content-Disposition: attachment; filename="'${country}.mbtiles'"'
      echo ""
      cat "${mbtilesCountryFile}"
      exit 0
    else
      echo "HTTP/1.1 404 Not Found" \
      && echo "Content-type: text/plain" \
      && echo "" \
      && echo "" \
      && exit 0
    fi
    ;;
    # https://api.openindoor.io/mbtiles/country/status/france
  status)
    if [ -f "${mbtilesCountryFile}" ]; then
      reply='{"country":"'${country}'", "status": "ready", "url": "'${mbtilesCountryApiUrl}/data/${country}'"}'
    elif [ -f "/tmp/mbtilesCountryPipe/${country}.json" ]; then
      reply='{"country":"'${country}'", "status": "in progress"}'
    else
      reply='{"country":"'${country}'", "status": "not found"}'
    fi
    echo "Content-type: application/json"
    echo ""
    echo "${reply}"
    exit 0
    ;;
  trigger)
    mkdir -p /tmp/mbtilesCountryPipe
    cat "${BBOXES}" > /tmp/mbtilesCountryPipe/${country}.json
    reply='{"api":"mbtiles-country", "country":"'${country}'", "status": "trigger received"}'
    echo "Content-type: application/json"
    echo ""
    echo "${reply}"
    nohup /usr/bin/tic
    exit 0
    ;;
  *)              
esac 
