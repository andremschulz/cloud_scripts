#!/bin/bash

## set interface config
echo "DEVICE=eth0
TYPE=Ethernet
BOOTPROTO=dhcp
ONBOOT=yes" > /etc/sysconfig/network-scripts/ifcfg-eth0

## set hostname to localhost so dhclient can set the VM hostname 
hostname localhost
echo "localhost" > /etc/hostname

## disable selinux 
sed -i 's/enforcing/disabled/g' /etc/selinux/config
setenforce permissive
sestatus

## forces the user to change the password of the VM after the template has been deployed.
passwd --expire root
u="cloud-user"
useradd $u
echo $u:"cloud" | chpasswd

## install and config cloud-init
apt-get install cloud-init cloud-initramfs-growroot
# verify package dpkg -L cloud-initramfs-growroot
sudo sed -i s/"set-passwords"/"[set-passwords, always]"/g /etc/cloud/cloud.cfg

echo "datasource_list: [ ConfigDrive, CloudStack, None ]
datasource:
  ConfigDrive:
   dsmode: local
  CloudStack: {}
  None: {}" > /etc/cloud/cloud.cfg.d/99_cloudstack.cfg
  
  echo "growpart:
    mode: auto
    devices:
        - \"/dev/xvda3\"
    ignore_growroot_disabled: false" > /etc/cloud/cloud.cfg.d/50_growpartion.cfg

rm -rf /var/lib/cloud
## install xentools

## install additional packages
apt-get install tcpdump psmisc net-tools wget mc chrony vim



## python & ansible tools
apt-get install python36 python36-devel python36-setuptools python-dnf
easy_install-3.6 pip
pip3 install --upgrade pip
##pip3 install ansible //not needed for client/dev vms


## remove address bindings as they are generated on boot
rm -f /etc/udev/rules.d/70*
rm -f /var/lib/dhclient/*

## remove ssh keys for security purposes
rm -f /etc/ssh/*key*

## clean logs
apt-get clean all
cat /dev/null > /var/log/wtmp 2>/dev/null
logrotate -f /etc/logrotate.conf 2>/dev/null
rm -f /var/log/*-* /var/log/*.gz 2>/dev/null

##Clearing User History
history -c
unset HISTFILE