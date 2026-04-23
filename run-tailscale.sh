#!/usr/bin/env bash
set -e

# 1. Jalankan Tailscale
/render/tailscaled --tun=userspace-networking --socks5-server=localhost:1055 &
TAILSCALED_PID=$!

# 2. Hubungkan Tailscale
until /render/tailscale up --authkey="${TAILSCALE_AUTHKEY}" --hostname="${RENDER_SERVICE_NAME}"; do
  sleep 0.5
done
echo "Tailscale is up."

# 3. BRIDGE PORT DATABASE (Tanpa ProxyChains/Gost)
# Socat akan mendengarkan di port 5432 dan meneruskannya ke Tailscale SOCKS5
socat TCP4-LISTEN:5432,fork,reuseaddr SOCKS4A:127.0.0.1:100.75.146.49:5432,socksport=1055 &
SOCAT_PID=$!

echo "Bridge database aktif di localhost:5432 via Socat"

# 4. Jalankan Vaultwarden secara normal
# PENTING: DATABASE_URL di Render harus: postgresql://user:pass@127.0.0.1:5432/dbname
export ROCKET_ADDRESS=0.0.0.0
cd /
/vaultwarden &
VAULT_PID=$!

wait -n ${TAILSCALED_PID} ${SOCAT_PID} ${VAULT_PID}
