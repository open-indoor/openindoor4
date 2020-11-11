#!/bin/bash

# set -x
# set -e
# API_DOMAIN_NAME="api.openindoor.io" PATH_INFO="data/france/FranceParisGareDeLEst" /geojson/geojson
# API_DOMAIN_NAME="api.openindoor.io" PATH_INFO="data/france/FranceRennesCampusDeVillejean" /geojson/geojson
# API_DOMAIN_NAME="api.openindoor.io" PATH_INFO="data/costa_rica/CostaRicaSanJoseStarbucks" /geojson/geojson
# API_DOMAIN_NAME="api.openindoor.io" PATH_INFO="data/united_states/UnitedStatesLosAngelesUnionStation" /geojson/geojson


action="$(echo ${PATH_INFO} | cut -d'/' -f1)"
country="$(echo ${PATH_INFO} | cut -d'/' -f2)"
id="$(echo ${PATH_INFO} | cut -d'/' -f3)"
uuid=$(uuidgen)
geojsonFile=/tmp/${country}_${id}_${uuid}.geojson

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

osmtogeojson -m "${osmFile}" > "${geojsonFile}"

cat "${geojsonFile}" | jq -c \
'(['\
'  .features[] | '\
'  ('\
'      (select(.properties | has("level")) | .properties.level |= ( gsub("(;\\d)+;"; ";") | gsub("-";";" ) ) )'\
'  )'\
'])' > "${geojsonFile}_level"

cat "${geojsonFile}" | jq -c \
'(['\
'  .features[] | '\
'  ('\
'      select(.properties | has("level") | not) '\
'  )'\
'])' > "${geojsonFile}_nolevel"

jq -c -s '[.[][]]' "${geojsonFile}_nolevel" "${geojsonFile}_level" > "${geojsonFile}_filtered"

cat "${geojsonFile}_filtered"
echo '}'


# echo '{"features":[{"properties": {"aaa":"bbb", "level":"0;1;2"}}, {"properties": {"level": "1-2"}}, {"properties": {"xxx": "yyy"}}]}' | jq \
# '(['\
# '  .features[] | '\
# '  ('\
# '      (select(.properties | has("level")) | .properties.level |= ( gsub("(;\\d)+;"; ";") | gsub("-";";" ) ) )'\
# '  )'\
# '])' > level.json


# echo '{"features":[{"properties": {"aaa":"bbb", "level":"0;1;2"}}, {"properties": {"level": "1-2"}}, {"properties": {"xxx": "yyy"}}]}' | jq \
# '(['\
# '  .features[] | '\
# '  ('\
# '      select(.properties | has("level") | not) '\
# '  )'\
# '])' > nolevel.json
# jq -s '[.[][]]' level.json nolevel.json
# | jq -c '.features[].properties.level |= gsub("-";";"))'
# |= gsub("(;\\d)+;"; ";")


# | jq -c '.features[].properties.level |= gsub("(;\\d)+;"; ";") |= gsub("-";";")' \

# | jq -c \
# '  .features | '\
# '  map('\
# '    select('\
# '      select(.properties | has("level")) | select(.properties.level | test(";.*;"; "ix") | not) '\
# '      or '\
# '      select(.properties | has("level") | not) '\
# '    )'\
# '  )'\
# | jq -c '.features[].properties.level |= gsub("-";";"))'

# echo -n $(osmtogeojson -m "${osmFile}" | jq -c .)

exit 0
