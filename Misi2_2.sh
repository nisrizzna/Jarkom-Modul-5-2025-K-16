# Vilya
iptables -A INPUT -p icmp --icmp-type echo-request -j DROP

ping [IP_Client_Lain]
# Harus berhasil ping

#Client lain
ping [IP_Vilya]
# Harus gagal ping
