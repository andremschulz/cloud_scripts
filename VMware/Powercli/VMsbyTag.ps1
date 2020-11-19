[CmdletBinding()]
Param(
 [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
 [string]$v, 		## vcenter FQDN
 [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
 [string]$u,		## username
 [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
 [string]$p="", 		## password
 [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
 [string]$tag, 		## filter got get VMs by
 [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
 [string]$sortBy,   ## sort output
 [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
 [string]$colour='#e6f2ff', ## table row colour
 [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
 [string]$title=$v + " - " + $tag, ## report title
 [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
 [string]$klas="table1" ## class to separate CSS styling from other HTML fragments
)

. ".\code\statics.ps1"

##$title = $v + " - " + "high"
##write-host "$title"

function VMsbyTag($tag){
	
	if($tag -eq $nul)
	{
		$vms = Get-VM
		$list = foreach($vm in $vms)
		{
			$vmtag = Get-TagAssignment -Entity $vm
			#if($vmtag -eq $null) { varsAll }
			if($vmtag -eq $null) { varsBackup }
		}
	} else
	{
		$vms = Get-VM -Tag $tag
		#$list = foreach($vm in $vms) { varsAll }
		$list = foreach($vm in $vms) { varsBackup }
	}
		
	return $list
}

function varsAll {
	[PSCustomObject]@{
		"Name" = $vm.Name
		"Hostname" = $vm.ExtensionData.Summary.Guest.HostName
		"OS" = $vm.ExtensionData.Config.GuestFullName
		"vCPUs" = $vm.NumCpu
		"Cores" = $vm.CoresPerSocket
		"Memory" = $vm.MemoryGB
		"NICS" = $vm.ExtensionData.Summary.Config.NumEthernetCards
		"IPs" = $vm.Guest.IPAddress -join '|'
		"UUID" = $vm.ExtensionData.Config.Uuidk
		"Host" = $vm.VMHost.Name
		"Notes" = $vm.Notes
		"Version" = $vm.ExtensionData.Config.Version
		"attached ISO" = ($vm |Get-CDDrive).IsoPath
	}
}

function varsBackup {
	
	if (($vm |Get-CDDrive).IsoPath)	{ $iso = "yes" } else { $iso = "" }
	[PSCustomObject]@{
		"Name" = $vm.Name
		"Host" = $vm.VMHost.Name
		"Version" = $vm.ExtensionData.Config.Version
		"OS" = $vm.ExtensionData.Config.GuestFullName
		"ISO?" = $iso
	}
}

#$ips=$vm.guest.net.ipaddress
#if ($ips.count -gt 1) {$ips=$vm.guest.net.ipaddress[0] + " " + $vm.guest.net.ipaddress[1]}

$log = login $v $u $p
if( $log -eq 0) { 
	$frag = VMsbyTag |Sort-Object -Property Name| ConvertTo-Html -Head $(header($klas)) 
	$frag = $frag -replace '<table>',"<table class=`"$klas`">"
	#$frag = VMsbyTag |Sort-Object -Property Name| ConvertTo-Html -Head $(header_backup) -PreContent $title
	#$frag = $frag -replace '<table>',"<table class=`"$klas`">" | Add-Content c:\TEMP\$output
	logout($v)
	return $frag
}
