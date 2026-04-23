#!/usr/bin/env bash
set -e

# 1. Jalankan Tailscale daemon
/render/tailscaled --tun=userspace-networking --socks5-server=localhost:1055 &
TAILSCALED_PID=$!

# 2. Hubungkan Tailscale
ADVERTISE_ROUTES=${ADVERTISE_ROUTES:-10.0.0.0/8}
until /render/tailscale up --authkey="${TAILSCALE_AUTHKEY}" --hostname="${RENDER_SERVICE_NAME}" --advertise-routes="$ADVERTISE_ROUTES"; do
  sleep 0.5
done

echo "Tailscale is up."

# 3. Konfigurasi ProxyChains (Lokasi default Alpine: /etc/proxychains.conf)
mkdir -p /etc/proxychains
cat <<EOF > /etc/proxychains/proxychains.conf
strict_chain
proxy_dns 
remote_dns_subnet 224
tcp_read_time_out 15000
tcp_connect_time_out 8000
[ProxyList]
socks5  127.0.0.1 1055
EOF

# 4. Tes koneksi
echo "Mengetes koneksi ke Postgres..."
proxychains4 nc -zv 100.75.146.49 5432

# 5. JALANKAN VAULTWARDEN
echo "Starting Vaultwarden via ProxyChains..."
# Di image alpine, binary berada di /vaultwarden
cd /
proxychains4 /vaultwarden &
VAULT_PID=$!

wait -n ${TAILSCALED_PID} ${VAULT_PID}
