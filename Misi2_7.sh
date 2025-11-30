#Pastikan date sudah di set ke Sabtu, 30 Nov 2025 
date -s "2025-11-29 10:00:00"

#Pasang rule limit koneksi

# Batasi koneksi port 80 maksimal 3 per IP source
iptables -A INPUT -p tcp --dport 80 -m connlimit --connlimit-above 3 -j REJECT

#Stress test

# Kirim 10 request curl secara bersamaan
for i in {1..10}; do curl -s http://[IP_IRONHILLS] > /dev/null & done