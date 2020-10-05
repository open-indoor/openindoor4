#!/bin/bash

# PATH_INFO=/mbtiles/country/list DOMAIN_NAME=api-ovh.openindoor.io /mbtiles-country/mbtiles-country

list="["
for mbtilesCountryFile in $(find /tmp/mbtiles-country -name "*.mbtiles"); do
  list="${list}{"
  list="${list}\"country\":"
  list="${list}\"$(basename ${mbtilesCountryFile%.*})\","
  cksumFile="${mbtilesCountryFile%.*}.cksum"
  list="${list}\"cksum\":$(cat ${cksumFile}),"
  list="${list}\"status\":\"ready\""
  list="${list}},"
done
list=$(echo -n "$list" | sed 's/,$//')
list="${list}]"
echo "Content-type: application/json"
echo ""
echo "${list}"
exit 0
;;
