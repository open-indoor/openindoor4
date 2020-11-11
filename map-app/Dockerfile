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

COPY ./Caddyfile /tmp/Caddyfile
RUN mkdir -p /map-app/www
COPY ./www/ /map-app/www/
COPY ./style.css /map-app/www/style.css
COPY ./img/favicon.ico /map-app/www/favicon.ico
COPY ./img/custom_marker.png /map-app/www/custom_marker.png
# COPY ./style /map-app/www/style

COPY ./map-app.sh /usr/bin/map-app.sh
RUN chmod +x /usr/bin/map-app.sh

ENV APP_DOMAIN_NAME app.openindoor.io
ENV API_DOMAIN_NAME api.openindoor.io

CMD /usr/bin/map-app.sh
EXPOSE 80
