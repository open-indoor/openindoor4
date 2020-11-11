#!/bin/bash

set -x
set -e
source /style/style.src

uuid=$(uuidgen)
bboxesApiUrl="${API_URL}/bboxes"
while read i; do
  export country=$(echo $i | jq -r -c '.country | ascii_downcase | gsub("\\s+";"_")')
  cat /data/www/style/openindoorStyle.json | envsubst > "/data/www/style/openindoorStyle_${country}.json"
done <<<$(curl -k -f https://${API_DOMAIN_NAME}/places/countries/ | jq -c '.[]')
