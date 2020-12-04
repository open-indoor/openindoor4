#!/bin/bash

# PATH_INFO=list/world     /mbtiles-country/mbtiles-country
# PATH_INFO=status/france  /mbtiles-country/mbtiles-country
# PATH_INFO=trigger/france /mbtiles-country/mbtiles-country
# PATH_INFO=trigger/world  /mbtiles-country/mbtiles-country
# PATH_INFO=data/france    /mbtiles-country/mbtiles-country

# world/list
# france/status
# france/trigger
# france/data

action="$(echo ${PATH_INFO} | cut -d'/' -f1)"
country="$(echo ${PATH_INFO} | cut -d'/' -f2)"
format="$(echo ${PATH_INFO} | cut -d'/' -f3)"

mkdir -p /tmp/mbtiles-country

uuid=$(uuidgen)
placesApiUrl="http://places-api/places"
# mbtilesApiUrl="http://mbtiles-api/mbtiles"
BBOXES="/tmp/bboxes_${country}.json"
mbtilesCountryFile=/tmp/mbtiles-country/${country}.mbtiles
code=$(curl \
    -k \
    -L \
    -o "${BBOXES}" \
    -s \
    -w "%{http_code}" \
    "${placesApiUrl}/data/${country}")

if [ "${code}" -ge "400" ]; then
    echo "HTTP/1.1 404 Not Found"
    echo "Content-type: text/plain"
    echo ""
    exit 0
fi

case $action in
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
      reply='{"country":"'${country}'", "status": "ready", "url": "'${API_URL}/mbtiles-country/data/${country}'"}'
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
    case ${country} in
      world)
        countries=$(curl -k -L "${placesApiUrl}/countries/world")
        ;;
      *)
        countries='[{"country":"'${country}'"}]'
        ;;
    esac
    mkdir -p /tmp/mbtilesCountryPipe
    while read i; do
      myCountry="$(echo $i | jq -r -c '.country | ascii_downcase | gsub("\\s+";"_")')"
      curl -k -L "${placesApiUrl}/data/${myCountry}" > /tmp/mbtilesCountryPipe/${myCountry}.geojson
    done <<< $(echo "${countries}" | jq -c '.[]')
    echo "Content-type: application/json"
    echo ""
    echo '{"api":"mbtiles-country", "countries": '${countries}', "status": "trigger received"}'
    nohup tic 2>/dev/null 1>/dev/null &
    exit 0
    ;;
  *)
    ;;          
esac 
