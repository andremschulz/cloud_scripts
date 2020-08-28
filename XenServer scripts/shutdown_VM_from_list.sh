#!/bin/bash

############################
# Script prepared by Boris Stankov 
# Email address boriss@nsogroup.com
# Initial version on 24-Sep-2019.
############################

#Input file with all the names (name-labels) of the machines you want to shutdown
vmlist=vm_list.txt
#We will add to the shutted down VM the following strink in the name-label parameter "0000-"
addname="0000-"
#We will add the following text to the description in the name-description field of each VM.
adddesc="Updated by Boris Stankov. Please delete after 1st of Jan 2020.     "


#####
#Important variable:
#	vmname - name of the VM that needs to be shutted down. Taken from a text file.
#	vmid - each VM has unique ID in the XEN called UUID. SOme of the operations must be completed only by this ID.
#	newname - this is used only for printing purposes to the user monitoring the script.
#	olddesc - this is used for setting up new description without losing the old one. So I am saving the old description of the VM here. Then I am adding it to the new one.
#	newdesc - this is combination of the text behind $adddesc and $olddesc.
#####

cat $vmlist | while read vmname
do
	echo " "
	echo "Start shutdown process of $vmname!"
	xe vm-shutdown name-label=$vmname
	echo "VM $vmname is now shutted down."
	echo " "
	sleep 2
	echo "Getting UUID for $vmname"
	vmid=$(xe vm-list name-label=$vmname| grep uuid | cut -c 24-59)
	echo "UUID for $vmname is $vmid."
	echo " "
	sleep 2
	echo "Changing the name-label of the machines inside XEN for $vmname with UUID $vmid"
	xe vm-param-set uuid=$vmid name-label=$addname$vmname
	newname=$(xe vm-param-get uuid=$vmid param-name=name-label)
	echo "New name of the machine is: $newname."
	echo " "
	sleep 2
	echo "Chaning the name-description of the machine inside XEN for $vmname with UUID $vmid"
	olddesc=$(xe vm-param-get uuid=$vmid param-name=name-description)
	xe vm-param-set uuid=$vmid name-description="$adddesc $olddesc"
	newdesc=$(xe vm-param-get uuid=$vmid param-name=name-description)
	echo "New description of the machine is $newdesc."
	echo " "
	sleep 1
	echo "Everything is ready for $vmname with UUID $vmid. Going to next machine."
	echo " "
	echo " "
	echo "------------------------------------------"
	sleep 2
done
echo " "
echo " " 
echo "------- Script completed ------------"