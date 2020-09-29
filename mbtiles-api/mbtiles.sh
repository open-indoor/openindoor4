#!/bin/bash

id="$(basename $PATH_INFO)"
action="$(basename($(dirname $PATH_INFO)))"
mbtilesApiUrl="https://${DOMAIN_NAME}/mbtiles"
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
    geojsonApiUrl="https://${DOMAIN_NAME}/geojson"
    uuid=$(uuidgen)
    mbtilesFileTmp="/tmp/${id}_${uuid}.mbtiles"
    action="/tmp/actions/${uuid}.sh"
    mkdir -p $(dirname ${action})
    geojsonFile="/tmp/${id}_${uuid}.geojson"
    cat << EOF > ${action}
#!/bin/bash
echo "coucou"
curl \
  -k \
  -L \
  -o "${geojsonFile}" \
  "${geojsonApiUrl}/${id}" \
&& ogr2ogr -f MBTILES ${mbtilesFileTmp} \
  "$geojsonFile" \
  -dsco MAXZOOM=20 \
  -nln "osm-indoor" \
  > /dev/null 2>&1 \
&& mv ${mbtilesFileTmp} ${mbtilesFile} \
    && contentLength=$(wc -c < ${mbtilesFile})
EOF
    chmod +x "${action}"
    reply='{"api":"mbtiles", "id":"'${id}'", "status": "trigger received"}'
    echo "Content-type: application/json"
    echo ""
    echo "${reply}"
    exit 0
    ;;
  *)              
esac 

geojsonFile="/tmp/${id}.geojson"
cksumFile="/tmp/${id}.cksum"
# cksumFile="/tmp/${id}.cksum"
# mbtilesFile="/tmp/${id}.mbtiles"
mbtilesFileTmp="/tmp/${id}_$(uuidgen).mbtiles"
geojsonApiUrl="https://${DOMAIN_NAME}/geojson"
osmApiUrl="https://${DOMAIN_NAME}/osm"

############################
# STEP 1 : use cache first #
############################
codeLastCksum=$(curl \
  -k \
  -L \
  -o "${cksumFile}" \
  -s \
  -w "%{http_code}" \
  "${osmApiUrl}/cksum/${id}")

if [ "$?" -ne "0" ] && [ "${codeLastCksum}" -ge "400" ]; then
    echo "HTTP/1.1 404 Not Found" \
    && echo "Content-type: application/octet-stream" \
    && echo "" \
    && exit 0
fi

cksum=$(cat "${cksumFile}")
mkdir -p /tmp/mbtiles
mbtilesFile="/tmp/mbtiles/${id}_${cksum}.mbtiles"
if [ -f "${mbtilesFile}" ]; then
  contentLength=$(wc -c < ${mbtilesFile})
  echo "Content-type: application/octet-stream"
  echo "Content-Length: $contentLength"
  echo "Content-Transfer-Encoding: binary"
  echo 'Content-Disposition: attachment; filename="'${id}.mbtiles'"'
  echo ""
  cat "${mbtilesFile}"
  exit 0
fi

#####################
# STEP 2 : generate #
#####################
code=$(curl \
    -k \
    -L \
    -o "${geojsonFile}" \
    -s \
    -w "%{http_code}" \
    "${geojsonApiUrl}/${id}")

if [ "$?" -ne "0" ] && [ "${code}" -ge "400" ]; then
    echo "HTTP/1.1 404 Not Found" \
    && echo "Content-type: application/octet-stream" \
    && echo "" \
    && exit 0
fi

if ogr2ogr -f MBTILES ${mbtilesFileTmp} \
  "$geojsonFile" \
  -dsco MAXZOOM=20 \
  -nln "osm-indoor" \
  > /dev/null 2>&1 ; then
    mv ${mbtilesFileTmp} ${mbtilesFile} \
    && contentLength=$(wc -c < ${mbtilesFile}) \
    && echo "Content-type: application/octet-stream" \
    && echo "Content-Length: $contentLength" \
    && echo "Content-Transfer-Encoding: binary" \
    && echo 'Content-Disposition: attachment; filename="'${id}.mbtiles'"' \
    && echo "" \
    && cat "${mbtilesFile}" \
    && exit 0
else
    echo "HTTP/1.1 400 Bad Request" \
    && echo "Content-type: application/octet-stream" \
    && echo "" \
    && exit 0
fi

