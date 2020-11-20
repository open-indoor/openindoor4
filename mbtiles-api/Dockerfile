################ geojson to mbtiles #####################
FROM caddy:2-alpine

RUN apk add --update-cache \
    bash \
    build-base \
    ca-certificates \
    coreutils \
    curl \
    fcgiwrap \
    file \
    gdal \
    gdal-tools \
    gettext \
    grep \
    jq \
    net-tools \
    procps \
    sqlite-dev \
    util-linux \
    vim \
    wget \
    zlib-dev \
    && rm -rf /var/cache/apk/*

# Install tippecanoe
ARG tippecanoeBranch=1.36.0
ADD https://github.com/mapbox/tippecanoe/archive/${tippecanoeBranch}.tar.gz /usr/local/src/tippecanoe-${tippecanoeBranch}.tar.gz
# copy ./tippecanoe-${tippecanoeBranch}.tar.gz /usr/local/src/tippecanoe-${tippecanoeBranch}.tar.gz
WORKDIR /usr/local/src/
RUN tar xvfz tippecanoe-${tippecanoeBranch}.tar.gz
WORKDIR /usr/local/src/tippecanoe-${tippecanoeBranch}
RUN make \
  && make install \
  && rm -rf /usr/local/src/tippecanoe-${tippecanoeBranch}

COPY ./Caddyfile /tmp/Caddyfile

RUN mkdir -p /mbtiles

WORKDIR /mbtiles

ENV API_DOMAIN_NAME api.openindoor.io

CMD ["/mbtiles/mbtiles-api.sh"]

COPY ./mbtiles-api.sh /mbtiles/mbtiles-api.sh
COPY ./mbtiles.sh /mbtiles/mbtiles
COPY ./action.sh /usr/bin/action
RUN  chmod +x /mbtiles/mbtiles-api.sh
COPY ./tic.sh /usr/bin/tic

EXPOSE 80