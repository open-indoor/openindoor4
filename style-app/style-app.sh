#!/bin/bash

set -x
set -e

cat << EOF > /style/style.src
API_DOMAIN_NAME="${API_DOMAIN_NAME}"
APP_DOMAIN_NAME="${APP_DOMAIN_NAME}"
EOF

cat /usr/bin/tic
cat /usr/bin/actions.sh

export CADDYPATH=/data/caddy

cd /data/www/style/

source ./styleValues.sh

cat ./indoor/indoorLayers.json | envsubst > /tmp/indoorLayers.json \
&& mv -f /tmp/indoorLayers.json ./indoor/indoorLayers.json


#########
# rooms #
#########
while read i; do
  export roomlId="$(echo $i | jq -r -c '.id')"
  export roomColor="$(echo $i | jq -r -c '.color')"
  export roomFilter="$(echo $i | jq -r -c '.filter')"
  cat ./indoor/room.json | envsubst > /tmp/room.json
  jq '.[. | length] |= . + '"$(cat /tmp/room.json)" ./indoor/indoorLayers.json > /tmp/indoorLayers.json \
    && mv -f /tmp/indoorLayers.json ./indoor/indoorLayers.json
done <<< $(echo '[
    {"id": "indoor-room-extrusion",    "color": "#ebbc00",   "filter": [ "all", [ "==", [ "get", "indoor" ], "room" ]]},
    {"id": "indoor-area-extrusion",    "color": "#ff0000",   "filter": [ "all", [ "==", [ "get", "indoor" ], "area" ]]}
]' | jq -c '.[]')

###########
# symbols #
###########
while read i; do
  export symbolId="$(echo $i | jq -r -c '.id')"
  export symbolImage="$(echo $i | jq -r -c '.image')"
  export symbolFilter="$(echo $i | jq -r -c '.filter')"
  cat ./indoor/symbol.json | envsubst > /tmp/symbol.json
  jq '.[. | length] |= . + '"$(cat /tmp/symbol.json)" ./indoor/indoorLayers.json > /tmp/indoorLayers.json \
    && mv -f /tmp/indoorLayers.json ./indoor/indoorLayers.json
done <<< $(echo '[
    {"id": "poi-indoor-shop",             "image": "shop_64",           "filter": [ "any", [ "has", "shop" ]]},
    {"id": "poi-indoor-fast-food",        "image": "fast_food_64",      "filter": [ "all", [ "==", ["get", "amenity"], "fast_food" ]]},
    {"id": "poi-indoor-toilets",          "image": "toilet_64",         "filter": [ "all", [ "==", ["get", "amenity"], "toilets" ]]},
    {"id": "poi-indoor-shop-cosmetics",   "image": "perfumery_64",      "filter": [ "any", [ "==", ["get", "shop"], "cosmetics" ]]},
    {"id": "poi-indoor-shop-clothes",     "image": "clothing_store_64", "filter": [ "any", [ "==", ["get", "shop"], "clothes" ]]},
    {"id": "poi-indoor-shop-electronics", "image": "electronics_64",    "filter": [ "any", [ "==", ["get", "shop"], "electronics" ]]},
    {"id": "poi-indoor-shop-jewelry",     "image": "jewelry_64",        "filter": [ "any", [ "==", ["get", "shop"], "jewelry" ]]},
    {"id": "poi-indoor-shop-bakery",      "image": "bakery_64",         "filter": [ "any", [ "==", ["get", "shop"], "bakery" ]]},
    {"id": "poi-indoor-shop-dim",         "image": "dim_64",            "filter": [ "any", [ "==", ["get", "name"], "DIM" ]]},
    {"id": "poi-indoor-shop-fnac",        "image": "fnac_64",           "filter": [ "any", [ "==", ["get", "name"], "Fnac" ]]}
]' | jq -c '.[]')



cat ./shape/shapeLayers.json | envsubst > /tmp/shapeLayers.json \
&& mv -f /tmp/shapeLayers.json ./shape/shapeLayers.json

cat ./building/buildingLayers.json | envsubst > /tmp/buildingLayers.json \
&& mv -f /tmp/buildingLayers.json ./building/buildingLayers.json

cat ./openindoorStyle.json | envsubst '${INDOOR_MIN_ZOOM} ${BUILDING_MIN_ZOOM} ${BUILDING_MAX_ZOOM}' > /tmp/openindoorStyle.json \
&& mv -f /tmp/openindoorStyle.json ./openindoorStyle.json

while read i; do \
    jq '.layers[.layers | length] |= . + '"$i" ./openindoorStyle.json > /tmp/openindoorStyle.json \
    && mv -f /tmp/openindoorStyle.json ./openindoorStyle.json; \
done <<<$(cat ./building/buildingLayers.json | jq -c '.[]')
while read i; do \
    jq '.layers[.layers | length] |= . + '"$i" ./openindoorStyle.json > /tmp/openindoorStyle.json \
    && mv -f /tmp/openindoorStyle.json ./openindoorStyle.json; \
done <<<$(cat ./indoor/indoorLayers.json | jq -c '.[]')

/usr/bin/tic

cd /etc/caddy
cat ./Caddyfile | envsubst > ./Caddyfile_tmp
cat ./Caddyfile_tmp
mv  ./Caddyfile_tmp              ./Caddyfile

crontab -l | { cat; echo "* * * * * /usr/bin/tic"; } | crontab -
echo "Start cron task" && crontab -l && /usr/sbin/crond -l 8
caddy run --watch --config /etc/caddy/Caddyfile
