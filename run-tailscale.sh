#!/usr/bin/env bash

/render/tailscaled --tun=userspace-networking --socks5-server=localhost:1055 &
PID=$!

until /render/tailscale up --authkey="${TAILSCALE_AUTHKEY}" --hostname="${RENDER_SERVICE_NAME}"; do
  sleep 0.1
done

tailscale_ip=$(/render/tailscale ip)
echo "Tailscale is up at IP ${tailscale_ip}"

while true; do
  socat TCP4-LISTEN:5432,fork,reuseaddr SOCKS5:127.0.0.1:1055:100.66.66.66:5432
  sleep 1
done &

cd /
/vaultwarden &
VAULT_PID=$!

wait ${PID} ${VAULT_PID}
