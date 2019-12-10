#!/bin/bash

user='user'
pw='password'

echo "" >> /etc/sudoers
echo "# ServiceNOW UCMDB" >> /etc/sudoers
echo "$user ALL=(root) NOPASSWD:/bin/chage,/sbin/chpasswd,/sbin/dmidecode,/sbin/fdisk,/sbin/multipath,/sbin/lsof,/sbin/dmsetup" >> /etc/sudoers
adduser $user
echo $pw | passwd $user --stdin
