#!/bin/bash
## Cloudstack OS level settings

## Define Variables
IP=""
GATEWAY=""
NETMASK=""
DNS1=""
DNS2=""
FQDN=""
NTP1=""
NTP2=""
TIMEZONE="Europe/Sofia"

## Update system
printf "\n############### UPDATE SYSTEM ################\n"
yum upgrade -y
yum install bridge-utils net-tools -y -q

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
printf "port 8080 tcp enabled\n"
systemctl status firewalld

## Configure FQDN
printf "\n############### HOSTNAME ################\n"
printf $FQDN > /etc/hostname
hostname --fqdn

## Configure ntp
printf "\n############### NTP CONFIG ################\n"
yum install ntp -y -q
sytemctl enable ntpd 2>/dev/null
sed -i "s/0.centos.pool.ntp.org/$NTP1/g" /etc/ntp.conf /etc/ntp.conf
sed -i "s/1.centos.pool.ntp.org/$NTP2/g" /etc/ntp.conf /etc/ntp.conf
systemctl start ntpd
timedatectl set-timezone $TIMEZONE
ntpq -p
date -R

## Configure network
printf "\n############### NETWORKING CONFIG ################\n"
echo "DEVICE=cloudbr0
TYPE=Bridge
ONBOOT=yes
BOOTPROTO=static
IPV6INIT=no
IPV6_AUTOCONF=no
DELAY=5
IPADDR=$IP
GATEWAY=$GATEWAY
NETMASK=$NETMASK
DNS1=$DNS1
DNS2=$DNS2
STP=yes
USERCTL=no
NM_CONTROLLED=no" > /etc/sysconfig/network-scripts/ifcfg-cloudbr0

echo "TYPE=Ethernet
BOOTPROTO=none
DEFROUTE=yes
NAME=eth0
DEVICE=eth0
ONBOOT=yes
BRIDGE=cloudbr0
NM_CONTROLLED=no" > /etc/sysconfig/network-scripts/ifcfg-eth0

systemctl enable network
systemctl restart network
