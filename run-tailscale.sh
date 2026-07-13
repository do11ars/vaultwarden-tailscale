#!/usr/bin/env bash

/render/tailscaled --tun=userspace-networking --socks5-server=localhost:1055 --outbound-http-proxy-listen=localhost:1055 &
PID=$!

until /render/tailscale up --authkey="${TAILSCALE_AUTHKEY}" --hostname="${RENDER_SERVICE_NAME}"; do
  sleep 0.1
done

tailscale_ip=$(/render/tailscale ip)
echo "Tailscale is up at IP ${tailscale_ip}"

cd /
ALL_PROXY=socks5://localhost:1055/ HTTP_PROXY=http://localhost:1055/ http_proxy=http://localhost:1055/ /vaultwarden &
VAULT_PID=$!

wait ${PID} ${VAULT_PID}
