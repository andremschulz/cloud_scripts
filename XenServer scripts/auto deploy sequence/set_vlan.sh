#!/bin/bash
# Description: what it does.
# Created on: 23-June-2016 by Duke Yordan Kostov

declare -A vlans=( 
["300"]="office lab internal, vlan 300, network 10.134.0.0/16"
["557"]="office-novatel-internet, vlan 557"
["1424"]="office lab external, vlan 1424, network 10.133.0.0/27"
["1457"]="Mobiltel-VoIP, vlan 1457, network 10.252.33.0/24"
["1500"]="Internal public, vlan 1500, network 46.107.239.0/26"
["1501"]="Public Internet DMZ, vlan 1501, network 46.107.239.128/25"
["1619"]="3DC HUB VMs, vlan 1619, network 172.16.19.0/24"
["1626"]="FPGA project, vlan 1626, network 172.16.26.0/24"
["1625"]="NSO Projects, vlan 1625, network 172.16.25.0/24"
["1628"]="VDI network, vlan 1628, network 172.16.28.0/24"
["1638"]="3DC Company DMZ, vlan 1638, network 172.16.38.0/24"
["1664"]="3DC Routing, vlan 1664, network 172.16.64.0/24"
["3401"]="NSO-Proxy-DMZ, vlan 3401, network 172.16.33.0/24"
["3497"]="Pixcell-VMs,vlan 3497, network 172.16.34.0/23"
["3498"]="DMZ-SharedMachines, vlan 3498, network 172.16.30.0/24"
["3500"]="Internal DMZ, vlan 3500, network 172.16.24.0/24"
["3501"]="Customers, vlan 3501, network 172.16.22.0/24"
["3502"]="Development & Test, vlan 3502, network 172.16.20.0/24"
["3503"]="Production, vlan 3503,network 172.16.18.0/24"
["3504"]="Internal, vlan 3504, network 192.168.129.0/24"
["3505"]="External Interoute, vlan 3505, network 195.138.130.224/27"
["3506"]="External Novatel,vlan 3506, network 95.158.131.64/27"
["3507"]="Novatel VoIP, vlan 3507, network 84.1.240.216/29" 
)

BOND_LIST=$(xe pif-list network-name-label="Bond 4+5" params=uuid| awk '/^[[:alnum:]]/ {print $5}')
BOND_COUNT=$(xe pif-list network-name-label="Bond 4+5" params=uuid| awk '/^[[:alnum:]]/ {print $5}'|wc -l)
			 	
for i in "${!vlans[@]}"
do
	check=$(xe vlan-list tag="$i")
	if [ "$check" == "" ]; then
		NETWORK_UUID=$(xe network-create name-label="${vlans[$i]}" name-description="${vlans[$i]}") || exit 1
		xe network-param-set other-config:automatic=false uuid=$NETWORK_UUID || exit 1
		echo "${vlans[$i]} created UUID: $NETWORK_UUID"
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
done