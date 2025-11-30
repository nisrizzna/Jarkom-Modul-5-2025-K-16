#Narya

# 1. Izinkan Vilya akses UDP port 53
iptables -A INPUT -s {IP_Vilya} -p udp --dport 53 -j ACCEPT

# 2. Izinkan Vilya akses TCP port 53 (DNS kadang pakai TCP untuk zone transfer/paket besar)
iptables -A INPUT -s {IP_Vilya} -p tcp --dport 53 -j ACCEPT

# 3. Blokir akses port 53 dari SEMUA sumber lain
iptables -A INPUT -p udp --dport 53 -j DROP
iptables -A INPUT -p tcp --dport 53 -j DROP