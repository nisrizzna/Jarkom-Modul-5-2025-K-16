#!/bin/bash
# CONFIG FINAL MORIA

# 1. Kernel Tuning (Proxy ARP Wajib)
echo 0 > /proc/sys/net/ipv4/conf/all/rp_filter
for i in /proc/sys/net/ipv4/conf/*/rp_filter; do echo 0 > $i; done
sysctl -w net.ipv4.ip_forward=1
echo 1 > /proc/sys/net/ipv4/conf/all/proxy_arp
for i in /proc/sys/net/ipv4/conf/*/proxy_arp; do echo 1 > $i; done

# 2. Routing Exception (CRITICAL)
# Paksa paket Osgiliath (2.1) lewat atas, jangan ke bawah (Wilderland)
ip route add 192.219.2.1/32 dev eth0 2>/dev/null

# Route ke anak-anak (Wilderland)
ip route add 192.219.2.0/26 via 192.219.2.74 2>/dev/null
ip route add 192.219.2.64/29 via 192.219.2.74 2>/dev/null

echo "✅ Moria Ready."
