FROM varnish:6.2

RUN apt-get -qq update \
  && DEBIAN_FRONTEND=noninteractive \
  apt-get -y install --no-install-recommends \
    bash \
    curl \
    file \
    gettext \
    grep \
    net-tools \
    procps \
    unzip \
    util-linux \
    uuid-runtime \
    vim \
    wget \
  && apt-get clean

COPY default.vcl    /etc/varnish/
COPY run.sh         /run.sh

ENV VARNISH_TTL=2419200