#IronHills

# Set tanggal ke Rabu, 26 Nov 2025
date -s "2025-11-26 10:00:00"

# Cek tanggal (Pastikan outputnya Wed)
date

#Izinkan akses Port 80 (Web) hanya untuk IP Subnet Pasukan (Durin, Khamul, Elendil, Isildur) DAN hanya pada hari Sabtu/Minggu.

# 1. Izinkan koneksi yang sudah nyambung (biar gak putus)
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# 2. Rule untuk Faksi KURCACI (Durin & Khamul) - HANYA SABTU MINGGU
# Subnet Durin (192.219.2.0/26) & Khamul (192.219.2.64/29)
iptables -A INPUT -p tcp --dport 80 -s 192.219.2.0/26 -m time --weekdays Sat,Sun -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -s 192.219.2.64/29 -m time --weekdays Sat,Sun -j ACCEPT

# 3. Rule untuk Faksi MANUSIA (Elendil & Isildur) - HANYA SABTU MINGGU
# Subnet Minastir Supernet (192.219.0.0/23)
iptables -A INPUT -p tcp --dport 80 -s 192.219.0.0/23 -m time --weekdays Sat,Sun -j ACCEPT

# 4. Blokir sisa akses Web (Port 80) selain yang diizinkan di atas
iptables -A INPUT -p tcp --dport 80 -j DROP


#Skenario Gagal
curl http://[IP_IRONHILLS]
# Atau telnet kalau gak ada curl
telnet [IP_IRONHILLS] 80

#Skenario Berhasil (Sabtu/Minggu)
# Set tanggal ke Sabtu, 30 Nov 2025
date -s "2025-11-29 10:00:00"
#Akses dari Durin
curl http://[IP_IRONHILLS]
