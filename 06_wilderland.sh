#!/bin/bash
# CONFIG FINAL WILDERLAND

# 1. Kernel Tuning
sysctl -w net.ipv4.ip_forward=1

# 2. Routing Exception (CRITICAL)
# Agar ping ke Osgiliath & Moria tidak mental ke bawah
GW_MORIA="192.219.2.73"
ip route add 192.219.2.1/32 via $GW_MORIA 2>/dev/null
ip route add 192.219.2.2/32 via $GW_MORIA 2>/dev/null

# 3. DHCP Relay
apt-get install isc-dhcp-relay -y
cat > /etc/default/isc-dhcp-relay <<EOF
SERVERS="192.219.2.138"
INTERFACES="eth0 eth1 eth2"
OPTIONS=""
EOF

iptables -F
service isc-dhcp-relay restart
echo "✅ Wilderland Ready."
