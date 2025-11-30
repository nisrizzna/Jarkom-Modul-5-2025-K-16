#!/bin/bash
# CONFIG FINAL PELARGIR

# 1. Kernel Tuning
echo 0 > /proc/sys/net/ipv4/conf/all/rp_filter
for i in /proc/sys/net/ipv4/conf/*/rp_filter; do echo 0 > $i; done
sysctl -w net.ipv4.ip_forward=1

# 2. Routing Manual
# Route ke Bawah (Gilgalad)
ip route add 192.219.1.0/25 via 192.219.1.138 2>/dev/null

# BLACKHOLE (Anti Loop dengan Minastir)
ip route add blackhole 192.219.1.0/24 2>/dev/null

# 3. MTU Tuning (Penting buat Palantir)
ip link set dev eth0 mtu 1400
ip link set dev eth1 mtu 1400
ip link set dev eth2 mtu 1400

echo "✅ Pelargir Ready."
