#!/bin/bash

set -x
set -e
source /style/style.src

uuid=$(uuidgen)
while read i; do
  export country=$(echo $i | jq -r -c '.country | ascii_downcase | gsub("\\s+";"_")')
  sed 's/__country__/$country/g' /data/www/style/openindoorStyle.json | envsubst > "/data/www/style/openindoorStyle_${country}.json"
done <<<$(curl -k -f http://places-api/places/countries/ | jq -c '.[]')
