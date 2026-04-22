#!/usr/bin/env bash

# 1. Jalankan Tailscale daemon
/render/tailscaled --tun=userspace-networking --socks5-server=localhost:1055 &
TAILSCALED_PID=$!

# 2. Tunggu dan hubungkan Tailscale
ADVERTISE_ROUTES=${ADVERTISE_ROUTES:-10.0.0.0/8}
until /render/tailscale up --authkey="${TAILSCALE_AUTHKEY}" --hostname="${RENDER_SERVICE_NAME}" --advertise-routes="$ADVERTISE_ROUTES"; do
  sleep 0.5
done

tailscale_ip=$(/render/tailscale ip -4)
echo "Tailscale is up at IP ${tailscale_ip}"

# 3. JALANKAN VAULTWARDEN
# Di image asli vaultwarden, script utamanya ada di /start.sh
echo "Starting Vaultwarden..."
cd /
/vaultwarden &
VAULT_PID=$!

# Tunggu salah satu proses mati (biasanya tailscaled atau vaultwarden)
wait -n ${TAILSCALED_PID} ${VAULT_PID}
