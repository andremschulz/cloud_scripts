#!/bin/bash

###### REQUIRED VARIABLES #######
NFSSRs+=(
"/var/primary" 
"/var/secondary"
) 		

###### CONFIGURE FIREWALLD #######
printf "\n############### CONFIGURE FIREWALL ################\n"
yum -y -q install firewalld
systemctl start firewalld.service
systemctl enable firewalld.service
firewall-cmd --permanent --add-service=ssh
firewall-cmd --permanent --add-service=nfs
firewall-cmd --permanent --add-service=mountd
firewall-cmd --permanent --add-service=rpc-bind
firewall-cmd --reload

##### CONFIGURE NFS #########
printf "\n############### CONFIGURE NFS ################\n"
yum install nfs-utils -y -q
systemctl enable nfs-server.service
systemctl start nfs-server.service

sed -i 's/#LOCKD_TCPPORT=32803/LOCKD_TCPPORT=32803/' 				/etc/sysconfig/nfs
sed -i 's/#LOCKD_UDPPORT=32769/LOCKD_UDPPORT=32769/' 				/etc/sysconfig/nfs
sed -i 's/#MOUNTD_PORT=892/MOUNTD_PORT=892/' 		  				/etc/sysconfig/nfs
sed -i 's/#RQUOTAD_PORT=875/RQUOTAD_PORT=875/'       				/etc/sysconfig/nfs
sed -i 's/#STATD_PORT=662/STATD_PORT=662/'           				/etc/sysconfig/nfs
sed -i 's/#STATD_OUTGOING_PORT=2020/STATD_OUTGOING_PORT=2020/' 		/etc/sysconfig/nfs

printf "" > /etc/exports
for  (( i = 0; i < "${#NFSSRs[@]}"; i++ ))
do
	NFS=${vm_array[i]};
	if [ ! -d $NFS ]; then
		mkdir $NFS
	fi
	chmod -R 755 $NFS
	chown nfsnobody:nfsnobody $NFS

	printf "$NFS         *(rw,no_root_squash,no_subtree_check)\n" >>     /etc/exports
	
done
exportfs -a
##### NFS STATUS #########
systemctl status nfs.service

