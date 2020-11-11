##############  SPRITE BUILDER  ###################
FROM node:10 AS sprite_builder

# RUN apt-get -y update \
#     && apt-get -y install \
#     librsvg2-bin \
#     libcairo2 \
#     inkscape \
#     libcanberra-gtk-module

COPY ./spritezero-cli /spritezero-cli
WORkDIR /spritezero-cli
RUN npm install @mapbox/spritezero
RUN npm install

COPY ./input /input



# RUN mkdir -p /sprite-32
# RUN ./bin/spritezero           /sprite-32/sprite    /input/32
# RUN ./bin/spritezero --retina  /sprite-32/sprite@2x /input/32

RUN mkdir -p /input/tmp
RUN cd /input/32; for f in $(find . -type f -name "*_32.svg"); do \
    mv -f ${f} ../tmp/${f%_32.svg}_64.svg; \
    done

# RUN mkdir -p /input/tmp
# WORKDIR /input/32 
# RUN for f in $(find . -type f -name "*_32.svg"); do \
#       mv -f ${f} ../tmp/${f%_32.svg}.svg; \
#     done
RUN mkdir -p /sprite-64
RUN /spritezero-cli/bin/spritezero --ratio=2 /sprite-64/sprite    /input/tmp
RUN sed -i 's/"pixelRatio": 2,/"pixelRatio": 1,/g' /sprite-64/sprite.json
RUN /spritezero-cli/bin/spritezero --ratio=4 /sprite-64/sprite@2x /input/tmp
RUN sed -i 's/"pixelRatio": 4,/"pixelRatio": 2,/g' /sprite-64/sprite@2x.json

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
RUN mkdir -p /tmp/www
# COPY --from=sprite_builder /sprite-32/ /sprite-app/www/
COPY --from=sprite_builder /sprite-64/ /tmp/www/
COPY --from=sprite_builder /input/ /input/

COPY ./sprite-app.sh /usr/bin/sprite-app.sh
RUN chmod +x /usr/bin/sprite-app.sh

ENV APP_DOMAIN_NAME app.openindoor.io

CMD /usr/bin/sprite-app.sh
EXPOSE 80