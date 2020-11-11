################ geojson to mbtiles #####################
FROM caddy:2-alpine

RUN apk add --update-cache \
    gdal \
    gdal-tools \
    curl \
    bash \
    net-tools \
    fcgiwrap \
    grep \
    vim \
    gettext \
    util-linux \
    file \
    && rm -rf /var/cache/apk/*

COPY ./Caddyfile /etc/caddy/Caddyfile

RUN mkdir -p /mbtiles

WORKDIR /mbtiles

ENV SCRIPT_FILENAME /mbtiles/mbtiles
ENV API_DOMAIN_NAME api.openindoor.io

CMD ["/mbtiles/mbtiles-api.sh"]

COPY ./mbtiles-api.sh /mbtiles/mbtiles-api.sh
COPY ./mbtiles.sh /mbtiles/mbtiles
COPY ./actions.sh /usr/bin/actions.sh
RUN  chmod +x /mbtiles/mbtiles-api.sh
COPY ./tic.sh /usr/bin/tic

EXPOSE 80
