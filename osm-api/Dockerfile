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
COPY ./getOsmFiles.sh /usr/bin/getOsmFiles.sh
RUN chmod +x /usr/bin/getOsmFiles.sh
COPY ./osm-api.sh /usr/bin/osm-api.sh
RUN chmod +x /usr/bin/osm-api.sh

CMD /usr/bin/osm-api.sh

EXPOSE 80
