##############  SPRITE BUILDER  ###################
FROM node:10 AS sprite_builder

COPY ./spritezero-cli /spritezero-cli
WORkDIR /spritezero-cli

RUN npm install @mapbox/spritezero
RUN npm install

COPY ./input /input

RUN mkdir -p /sprite-32
RUN ./bin/spritezero          /sprite-32/sprite    /input/32
RUN ./bin/spritezero --retina /sprite-32/sprite@2x /input/32

###########################################################
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

COPY ./Caddyfile /etc/caddy/Caddyfile
RUN mkdir -p /sprite-app/www
COPY --from=sprite_builder /sprite-32/ /sprite-app/www/

COPY ./sprite-app.sh /usr/bin/sprite-app.sh
RUN chmod +x /usr/bin/sprite-app.sh

ENV APP_DOMAIN_NAME app.openindoor.io

CMD /usr/bin/sprite-app.sh
EXPOSE 80