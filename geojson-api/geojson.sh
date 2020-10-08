#!/bin/bash

id="$(basename $PATH_INFO)"
osmFile="/tmp/${id}.osm"
osmApiUrl="https://${DOMAIN_NAME}/osm"
code=$(curl \
    -k \
    -L \
    -o "${osmFile}" \
    -s \
    -w "%{http_code}" \
    "${osmApiUrl}/${id}")

if [ "${code}" -ge "400" ]; then
    echo "HTTP/1.1 404 Not Found"
    echo "Content-type: application/json"
    echo ""
    exit 0
fi

echo "Content-type: application/json"
echo ""
echo $(osmtogeojson -m "${osmFile}")
# echo '{"type": "FeatureCollection","features":'
# echo $(osmtogeojson -m "${osmFile}" | jq -c '.features | map(select(.properties | has("level")) | select(.properties.level | test(";.*;"; "ix") | not))')
# echo '}'
exit 0

# cat FranceParisParisGareDuNord.geojson | jq '. | select(.features[].properties.level == "0")' | less
# cat FranceParisParisGareDuNord.geojson | jq '. | select ( any(.features[]; .properties.level == "0") )' |less
# cat FranceParisParisGareDuNord.geojson | jq '. | select(.features[].properties.level|contains("0")?)' |less
# cat FranceParisParisGareDuNord.geojson | jq '. | select(.features[]| select(.properties.level|contains(";")?))' |less
# cat FranceParisParisGareDuNord.geojson | jq '. | select(.features[]| select(.properties | has("level")))' |less
# cat FranceParisParisGareDuNord.geojson | jq '. | select(.features[].properties | has("level"))' |less
# cat FranceParisParisGareDuNord.geojson | jq '.features[] | select(.properties | has("level"))' |less
# cat FranceParisParisGareDuNord.geojson | jq '.features[] | select(.properties | has("level")) | select(.properties.level | contains(";"))' |less
# cat FranceParisParisGareDuNord.geojson | jq '.features | map(select(.properties | has("level")) | select(.properties.level | contains(";")))' |less
# cat FranceParisParisGareDuNord.geojson | jq '.features | map(select(.properties | has("level")) | select(.properties.level | contains(";") | not))' |less
# cat FranceParisParisGareDuNord.geojson | jq '.features | map(select(.properties | has("level")) | select(.properties.level | test(";.*;"; "ix") | not))' |less