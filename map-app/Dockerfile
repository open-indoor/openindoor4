################ OSM TO GEOJSON #####################
FROM caddy:2-alpine

RUN apk add --update-cache \
    jq \
    curl \
    bash \
    net-tools \
    grep \
    vim \
    gettext \
    util-linux \
    && rm -rf /var/cache/apk/*

RUN mkdir -p /map-app
WORKDIR /map-app

COPY ./Caddyfile /etc/caddy/Caddyfile
RUN mkdir -p /map-app/www
COPY ./index.html /map-app/www/index.html
COPY ./style.css /map-app/www/style.css
COPY ./favicon.ico /map-app/www/favicon.ico
# COPY ./style /map-app/www/style

COPY ./map-app.sh /usr/bin/map-app.sh
RUN chmod +x /usr/bin/map-app.sh

ENV APP_DOMAIN_NAME app.openindoor.io
ENV API_DOMAIN_NAME api.openindoor.io

CMD /usr/bin/map-app.sh
EXPOSE 80
