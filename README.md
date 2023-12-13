### Note 
    - you need chmod +x for each file .sh
    - when i create AMI i check status of elasticsearch is available but when i create instance by ami i create previous the elasticsearch service is activating
    - so you access to your instance and start elasticsearch service.

### In this resource i will implement ELK on AMI using Packer
    The package I will install:
        - openjdk-11-jdk
        - nginx
        - elasticsearch
        - kibana
        - logstash
        - filebeat
        
### I write two version 
    - one for create ELK on AMI using Packer: packer build -var-file vars.json template.json
    - one for create ELK on local machine (Am using linux machine and i write for this OS): just run local_machine.sh don't need packer

### I using nginx for purpose reverse proxy then you need a username and password to access kibana dashboard
    - username: kibanaadmin
    - password: kibanaadmin