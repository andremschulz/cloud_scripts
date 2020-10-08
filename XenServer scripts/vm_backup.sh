#!/bin/bash

helptext="
Usage:  $(basename $0) [Options]...
Description The script snapshots VMs with particular xen tag.
Example  $(basename $0) -t test -k 7 -x 732ff252-a75d-ae63-298f-32c38bbd03b8 -m yordan.kostov@circles.bz

Mandatory variables
        -t                      Followed by string. Represents the tag used for BM filtering
        -k              Followed by integer. Number of latest snapshots that should be kept in Xen

Optional variables
        -x                      Followed by string. The ID of the attached NFS. must have write access.
        -m              Followed by string. this is the notification e-mail address."

#defining variables
tag=0;                                                                          #tag from XEN - variable 0
snap_count=0;                                           #counts the number of snapshots made by the system
snap_array=();                                          #array of all snapshots of the current VM
vm_array=();                                                    #List of VMs for backup
vm_array_complete=( " " );      #List of VMs from vm_array successfully backed up.
vm_array_off=( " " );                           #List of vms from vm_array that are also shutdown
vm_array_failed=();                             #List of vms from vm_array that are not backed up
vm_state=0;                                                     #VM power state 0 -off; 1 - on.

checkInteger () {               #check variable consistency

    if [ "$1" -eq "$1" ] 2>/dev/null; then
        return 0;
    else
        errors 3;
    fi
}

snap_create () {                        #create snapshot

    logger -p news.info "Creating snapshot...."
    snap_id=($(xe vm-snapshot vm=${vm_array[i]} new-name-label=${vm_array[i]}@$tag@$data));
    if [ "$?" -ne "0" ]; then
        backup_failed;
        errors 4;
    fi
        logger -p news.info "Snapshot created!"
}

snap_export () {                        #export snapshot

    logger -p news.info "Exporting snapshot $snap_id ..."
    logger -p news.info "Exporting snapshot ${vm_array[i]};"
    xe vm-export vm=$snap_id filename=/var/run/sr-mount/$NFS/${vm_array[i]}@$tag@$data;
    if [ "$?" -ne "0" ]; then
        backup_failed;
        errors 5;
    fi
    logger -p news.info "Export completed!;"
}

snap_delete (){            #delete snapshot

	local x=0; #counter 1
	local y=0; #counter 2
	local pass=0; #increase with one everytime Array[x] variable is bigger than array[y] variable. used for calculating snapshot aging.
	local snap_uuid=0; #UUID of the snapshot
	qwe=$6[@]
	array=("${!qwe}")

    while [ "$x" -lt "$snap_count" ]
    do
        checkInteger "${array[x]}"
        x=$[x+1];
    done
	x=0;
    while [ "$x" -lt "$snap_count" ]
    do
        while [ "$y" -lt "$snap_count" ]
        do
            if [ "$x" != "$y" ];then
                if [ "${snap_array[x]}" -gt "${snap_array[y]}" ] ;then
                    pass=$[pass+1];
                fi
            fi
            y=$[y+1];
        done
        if [ "$[snap_count-pass]" -gt "$snap_keep" ]; then
            snap_uuid=($(xe snapshot-list snapshot-of=$uuid name-label=${vm_array[i]}@$tag@${snap_array[x]} |grep uuid|cut -d ":" -f 2 |sed  's/^[ \t]*//'))
            xe snapshot-uninstall snapshot-uuid="$snap_uuid" force=true
            if [ "$?" -ne "0" ]; then
                backup_failed;
                errors 6;
            fi
            logger -p news.info "Snapshot ${snap_array[x]} purged! uuid:  $snap_uuid";
        fi
        pass=0;
        y=0;
        x=$[x+1];
    done
}

errors () {                                     #list of errors

	local description;
	case "$1" in
		"2") logger -p news.err "Script will quit. -t and -k are mandatory tags";
			  description="Script will quit. missing variables";
		;;
		"3")  logger -p news.err  "Integer is required!";
			  description="Integer is required";
		;;
		"4") logger -p news.crit "Snapshot failed for VM ${vm_array[i]}. The following VMs were not backed up ${vm_array_failed[@]}";
			 description="Snapshot failed for VM ${vm_array[i]}. The following VMs were not backed up ${vm_array_failed[@]}";
		;;
		"5") logger -p news.crit "Exporting operation failed.  The following VMs were not backed up ${vm_array_failed[@]}";
				description="Exporting operation failed. The following VMs were not backed up ${vm_array_failed[@]}";
		;;
		"6") logger -p news.crit "Snapshot purge failed. Snapshot UUID $snap_uuid. The following VMs were not backed up ${vm_array_failed[@]}";
				description="Snapshot purge failed. Snapshot UUID $snap_uuid. The following VMs were not backed up ${vm_array_failed[@]}";
		;;
		"*") logger -p news.crit "General error. The following VMs were not backed up ${vm_array_failed[@]}";
				description="General error. The following VMs were not backed up ${vm_array_failed[@]}";
		;;
	esac

	send_mail  "Backup error" "$description"
	logger -p news.info "# # # # # # # # # # # # Script finished! # # # # # # # # # # # #";
	exit $1;
}

