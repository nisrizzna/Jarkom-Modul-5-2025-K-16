#!/bin/bash
# CONFIG FINAL RIVENDELL (ROUTER BAWAH)
# Catatan: Pastikan IP Address sudah disetting di /etc/network/interfaces

echo "=== [1/3] Persiapan Awal ==="
# Pancingan DNS sementara agar bisa apt update (jika perlu install paket di masa depan)
echo "nameserver 8.8.8.8" > /etc/resolv.conf
apt-get update

echo "=== [2/3] Kernel Tuning (Router Optimization) ==="
# 1. Matikan rp_filter (Reverse Path Filter)
# Ini WAJIB dimatikan di topologi VLSM agar paket tidak dibuang kernel karena dianggap spoofing
echo 0 > /proc/sys/net/ipv4/conf/all/rp_filter
for i in /proc/sys/net/ipv4/conf/*/rp_filter; do echo 0 > $i; done

# 2. Aktifkan IP Forwarding
sysctl -w net.ipv4.ip_forward=1
# Simpan permanen (jaga-jaga)
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf

echo "=== [3/3] Routing & Firewall ==="
# 1. Pastikan Default Gateway ke Osgiliath (192.219.2.129)
# Cek apakah gateway sudah benar, jika salah/belum ada, tambahkan.
ip route add default via 192.219.2.129 2>/dev/null || ip route replace default via 192.219.2.129

# 2. Reset Firewall
# Hapus semua aturan blokir sisa agar routing lancar
iptables -F
iptables -X
iptables -t nat -F
iptables -t mangle -F
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT

echo "✅ Rivendell Ready."
