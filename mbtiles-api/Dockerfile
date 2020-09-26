################ geojson to mbtiles #####################
FROM caddy:2-alpine

RUN apk add --update \
    gdal \
    gdal-tools \
    curl \
    bash \
    net-tools \
    fcgiwrap \
    grep \
    vim \
    gettext

COPY ./Caddyfile /etc/caddy/Caddyfile

RUN mkdir -p /mbtiles
COPY ./mbtiles.sh /mbtiles/mbtiles
RUN chmod +x /mbtiles/mbtiles

COPY ./mbtiles-api.sh /mbtiles/mbtiles-api.sh
RUN chmod +x /mbtiles/mbtiles-api.sh

WORKDIR /mbtiles

ENV SCRIPT_FILENAME /mbtiles/mbtiles
ENV DOMAIN_NAME api.openindoor.io

CMD /mbtiles/mbtiles-api.sh
# CMD bash -c "(fcgiwrap -f -s tcp:127.0.0.1:8999)"

EXPOSE 80
EXPOSE 8999
