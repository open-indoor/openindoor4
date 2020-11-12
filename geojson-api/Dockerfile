################ OSM TO GEOJSON #####################
FROM debian:testing

RUN apt-get -qq update \
  && DEBIAN_FRONTEND=noninteractive \
  apt-get -y install --no-install-recommends \
    ca-certificates \
  && apt-get clean


RUN echo "deb [trusted=yes] https://apt.fury.io/caddy/ /" \
    | tee -a /etc/apt/sources.list.d/caddy-fury.list
RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y update \
    && apt-get -y install \
      --no-install-recommends \
      bash \
      caddy \
      cron \
      curl \
      fcgiwrap \
      file \
      gettext \
      grep \
      jq \
      less \
      net-tools \
      npm nodejs \
      procps \
      python3-geopandas \
      python3-pycurl \
      python3-pip \
      unzip \
      util-linux \
      uuid-runtime \
      vim \
      wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# RUN apt-get -qq update \
#   && DEBIAN_FRONTEND=noninteractive \
#   apt-get -y install --no-install-recommends \
#     pygeos \
#   && apt-get clean

# RUN apk add --update-cache \
#     nodejs npm  \
#     jq \
#     curl \
#     bash \
#     net-tools \
#     fcgiwrap \
#     grep \
#     vim \
#     gettext \
#     util-linux \
#     gdal gdal-dev \
#     python3 py3-pip py3-gdal geos geos-dev py3-wheel py3-scipy curl-dev gcc musl-dev \
#     musl-dev py3-numpy py3-shapely proj proj-dev proj-util \
#     && rm -rf /var/cache/apk/*

# RUN apk add --update-cache \
#     py3-numpy-dev

RUN npm install -g osmtogeojson

COPY ./requirements.txt /geojson/
RUN pip3 install -v -r /geojson/requirements.txt

COPY ./Caddyfile /tmp/Caddyfile_template

COPY ./geojson-api.sh /geojson/geojson-api.sh
RUN chmod +x /geojson/geojson-api.sh

WORKDIR /geojson

ENV SCRIPT_FILENAME /geojson/geojson

CMD bash -c "/geojson/geojson-api.sh"

# CMD bash -c "(caddy run --watch --config /etc/caddy/Caddyfile & fcgiwrap -f -s tcp:127.0.0.1:8999)"
# CMD bash -c "(fcgiwrap -f -s tcp:127.0.0.1:8999)"

EXPOSE 80

RUN mkdir -p /geojson
COPY ./geojson.py /geojson/geojson
RUN chmod +x /geojson/geojson

