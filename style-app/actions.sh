#!/bin/bash

set -x
set -e
source /style/style.src

uuid=$(uuidgen)
bboxesApiUrl="https://${API_DOMAIN_NAME}/bboxes"
while read i; do
  export country=$(echo $i | jq -r -c '.country' | tr '[:upper:]' '[:lower:]')
  cat /data/www/style/openindoorStyle.json | envsubst > "/data/www/style/openindoorStyle_${country}.json"
done <<<$(curl -k -f https://${API_DOMAIN_NAME}/bboxes/countries | jq -c '.[]')
