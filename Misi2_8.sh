#Pasang rule sihir

# "Setiap paket keluar (OUTPUT) yang tujuannya ke KHAMUL,
# Ganti tujuannya (DNAT) menjadi ke IRONHILLS"

iptables -t nat -A OUTPUT -d [IP_KHAMUL] -j DNAT --to-destination [IP_IRONHILLS]

#Connect ke ip khamul port 80 dari vilya

nc -v [IP_KHAMUL] 80

#IronHills (limit)

iptables -A INPUT -p tcp --dport 80 -m connlimit --connlimit-above 3 -j REJECT

#Vilya (redirect)

iptables -t nat -A OUTPUT -d [IP_KHAMUL] -j DNAT --to-destination [IP_IRONHILLS]