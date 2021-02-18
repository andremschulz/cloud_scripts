#!/bin/bash

UUIDs=($(xe vm-list params=uuid | cut "-c17-"));
## meta arrays
declare -A TagIndex
declare -A TagVMCount
declare -A VMsByIndex

## arrays with data
declare -A VMnames   # collects the VM names
declare -A VMdesc    # collects description fields
declare -A VMsizes   # collects the VM sizes
declare -A VMstates  # collects the VM power states
declare -A VMips	 # collects the VM ip addresses
declare -A VMtags    # collects the VM power states


skipVM() {
	local name=$1;
	local id=$2;
	if [[ "$name" == "Control domain"* ]]; then
		echo "$id is DOMAIN CONTROLLER skipping...";
		return 1;
	fi
	return 0;
}

initTAG() {
	local tag="$1";
	local length="${#TagIndex[@]}";
	TagIndex["$tag"]=$((length + 1));
	TagVMCount["tag"]=0;
}

addVM() {
	local tag="$1";
	local id="$2";
	local count=$3;
	TagVMCount[$tag]=$count;
	VMsByIndex[$tag,${TagVMCount[$tag]}]=$id;
}

htmlReport() {
	 local output=$1;
	 local class=$2;
	 local cluster="Clustername";
	 local head="VMs by TAG"
	 echo "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\"  \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">
<html xmlns=\"http://www.w3.org/1999/xhtml\">
<head>
$head
</head><body>
<table>
</table>
<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\"  \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\"> <html xmlns=\"http://www.w3.org/1999/xhtml\"> <head>  <style>
 body{
 font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
 }
 
 table.t$class{
  border-collapse: collapse;
  border: none;
  font: 10pt Verdana, Geneva, Arial, Helvetica, sans-serif;
  color: black;
  margin-bottom: 10px;
 }
 
 table.t$class td{
  font-size: 12px;
  padding-left: 0px;
  padding-right: 20px;
  text-align: left;
 }
 
 table.t$class th{
  font-size: 12px;
  font-weight: bold;
  padding-left: 0px;
  padding-right: 20px;
  text-align: left;
 }
 
 h2{
  clear: both; font-size: 130%;color:#00134d;
 }
 
 p{
  margin-left: 10px; font-size: 12px;
 }
 
 table.t$class.list{
  float: left;
 }
 
 table.t$class tr:nth-child(even){background: #FFEFE6;} 
 table.t$class tr:nth-child(odd) {background: #FFFFFF;}

 div.column {width: 320px; float: left;}
 div.first {padding-right: 20px; border-right: 1px grey solid;}
 div.second {margin-left: 30px;}

 table.t$class{
  margin-left: 10px;
 }
 >
 </style> </head>" > $output;
	 echo "<body> $cluster <table class=\"t$class\">" >> $output;
	 echo "<colgroup><col/><col/><col/><col/></colgroup>" >> $output;
	 echo "<tr><th>Name</th><th>State</th><th>Total size(GB)</th><th>Tag</th><th>IP address</th><th>description</th></tr>" >> $output;
	
	 for UUID in "${UUIDs[@]}"
	 do
		skipVM "${VMnames[$UUID]}" "$UUID"
		if [ "$?" == "1" ]; then continue; fi
		echo "<tr><td>${VMnames[$UUID]}</td><td>${VMstates[$UUID]}</td><td>${VMsizes[$UUID]}</td><td>${VMtags[$UUID]}</td><td>${VMips[$UUID]}</td><td>${VMdesc[$UUID]}</td></tr>" >> $output
	 done
	 echo "</table>  </body>" >> $output
}

## declare arrays for vms with no tag
initTAG "NONE"

for UUID in "${UUIDs[@]}" 
do

### get VM name
	VMNAME="$(xe vm-list uuid=$UUID params=name-label |cut "-c23-");"
	
	### skip non VM nodes
	VMnames["$UUID"]="$VMNAME";
	skipVM "$VMNAME" "$UUID"
	if [ "$?" == "1" ]; then continue; fi

### get VM description
	VMdesc["$UUID"]="$(xe vm-list uuid=$UUID params=name-description| awk '{gsub(/name-description \( RW\)    \: /,"")}1'|grep -v "^$")";
	#echo "${VMdesc[$UUID]}"
### get disk total size
	VMVBDS=($(xe vm-disk-list uuid=$UUID| grep "VDI:" -A 1 |grep uuid |cut "-c26-"))
	VMSIZE=0;
	for VBD in "${VMVBDS[@]}"
	do
		disk_size=($(xe vdi-list uuid=$VBD params=physical-utilisation| cut "-c33-"));
		VMSIZE=$(($VMSIZE+$disk_size));
	done
	VMsizes["$UUID"]=$((VMSIZE / 1073741824));
	
### Get power state
	VMstates["$UUID"]="$(xe vm-list uuid=$UUID params=power-state  |cut "-c24-")";
	#echo "state ${VMstates[$UUID]}"
	
### Get IPs
	VMips["$UUID"]="$(xe vm-list uuid=$UUID params=networks |cut "-c21-" | awk '{gsub(/.\/ip: |.\/ipv.[^;]*;/,"")}1' | awk '{gsub(/.\/ipv.*$/,"")}1' | awk '{gsub(/ /,"")}1')"
### Populate tag arrays (for future filter use)
	IFS=', ' read -r -a VMTAG <<< "$(xe vm-list uuid=$UUID params=tags  | cut "-c17-")";
	VMtags["$UUID"]="${VMTAG[@]}";
	flag=0;
	for t in "${VMTAG[@]}"
	do
		for b in "${!TagIndex[@]}"
		do
			if [ "$t" == "$b" ]; then
				addVM "$t" "$UUID" $((TagVMCount[$t] + 1))
				#echo "$t ${TagVMCount[$t]} - $UUID $VMNAME"
				flag=1;
				break;
			fi
		done
		if [ $flag == 0 ]; then
			flag=2;
			initTAG "$t";
			addVM "$t" "$UUID" $((TagVMCount[$t] + 1));
			#echo "$t ${TagVMCount[$t]} - $UUID $VMNAME"
		fi
	done
	if [ $flag == 0 ]; then
		t="NONE";
		cnt=$((TagVMCount["$t"] + 1));
		addVM "$t" "$UUID" $((TagVMCount["$t"] + 1));
		#echo "$t ${TagVMCount[$t]} - $UUID $VMNAME"
	fi
done
echo "Doing reports..."
htmlReport "/tmp/test.html" 1
for idx in "${!TagIndex[@]}";
do
	echo "$idx - ${TagVMCount[$idx]}";
done


