FROM debian-slim:latest
WORKDIR /render

ARG TAILSCALE_VERSION
ENV TAILSCALE_VERSION=$TAILSCALE_VERSION

RUN apt-get -qq update \
  && apt-get -qq install --upgrade -y --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    netcat-openbsd \
    wget \
    dnsutils \
    curl \
    libmariadb3 \
    libpq5 \
    openssl \
  > /dev/null \
  && apt-get -qq clean \
  && rm -rf \
    /var/lib/apt/lists/* \
    /tmp/* \
    /var/tmp/* \
  && :

RUN echo "+search +short" > /root/.digrc
COPY run-tailscale.sh /render/

COPY install-tailscale.sh /tmp
RUN chmod +x /render/run-tailscale.sh
RUN chmod +x /tmp/install-tailscale.sh
RUN /tmp/install-tailscale.sh && rm -r /tmp/*
COPY --from=ghcr.io/do11ars/vaultwarden:latest /vaultwarden /render/
COPY --from=ghcr.io/do11ars/vaultwarden:latest /web-vault/ /render/web-vault/

CMD ./run-tailscale.sh
