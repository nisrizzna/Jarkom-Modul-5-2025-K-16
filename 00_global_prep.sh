#!/bin/bash
# GLOBAL PREP (Anti-Lag & Speed Up)

echo "[GLOBAL] 1. Mematikan IPv6..."
sysctl -w net.ipv6.conf.all.disable_ipv6=1
sysctl -w net.ipv6.conf.default.disable_ipv6=1
sysctl -w net.ipv6.conf.lo.disable_ipv6=1
echo 'Acquire::ForceIPv4 "true";' > /etc/apt/apt.conf.d/99force-ipv4

echo "[GLOBAL] 2. Set DNS Google..."
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "options single-request-reopen" >> /etc/resolv.conf

echo "[GLOBAL] 3. Ganti Repo ke Kartolo (HTTP)..."
mv /etc/apt/sources.list /etc/apt/sources.list.bak 2>/dev/null
cat > /etc/apt/sources.list <<EOF
deb http://kartolo.sby.datautama.net.id/debian/ bullseye main contrib non-free
deb http://kartolo.sby.datautama.net.id/debian/ bullseye-updates main contrib non-free
deb http://kartolo.sby.datautama.net.id/debian-security/ bullseye-security main contrib non-free
EOF

echo "[GLOBAL] 4. Update Cache..."
apt-get update -o Acquire::http::Timeout="10"
