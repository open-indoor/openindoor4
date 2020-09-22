################ geojson to mbtiles #####################
FROM caddy:2-alpine

RUN apk add --update \
    gdal \
    curl \
    bash \
    net-tools \
    fcgiwrap \
    grep \
    vim

COPY ./Caddyfile /etc/caddy/Caddyfile

RUN mkdir -p /mbtiles
COPY ./mbtiles.sh /mbtiles/mbtiles
RUN chmod +x /mbtiles/mbtiles

WORKDIR /mbtiles

ENV SCRIPT_FILENAME /mbtiles/mbtiles

CMD bash -c "(caddy run --watch --config /etc/caddy/Caddyfile & fcgiwrap -f -s tcp:127.0.0.1:8999)"
# CMD bash -c "(fcgiwrap -f -s tcp:127.0.0.1:8999)"

EXPOSE 80
EXPOSE 8999
