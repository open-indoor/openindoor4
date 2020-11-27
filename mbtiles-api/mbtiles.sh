#!/bin/bash

# PATH_INFO=status/france/FranceParisGareDeLEst /mbtiles/mbtiles
# PATH_INFO=trigger/france/FranceParisGareDeLEst /mbtiles/mbtiles
# PATH_INFO=data/france/FranceParisGareDeLEst /mbtiles/mbtiles
# PATH_INFO=pins/france /mbtiles/mbtiles

# /mbtiles/status/france/FranceParisGareDeLEst
# /mbtiles/trigger/france/FranceParisGareDeLEst
# /mbtiles/data/france/FranceParisGareDeLEst
# /mbtiles/pins/france

action="$(echo ${PATH_INFO} | cut -d'/' -f1)"
country="$(echo ${PATH_INFO} | cut -d'/' -f2)"
id="$(echo ${PATH_INFO} | cut -d'/' -f3)"

uuid=$(uuidgen)

case ${action} in
  pins)
    # get geojson
    geojsonFile="/tmp/${country}_${uuid}.geojson"
    cksum=$(curl -k -L "http://places-api/places/checksum/${country}")
    mbtilesFile="/tmp/mbtiles/${country}/pins_${cksum}.mbtiles"
    mkdir -p "$(dirname ${mbtilesFile})"
    codePins=$(curl -k -L \
      -s -w "%{http_code}" \
      -o "${geojsonFile}" "http://places-api/places/pins/${country}")
    if [ "$?" -ne "0" ] && [ "${codePins}" -ge "400" ]; then
        echo "HTTP/1.1 404 Not Found" \
        && echo "Content-type: text/plain" \
        && echo "" \
        && exit 0
    fi
    
    ogr2ogr -f MBTILES "${mbtilesFile}" \
      "${geojsonFile}" \
      -dsco MAXZOOM=20 \
      -nln "osm-indoor-pins"

    contentLength=$(wc -c < ${mbtilesFile})
    echo "Content-type: application/octet-stream"
    echo "Content-Length: $contentLength"
    echo "Content-Transfer-Encoding: binary"
    echo 'Content-Disposition: attachment; filename="'"pins_${country}_${cksum}.mbtiles"'"'
    echo ""
    cat "${mbtilesFile}"

    rm -rf "${mbtilesFile}"
    rm -rf "${geojsonFile}"
    exit 0
    ;;
  *)              
esac 

cksumFile="/tmp/${id}.cksum"
mbtilesApiUrl="${API_URL}/mbtiles"
osmApiUrl="http://osm-api/osm"
codeLastCksum=$(curl \
  -k \
  -L \
  -o "${cksumFile}" \
  -s \
  -w "%{http_code}" \
  "${osmApiUrl}/${country}/${id}.cksum")
if [ "$?" -ne "0" ] && [ "${codeLastCksum}" -ge "400" ]; then
    echo "HTTP/1.1 404 Not Found" \
    && echo "Content-type: text/plain" \
    && echo "" \
    && exit 0
fi
cksum=$(cat "${cksumFile}")
rm -rf "${cksumFile}"
pipeFile="/tmp/mbtilesPipe/${country}/${id}.cksum"
mbtilesFile="/tmp/mbtiles/${country}/${id}_${cksum}.mbtiles"
# mkdir -p $(dirname "${mbtilesFile}")

case $action in
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
      reply='{"id":"'${id}'", "status": "ready", "cksum": "'${cksum}'", "url": "'${mbtilesApiUrl}/data/${country}/${id}'"}'
    elif [ -f "${pipeFile}" ]; then
      reply='{"id":"'${id}'", "status": "in progress", "cksum": "'${cksum}'"}'
    else
      reply='{"id":"'${id}'", "status": "not found"}'
    fi
    echo "Content-type: application/json"
    echo ""
    echo "${reply}"
    exit 0
    ;;
  trigger)
    mkdir -p $(dirname "${pipeFile}")
    echo -n "${cksum}" > "${pipeFile}"
    reply='{"api":"mbtiles", "country":"'${country}'", "id":"'${id}'", "status": "trigger received"}'
    echo "Content-type: application/json"
    echo ""
    echo "${reply}"
    nohup tic 2>/dev/null 1>/dev/null &
    exit 0
    ;;
  update)
    mbtilesFile="/tmp/mbtiles/${country}/${id}_${cksum}.mbtiles"
    rm -rf ${mbtilesFile}
    mkdir -p $(dirname "${pipeFile}")
    echo -n "${cksum}" > "${pipeFile}"
    reply='{"api":"mbtiles", "country":"'${country}'", "id":"'${id}'", "status": "trigger received"}'
    echo "Content-type: application/json"
    echo ""
    echo "${reply}"
    nohup tic 2>/dev/null 1>/dev/null &
    exit 0
    ;;
  *)
    echo "HTTP/1.1 404 Not Found" \
    && echo "Content-type: text/plain" \
    && echo "" \
    && exit 0
    ;;
esac 
