#!/bin/bash
## pre-configuration script for XenServer before importing to Cloudstack.
## Run xe-switch-network-backend bridge and reboot the server before running the script.

grep "net.bridge.bridge-nf-call-iptables = 1" /etc/sysctl.conf

if [ $? == 1 ]; then
	printf 'net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 0
net.bridge.bridge-nf-call-arptables = 1
' >> /etc/sysctl.conf
	sysctl -p /etc/sysctl.conf
fi 
