#!/bin/bash
## Cloudstack auto-deployment script for Centos 7.
## place deploy_cloudstack.sh and mysql_secure files in one directory and give them execute rights.
## Set Vars below and execute ./deploy_cloudstack.sh

## Defining vars
WORK_DIR="/tmp"
db_root_password="root"			## mariadb root password
db_cloud_password="cloud"       ## password for mariadb cloudstack user cloud

## Installing prerequisites
printf "\n############### PREREQUISITES ################\n"
yum install expect epel-release -y -q
yum repolist

## Configure cloudstack repo
printf "\n############### YUM CONFIG ################\n"
rpm --import http://packages.shapeblue.com/release.asc
echo "[cloudstack-4.15]
name=cloudstack
baseurl=http://packages.shapeblue.com/cloudstack/upstream/centos7/4.15
enabled=1
gpgcheck=1
gpgkey=http://packages.shapeblue.com/release.asc" > /etc/yum.repos.d/cloudstack.repo
cat /etc/yum.repos.d/cloudstack.repo

## Configure database
printf "\n############### DATABASE CONFIG ################\n"
rpm -ivh mysql-community-release-el7-5.noarch.rpm
yum install MariaDB-client mariaDB-server -y -q
yum install mysql-connector-python -y -q
grep  'binlog-format' /etc/my.cnf 2> /dev/null
if [ $? == '1' ]; then 
	sed "/mysql.sock/a innodb_rollback_on_timeout=1\ninnodb_lock_wait_timeout=600\nmax_connections=350\nlog-bin=mysql-bin\nbinlog-format = 'ROW'" /etc/my.cnf
fi
systemctl enable mysqld 2>/dev/null
systemctl start mysqld 2>/dev/null
systemctl status mysql
/usr/bin/mysql_secure_installation
#/usr/bin/mysqladmin -u root password 'root'
#/usr/bin/mysqladmin -u root -h localhost.localdomain password 'root'
## Install Cloudstack
printf "\n############### CLOUDSTACK CONFIG ################\n"
yum install cloudstack-management -y -q
alternatives --config java
cloudstack-setup-databases cloud:$db_cloud_password@localhost --deploy-as=root:root
cloudstack-setup-management
### xenserver post install commands
wget http://download.cloudstack.org/tools/vhd-util -P $WORK_DIR
yes | cp $WORK_DIR/vhd-util /usr/share/cloudstack-common/scripts/vm/hypervisor/xenserver/vhd-util



