#!/bin/bash

id="$(basename $PATH_INFO)"
osmFile="/tmp/${id}.osm"
# osmApiUrl="https://api.openindoor.io/osm"
osmApiUrl="http://osm-api/osm"
code=$(curl \
    -k \
    -L \
    -o "${osmFile}" \
    -s \
    -w "%{http_code}" \
    "${osmApiUrl}/${id}.osm")

if [ "${code}" -ge "400" ]; then
    echo "HTTP/1.1 404 Not Found"
    echo "Content-type: application/json"
    echo ""
    exit 0
fi

echo "Content-type: application/json"
echo ""
echo $(osmtogeojson "${osmFile}")
exit 0