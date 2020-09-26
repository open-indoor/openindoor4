################ OSM TO GEOJSON #####################
FROM caddy:2-alpine

RUN apk add --update \
    nodejs \
    npm \
    jq \
    curl \
    bash \
    net-tools \
    fcgiwrap \
    grep \
    vim \
    gettext
RUN npm install -g osmtogeojson

COPY ./Caddyfile /etc/caddy/Caddyfile

RUN mkdir -p /geojson
COPY ./geojson.sh /geojson/geojson
RUN chmod +x /geojson/geojson

COPY ./geojson-api.sh /geojson/geojson-api.sh
RUN chmod +x /geojson/geojson-api.sh

WORKDIR /geojson

ENV SCRIPT_FILENAME /geojson/geojson

CMD bash -c "/geojson/geojson-api.sh"

# CMD bash -c "(caddy run --watch --config /etc/caddy/Caddyfile & fcgiwrap -f -s tcp:127.0.0.1:8999)"
# CMD bash -c "(fcgiwrap -f -s tcp:127.0.0.1:8999)"

EXPOSE 80
EXPOSE 8999
