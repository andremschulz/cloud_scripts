#!/bin/bash
# Description: The script configures VM autostart option when electricity outage occurs and all xens are rebooted.
# Created on 14-Oct-2016 by Jordan Kostov, email: yordan.kostov@circles.bz

helptext="$(basename $0) [state] [VM name] ...
The script configures VM autostart option when electricity outage occurs and all xens are rebooted.
Example: $(basename $0) -true hub1-vm \"pixcell server\"  \"FusionHub - new\" TEST

Mandatory variables:
[state] argument can be:
			-true - this option enables autostart on VMs
			-false - this option disables autostart on VMs
			-status - this prints the current setting of the VMs
			-help or -h or --help - will print this help menu
[VM name] - argument is the name of the VM which power state should be modified. User can list as many vms as he wants. 
			Example: $(basename $0) -status vm_name1 vm_name2 vm_name3 vm_name4 vm_name5 vm_name6 and so on
			NOTE: When VM name includes spaces it should be put in quotes.
			
IMPORTANT: If VM name has spaces put the whole VM name in quotes. 
Example: ./$(basename $0) -true \"pixcell server\" \"FusionHub - new\""
 
case "$1" in
-true)
	state="true" ;;
-false)
	state="false" ;;
-status)
	state="status" ;;
-help | -h | --help)
	echo "$helptext"
	exit 0;;
*)
	echo "Invalid state. Check $(basename $0) -help | -h or --help option."
exit 5 ;;
esac

pool_id=$(xe pool-list params=uuid | awk '{print $5}')
xe pool-param-set uuid=$pool_id other-config:auto_poweron=true

for i in "${@:2}"
do
	vm_id=$(xe vm-list name-label="$i" params=uuid | awk '{print $5}')
	if [ "$vm_id" == "" ]; then
		echo "There is no such VM called $i. Check your spelling. Exit..."
		exit 10;
	fi
	if [ "$state" == "status" ]; then
		power=$(xe vm-param-get uuid=$vm_id param-name=other-config param-key=auto_poweron 2> /dev/null)
		if [ "$power" != "true" ]; then
			power="false"
		fi
		echo "$i VM autopoweron is set to $power."
	else
		xe vm-param-set uuid=$vm_id other-config:auto_poweron=$state
		if [ "$?" != "0" ];	then
			echo "VM $i poweron state could not be set."
		else
			echo "VM $i poweron state is set to $state."
		fi
	fi
done

echo "Done!"