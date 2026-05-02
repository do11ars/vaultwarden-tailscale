#!/usr/bin/env bash
set -e

/render/tailscaled --tun=userspace-networking --socks5-server=localhost:1055 &
TAILSCALED_PID=$!

until /render/tailscale up --authkey="${TAILSCALE_AUTHKEY}" --hostname="${RENDER_SERVICE_NAME}"; do
  sleep 0.5
done
echo "Tailscale is up."

socat TCP4-LISTEN:5432,fork,reuseaddr SOCKS5:127.0.0.1:1055:100.75.146.49:5432 &
SOCAT_PID=$!

cd /
/vaultwarden &
VAULT_PID=$!

wait -n ${TAILSCALED_PID} ${SOCAT_PID} ${VAULT_PID}
