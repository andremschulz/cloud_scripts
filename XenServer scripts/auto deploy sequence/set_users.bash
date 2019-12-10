#!/bin/bash
NAME_IDS=$(xe subject-list roles=vm-power-admin params=uuid |awk '{print $5}'| grep -v '^$' )
NAME_LENGTH=$(xe subject-list roles=vm-power-admin params=uuid |awk '{print $5}'| grep -v '^$'|wc -l )

i=1
while [ "$i" -le "$NAME_LENGTH" ]; do
		UUID=$(echo $NAME_IDS |awk -v var=$i '{print $var}')
		echo "UUID $i is $UUID"
		xe subject-role-add uuid=$UUID role-name=vm.pool_migrate
		i=$((i+1))
done

 xe subject-list roles:contains=vm.pool_migrate