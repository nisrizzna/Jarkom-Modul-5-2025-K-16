#!/bin/bash
# CONFIG FINAL PALANTIR (PHP 8.4)

# MTU Fix (PENTING!)
ip link set dev eth0 mtu 1280

# Repo & Install PHP 8.4 (Sama kayak IronHills tapi extra hati-hati koneksinya)
apt-get install -y lsb-release ca-certificates apt-transport-https software-properties-common gnupg2 curl
curl -sSLo /usr/share/keyrings/deb.sury.org-php.gpg [https://packages.sury.org/php/apt.gpg](https://packages.sury.org/php/apt.gpg)
echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-php.gpg] [https://packages.sury.org/php/](https://packages.sury.org/php/) bullseye main" > /etc/apt/sources.list.d/php.list
apt-get update

apt-get install -y nginx php8.4 php8.4-fpm
service apache2 stop 2>/dev/null
SOCK_FILE="/run/php/php8.4-fpm.sock"

cat > /etc/nginx/sites-available/default <<EOF
server {
    listen 80 default_server;
    root /var/www/html;
    index index.php index.html;
    server_name _;
    location / { try_files \$uri \$uri/ =404; }
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:$SOCK_FILE;
    }
}
EOF

rm /var/www/html/index.nginx-debian.html 2>/dev/null
echo "<?php echo '<h1>Mata Palantir (PHP 8.4)</h1>IP: '.\$_SERVER['SERVER_ADDR']; ?>" > /var/www/html/index.php

service php8.4-fpm start
service nginx restart
echo "✅ Palantir Ready."
