#!/bin/bash

# THIS FILE USING WHEN USE LOCAL MACHINE

sudo rm -rf /var/lib/elasticsearch /usr/share/elasticsearch /etc/elasticsearch
sudo rm -rf /etc/kibana
sudo rm -rf elasticsearch-8.11.1-amd64.deb elasticsearch-8.11.1-amd64.deb.sha512
sudo apt remove --purge --auto-remove elasticsearch -y
sudo apt remove --purge --auto-remove kibana -y
sudo apt remove --purge --auto-remove nginx -y
sudo apt-get purge nginx nginx-common -y
sudo apt remove --purge --auto-remove logstash -y
sudo apt remove --purge --auto-remove filebeat -y
sudo systemctl daemon-reload
sudo systemctl stop kibana
sudo systemctl stop elasticsearch
sudo systemctl stop nginx
sudo systemctl stop logstash
sudo systemctl stop filebeat
sudo systemctl daemon-reload

sudo ufw delete allow 'Nginx HTTP'

sudo unlink /etc/nginx/sites-enabled/elk

sudo rm -rf /etc/nginx/sites-available/elk
sudo rm -rf /etc/nginx/sites-enable/elk
sudo rm -rf /etc/nginx/htpasswd.users