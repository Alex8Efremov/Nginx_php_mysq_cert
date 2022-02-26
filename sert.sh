#!/usr/bin/env bash
sudo certbot --nginx certonly

sudo cat <<EOF >/etc/nginx/sites-available/example.com.conf
server {
        listen 80;
        listen [::]:80;

        server_name example.com www.example.com;
        return 301 https://example.com\$request_uri;
    }

server {
        listen 443 ssl http2;
        listen [::]:443 ssl http2;

        server_name www.example.com;
        return 301 https://example.com\$request_uri;

        ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;
        ssl_trusted_certificate /etc/letsencrypt/live/example.com/chain.pem;

        include snippets/ssl-params.conf;
    }

server {
        listen 443 ssl http2;
        listen [::]:443 ssl http2;

        root \$root_path;
        set \$root_path /var/www/example.com/html;
        set \$php_sock unix:/var/run/php/php7.3-fpm.sock;
        index index.php index.html index.htm;

        server_name example.com;

        access_log /var/www/example.com/logs/access.log;
        error_log /var/www/example.com/logs/error.log;

        ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;
        ssl_trusted_certificate /etc/letsencrypt/live/example.com/chain.pem;

        location / {
            try_files \$uri \$uri/ =404;
        }

        location ~ \.php\$ {
            include snippets/fastcgi-php.conf;
            fastcgi_pass \$php_sock;
            fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        }

      #  include snippets/ssl-params.conf;
    }
EOF

sudo rm -r /var/www/example.com/html/*
sudo apt install git -y
git clone https://github.com/Alex8Efremov/WebSite_portfolio.git /var/www/example.com/html/

sudo systemctl restart nginx
