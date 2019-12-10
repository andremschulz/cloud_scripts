#!/bin/bash
if [ -z "$1" ]
then
	echo "Requires parameter - MAC address"
	exit 1
fi

MAC=$1
# You might want to check MAC correctness here. Enjoy doing it. RegExp, man!

# XenServer is agnostic to case for MAC addresses, so we don't care
VIF_UUID=`xe vif-list MAC=$MAC | grep ^uuid | awk '{print $NF}'`

VM=`xe vif-param-list uuid=$VIF_UUID | grep vm-name-label | awk '{print $NF}'`

echo "MAC $MAC has VM $VM"