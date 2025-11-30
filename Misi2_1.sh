# Osgiliath
iptables -t nat -A POSTROUTING -o eth0 -j SNAT --to-source [IP_Interface_Keluar]

ping 8.8.8.8