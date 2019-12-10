#!/bin/bash
# Description: what it does.
# Created on: 24-March-2017 by Duke Yordan Kostov

source scripts/list_vlans_client

traffic_bond="Bond 4+5"
#traffic_bond="Bond 2+3"

BOND_LIST=$(xe pif-list network-name-label="$traffic_bond" params=uuid| awk '{print $5}'| grep -v '^$')
BOND_COUNT=$(xe pif-list network-name-label="$traffic_bond" params=uuid| awk '{print $5}'| grep -v '^$'|wc -l)

for i in "${!vlans[@]}"
do
	xe network-list name-label="${vlans[$i]}" params=uuid | awk '{print $5}'| grep -v '^$'
	if [ "$?" == "1" ]; then
		check=$(xe vlan-list tag="$i")
		if [ "$check" == "" ]; then
			NETWORK_UUID=$(xe network-create name-label="${vlans[$i]}" name-description="${vlans[$i]}") || exit 1
			xe network-param-set other-config:automatic=false uuid=$NETWORK_UUID || exit 1
			echo "${vlans[$i]} created (UUID: $NETWORK_UUID"
			b=1
			while [ "$b" -le "$BOND_COUNT" ]; do
				BOND=$(echo $BOND_LIST |awk -v var=$b '{print $var}')
				VLAN_UUID=$(xe vlan-create pif-uuid="$BOND" network-uuid="$NETWORK_UUID" vlan="$i") || exit 2
				echo "${vlans[$i]} is set to bond with UUID $BOND"
				b=$((b+1))
			done
		else
			echo VLAN $i already exists
		fi
	fi
done

