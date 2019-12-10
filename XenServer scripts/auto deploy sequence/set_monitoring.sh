#!/bin/bash

cat scripts/iptables > /etc/sysconfig/iptables ##open snmp ports in firewall
cat scripts/snmpd.conf > /etc/snmp/snmpd.conf  #set monit configuration
cat scripts/ssmtp.conf > /etc/ssmtp/ssmtp.conf #set e-mail config

systemctl restart iptables.service snmpd.service
systemctl enable snmpd.service

#ssmtp integration@worldsupport.info < test_msg.txt
