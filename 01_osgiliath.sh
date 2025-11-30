#!/bin/bash
# CONFIG FINAL OSGILIATH

# 1. Kernel Tuning
echo 0 > /proc/sys/net/ipv4/conf/all/rp_filter
for i in /proc/sys/net/ipv4/conf/*/rp_filter; do echo 0 > $i; done
sysctl -w net.ipv4.ip_forward=1

# 2. Routing Manual (PENTING)
# Route ke Server Farm (Vilya/Narya)
ip route add 192.219.2.136/29 via 192.219.2.130 2>/dev/null

# Fix Routing ke Wilayah Minastir (Blok 0.x dan 1.x)
# Paksa lewat Minastir agar tidak ARP di lokal
ip route add 192.219.0.0/24 via 192.219.0.2 2>/dev/null
ip route add 192.219.1.0/24 via 192.219.0.2 2>/dev/null

# Fix Routing ke Wilayah Moria (Durin/Khamul)
# Paksa lewat Moria agar tidak ARP di lokal
ip route add 192.219.2.0/26 via 192.219.2.2 2>/dev/null
ip route add 192.219.2.64/29 via 192.219.2.2 2>/dev/null

# 3. IPTABLES (SNAT & MSS Clamping)
# Ganti IP ini jika IP public berubah!
IP_NAT="192.168.122.206" 

iptables -t nat -F
iptables -t mangle -F

# MSS Clamping (Obat Connection Timed Out)
iptables -t mangle -A POSTROUTING -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu

# Rule SNAT
iptables -t nat -A POSTROUTING -s 192.219.0.0/23 -o eth0 -j SNAT --to-source $IP_NAT
iptables -t nat -A POSTROUTING -s 192.219.2.0/25 -o eth0 -j SNAT --to-source $IP_NAT
iptables -t nat -A POSTROUTING -s 192.219.2.128/25 -o eth0 -j SNAT --to-source $IP_NAT

echo "✅ Osgiliath Ready."
