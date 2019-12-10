#!/bin/bash

FILE="$1"

echo "Removing empty lines..."
sed -i '/^[[:space:]]*$/d' $FILE
echo "Removing name-label..."
sed -i -e 's/name-label ( RW)    : //g' $FILE
echo "Removing networks label..."
sed -i ':a;N;$!ba;s/\n      networks (MRO):/,/g' $FILE
echo "Removing duplicate IP..."
sed -i 's/ 0\/ip: .* 0\/ipv4\/0: //g'  $FILE
#echo "Removing 0/ip..."
#sed -i 's/ 0\/ip: //g' $FILE
#echo "Removing 0/ipv4/0..."
#sed -i 's/ 0\/ipv4\/0: //g' $FILE
echo "Removing 0/ipv6/0..."
sed -i 's/ 0\/ipv6\/0: //g' $FILE
echo "Removing Control Domain..."
sed -i '/^Control domain on host/d' $FILE

echo "Done"


### Debug sed '/^[[:space:]]*$/d' vms.txt |sed -e 's/name-label ( RW)    : //g' |sed ':a;N;$!ba;s/\n      networks (MRO):/,/g'|sed 's/ 0\/ip: //g'|sed 's/ 0\/ipv4\/0: //g'|sed 's/ 0\/ipv6\/0: //g'|sed '/^Control domain on host/ d' 
