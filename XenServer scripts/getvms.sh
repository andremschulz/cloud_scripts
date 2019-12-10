#!/bin/bash
filename=$1
while IFS='' read -r line || [[ -n "$line" ]]; do
           ip=$(xe vm-list name-label=$line params=networks|cut -d':' -f3)
	if [ "$ip" == "" ]; then
	   echo "$line" >> missing.txt
	else
           echo "$line with ip $ip" >>  ips.txt
	fi
done < "$filename"




vbds=$(xe vm-list name-label=$line params=VBDs|cut -d':' -f2)

vdi=$(xe vbd-list uuid=6dfac922-9401-e16a-5833-7152f9f39b81 params=vdi-uuid |cut -d' ' -f8)