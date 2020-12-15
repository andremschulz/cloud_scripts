#!/bin/bash

xe vdi-list|

xe vdi-list | \
awk '{if ( $0 ~ /uuid/) {uuid=$5} \
 if ($0 ~ /name-label/) { $1=$2=$3="";vmname=$0; printf "%s - %s\n", vmname, uuid}}'
 
 
 
xe vdi-list params=all | awk '{if ( $0 ~ /name-label ( RW)/) {name=$4} if ( $0 ~ /vbd-uuids/) {printf "%s - vbd: %s\n", $name, $3}}'
xe vdi-list params=all | awk '{if ( $0 ~ /name-label/) {name=$4}' if ( $0 ~ /vbd-uuids/) {printf "%s - vbd: %s\n", $name, $3}}'

xe vdi-list params=name-label,vbd-uuids | awk '{if ( $0 ~ /name-label \(/) {name=$2; printf "name: %s\n", $name}}'



awk '{if ( $0 ~ /uuid/)       {uuid=$5} if ($0 ~ /name-label/) { $1=$2=$3=""; vmname=$0; printf "%s - %s\n", vmname, uuid}}'
awk '{if ( $0 ~ /name-label/) {name=$2} if ($0 ~ /vbd-uuids/)  { $1=$2=$3=""; print $name}}'
xe vdi-list params=name-label,vbd-uuids | awk '{if ( $0 ~ /name-label/) {name=$2} if ($0 ~ /vbd-uuids/) {print $name}}'
 
 xe vdi-list params=name-label,vbd-uuids |awk '{if ( $0 ~ /name-label/) {name=$2} if ($0 ~ /vbd-uuids/)  { $1=$2=$3=""; print $name}}'

xe vdi-list | awk -F  ":" '{if ( $0 ~ /name-label/) {uuid=$1;print $uuid}}'


xe vdi-list params=name-label,uuid,vbd-uuids  sr-uuid=cd5c4763-65a4-a44d-7687-e1015e414acc
vhd-util scan -f ?m "VHD-*" -l VG_XenStorage-cd5c4763-65a4-a44d-7687-e1015e414acc