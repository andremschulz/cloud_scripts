#!/bin/bash
ip=$1;
rootP=$2
cloudP=$3
port=33306
systemctl stop cloudstack-management

### remote sql commands
mysql -u cloud -p$cloudP -e 'drop database cloud' -h $ip -P $port
mysql -u cloud -p$cloudP -e 'drop database cloud_usage' -h $ip -P $port
cloudstack-setup-databases cloud:$cloudP@$ip:$port --deploy-as=root:$rootP
### local sql commands
#mysql -u cloud -pcloud -e 'drop database cloud'
#mysql -u cloud -pcloud -e 'drop database cloud_usage'
#cloudstack-setup-databases cloud:cloud@localhost --deploy-as=root:root

rm -rf /var/log/cloudstack/management/*
cloudstack-setup-management
systemctl start cloudstack-management
