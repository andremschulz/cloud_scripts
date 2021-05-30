#!/bin/bash
apt-get update
apt-get upgrade -y

## install cloud-init
apt-get install cloud-init cloud-initramfs-growroot wget -y
# verify package dpkg -L cloud-initramfs-growroot

## install additional packages
apt-get install tcpdump psmisc net-tools mc chrony vim -y

## set hostname to localhost so dhclient can set the VM hostname 
hostname localhost
echo "localhost" > /etc/hostname

## disable selinux 
#sed -i 's/enforcing/disabled/g' /etc/selinux/config
#setenforce permissive
#sestatus

## config cloud-init
sudo sed -i s/" - set-passwords"/" - [set-passwords, always]"/g /etc/cloud/cloud.cfg
sudo sed -i s/" - runcmd"/" - [runcmd, always]"/g /etc/cloud/cloud.cfg
sudo sed -i s/" - scripts-user"/" - [scripts-user, always]"/g /etc/cloud/cloud.cfg
sudo sed -i s/" - ssh$"/" - [ssh, always]"/g /etc/cloud/cloud.cfg

echo "datasource_list: [ ConfigDrive, CloudStack, None ]
datasource:
  ConfigDrive:
   dsmode: local
  CloudStack: {}
  None: {}" > /etc/cloud/cloud.cfg.d/99_cloudstack.cfg

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
        - \"/dev/xvda3\"
    ignore_growroot_disabled: false" > /etc/cloud/cloud.cfg.d/50_growpartion.cfg
	
echo "runcmd:
  - [ pvresize, /dev/xvda3 ]
  - [ lvresize, -l, '+100%FREE', /dev/ubuntu-vg/ubuntu-lv ]
  - [ xfs_growfs, /dev/ubuntu-vg/ubuntu-lv ]" > /etc/cloud/cloud.cfg.d/51_extend_volume.cfg

rm -rf /var/lib/cloud

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

## python & ansible tools
#apt-get install python36 python36-devel python36-setuptools python-dnf
#easy_install-3.6 pip
#pip3 install --upgrade pip

# sudo sed -i s/"#PermitRootLogin prohibit-password"/"PermitRootLogin yes"/g /etc/ssh/sshd_config
# systemctl restart sshd
# passwrd root
# userdel -r ubuntu