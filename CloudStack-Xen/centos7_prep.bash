#!/bin/bash
yum -y update 

## install cloud-init
yum -y install cloud-init cloud-utils-growpart

## install additional packages
yum -y install epel-repo
yum -y install tcpdump psmisc bind-utils net-tools wget mc chrony vim

## set interface config
echo "DEVICE=eth0
TYPE=Ethernet
BOOTPROTO=dhcp
ONBOOT=yes" > /etc/sysconfig/network-scripts/ifcfg-eth0

## set hostname to localhost so dhclient can set the VM hostname 
hostname localhost
echo "localhost" > /etc/hostname

## disable selinux 
sed -i 's/enforcing/disabled/g' /etc/selinux/config /etc/selinux/config
setenforce permissive
sestatus

## forces the user to change the password of the VM after the template has been deployed.
#passwd --expire root

## config cloud-init
systemctl enable cloud-init
systemctl enable cloud-init-local.service
systemctl enable cloud-init.service
systemctl enable cloud-config.service
systemctl enable cloud-final.service
systemctl enable cloud-init.service
systemctl enable cloud-config.service
systemctl enable cloud-final.service

echo "datasource: ConfigDrive, CloudStack" > /etc/cloud/ds-identify.cfg 
sudo sed -i s/"set-passwords"/"[set-passwords, always]"/g /etc/cloud/cloud.cfg

echo "system_info:
    default_user:
     name: cloud-user
     lock_passwd: false
     sudo: [\"ALL=(ALL) ALL\"]
disable_root: 0
ssh_pwauth: 1" > /etc/cloud/cloud.cfg.d/80_root.cfg

echo "growpart:
    mode: auto
    devices:
        - \"/dev/xvda2\"
    ignore_growroot_disabled: false" > /etc/cloud/cloud.cfg.d/50_growpartion.cfg

echo "runcmd:
  - [ cloud-init-per, always, grow_VG, pvresize, /dev/xvda2 ]
  - [ cloud-init-per, always, grow_LV, lvresize, -l, '+100%FREE', /dev/centos/root ]
  - [ cloud-init-per, always, grow_FS, xfs_growfs, /dev/centos/root ]" > /etc/cloud/cloud.cfg.d/51_extend_volume.cfg
  
## install xentools

## make Yaml valid filetype for ansible, change TAB key to add spaces instead of tabs
echo "autocmd FileType yaml setlocal ai ts=2 sw=2 et" >> /etc/vimrc 

## clean cloud-init
rm -rf /var/lib/cloud/data/*
rm -rf /var/lib/cloud/instance/*
rm -rf /var/lib/cloud/instances/*

## remove address bindings as they are generated on boot
rm -f /etc/udev/rules.d/70*
rm -f /var/lib/dhclient/*

## remove ssh keys for security purposes
rm -f /etc/ssh/*key*

## clean logs
yum clean all
cat /dev/null > /var/log/wtmp 2>/dev/null
logrotate -f /etc/logrotate.conf 2>/dev/null
rm -f /var/log/*-* /var/log/*.gz 2>/dev/null

##Clearing User History
history -c
unset HISTFILE

## python & ansible tools
#yum -y install python36 python36-devel python36-setuptools python-dnf
#easy_install-3.6 pip
#pip3 install --upgrade pip
##pip3 install ansible //not needed for client/dev vms