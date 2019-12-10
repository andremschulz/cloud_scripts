#!/bin/bash

###### CONFIGURE FIREWALLD #######

yum -y -q install firewalld
systemctl start firewalld.service
systemctl enable firewalld.service
firewall-cmd --permanent --add-service=ssh
firewall-cmd --permanent --add-service=nfs
firewall-cmd --permanent --add-service=mountd
firewall-cmd --permanent --add-service=rpc-bind
firewall-cmd --reload

##### CONFIGURE NFS #########
yum install nfs-utils -y -q
systemctl enable nfs-server.service
systemctl start nfs-server.service

add to /etc/sysconfig/nfs

LOCKD_TCPPORT=32803
LOCKD_UDPPORT=32769
MOUNTD_PORT=892
RQUOTAD_PORT=875
STATD_PORT=662
STATD_OUTGOING_PORT=2020


#mkdir /var/cloud_isos
chmod -R 755 /var/cloud_isos
chown nfsnobody:nfsnobody /var/cloud_isos


printf "/var/cloud_isos         *(rw,no_root_squash,no_subtree_check)">>/etc/exports
exportfs -a



lvcreate -n cloud_isos --size 100G cloud_nfs
