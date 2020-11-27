FROM caddy:2-alpine

RUN apk add --update-cache \
    bash \
    build-base \
    ca-certificates \
    coreutils \
    curl \
    fcgiwrap \
    file \
    gettext \
    grep \
    htop \
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

# setup
COPY ./Caddyfile /tmp/Caddyfile

RUN mkdir -p /mbtiles-country

WORKDIR /mbtiles-country

# ENV SCRIPT_FILENAME /mbtiles-country/mbtiles-country
ENV APÏ_DOMAIN_NAME api.openindoor.io

CMD ["/mbtiles-country/mbtiles-country-api.sh"]

EXPOSE 80

COPY ./mbtiles-country-api.sh /mbtiles-country/mbtiles-country-api.sh
RUN chmod +x /mbtiles-country/mbtiles-country-api.sh
COPY ./mbtiles-country.sh /mbtiles-country/mbtiles-country
COPY ./action.sh /usr/bin/action
COPY ./tic.sh /usr/bin/tic
