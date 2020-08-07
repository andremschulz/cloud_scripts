#!/bin/bash 
SR_ID=4ce36cab-a164-3d2b-87f3-9d6037643b05


declare -A VHDs
VHDs=( 
["git.cy.corp.int_0_snap"]=61
["git.cy.corp.int_1_snap"]=141
["confluence.cy.corp.int_snap"]=51
["passify_snap"]=50
["npm.cy.corp.int_snap"]=101
["maven.cy.corp.int_snap"]=20
["maven2.cy.corp.int_snap"]=131
["surf_snap"]=25
["satis_snap"]=71
["sonarqube.cy.corp.int_snap"]=101
["baker_0_snap"]=301
["baker_1_snap"]=100)


for snap in "${!VHDs[@]}"
do
	echo "Importing $snap with size ${VHDs[$snap]}GB"
	size=$((${VHDs[$snap]}*1024*1024*1024))
	#echo $size
	uuid=`xe vdi-create sr-uuid=$SR_ID name-label="CYHQ-$snap" type=user virtual-size=$size`
	xe vdi-import format=raw uuid=$uuid filename=/run/sr-mount/4b033466-8b1e-7fb7-c1d5-8b34bfe5a2b2/$snap
	RESULT=$?
	if [ $RESULT != 0 ]; then
	  break;
	fi
done

${!VHDs[@]}

