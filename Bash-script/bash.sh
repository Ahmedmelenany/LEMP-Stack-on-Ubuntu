#!/bin/bash
# Author: [Ahmed Elenany]

sudo -i
apt update && apt upgrade -y

apt-get install -y nginx mysql-server php-fpm php-mysql
systemctl enable --now nginx.service
systemctl enable --now mysql.service
systemctl enable --now php8.1-fpm.service

echo "All services started and enabled"

echo "<?php phpinfo(); ?>" | tee /var/www/html/info.php > /dev/null

NGINX_CONFIG="
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    root /var/www/html;
    index index.php index.html index.htm index.nginx-debian.html;

    server_name _;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location ~ \\.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\\.ht {
        deny all;
    }
}
"
echo "$NGINX_CONFIG" | tee /etc/nginx/sites-available/default > /dev/null

chmod 0644 /etc/nginx/sites-available/default

systemctl restart nginx

echo "Nginx server configuration updated"
echo ""
echo "******************************************"
echo ""
echo "       Server is now ready to use         "
echo ""
echo "******************************************"

curl http://localhost
