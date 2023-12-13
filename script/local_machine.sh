#!/bin/bash

#ELASTIC_HOST="$(hostname -I | cut -f1 -d' ')"
#ELASTIC_HOST="$(dig +short myip.opendns.com @resolver1.opendns.com)"
ELASTIC_HOST="localhost"
ELASTIC_PORT=9200
KIBANA_PORT=5601

. ./env.sh

add-apt-repository ppa:openjdk-r/ppa
apt-get update
apt-get install openjdk-11-jdk -y

apt-get install nginx -y
systemctl start nginx

wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee –a /etc/apt/sources.list.d/elastic-7.x.list

apt-get update
apt-get install elasticsearch -y

echo "network.host: $ELASTIC_HOST" >> /etc/elasticsearch/elasticsearch.yml
echo "http.port: $ELASTIC_PORT" >> /etc/elasticsearch/elasticsearch.yml
echo "discovery.type: single-node" >> /etc/elasticsearch/elasticsearch.yml

apt-get install kibana -y

ufw allow $KIBANA_PORT/tcp

echo "server.port: $KIBANA_PORT" >> /etc/kibana/kibana.yml
echo "server.host: $ELASTIC_HOST" >> /etc/kibana/kibana.yml
echo "elasticsearch.hosts: ["\"http://$ELASTIC_HOST:$ELASTIC_PORT\""]" >> /etc/kibana/kibana.yml

echo "kibanaadmin:`openssl passwd -apr1 kibanaadmin`" | sudo tee -a /etc/nginx/htpasswd.users

systemctl daemon-reload
systemctl enable elasticsearch.service
systemctl start elasticsearch.service
systemctl enable kibana
systemctl start kibana

touch /etc/nginx/sites-available/elk
tee /etc/nginx/sites-available/elk << EOF
server {
    listen 80;

    server_name elk;

    auth_basic "Restricted Access";
    auth_basic_user_file /etc/nginx/htpasswd.users;

    location / {
        proxy_pass http://localhost:5601;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

ln -s /etc/nginx/sites-available/elk /etc/nginx/sites-enabled/elk
ufw allow 'Nginx Full'
unlink /etc/nginx/sites-enabled/default

apt-get install logstash -y
touch /etc/logstash/conf.d/02-beats-input.conf
touch /etc/logstash/conf.d/30-elasticsearch-output.conf
tee /etc/logstash/conf.d/02-beats-input.conf << EOF
input {
  beats {
    port => 5044
  }
}
EOF

tee /etc/logstash/conf.d/30-elasticsearch-output.conf << EOF
output {
  if [@metadata][pipeline] {
        elasticsearch {
        hosts => ["localhost:9200"]
        manage_template => false
        index => "%{[@metadata][beat]}-%{[@metadata][version]}-%{+YYYY.MM.dd}"
        pipeline => "%{[@metadata][pipeline]}"
        }
  } else {
        elasticsearch {
        hosts => ["localhost:9200"]
        manage_template => false
        index => "%{[@metadata][beat]}-%{[@metadata][version]}-%{+YYYY.MM.dd}"
        }
  }
}
EOF

/usr/share/logstash/bin/logstash --path.settings /etc/logstash -t
systemctl start logstash
systemctl enable logstash

apt-get install filebeat -y

cp ./filebeat.yml  /etc/filebeat/filebeat.yml

sudo filebeat modules enable system
sudo filebeat setup --pipelines --modules system
sudo filebeat setup --index-management -E output.logstash.enabled=false -E 'output.elasticsearch.hosts=["localhost:9200"]'
sudo filebeat setup -E output.logstash.enabled=false -E output.elasticsearch.hosts=['localhost:9200'] -E setup.kibana.host=localhost:5601
sudo systemctl start filebeat
sudo systemctl enable filebeat

systemctl reload nginx

STATUS="$(systemctl is-active elasticsearch)"
if [ "${STATUS}" = "inactive" ]; then
    systemctl start elasticsearch
else
    echo "Continue ================>"
fi