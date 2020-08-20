FROM node:10 as fonts

COPY . /fonts
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
