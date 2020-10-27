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

ENV APÏ_DOMAIN_NAME api.openindoor.io
ENV APP_DOMAIN_NAME app.openindoor.io

COPY default.vcl    /etc/varnish/
COPY run.sh         /run.sh
RUN chmod +x        /run.sh

# CMD /run.sh

ENV VARNISH_TTL=2419200