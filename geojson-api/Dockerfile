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
ENV DOMAIN_NAME api.openindoor.io

ENTRYPOINT ["/geojson/geojson-api.sh"]


# CMD bash -c "(fcgiwrap -f -s tcp:127.0.0.1:8999)"

EXPOSE 80
EXPOSE 8999
