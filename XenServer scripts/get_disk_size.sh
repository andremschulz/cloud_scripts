#!/bin/bash
file_input=$1
file_output=$2

declare -i current_full num
declare -i current_used num
		
while IFS='' read -r line || [[ -n "$line" ]]; do
	full=0
	used=0
	vbds=$(xe vm-list name-label="$line" params=VBDs|cut -d':' -f2|sed 's/ //g'|sed 's/;/ /g')
	for vbd in $vbds; do
		vdi=$(xe vbd-list uuid="$vbd" params=vdi-uuid |cut -d' ' -f8)
		if [[ $vdi != *"not"* ]]; then
			current_full=$(xe vdi-list uuid="$vdi" params=virtual-size |cut -d' ' -f8)
			full=$(( full + current_full / 1024 / 1024 / 1024 ))
			current_used=$(xe vdi-list uuid="$vdi" params=physical-utilisation |cut -d' ' -f8)
			used=$(( used + current_used / 1024 / 1024 / 1024 ))
			#echo "vbd: $vbd, vdi: $vdi , full: $current_full, used: $current_used"
		fi
	done
	echo "$line,$full,$used"
	printf "$line,$full,$used\n" >> $file_output
	
done < "$file_input"