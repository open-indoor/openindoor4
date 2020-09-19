#!/bin/bash

echo "Content-type: application/json"
echo ""

# # echo "<html>"
# # echo "<head>"
# # echo "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\">"
# # echo "<title>Bash CGI script</title>"
# # echo "</head>"
# # echo "<body>"
# # echo "<p>Hello, Your IP address is \$REMOTE_ADDR</p>"
# # echo $PATH_INFO
# # echo "<pre>"
# # env
# # echo "</pre>"
# # echo "</body>"
# # echo "</html>"
echo '{
    "json": 13
}'
exit 0


geojsonFile="$(basename $PATH_INFO)"
geojsonFile="${geojsonFile%.*}.geojson"
osmFile="${geojsonFile%.*}.osm"
# osmApiUrl="https://api.openindoor.io/osm"
# osmApiUrl="http://osm-caddy"
osmApiUrl="http://api.openindoor.io/osm"
code=$(curl \
    -L \
    -o "/tmp/${osmFile}" \
    -s \
    -w "%{http_code}" \
    "${osmApiUrl}/${osmFile}")
if ! [ "x${code}" = "x200" ]; then
    echo "HTTP/1.1 404 Not Found"
    echo "Content-type: application/json"
    echo ""
    exit 0
fi
osmtogeojson "/tmp/${osmFile}" > "/tmp/$geojsonFile"; 
echo "Content-type: application/json"
echo ""
cat "/tmp/$geojsonFile"
exit 0

# $ curl http://localhost:8082/geojson/ArgentinaBuenosAiresFineArtsNationalMuseum.geojson
# SERVER_NAME=localhost
# REMOTE_HOST=172.17.0.1
# HOSTNAME=7ccd007f8168
# REMOTE_IDENT=
# XDG_DATA_HOME=/data
# SCRIPT_NAME=/geojson
# XDG_CONFIG_HOME=/config
# GATEWAY_INTERFACE=CGI/1.1
# SERVER_SOFTWARE=Caddy/v2.1.1
# PATH_INFO=/ArgentinaBuenosAiresFineArtsNationalMuseum.geojson
# DOCUMENT_ROOT=/geojson
# PWD=/geojson
# REQUEST_URI=/geojson/ArgentinaBuenosAiresFineArtsNationalMuseum.geojson
# PATH_TRANSLATED=/geojson/ArgentinaBuenosAiresFineArtsNationalMuseum.geojson
# FCGI_ROLE=RESPONDER
# REQUEST_SCHEME=http
# HOME=/root
# CADDY_VERSION=v2.1.1
# QUERY_STRING=
# DOCUMENT_URI=/geojson
# HTTP_X_FORWARDED_PROTO=http
# HTTP_ACCEPT=*/*
# REMOTE_PORT=39600
# AUTH_TYPE=
# HTTP_HOST=localhost:8082
# HTTP_X_FORWARDED_FOR=172.17.0.1
# HTTP_USER_AGENT=curl/7.64.0
# SHLVL=3
# CONTENT_LENGTH=0
# CADDY_DIST_COMMIT=80870b227ded910971ecace4a0c136bf0ef46342
# SERVER_PROTOCOL=HTTP/1.1
# SERVER_PORT=8082
# SCRIPT_FILENAME=/geojson/geojson
# REMOTE_ADDR=172.17.0.1
# aaa=bbb
# PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
# REMOTE_USER=
# CONTENT_TYPE=
# REQUEST_METHOD=GET
# _=/usr/bin/env



# # SCRIPT_NAME=/cgi-bin/osmtogeojson.sh
# # XDG_CONFIG_HOME=/config
# # GATEWAY_INTERFACE=CGI/1.1
# # SERVER_SOFTWARE=Caddy/v2.1.1
# # PATH_INFO=
# # DOCUMENT_ROOT=/geojson
# # PWD=/geojson/cgi-bin
# # REQUEST_URI=/cgi-bin/osmtogeojson.sh
# # FCGI_ROLE=RESPONDER
# # REQUEST_SCHEME=http
# # HOME=/root
# # CADDY_VERSION=v2.1.1
# # QUERY_STRING=
# # DOCUMENT_URI=/cgi-bin/osmtogeojson.sh


# # ddate=$(date -u +"%a, %d %b %Y %H:%M:%S GMT")
# # contentLength=$(stat -c%s push.sh)

# # read -r -d '' responseOK <<EOF
# # HTTP/1.1 200 OK
# # Date: $ddate
# # Server: CaddyServer 2 (GNU/Linux64)
# # Last-Modified: $ddate
# # Content-Length: 0
# # Content-Type: text/html
# # Connection: Closed
# # EOF

# # read -r -d '' responseKO <<'EOF'
# # HTTP/1.1 404 Not Found
# # Date: Sun, 18 Oct 2012 10:36:20 GMT
# # Server: Apache/2.2.14 (Win32)
# # Content-Length: 230
# # Connection: Closed
# # Content-Type: text/html; charset=iso-8859-1
# # EOF

# # # echo $@

# # echo $responseOK

# # geojsonRoute() {
# #   # Not a geojson query
# #   if ! (echo "$2" | grep -E ".*\.geojson$"); then
# #     echo "[ERROR] not a geojson file request"
# #     send "HTTP/1.0 400 ${HTTP_RESPONSE[400]}"
# #     exit 0
# #   fi
# #   osmFile="${2%.*}.osm"
# #   code=$(curl \
# #     -L \
# #     -o "/tmp/${osmFile}" \
# #     -s \
# #     -w "%{http_code}" \
# #     "http://api.openindoor.io/osm/${osmFile}")
# #   # File not found
# #   if ! [ "x${code}" = "x200" ]; then
# #     echo "[ERROR] osm original file not found"
# #     send "HTTP/1.0 $code ${HTTP_RESPONSE[$code]}"
# #     exit 0
# #   fi

# #   add_response_header "Content-Type" "application/json"
# #   osmtogeojson "/tmp/${osmFile}" > "/tmp/$2"; 
# #   result=$(cat "/tmp/$2")

# #   send_response_ok_exit <<< ${result}
  
# # }

# # on_uri_match '^/api/geojson/(.*)$' geojsonRoute
