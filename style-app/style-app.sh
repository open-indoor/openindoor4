#!/bin/bash

set -x
set -e

chmod +x /usr/bin/tic
chmod +x /usr/bin/actions.sh

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



    # {"id": "indoor-area-extrusion",    "color": "#ff0000",   "height": 0, "filter": [ "all", [ "==", [ "get", "indoor" ], "area" ]]}

####################
# indoor - symbols #
####################
while read i; do
  export symbolId="$(echo $i | jq -r -c '.id')"
  export symbolImage="$(echo $i | jq -r -c '.image')"
  export symbolFilter="$(echo $i | jq -r -c '.filter')"
  cat ./indoor/symbol.json | envsubst > /tmp/symbol.json
  jq '.[. | length] |= . + '"$(cat /tmp/symbol.json)" ./indoor/indoorLayers.json > /tmp/indoorLayers.json \
    && mv -f /tmp/indoorLayers.json ./indoor/indoorLayers.json
done <<< $(echo '[
    {"id": "poi-indoor-room",             "image": "",                  "filter": [ "all", [ "==", [ "get", "indoor" ], "room" ]]},
    {"id": "poi-indoor-shop",             "image": "shop_64",           "filter": [ "any", [ "has", "shop" ]]},
    {"id": "poi-indoor-fast-food",        "image": "fast_food_64",      "filter": [ "all", [ "==", ["get", "amenity"], "fast_food" ]]},
    {"id": "poi-indoor-toilets",          "image": "toilet_64",         "filter": [ "all", [ "==", ["get", "amenity"], "toilets" ]]},
    {"id": "poi-indoor-shop-coffee",      "image": "cafe_64",           "filter": [ "all", [ "==", ["get", "amenity"], "cafe" ]]},
    {"id": "poi-indoor-shop-cosmetics",   "image": "perfumery_64",      "filter": [ "any", [ "==", ["get", "shop"], "cosmetics" ]]},
    {"id": "poi-indoor-shop-clothes",     "image": "clothing_store_64", "filter": [ "any", [ "==", ["get", "shop"], "clothes" ]]},
    {"id": "poi-indoor-shop-electronics", "image": "electronics_64",    "filter": [ "any", [ "==", ["get", "shop"], "electronics" ]]},
    {"id": "poi-indoor-shop-jewelry",     "image": "jewelry_64",        "filter": [ "any", [ "==", ["get", "shop"], "jewelry" ]]},
    {"id": "poi-indoor-shop-bakery",      "image": "bakery_64",         "filter": [ "any", [ "==", ["get", "shop"], "bakery" ]]},
    {"id": "poi-indoor-shop-dim",         "image": "dim_64",            "filter": [ "any", [ "==", ["get", "name"], "DIM" ]]},
    {"id": "poi-indoor-shop-fnac",        "image": "fnac_64",           "filter": [ "any", [ "==", ["get", "name"], "Fnac" ]]}
]' | jq -c '.[]')

##################
# indoor - rooms #
##################
while read i; do
  export roomId="$(echo $i | jq -r -c '.id')"
  export roomColor="$(echo $i | jq -r -c '.color')"
  export roomFilter="$(echo $i | jq -r -c '.filter')"
  export roomHeight="$(echo $i | jq -r -c '.height')"
  cat ./indoor/room.json | envsubst > /tmp/room.json
  jq '.[. | length] |= . + '"$(cat /tmp/room.json)" ./indoor/indoorLayers.json > /tmp/indoorLayers.json \
    && mv -f /tmp/indoorLayers.json ./indoor/indoorLayers.json
done <<< $(echo '[
    {"id": "indoor-room-extrusion",      "color": "#ebbc00",   "height": 3, "filter": [ "all", [ "==", [ "get", "indoor" ], "room" ]]},
    {"id": "indoor-area-extrusion",      "color": "#e0b0F0",   "height": 0, "filter": [ "all", [ "==", [ "get", "indoor" ], "area" ]]},
    {"id": "indoor-indoor-extrusion",    "color": "#10e0F0",   "height": 0, "filter": [ "all", [ "has", "indoor" ]]}
]' | jq -c '.[]')

####################
# indoor - highway #
####################
layer="indoor"
type="line"
while read i; do
  export id="$(echo $i | jq -r -c '.id')"
  export color="$(echo $i | jq -r -c '.color')"
  export width="$(echo $i | jq -r -c '.width')"
  export filter="$(echo $i | jq -r -c '.filter')"
  cat ./${layer}/${type}.json | envsubst > /tmp/${type}.json
  jq '.[. | length] |= . + '"$(cat /tmp/${type}.json)" "./${layer}/${layer}Layers.json" > "/tmp/${layer}Layers.json" \
    && mv -f "/tmp/${layer}Layers.json" "./${layer}/${layer}Layers.json"
done <<< $(echo '[
    {"id": "indoor-highway-line",      "color": "#ebbc00", "width": 5, "filter": [ "all", [ "has", "highway" ]]},
    {"id": "indoor-footway-line",      "color": "#ff0000", "width": 5, "filter": [ "all", [ "has", "highway" ], [ "==", [ "get", "highway" ], "footway" ]]}
]' | jq -c '.[]')


