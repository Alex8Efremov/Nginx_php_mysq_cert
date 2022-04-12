#!/usr/bin/env bash
sudo apt update && sudo apt upgrade -y
sudo apt install ufw -y
sudo apt-get install nginx -y
sudo ufw enable
sudo ufw allow 'OpenSSH' && sudo ufw allow 'Nginx Full' && sudo ufw status
sudo apt-get install software-properties-common -y
sudo add-apt-repository ppa:certbot/certbot -y
sudo apt-get update
sudo apt-get install python-certbot-nginx -y
sudo openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048
sudo mkdir -p /etc/nginx/snippets && sudo chown -R $USER:$USER /etc/nginx

cat <<EOF >/etc/nginx/snippets/ssl-params.conf
ssl_session_timeout 1d;
ssl_session_cache shared:SSL:10m;
ssl_session_tickets off;

ssl_dhparam /etc/ssl/certs/dhparam.pem;

ssl_protocols TLSv1.2 TLSv1.3;
ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;
ssl_prefer_server_ciphers off;

add_header Strict-Transport-Security "max-age=63072000" always;

EOF
sudo apt install php-fpm php-mysql -y
echo -n -e "Enter your domain name\nEnter: example.com\n ---> "
read domain
if [[ -z $domain ]]
then domain="example.com"
fi

sudo mkdir -p /var/www/$domain/html
sudo mkdir -p /var/www/$domain/logs
sudo chown -R $USER:$USER /var/www/

sudo cat <<EOF >/etc/nginx/sites-available/$domain.conf
server {
        listen 80;
        listen [::]:80;

        root \$root_path;
        set \$root_path /var/www/$domain/html;
        set \$php_sock unix:/var/run/php/php7.3-fpm.sock;
        index index.php index.html index.htm;

        server_name $domain www.$domain;

        access_log /var/www/$domain/logs/access.log;
        error_log /var/www/$domain/logs/error.log;

        location / {
            try_files \$uri \$uri/ =404;
        }

        location ~ \.php\$ {
            include snippets/fastcgi-php.conf;
            fastcgi_pass \$php_sock;
            fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        }
    }
EOF
sudo nginx -t
sudo ln -s /etc/nginx/sites-available/$domain.conf /etc/nginx/sites-enabled/
sudo nginx -t

sudo systemctl restart nginx

sudo cat <<EOF >/var/www/$domain/html/index.html
<!DOCTYPE html>
<title>Title</title>
<h1><center>Hello World!</h1>
#<?php
#  phpinfo();
#?>
</html>
EOF

sudo systemctl restart nginx
