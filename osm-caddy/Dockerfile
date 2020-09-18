FROM caddy:2-alpine

COPY ./Caddyfile /etc/caddy/Caddyfile

CMD ["caddy", "run", "--watch", "--config", "/etc/caddy/Caddyfile"]

EXPOSE 80
