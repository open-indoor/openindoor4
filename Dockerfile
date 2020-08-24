#############  OSMTOGEOJSON BUILDER  ##############
FROM node:12 AS osmtogeojson_builder
WORKDIR /
RUN npm install osmtogeojson

##############  SPRITE BUILDER  ###################
FROM node:10 AS sprite_builder
COPY ./sprite/spritezero-cli /spritezero-cli
WORkDIR /spritezero-cli
RUN npm install @mapbox/spritezero
RUN npm install
COPY ./sprite/input /input
RUN mkdir -p /sprite-32
RUN ./bin/spritezero /sprite-32/sprite /input/32

# ##############  STYLE BUILDER  ###################
# FROM alpine:3.6 AS style_builder
# ARG WEB_SITE=https://map.openindoor.io
# RUN apk add --update libintl && apk add --virtual build_deps gettext
# COPY ./style /style

###########################################################
FROM caddy:2-alpine
RUN apk add --update libintl && apk add --virtual build_deps gettext
COPY --from=osmtogeojson_builder /node_modules/osmtogeojson/osmtogeojson.js /openindoor/dist/osmtogeojson.js
COPY --from=sprite_builder       /sprite-32/                                /openindoor/sprite/
COPY                             ./style                                    /openindoor/style/
COPY                             ./run.sh                                   /openindoor/run.sh

ENV WEB_SITE="https://map.openindoor.io"
ENV CADDYFILE="/etc/caddy/Caddyfiles/localhost_Caddyfile"
ENV OVERPASS_API="${WEB_SITE}/overpass/api"

CMD /openindoor/run.sh

EXPOSE 80
EXPOSE 443
