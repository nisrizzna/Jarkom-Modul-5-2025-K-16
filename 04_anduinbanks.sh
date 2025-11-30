#!/bin/bash
# CONFIG FINAL ANDUINBANKS

# 1. Kernel Tuning
echo 0 > /proc/sys/net/ipv4/conf/all/rp_filter
for i in /proc/sys/net/ipv4/conf/*/rp_filter; do echo 0 > $i; done
sysctl -w net.ipv4.ip_forward=1

# 2. DHCP Relay
apt-get install isc-dhcp-relay -y
cat > /etc/default/isc-dhcp-relay <<EOF
SERVERS="192.219.2.138"
INTERFACES="eth0 eth1"
OPTIONS=""
EOF

iptables -F
service isc-dhcp-relay restart
echo "✅ AnduinBanks Ready."
