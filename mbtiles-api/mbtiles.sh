#!/bin/bash

# Test
# PATH_INFO=/mbtiles/trigger/FranceParisGareDeLEst DOMAIN_NAME=api-ovh.openindoor.io /mbtiles/mbtiles


id="$(basename $PATH_INFO)"
cksumFile="/tmp/${id}.cksum"
actionDirname="$(dirname $PATH_INFO)"
action="$(basename ${actionDirname})"
mbtilesApiUrl="https://${DOMAIN_NAME}/mbtiles"
osmApiUrl="https://${DOMAIN_NAME}/osm"
codeLastCksum=$(curl \
  -k \
  -L \
  -o "${cksumFile}" \
  -s \
  -w "%{http_code}" \
  "${osmApiUrl}/cksum/${id}")
if [ "$?" -ne "0" ] && [ "${codeLastCksum}" -ge "400" ]; then
    echo "HTTP/1.1 404 Not Found" \
    && echo "Content-type: text/plain" \
    && echo "" \
    && exit 0
fi
cksum=$(cat "${cksumFile}")
mbtilesFile="/tmp/mbtiles/${id}_${cksum}.mbtiles"

case  $action  in
  data)
    if [ -f "${mbtilesFile}" ]; then
      contentLength=$(wc -c < ${mbtilesFile})
      echo "Content-type: application/octet-stream"
      echo "Content-Length: $contentLength"
      echo "Content-Transfer-Encoding: binary"
      echo 'Content-Disposition: attachment; filename="'${id}.mbtiles'"'
      echo ""
      cat "${mbtilesFile}"
      exit 0
    else
      echo "HTTP/1.1 404 Not Found" \
      && echo "Content-type: text/plain" \
      && echo "" \
      && exit 0
    fi
    ;;
  status)
    if [ -f "${mbtilesFile}" ]; then
      reply='{"id":"'${id}'", "status": "ready", "url": "'${mbtilesApiUrl}/data/${id}'"}'
    else
      reply='{"id":"'${id}'", "status": "not found"}'
    fi
    echo "Content-type: application/json"
    echo ""
    echo "${reply}"
    exit 0
    ;;
  trigger)
    mkdir -p /tmp/mbtilesPipe
    echo -n "${cksum}" > /tmp/mbtilesPipe/${id}.cksum
    reply='{"api":"mbtiles", "id":"'${id}'", "status": "trigger received"}'
    echo "Content-type: application/json"
    echo ""
    echo "${reply}"
    exit 0
    ;;
  *)              
esac 
