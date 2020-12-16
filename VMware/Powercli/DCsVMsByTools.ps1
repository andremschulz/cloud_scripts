 ## vcenter FQDN### Backup team report
[CmdletBinding()]
Param(
 [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
 [string]$u, 		
 [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
 [string]$p="",
 [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
 [string]$email=""
 )
 

#$vCenters =
#"bghq-bk-vci01.office.corp"
 
. ".\code\statics.ps1"

 $vCenters =
"xx",
"xx",
"xx",
"xx",
"xx"
 

$reports = @()
 ForEach ($v in $vCenters)
 {
	$output = "C:\scripts\vmware-output\$v`VMsByTools"  + (get-date -Format "dd/MM/yyyy/HH/mm") + ".html"
	echo  "==> Logging on $v..."
	if($p -eq "") {
		.\VMsByTools.ps1 -v $v -u $u       -output "$output"
	}
	else {
		.\VMsByTools.ps1 -v $v -u $u -p $p -output "$output"
	}
	eol -lineEnding unix -file $output
	$reports += $output
	echo  " ==> Report complete!"
 }
 
#email -EmailTo "backup.team@NSOGROUP.COM" -Body "VMs by VMware tools for each vcenter in Black environment" -Subject "Global Black: VMs by tools" -attachment $reports

email -Body "VMs by VMware tools for each vcenter in Black environment" -Subject "Global Black: VMs by tools" -attachment $reports

	