send_mail (){                           #send mail function
	logger -p news.info "### Sending mail.... ";
	if [ -n "$mail_group" ]; then
		local subject="$1";
		local description1="$2"
		local description1_var=("${!3}");
		local description2="$4";
		local description2_var=("${!5}");
		local host=$(hostname);

ssmtp "$mail_group"<<END_MAIL
To: $mail_group;
From: xen@tracksystem.info;
Subject: $host $subject;

${description1[@]}  ${description1_var[@]}
asd
${description2[@]}  ${description2_var[@]}

More information can be found in /var/log/backup.sh
END_MAIL
	fi
	logger -p news.info "### Mail sent!";
}

backup_failed (){
	local a="$i"
	while [ "$a" -le "${#vm_array[@]}" ]; do
	vm_array_failed=(${vm_array_failed[@]} ${vm_array[a]})
			a=$[a+1];
	done
}


grep master /etc/xensource/pool.conf
if [ $? == 1 ]; then
	logger -p news.info "This is slave. Only master does backups."
	exit 0;
fi

logger -p news.info "########################################################################";
logger -p news.info "Starting scheduled backup script!";
logger -p news.info "Checking for required variables.";


while getopts "t:k:x:m:" opt; do
        case "$opt" in
			t) tag=$OPTARG;
			;;
			k) snap_keep=$OPTARG; #how much snapshots to keep behind - Variable 1
			;;
			x)  NFS=$OPTARG;
			;;
			m) mail_group=$OPTARG;
			;;
			?) echo $helptext;
			exit 0;
     esac
done

if [ -z "$tag" ] || [ -z "$snap_keep" ]; then
	echo "Script will quit. -t and -k are mandatory tags;"
	echo "$helptext"
	errors 2;
fi
checkInteger "$snap_keep";
vm_array=($(xe vm-list tags:contains=$tag| grep "label"| cut "-c24-"));

logger -p news.info "VMs for backup ${vm_array[@]};"
for  (( i = 0; i < "${#vm_array[@]}"; i++ ))
do
	logger -p news.info "Collecting VM information;"
	uuid=($(xe vm-list name-label=${vm_array[i]}| grep "uuid"| cut -d  " " -f 15));
	vm_state=($(xe vm-list uuid=$uuid |grep "power-state ( RO): running"| wc -l));
	logger -p news.info "VM name = ${vm_array[i]}    VM uuid = $uuid";
	data=($(date +"%Y%m%d%H%M"));

	if [ "$vm_state" == "1" ]; then
		snap_create;
		snap_count=($(xe snapshot-list snapshot-of=$uuid |grep name-label |grep "${vm_array[i]}@$tag@" | wc -l));
		if [ -n "$NFS" ]; then
			snap_export "$snap_id";
		fi
		if [ "$snap_count" -gt "$snap_keep" ]; then
			logger -p news.info "Collecting all snapshots for  VM ${vm_array[i]};"
			snap_array=($(xe snapshot-list snapshot-of=$uuid |grep "name-label" |grep "${vm_array[i]}@$tag@" | cut -d "@" -f 3));
			logger -p news.info "Keeping the latest $snap_keep snapshots and purging rest...";
			# This is the snapshot comparison engine
			snap_delete "${vm_array[i]}" "$uuid" "$tag" "$snap_keep" "$snap_count"  snap_array;
		fi
		vm_array_complete=( "${vm_array_complete[@]}" "${vm_array[i]}" );
	else
		logger -p news.warn "VM ${vm_array[i]} is turned off no backup wiil be done";
		vm_array_off=( "${vm_array_off[@]}" "${vm_array[i]}" );
	fi

done
send_mail "Backup report"  "$(( m = ${#vm_array_complete[@]} - 1 )) VMs successfully backed up:" vm_array_complete[@]  "$(( n = ${#vm_array_off[@]} - 1 )) VMs were skipped due to being powered off:"  vm_array_off[@]
logger -p news.info "Backup was successful for the following VMs: ${vm_array_complete[@]}";
logger -p news.info "The following VMs were skipped due to being powered off: ${vm_array_off[@]}";
logger -p news.info "Launching backup collection.....;"
#ssh root@192.168.129.33 optomnibinomnib -datalist XEN-Snapshot-TEST-Backup
#if [ $ != 0 ]; then
#               logger -p news.err Failed.;
#               send_mail "DP backup failed DP backup phase failed to launch
#else
#               logger -p news.info "Success";
#fi
logger -p news.info "# # # # # # # # # # # # Script finished! # # # # # # # # # # # #";
