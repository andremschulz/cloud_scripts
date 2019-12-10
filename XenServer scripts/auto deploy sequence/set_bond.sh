#!/bin/bash
# Description: what it does.
# Created on: 24-March-2017 by Duke Yordan Kostov

XEN_COUNT=$(xe host-list params=name-label | awk '{print $5}'| grep -v '^$'|wc -l)
XEN_LIST=$(xe host-list params=name-label | awk '{print $5}'| grep -v '^$')

echo "date '+%D--%X'#Configuring bonds of $XEN_COUNT XenServers"

xe network-list name-label="Bond 0+1" params=uuid | awk '{print $5}'| grep -v '^$'
if [ "$?" == "1" ]; then
	BOND0_UUID=$(xe network-create name-label="Bond 0+1")
	xe network-param-set other-config:automatic=false uuid=$BOND0_UUID
	i=1;
	while [ "$i" -le "$XEN_COUNT" ]; do
		HOST=$(echo $XEN_LIST |awk -v var=$i '{print $var}')
		echo "date '+%D--%X'#Configuring $HOST"
		PIF3=$(xe pif-list host-name-label=$HOST device=eth2 params=uuid | awk '{print $5}'| grep -v '^$')
		PIF4=$(xe pif-list host-name-label=$HOST device=eth3 params=uuid | awk '{print $5}'| grep -v '^$')
		xe bond-create network-uuid=$BOND1_UUID pif-uuids=$PIF3,$PIF4
		if [ "$?" != "0" ]; then
			echo "date '+%D--%X'#$HOST bond 2+3 configuration failed"
			exit 2;
		fi
		i=$((i+1))
		sleep 30
	done
fi

xe network-list name-label="Bond 2+3" params=uuid | awk '{print $5}'| grep -v '^$'
if [ "$?" == "1" ]; then
	BOND1_UUID=$(xe network-create name-label="Bond 2+3")
	xe network-param-set other-config:automatic=false uuid=$BOND1_UUID
	i=1;
	while [ "$i" -le "$XEN_COUNT" ]; do
		HOST=$(echo $XEN_LIST |awk -v var=$i '{print $var}')
		echo "date '+%D--%X'#Configuring $HOST"
		PIF1=$(xe pif-list host-name-label=$HOST device=eth0 params=uuid | awk '{print $5}'| grep -v '^$')
		PIF2=$(xe pif-list host-name-label=$HOST device=eth1 params=uuid | awk '{print $5}'| grep -v '^$')
		xe bond-create network-uuid=$BOND0_UUID pif-uuids=$PIF1,$PIF2
		if [ "$?" != "0" ]; then
			echo "date '+%D--%X'#$HOST bond 0+1 configuration failed"
			exit 1;
		fi
		i=$((i+1))
		sleep 30
	done
fi

