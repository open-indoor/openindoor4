#!/bin/bash

# API_DOMAIN_NAME="api.openindoor.io" PATH_INFO="data/france/FranceParisGareDeLEst" /geojson/geojson
# API_DOMAIN_NAME="api.openindoor.io" PATH_INFO="data/costa_rica/CostaRicaSanJoseStarbucks" /geojson/geojson


action="$(echo ${PATH_INFO} | cut -d'/' -f1)"
country="$(echo ${PATH_INFO} | cut -d'/' -f2)"
id="$(echo ${PATH_INFO} | cut -d'/' -f3)"

osmFile="/tmp/${id}.osm"
osmApiUrl="https://${API_DOMAIN_NAME}/osm"
code=$(curl -k -L \
    -o "${osmFile}" \
    -s -w "%{http_code}" \
    "${osmApiUrl}/${country}/${id}.osm")

if [ "${code}" -ge "400" ]; then
    echo "HTTP/1.1 404 Not Found"
    echo "Content-type: application/json"
    echo ""
    exit 0
fi

echo "Content-type: application/json"
echo ""
echo -n '{"type": "FeatureCollection","features":'
echo -n $(\
osmtogeojson -m "${osmFile}" \
| jq -c \
'  .features | '\
'  map('\
'    select('\
'      select(.properties | has("level")) | select(.properties.level | test(";.*;"; "ix") | not) '\
'      or '\
'      select(.properties | has("level") | not) '\
'    )'\
'  )'\
)
echo '}'
exit 0
