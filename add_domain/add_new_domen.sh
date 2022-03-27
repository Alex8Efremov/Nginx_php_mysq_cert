#!/usr/bin/env bash

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

        location ~ \.php\$ {
            include snippets/fastcgi-php.conf;
            fastcgi_pass \$php_sock;
            fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        }
    }
EOF
sudo nginx -t && echo Next! || exit 113
sudo ln -s /etc/nginx/sites-available/$domain.conf /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl restart nginx && echo create certificate || exit 113
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

        location ~ \.php\$ {
            include snippets/fastcgi-php.conf;
            fastcgi_pass \$php_sock;
            fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        }


    }
EOF

sudo nginx -t && echo Successful!! || exit 113
sudo systemctl restart nginx
