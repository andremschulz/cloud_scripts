#!/bin/bash
# Description: what it does.
# Created on: 23-June-2016 by Duke Yordan Kostov

USAGE="sh $0 POOL_NAME HOST_NUMBER POOL_ROOT_PASSWORD
- POOL_NAME - this the name of the whole pool
- HOST_NUMBER - this is the number of physical hosts in the pool. Defined by an integer from 1 and above
- POOL_ROOT_PASSWORD - the password used to login hosts. All hosts should be configured with the same password prior to script execution

Example: sh $0 POOL_NHWK1 2 Passw0rd"

## POOL INIT
POOL_NAME="$1"
HOST_COUNT="$2"
PASS="$3"
DIR=$(pwd)

if [ "$POOL_NAME" == "" ]; then echo "Please set a pool name"; printf "$USAGE"; exit; fi
if [ "$HOST_COUNT" == "" ]; then echo "Please define the number of hosts"; echo $USAGE; exit; fi
if [ "$PASS" == "" ]; then echo "Please fill in a password"; echo $USAGE; exit; fi


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

wget "$URL/client_scripts.tgz"
is_it_ok $? "Could not contact $URL. Check network accessibility" 1
tar -zxvf client_scripts.tgz
 
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

sh scripts/set_vlans.sh
is_it_ok $? "Network configuration failed" 3
#########MULTIPATHING
sh scripts/pool_multipath.sh

#########MONITORING
count=1
IP=$SLAVE_OCTET
#set monitoring on foreign hosts
while [ $count -lt $HOST_COUNT ]; do
	IP=$((IP+1))
	echo "Configuring monitoring at $MGM_NETWORK.$IP ..."
	expect scripts/pool_monitoring "$MGM_NETWORK.$IP" $PASS
	count=$((count+1))
done
sh scripts/set_monitoring.sh  ##set stuff on native host

###ADDING STORAGE
echo "FINISH"


