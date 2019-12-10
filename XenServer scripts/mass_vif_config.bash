#!/bin/bash

uuids=( "308cae4d-5c84-bef1-0f92-87606c285b7a"
"f60c7608-3730-4c27-dc6d-add04ba930a2"
"dbf1aa7a-1a13-9aa2-56ee-8f54265fab90"
"0ccb4905-18cd-266e-9768-379a7a208794"
"1520c037-0c7b-46e2-de8d-7b17cc892482" )

for i in "${uuids[@]}"
do
	result1=`xe vif-param-set uuid=$i other-config:ethtool-gso="off"`
	result2=`xe vif-param-set uuid=$i other-config:ethtool-ufo="off"`
	result3=`xe vif-param-set uuid=$i other-config:ethtool-tso="off"`
	result4=`xe vif-param-set uuid=$i other-config:ethtool-sg="off"`
	result5=`xe vif-param-set uuid=$i other-config:ethtool-tx="off"`
	result6=`xe vif-param-set uuid=$i other-config:ethtool-rx="off"`
done