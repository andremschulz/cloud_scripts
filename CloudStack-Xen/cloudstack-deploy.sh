#!/bin/bash
## Cloudstack auto-deployment script for Centos 7.
## place deploy_cloudstack.sh and mysql_secure files in one directory and give them execute rights.
## Set Vars below and execute ./deploy_cloudstack.sh

## Defining vars
WORK_DIR="/tmp"
FQDN="cloudstack.domain.int"		## host FQDN
ntp_1="0.0.0.0"					## first ntp server to sync
ntp_2="0.0.0.0"					## second ntp server to sync
db_root_password="root"			## mariadb root password
db_cloud_password="cloud"         ## password for mariadb cloudstack user cloud

## Installing prerequisites
printf "\n############### PREREQUISITES ################\n"
yum install expect epel-release -y -q
yum repolist
yum install mysql-connector-python -y -q

## Disable SELINUX
printf "\n############### SELINUX CONFIG ################\n"
sed -i 's/enforcing/disabled/g' /etc/selinux/config /etc/selinux/config
setenforce permissive
sestatus

## Disable firewalld
#systemctl disable firewalld 2>/dev/null
#systemctl stop firewalld 2>/dev/null
printf "\n############### FIREWALL CONFIG ################\n"
firewall-cmd --zone=public --add-port=8080/tcp --permanent
firewall-cmd reload
printf "port 8080 tcp enabled"
systemctl status firewalld

## Configure FQDN
printf "\n############### HOSTNAME ################\n"
printf $FQDN > /etc/hostname
hostname --fqdn

## Configure ntp
printf "\n############### NTP CONFIG ################\n"
yum install ntp -y -q
sytemctl enable ntpd 2>/dev/null
sed -i "s/0.centos.pool.ntp.org/$ntp_1/g" /etc/ntp.conf /etc/ntp.conf
sed -i "s/1.centos.pool.ntp.org/$ntp_2/g" /etc/ntp.conf /etc/ntp.conf
systemctl start ntpd
timedatectl set-timezone Europe/Sofia
ntpq -p
date -R

## Configure cloudstack repo
printf "\n############### YUM CONFIG ################\n"
rpm --import http://packages.shapeblue.com/release.asc
echo "[cloudstack]
name=cloudstack
baseurl=http://packages.shapeblue.com/cloudstack/upstream/centos7/4.14
enabled=1
gpgcheck=0" > /etc/yum.repos.d/cloudstack.repo
cat /etc/yum.repos.d/cloudstack.repo
#gpgkey=http://packages.shapeblue.com/release.asc
## Configure database
printf "\n############### DATABASE CONFIG ################\n"
rpm -ivh mysql-community-release-el7-5.noarch.rpm
yum install mariadb mariadb-server -y -q
grep  'binlog-format' /etc/my.cnf 2> /dev/null
if [ $? == '1' ]; then 
	sed "/mysql.sock/a innodb_rollback_on_timeout=1\ninnodb_lock_wait_timeout=600\nmax_connections=350\nlog-bin=mysql-bin\nbinlog-format = 'ROW'" /etc/my.cnf
fi
systemctl enable mysqld 2>/dev/null
systemctl start mysqld 2>/dev/null
systemctl status mysql
./mysql_secure $db_root_password

## Install Cloudstack
printf "\n############### CLOUDSTACK CONFIG ################\n"
yum install cloudstack-management -y -q
alternatives --config java
cloudstack-setup-databases cloud:$db_cloud_password@localhost --deploy-as=root:$db_root_password
cloudstack-setup-management
### xenserver post install commands
wget http://download.cloudstack.org/tools/vhd-util -P $WORK_DIR
yes | cp $WORK_DIR/vhd-util /usr/share/cloudstack-common/scripts/vm/hypervisor/xenserver/vhd-util
