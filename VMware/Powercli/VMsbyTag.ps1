[CmdletBinding()]
Param(
 [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
 [string]$v, 		## vcenter FQDN
 [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
 [string]$u,		## username
 [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
 [string]$p="", 		## password
 [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
 [string]$tag="notag", 		## filter got get VMs by
 [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
 [string]$category="", 		## filter got get VMs by
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

function VMsbyTag($v, $tag){
	
	$returnVars = @{}
	if($tag -eq "notag") {
		$vms = Get-VM -Location (Get-Datacenter -Server $v).Name
		$list = foreach($vm in $vms) {
			$flag = 0
			$vmtag = (Get-TagAssignment -Entity $vm).tag.Category.Name
			foreach($i in (Get-TagAssignment -Entity $vm).tag.Category.Name) {
				if($i -eq $category) {
					#write-host "category $i - $vm"
					$flag = 1
					break						
				}
			}
			if( $flag -eq 0) { varsBackup }
		}
	}
	else {
		$vms = Get-VM -Tag $tag -Location (Get-Datacenter -Server $v).Name
		$list = foreach($vm in $vms) { varsBackup }
	}
	
	$returnVars.Add("content", $list)
	#$returnVars.Add("error", $flag)
	return $returnVars
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
	
	#$ips=$vm.guest.net.ipaddress
	#if ($ips.count -gt 1) {$ips=$vm.guest.net.ipaddress[0] + " " + $vm.guest.net.ipaddress[1]}
}

function varsBackup {
	
	if (($vm |Get-CDDrive).IsoPath)	{ $iso = "yes" } else { $iso = "" }
	[PSCustomObject]@{
		"Name" = $vm.Name
		"State" = $vm.PowerState
		"Host" = $vm.VMHost.Name
		"Total size(GB)" = [System.Math]::Round($vm.UsedSpaceGB)
		"Version" = $vm.ExtensionData.Config.Version
		"OS" = $vm.ExtensionData.Config.GuestFullName
		"ISO?" = $iso
	}
}

$log = login $v $u $p
if( $log -eq 0) { 
	$vars = VMsbyTag $v $tag
	if($tag -eq "notag") { $title = "$v - VMs with no tag in category `"$category`" (even if they have other tags)" }
	$content = $vars["content"] |Sort-Object -Property Name| ConvertTo-Html -Head $( header($klas)) -PreContent $title
	$content = $content -replace '<table>',"<table class=`"t$klas`">"
	#$content = VMsbyTag |Sort-Object -Property Name| ConvertTo-Html -Head $(header_backup) -PreContent $title
	#$content = $content -replace '<table>',"<table class=`"$klas`">" | Add-Content c:\TEMP\$output
	logout($v)
	return $content
}
