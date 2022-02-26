#!/bin/bash
sudo mv auto_update_cert/certbot-renewal.service auto_update_cert/certbot-renewal.timer /etc/systemd/system/

# Turn on the Timer
sudo systemctl start certbot-renewal.timer && sudo systemctl enable certbot-renewal.timer

# Check
sudo systemctl status certbot-renewal.timer
