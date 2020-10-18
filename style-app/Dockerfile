##############################################
FROM caddy:2-alpine

RUN apk add --update-cache \
    bash \
    curl \
    file \
    gettext \
    grep \
    jq \
    net-tools \
    procps \
    util-linux \
    vim \
    wget \
    && rm -rf /var/cache/apk/*

RUN mkdir -p /style

COPY ./Caddyfile /etc/caddy/Caddyfile
COPY ./style/ /data/www/style/

COPY ./style-app.sh /usr/bin/style-app.sh
RUN chmod +x /usr/bin/style-app.sh

COPY ./actions.sh /usr/bin/actions.sh
RUN chmod +x /usr/bin/actions.sh
COPY ./tic.sh /usr/bin/tic
RUN chmod +x /usr/bin/tic

ENV API_DOMAIN_NAME api.openindoor.io
ENV APP_DOMAIN_NAME app.openindoor.io
ENV INDOOR_MIN_ZOOM 18
ENV BUILDING_MIN_ZOOM 15
ENV BUILDING_MAX_ZOOM 18

CMD /usr/bin/style-app.sh
EXPOSE 80