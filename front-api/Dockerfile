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

RUN mkdir -p /front-api
WORKDIR /front-api

COPY ./Caddyfile /etc/caddy/Caddyfile
RUN mkdir -p /front-api/www
COPY ./index.html /front-api/www/index.html

COPY ./front-api.sh /usr/bin/front-api.sh
RUN chmod +x /usr/bin/front-api.sh

ENV DOMAIN_NAME api.openindoor.io
ENV DOMAIN_NAMES api.openindoor.io
ENV CERTIFICATE_AUTHORITY "https://acme-staging-v02.api.letsencrypt.org/directory"
CMD /usr/bin/front-api.sh
EXPOSE 80
