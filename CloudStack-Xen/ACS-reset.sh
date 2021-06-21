#!/bin/bash





systemctl stop cloudstack-management
mysql -u cloud -pcloud -e 'drop database cloud'
mysql -u cloud -pcloud -e 'drop database cloud_usage'
cloudstack-setup-databases cloud:cloud@localhost --deploy-as=root:root

rm -rf /var/log/cloudstack/management/*
cloudstack-setup-management
systemctl start cloudstack-management
