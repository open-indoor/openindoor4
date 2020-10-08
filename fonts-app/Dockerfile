FROM node:10 as fonts

COPY . /fonts
WORKDIR /fonts

RUN npm install
RUN node ./generate.js

##############################################
FROM caddy:2-alpine

RUN apk add --update-cache \
    curl \
    wget \
    procps \
    bash \
    net-tools \
    grep \
    vim \
    gettext \
    util-linux \
    && rm -rf /var/cache/apk/*

# RUN mkdir -p /fonts
COPY --from=fonts /fonts/_output/ /data/www/fonts/
COPY ./Caddyfile     /etc/caddy/Caddyfile
COPY ./fonts-app.sh /usr/bin/fonts-app.sh
RUN chmod +x /usr/bin/fonts-app.sh
ENV APP_DOMAIN_NAME app.openindoor.io
CMD /usr/bin/fonts-app.sh
EXPOSE 80