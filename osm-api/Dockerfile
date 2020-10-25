FROM caddy:2-alpine

RUN apk add --update-cache \
    bash \
    wget \
    procps \
    curl \
    vim \
    util-linux \
    jq \
    && rm -rf /var/cache/apk/*

COPY ./Caddyfile /etc/caddy/Caddyfile

WORKDIR /usr/bin
COPY ./osm.sh /usr/bin/osm.sh
RUN chmod +x /usr/bin/osm.sh
COPY ./osm-api.sh /usr/bin/osm-api.sh
RUN chmod +x /usr/bin/osm-api.sh

COPY ./bboxes.json /tmp/bboxes_default.json

CMD /usr/bin/osm-api.sh

EXPOSE 80
