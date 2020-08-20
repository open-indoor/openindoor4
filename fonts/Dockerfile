FROM node:10 as fonts

WORKDIR /

ARG commit=master

ADD https://github.com/openmaptiles/fonts/archive/${commit}.tar.gz .
# COPY ./fonts-${commit}.tar.gz ./${commit}.tar.gz
RUN tar -zxvf ${commit}.tar.gz
RUN mv fonts-${commit} fonts
WORKDIR /fonts

RUN npm install
RUN node ./generate.js

##############################################
FROM caddy:2-alpine

RUN mkdir -p /fonts
COPY --from=fonts /fonts/_output/ /fonts/
COPY              ./Caddyfile     /etc/caddy/Caddyfile

CMD ["caddy", "run", "--watch", "--config", "/etc/caddy/Caddyfile"]

EXPOSE 80
