#!/bin/bash
XEN_COUNT=$(xe host-list params=name-label | awk '{print $5}'| grep -v '^$'|wc -l)
XEN_LIST=$(xe host-list params=name-label | awk '{print $5}'| grep -v '^$')

echo "date '+%D--%X'#Configuring multipath on $XEN_COUNT XenServers"
i=1;
while [ "$i" -le "$XEN_COUNT" ]; do
	HOST=$(echo $XEN_LIST |awk -v var=$i '{print $var}')
	HOST_UUID=$(xe host-list name-label=$HOST |grep uuid |awk '{print $5}')
	echo "date '+%D--%X'#Configuring $HOST"
	xe host-disable uuid=$HOST_UUID
	sleep 2
	xe host-param-set other-config:multipathing=true uuid=$HOST_UUID
	xe host-param-set other-config:multipathhandle=dmp uuid=$HOST_UUID
	sleep 2
	xe host-enable uuid=$HOST_UUID
	echo "$HOST new multipath config: `multipath -ll`"
	i=$((i+1))
done

