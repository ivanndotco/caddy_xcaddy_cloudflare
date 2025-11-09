# Use CADDY_VERSION to specify a version like "2.8.4" or leave empty for latest
# Use CLOUDFLARE_VERSION to specify plugin version like "v0.2.2" or leave empty for latest
# Examples:
#   docker build --build-arg CADDY_VERSION=2.10.2 --build-arg CLOUDFLARE_VERSION=v0.2.2 .
#   docker build .  (uses latest versions)
ARG CADDY_VERSION=
ARG CLOUDFLARE_VERSION=

FROM caddy:${CADDY_VERSION:+${CADDY_VERSION}-}builder AS builder

RUN xcaddy build \
    --with github.com/caddy-dns/cloudflare${CLOUDFLARE_VERSION:+@$CLOUDFLARE_VERSION}

FROM caddy:${CADDY_VERSION:+${CADDY_VERSION}-}alpine

COPY --from=builder /usr/bin/caddy /usr/bin/caddy

CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
