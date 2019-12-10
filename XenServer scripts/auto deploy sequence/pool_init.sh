#!/bin/bash
## POOL INIT
POOL_NAME="$1"
HOST_COUNT="$2"
PASS="$3"
DIR=$(pwd)

#################COLLECT INFORMATION
echo "Gathering Info..."
POOL_UUID=$(xe pool-list params=uuid | awk '{print $5}'| grep -v '^$')
MASTER_UUID=$(xe pool-list params=master| awk '{print $5}'| grep -v '^$' )
MGM_PIF_UUID=$(xe pif-list management=true  host-uuid=$MASTER_UUID| awk '{print $5}'| grep -v '^$')
MASTER_IP=$(xe pif-param-list uuid=$MGM_PIF_UUID |grep " IP ( RO):" | awk '{print $4}'| grep -v '^$')
MGM_NETWORK=$(echo $MASTER_IP| awk -F . '{print $1"."$2"."$3}')
SLAVE_OCTET=$(echo $MASTER_IP| awk -F . '{print $4}')
URL="http://mirrors.corp.int/xenserver/prod"

is_it_ok () {
if [ "$1" != "0" ]; then
	echo "date '+%D--%X'#$2"
	exit $3
fi
}

wget "$URL/xen_scripts"
is_it_ok $? "Could not contact $URL. Check network accessibility" 1
tar -zxvf xen_scripts
 
#########POOL CREATION
echo "Creating Pool with name $POOL_NAME..."
xe pool-param-set name-label="$POOL_NAME" uuid=$POOL_UUID
count=1
echo "Started joining slaves..."
IP=$SLAVE_OCTET
while [ $count -lt $HOST_COUNT ]; do
	IP=$((IP+1))
	echo "Joining slave... $MGM_NETWORK.$IP"
	expect scripts/join-slave "$MGM_NETWORK.$IP" $MASTER_IP $PASS
	echo "Slave joined"
	count=$((count+1))
done
echo "POOL creation complete!"
sleep 30

#########POOL PATCHING
sh scripts/set_patches.sh $URL
is_it_ok $? "Could not contact $URL. Check network accessibility" 2

#########NETWORKING
sh scripts/set_bond.sh
is_it_ok $? "Network configuration failed" 3

sh scripts/set_vlan.sh
is_it_ok $? "Network configuration failed" 3
#########MULTIPATHING
sh scripts/pool_multipath.sh

#########MONITORING
count=1
IP=$SLAVE_OCTET
while [ $count -lt $HOST_COUNT ]; do
	IP=$((IP+1))
	echo "Configuring monitoring at $MGM_NETWORK.$IP ..."
	expect scripts/pool_monitoring "$MGM_NETWORK.$IP" $PASS
	count=$((count+1))
done
sh scripts/set_monitoring.sh  ##set stuff on localhost

###ADDING STORAGE
echo "FINISH"

###BACKUP MODULE

sh scripts/set_backup
sh scripts/set_bond.sh
is_it_ok $? "Network configuration failed" 7
