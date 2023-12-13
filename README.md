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
### Note 
    - you need chmod +x for each file .sh

### I using nginx for purpose reverse proxy then you need a username and password to access kibana dashboard
    - username: kibanaadmin
    - password: kibanaadmin