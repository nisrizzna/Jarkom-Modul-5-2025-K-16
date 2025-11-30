#Rule Palantir

# 1. Izinkan koneksi yang sudah established (Wajib)
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# 2. Rule untuk FAKSI ELF (07.00 - 15.00)
# Ganti IP sesuai subnet Elf kamu
iptables -A INPUT -p tcp --dport 80 -s 192.219.1.0/25 -m time --timestart 07:00 --timestop 15:00 -j ACCEPT

# 3. Rule untuk FAKSI MANUSIA (17.00 - 23.00)
# Ganti IP sesuai subnet Manusia kamu
iptables -A INPUT -p tcp --dport 80 -s 192.219.0.0/24 -m time --timestart 17:00 --timestop 23:00 -j ACCEPT

# 4. Blokir sisa akses Web selain jam di atas
iptables -A INPUT -p tcp --dport 80 -j DROP

#Simulasi Jam 10:00

# Di Palantir: Set jam ke 10:00
date -s "10:00:00"

#Simulasi jam 19:00

# Di Palantir: Set jam ke 19:00
date -s "19:00:00"

