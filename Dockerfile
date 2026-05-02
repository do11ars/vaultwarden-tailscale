FROM vaultwarden/server:latest-alpine
WORKDIR /render

RUN apk add --no-cache ca-certificates wget netcat-openbsd bash bind-tools socat

ARG TAILSCALE_VERSION
ENV TAILSCALE_VERSION=$TAILSCALE_VERSION

COPY run-tailscale.sh /render/
COPY install-tailscale.sh /tmp
RUN chmod +x /tmp/install-tailscale.sh && /tmp/install-tailscale.sh && rm -rf /tmp/*

CMD ["./run-tailscale.sh"]
