[CmdletBinding()]
Param(
 [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
 [string]$v, 		## vcenter FQDN
 [Parameter(Mandatory=$true,ValueFromPipeline=$false)]
 [string]$u,		## username
 [Parameter(Mandatory=$false,ValueFromPipeline=$false)]
 [string]$p="", 		## password
 [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
 [string]$tag, 		## filter got get VMs by
 [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
 [string]$output="test", 	## file to save report output
 [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
 [string]$sortBy,   ## sort output
 [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
 [string]$colour='#e6f2ff', ## table row colour
 [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
 [string]$title=$v, ## report title
 [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
 [string]$klas="table1" ## class to separate CSS styling from other HTML fragments
)

. ".\code\statics.ps1"

function vmByTools() {
	$vms = Get-VM
	$list = foreach($vm in $vms)
	{
		[PSCustomObject]@{
			"update?" = $vm.Extensiondata.Summary.Guest.ToolsVersionStatus
			"Name" = $vm.Name
			"Tools version" = $vm.Guest.ToolsVersion
			"HW Version" = $vm.ExtensionData.Config.Version
		}
	}
	return $list
}

$log = login $v $u $p
if( $log -eq 0) { 
	vmByTools |Sort-Object -Property "update?"| ConvertTo-Html -Head $(header)  -PreContent "$title - VMs by VMtools version" | Out-File -FilePath $output
	logout($v)
}