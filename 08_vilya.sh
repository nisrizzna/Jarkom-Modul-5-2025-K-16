#!/bin/bash
# CONFIG FINAL VILYA

apt-get install isc-dhcp-server -y
sed -i 's/INTERFACESv4=""/INTERFACESv4="eth0"/g' /etc/default/isc-dhcp-server

cat > /etc/dhcp/dhcpd.conf <<EOF
option domain-name "k16.com";
option domain-name-servers 192.219.2.139, 8.8.8.8;
default-lease-time 600;
max-lease-time 7200;
authoritative;

# Subnet Lokal
subnet 192.219.2.136 netmask 255.255.255.248 {}

# --- WILAYAH KANAN ---
# Subnet Elendil (Gateway: Minastir)
subnet 192.219.0.0 netmask 255.255.255.0 {
    range 192.219.0.10 192.219.0.250;
    option routers 192.219.0.3; 
    option broadcast-address 192.219.0.255;
}
# Subnet Gilgalad (Gateway: AnduinBanks)
subnet 192.219.1.0 netmask 255.255.255.128 {
    range 192.219.1.10 192.219.1.120;
    option routers 192.219.1.1; 
    option broadcast-address 192.219.1.127;
}

# --- WILAYAH KIRI ---
# Subnet Durin (Gateway: Wilderland)
subnet 192.219.2.0 netmask 255.255.255.128 {
    range 192.219.2.10 192.219.2.60;
    option routers 192.219.2.3;
    option subnet-mask 255.255.255.192; # WAJIB /26
    option broadcast-address 192.219.2.63;
}
EOF

# Fix Checksum & Restart
iptables -t mangle -A POSTROUTING -p udp --dport 68 -j CHECKSUM --checksum-fill 2>/dev/null
service isc-dhcp-server restart
echo "✅ Vilya Ready."
