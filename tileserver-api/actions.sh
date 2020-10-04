#!/bin/bash

set -x
set -e
source /tileserver/tileserver.src

uuid=$(uuidgen)
mkdir -p /tmp/mbtiles-country
bboxesApiUrl="https://${DOMAIN_NAME}/bboxes"
mbtilesCountryApiUrl="https://${DOMAIN_NAME}/mbtiles/country"

################################
# Get mbtiles and publish them #
################################

# Get countries
countries=$(curl -k -L  "${mbtilesCountryApiUrl}/list")

# If data locally missing or data not update from remote, check if can be remotely retrieve
while read i; do
  country=$(echo $i | jq -r -c '.country')
  cksum=$(echo $i | jq -r -c '.cksum')
done <<<$(echo "${countries}" | jq -c '.[]')
# If data not available remotely, trigger an update

# If data available, publish them