#!/bin/bash
## Get started VMs in specific network (defined by UUID)
## Author: Jordan kostov

#NETWORK_NAME="$1"
#NETWORK_UUID=($(xe network-list name-label=$NETWORK_NAME |grep uuid| cut -d ' ' -f 20))
NETWORK_UUID="$1"
echo $NETWORK_UUID
VM_UUIDS=($(xe vif-list network-uuid=$NETWORK_UUID currently-attached=true params=vm-uuid |grep vm-uuid|cut -d ' ' -f 8))
echo $VM_UUIDS
for  (( i = 0; i < ${#VM_UUIDS[@]}; i++ ))
do
	echo -n "`xe vm-list uuid=${VM_UUIDS[i]} params=name-label |grep name-label |cut -d ' ' -f 8`," >> output.txt
	echo "`xe vm-list uuid=${VM_UUIDS[i]} params=networks |grep networks |cut -d ' ' -f 8`" >> output.txt
done
