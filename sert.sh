#!/usr/bin/env bash
echo -n -e "Enter your domain name\nEnter: example.com\n ---> "
read domain
if [[ -z $domain ]]
then domain="example.com"
fi

sudo certbot --nginx certonly

sudo cat <<EOF >/etc/nginx/sites-available/$domain.conf
server {
        listen 80;
        listen [::]:80;

        server_name $domain www.$domain;
        return 301 https://$domain\$request_uri;
    }

server {
        listen 443 ssl http2;
        listen [::]:443 ssl http2;

        server_name www.$domain;
        return 301 https://$domain\$request_uri;

        ssl_certificate /etc/letsencrypt/live/$domain/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/$domain/privkey.pem;
        ssl_trusted_certificate /etc/letsencrypt/live/$domain/chain.pem;

        include snippets/ssl-params.conf;
    }

server {
        listen 443 ssl http2;
        listen [::]:443 ssl http2;

        root \$root_path;
        set \$root_path /var/www/$domain/html;
        set \$php_sock unix:/var/run/php/php7.3-fpm.sock;
        index index.php index.html index.htm;

        server_name $domain;

        access_log /var/www/$domain/logs/access.log;
        error_log /var/www/$domain/logs/error.log;

        ssl_certificate /etc/letsencrypt/live/$domain/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/$domain/privkey.pem;
        ssl_trusted_certificate /etc/letsencrypt/live/$domain/chain.pem;

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

sudo rm -r /var/www/$domain/html/*
sudo apt install git -y
git clone https://github.com/Alex8Efremov/WebSite_portfolio.git /var/www/$domain/html/

sudo systemctl restart nginx
