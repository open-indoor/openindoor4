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

RUN mkdir -p /front-app
WORKDIR /front-app

COPY ./Caddyfile /etc/caddy/Caddyfile
RUN mkdir -p /front-app/www
COPY ./index.html /front-app/www/index.html

COPY ./front-app.sh /usr/bin/front-app.sh
RUN chmod +x /usr/bin/front-app.sh

ENV DOMAIN_NAME app.openindoor.io
ENV DOMAIN_NAMES app.openindoor.io
ENV CERTIFICATE_AUTHORITY "https://acme-staging-v02.api.letsencrypt.org/directory"
CMD /usr/bin/front-app.sh
EXPOSE 80
