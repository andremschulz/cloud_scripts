#!/bin/bash

###### REQUIRED VARIABLES #######
NFSSRs=(
"/var/secondary"
) 		

###### CONFIGURE FIREWALLD #######
printf "\n############### CONFIGURE FIREWALL ################\n"
#yum -y -q install firewalld
systemctl start firewalld.service
systemctl enable firewalld.service
firewall-cmd --permanent --add-service=ssh
firewall-cmd --permanent --add-service=nfs
firewall-cmd --permanent --add-service=mountd
firewall-cmd --permanent --add-service=rpc-bind
firewall-cmd --permanent --add-port=111/tcp
firewall-cmd --permanent --add-port=111/udp
#firewall-cmd --permanent --add-port=1110/udp
#firewall-cmd --permanent --add-port=1110/tcp
#firewall-cmd --permanent --add-port=54302/tcp
#firewall-cmd --permanent --add-port=20048/tcp
firewall-cmd --permanent --add-port=2049/tcp
firewall-cmd --permanent --add-port=2049/udp
#firewall-cmd --permanent --add-port=4045/tcp
#firewall-cmd --permanent --add-port=4045/udp
#firewall-cmd --permanent --add-port=46666/tcp
#firewall-cmd --permanent --add-port=42955/tcp
#firewall-cmd --permanent --add-port=875/tcp
firewall-cmd --permanent --add-port=892/udp
firewall-cmd --reload

##### CONFIGURE NFS #########
printf "\n############### CONFIGURE NFS ################\n"
yum install nfs-utils -y -q
systemctl enable rpcbind
systemctl enable nfs-server
systemctl enable nfs-lock
systemctl enable nfs-idmap
systemctl start rpcbind
systemctl start nfs-server
systemctl start nfs-lock
systemctl start nfs-idmap


sed -i 's/#LOCKD_TCPPORT=32803/LOCKD_TCPPORT=32803/' 				/etc/sysconfig/nfs
sed -i 's/#LOCKD_UDPPORT=32769/LOCKD_UDPPORT=32769/' 				/etc/sysconfig/nfs
sed -i 's/#MOUNTD_PORT=892/MOUNTD_PORT=892/' 		  				/etc/sysconfig/nfs
sed -i 's/#RQUOTAD_PORT=875/RQUOTAD_PORT=875/'       				/etc/sysconfig/nfs
sed -i 's/#STATD_PORT=662/STATD_PORT=662/'           				/etc/sysconfig/nfs
sed -i 's/#STATD_OUTGOING_PORT=2020/STATD_OUTGOING_PORT=2020/' 		/etc/sysconfig/nfs

printf "" > /etc/exports
for  (( i = 0; i < "${#NFSSRs[@]}"; i++ ))
do
	NFS=${NFSSRs[i]};
	if [ ! -d $NFS ]; then
		mkdir $NFS
	fi
	chmod -R 755 $NFS
	chown nfsnobody:nfsnobody $NFS

	printf "$NFS         *(rw,no_root_squash,no_subtree_check)\n" >>     /etc/exports
	
done
exportfs -a
systemctl restart nfs-server
##### NFS STATUS #########
systemctl status nfs.service



##pvcreate /dev/xxx
##vgcreate secondaryNFS /dev/xxx
##lvcreate -n secondaryNFS -l 100%FREE secondaryNFS
