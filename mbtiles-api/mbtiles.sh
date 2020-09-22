#!/bin/bash

id="$(basename $PATH_INFO)"
geojsonFile="/tmp/${id}.geojson"
geojsonApiUrl="http://geojson-api"
code=$(curl \
    -k \
    -L \
    -o "${geojsonFile}" \
    -s \
    -w "%{http_code}" \
    "${geojsonApiUrl}/${id}")

if [ "${code}" -ge "400" ]; then
    echo "HTTP/1.1 404 Not Found"
    echo "Content-type: application/octet-stream"
    echo ""
    exit 0
fi

echo "Content-type: text/plain"
echo ""
echo $(ogr2ogr -f MBTILES /tmp/${id}.mbtiles $geojsonFile -dsco MAXZOOM=20 -nln "osm-indoor")
echo $(find /tmp -type f -name "*.mbtiles")
exit 0

# echo "Content-type: application/octet-stream"
# echo ""
# ogr2ogr -f MBTILES /tmp/${id}.mbtiles $geojsonFile -dsco MAXZOOM=20 -nln "osm-indoor" >/dev/null 2>&1
# cat /tmp/${id}.mbtiles
# exit 0
