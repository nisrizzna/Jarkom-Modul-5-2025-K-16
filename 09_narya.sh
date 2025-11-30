#!/bin/bash
# CONFIG FINAL NARYA

apt-get install bind9 -y

cat > /etc/bind/named.conf.options <<EOF
options {
        directory "/var/cache/bind";
        forwarders { 8.8.8.8; };
        allow-query { any; };
        dnssec-validation no; # FIX SERVFAIL
        listen-on-v6 { any; };
};
EOF

cat >> /etc/bind/named.conf.local <<EOF
zone "k16.com" {
    type master;
    file "/etc/bind/jarkom/k16.com";
};
EOF

mkdir -p /etc/bind/jarkom
cat > /etc/bind/jarkom/k16.com <<EOF
\$TTL 604800
@ IN SOA k16.com. root.k16.com. ( 2 604800 86400 2419200 604800 )
@ IN NS k16.com.
@ IN A 192.219.2.82    ; IronHills
www IN CNAME k16.com.  ; www -> IronHills
ns1 IN A 192.219.2.139
vilya IN A 192.219.2.138
EOF

service bind9 restart
echo "✅ Narya Ready."
