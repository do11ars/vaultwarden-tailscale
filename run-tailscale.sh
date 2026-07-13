#!/usr/bin/env bash

/render/tailscaled --tun=userspace-networking --socks5-server=localhost:1055 --disable-peer-api &
PID=$!

until /render/tailscale up --authkey="${TAILSCALE_AUTHKEY}" --hostname="${RENDER_SERVICE_NAME}"; do
  sleep 0.1
done
export ALL_PROXY=socks5://localhost:1055/
tailscale_ip=$(/render/tailscale ip)
echo "Tailscale is up at IP ${tailscale_ip}"

cd /
/vaultwarden &
VAULT_PID=$!

wait ${PID} ${VAULT_PID}