#####################
# shape - extrusion #
#####################
while read i; do
  export id="$(echo $i | jq -r -c '.id')"
  export color="$(echo $i | jq -r -c '.color')"
  export filter="$(echo $i | jq -r -c '.filter')"
  export extrusionBase="$(echo $i | jq -r -c '.extrusionBase')"
  export extrusionHeight="$(echo $i | jq -r -c '.extrusionHeight')"
  cat ./shape/extrusion.json | envsubst > /tmp/extrusion.json
  jq '.[. | length] |= . + '"$(cat /tmp/extrusion.json)" ./shape/shapeLayers.json > /tmp/shapeLayers.json \
    && mv -f /tmp/shapeLayers.json ./shape/shapeLayers.json
done <<< $(echo '[
    { "id": "shape-area-extrusion-indoor",
      "color": "#FF00F0",
      "filter": ["all",["has","indoor"],["has","level"],["==",["index-of",";",["get","level"]],-1],[">=",["to-number",["get","level"]],0]],
      "extrusionBase": ["*",'${DEFAULT_LEVEL_HEIGHT}',["to-number",["get","level"]]],
      "extrusionHeight": ["*",'${DEFAULT_LEVEL_HEIGHT}',["to-number",["get","level"]]]
    },
    { "id": "shape-area-extrusion-area",
      "color": "#FF0000",
      "filter": ["all",["==",["get","indoor"],"area"],["has","level"],["==",["index-of",";",["get","level"]],-1],[">=",["to-number",["get","level"]],0]],
      "extrusionBase": ["*",'${DEFAULT_LEVEL_HEIGHT}',["to-number",["get","level"]]],
      "extrusionHeight": ["*",'${DEFAULT_LEVEL_HEIGHT}',["to-number",["get","level"]]]
    },
    { "id": "shape-area-extrusion-room",
      "color": "#0000FF",
      "filter": ["all",["==",["get","indoor"],"room"],["has","level"],["==",["index-of",";",["get","level"]],-1],[">=",["to-number",["get","level"]],0]],
      "extrusionBase": ["+",1,["*",'${DEFAULT_LEVEL_HEIGHT}',["to-number",["get","level"]]]],
      "extrusionHeight": ["+",1,["*",'${DEFAULT_LEVEL_HEIGHT}',["to-number",["get","level"]]]]
    }
]' | jq -c '.[]')


# ############
# # Building #
# ############
# layer="building"
# type="extrusion"
# while read i; do
#   export id="$(echo $i | jq -r -c '.id')"
#   export color="$(echo $i | jq -r -c '.color')"
#   export width="$(echo $i | jq -r -c '.width')"
#   export filter="$(echo $i | jq -r -c '.filter')"
#   cat ./${layer}/${type}.json | envsubst > /tmp/${type}.json
#   jq '.[. | length] |= . + '"$(cat /tmp/${type}.json)" "./${layer}/${layer}Layers.json" > "/tmp/${layer}Layers.json" \
#     && mv -f "/tmp/${layer}Layers.json" "./${layer}/${layer}Layers.json"
# done <<< $(echo '[
#     {"id": "indoor-highway-line",      "color": "#ebbc00", "width": 5, "filter": [ "all", [ "has", "highway" ]]},
#     {"id": "indoor-footway-line",      "color": "#ff0000", "width": 5, "filter": [ "all", [ "has", "highway" ], [ "==", [ "get", "highway" ], "footway" ]]}
# ]' | jq -c '.[]')

#########
# shape #
#########
cat ./shape/shapeLayers.json | envsubst > /tmp/shapeLayers.json \
&& mv -f /tmp/shapeLayers.json ./shape/shapeLayers.json

############
# building #
############
cat ./building/buildingLayers.json | envsubst > /tmp/buildingLayers.json \
&& mv -f /tmp/buildingLayers.json ./building/buildingLayers.json

#############
# Merge all #
#############
sed -i 's/${country}/_COUNTRY_/g' ./openindoorStyle.json
cat ./openindoorStyle.json | envsubst > /tmp/openindoorStyle.json
sed 's/_COUNTRY_/${country}/g' /tmp/openindoorStyle.json > ./openindoorStyle.json

# indoor
while read i; do \
    jq '.layers[.layers | length] |= . + '"$i" ./openindoorStyle.json > /tmp/openindoorStyle.json \
    && mv -f /tmp/openindoorStyle.json ./openindoorStyle.json; \
done <<<$(cat ./indoor/indoorLayers.json | jq -c '.[]')
# shape
while read i; do \
    jq '.layers[.layers | length] |= . + '"$i" ./openindoorStyle.json > /tmp/openindoorStyle.json \
    && mv -f /tmp/openindoorStyle.json ./openindoorStyle.json; \
done <<<$(cat ./shape/shapeLayers.json | jq -c '.[]')
# building
while read i; do \
    jq '.layers[.layers | length] |= . + '"$i" ./openindoorStyle.json > /tmp/openindoorStyle.json \
    && mv -f /tmp/openindoorStyle.json ./openindoorStyle.json; \
done <<<$(cat ./building/buildingLayers.json | jq -c '.[]')

/usr/bin/tic

cd /etc/caddy
cat ./Caddyfile | envsubst > ./Caddyfile_tmp
cat ./Caddyfile_tmp
mv  ./Caddyfile_tmp              ./Caddyfile

crontab -l | { cat; echo "* * * * * /usr/bin/tic"; } | crontab -
echo "Start cron task" && crontab -l && /usr/sbin/crond -l 8
caddy run --watch --config /etc/caddy/Caddyfile
