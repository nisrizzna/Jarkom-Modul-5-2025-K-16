#jebakan port scan

# Buat Chain baru biar rapi (opsional, tapi disarankan)
iptables -N PORTSCAN

# Arahkan paket TCP NEW (koneksi baru) ke chain PORTSCAN
# Kecuali port 80 (Web) & 22 (SSH) yang memang legal dibuka
iptables -A INPUT -p tcp --syn --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --syn -j PORTSCAN

# --- DI DALAM CHAIN PORTSCAN ---

# 1. Tandai penyerang yang melebihi batas (15 hit dalam 20 detik)
iptables -A PORTSCAN -m recent --set --name SCANNER
iptables -A PORTSCAN -m recent --update --seconds 20 --hitcount 15 --name SCANNER -j LOG --log-prefix "PORT_SCAN_DETECTED: "

# 2. Blokir penyerang tersebut
iptables -A PORTSCAN -m recent --update --seconds 20 --hitcount 15 --name SCANNER -j DROP

# 3. Kalau belum sampai batas limit, kembalikan ke pengecekan normal (atau reject pelan-pelan)
iptables -A PORTSCAN -j RETURN

#Menguji port scan

# Scan port 1 sampai 100 di Palantir
nmap -p 1-100 [IP_PALANTIR]

# Cek log di Palantir
dmesg | tail